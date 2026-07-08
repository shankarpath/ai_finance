import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/parsed_sms.dart';

/// Parses raw bank SMS text into a [ParsedSms].
///
/// The parser is intentionally conservative: if a message does not look like a
/// real debit/credit transaction it returns `null` so that OTPs, promotional
/// messages, and balance-enquiry replies are ignored.
class ParserService {
  const ParserService();

  // Words that indicate money left the account. "txn" covers HDFC-style card
  // debits ("Txn Rs.X On ... Card ... At <merchant>") that carry no other verb.
  static final _debitWords = RegExp(
    r'\b(debit(?:ed)?|spent|paid|withdrawn|purchase(?:d)?|sent|deducted|txn|dr)\b',
    caseSensitive: false,
  );

  // Words that indicate money came in. "reversed" covers standalone reversal
  // credits ("Rs.120 reversed to your A/c"); a "debited ... reversed" message
  // still resolves to debit because the debit word comes first.
  static final _creditWords = RegExp(
    r'\b(credit(?:ed)?|received|deposited|refund(?:ed)?|added|reversed|cr)\b',
    caseSensitive: false,
  );

  // Messages we should never treat as transactions: OTPs, promos, and — crucially —
  // payment *reminders* (EMI/bill dues) which come from real bank senders but
  // describe money that has NOT moved yet.
  static final _nonTransaction = RegExp(
    r'(\botp\b|one\s*time\s*password|will\s*expire|do\s*not\s*share|'
    r'requested|request\s*for|e-?mandate|reward\s*points?|\boffer\b|cashback\s*of|'
    // NOTE: don't blanket-filter "emi" — a real "EMI ... deducted" is a
    // transaction. Reminders are still caught by the phrases below.
    r'ignore\s+if\s+(?:already\s+)?paid|\breminder\b|'
    r'will\s+be\s+(?:debited|deducted|auto)|'
    r'\bpay\b[^.]{0,40}\bby\s+\d)',
    caseSensitive: false,
  );

  // SMS headers (DLT sender IDs) that belong to banks / payment services.
  // Matched as substrings of the uppercased sender, e.g. "AD-HDFCBK-S".
  static const _financialSenderTokens = [
    'HDFC', 'SBI', 'ICIC', 'AXIS', 'KOTAK', 'PNB', 'BOB', 'BOI', 'CANBNK',
    'CANARA', 'UNION', 'IDFC', 'YES', 'INDUS', 'INDB', 'CENTBK', 'UCO', 'IOB',
    'FEDBNK', 'FEDERAL', 'RBL', 'AUBANK', 'BANDHAN', 'IDBI', 'CITI', 'HSBC',
    'SCB', 'DBS', 'AMEX', 'PAYTM', 'PHONPE', 'GPAY', 'AMZN', 'BHIM', 'UPI',
    'JUPITER', 'SLICE', 'CRED', 'BANK', 'BNK', 'CARD', 'CRD', 'NPCI',
  ];

  // A transaction that was attempted but never completed. These SMS come from
  // real bank senders and otherwise look exactly like debits, so without this
  // check a failed payment would be counted as spending.
  static final _failedWords = RegExp(
    r'\b(failed|failure|declined|unsuccessful|rejected|cancelled|'
    r'could\s+not\s+be\s+(?:processed|completed)|'
    r'not\s+(?:be\s+)?(?:processed|completed)|timed?\s*.?out)\b',
    caseSensitive: false,
  );

  // A debit that was rolled back ("...has been reversed"). The money is back,
  // so the message must not count as fresh spending.
  static final _reversalWords = RegExp(
    r'\brevers(?:ed|al)\b',
    caseSensitive: false,
  );

