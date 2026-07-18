import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/parsed_sms.dart';

/// Why a message could not be turned into a transaction (or that it was).
enum ParseStatus {
  /// Successfully parsed — [ParseResult.parsed] is non-null.
  parsed,

  /// Sender isn't a bank/payment service — not our concern.
  ignoredSender,

  /// A real bank message, but not money movement (OTP, promo, bill reminder).
  ignoredNonTxn,

  /// Looks transactional but no debit/credit direction could be determined.
  needsType,

  /// Looks transactional but no amount could be extracted.
  needsAmount,

  /// Looks transactional but lacks corroborating structure (a/c, ref, rail).
  needsStructure,

  /// The body parses as a clean transaction but the sender isn't a known
  /// bank header — likely a bank we haven't listed yet. Surfaced for review
  /// so a new sender template never silently loses transactions.
  unknownSender,
}

/// The full outcome of classifying one SMS: either a [parsed] transaction, or a
/// reason it wasn't. Lets the pipeline record *every* message instead of
/// silently dropping the ones the regex can't handle.
class ParseResult {
  final ParsedSms? parsed;
  final ParseStatus status;
  const ParseResult._(this.status, [this.parsed]);

  factory ParseResult.ok(ParsedSms p) => ParseResult._(ParseStatus.parsed, p);
  factory ParseResult.fail(ParseStatus s) => ParseResult._(s);

  bool get isParsed => parsed != null;

  /// A message we couldn't confidently log but that looks like it should have
  /// been a transaction — these must be surfaced for review, never dropped.
  bool get needsAttention =>
      status == ParseStatus.needsType ||
      status == ParseStatus.needsAmount ||
      status == ParseStatus.needsStructure ||
      status == ParseStatus.unknownSender;
}

/// Parses raw bank SMS text into a [ParsedSms].
///
/// The parser is intentionally conservative: if a message does not look like a
/// real debit/credit transaction [parse] returns `null`. Use [classify] instead
/// when you need to know *why* (to route unparseable-but-financial messages to a
/// review queue rather than losing them).
class ParserService {
  const ParserService();

