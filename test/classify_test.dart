import 'package:ai_finance_assistant/services/parser_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = ParserService();
  final now = DateTime(2026, 7, 16);

  ParseResult classify(String body, {String? sender}) =>
      parser.classify(body: body, receivedAt: now, sender: sender);

  group('ParserService.classify — nothing is dropped', () {
    test('a clean debit parses', () {
      final r = classify(
          'Rs.500 debited from A/c XX1234 at SWIGGY via UPI 123456789.',
          sender: 'HDFCBK');
      expect(r.status, ParseStatus.parsed);
      expect(r.isParsed, isTrue);
      expect(r.needsAttention, isFalse);
    });

    test('an OTP is ignored, not queued', () {
      final r = classify('Your OTP is 445566. Do not share it with anyone.',
          sender: 'HDFCBK');
      expect(r.status, ParseStatus.ignoredNonTxn);
      expect(r.needsAttention, isFalse);
    });

    test(
        'a transaction-shaped body from an UNKNOWN sender is queued, not dropped',
        () {
      final r = classify('Rs.500 debited from A/c XX1234 at SWIGGY',
          sender: '9876543210');
      expect(r.status, ParseStatus.unknownSender);
      expect(r.needsAttention, isTrue);
      expect(r.isParsed, isFalse); // not auto-logged either — human confirms
    });

    test('non-transactional junk from an unknown sender is still ignored', () {
      final r = classify('Flash sale! 70% off everything this weekend only!',
          sender: 'VM-PROMO');
      expect(r.status, ParseStatus.ignoredSender);
      expect(r.needsAttention, isFalse);
    });

    test('financial sender + amount but no structure → needs attention', () {
      // Has a debit word and an amount, but no account/ref/rail to confirm it.
      final r = classify('Rs.500 spent recently.', sender: 'HDFCBK');
      expect(r.status, ParseStatus.needsStructure);
      expect(r.needsAttention, isTrue);
      // Backwards-compatible parse() still returns null for these.
      expect(
          parser.parse(body: 'Rs.500 spent recently.', receivedAt: now, sender: 'HDFCBK'),
          isNull);
    });

    test('financial sender, no debit/credit direction → needs attention', () {
      final r = classify('Something happened on your account XX1234.',
          sender: 'HDFCBK');
      expect(r.needsAttention, isTrue);
    });

    test('a bill/EMI reminder is ignored (money not moved), not queued', () {
      final r = classify(
          'Your credit card bill of Rs.5000 is due on 20-07. Please pay by then.',
          sender: 'HDFCBK');
      expect(r.status, ParseStatus.ignoredNonTxn);
      expect(r.needsAttention, isFalse);
    });
  });

  group('Real missed formats from the field (2026-07-16)', () {
    test('BOBCARD spend alert with "earned reward points" still parses', () {
      final r = classify(
          'You\'ve paid Rs. 5,175.00 at Dreamplug Paytech S with your BOBCARD '
          'One Credit Card ending in XX0624 and earned reward points! To '
          'dispute this payment, visit: m.1crd.in/OneCrd/shcut',
          sender: 'AD-BOBONE-S');
      expect(r.status, ParseStatus.parsed);
      expect(r.parsed!.amount, 5175.00);
      expect(r.parsed!.transactionType, 'debit');
      expect(r.parsed!.merchant, 'Dreamplug Paytech S');
    });

    test('BOBCARD Zepto alert with "Reward points are now in your basket"', () {
      final r = classify(
          'Fresh picks! You\'ve spent Rs. 182.00 at Zepto Marketplace Private '
          'with your BOBCARD One Credit Card ending in XX0624. Reward points '
          'are now in your basket.',
          sender: 'AD-BOBONE-S');
      expect(r.status, ParseStatus.parsed);
      expect(r.parsed!.amount, 182.00);
      expect(r.parsed!.transactionType, 'debit');
    });

    test('SBI UPI "debited by 25.00" (no currency marker) parses', () {
      final r = classify(
          'Dear UPI user A/C X3148 debited by 25.00 on date 15Jul26 trf to '
          'MR CHAKALI SAIL Refno 153398891393 If not u? call-1800111109',
          sender: 'VM-SBIUPI-S');
      expect(r.status, ParseStatus.parsed);
      expect(r.parsed!.amount, 25.00);
      expect(r.parsed!.transactionType, 'debit');
    });

    test('YES BANK declined txn logs as a failed debit', () {
      final r = classify(
          'Txn of INR 10,350.00 @ DREAMPLUG PAYTECH S on YES BANK Credit Card '
          'ending 9574 is declined due to suspicious high risk txn, call '
          'Customer Care on 18001031212.',
          sender: 'AX-YESBNK-S');
      expect(r.status, ParseStatus.parsed);
      expect(r.parsed!.amount, 10350.00);
      expect(r.parsed!.status, 'failed');
      expect(r.parsed!.merchant, 'DREAMPLUG PAYTECH S');
    });

    test('SBI UPI "trf to MR CHAKALI SAIL" extracts the payee', () {
      final r = classify(
          'Dear UPI user A/C X3148 debited by 25.00 on date 15Jul26 trf to '
          'MR CHAKALI SAIL Refno 153398891393 If not u? call-1800111109',
          sender: 'VM-SBIUPI-S');
      expect(r.parsed!.merchant, isNotNull);
      expect(r.parsed!.merchant!.toUpperCase(), contains('CHAKALI'));
    });

    test('"for Rs. 3,000" never yields "Rs" as the merchant', () {
      final r = classify(
          'Hola! that was sweet. We have received payment against your '
          'OneCard for Rs. 3,000.00 on 16 Jul 2026.',
          sender: 'JK-BOBONE-S');
      expect(r.status, ParseStatus.parsed);
      expect(r.parsed!.merchant, isNot('Rs'));
    });

    test('reward-points PROMO without money movement is still filtered', () {
      final r = classify(
          'Earn 5X reward points on every dining spend this weekend with your '
          'BOBCARD. T&C apply.',
          sender: 'AD-BOBONE-S');
      expect(r.isParsed, isFalse);
    });

    test('min-due reminder mentioning "paid" is still filtered', () {
      final r = classify(
          'Pay your HDFC Bank Credit Card X4335 Minimum Due of Rs.22002.91 in '
          'just a click: hdfcbk.io/x Please ignore if already paid',
          sender: 'AD-HDFCBK-S');
      expect(r.isParsed, isFalse);
      expect(r.needsAttention, isFalse);
    });

    test('e-mandate "will be debited by Rs.999" stays filtered', () {
      final r = classify(
          'Your a/c will be debited by Rs.999 for Netflix e-mandate on 20-07.',
          sender: 'AD-HDFCBK-S');
      expect(r.isParsed, isFalse);
    });
  });

  group('Amount pattern library — formats without a currency prefix', () {
    test('"debited by 1200.0" (SBI style, no Rs) parses', () {
      final r = classify(
          'A/c XX9876 debited by 1200.0 on 16Jul26 trf to RAMESH Refno 512345678901',
          sender: 'SBIN');
      expect(r.status, ParseStatus.parsed);
      expect(r.parsed!.amount, 1200.0);
      expect(r.parsed!.transactionType, 'debit');
    });

    test('"credited with 500" parses as credit', () {
      final r = classify(
          'A/c XX9876 credited with 500 on 16-07-26. Avl Bal Rs.2,300',
          sender: 'CANBNK');
      expect(r.status, ParseStatus.parsed);
      expect(r.parsed!.amount, 500);
      expect(r.parsed!.transactionType, 'credit');
    });

    test('"1,200.00 debited from A/c" (amount-first) parses', () {
      final r = classify(
          '1,200.00 debited from A/c XX1234 via IMPS Ref 987654321',
          sender: 'ICICIB');
      expect(r.status, ParseStatus.parsed);
      expect(r.parsed!.amount, 1200.0);
    });

    test('"INR 349 spent via UPI" still parses (currency form)', () {
      final r = classify(
          'INR 349 spent via UPI on 16-07 at ZOMATO. Ref 123456789.',
          sender: 'AXISBK');
      expect(r.status, ParseStatus.parsed);
      expect(r.parsed!.amount, 349);
    });

    test('the balance figure is never mistaken for the amount', () {
      final r = classify(
          'A/c XX1234 debited by 250.0 on 16Jul. Avl Bal Rs.18,540.55. Ref 445566778',
          sender: 'SBIN');
      expect(r.status, ParseStatus.parsed);
      expect(r.parsed!.amount, 250.0);
      expect(r.parsed!.balance, 18540.55);
    });
  });
}
