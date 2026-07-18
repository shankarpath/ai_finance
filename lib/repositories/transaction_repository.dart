import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show compute;

import '../models/parsed_sms.dart';
import '../services/ai_merchant_categorizer.dart';
import '../services/ai_sms_parser.dart';
import '../services/categorizer_service.dart';
import '../services/coach_service.dart';
import '../services/database_service.dart';
import '../services/duplicate_detector.dart';
import '../services/merchant_normalizer.dart';
import '../services/notification_capture_service.dart';
import '../services/notification_service.dart';
import '../services/parser_service.dart';
import '../services/settings_service.dart';
import '../services/sms_service.dart';
import '../services/subscription_detector.dart';
import '../utils/formatters.dart';

/// Orchestrates the full ingestion pipeline:
/// raw SMS → parse → normalize merchant → rule-categorize → persist,
/// followed by enrichment (subscription detection + AI categorization).
class TransactionRepository {
  final SmsService _sms;
  final ParserService _parser;
  final MerchantNormalizer _normalizer;
  final CategorizerService _categorizer;
  final AiMerchantCategorizer _aiCategorizer;
  final AiSmsParser _aiSmsParser;
  final NotificationService _notifications;
  final CoachService _coach;
  final SettingsService _settings;
  final AppDatabase _db;
  final DuplicateDetector _dupes;

  /// Second ingestion source: payment-app notifications (nullable for tests).
  final NotificationCaptureService? _notifCapture;

  /// Debits at or above this (₹) trigger a large-transaction notification.
  static const _largeTxnThreshold = 3000.0;

  /// Uncertain guesses below this amount (₹) skip the review queue — asking a
  /// human to review a ₹15 chai payment costs more attention than it protects.
  static const _reviewMinAmount = 200.0;

  TransactionRepository({
    required SmsService sms,
    required ParserService parser,
    required MerchantNormalizer normalizer,
    required CategorizerService categorizer,
    required AiMerchantCategorizer aiCategorizer,
    required AiSmsParser aiSmsParser,
    required NotificationService notifications,
    required CoachService coach,
    required SettingsService settings,
    required AppDatabase db,
    DuplicateDetector dupes = const DuplicateDetector(),
    NotificationCaptureService? notifCapture,
  })  : _sms = sms,
        _parser = parser,
        _normalizer = normalizer,
        _categorizer = categorizer,
        _aiCategorizer = aiCategorizer,
        _aiSmsParser = aiSmsParser,
        _notifications = notifications,
        _coach = coach,
        _settings = settings,
        _db = db,
        _dupes = dupes,
        _notifCapture = notifCapture;

  Stream<List<Transaction>> watchAll() => _db.watchAll();

  Stream<List<Transaction>> watchBetween(DateTime start, DateTime end) =>
      _db.watchBetween(start, end);

  /// Scans the inbox, imports new transactions, captures the ones the parser
  /// couldn't read into the never-drop queue, then enriches. Returns the number
  /// of new transactions written.
  Future<int> syncInbox() async {
    final inbox = await _sms.readInbox();
    final memory = await _db.merchantMemoryMap();
    final aliases = await _db.merchantAliasMap();
    // Parsing thousands of SMS is regex-heavy — run it off the UI thread so
    // the app stays responsive during a full inbox scan.
    final scan =
        await compute(scanInboxBatch, ParseBatchInput(inbox, memory, aliases));

    final entries = <(ParsedSms, TransactionsCompanion)>[
      for (final e in scan.parsed)
        (e.parsed, _toCompanion(e.parsed, e.canonical, e.result)),
    ];

    var imported = 0;
    await _db.transaction(() async {
      for (final (parsed, companion) in entries) {
        if (await _isCrossProviderDuplicate(parsed)) continue;
        if (await _db.insertIfNew(companion)) imported++;
        // If this SMS was previously stuck in the review queue, it's handled now.
        await _db.clearUnparsedBySmsId(parsed.smsId);
      }
      // Never drop: record every financial-sender message we couldn't parse.
      for (final u in scan.unparsed) {
        await _db.insertUnparsedIfNew(UnparsedMessagesCompanion.insert(
          smsId: u.smsId,
          body: u.body,
          sender: Value(u.sender),
          receivedAt: u.receivedAt,
          reason: u.reason,
          createdAt: DateTime.now(),
        ));
      }
    });

    await _settings.setLastScan(ScanSummary(
      scanned: scan.scanned,
      parsed: scan.parsed.length,
      ignored: scan.ignored,
      needsAttention: scan.unparsed.length,
      at: DateTime.now(),
    ));

    imported += await ingestNotifications();

    await enrich();
    return imported;
  }