  // Words that indicate money left the account. "txn" covers HDFC-style card
  // debits ("Txn Rs.X On ... Card ... At <merchant>") that carry no other verb.
  static final _debitWords = RegExp(
    r'\b(debit(?:ed)?|spent|paid|withdrawn|purchase(?:d)?|sent|deducted|'
    r'transferred|txn|dr)\b',
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
  // payment *reminders* (EMI / credit-card bill / loan dues) which come from real
  // bank senders but describe money that has NOT moved yet. A credit-card bill
  // reminder contains the word "credit", so without this it would be miscounted
  // as income.
  static final _nonTransaction = RegExp(
    r'(\botp\b|one\s*time\s*password|will\s*expire|do\s*not\s*share|'
    r'requested|request\s*for|e-?mandate|reward\s*points?|\boffer\b|cashback\s*of|'
    // NOTE: don't blanket-filter "emi" — a real "EMI ... deducted" is a
    // transaction. Reminders are still caught by the "due"/"pay" phrases below.
    r'ignore\s+if\s+(?:already\s+)?paid|\breminder\b|'
    r'will\s+be\s+(?:debited|deducted|auto)|'
    // --- Payment / bill / EMI due reminders ---
    r'\b(?:amount|amt|min(?:imum)?|total|tot|outstanding|payment)\s+due\b|'
    r'\bdue\s+(?:date|on|by|amount|amt)\b|'
    r'\bpay\s+(?:now|before|immediately|your)\b|'
    r'\b(?:please|kindly)\s+(?:pay|clear)\b|'
    r'avoid\s+(?:late|penalty|overdue)|'
    r'statement\s+(?:has\s+been\s+)?(?:generated|is\s+ready)|'
    r'\bpay\b[^.]{0,40}\bby\s+\d)',
    caseSensitive: false,
  );

  // SMS headers (DLT sender IDs) that belong to banks / payment services.
  // Matched as substrings of the uppercased sender, e.g. "AD-HDFCBK-S".
  // Keep tokens ≥3 chars to avoid false positives on promo headers.
  static const _financialSenderTokens = [
    'HDFC', 'SBI', 'ICIC', 'AXIS', 'KOTAK', 'PNB', 'BOB', 'BOI', 'CANBNK',
    'CANARA', 'UNION', 'IDFC', 'YES', 'INDUS', 'INDB', 'CENTBK', 'UCO', 'IOB',
    'FEDBNK', 'FEDERAL', 'RBL', 'AUBANK', 'BANDHAN', 'IDBI', 'CITI', 'HSBC',
    'SCB', 'DBS', 'AMEX', 'PAYTM', 'PHONPE', 'GPAY', 'AMZN', 'BHIM', 'UPI',
    'JUPITER', 'SLICE', 'CRED', 'BANK', 'BNK', 'CARD', 'CRD', 'NPCI',
    // Additional banks / RRBs / small finance & payments banks.
    'BARODA', 'MAHABK', 'MAHB', 'KARUR', 'KVB', 'TMBL', 'TMBNK', 'DCBBNK',
    'EQUITAS', 'UJJIVN', 'UJJIVAN', 'JANABK', 'FINCARE', 'IPPB', 'AIRBNK',
    'NSDLPB', 'SARASWAT', 'COSMOS', 'SVCBNK', 'APGVB', 'TSGB', 'KGBBNK',
    // Payment / credit apps that send real transaction alerts.
    'NAVI', 'LAZYPAY', 'SIMPL', 'MOBIKW', 'FREECH', 'ONECRD', 'ONECARD',
    'FAMPAY', 'FIMONY', 'RZPAY', 'RAZORP', 'BAJAJF', 'BAJFIN', 'TATACAP',
    'WHTSAP', 'APAY',
  ];

  // Positive override for the non-transaction filter: a money verb followed
  // closely by a currency amount ("paid Rs. 5,175.00 at X") is real movement
  // even when the message ALSO mentions promo-ish words. BOBCARD, for one,
  // appends "and earned reward points!" to every genuine spend alert — without
  // this override those debits are misfiled as promos and lost. Reminders stay
  // filtered because their verb never directly precedes the amount ("Minimum
  // Due of Rs.X ... please pay").
  static final _strongTxn = RegExp(
    r'\b(?:spent|paid|debited|credited|withdrawn|deducted|sent|received)\b'
    r'[^.\n]{0,30}?(?:rs|inr|₹)\.?\s*:?\s*[\d,]+',
    caseSensitive: false,
  );

  // The override must never rescue future/reminder phrasing ("will be
  // debited", "minimum due", "ignore if already paid", statements).
  static final _reminderish = RegExp(
    r'\bwill\s+be\b|\bshall\s+be\b|\bdue\b|ignore\s+if|statement',
    caseSensitive: false,
  );

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

  // ---- Amount pattern library ----------------------------------------------
  // Ordered, most-precise first. Banks constantly change templates; a missed
  // amount silently downgrades a transaction to the review queue, so each
  // observed format gets its own entry rather than one brittle mega-regex.

  // 1. Currency-prefixed: "Rs.1,250.00", "INR 1250", "₹ 1,250", "Rs:500".
  static final _money = RegExp(
    r'(?:rs|inr|₹)\.?\s*:?\s*([\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  // 2. Verb-then-amount without a currency marker: "debited by 1200.0",
  //    "credited with 500", "debited for 349" (SBI/Canara/RRB style).
  static final _amountAfterVerb = RegExp(
    r'\b(?:debited|credited|deducted|withdrawn|deposited|spent|paid|sent|'
    r'received|transferred)\s*(?:by|with|for|of)?\s*[:\-]?\s*'
    r'(?:rs|inr|₹)?\.?\s*([\d,]+(?:\.\d{1,2})?)\b',
    caseSensitive: false,
  );

  // 3. Amount-then-verb: "1,200.00 debited from A/c", "500 is credited".
  static final _amountBeforeVerb = RegExp(
    r'\b([\d,]+(?:\.\d{1,2})?)\s*(?:is|was|has been)?\s*'
    r'(?:debited|credited|deducted|withdrawn|deposited)\b',
    caseSensitive: false,
  );

  /// Tried in order; first pattern that yields a valid figure wins.
  static final List<RegExp> _amountPatterns = [
    _money,
    _amountAfterVerb,
    _amountBeforeVerb,
  ];

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

  /// Backwards-compatible: returns the parsed transaction or null. Prefer
  /// [classify] when you need the failure reason.
  ParsedSms? parse({
    required String body,
    required DateTime receivedAt,
    String? sender,
    String? providerId,
  }) {
    return classify(
      body: body,
      receivedAt: receivedAt,
      sender: sender,
      providerId: providerId,
    ).parsed;
  }

  /// Full classification of one SMS — a transaction, or the reason it isn't.
  ParseResult classify({
    required String body,
    required DateTime receivedAt,
    String? sender,
    String? providerId,
  }) {
    if (body.trim().isEmpty) {
      return ParseResult.fail(ParseStatus.ignoredNonTxn);
    }
    final text = body.replaceAll('\n', ' ');

    // Sender gate: unknown senders are not trusted for auto-logging, but if the
    // body parses like a clean transaction it goes to the review queue instead
    // of being dropped — new bank headers must never lose transactions.
    final senderKnown = _looksFinancialSender(sender);

    // The promo/reminder filter is skipped when the body carries an
    // unmistakable money-movement clause (verb + amount) — see [_strongTxn] —
    // and no future/reminder phrasing.
    final strongOverride =
        _strongTxn.hasMatch(text) && !_reminderish.hasMatch(text);
    if (!strongOverride && _nonTransaction.hasMatch(text)) {
      return ParseResult.fail(senderKnown
          ? ParseStatus.ignoredNonTxn
          : ParseStatus.ignoredSender);
    }

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
    if (type == null) {
      return ParseResult.fail(
          senderKnown ? ParseStatus.needsType : ParseStatus.ignoredSender);
    }

    final balance = _extractBalance(text);
    final amount = _extractAmount(text, balanceValue: balance);
    if (amount == null || amount <= 0) {
      return ParseResult.fail(
          senderKnown ? ParseStatus.needsAmount : ParseStatus.ignoredSender);
    }

    final accountLast4 = _firstGroup(_accountTail, text);
    final paymentMethod = _detectPaymentMethod(text);

    // A real transaction references an account, a balance, a payment rail, or a
    // transaction reference number. Reminders/promos usually reference none of
    // these — this is the last line of defence against false positives.
    final hasStructure = accountLast4 != null ||
        balance != null ||
        paymentMethod != null ||
        _txnRef.hasMatch(text);
    if (!hasStructure) {
      return ParseResult.fail(senderKnown
          ? ParseStatus.needsStructure
          : ParseStatus.ignoredSender);
    }

    // Fully transaction-shaped but from an unrecognised sender: queue it for
    // the user instead of auto-logging (or worse, dropping) it.
    if (!senderKnown) return ParseResult.fail(ParseStatus.unknownSender);

    return ParseResult.ok(ParsedSms(
      amount: amount,
      transactionType: type,
      date: receivedAt,
      smsBody: body,
      smsId: dedupId(body: body, receivedAt: receivedAt, providerId: providerId),
      merchant: _extractMerchant(text),
      accountLast4: accountLast4,
      balance: balance,
      paymentMethod: paymentMethod,
      referenceNo: _firstGroup(_txnRef, text),
      status: _detectStatus(text, type),
    ));
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

  // "credit card", "credit limit", "credit line" are card nouns — not incoming
  // money. Neutralise them so only a standalone "credit(ed)" signals income.
  static final _creditNoun = RegExp(
    r'credit\s*(?:card|limit|line|cards)',
    caseSensitive: false,
  );

  String? _detectType(String text) {
    final cleaned = text.replaceAll(_creditNoun, ' ');
    final isDebit = _debitWords.hasMatch(cleaned);
    final isCredit = _creditWords.hasMatch(cleaned);
    if (isDebit && !isCredit) return 'debit';
    if (isCredit && !isDebit) return 'credit';
    if (isDebit && isCredit) {
      // Both appear (e.g. "debited ... credited to beneficiary"). Fall back to
      // whichever keyword comes first in the message.
      final d = _debitWords.firstMatch(cleaned)!.start;
      final c = _creditWords.firstMatch(cleaned)!.start;
      return d <= c ? 'debit' : 'credit';
    }
    return null;
  }

  double? _extractBalance(String text) {
    final m = _balance.firstMatch(text);
    if (m == null) return null;
    return _toDouble(m.group(1));
  }

  /// The transaction amount is the first figure (per the pattern library, in
  /// priority order) that is *not* part of the balance clause.
  double? _extractAmount(String text, {double? balanceValue}) {
    final balanceMatch = _balance.firstMatch(text);
    for (final pattern in _amountPatterns) {
      for (final m in pattern.allMatches(text)) {
        // Skip the figure that belongs to the balance clause.
        if (balanceMatch != null &&
            m.start < balanceMatch.end &&
            m.end > balanceMatch.start) {
          continue;
        }
        final value = _toDouble(m.group(1));
        if (value != null && value > 0) return value;
      }
    }
    return null;
  }

  String? _extractMerchant(String text) {
    // 1. Prefer an explicit "at / to / for / @ <name>" clause. The boundary set
    // must cover each template's connector word ("with your … Card", "and
    // earned…") or the lazy match runs past 40 chars and the clause is lost.
    final atMatch = RegExp(
      r'(?:\b(?:at|to|towards|for|trf\s+to|via\s+upi\s+to)\s+|@\s*)'
      r"([A-Za-z0-9][A-Za-z0-9&'@.\- ]{1,40}?)"
      r'(?=\s+(?:on|via|by|ref|refno|txn|upi|avl|avbl|bal|dated|info|a/?c|'
      r'using|not|call|with|and|is|was|linked)\b|[.,;*]|$)',
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
    // Currency tokens that leak in when the clause is "for Rs. 3,000".
    'rs', 'inr', 'rupees',
    // Template fragments that are never merchants.
    'dispute this', 'dispute this payment', 'suspicious high risk',
    'this payment',
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
  /// Public so the unparsed-message queue can share the same identity scheme.
  String dedupId({
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
