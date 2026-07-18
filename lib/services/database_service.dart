import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/categories.dart';
import 'secure_key_service.dart';

part 'database_service.g.dart';

/// A single parsed financial transaction.
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();

  /// The raw merchant/payee string as detected from the SMS.
  TextColumn get merchant => text().withDefault(const Constant('Unknown'))();

  /// Normalised, display/grouping name (e.g. "upiswiggy@icici" -> "Swiggy").
  /// Falls back to [merchant] when null.
  TextColumn get merchantCanonical => text().nullable()();

  TextColumn get category =>
      text().withDefault(const Constant(AppCategory.others))();

  /// How [category] was assigned: 'rule', 'ai', or 'user'.
  TextColumn get categorySource => text().nullable()();

  /// Confidence (0–100) in [category], when known (mainly for AI/rule guesses).
  IntColumn get confidence => integer().nullable()();

  /// True when this looks like a recurring subscription charge.
  BoolColumn get isSubscription =>
      boolean().withDefault(const Constant(false))();

  /// 'debit' or 'credit'.
  TextColumn get transactionType => text()();
  TextColumn get paymentMethod => text().nullable()();
  TextColumn get accountLast4 => text().nullable()();
  RealColumn get balance => real().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get smsBody => text()();

  /// Stable per-SMS id used to prevent duplicate inserts on re-scan.
  TextColumn get smsId => text().unique()();

  /// 'posted' (money moved), 'failed' (declined/timed out), or 'reversed'
  /// (debit rolled back). Only 'posted' rows count towards analytics; the
  /// others are kept for the audit trail.
  TextColumn get status => text().withDefault(const Constant('posted'))();

  /// Bank/UPI reference number (UTR), when the SMS exposed one. Used to spot
  /// the same payment being announced by two senders (bank + UPI app).
  TextColumn get referenceNo => text().nullable()();

  /// True when the categorization was too uncertain to trust silently
  /// (confidence < 80). Surfaced in the Review screen until the user confirms
  /// or corrects it.
  BoolColumn get needsReview => boolean().withDefault(const Constant(false))();
}

/// Learned merchant → category mappings. Written when the user corrects a
/// category; consulted first when categorising future transactions.
class MerchantMemories extends Table {
  TextColumn get canonical => text()();
  TextColumn get category => text()();
  TextColumn get source => text().withDefault(const Constant('user'))();

  @override
  Set<Column> get primaryKey => {canonical};
}

/// Per-category monthly spending limits set by the user.
class Budgets extends Table {
  TextColumn get category => text()();
  RealColumn get monthlyLimit => real()();

  @override
  Set<Column> get primaryKey => {category};
}

