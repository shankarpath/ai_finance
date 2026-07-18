import '../models/categories.dart';
import '../services/database_service.dart';

/// The verdict of a "can I afford this?" check.
enum AffordVerdict {
  /// Comfortably affordable — money left over even after upcoming bills.
  yes,

  /// Possible, but it eats into the safety buffer — waiting is smarter.
  tight,

  /// Buying now would leave less than the upcoming bills need.
  no,

  /// Not enough data (no known balance) to answer honestly.
  unknown,
}

/// One upcoming recurring charge (subscription/EMI) predicted for the rest of
/// this month, used to explain "why" behind the verdict.
class UpcomingCharge {
  final String merchant;
  final double amount;
  const UpcomingCharge(this.merchant, this.amount);
}

/// Everything the coach needs to answer "Can I buy X for ₹Y?" — computed
/// locally from real data, never guessed.
class AffordabilityResult {
  final AffordVerdict verdict;
  final double price;

  /// Sum of the most recent known balance per active account.
  final double knownBalance;
  final int accountsCounted;

  /// Subscriptions/EMIs predicted to charge in the remainder of this month.
  final double upcomingRecurring;
  final List<UpcomingCharge> upcomingCharges;

  /// balance − upcoming recurring − price.
  final double leftAfter;

  /// The safety cushion the verdict was judged against.
  final double buffer;

  /// How many days later the monthly savings goal is reached if this money
  /// comes out of savings (null when no saving rate is known).
  final int? goalDelayDays;

  /// Days until the next predicted salary credit (null if no salary seen).
  final int? daysUntilSalary;

  const AffordabilityResult({
    required this.verdict,
    required this.price,
    required this.knownBalance,
    required this.accountsCounted,
    required this.upcomingRecurring,
    required this.upcomingCharges,
    required this.leftAfter,
    required this.buffer,
    this.goalDelayDays,
    this.daysUntilSalary,
  });
}

/// Pure affordability engine: no network, no DB handle — fully unit-testable.
class Affordability {
  const Affordability._();

  /// [monthlySaving] is the user's saving rate (goal or estimated surplus);
  /// [monthlyIncome] scales the safety buffer.
  static AffordabilityResult check(
    List<Transaction> txns, {
    required double price,
    required DateTime now,
    double monthlySaving = 0,
    double monthlyIncome = 0,
  }) {
    final balanceInfo = _latestBalances(txns, now);
    final upcoming = _upcomingRecurring(txns, now);
    final upcomingTotal =
        upcoming.fold<double>(0, (s, u) => s + u.amount);

    // Safety cushion: a tenth of monthly income, floor ₹2,000. Below this the
    // purchase is "tight" even when the arithmetic technically clears.
    final buffer =
        (monthlyIncome * 0.10) < 2000 ? 2000.0 : monthlyIncome * 0.10;

    final left = balanceInfo.total - upcomingTotal - price;

    AffordVerdict verdict;
    if (balanceInfo.accounts == 0) {
      verdict = AffordVerdict.unknown;
    } else if (left >= buffer) {
      verdict = AffordVerdict.yes;
    } else if (left >= 0) {
      verdict = AffordVerdict.tight;
    } else {
      verdict = AffordVerdict.no;
    }

    return AffordabilityResult(
      verdict: verdict,
      price: price,
      knownBalance: balanceInfo.total,
      accountsCounted: balanceInfo.accounts,
      upcomingRecurring: upcomingTotal,
      upcomingCharges: upcoming,
      leftAfter: left,
      buffer: buffer,
      goalDelayDays: monthlySaving > 0
          ? (price / monthlySaving * 30).ceil()
          : null,
      daysUntilSalary: _daysUntilSalary(txns, now),
    );
  }

  /// Latest known balance per account (from SMS balance clauses), counting only
  /// accounts active in the last 60 days so a dormant account doesn't inflate
  /// the picture.
  static ({double total, int accounts}) _latestBalances(
      List<Transaction> txns, DateTime now) {
    final cutoff = now.subtract(const Duration(days: 60));
    final latest = <String, Transaction>{};
    for (final t in txns) {
      if (t.balance == null || t.status != 'posted') continue;
      if (t.date.isBefore(cutoff)) continue;
      final key = t.accountLast4 ?? '?';
      final existing = latest[key];
      if (existing == null || t.date.isAfter(existing.date)) latest[key] = t;
    }
    // If any real account keys exist, drop the "?" bucket — it is usually the
    // same account announced by a sender that omitted the number.
    if (latest.length > 1) latest.remove('?');
    double total = 0;
    for (final t in latest.values) {
      total += t.balance!;
    }
    return (total: total, accounts: latest.length);
  }

  /// Subscriptions and EMIs whose usual charge day is still ahead this month
  /// and which haven't charged yet this month.
  static List<UpcomingCharge> _upcomingRecurring(
      List<Transaction> txns, DateTime now) {
    final startOfMonth = DateTime(now.year, now.month, 1);
    // merchant -> recent posted debits (newest first, txns arrive sorted).
    final history = <String, List<Transaction>>{};
    for (final t in txns) {
      if (t.transactionType != 'debit' || t.status != 'posted') continue;
      final recurring = t.isSubscription || t.category == AppCategory.emi;
      if (!recurring) continue;
      final name = t.merchantCanonical ?? t.merchant;
      history.putIfAbsent(name, () => []).add(t);
    }

    final out = <UpcomingCharge>[];
    history.forEach((merchant, rows) {
      final chargedThisMonth =
          rows.any((t) => !t.date.isBefore(startOfMonth));
      if (chargedThisMonth) return;
      final past = rows.where((t) => t.date.isBefore(startOfMonth)).toList();
      if (past.isEmpty) return;
      // Usual charge day: the most recent cycle's day-of-month.
      final usualDay = past.first.date.day;
      if (usualDay < now.day) return; // its day already passed — likely lapsed
      final amount = past.take(3).fold<double>(0, (s, t) => s + t.amount) /
          past.take(3).length;
      out.add(UpcomingCharge(merchant, amount));
    });
    out.sort((a, b) => b.amount.compareTo(a.amount));
    return out;
  }

  /// Predicts the next salary credit from the most recent one (+1 month).
  static int? _daysUntilSalary(List<Transaction> txns, DateTime now) {
    for (final t in txns) {
      if (t.category == AppCategory.salary && t.status == 'posted') {
        var next = DateTime(t.date.year, t.date.month + 1, t.date.day);
        while (next.isBefore(now)) {
          next = DateTime(next.year, next.month + 1, next.day);
        }
        return next.difference(now).inDays;
      }
    }
    return null;
  }
}
