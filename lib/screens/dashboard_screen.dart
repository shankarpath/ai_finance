import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../utils/formatters.dart';
import '../widgets/stat_card.dart';
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

    // Calendar-period start dates, shown in the labels so it's clear why the
    // week total can exceed the month total early in a month.
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Review uncertain transactions',
            icon: Badge(
              isLabelVisible: reviewCount > 0,
              label: Text('$reviewCount'),
              child: const Icon(Icons.rule),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReviewScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Re-scan inbox',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(transactionRepositoryProvider).syncInbox(),
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Today', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                StatCard(
                  label: 'Spent today',
                  value: formatRupees(stats.todaySpent),
                  icon: Icons.trending_down,
                  accent: const Color(0xFFFF6B6B),
                ),
                StatCard(
                  label: 'Transactions',
                  value: '${stats.todayCount}',
                  icon: Icons.receipt_long,
                  accent: const Color(0xFF4DABF7),
                ),
                StatCard(
                  label: 'Week (from ${formatDayMonth(weekStart)})',
                  value: formatRupees(stats.weekSpent),
                  icon: Icons.calendar_view_week,
                  accent: const Color(0xFF845EF7),
                ),
                StatCard(
                  label: 'Month (from ${formatDayMonth(monthStart)})',
                  value: formatRupees(stats.monthSpent),
                  icon: Icons.calendar_month,
                  accent: const Color(0xFFFFA94D),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (stats.biggestExpenseToday != null)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.local_fire_department,
                      color: Color(0xFFFF6B6B)),
                  title: const Text('Biggest expense today'),
                  subtitle: Text(stats.biggestExpenseToday!.merchantCanonical ??
                      stats.biggestExpenseToday!.merchant),
                  trailing: Text(
                    formatRupees(stats.biggestExpenseToday!.amount),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Recent transactions', style: theme.textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const TransactionsScreen()),
                  ),
                  child: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            txnsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Could not load transactions: $e'),
              ),
              data: (txns) {
                if (txns.isEmpty) return const _EmptyState();
                return Column(
                  children: [
                    for (final t in txns.take(50)) TransactionTile(txn: t),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.inbox, size: 56, color: Theme.of(context).disabledColor),
          const SizedBox(height: 12),
          const Text('No transactions found yet.'),
          const SizedBox(height: 4),
          const Text(
            'Pull down to re-scan your SMS inbox.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