/// De-duplication log so a given alert (e.g. "Food over-budget this month")
/// only fires once.
class AlertLogs extends Table {
  TextColumn get key => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Cached AI-generated coach content (briefings, digests, reports, insight
/// cards), keyed by kind + period so each is generated once per period rather
/// than on every open — critical on a free-tier Gemini key.
class AiInsights extends Table {
  /// 'briefing' | 'daily' | 'weekly' | 'monthly' | 'card'
  TextColumn get kind => text()();

  /// e.g. '2026-07-09' (daily kinds), '2026-W28' (weekly), '2026-07' (monthly).
  TextColumn get periodKey => text()();

  /// Markdown content.
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {kind, periodKey};
}

/// The AI's category verdict for a canonical merchant name, cached so each name
/// is sent to Gemini at most once — ever. This is what makes "AI categorises
/// every merchant" survivable on a free-tier key: re-syncs consult the cache
/// instead of re-billing an API call for a name already seen.
class MerchantCategoryCache extends Table {
  TextColumn get canonical => text()();
  TextColumn get category => text()();

  /// The AI's own confidence (0–100) in this label.
  IntColumn get confidence => integer()();
  DateTimeColumn get askedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {canonical};
}

/// A thing the user is saving up to buy (bike, TV, AC, …). [estimatedPrice] is
/// usually AI-estimated; [saved] is how much the user has set aside toward it.
class PurchaseGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get estimatedPrice => real()();
  RealColumn get saved => real().withDefault(const Constant(0))();

  /// A short AI note about the estimate (model/segment/range), if any.
  TextColumn get priceNote => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// A financial-sender SMS the regex parser could not turn into a transaction.
/// Captured (never dropped) so the user — or opt-in AI parsing — can resolve it.
class UnparsedMessages extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Same stable id scheme as transactions, so re-scans don't duplicate.
  TextColumn get smsId => text().unique()();
  TextColumn get body => text()();
  TextColumn get sender => text().nullable()();
  DateTimeColumn get receivedAt => dateTime()();

  /// 'needs_type' | 'needs_amount' | 'needs_structure'.
  TextColumn get reason => text()();

  /// 'needs_attention' | 'ignored' (user/AI said not a txn) | 'resolved'.
  TextColumn get status =>
      text().withDefault(const Constant('needs_attention'))();

  /// How many times opt-in AI parsing has been attempted (bounds retries).
  IntColumn get aiAttempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

/// Learned raw-merchant-string → canonical-name mappings, extending the static
/// rules in MerchantNormalizer without an app update. Written when a human or
/// the AI resolves a messy name ("SWGY*123") to a canonical one ("Swiggy").
class MerchantAliases extends Table {
  /// The raw string as seen in SMS, lowercased.
  TextColumn get alias => text()();
  TextColumn get canonical => text()();

  /// 'user' | 'ai'.
  TextColumn get source => text().withDefault(const Constant('user'))();

  @override
  Set<Column> get primaryKey => {alias};
}

@DriftDatabase(tables: [
  Transactions,
  MerchantMemories,
  Budgets,
  AlertLogs,
  AiInsights,
  MerchantCategoryCache,
  PurchaseGoals,
  UnparsedMessages,
  MerchantAliases,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For unit tests: inject an in-memory executor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(transactions, transactions.merchantCanonical);
            await m.addColumn(transactions, transactions.categorySource);
            await m.addColumn(transactions, transactions.confidence);
            await m.addColumn(transactions, transactions.isSubscription);
          }
          if (from < 3) {
            await m.createTable(merchantMemories);
          }
          if (from < 4) {
            await m.createTable(budgets);
          }
          if (from < 5) {
            await m.createTable(alertLogs);
          }
          if (from < 6) {
            await m.addColumn(transactions, transactions.status);
            await m.addColumn(transactions, transactions.referenceNo);
            await m.addColumn(transactions, transactions.needsReview);
          }
          if (from < 7) {
            await m.createTable(aiInsights);
          }
          if (from < 8) {
            await m.createTable(merchantCategoryCache);
          }
          if (from < 9) {
            await m.createTable(purchaseGoals);
          }
          if (from < 10) {
            await m.createTable(unparsedMessages);
          }
          if (from < 11) {
            await m.createTable(merchantAliases);
          }
        },
      );

  // ---- AI insight cache ----------------------------------------------------

  Future<AiInsight?> getAiInsight(String kind, String periodKey) =>
      (select(aiInsights)
            ..where((i) => i.kind.equals(kind) & i.periodKey.equals(periodKey)))
          .getSingleOrNull();

  Future<void> saveAiInsight(
      String kind, String periodKey, String content) async {
    await into(aiInsights).insertOnConflictUpdate(AiInsightsCompanion.insert(
      kind: kind,
      periodKey: periodKey,
      content: content,
      createdAt: DateTime.now(),
    ));
  }

  /// All weekly/monthly reports, newest first (for the Reports screen).
  Future<List<AiInsight>> listReports() =>
      (select(aiInsights)
            ..where((i) => i.kind.isIn(['weekly', 'monthly']))
            ..orderBy([(i) => OrderingTerm.desc(i.createdAt)]))
          .get();

  Stream<List<Budget>> watchBudgets() =>
      (select(budgets)..orderBy([(b) => OrderingTerm.asc(b.category)])).watch();

  Future<List<Budget>> getBudgets() => select(budgets).get();

