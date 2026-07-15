import '../services/database_service.dart';

/// The single most important number in the app: how much the user can spend
/// per day for the rest of the month without blowing their budgets.
///
/// remaining = Σ max(0, budget limit − spent in that category this month)
/// perDay    = remaining / days left in the month (including today)
class SafeToSpend {
  final bool hasBudgets;
  final double perDay;
  final double remainingTotal;
  final int daysLeft;

  const SafeToSpend({
    required this.hasBudgets,
    required this.perDay,
    required this.remainingTotal,
    required this.daysLeft,
  });

  factory SafeToSpend.from(
    List<Budget> budgets,
    List<Transaction> txns, {
    required DateTime now,
  }) {
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = daysInMonth - now.day + 1;
    if (budgets.isEmpty) {
      return SafeToSpend(
          hasBudgets: false, perDay: 0, remainingTotal: 0, daysLeft: daysLeft);
    }

    final startOfMonth = DateTime(now.year, now.month, 1);
    final spent = <String, double>{};
    for (final t in txns) {
      if (t.transactionType != 'debit' || t.status != 'posted') continue;
      if (t.date.isBefore(startOfMonth)) continue;
      spent.update(t.category, (v) => v + t.amount, ifAbsent: () => t.amount);
    }

    double remaining = 0;
    for (final b in budgets) {
      if (b.monthlyLimit <= 0) continue;
      final left = b.monthlyLimit - (spent[b.category] ?? 0);
      if (left > 0) remaining += left;
    }

    return SafeToSpend(
      hasBudgets: true,
      perDay: remaining / daysLeft,
      remainingTotal: remaining,
      daysLeft: daysLeft,
    );
  }
}
