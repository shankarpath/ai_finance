import 'dart:convert';

import 'database_service.dart';

/// Builds the compact, privacy-safe spending summary that is sent to the cloud
/// AI. This is the ONLY place transaction data is serialised for the network,
/// so the allow-list of fields here is the privacy boundary.
///
/// Deliberately excluded: raw SMS bodies, account numbers, and balances.
/// Included: category totals, merchant names, amounts, dates, and coarse totals.
class FinanceContext {
  /// Returns a JSON string summarising spending for the current month plus a
  /// short list of recent transactions.
  static String build(List<Transaction> txns, {required DateTime now}) {
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfWeek =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));

    final categoryTotals = <String, double>{};
    final merchantTotals = <String, double>{};
    double monthSpent = 0;
    double weekSpent = 0;

    for (final t in txns) {
      // Failed/reversed attempts must not skew the AI's picture of spending.
      if (t.transactionType != 'debit' || t.status != 'posted') continue;
      if (!t.date.isBefore(startOfWeek)) weekSpent += t.amount;
      if (t.date.isBefore(startOfMonth)) continue;
      monthSpent += t.amount;
      categoryTotals.update(t.category, (v) => v + t.amount,
          ifAbsent: () => t.amount);
      merchantTotals.update(t.merchantCanonical ?? t.merchant,
          (v) => v + t.amount,
          ifAbsent: () => t.amount);
    }

    final topMerchants = merchantTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
      'month_spent': _round(monthSpent),
      'week_spent': _round(weekSpent),
      'category_totals': categoryTotals
          .map((k, v) => MapEntry(k, _round(v))),
      'top_merchants': {
        for (final e in topMerchants.take(10)) e.key: _round(e.value),
      },
      'recent_transactions': recent,
    };

    return const JsonEncoder.withIndent('  ').convert(summary);
  }

  static double _round(double v) => (v * 100).roundToDouble() / 100;
}
