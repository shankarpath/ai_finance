import 'package:ai_finance_assistant/models/categories.dart';
import 'package:ai_finance_assistant/services/database_service.dart';
import 'package:ai_finance_assistant/services/transaction_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var id = 0;
  Transaction tx({
    required double amount,
    String type = 'debit',
    String category = AppCategory.food,
    String merchant = 'Swiggy',
    String status = 'posted',
    required DateTime date,
  }) =>
      Transaction(
        id: id++,
        amount: amount,
        merchant: merchant,
        merchantCanonical: merchant,
        category: category,
        isSubscription: false,
        transactionType: type,
        date: date,
        smsBody: 'x',
        smsId: 'x${id}',
        status: status,
        needsReview: false,
      );

  final txns = [
    tx(amount: 300, category: AppCategory.food, merchant: 'Swiggy', date: DateTime(2026, 3, 5)),
    tx(amount: 500, category: AppCategory.food, merchant: 'Dominos', date: DateTime(2026, 3, 20)),
    tx(amount: 200, category: AppCategory.food, merchant: 'Swiggy', date: DateTime(2026, 4, 2)),
    tx(amount: 1500, category: AppCategory.shopping, merchant: 'Amazon', date: DateTime(2026, 4, 10)),
    tx(amount: 999, category: AppCategory.food, merchant: 'Zomato', status: 'failed', date: DateTime(2026, 4, 11)),
    tx(amount: 55000, type: 'credit', category: AppCategory.salary, merchant: 'Employer', date: DateTime(2026, 4, 1)),
  ];

  group('TransactionQuery.search', () {
    test('filters by category and sums only matches (posted only)', () {
      final r = TransactionQuery.search(
          txns, const TxnFilter(category: AppCategory.food));
      // 3 posted food rows (300 + 500 + 200); the 999 Zomato is failed.
      expect(r.count, 3);
      expect(r.total, 1000);
    });

    test('filters by merchant substring, case-insensitive', () {
      final r = TransactionQuery.search(
          txns, const TxnFilter(merchant: 'swig'));
      expect(r.count, 2);
      expect(r.total, 500);
    });

    test('filters by date range and returns newest first', () {
      final r = TransactionQuery.search(
        txns,
        TxnFilter(start: DateTime(2026, 3, 1), end: DateTime(2026, 3, 31)),
      );
      expect(r.count, 2);
      expect(r.rows.first.date, DateTime(2026, 3, 20)); // newest first
    });

    test('respects a limit but counts all matches', () {
      final r =
          TransactionQuery.search(txns, const TxnFilter(), limit: 2);
      expect(r.rows.length, 2);
      expect(r.count, 5); // all posted rows
    });

    test('min/max amount bounds', () {
      final r = TransactionQuery.search(
          txns, const TxnFilter(minAmount: 400, maxAmount: 2000));
      // 500 (Dominos) and 1500 (Amazon)
      expect(r.count, 2);
    });
  });

  group('TransactionQuery.aggregate', () {
    test('groups by merchant, sorted by total desc', () {
      final map = TransactionQuery.aggregate(
          txns, const TxnFilter(type: 'debit'), 'merchant');
      expect(map.keys.first, 'Amazon'); // 1500 is the largest
      expect(map['Swiggy'], 500);
      expect(map.containsKey('Zomato'), isFalse); // failed excluded
    });

    test('groups by month', () {
      final map = TransactionQuery.aggregate(
          txns, const TxnFilter(category: AppCategory.food), 'month');
      expect(map['2026-03'], 800);
      expect(map['2026-04'], 200);
    });
  });
}
