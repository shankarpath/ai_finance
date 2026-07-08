import 'package:ai_finance_assistant/models/categories.dart';
import 'package:ai_finance_assistant/services/categorizer_service.dart';
import 'package:ai_finance_assistant/services/merchant_normalizer.dart';
import 'package:ai_finance_assistant/services/parser_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = ParserService();
  const categorizer = CategorizerService();
  const normalizer = MerchantNormalizer();
  final now = DateTime(2026, 7, 3, 19, 30);

  ({double amount, String type, String? merchant, double? balance, String cat})
      run(String body) {
    final p = parser.parse(body: body, receivedAt: now);
    expect(p, isNotNull, reason: 'Expected a parse for: $body');
    final canonical = normalizer.normalize(p!.merchant ?? 'Unknown');
    return (
      amount: p.amount,
      type: p.transactionType,
      merchant: p.merchant,
      balance: p.balance,
      cat: categorizer.categorize(p, canonical).category,
    );
  }

  test('parses the classic UPI spend example', () {
    final r = run('Rs.1,250 spent on UPI at Swiggy. Available balance Rs.23,560');
    expect(r.amount, 1250);
    expect(r.type, 'debit');
    expect(r.merchant?.toLowerCase(), contains('swiggy'));
    expect(r.balance, 23560);
    expect(r.cat, AppCategory.food);
  });

  test('parses debit with A/c tail and Avbl Bal', () {
    final r = run(
        'INR 899.00 debited from A/c XX1234 on 03-Jul for AMAZON. Avbl Bal Rs.5,000.50');
    expect(r.amount, 899);
    expect(r.type, 'debit');
    expect(r.balance, 5000.50);
    expect(r.cat, AppCategory.shopping);
  });

  test('parses a salary credit', () {
    final r = run(
        'Rs 55,000.00 credited to your A/c XX9988 towards SALARY. Bal Rs.61,200');
    expect(r.amount, 55000);
    expect(r.type, 'credit');
    expect(r.cat, AppCategory.salary);
  });

  test('extracts merchant from a UPI VPA handle', () {
    final r = run('Rs.210 paid to uber@ybl via UPI. Avl bal Rs.4,120');
    expect(r.amount, 210);
    expect(r.merchant?.toLowerCase(), contains('uber'));
    expect(r.cat, AppCategory.travel);
  });

  test('ignores OTP messages', () {
    final p = parser.parse(
      body: 'Your OTP is 445566. Do not share it with anyone.',
      receivedAt: now,
    );
    expect(p, isNull);
  });

  test('ignores non-transaction promo messages', () {
    final p = parser.parse(
      body: 'Get cashback of Rs.500 on your next purchase! Offer valid today.',
      receivedAt: now,
    );
    expect(p, isNull);
  });

  test('does not confuse balance figure with the spent amount', () {
    final r = run('Rs.120 spent at CAFE COFFEE. Avbl Bal Rs.9,999');
    expect(r.amount, 120);
    expect(r.balance, 9999);
  });

  // ---- Real formats captured from an HDFC inbox (2026-07) ------------------

  test('parses HDFC card/UPI debit ("Txn Rs..On Card..At <vpa>")', () {
    final p = parser.parse(
      body: 'Txn Rs.291.00\nOn HDFC Bank Card 4335\nAt upiswiggy@icici \n'
          'by UPI 115772496384\nOn 03-07\nNot You?\nCall 18002586161',
      receivedAt: now,
      sender: 'AD-HDFCBK-S',
    );
    expect(p, isNotNull);
    expect(p!.amount, 291);
    expect(p.transactionType, 'debit');
    expect(p.accountLast4, '4335');
    // upiswiggy@icici -> canonical "Swiggy" -> Food
    final canonical = normalizer.normalize(p.merchant ?? '');
    expect(canonical, 'Swiggy');
    expect(categorizer.categorize(p, canonical).category, AppCategory.food);
  });

  test('parses HDFC credit and does NOT use the bank name as merchant', () {
    final p = parser.parse(
      body: 'Credit Alert!\nRs.3000.00 credited to HDFC Bank A/c XX8820 on '
          '03-07-26 from VPA 7993680113@ybl (UPI 073197822149)',
      receivedAt: now,
      sender: 'VM-HDFCBK-S',
    );
    expect(p, isNotNull);
    expect(p!.amount, 3000);
    expect(p.transactionType, 'credit');
    expect(p.merchant, isNot(contains('Bank')));
  });

  test('parses P2P "Sent" debit with the payee as merchant', () {
    final p = parser.parse(
      body: 'Sent Rs.30.00\nFrom HDFC Bank A/C *8820\nTo GOUNI RAJU\n'
          'On 03/07/26\nRef 454206294240',
      receivedAt: now,
      sender: 'VM-HDFCBK-T',
    );
    expect(p, isNotNull);
    expect(p!.amount, 30);
    expect(p.transactionType, 'debit');
    expect(p.merchant, 'GOUNI RAJU');
    expect(p.accountLast4, '8820');
  });

  test('ignores an EMI payment reminder from a real bank sender', () {
    final p = parser.parse(
      body: 'Keeping track of dues helps avoid last-minute stress. Pay Rs.8775 '
          'EMI for HDFC Bank Personal Loan 1824 by 07-Jul-26 for a smoother '
          'month. Ignore if paid.',
      receivedAt: now,
      sender: 'VD-HDFCBK-S',
    );
    expect(p, isNull);
  });

  test('ignores transactional-looking SMS from a non-financial sender', () {
    final p = parser.parse(
      body: 'Rs.499 spent! Grab it now. A/c updated.',
      receivedAt: now,
      sender: 'AX-SHOPXY',
    );
    expect(p, isNull);
  });

  test('does not treat payment-app words as a merchant', () {
    // "via Google Pay" should not yield "pay" as the merchant.
    final p = parser.parse(
      body: 'Rs.9,693.34 credited to A/c XX1234 via Google Pay. Bal Rs.12,000',
      receivedAt: now,
    );
    expect(p, isNotNull);
    expect(p!.merchant, isNot('pay'));
    expect(p.merchant?.toLowerCase(), isNot('google pay'));
  });

  test('produces a stable dedup id for identical messages', () {
    const body = 'Rs.500 spent at DMART. Avbl Bal Rs.100';
    final a = parser.parse(body: body, receivedAt: now)!;
    final b = parser.parse(body: body, receivedAt: now)!;
    expect(a.smsId, b.smsId);
  });
}