  /// Records an alert key if not seen before. Returns true when it's new (so
  /// the caller should actually fire the notification).
  Future<bool> markAlertOnce(String key) async {
    final existing =
        await (select(alertLogs)..where((a) => a.key.equals(key)))
            .getSingleOrNull();
    if (existing != null) return false;
    await into(alertLogs).insert(AlertLogsCompanion.insert(key: key));
    return true;
  }

  Future<void> setBudget(String category, double limit) async {
    await into(budgets).insertOnConflictUpdate(
      BudgetsCompanion.insert(category: category, monthlyLimit: limit),
    );
  }

  Future<void> removeBudget(String category) async {
    await (delete(budgets)..where((b) => b.category.equals(category))).go();
  }

  /// The learned merchant → category map (canonical name → category).
  Future<Map<String, String>> merchantMemoryMap() async {
    final rows = await select(merchantMemories).get();
    return {for (final r in rows) r.canonical: r.category};
  }

  /// The learned raw-alias → canonical-name map (aliases stored lowercased).
  Future<Map<String, String>> merchantAliasMap() async {
    final rows = await select(merchantAliases).get();
    return {for (final r in rows) r.alias: r.canonical};
  }

  /// Records that raw string [alias] means merchant [canonical] (upsert).
  Future<void> rememberMerchantAlias(String alias, String canonical,
      {String source = 'user'}) async {
    final a = alias.trim().toLowerCase();
    if (a.isEmpty || canonical.trim().isEmpty) return;
    await into(merchantAliases).insertOnConflictUpdate(
      MerchantAliasesCompanion.insert(
        alias: a,
        canonical: canonical.trim(),
        source: Value(source),
      ),
    );
  }

  /// Records a user's category choice for a merchant (upsert).
  Future<void> rememberMerchant(String canonical, String category) async {
    await into(merchantMemories).insertOnConflictUpdate(
      MerchantMemoriesCompanion.insert(
        canonical: canonical,
        category: category,
        source: const Value('user'),
      ),
    );
  }

  /// Applies a user-chosen category to every transaction of a merchant,
  /// overriding any previous rule/AI/user value.
  Future<void> applyUserCategoryToMerchant(
      String canonical, String category) async {
    await (update(transactions)
          ..where((t) => t.merchantCanonical.equals(canonical)))
        .write(TransactionsCompanion(
      category: Value(category),
      confidence: const Value(100),
      categorySource: const Value('user'),
      needsReview: const Value(false),
    ));
  }

  /// The user confirmed one transaction's current category as correct.
  Future<void> confirmTransaction(int id) async {
    await (update(transactions)..where((t) => t.id.equals(id))).write(
      const TransactionsCompanion(
        needsReview: Value(false),
        confidence: Value(100),
        categorySource: Value('user'),
      ),
    );
  }

  /// Inserts a transaction, silently ignoring duplicates (matched by [smsId]).
  /// Returns true if a new row was actually written.
  Future<bool> insertIfNew(TransactionsCompanion entry) async {
    final rowId = await into(transactions)
        .insert(entry, mode: InsertMode.insertOrIgnore);
    return rowId != 0;
  }

  /// Rows sharing a bank reference number (strong duplicate signal when two
  /// senders announce the same payment).
  Future<List<Transaction>> findByReference(String referenceNo) =>
      (select(transactions)..where((t) => t.referenceNo.equals(referenceNo)))
          .get();

  /// Rows with the same amount and direction within [window] of [date] —
  /// candidates for cross-provider duplicate detection.
  Future<List<Transaction>> findNearby({
    required DateTime date,
    required double amount,
    required String transactionType,
    Duration window = const Duration(minutes: 3),
  }) {
    return (select(transactions)
          ..where((t) =>
              t.amount.equals(amount) &
              t.transactionType.equals(transactionType) &
              t.date.isBiggerOrEqualValue(date.subtract(window)) &
              t.date.isSmallerOrEqualValue(date.add(window))))
        .get();
  }

