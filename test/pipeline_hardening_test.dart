import 'package:ai_finance_assistant/models/categories.dart';
import 'package:ai_finance_assistant/models/parsed_sms.dart';
import 'package:ai_finance_assistant/services/categorizer_service.dart';
import 'package:ai_finance_assistant/services/database_service.dart';
import 'package:ai_finance_assistant/services/duplicate_detector.dart';
import 'package:ai_finance_assistant/services/parser_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = ParserService();
  const detector = DuplicateDetector();
  final now = DateTime(2026, 7, 3, 19, 30);

  ParsedSms parse(String body, {String sender = 'AD-HDFCBK'}) {
    final p = parser.parse(body: body, receivedAt: now, sender: sender);
    expect(p, isNotNull, reason: 'Expected a parse for: $body');
    return p!;
  }

  group('Transaction status detection', () {
    test('a failed UPI debit is parsed but marked failed', () {
      final p = parse(
          'UPI txn of Rs.500.00 to merchant@ybl from A/c XX1234 failed. '
          'Ref 411223344556. Any amount debited will be reversed.');
      expect(p.status, 'failed');
      expect(p.isPosted, isFalse);
    });

    test('declined and timed-out attempts are marked failed', () {
      expect(
        parse('Txn of Rs.1,200 on Card 4335 at AMAZON declined. Ref 991122334455')
            .status,
        'failed',
      );
      expect(
        parse('Payment of Rs.350 via UPI 322110045678 from A/c XX1234 timed out')
            .status,
        'failed',
      );
    });

    test('a reversed debit is parsed but marked reversed', () {
      final p = parse(
          'Rs.750 debited from A/c XX1234 has been reversed. Ref 566778899001');
      expect(p.transactionType, 'debit');
      expect(p.status, 'reversed');
    });

    test('a standalone reversal credit stays a posted refund credit', () {
      final p = parse('Rs.120.00 reversed to your A/c XX1234. Ref 606060606060');
      expect(p.transactionType, 'credit');
      expect(p.status, 'posted');
      const categorizer = CategorizerService();
      expect(categorizer.categorize(p, 'Unknown').category, AppCategory.refund);
    });

    test('an ordinary debit stays posted', () {
      final p = parse('Rs.291 spent at upiswiggy@icici via UPI 115772496384. '
          'Avbl Bal Rs.1,000');
      expect(p.status, 'posted');
    });
  });

  group('Reference number extraction', () {
    test('extracts UPI / Ref / UTR numbers', () {
      expect(
        parse('Sent Rs.30.00 From HDFC Bank A/C *8820 To GOUNI RAJU '
                'On 03/07/26 Ref 454206294240')
            .referenceNo,
        '454206294240',
      );
      expect(
        parse('Rs.291 spent at upiswiggy@icici by UPI 115772496384 from A/c XX4335')
            .referenceNo,
        '115772496384',
      );
    });

    test('no reference number -> null', () {
      final p = parse('Rs.120 spent at CAFE COFFEE from A/c XX1234. '
          'Avbl Bal Rs.9,999');
      expect(p.referenceNo, isNull);
    });
  });

  group('Review flag (never silently guess)', () {
    const categorizer = CategorizerService();

    test('low-confidence P2P transfer needs review', () {
      final p = parse('Sent Rs.500 to RAHUL KUMAR via UPI 123456789012 '
          'From A/c XX1234');
      final r = categorizer.categorize(p, 'Rahul Kumar');
      expect(r.confidence, lessThan(CategoryResult.reviewThreshold));
      expect(r.needsReview, isTrue);
    });

    test('a confident brand match does not need review', () {
      final p = parse('Rs.291 spent at upiswiggy@icici via UPI 115772496384. '
          'Bal Rs.100');
      final r = categorizer.categorize(p, 'Swiggy');
      expect(r.needsReview, isFalse);
    });

    test('a user-taught mapping never needs review', () {
      final p = parse('Sent Rs.500 to RAHUL KUMAR via UPI 123456789012 '
          'From A/c XX1234');
      final r = categorizer
          .categorize(p, 'Rahul Kumar', memory: {'Rahul Kumar': AppCategory.transfer});
      expect(r.source, 'user');
      expect(r.needsReview, isFalse);
    });
  });

  group('DuplicateDetector (cross-provider)', () {
    Transaction stored({
      required String smsId,
      required double amount,
      String type = 'debit',
      String? referenceNo,
      String? accountLast4,
      DateTime? date,
    }) =>
        Transaction(
          id: smsId.hashCode,
          amount: amount,
          merchant: 'X',
          category: AppCategory.others,
          isSubscription: false,
          transactionType: type,
          date: date ?? now,
          smsBody: 'x',
          smsId: smsId,
          status: 'posted',
          needsReview: false,
          referenceNo: referenceNo,
          accountLast4: accountLast4,
        );

    ParsedSms candidate({
      required double amount,
      String type = 'debit',
      String? referenceNo,
      String? accountLast4,
      DateTime? date,
    }) =>
        ParsedSms(
          amount: amount,
          transactionType: type,
          date: date ?? now,
          smsBody: 'y',
          smsId: 'sms_new',
          referenceNo: referenceNo,
          accountLast4: accountLast4,
        );

    test('same reference number -> duplicate', () {
      final dup = detector.isDuplicate(
        candidate(amount: 500, referenceNo: '454206294240'),
        [stored(smsId: 'sms_a', amount: 500, referenceNo: '454206294240')],
      );
      expect(dup, isTrue);
    });

    test('different reference numbers -> NOT duplicate even if close in time',
        () {
      final dup = detector.isDuplicate(
        candidate(amount: 500, referenceNo: '111111111111'),
        [stored(smsId: 'sms_a', amount: 500, referenceNo: '222222222222')],
      );
      expect(dup, isFalse);
    });

    test('same amount + account within window (no refs) -> duplicate', () {
      final dup = detector.isDuplicate(
        candidate(amount: 500, accountLast4: '1234'),
        [
          stored(
              smsId: 'sms_a',
              amount: 500,
              accountLast4: '1234',
              date: now.add(const Duration(minutes: 1))),
        ],
      );
      expect(dup, isTrue);
    });

    test('same amount but outside the window -> NOT duplicate', () {
      final dup = detector.isDuplicate(
        candidate(amount: 500, accountLast4: '1234'),
        [
          stored(
              smsId: 'sms_a',
              amount: 500,
              accountLast4: '1234',
              date: now.add(const Duration(minutes: 10))),
        ],
      );
      expect(dup, isFalse);
    });

    test('no corroborating account or reference -> NOT duplicate', () {
      final dup = detector.isDuplicate(
        candidate(amount: 500),
        [stored(smsId: 'sms_a', amount: 500)],
      );
      expect(dup, isFalse);
    });

    test('different direction or amount -> NOT duplicate', () {
      expect(
        detector.isDuplicate(
          candidate(amount: 500, accountLast4: '1234'),
          [
            stored(
                smsId: 'sms_a',
                amount: 500,
                type: 'credit',
                accountLast4: '1234'),
          ],
        ),
        isFalse,
      );
      expect(
        detector.isDuplicate(
          candidate(amount: 500, accountLast4: '1234'),
          [stored(smsId: 'sms_a', amount: 501, accountLast4: '1234')],
        ),
        isFalse,
      );
    });

    test('the same SMS row (re-scan) is ignored, not flagged', () {
      final c = candidate(amount: 500, referenceNo: '454206294240');
      final own = Transaction(
        id: 1,
        amount: 500,
        merchant: 'X',
        category: AppCategory.others,
        isSubscription: false,
        transactionType: 'debit',
        date: now,
        smsBody: 'y',
        smsId: 'sms_new', // same id as the candidate
        status: 'posted',
        needsReview: false,
        referenceNo: '454206294240',
      );
      expect(detector.isDuplicate(c, [own]), isFalse);
    });
  });
}
