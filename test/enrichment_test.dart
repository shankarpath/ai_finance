import 'package:ai_finance_assistant/models/categories.dart';
import 'package:ai_finance_assistant/services/categorizer_service.dart';
import 'package:ai_finance_assistant/services/database_service.dart';
import 'package:ai_finance_assistant/services/merchant_normalizer.dart';
import 'package:ai_finance_assistant/services/parser_service.dart';
import 'package:ai_finance_assistant/services/subscription_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const normalizer = MerchantNormalizer();
  const parser = ParserService();
  const categorizer = CategorizerService();
  final now = DateTime(2026, 7, 3);

  group('MerchantNormalizer', () {
    test('collapses Swiggy variants to one canonical name', () {
      for (final raw in [
        'SWIGGY',
        'SWIGGY LIMITED',
        'SWIGGY*ONLINE',
        'SWIGGYBLR',
        'SWIGGY-UPI',
        'upiswiggy@icici',
      ]) {
        expect(normalizer.normalize(raw), 'Swiggy', reason: raw);
      }
    });

    test('keeps Swiggy Instamart distinct (grocery)', () {
      expect(normalizer.normalize('SWIGGYINSTAMART'), 'Swiggy Instamart');
    });

    test('normalizes Amazon and Zomato variants', () {
      expect(normalizer.normalize('AMZN INDIA'), 'Amazon');
      expect(normalizer.normalize('AMAZON SELLER SERVICES'), 'Amazon');
      expect(normalizer.normalize('payzomato@hdfcbank'), 'Zomato');
    });

    test('title-cases an unknown person payee', () {
      expect(normalizer.normalize('GOUNI RAJU'), 'Gouni Raju');
    });
  });

  group('Categorizer special types', () {
    String catFor(String body, {String? sender}) {
      final p = parser.parse(body: body, receivedAt: now, sender: sender);
      expect(p, isNotNull, reason: body);
      final canonical = normalizer.normalize(p!.merchant ?? 'Unknown');
      return categorizer.categorize(p, canonical).category;
    }

    test('EMI deduction -> EMI', () {
      expect(
        catFor('EMI of Rs.3250.00 deducted from A/c XX1234 on 03-07',
            sender: 'AD-HDFCBK'),
        AppCategory.emi,
      );
    });

    test('bank fee -> Bank Charges (but recharge stays Bills)', () {
      expect(
        catFor('Rs.590 debited from A/c XX1234 towards Annual Fee. Ref 99',
            sender: 'HDFCBK'),
        AppCategory.bankCharges,
      );
      expect(
        catFor('Rs.299 debited for Airtel mobile recharge. A/c XX1234',
            sender: 'HDFCBK'),
        AppCategory.bills,
      );
    });

    test('ATM cash -> Cash Withdrawal', () {
      expect(
        catFor('Rs.2000 withdrawn at ATM from A/c XX1234. Avbl Bal Rs.500',
            sender: 'HDFCBK'),
        AppCategory.cash,
      );
    });

    test('user merchant-memory overrides the rules', () {
      final p = parser.parse(
        body: 'Rs.291 spent at upiswiggy@icici via UPI 123456789. Bal Rs.100',
        receivedAt: now,
        sender: 'HDFCBK',
      );
      expect(p, isNotNull);
      final canonical = normalizer.normalize(p!.merchant ?? '');
      expect(canonical, 'Swiggy');
      // Rules alone -> Food.
      expect(categorizer.categorize(p, canonical).category, AppCategory.food);
      // A remembered choice wins, with source 'user' and full confidence.
      final r = categorizer
          .categorize(p, canonical, memory: {canonical: AppCategory.shopping});
      expect(r.category, AppCategory.shopping);
      expect(r.source, 'user');
      expect(r.confidence, 100);
    });

    test('P2P UPI to a person -> Transfer (low confidence)', () {
      final p = parser.parse(
        body: 'Sent Rs.500 to RAHUL KUMAR via UPI 123456789012. From A/c XX1234',
        receivedAt: now,
        sender: 'HDFCBK',
      );
      expect(p, isNotNull);
      final canonical = normalizer.normalize(p!.merchant ?? '');
      expect(canonical, 'Rahul Kumar');
      final r = categorizer.categorize(p, canonical);
      expect(r.category, AppCategory.transfer);
      expect(r.confidence, lessThan(60));
    });

    test('credit subtypes: refund / cashback / interest / salary', () {
      expect(catFor('Rs.150 refund credited to A/c XX1234', sender: 'HDFCBK'),
          AppCategory.refund);
      expect(catFor('Rs.20 cashback credited to A/c XX1234', sender: 'HDFCBK'),
          AppCategory.cashback);
      expect(
          catFor('Rs.312 interest credited to A/c XX1234', sender: 'HDFCBK'),
          AppCategory.interest);
      expect(
          catFor('Rs.55000 credited to A/c XX1234 towards SALARY',
              sender: 'HDFCBK'),
          AppCategory.salary);
    });
  });

  group('SubscriptionDetector', () {
    Transaction tx(String canonical, double amount, DateTime date) => Transaction(
          id: date.millisecondsSinceEpoch,
          amount: amount,
          merchant: canonical,
          merchantCanonical: canonical,
          category: AppCategory.entertainment,
          isSubscription: false,
          transactionType: 'debit',
          date: date,
          smsBody: 'x',
          smsId: '$canonical-${date.toIso8601String()}',
          status: 'posted',
          needsReview: false,
        );

    test('flags a known subscription brand', () {
      final subs = SubscriptionDetector.detect([tx('Netflix', 199, now)]);
      expect(subs, contains('Netflix'));
    });

    test('flags a recurring similar-amount monthly charge', () {
      final subs = SubscriptionDetector.detect([
        tx('MyGym', 1000, DateTime(2026, 5, 3)),
        tx('MyGym', 1050, DateTime(2026, 6, 3)),
      ]);
      expect(subs, contains('MyGym'));
    });

    test('does not flag a one-off purchase', () {
      final subs = SubscriptionDetector.detect([tx('RandomShop', 500, now)]);
      expect(subs, isNot(contains('RandomShop')));
    });
  });
}
