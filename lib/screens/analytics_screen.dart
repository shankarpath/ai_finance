import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/categories.dart';
import '../providers/analytics_data.dart';
import '../providers/app_providers.dart';
import '../utils/formatters.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(analyticsDataProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: data.isEmpty
          ? const Center(child: Text('No spending data yet.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('This month', style: theme.textTheme.titleMedium),
                Text(
                  formatRupees(data.totalSpent),
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  title: 'Spending by category',
                  child: _CategoryPie(totals: data.categoryTotals),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Last 14 days',
                  child: _DailyBars(days: data.last14Days),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Top merchants',
                  child: _MerchantRanking(merchants: data.topMerchants),
                ),
              ],
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _CategoryPie extends StatelessWidget {
  final Map<String, double> totals;
  const _CategoryPie({required this.totals});

  @override
  Widget build(BuildContext context) {
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final grandTotal = entries.fold<double>(0, (s, e) => s + e.value);
    if (grandTotal <= 0) {
      return const SizedBox(height: 60, child: Center(child: Text('—')));
    }

    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 44,
              sections: [
                for (final e in entries)
                  PieChartSectionData(
                    value: e.value,
                    color: AppCategory.colorFor(e.key),
                    radius: 58,
                    title: '${(e.value / grandTotal * 100).round()}%',
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            for (final e in entries) _LegendDot(category: e.key, amount: e.value),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String category;
  final double amount;
  const _LegendDot({required this.category, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: AppCategory.colorFor(category),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text('$category  ${formatRupees(amount)}',
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _DailyBars extends StatelessWidget {
  final List<DayTotal> days;
  const _DailyBars({required this.days});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxY = days.fold<double>(0, (m, d) => d.total > m ? d.total : m);
    if (maxY <= 0) {
      return const SizedBox(height: 60, child: Center(child: Text('—')));
    }

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY * 1.2,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                formatRupees(rod.toY),
                const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= days.length) return const SizedBox.shrink();
                  // Label every other day to avoid crowding.
                  if (i % 2 != 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('${days[i].day.day}',
                        style: theme.textTheme.bodySmall),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < days.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: days[i].total,
                    color: theme.colorScheme.primary,
                    width: 10,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _MerchantRanking extends StatelessWidget {
  final List<MerchantTotal> merchants;
  const _MerchantRanking({required this.merchants});

  @override
  Widget build(BuildContext context) {
    if (merchants.isEmpty) {
      return const SizedBox(height: 40, child: Center(child: Text('—')));
    }
    final max = merchants.first.total;
    final theme = Theme.of(context);

    return Column(
      children: [
        for (final m in merchants)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        m.merchant,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text('${formatRupees(m.total)}  (${m.count})',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: max > 0 ? m.total / max : 0,
                    minHeight: 6,
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
