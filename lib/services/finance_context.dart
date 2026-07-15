import 'dart:convert';

import '../providers/safe_to_spend.dart';
import 'database_service.dart';

/// Builds the compact, privacy-safe spending summary that is sent to the cloud
/// AI. This is the ONLY place transaction data is serialised for the network,
/// so the allow-list of fields here is the privacy boundary.
///
/// Deliberately excluded: raw SMS bodies, account numbers, and balances.
/// Included: category totals, merchant names, amounts, dates, budgets, and
/// coarse derived numbers (safe-to-spend, projection, leaks).
class FinanceContext {
  /// Projects the month-end spend from the run-rate so far.
  static double projectMonthEnd(double monthSpent, DateTime now) {
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    if (now.day == 0) return monthSpent;
    return monthSpent / now.day * daysInMonth;
  }

  /// Returns a JSON string summarising spending — this month, last month,
  /// budgets, safe-to-spend, leaks — plus a short recent-transaction sample.
  static String build(
    List<Transaction> txns, {
    required DateTime now,
    List<Budget> budgets = const [],
    double? goalMonthlySave,
  }) {
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfPrevMonth = DateTime(now.year, now.month - 1, 1);
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(now.year, now.month, now.day);

    final categoryTotals = <String, double>{};
    final prevCategoryTotals = <String, double>{};
    final merchantTotals = <String, double>{};
    double monthSpent = 0, prevMonthSpent = 0, weekSpent = 0, todaySpent = 0;
    double monthIncome = 0;
    int smallCount = 0;
    double smallTotal = 0;
    final subscriptions = <String>{};

    for (final t in txns) {
      // Failed/reversed attempts must not skew the AI's picture of spending.
      if (t.status != 'posted') continue;
      final name = t.merchantCanonical ?? t.merchant;

      if (t.transactionType == 'credit') {
        if (!t.date.isBefore(startOfMonth)) monthIncome += t.amount;
        continue;
      }

      if (t.isSubscription) subscriptions.add(name);
      if (!t.date.isBefore(startOfDay)) todaySpent += t.amount;
      if (!t.date.isBefore(startOfWeek)) weekSpent += t.amount;
      if (!t.date.isBefore(startOfMonth)) {
        monthSpent += t.amount;
        categoryTotals.update(t.category, (v) => v + t.amount,
            ifAbsent: () => t.amount);
        merchantTotals.update(name, (v) => v + t.amount,
            ifAbsent: () => t.amount);
        if (t.amount < 100) {
          smallCount++;
          smallTotal += t.amount;
        }
      } else if (!t.date.isBefore(startOfPrevMonth)) {
        prevMonthSpent += t.amount;
        prevCategoryTotals.update(t.category, (v) => v + t.amount,
            ifAbsent: () => t.amount);
      }
    }

    final topMerchants = merchantTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sts = SafeToSpend.from(budgets, txns, now: now);

    // A small sample of recent transactions (safe fields only).
    final recent = txns.where((t) => t.status == 'posted').take(40).map((t) {
      return {
        'date': t.date.toIso8601String().split('T').first,
        'merchant': t.merchantCanonical ?? t.merchant,
        'category': t.category,
        'type': t.transactionType,
        'amount': _round(t.amount),
      };
    }).toList();

    final summary = {
      'currency': 'INR',
      'today': now.toIso8601String().split('T').first,
      'today_spent': _round(todaySpent),
      'week_spent': _round(weekSpent),
      'month_spent': _round(monthSpent),
      'month_income': _round(monthIncome),
      'prev_month_spent': _round(prevMonthSpent),
      'projected_month_end_spend': _round(projectMonthEnd(monthSpent, now)),
      'category_totals_this_month':
          categoryTotals.map((k, v) => MapEntry(k, _round(v))),
      'category_totals_last_month':
          prevCategoryTotals.map((k, v) => MapEntry(k, _round(v))),
      'budgets': {
        for (final b in budgets)
          b.category: {
            'limit': _round(b.monthlyLimit),
            'spent': _round(categoryTotals[b.category] ?? 0),
          },
      },
      if (sts.hasBudgets)
        'safe_to_spend': {
          'per_day': _round(sts.perDay),
          'remaining_total': _round(sts.remainingTotal),
          'days_left_in_month': sts.daysLeft,
        },
      'small_payments_under_100': {
        'count': smallCount,
        'total': _round(smallTotal),
      },
      'subscriptions': subscriptions.take(15).toList(),
      if (goalMonthlySave != null && goalMonthlySave > 0)
        'monthly_savings_goal': _round(goalMonthlySave),
      'top_merchants': {
        for (final e in topMerchants.take(10)) e.key: _round(e.value),
      },
      'recent_transactions': recent,
    };

    return const JsonEncoder.withIndent('  ').convert(summary);
  }

  static double _round(double v) => (v * 100).roundToDouble() / 100;
}
