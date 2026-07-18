import 'package:ai_finance_assistant/models/categories.dart';
import 'package:ai_finance_assistant/providers/savings_capacity.dart';
import 'package:ai_finance_assistant/services/database_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 7, 15);
  var _id = 0;

  Transaction tx({
    required double amount,
    required String type,
    required String category,
    required DateTime date,
  }) =>
      Transaction(
        id: _id++,
        amount: amount,
        merchant: 'x',
        merchantCanonical: 'x',
        category: category,
        isSubscription: false,
        transactionType: type,
        date: date,
        smsBody: 'x',
        smsId: 'x${_id}',
        status: 'posted',
        needsReview: false,
      );

  group('SavingsCapacity', () {
    test('averages income minus discretionary spend over completed months', () {
      final txns = [
        // June: 50000 in, 30000 out -> net 20000
        tx(amount: 50000, type: 'credit', category: AppCategory.salary, date: DateTime(2026, 6, 1)),
        tx(amount: 30000, type: 'debit', category: AppCategory.food, date: DateTime(2026, 6, 10)),
        // May: 50000 in, 20000 out -> net 30000
        tx(amount: 50000, type: 'credit', category: AppCategory.salary, date: DateTime(2026, 5, 1)),
        tx(amount: 20000, type: 'debit', category: AppCategory.shopping, date: DateTime(2026, 5, 8)),
      ];
      final cap = SavingsCapacity.from(txns, now: now);
      expect(cap.monthsCounted, 2);
      expect(cap.monthlyNet, 25000); // (20000 + 30000) / 2
      expect(cap.isKnown, isTrue);
    });

    test('excludes Investment and Transfer from spend', () {
      final txns = [
        tx(amount: 50000, type: 'credit', category: AppCategory.salary, date: DateTime(2026, 6, 1)),
        tx(amount: 10000, type: 'debit', category: AppCategory.investment, date: DateTime(2026, 6, 5)),
        tx(amount: 8000, type: 'debit', category: AppCategory.transfer, date: DateTime(2026, 6, 6)),
        tx(amount: 5000, type: 'debit', category: AppCategory.food, date: DateTime(2026, 6, 7)),
      ];
      final cap = SavingsCapacity.from(txns, now: now);
      // Only Food (5000) counts as spend -> net 45000 over 1 month.
      expect(cap.monthlyNet, 45000);
    });

    test('ignores the current (partial) month', () {
      final txns = [
        tx(amount: 50000, type: 'credit', category: AppCategory.salary, date: DateTime(2026, 7, 2)),
        tx(amount: 1000, type: 'debit', category: AppCategory.food, date: DateTime(2026, 7, 3)),
      ];
      final cap = SavingsCapacity.from(txns, now: now);
      expect(cap.monthsCounted, 0);
      expect(cap.isKnown, isFalse);
    });

    test('clamps a net-negative month set to zero capacity', () {
      final txns = [
        tx(amount: 10000, type: 'credit', category: AppCategory.salary, date: DateTime(2026, 6, 1)),
        tx(amount: 40000, type: 'debit', category: AppCategory.shopping, date: DateTime(2026, 6, 2)),
      ];
      final cap = SavingsCapacity.from(txns, now: now);
      expect(cap.monthlyNet, 0); // -30000 clamped up to 0
      expect(cap.isKnown, isFalse); // known requires net > 0
    });
  });
}
