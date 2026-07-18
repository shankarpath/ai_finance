import '../models/categories.dart';
import '../services/database_service.dart';

/// Estimates how much the user can realistically set aside per month, from the
/// gap between income and *discretionary* spending over recent complete months.
///
/// Money out excludes Investment (already a form of saving) and Transfer
/// (mostly own-money / peer movement, too noisy to treat as consumption). The
/// result is clamped at 0 — you can't save a negative amount.
class SavingsCapacity {
  /// Average monthly (income − discretionary spend), never below 0.
  final double monthlyNet;

  /// How many of the looked-back months actually had data (for honesty in UI).
  final int monthsCounted;

  /// Average monthly income over the counted months (for the plan builder).
  final double monthlyIncome;

  const SavingsCapacity(this.monthlyNet, this.monthsCounted,
      {this.monthlyIncome = 0});

  bool get isKnown => monthsCounted > 0 && monthlyNet > 0;

  static SavingsCapacity from(
    List<Transaction> txns, {
    required DateTime now,
    int lookbackMonths = 3,
  }) {
    // The window: the last [lookbackMonths] *completed* months (skip the
    // current partial month so a mid-month dip doesn't distort the estimate).
    final windowKeys = <String>{
      for (var i = 1; i <= lookbackMonths; i++)
        _key(DateTime(now.year, now.month - i, 1)),
    };

    final income = <String, double>{};
    final spend = <String, double>{};
    for (final t in txns) {
      if (t.status != 'posted') continue;
      final key = _key(t.date);
      if (!windowKeys.contains(key)) continue;

      if (t.transactionType == 'credit') {
        if (AppCategory.isIncome(t.category)) {
          income.update(key, (v) => v + t.amount, ifAbsent: () => t.amount);
        }
      } else {
        if (t.category == AppCategory.investment ||
            t.category == AppCategory.transfer) {
          continue;
        }
        spend.update(key, (v) => v + t.amount, ifAbsent: () => t.amount);
      }
    }

    double total = 0;
    double incomeTotal = 0;
    var counted = 0;
    for (final key in windowKeys) {
      final inc = income[key] ?? 0;
      final sp = spend[key] ?? 0;
      if (inc == 0 && sp == 0) continue; // no activity that month — skip
      total += inc - sp;
      incomeTotal += inc;
      counted++;
    }

    if (counted == 0) return const SavingsCapacity(0, 0);
    final avg = total / counted;
    return SavingsCapacity(avg < 0 ? 0 : avg, counted,
        monthlyIncome: incomeTotal / counted);
  }

  static String _key(DateTime d) => '${d.year}-${d.month}';
}
