import '../services/database_service.dart';

class MerchantTotal {
  final String merchant;
  final double total;
  final int count;
  const MerchantTotal(this.merchant, this.total, this.count);
}

class DayTotal {
  final DateTime day;
  final double total;
  const DayTotal(this.day, this.total);
}

/// Aggregations for the Analytics screen, derived from all transactions.
/// Only debit transactions in the current month count as "spending".
class AnalyticsData {
  final Map<String, double> categoryTotals; // category -> spent (this month)
  final double totalSpent;
  final List<DayTotal> last14Days; // oldest -> newest
  final List<MerchantTotal> topMerchants; // highest spend first

  const AnalyticsData({
    required this.categoryTotals,
    required this.totalSpent,
    required this.last14Days,
    required this.topMerchants,
  });

  static const empty = AnalyticsData(
    categoryTotals: {},
    totalSpent: 0,
    last14Days: [],
    topMerchants: [],
  );

  bool get isEmpty => totalSpent == 0 && topMerchants.isEmpty;

  factory AnalyticsData.from(List<Transaction> txns, {required DateTime now}) {
    final startOfMonth = DateTime(now.year, now.month, 1);
    final today = DateTime(now.year, now.month, now.day);

    final categoryTotals = <String, double>{};
    final merchantAgg = <String, ({double total, int count})>{};
    double totalSpent = 0;

    // Buckets for the last 14 calendar days (including today).
    final dayBuckets = <DateTime, double>{};
    for (var i = 13; i >= 0; i--) {
      dayBuckets[today.subtract(Duration(days: i))] = 0;
    }

    for (final t in txns) {
      // Failed/reversed attempts are kept for audit but are not spending.
      if (t.transactionType != 'debit' || t.status != 'posted') continue;

      // Per-day totals (last 14 days window).
      final day = DateTime(t.date.year, t.date.month, t.date.day);
      if (dayBuckets.containsKey(day)) {
        dayBuckets[day] = dayBuckets[day]! + t.amount;
      }

      // Category + merchant + total are scoped to the current month.
      if (t.date.isBefore(startOfMonth)) continue;
      totalSpent += t.amount;
      categoryTotals.update(t.category, (v) => v + t.amount,
          ifAbsent: () => t.amount);
      final name = t.merchantCanonical ?? t.merchant;
      final prev = merchantAgg[name];
      merchantAgg[name] = prev == null
          ? (total: t.amount, count: 1)
          : (total: prev.total + t.amount, count: prev.count + 1);
    }

    final merchants = merchantAgg.entries
        .map((e) => MerchantTotal(e.key, e.value.total, e.value.count))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    final days = dayBuckets.entries
        .map((e) => DayTotal(e.key, e.value))
        .toList()
      ..sort((a, b) => a.day.compareTo(b.day));

    return AnalyticsData(
      categoryTotals: categoryTotals,
      totalSpent: totalSpent,
      last14Days: days,
      topMerchants: merchants.take(8).toList(),
    );
  }
}
