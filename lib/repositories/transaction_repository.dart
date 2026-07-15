import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show compute;

import '../models/parsed_sms.dart';
import '../services/ai_merchant_categorizer.dart';
import '../services/categorizer_service.dart';
import '../services/coach_service.dart';
import '../services/database_service.dart';
import '../services/duplicate_detector.dart';
import '../services/merchant_normalizer.dart';
import '../services/notification_service.dart';
import '../services/parser_service.dart';
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
  final NotificationService _notifications;
  final CoachService _coach;
  final AppDatabase _db;
  final DuplicateDetector _dupes;

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
    required NotificationService notifications,
    required CoachService coach,
    required AppDatabase db,
    DuplicateDetector dupes = const DuplicateDetector(),
  })  : _sms = sms,
        _parser = parser,
        _normalizer = normalizer,
        _categorizer = categorizer,
        _aiCategorizer = aiCategorizer,
        _notifications = notifications,
        _coach = coach,
        _db = db,
        _dupes = dupes;

  Stream<List<Transaction>> watchAll() => _db.watchAll();

  Stream<List<Transaction>> watchBetween(DateTime start, DateTime end) =>
      _db.watchBetween(start, end);

  /// Scans the inbox, imports new transactions, then enriches them.
  /// Returns the number of new transactions written.
  Future<int> syncInbox() async {
    final inbox = await _sms.readInbox();
    final memory = await _db.merchantMemoryMap();
    // Parsing thousands of SMS is regex-heavy — run it off the UI thread so
    // the app stays responsive during a full inbox scan.
    final parsedBatch =
        await compute(parseInboxBatch, ParseBatchInput(inbox, memory));
    final entries = <(ParsedSms, TransactionsCompanion)>[
      for (final e in parsedBatch) (e.parsed, _toCompanion(e.parsed, e.canonical, e.result)),
    ];

    var imported = 0;
    if (entries.isNotEmpty) {
      await _db.transaction(() async {
        for (final (parsed, companion) in entries) {
          if (await _isCrossProviderDuplicate(parsed)) continue;
          if (await _db.insertIfNew(companion)) imported++;
        }
      });
    }

    await enrich();
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
    return _dupes.isDuplicate(parsed, candidates);
  }

  /// Post-import enrichment: mark subscriptions, AI-label unknowns, check budget
  /// alerts, and refresh the coach's scheduled content.
  Future<void> enrich() async {
    await _detectSubscriptions();
    await _aiCategorizer.categorizeAll();
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
        final status = reparsed?.status ?? t.status;
        final referenceNo = reparsed?.referenceNo ?? t.referenceNo;
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
        final canonical = _normalizer.normalize(t.merchant);
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
      final entry = _parseToEntry(raw, memory);
      if (entry == null) return;
      final (parsed, companion) = entry;
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

  // ---- Isolate-friendly batch parsing --------------------------------------

  (ParsedSms, TransactionsCompanion)? _parseToEntry(
      RawSms raw, Map<String, String> memory) {
    final parsed = _parser.parse(
      body: raw.body,
      receivedAt: raw.receivedAt,
      sender: raw.sender,
      providerId: raw.providerId,
    );
    if (parsed == null) return null;

    final canonical = _normalizer.normalize(parsed.merchant ?? 'Unknown');
    final result = _categorizer.categorize(parsed, canonical, memory: memory);
    return (parsed, _toCompanion(parsed, canonical, result));
  }

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

/// Input for [parseInboxBatch] (must be a plain sendable object).
class ParseBatchInput {
  final List<RawSms> inbox;
  final Map<String, String> memory;
  const ParseBatchInput(this.inbox, this.memory);
}

/// One parsed inbox entry produced off the UI thread.
class ParsedEntry {
  final ParsedSms parsed;
  final String canonical;
  final CategoryResult result;
  const ParsedEntry(this.parsed, this.canonical, this.result);
}

/// Top-level so it can run in a background isolate via [compute]. All three
/// services are pure Dart with const constructors.
List<ParsedEntry> parseInboxBatch(ParseBatchInput input) {
  const parser = ParserService();
  const normalizer = MerchantNormalizer();
  const categorizer = CategorizerService();
  final out = <ParsedEntry>[];
  for (final raw in input.inbox) {
    final parsed = parser.parse(
      body: raw.body,
      receivedAt: raw.receivedAt,
      sender: raw.sender,
      providerId: raw.providerId,
    );
    if (parsed == null) continue;
    final canonical = normalizer.normalize(parsed.merchant ?? 'Unknown');
    out.add(ParsedEntry(parsed, canonical,
        categorizer.categorize(parsed, canonical, memory: input.memory)));
  }
  return out;
}