  /// Drains captured payment-app notifications (the second ingestion source —
  /// catches transactions that never produce an SMS, e.g. RuPay-CC-on-UPI) and
  /// runs them through the same classify → dedup → never-drop pipeline.
  /// Returns the number of new transactions written.
  Future<int> ingestNotifications() async {
    final capture = _notifCapture;
    if (capture == null) return 0;
    final pending = await capture.drain();
    if (pending.isEmpty) return 0;

    final memory = await _db.merchantMemoryMap();
    final aliases = await _db.merchantAliasMap();
    var imported = 0;

    for (final n in pending) {
      // Known payment apps map to trusted sender tokens; unknown apps fall to
      // 'APP' (untrusted) so their transaction-shaped notifications queue for
      // review instead of auto-logging.
      final sender = senderTokenForPackage(n.package) ?? 'APP';
      final result = _parser.classify(
        body: n.body,
        receivedAt: n.postedAt,
        sender: sender,
        providerId: 'ntf_${n.key.hashCode & 0x7fffffff}',
      );

      if (result.isParsed) {
        final parsed = result.parsed!;
        if (await _isCrossProviderDuplicate(parsed)) continue;
        // Loose guard: the same payment usually also arrives as a bank SMS
        // (which carries account/ref). Any same-amount, same-direction posted
        // row within ±5 minutes means this notification is an echo.
        final nearby = await _db.findNearby(
          date: parsed.date,
          amount: parsed.amount,
          transactionType: parsed.transactionType,
          window: const Duration(minutes: 5),
        );
        if (nearby.isNotEmpty) continue;

        final canonical = _normalizer.normalize(parsed.merchant ?? 'Unknown',
            aliases: aliases);
        final companion = _toCompanion(parsed, canonical,
            _categorizer.categorize(parsed, canonical, memory: memory));
        if (await _db.insertIfNew(companion)) imported++;
      } else if (result.needsAttention) {
        await _db.insertUnparsedIfNew(UnparsedMessagesCompanion.insert(
          smsId: 'ntf_${n.key.hashCode & 0x7fffffff}',
          body: n.body,
          sender: Value('app: ${n.package}'),
          receivedAt: n.postedAt,
          reason: result.status.name,
          createdAt: DateTime.now(),
        ));
      }
    }
    return imported;
  }

  /// True when another SMS (different sender / DLT header) already stored this
  /// same payment — matched by reference number, or amount+account+time.
  Future<bool> _isCrossProviderDuplicate(ParsedSms parsed) async {
    final candidates = <Transaction>[
      if (parsed.referenceNo != null)
        ...await _db.findByReference(parsed.referenceNo!),
      ...await _db.findNearby(
        date: parsed.date,
        amount: parsed.amount,
        transactionType: parsed.transactionType,
        window: DuplicateDetector.window,
      ),
    ];
    if (_dupes.isDuplicate(parsed, candidates)) return true;

    // Loose rule for notification-sourced rows: those carry no account/ref to
    // corroborate strictly, so a same-amount same-direction row within ±5 min
    // whose id marks it as notification-captured is the same payment.
    final nearby = await _db.findNearby(
      date: parsed.date,
      amount: parsed.amount,
      transactionType: parsed.transactionType,
      window: const Duration(minutes: 5),
    );
    return nearby
        .any((t) => t.smsId.contains('ntf_') && t.smsId != parsed.smsId);
  }

  /// Post-import enrichment: mark subscriptions, AI-label unknowns, check budget
  /// alerts, and refresh the coach's scheduled content.
  Future<void> enrich() async {
    await _detectSubscriptions();
    await _aiCategorizer.categorizeAll();
    // Opt-in: let AI read the SMS the regex couldn't (no-op without consent).
    await _aiSmsParser.parseUnparsed();
    await _checkBudgetAlerts();
    await _scheduleDailySummary();
    await _refreshCoachContent();
  }