  /// Applies an AI/user category to every transaction of a given canonical
  /// merchant (only overwriting rows not already user-confirmed).
  Future<void> applyCategoryToMerchant({
    required String merchantCanonical,
    required String category,
    required int confidence,
    required String source,
    required bool needsReview,
  }) async {
    await (update(transactions)
          ..where((t) =>
              t.merchantCanonical.equals(merchantCanonical) &
              t.categorySource.equals('user').not()))
        .write(TransactionsCompanion(
      category: Value(category),
      confidence: Value(confidence),
      categorySource: Value(source),
      needsReview: Value(needsReview),
    ));
  }

  // ---- AI merchant-category cache ------------------------------------------

  /// Canonical merchant names the AI has already been asked about (any verdict).
  /// Consulted before every AI categorisation run so a name is billed once.
  Future<Set<String>> cachedMerchants() async {
    final rows = await select(merchantCategoryCache).get();
    return {for (final r in rows) r.canonical};
  }

  /// Records the AI's verdict for [canonical] so it is never re-queried.
  Future<void> cacheMerchantCategory(
      String canonical, String category, int confidence) async {
    await into(merchantCategoryCache).insertOnConflictUpdate(
      MerchantCategoryCacheCompanion.insert(
        canonical: canonical,
        category: category,
        confidence: confidence,
        askedAt: DateTime.now(),
      ),
    );
  }

  Future<void> markSubscription(String merchantCanonical, bool value) async {
    await (update(transactions)
          ..where((t) => t.merchantCanonical.equals(merchantCanonical)))
        .write(TransactionsCompanion(isSubscription: Value(value)));
  }

  Future<List<Transaction>> allTransactions() =>
      (select(transactions)..orderBy([(t) => OrderingTerm.desc(t.date)])).get();

  // ---- Purchase goals ------------------------------------------------------

  Stream<List<PurchaseGoal>> watchPurchaseGoals() =>
      (select(purchaseGoals)..orderBy([(g) => OrderingTerm.desc(g.createdAt)]))
          .watch();

  Future<int> addPurchaseGoal({
    required String name,
    required double estimatedPrice,
    String? note,
  }) {
    return into(purchaseGoals).insert(PurchaseGoalsCompanion.insert(
      name: name,
      estimatedPrice: estimatedPrice,
      priceNote: Value(note),
      createdAt: DateTime.now(),
    ));
  }