  // A currency amount such as "Rs.1,250.00", "INR 1250", "₹ 1,250".
  static final _money = RegExp(
    r'(?:rs|inr|₹)\.?\s*([\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  // Balance clause, e.g. "Avbl Bal Rs.23,560", "Available balance: INR 23560".
  static final _balance = RegExp(
    r'(?:avbl|avl|available|closing|a/c|remaining)?\s*'
    r'bal(?:ance)?\.?\s*[:\-]?\s*(?:is)?\s*(?:rs|inr|₹)\.?\s*([\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  // Account / card tail: "A/c XX1234", "Card ending 1234", "ac no XXXX5678".
  static final _accountTail = RegExp(
    r'(?:a/?c|acct?|account|card)\s*(?:no\.?|number|ending(?:\s*in)?|xx+|\*+)?\s*'
    r'[xX*]*(\d{4})\b',
    caseSensitive: false,
  );

  // UPI VPA handle, e.g. "swiggy@ybl".
  static final _vpa = RegExp(
    r'\b([a-z0-9][a-z0-9._-]{1,})@[a-z]{2,}\b',
    caseSensitive: false,
  );

  ParsedSms? parse({
    required String body,
    required DateTime receivedAt,
    String? sender,
    String? providerId,
  }) {
    if (body.trim().isEmpty) return null;
    final text = body.replaceAll('\n', ' ');

    // Only trust messages from a bank / payment sender (when the sender is known).
    if (!_looksFinancialSender(sender)) return null;

    if (_nonTransaction.hasMatch(text)) return null;

    var type = _detectType(text);
    // Failed-payment alerts often carry no debit/credit verb at all
    // ("Payment of Rs.350 ... timed out"). An outgoing word plus a failure
    // word is still a (failed) debit attempt worth recording.
    if (type == null &&
        _failedWords.hasMatch(text) &&
        RegExp(r'\b(payment|transaction|transfer)\b', caseSensitive: false)
            .hasMatch(text)) {
      type = 'debit';
    }
    if (type == null) return null;

    final balance = _extractBalance(text);
    final amount = _extractAmount(text, balanceValue: balance);
    if (amount == null || amount <= 0) return null;

    final accountLast4 = _firstGroup(_accountTail, text);
    final paymentMethod = _detectPaymentMethod(text);

    // A real transaction references an account, a balance, a payment rail, or a
    // transaction reference number. Reminders/promos usually reference none of
    // these — this is the last line of defence against false positives.
    final hasStructure = accountLast4 != null ||
        balance != null ||
        paymentMethod != null ||
        _txnRef.hasMatch(text);
    if (!hasStructure) return null;

    return ParsedSms(
      amount: amount,
      transactionType: type,
      date: receivedAt,
      smsBody: body,
      smsId: _dedupId(body: body, receivedAt: receivedAt, providerId: providerId),
      merchant: _extractMerchant(text),
      accountLast4: accountLast4,
      balance: balance,
      paymentMethod: paymentMethod,
      referenceNo: _firstGroup(_txnRef, text),
      status: _detectStatus(text, type),
    );
  }

  /// 'failed' when the payment never went through; 'reversed' when a *debit*
  /// was rolled back (a reversal message about a credit IS the refund credit,
  /// which stays 'posted'); otherwise 'posted'.
  String _detectStatus(String text, String type) {
    if (_failedWords.hasMatch(text)) return 'failed';
    if (type == 'debit' && _reversalWords.hasMatch(text)) return 'reversed';
    return 'posted';
  }

  /// A UPI/IMPS/NEFT/reference number (6+ digits after a rail keyword).
  static final _txnRef = RegExp(
    r'\b(?:upi|imps|neft|rtgs|ref|txn|utr)\b[^\d]{0,6}(\d{6,})',
    caseSensitive: false,
  );

  bool _looksFinancialSender(String? sender) {
    if (sender == null || sender.trim().isEmpty) return true; // permissive
    final s = sender.toUpperCase();
    // Pure 10-digit personal numbers are never transactional bank alerts.
    return _financialSenderTokens.any(s.contains);
  }

  String? _detectType(String text) {
    final isDebit = _debitWords.hasMatch(text);
    final isCredit = _creditWords.hasMatch(text);
    if (isDebit && !isCredit) return 'debit';
    if (isCredit && !isDebit) return 'credit';
    if (isDebit && isCredit) {
      // Both appear (e.g. "debited ... credited to beneficiary"). Fall back to
      // whichever keyword comes first in the message.
      final d = _debitWords.firstMatch(text)!.start;
      final c = _creditWords.firstMatch(text)!.start;
      return d <= c ? 'debit' : 'credit';
    }
    return null;
  }

  double? _extractBalance(String text) {
    final m = _balance.firstMatch(text);
    if (m == null) return null;
    return _toDouble(m.group(1));
  }

  /// The transaction amount is the first currency figure that is *not* the
  /// balance clause.
  double? _extractAmount(String text, {double? balanceValue}) {
    final balanceMatch = _balance.firstMatch(text);
    for (final m in _money.allMatches(text)) {
      // Skip the figure that belongs to the balance clause.
      if (balanceMatch != null &&
          m.start >= balanceMatch.start &&
          m.end <= balanceMatch.end) {
        continue;
      }
      final value = _toDouble(m.group(1));
      if (value != null && value > 0) return value;
    }
    return null;
  }

  String? _extractMerchant(String text) {
    // 1. Prefer an explicit "at / to / for <name>" clause.
    final atMatch = RegExp(
      r'\b(?:at|to|towards|for|via\s+upi\s+to)\s+'
      r"([A-Za-z0-9][A-Za-z0-9&'@.\- ]{1,40}?)"
      r'(?=\s+(?:on|via|by|ref|txn|upi|avl|avbl|bal|dated|info|a/?c|using|not|call)\b|[.,;*]|$)',
      caseSensitive: false,
    ).firstMatch(text);
    if (atMatch != null) {
      final cleaned = _cleanMerchant(atMatch.group(1)!);
      if (cleaned != null) return cleaned;
    }

    // 2. Fall back to a UPI VPA handle (swiggy@ybl -> swiggy).
    final vpa = _vpa.firstMatch(text);
    if (vpa != null) {
      final handle = vpa.group(1)!;
      final cleaned = _cleanMerchant(handle);
      if (cleaned != null) return cleaned;
    }

    return null;
  }

  /// Generic payment-rail / app words that are never a real merchant name.
  static const _merchantStopwords = {
    'pay', 'gpay', 'google pay', 'googlepay', 'phonepe', 'phone pe', 'paytm',
    'upi', 'imps', 'neft', 'rtgs', 'a/c', 'ac', 'account', 'you', 'your',
    'self', 'vpa', 'bank',
  };

  String? _cleanMerchant(String raw) {
    var s = raw.trim();
    // Drop trailing reference/transaction noise if the boundary slipped.
    s = s.replaceAll(RegExp(r'\s{2,}'), ' ');
    s = s.replaceAll(RegExp(r'[*_]+'), ' ').trim();
    if (s.isEmpty) return null;
    // Reject values that are purely numeric (likely a ref number, not a name).
    if (RegExp(r'^\d+$').hasMatch(s)) return null;
    // Reject generic payment-app / rail words that aren't real merchants.
    if (_merchantStopwords.contains(s.toLowerCase())) return null;
    // Reject the bank's own name ("HDFC Bank", "SBI") — on a credit "to HDFC
    // Bank A/c ..." the real counterparty is the sender VPA, not the bank.
    if (RegExp(r'\bbank\b', caseSensitive: false).hasMatch(s)) return null;
    return s;
  }

  String? _detectPaymentMethod(String text) {
    final t = text.toLowerCase();
    if (t.contains('upi') || _vpa.hasMatch(text)) return 'UPI';
    if (t.contains('imps')) return 'IMPS';
    if (t.contains('neft')) return 'NEFT';
    if (t.contains('rtgs')) return 'RTGS';
    if (t.contains('atm')) return 'ATM';
    if (t.contains('pos') || t.contains('card')) return 'CARD';
    if (t.contains('netbanking') || t.contains('net banking')) return 'NETBANKING';
    return null;
  }

  String? _firstGroup(RegExp re, String text) => re.firstMatch(text)?.group(1);

  double? _toDouble(String? raw) {
    if (raw == null) return null;
    return double.tryParse(raw.replaceAll(',', ''));
  }

  /// Deterministic id so re-scanning the inbox never inserts duplicates.
  String _dedupId({
    required String body,
    required DateTime receivedAt,
    String? providerId,
  }) {
    if (providerId != null && providerId.isNotEmpty) return 'sms_$providerId';
    final digest = sha1.convert(
      utf8.encode('${receivedAt.millisecondsSinceEpoch}|$body'),
    );
    return 'hash_$digest';
  }
}