  /// Generates/refreshes the coach's periodic artifacts (all cached per
  /// period) and keeps the weekly nudge scheduled. Best-effort.
  Future<void> _refreshCoachContent() async {
    try {
      await _notifications.scheduleWeeklyReportNudge();
      // Sunday (or later in the week if missed): make sure this week's report
      // card exists so the nudge has something to show.
      final now = DateTime.now();
      if (now.weekday >= DateTime.saturday) await _coach.weeklyReport();

      // Month rollover: generate last month's report once and announce it.
      final prev = DateTime(now.year, now.month - 1, 1);
      final prevKey = CoachService.monthKey(prev);
      final existing = await _db.getAiInsight('monthly', prevKey);
      if (existing == null && now.day <= 7) {
        final report = await _coach.monthlyReport(prevKey);
        if (report != null &&
            await _db.markAlertOnce('monthlyreport:$prevKey')) {
          await _notifications.showAlert(
            prevKey.hashCode & 0x7fffffff,
            'Your monthly report is ready',
            'The coach graded last month — see where the money went.',
          );
        }
      }
    } catch (_) {
      // Coach content must never break ingestion.
    }
  }

  /// Fires a one-time notification when a category first crosses 80% or 100%
  /// of its monthly budget.
  Future<void> _checkBudgetAlerts() async {
    final budgets = await _db.getBudgets();
    if (budgets.isEmpty) return;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final monthKey = '${now.year}-${now.month}';

    final spent = <String, double>{};
    for (final t in await _db.allTransactions()) {
      if (t.transactionType != 'debit' || t.status != 'posted') continue;
      if (t.date.isBefore(startOfMonth)) continue;
      spent.update(t.category, (v) => v + t.amount, ifAbsent: () => t.amount);
    }

    for (final b in budgets) {
      if (b.monthlyLimit <= 0) continue;
      final used = spent[b.category] ?? 0;
      final frac = used / b.monthlyLimit;
      if (frac >= 1.0) {
        if (await _db.markAlertOnce('budget:${b.category}:over:$monthKey')) {
          await _notifications.showAlert(
            _alertId('over', b.category),
            '${b.category} budget exceeded',
            'You have spent ${formatRupees(used)} of your '
                '${formatRupees(b.monthlyLimit)} ${b.category} budget.',
          );
        }
      } else if (frac >= 0.8) {
        if (await _db.markAlertOnce('budget:${b.category}:near:$monthKey')) {
          await _notifications.showAlert(
            _alertId('near', b.category),
            '${b.category} budget at ${(frac * 100).round()}%',
            'Only ${formatRupees(b.monthlyLimit - used)} left in your '
                '${b.category} budget this month.',
          );
        }
      }
    }
  }

