import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/transaction_repository.dart';
import '../services/ai_merchant_categorizer.dart';
import '../services/ai_service.dart';
import '../services/categorizer_service.dart';
import '../services/coach_service.dart';
import '../services/database_service.dart';
import '../services/export_service.dart';
import '../services/merchant_normalizer.dart';
import '../services/notification_service.dart';
import '../services/parser_service.dart';
import '../services/settings_service.dart';
import '../services/sms_service.dart';
import 'analytics_data.dart';
import 'budget_progress.dart';
import 'dashboard_stats.dart';
import 'safe_to_spend.dart';

// ---- Infrastructure singletons -------------------------------------------

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final smsServiceProvider = Provider<SmsService>((ref) => SmsService());
final parserServiceProvider = Provider<ParserService>((ref) => const ParserService());
final categorizerServiceProvider =
    Provider<CategorizerService>((ref) => const CategorizerService());

final merchantNormalizerProvider =
    Provider<MerchantNormalizer>((ref) => const MerchantNormalizer());

/// Overridden in main() with an already-initialized instance.
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => throw UnimplementedError('notificationServiceProvider not overridden'),
);

final settingsServiceProvider =
    Provider<SettingsService>((ref) => SettingsService());
final exportServiceProvider = Provider<ExportService>(
    (ref) => ExportService(ref.watch(databaseProvider)));
final aiServiceProvider = Provider<AiService>((ref) => AiService());

final aiMerchantCategorizerProvider = Provider<AiMerchantCategorizer>((ref) {
  return AiMerchantCategorizer(
    ai: ref.watch(aiServiceProvider),
    settings: ref.watch(settingsServiceProvider),
    db: ref.watch(databaseProvider),
  );
});

/// Whether cloud AI is usable (API key present + consent granted). Refreshable
/// via `ref.invalidate(aiReadyProvider)` after the user changes settings.
final aiReadyProvider = FutureProvider<bool>((ref) {
  return ref.watch(settingsServiceProvider).isAiReady();
});

final coachServiceProvider = Provider<CoachService>((ref) {
  return CoachService(
    ai: ref.watch(aiServiceProvider),
    settings: ref.watch(settingsServiceProvider),
    db: ref.watch(databaseProvider),
  );
});

/// Coach artifacts for the UI (cached per period inside CoachService).
final coachBriefingProvider =
    FutureProvider<String?>((ref) => ref.watch(coachServiceProvider).briefing());
final insightCardProvider = FutureProvider<String?>(
    (ref) => ref.watch(coachServiceProvider).dashboardCard());
final budgetInsightProvider = FutureProvider<String?>(
    (ref) => ref.watch(coachServiceProvider).budgetInsight());
final monthProgressProvider = FutureProvider<String?>(
    (ref) => ref.watch(coachServiceProvider).monthProgressInsight());
final reportsProvider = FutureProvider<List<AiInsight>>(
    (ref) => ref.watch(databaseProvider).listReports());

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(
    sms: ref.watch(smsServiceProvider),
    parser: ref.watch(parserServiceProvider),
    normalizer: ref.watch(merchantNormalizerProvider),
    categorizer: ref.watch(categorizerServiceProvider),
    aiCategorizer: ref.watch(aiMerchantCategorizerProvider),
    notifications: ref.watch(notificationServiceProvider),
    coach: ref.watch(coachServiceProvider),
    db: ref.watch(databaseProvider),
  );
});

// ---- Reactive data -------------------------------------------------------

/// Every stored transaction, newest first.
final allTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(transactionRepositoryProvider).watchAll();
});

/// Derived dashboard statistics for "today", recomputed whenever the
/// transaction list changes.
final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final async = ref.watch(allTransactionsProvider);
  final txns = async.value ?? const [];
  return DashboardStats.from(txns, now: DateTime.now());
});

/// Derived analytics (category/merchant/daily breakdowns) for the current month.
final analyticsDataProvider = Provider<AnalyticsData>((ref) {
  final async = ref.watch(allTransactionsProvider);
  final txns = async.value ?? const [];
  return AnalyticsData.from(txns, now: DateTime.now());
});

/// Transactions whose categorization was too uncertain to trust silently.
/// The user confirms or corrects these in the Review screen.
final reviewQueueProvider = Provider<List<Transaction>>((ref) {
  final async = ref.watch(allTransactionsProvider);
  final txns = async.value ?? const <Transaction>[];
  return txns
      .where((t) => t.needsReview && t.status == 'posted')
      .toList(); // already newest-first
});

/// User-set category budgets (reactive).
final budgetsProvider = StreamProvider<List<Budget>>((ref) {
  return ref.watch(databaseProvider).watchBudgets();
});

/// The daily "safe to spend" number derived from budgets + this month's spend.
final safeToSpendProvider = Provider<SafeToSpend>((ref) {
  final budgets = ref.watch(budgetsProvider).value ?? const [];
  final txns = ref.watch(allTransactionsProvider).value ?? const [];
  return SafeToSpend.from(budgets, txns, now: DateTime.now());
});

/// Each budget paired with this month's spend in that category.
final budgetProgressProvider = Provider<List<BudgetProgress>>((ref) {
  final budgets = ref.watch(budgetsProvider).value ?? const [];
  final analytics = ref.watch(analyticsDataProvider);
  final list = budgets
      .map((b) => BudgetProgress(
            category: b.category,
            limit: b.monthlyLimit,
            spent: analytics.categoryTotals[b.category] ?? 0,
          ))
      .toList()
    ..sort((a, b) => b.fraction.compareTo(a.fraction));
  return list;
});

/// Tracks whether SMS permission has been granted and the inbox synced.
final permissionProvider =
    NotifierProvider<PermissionController, PermissionState>(
  PermissionController.new,
);

enum PermissionStatus { unknown, granted, denied }

class PermissionState {
  final PermissionStatus status;
  final bool syncing;
  final int? lastImportCount;

  const PermissionState({
    this.status = PermissionStatus.unknown,
    this.syncing = false,
    this.lastImportCount,
  });

  PermissionState copyWith({
    PermissionStatus? status,
    bool? syncing,
    int? lastImportCount,
  }) {
    return PermissionState(
      status: status ?? this.status,
      syncing: syncing ?? this.syncing,
      lastImportCount: lastImportCount ?? this.lastImportCount,
    );
  }
}

class PermissionController extends Notifier<PermissionState> {
  bool _autoChecked = false;

  @override
  PermissionState build() {
    // Auto-request on startup: if permission was already granted, Android
    // returns immediately with NO dialog, so returning users skip the
    // permission screen entirely. First-run users see the system prompt.
    if (!_autoChecked) {
      _autoChecked = true;
      Future.microtask(requestAndSync);
    }
    return const PermissionState();
  }

  /// Requests SMS permission, then does the initial inbox scan + live listen.
  Future<void> requestAndSync() async {
    final sms = ref.read(smsServiceProvider);
    final granted = await sms.requestPermissions();
    if (!granted) {
      state = state.copyWith(status: PermissionStatus.denied);
      return;
    }
    state = state.copyWith(status: PermissionStatus.granted, syncing: true);

    // Ask for notification permission too (best-effort; alerts are optional).
    await ref.read(notificationServiceProvider).requestPermission();

    final repo = ref.read(transactionRepositoryProvider);
    final imported = await repo.syncInbox();
    repo.startLiveIngest();

    state = state.copyWith(syncing: false, lastImportCount: imported);
  }
}
