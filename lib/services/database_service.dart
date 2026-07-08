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

@DriftDatabase(tables: [Transactions, MerchantMemories, Budgets, AlertLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For unit tests: inject an in-memory executor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 6;

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
        },
      );

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

  /// Distinct canonical merchant names that still lack a confident category
  /// (i.e. rule-categorised as Others). These are candidates for AI labelling.
  Future<List<String>> merchantsNeedingCategory() async {
    final q = selectOnly(transactions, distinct: true)
      ..addColumns([transactions.merchantCanonical])
      ..where(transactions.category.equals(AppCategory.others) &
          transactions.categorySource.equals('ai').not() &
          transactions.merchantCanonical.isNotNull());
    final rows = await q.get();
    return rows
        .map((r) => r.read(transactions.merchantCanonical))
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .toList();
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

  Future<void> markSubscription(String merchantCanonical, bool value) async {
    await (update(transactions)
          ..where((t) => t.merchantCanonical.equals(merchantCanonical)))
        .write(TransactionsCompanion(isSubscription: Value(value)));
  }

  Future<List<Transaction>> allTransactions() =>
      (select(transactions)..orderBy([(t) => OrderingTerm.desc(t.date)])).get();

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