  /// Adds [amount] to a goal's saved total (read-modify-write in a txn).
  Future<void> addToGoalSavings(int id, double amount) async {
    await transaction(() async {
      final g = await (select(purchaseGoals)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (g == null) return;
      final next = (g.saved + amount).clamp(0, double.infinity).toDouble();
      await (update(purchaseGoals)..where((t) => t.id.equals(id)))
          .write(PurchaseGoalsCompanion(saved: Value(next)));
    });
  }

  Future<void> updateGoalPrice(int id, double price, String? note) async {
    await (update(purchaseGoals)..where((t) => t.id.equals(id))).write(
      PurchaseGoalsCompanion(
        estimatedPrice: Value(price),
        priceNote: Value(note),
      ),
    );
  }

  Future<void> deletePurchaseGoal(int id) async {
    await (delete(purchaseGoals)..where((t) => t.id.equals(id))).go();
  }

  // ---- Unparsed messages (never-drop queue) --------------------------------

  /// Messages awaiting review, newest first.
  Stream<List<UnparsedMessage>> watchNeedsAttention() =>
      (select(unparsedMessages)
            ..where((u) => u.status.equals('needs_attention'))
            ..orderBy([(u) => OrderingTerm.desc(u.receivedAt)]))
          .watch();

  Stream<int> watchNeedsAttentionCount() {
    final q = selectOnly(unparsedMessages)
      ..addColumns([unparsedMessages.id.count()])
      ..where(unparsedMessages.status.equals('needs_attention'));
    return q
        .map((r) => r.read(unparsedMessages.id.count()) ?? 0)
        .watchSingle();
  }

  /// Inserts an unparsed message unless one with the same [smsId] already
  /// exists. Returns true when a new row was written.
  Future<bool> insertUnparsedIfNew(UnparsedMessagesCompanion entry) async {
    final rowId = await into(unparsedMessages)
        .insert(entry, mode: InsertMode.insertOrIgnore);
    return rowId != 0;
  }

  /// Needs-attention rows that opt-in AI parsing may still try ([maxAttempts]).
  Future<List<UnparsedMessage>> unparsedForAi({int maxAttempts = 2, int limit = 10}) =>
      (select(unparsedMessages)
            ..where((u) =>
                u.status.equals('needs_attention') &
                u.aiAttempts.isSmallerThanValue(maxAttempts))
            ..orderBy([(u) => OrderingTerm.desc(u.receivedAt)])
            ..limit(limit))
          .get();

  Future<void> setUnparsedStatus(int id, String status) async {
    await (update(unparsedMessages)..where((u) => u.id.equals(id)))
        .write(UnparsedMessagesCompanion(status: Value(status)));
  }

  Future<void> bumpUnparsedAiAttempt(int id) async {
    await transaction(() async {
      final row = await (select(unparsedMessages)..where((u) => u.id.equals(id)))
          .getSingleOrNull();
      if (row == null) return;
      await (update(unparsedMessages)..where((u) => u.id.equals(id)))
          .write(UnparsedMessagesCompanion(aiAttempts: Value(row.aiAttempts + 1)));
    });
  }

  /// Drops any unparsed row that now corresponds to a stored transaction
  /// (e.g. a parser improvement finally handled it).
  Future<void> clearUnparsedBySmsId(String smsId) async {
    await (delete(unparsedMessages)..where((u) => u.smsId.equals(smsId))).go();
  }

  /// Re-writes the enrichment fields of one row (used by reprocessing).
  Future<void> updateEnrichmentById(
    int id, {
    required String canonical,
    required String category,
    required int confidence,
    required String source,
    required bool needsReview,
    String? status,
    String? referenceNo,
  }) async {
    await (update(transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        merchantCanonical: Value(canonical),
        category: Value(category),
        confidence: Value(confidence),
        categorySource: Value(source),
        needsReview: Value(needsReview),
        status: status != null ? Value(status) : const Value.absent(),
        referenceNo:
            referenceNo != null ? Value(referenceNo) : const Value.absent(),
      ),
    );
  }

  /// Removes a stored transaction (used when an improved parser now rejects a
  /// previously-imported message, e.g. a bill reminder).
  Future<void> deleteById(int id) async {
    await (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  /// All transactions, newest first — reactive.
  Stream<List<Transaction>> watchAll() {
    return (select(transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Transactions within [start] (inclusive) and [end] (exclusive), newest
  /// first — reactive.
  Stream<List<Transaction>> watchBetween(DateTime start, DateTime end) {
    return (select(transactions)
          ..where((t) => t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<int> countAll() async {
    final row = await (selectOnly(transactions)
          ..addColumns([transactions.id.count()]))
        .getSingle();
    return row.read(transactions.id.count()) ?? 0;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // The SQLCipher build is selected via the `hooks.user_defines.sqlite3`
    // block in pubspec.yaml (sqlite3 v3 native build hooks). Here we just supply
    // the key so the encrypted database can be opened.
    final dir = await getApplicationDocumentsDirectory();
    // New filename: the encrypted DB is incompatible with any earlier
    // unencrypted `ai_finance.sqlite`.
    final file = File(p.join(dir.path, 'ai_finance_enc.sqlite'));
    // The key is fetched here on the main isolate (secure storage uses a
    // platform channel and can't run in the background isolate), then applied
    // inside the background isolate's setup below.
    final keyHex = await SecureKeyService.getOrCreateDbKeyHex();

    // Run SQLite on a background isolate so encryption + bulk inserts never
    // block the UI thread.
    return NativeDatabase.createInBackground(
      file,
      setup: (db) {
        // Raw 256-bit key form so no characters need escaping.
        db.execute('PRAGMA key = "x\'$keyHex\'";');
        // Fail loudly if a plain-SQLite build slipped in instead of cipher.
        final cipher = db.select('PRAGMA cipher_version;');
        if (cipher.isEmpty) {
          throw StateError(
              'SQLCipher not active — refusing to store data unencrypted.');
        }
      },
    );
  });
}
