import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../services/finance_context.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/nav_bus.dart';
import '../widgets/coach_widgets.dart';
import '../widgets/transaction_tile.dart';
import 'review_screen.dart';
import 'settings_screen.dart';
import 'transactions_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);
    final txnsAsync = ref.watch(allTransactionsProvider);
    final reviewCount = ref.watch(reviewQueueProvider).length;
    final theme = Theme.of(context);
    final loading = txnsAsync.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FinCoach'),
        actions: [
          IconButton(
            tooltip: 'Review uncertain transactions',
            icon: Badge(
              isLabelVisible: reviewCount > 0,
              label: Text(reviewCount > 99 ? '99+' : '$reviewCount'),
              child: const Icon(Icons.rule),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReviewScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(transactionRepositoryProvider).syncInbox(),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              sliver: SliverList.list(children: [
                if (loading) ...const [
                  SkeletonBox(height: 190),
                  SizedBox(height: 12),
                  SkeletonBox(height: 72),
                  SizedBox(height: 12),
                  SkeletonBox(height: 96),
                ] else ...[
                  const _SafeToSpendHero()
                      .animate()
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.06, curve: Curves.easeOutCubic),
                  const SizedBox(height: 12),
                  const _InsightCard().animate().fadeIn(delay: 80.ms),
                  const SizedBox(height: 12),
                  _StatStrip(stats: stats).animate().fadeIn(delay: 140.ms),
                  const SizedBox(height: 12),
                  const _TrendCard().animate().fadeIn(delay: 200.ms),
                  if (stats.biggestExpenseToday != null) ...[
                    const SizedBox(height: 12),
                    Panel(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(children: [
                        const Icon(Icons.local_fire_department,
                            color: AppTheme.coral),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Biggest expense today',
                                  style: theme.textTheme.bodySmall),
                              Text(
                                stats.biggestExpenseToday!.merchantCanonical ??
                                    stats.biggestExpenseToday!.merchant,
                                style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatRupees(stats.biggestExpenseToday!.amount),
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ]),
                    ),
                  ],
                  if (stats.smallPaymentsCount >= 5) ...[
                    const SizedBox(height: 12),
                    Panel(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(children: [
                        const Icon(Icons.water_drop_outlined,
                            color: AppTheme.sky),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${stats.smallPaymentsCount} small payments '
                                  'this month',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700)),
                              Text('Each under ₹100 — they add up',
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                        Text(formatRupees(stats.smallPaymentsTotal),
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800)),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(children: [
                    Text('Recent activity',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const TransactionsScreen()),
                      ),
                      child: const Text('See all'),
                    ),
                  ]),
                ],
              ]),
            ),
            if (!loading)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: _RecentList(
                    txns: (txnsAsync.value ?? const []).take(30).toList()),
              ),
          ],
        ),
      ),
    );
  }
}

/// The hero: gauge + the one number that matters.
class _SafeToSpendHero extends ConsumerWidget {
  const _SafeToSpendHero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sts = ref.watch(safeToSpendProvider);
    final stats = ref.watch(dashboardStatsProvider);
    final theme = Theme.of(context);
    final projected =
        FinanceContext.projectMonthEnd(stats.monthSpent, DateTime.now());

    if (!sts.hasBudgets) {
      return Panel(
        gradient: AppTheme.heroGradient,
        child: Row(children: [
          const Icon(Icons.speed, color: AppTheme.mint, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Set budgets (or let the coach set them) to unlock your daily '
              '“safe to spend” number.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ]),
      );
    }

    final totalBudget = sts.remainingTotal +
        (stats.monthSpent.clamp(0, double.infinity)); // approximation for arc
    final fraction =
        totalBudget <= 0 ? 0.0 : sts.remainingTotal / totalBudget;
    final tight = sts.perDay < 100;

    return Panel(
      gradient: tight ? AppTheme.dangerGradient : AppTheme.heroGradient,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SafeToSpendGauge(
            remainingFraction: fraction,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CountUpText(
                  value: sts.perDay,
                  format: formatRupees,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text('per day',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: Colors.white60)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SAFE TO SPEND',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white54,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 8),
                _heroLine(theme, Icons.account_balance_wallet_outlined,
                    '${formatRupees(sts.remainingTotal)} left in budgets'),
                _heroLine(theme, Icons.event,
                    '${sts.daysLeft} day${sts.daysLeft == 1 ? '' : 's'} to go'),
                _heroLine(theme, Icons.query_stats,
                    'Projected month-end ${formatRupees(projected)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroLine(ThemeData theme, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(icon, size: 15, color: Colors.white54),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style:
                  theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }
}

/// The coach's one-liner for today.
class _InsightCard extends ConsumerWidget {
  const _InsightCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insight = ref.watch(insightCardProvider);
    final theme = Theme.of(context);

    return Panel(
      onTap: NavBus.openCoach,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.violet.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.auto_awesome,
              color: AppTheme.violet, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: insight.when(
            loading: () => const SkeletonBox(height: 16),
            error: (_, __) => Text('Coach is offline right now.',
                style: theme.textTheme.bodyMedium),
            data: (text) => Text(
              text ?? 'Add your Gemini key in Settings to get daily coaching.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600, height: 1.3),
            ),
          ),
        ),
        const Icon(Icons.chevron_right, size: 18),
      ]),
    );
  }
}

class _StatStrip extends StatelessWidget {
  final dynamic stats;
  const _StatStrip({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: _MiniStat(
              label: 'Today',
              value: stats.todaySpent,
              accent: AppTheme.coral)),
      const SizedBox(width: 10),
      Expanded(
          child: _MiniStat(
              label: 'This week',
              value: stats.weekSpent,
              accent: AppTheme.violet)),
      const SizedBox(width: 10),
      Expanded(
          child: _MiniStat(
              label: 'This month',
              value: stats.monthSpent,
              accent: AppTheme.amber)),
    ]);
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double value;
  final Color accent;
  const _MiniStat(
      {required this.label, required this.value, required this.accent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Panel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 22, height: 3.5,
              decoration: BoxDecoration(
                  color: accent, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 8),
          FittedBox(
            child: CountUpText(
              value: value,
              format: formatRupees,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

/// 14-day spending sparkline.
class _TrendCard extends ConsumerWidget {
  const _TrendCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(analyticsDataProvider);
    final theme = Theme.of(context);
    final days = data.last14Days;
    if (days.isEmpty) return const SizedBox.shrink();
    final maxY = days.fold<double>(0, (m, d) => d.total > m ? d.total : m);

    return Panel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Last 14 days',
              style: theme.textTheme.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          SizedBox(
            height: 64,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY <= 0 ? 1 : maxY * 1.15,
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < days.length; i++)
                        FlSpot(i.toDouble(), days[i].total),
                    ],
                    isCurved: true,
                    curveSmoothness: 0.32,
                    color: AppTheme.mint,
                    barWidth: 2.4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.mint.withValues(alpha: 0.22),
                          AppTheme.mint.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 600),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentList extends StatelessWidget {
  final List<dynamic> txns;
  const _RecentList({required this.txns});

  @override
  Widget build(BuildContext context) {
    if (txns.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(children: [
            Icon(Icons.inbox,
                size: 52, color: Theme.of(context).disabledColor),
            const SizedBox(height: 10),
            const Text('No transactions yet — pull down to scan.'),
          ]),
        ),
      );
    }
    return SliverList.builder(
      itemCount: txns.length,
      itemBuilder: (context, i) => TransactionTile(txn: txns[i]),
    );
  }
}
