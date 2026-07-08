import 'database_service.dart';

/// Flags recurring subscription merchants using simple offline heuristics:
/// a known subscription brand, OR the same merchant charged a similar amount
/// across two or more distinct months.
class SubscriptionDetector {
  static const _knownSubscriptionBrands = {
    'netflix', 'spotify', 'prime video', 'hotstar', 'youtube', 'disney',
    'jio', 'airtel', 'apple music', 'audible', 'sonyliv', 'zee5',
  };

  /// Returns the set of canonical merchant names that look like subscriptions.
  static Set<String> detect(List<Transaction> txns) {
    final byMerchant = <String, List<Transaction>>{};
    for (final t in txns) {
      if (t.transactionType != 'debit') continue;
      final m = (t.merchantCanonical ?? t.merchant).trim();
      if (m.isEmpty || m == 'Unknown') continue;
      byMerchant.putIfAbsent(m, () => []).add(t);
    }

    final subs = <String>{};
    byMerchant.forEach((merchant, list) {
      final lower = merchant.toLowerCase();
      if (_knownSubscriptionBrands.any(lower.contains)) {
        subs.add(merchant);
        return;
      }
      if (_looksRecurring(list)) subs.add(merchant);
    });
    return subs;
  }

  /// True if there are ≥2 charges in ≥2 distinct months with amounts within
  /// ~15% of each other (a steady monthly-ish charge).
  static bool _looksRecurring(List<Transaction> list) {
    if (list.length < 2) return false;
    final months = list.map((t) => t.date.year * 12 + t.date.month).toSet();
    if (months.length < 2) return false;

    final amounts = list.map((t) => t.amount).toList();
    final min = amounts.reduce((a, b) => a < b ? a : b);
    final max = amounts.reduce((a, b) => a > b ? a : b);
    if (min <= 0) return false;
    return (max - min) / min <= 0.15;
  }
}