  /// Schedules (or refreshes) tonight's spending-summary notification using the
  /// latest known "today" total.
  Future<void> _scheduleDailySummary() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    double today = 0;
    int count = 0;
    for (final t in await _db.allTransactions()) {
      if (t.transactionType != 'debit' || t.status != 'posted') continue;
      if (t.date.isBefore(startOfDay)) continue;
      today += t.amount;
      count++;
    }
    final fallback = count == 0
        ? 'No spending recorded today.'
        : 'You spent ${formatRupees(today)} across $count '
            'transaction${count == 1 ? '' : 's'} today.';
    // Prefer the coach-written digest; fall back to the plain template.
    final digest = await _coach.dailyDigest();
    await _notifications.scheduleDailySummary(digest ?? fallback);
  }

  int _alertId(String kind, String category) =>
      ('$kind:$category').hashCode & 0x7fffffff;

  /// Re-runs the normalization + rule-categorization pipeline over every stored
  /// transaction (using the retained SMS body), then re-enriches. This upgrades
  /// existing rows after the parser/categorizer logic improves — without
  /// re-reading the inbox or losing data. User-set categories are preserved.
  Future<void> reprocessAll() async {
    final txns = await _db.allTransactions();
    final memory = await _db.merchantMemoryMap();
    final aliases = await _db.merchantAliasMap();
    await _db.transaction(() async {
      for (final t in txns) {
        if (t.categorySource == 'user') continue;
        // Re-parse the retained SMS body so rows stored before the parser knew
        // about statuses / reference numbers get upgraded too.
        final reparsed = _parser.parse(body: t.smsBody, receivedAt: t.date);
        // The improved parser now rejects this message entirely (e.g. a bill /
        // EMI reminder that used to slip through as income) — drop the row.
        if (reparsed == null) {
          await _db.deleteById(t.id);
          continue;
        }
        final status = reparsed.status;
        final referenceNo = reparsed.referenceNo ?? t.referenceNo;
        final parsed = ParsedSms(
          amount: t.amount,
          transactionType: t.transactionType,
          date: t.date,
          smsBody: t.smsBody,
          smsId: t.smsId,
          merchant: t.merchant,
          accountLast4: t.accountLast4,
          balance: t.balance,
          paymentMethod: t.paymentMethod,
          referenceNo: referenceNo,
          status: status,
        );
        // Prefer the merchant from the *latest* parser logic — extraction
        // improvements must heal rows stored with a mis-grabbed clause.
        final canonical = _normalizer.normalize(
            reparsed.merchant ?? t.merchant,
            aliases: aliases);
        final ruleResult =
            _categorizer.categorize(parsed, canonical, memory: memory);
        // Don't wipe an earlier AI label just because the offline rules still
        // can't identify the merchant — AI re-labelling is capped per run, so
        // overwriting would slowly erase knowledge on every reprocess.
        final keepAiLabel = t.categorySource == 'ai' && ruleResult.isUnknown;
        final result = keepAiLabel
            ? CategoryResult(t.category, t.confidence ?? 50, 'ai')
            : ruleResult;
        await _db.updateEnrichmentById(
          t.id,
          canonical: canonical,
          category: result.category,
          confidence: result.confidence,
          source: result.source,
          needsReview: status == 'posted' &&
              result.needsReview &&
              t.amount >= _reviewMinAmount,
          status: status,
          referenceNo: referenceNo,
        );
      }
    });
    await enrich();
  }

  Future<void> _detectSubscriptions() async {
    final txns = await _db.allTransactions();
    final subs = SubscriptionDetector.detect(txns);
    for (final merchant in subs) {
      await _db.markSubscription(merchant, true);
    }
  }

  /// Starts listening for live incoming SMS and ingests + enriches them.
  void startLiveIngest() {
    _sms.listenIncoming((raw) async {
      final memory = await _db.merchantMemoryMap();
      final result = _parser.classify(
        body: raw.body,
        receivedAt: raw.receivedAt,
        sender: raw.sender,
        providerId: raw.providerId,
      );

      // Couldn't parse it, but it looks financial — queue it, don't drop it.
      if (!result.isParsed) {
        if (result.needsAttention) {
          await _db.insertUnparsedIfNew(UnparsedMessagesCompanion.insert(
            smsId: _parser.dedupId(
                body: raw.body,
                receivedAt: raw.receivedAt,
                providerId: raw.providerId),
            body: raw.body,
            sender: Value(raw.sender),
            receivedAt: raw.receivedAt,
            reason: result.status.name,
            createdAt: DateTime.now(),
          ));
          await enrich();
        }
        return;
      }

      final parsed = result.parsed!;
      final aliases = await _db.merchantAliasMap();
      final canonical = _normalizer.normalize(parsed.merchant ?? 'Unknown',
          aliases: aliases);
      final companion = _toCompanion(
          parsed, canonical, _categorizer.categorize(parsed, canonical, memory: memory));
      if (await _isCrossProviderDuplicate(parsed)) return;
      final isNew = await _db.insertIfNew(companion);
      if (!isNew) return;

      // Spend-moment awareness: every real debit gets an instant notification
      // with running context, so money never leaves "without knowing".
      // (Failed/reversed attempts never notify.)
      if (parsed.isDebit && parsed.isPosted) {
        await _notifySpend(parsed, companion);
      }
      await enrich();
    });
  }

  /// Builds the in-the-moment spend notification: amount + merchant in the
  /// title, and the running month/budget context in the body.
  Future<void> _notifySpend(ParsedSms p, TransactionsCompanion c) async {
    final merchant = c.merchantCanonical.value ?? 'Unknown';
    final category = c.category.value;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfDay = DateTime(now.year, now.month, now.day);

    double monthInCategory = 0;
    double todayTotal = 0;
    for (final t in await _db.allTransactions()) {
      if (t.transactionType != 'debit' || t.status != 'posted') continue;
      if (!t.date.isBefore(startOfDay)) todayTotal += t.amount;
      if (!t.date.isBefore(startOfMonth) && t.category == category) {
        monthInCategory += t.amount;
      }
    }

    Budget? budget;
    for (final b in await _db.getBudgets()) {
      if (b.category == category && b.monthlyLimit > 0) {
        budget = b;
        break;
      }
    }

    final title = p.amount >= _largeTxnThreshold
        ? 'Large payment: ${formatRupees(p.amount)} · $merchant'
        : '${formatRupees(p.amount)} · $merchant';
    final body = budget != null
        ? '$category this month: ${formatRupees(monthInCategory)} of '
            '${formatRupees(budget.monthlyLimit)} '
            '(${(monthInCategory / budget.monthlyLimit * 100).round()}%).'
        : 'Spent today: ${formatRupees(todayTotal)}.';
    await _notifications.showAlert(p.smsId.hashCode & 0x7fffffff, title, body);
  }

  /// Applies a user's category choice to a merchant: remembers it for the
  /// future and re-labels all existing transactions of that merchant.
  Future<void> setUserCategory(String canonical, String category) async {
    await _db.rememberMerchant(canonical, category);
    await _db.applyUserCategoryToMerchant(canonical, category);
  }

  /// The user reviewed [t] and confirmed the guessed category is right.
  /// Teaches the merchant memory (when the merchant is known) so the same
  /// payee never needs review again.
  Future<void> confirmReview(Transaction t) async {
    final canonical = t.merchantCanonical ?? '';
    if (canonical.isNotEmpty && canonical != 'Unknown') {
      await setUserCategory(canonical, t.category);
    }
    await _db.confirmTransaction(t.id);
  }

  /// The user reviewed [t] and picked a different [category].
  Future<void> correctReview(Transaction t, String category) async {
    final canonical = t.merchantCanonical ?? '';
    if (canonical.isNotEmpty && canonical != 'Unknown') {
      await setUserCategory(canonical, category);
    } else {
      // No usable merchant to learn from — fix just this row.
      await _db.updateEnrichmentById(
        t.id,
        canonical: canonical.isEmpty ? 'Unknown' : canonical,
        category: category,
        confidence: 100,
        source: 'user',
        needsReview: false,
      );
    }
    await _db.confirmTransaction(t.id);
  }

  // ---- Manual entry & review-queue resolution ------------------------------

  /// Adds a transaction the user entered by hand (cash spends, missed SMS, or a
  /// repaired unparsed message). [smsBody] carries the original SMS when this
  /// resolves a queue item, otherwise a short note.
  Future<void> addManualTransaction({
    required double amount,
    required String transactionType,
    required String merchant,
    required String category,
    required DateTime date,
    String smsBody = 'Added manually',
    String? sourceSmsId,
  }) async {
    final aliases = await _db.merchantAliasMap();
    final canonical = _normalizer.normalize(
        merchant.isEmpty ? 'Unknown' : merchant,
        aliases: aliases);
    // Learn the raw→canonical mapping so the same messy string resolves
    // automatically next time.
    if (merchant.isNotEmpty &&
        merchant.trim().toLowerCase() != canonical.toLowerCase()) {
      await _db.rememberMerchantAlias(merchant, canonical);
    }
    final smsId = sourceSmsId ??
        'manual_${DateTime.now().microsecondsSinceEpoch}';
    await _db.insertIfNew(TransactionsCompanion.insert(
      amount: amount,
      transactionType: transactionType,
      date: date,
      smsBody: smsBody,
      smsId: smsId,
      merchant: Value(merchant.isEmpty ? 'Unknown' : merchant),
      merchantCanonical: Value(canonical),
      category: Value(category),
      confidence: const Value(100),
      categorySource: const Value('user'),
      status: const Value('posted'),
      needsReview: const Value(false),
    ));
    await enrich();
  }

  /// Turns a queued unparsed message into a transaction (user-supplied fields),
  /// then marks the queue row resolved.
  Future<void> resolveUnparsed(
    UnparsedMessage row, {
    required double amount,
    required String transactionType,
    required String merchant,
    required String category,
  }) async {
    await addManualTransaction(
      amount: amount,
      transactionType: transactionType,
      merchant: merchant,
      category: category,
      date: row.receivedAt,
      smsBody: row.body,
      sourceSmsId: row.smsId,
    );
    await _db.setUnparsedStatus(row.id, 'resolved');
  }

  /// The user marked a queued message as "not a transaction".
  Future<void> dismissUnparsed(int id) => _db.setUnparsedStatus(id, 'ignored');

  // ---- Isolate-friendly batch parsing --------------------------------------

  TransactionsCompanion _toCompanion(
      ParsedSms p, String canonical, CategoryResult result) {
    return TransactionsCompanion.insert(
      amount: p.amount,
      transactionType: p.transactionType,
      date: p.date,
      smsBody: p.smsBody,
      smsId: p.smsId,
      merchant: Value(p.merchant ?? 'Unknown'),
      merchantCanonical: Value(canonical),
      category: Value(result.category),
      confidence: Value(result.confidence),
      categorySource: Value(result.source),
      paymentMethod: Value(p.paymentMethod),
      accountLast4: Value(p.accountLast4),
      balance: Value(p.balance),
      status: Value(p.status),
      referenceNo: Value(p.referenceNo),
      // Only real, material money movement is worth the user's review time.
      needsReview: Value(
          p.isPosted && result.needsReview && p.amount >= _reviewMinAmount),
    );
  }
}

