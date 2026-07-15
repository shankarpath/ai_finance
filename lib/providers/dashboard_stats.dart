import '../services/database_service.dart';

/// Immutable snapshot of the numbers shown on the dashboard for "today".
class DashboardStats {
  final double todaySpent;
  final int todayCount;
  final Transaction? biggestExpenseToday;
  final double weekSpent;
  final double monthSpent;

  /// The "leak": count and total of small (< ₹100) debits this month. Money
  /// that disappears unnoticed — the whole point is to make it visible.
  final int smallPaymentsCount;
  final double smallPaymentsTotal;

  const DashboardStats({
    required this.todaySpent,
    required this.todayCount,
    required this.biggestExpenseToday,
    required this.weekSpent,
    required this.monthSpent,
    required this.smallPaymentsCount,
    required this.smallPaymentsTotal,
  });

  static const empty = DashboardStats(
    todaySpent: 0,
    todayCount: 0,
    biggestExpenseToday: null,
    weekSpent: 0,
    monthSpent: 0,
    smallPaymentsCount: 0,
    smallPaymentsTotal: 0,
  );

  /// Anything below this (₹) counts as a "small payment" for leak detection.
  static const smallPaymentLimit = 100.0;

  /// Computes stats from the full transaction list. Only debit transactions
  /// count towards "spending".
  factory DashboardStats.from(List<Transaction> txns, {required DateTime now}) {
    final startOfDay = DateTime(now.year, now.month, now.day);
    // Week starts on Monday.
    final startOfWeek = startOfDay.subtract(Duration(days: now.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    double todaySpent = 0;
    int todayCount = 0;
    double weekSpent = 0;
    double monthSpent = 0;
    int smallCount = 0;
    double smallTotal = 0;
    Transaction? biggest;

    for (final t in txns) {
      // Failed/reversed attempts are kept for audit but are not spending.
      if (t.transactionType != 'debit' || t.status != 'posted') continue;
      if (!t.date.isBefore(startOfMonth)) {
        monthSpent += t.amount;
        if (t.amount < smallPaymentLimit) {
          smallCount++;
          smallTotal += t.amount;
        }
      }
      if (!t.date.isBefore(startOfWeek)) weekSpent += t.amount;
      if (!t.date.isBefore(startOfDay)) {
        todaySpent += t.amount;
        todayCount++;
        if (biggest == null || t.amount > biggest.amount) biggest = t;
      }
    }

    return DashboardStats(
      todaySpent: todaySpent,
      todayCount: todayCount,
      biggestExpenseToday: biggest,
      weekSpent: weekSpent,
      monthSpent: monthSpent,
      smallPaymentsCount: smallCount,
      smallPaymentsTotal: smallTotal,
    );
  }
}
