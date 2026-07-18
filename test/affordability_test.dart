import 'package:ai_finance_assistant/models/categories.dart';
import 'package:ai_finance_assistant/providers/affordability.dart';
import 'package:ai_finance_assistant/services/database_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 7, 16);
  var id = 0;

  Transaction tx({
    required double amount,
    String type = 'debit',
    String category = AppCategory.food,
    String merchant = 'X',
    double? balance,
    String? account,
    bool sub = false,
    required DateTime date,
  }) =>
      Transaction(
        id: id++,
        amount: amount,
        merchant: merchant,
        merchantCanonical: merchant,
        category: category,
        isSubscription: sub,
        transactionType: type,
        date: date,
        smsBody: 'x',
        smsId: 'x$id',
        status: 'posted',
        balance: balance,
        accountLast4: account,
        needsReview: false,
      );

  group('Affordability.check', () {
    test('yes when balance clears price + upcoming bills + buffer', () {
      final txns = [
        tx(amount: 100, balance: 60000, account: '1234', date: DateTime(2026, 7, 15)),
        // Netflix charged on the 20th last month -> upcoming this month.
        tx(amount: 649, merchant: 'Netflix', sub: true, date: DateTime(2026, 6, 20)),
      ];
      final r = Affordability.check(txns,
          price: 40000, now: now, monthlySaving: 15000, monthlyIncome: 50000);
      expect(r.verdict, AffordVerdict.yes);
      expect(r.knownBalance, 60000);
      expect(r.upcomingRecurring, 649);
      expect(r.leftAfter, 60000 - 649 - 40000);
      expect(r.goalDelayDays, (40000 / 15000 * 30).ceil()); // 80 days
    });

    test('no when the purchase overruns balance minus upcoming bills', () {
      final txns = [
        tx(amount: 100, balance: 20000, account: '1234', date: DateTime(2026, 7, 15)),
      ];
      final r = Affordability.check(txns, price: 45000, now: now);
      expect(r.verdict, AffordVerdict.no);
      expect(r.leftAfter, lessThan(0));
    });

    test('tight when it clears but eats the buffer', () {
      final txns = [
        tx(amount: 100, balance: 46000, account: '1234', date: DateTime(2026, 7, 15)),
      ];
      final r = Affordability.check(txns,
          price: 45000, now: now, monthlyIncome: 50000); // buffer 5000
      expect(r.verdict, AffordVerdict.tight);
    });

    test('unknown when no balance has ever been seen', () {
      final txns = [tx(amount: 100, date: DateTime(2026, 7, 15))];
      final r = Affordability.check(txns, price: 500, now: now);
      expect(r.verdict, AffordVerdict.unknown);
      expect(r.accountsCounted, 0);
    });

    test('uses the LATEST balance per account and sums accounts', () {
      final txns = [
        tx(amount: 1, balance: 10000, account: '1111', date: DateTime(2026, 7, 10)),
        tx(amount: 1, balance: 99999, account: '1111', date: DateTime(2026, 7, 1)),
        tx(amount: 1, balance: 5000, account: '2222', date: DateTime(2026, 7, 12)),
      ];
      final r = Affordability.check(txns, price: 100, now: now);
      expect(r.knownBalance, 15000); // 10000 (latest of 1111) + 5000
      expect(r.accountsCounted, 2);
    });

    test('a subscription already charged this month is not "upcoming"', () {
      final txns = [
        tx(amount: 1, balance: 50000, account: '1234', date: DateTime(2026, 7, 15)),
        tx(amount: 649, merchant: 'Netflix', sub: true, date: DateTime(2026, 7, 2)),
        tx(amount: 649, merchant: 'Netflix', sub: true, date: DateTime(2026, 6, 2)),
      ];
      final r = Affordability.check(txns, price: 1000, now: now);
      expect(r.upcomingRecurring, 0);
    });

    test('predicts days until next salary from the last salary credit', () {
      final txns = [
        tx(amount: 1, balance: 8000, account: '1234', date: DateTime(2026, 7, 15)),
        tx(
            amount: 50000,
            type: 'credit',
            category: AppCategory.salary,
            merchant: 'Employer',
            date: DateTime(2026, 7, 1)),
      ];
      final r = Affordability.check(txns, price: 500, now: now);
      expect(r.daysUntilSalary, DateTime(2026, 8, 1).difference(now).inDays);
    });
  });
}