/// Input for [scanInboxBatch] (must be a plain sendable object).
class ParseBatchInput {
  final List<RawSms> inbox;
  final Map<String, String> memory;

  /// Learned raw→canonical merchant aliases (lowercased keys).
  final Map<String, String> aliases;
  const ParseBatchInput(this.inbox, this.memory,
      [this.aliases = const {}]);
}

/// One parsed inbox entry produced off the UI thread.
class ParsedEntry {
  final ParsedSms parsed;
  final String canonical;
  final CategoryResult result;
  const ParsedEntry(this.parsed, this.canonical, this.result);
}

/// A financial-sender message the parser couldn't read (for the review queue).
class UnparsedRecord {
  final String smsId;
  final String body;
  final String? sender;
  final DateTime receivedAt;
  final String reason;
  const UnparsedRecord(
      this.smsId, this.body, this.sender, this.receivedAt, this.reason);
}

/// The full outcome of scanning the inbox off the UI thread: parsed
/// transactions, unparsed-but-financial messages, and a tally of everything.
class InboxScan {
  final List<ParsedEntry> parsed;
  final List<UnparsedRecord> unparsed;
  final int scanned;
  final int ignored;
  const InboxScan(this.parsed, this.unparsed, this.scanned, this.ignored);
}

/// Top-level so it can run in a background isolate via [compute]. Classifies
/// every message so nothing is silently dropped.
InboxScan scanInboxBatch(ParseBatchInput input) {
  const parser = ParserService();
  const normalizer = MerchantNormalizer();
  const categorizer = CategorizerService();
  final parsed = <ParsedEntry>[];
  final unparsed = <UnparsedRecord>[];
  var ignored = 0;

  for (final raw in input.inbox) {
    final result = parser.classify(
      body: raw.body,
      receivedAt: raw.receivedAt,
      sender: raw.sender,
      providerId: raw.providerId,
    );
    if (result.isParsed) {
      final p = result.parsed!;
      final canonical =
          normalizer.normalize(p.merchant ?? 'Unknown', aliases: input.aliases);
      parsed.add(ParsedEntry(
          p, canonical, categorizer.categorize(p, canonical, memory: input.memory)));
    } else if (result.needsAttention) {
      unparsed.add(UnparsedRecord(
        parser.dedupId(
            body: raw.body,
            receivedAt: raw.receivedAt,
            providerId: raw.providerId),
        raw.body,
        raw.sender,
        raw.receivedAt,
        result.status.name,
      ));
    } else {
      ignored++; // non-financial sender or clearly non-transactional
    }
  }
  return InboxScan(parsed, unparsed, input.inbox.length, ignored);
}
