import '../services/database_service.dart';

/// A structured filter over transactions, built from the AI's read-tool
/// arguments. All fields are optional; a null field means "don't filter on it".
class TxnFilter {
  final String? category;

  /// Substring match (case-insensitive) against the canonical/merchant name.
  final String? merchant;

  /// 'debit' or 'credit'.
  final String? type;

  /// Inclusive lower bound (date >= start).
  final DateTime? start;

  /// Inclusive upper bound (date <= end).
  final DateTime? end;

  final double? minAmount;
  final double? maxAmount;

  /// When true (default), only 'posted' rows count — failed/reversed attempts
  /// are excluded, matching every analytics surface in the app.
  final bool postedOnly;

  const TxnFilter({
    this.category,
    this.merchant,
    this.type,
    this.start,
    this.end,
    this.minAmount,
    this.maxAmount,
    this.postedOnly = true,
  });
}

/// Pure query engine over an in-memory transaction list — the local backend for
/// the AI coach's read tools. No network, no DB access; fully unit-testable.
///
/// Deliberately returns only safe fields (date, merchant, category, amount,
/// type) — never raw SMS bodies or account numbers — so tool results honour the
/// same privacy allow-list as [FinanceContext].
class TransactionQuery {
  const TransactionQuery._();

  static bool matches(Transaction t, TxnFilter f) {
    if (f.postedOnly && t.status != 'posted') return false;
    if (f.type != null && t.transactionType != f.type) return false;
    if (f.category != null &&
        t.category.toLowerCase() != f.category!.toLowerCase()) {
      return false;
    }
    if (f.merchant != null && f.merchant!.trim().isNotEmpty) {
      final name = (t.merchantCanonical ?? t.merchant).toLowerCase();
      if (!name.contains(f.merchant!.toLowerCase())) return false;
    }
    if (f.start != null && t.date.isBefore(f.start!)) return false;
    if (f.end != null && t.date.isAfter(f.end!)) return false;
    if (f.minAmount != null && t.amount < f.minAmount!) return false;
    if (f.maxAmount != null && t.amount > f.maxAmount!) return false;
    return true;
  }

  /// Matching rows (newest first, capped at [limit]) plus the full match count
  /// and summed amount across *all* matches (not just the returned page).
  static ({int count, double total, List<Transaction> rows}) search(
    List<Transaction> txns,
    TxnFilter f, {
    int limit = 20,
  }) {
    final matched = txns.where((t) => matches(t, f)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final total = matched.fold<double>(0, (s, t) => s + t.amount);
    return (
      count: matched.length,
      total: total,
      rows: matched.take(limit).toList(),
    );
  }

  /// Totals grouped by [groupBy] ∈ {category, merchant, month, day}, sorted
  /// by total descending.
  static Map<String, double> aggregate(
    List<Transaction> txns,
    TxnFilter f,
    String groupBy,
  ) {
    final out = <String, double>{};
    for (final t in txns) {
      if (!matches(t, f)) continue;
      final key = switch (groupBy) {
        'merchant' => t.merchantCanonical ?? t.merchant,
        'month' => _monthKey(t.date),
        'day' => _dayKey(t.date),
        _ => t.category,
      };
      out.update(key, (v) => v + t.amount, ifAbsent: () => t.amount);
    }
    final sorted = out.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final e in sorted) e.key: e.value};
  }

  static String _monthKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';
  static String _dayKey(DateTime d) =>
      '${_monthKey(d)}-${d.day.toString().padLeft(2, '0')}';
}
