import 'package:ai_finance_assistant/models/categories.dart';
import 'package:ai_finance_assistant/providers/safe_to_spend.dart';
import 'package:ai_finance_assistant/services/database_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Transaction tx(String category, double amount, DateTime date,
          {String status = 'posted', String type = 'debit'}) =>
      Transaction(
        id: date.microsecondsSinceEpoch + amount.toInt(),
        amount: amount,
        merchant: 'M',
        merchantCanonical: 'M',
        category: category,
        isSubscription: false,
        needsReview: false,
        transactionType: type,
        status: status,
        date: date,
        smsBody: 'x',
        smsId: '$category-$amount-${date.toIso8601String()}',
      );

  Budget budget(String category, double limit) =>
      Budget(category: category, monthlyLimit: limit);

  // 10 July 2026 → 31-day month, 22 days left including today.
  final now = DateTime(2026, 7, 10);

  test('no budgets -> hasBudgets false', () {
    final s = SafeToSpend.from(const [], const [], now: now);
    expect(s.hasBudgets, isFalse);
  });

  test('computes remaining / days left', () {
    final s = SafeToSpend.from(
      [budget(AppCategory.food, 3000), budget(AppCategory.travel, 1000)],
      [
        tx(AppCategory.food, 800, DateTime(2026, 7, 5)),
        tx(AppCategory.travel, 200, DateTime(2026, 7, 6)),
        // Outside the month — ignored.
        tx(AppCategory.food, 999, DateTime(2026, 6, 20)),
      ],
      now: now,
    );
    expect(s.hasBudgets, isTrue);
    expect(s.daysLeft, 22);
    expect(s.remainingTotal, 3000 - 800 + 1000 - 200); // 3000
    expect(s.perDay, closeTo(3000 / 22, 0.01));
  });

  test('overspent category clamps at zero (never negative)', () {
    final s = SafeToSpend.from(
      [budget(AppCategory.food, 500), budget(AppCategory.travel, 1000)],
      [tx(AppCategory.food, 900, DateTime(2026, 7, 5))],
      now: now,
    );
    expect(s.remainingTotal, 1000); // food contributes 0, not -400
  });

  test('failed/reversed and credit rows do not reduce the budget', () {
    final s = SafeToSpend.from(
      [budget(AppCategory.food, 1000)],
      [
        tx(AppCategory.food, 300, DateTime(2026, 7, 5), status: 'failed'),
        tx(AppCategory.food, 200, DateTime(2026, 7, 6), status: 'reversed'),
        tx(AppCategory.food, 100, DateTime(2026, 7, 7), type: 'credit'),
      ],
      now: now,
    );
    expect(s.remainingTotal, 1000);
  });
}
