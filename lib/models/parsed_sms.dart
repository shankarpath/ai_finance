/// The structured result of parsing a single bank SMS.
///
/// This is a plain value object produced by [ParserService]. It is deliberately
/// decoupled from the database layer so the parser can be unit-tested without
/// any Flutter/Drift dependencies.
class ParsedSms {
  final double amount;

  /// Either `'debit'` or `'credit'`.
  final String transactionType;

  final String? merchant;

  /// Last 4 digits of the account/card, if the SMS exposed them.
  final String? accountLast4;

  /// Available balance after the transaction, if present.
  final double? balance;

  /// e.g. UPI, IMPS, NEFT, CARD, ATM. Null if undetermined.
  final String? paymentMethod;

  /// UPI/IMPS/NEFT/UTR reference number, if the SMS exposed one. Used for
  /// cross-provider duplicate detection (bank + UPI app alerting on the same
  /// payment carry the same reference).
  final String? referenceNo;

  /// 'posted' for money that actually moved; 'failed' for declined/failed/
  /// timed-out attempts; 'reversed' when a debit was rolled back. Non-posted
  /// transactions are stored for the audit trail but excluded from analytics.
  final String status;

  /// When the transaction happened. Defaults to the SMS received time.
  final DateTime date;

  /// The raw SMS body, retained for auditing / re-parsing.
  final String smsBody;

  /// A stable id used to de-duplicate the same SMS across re-scans.
  final String smsId;

  const ParsedSms({
    required this.amount,
    required this.transactionType,
    required this.date,
    required this.smsBody,
    required this.smsId,
    this.merchant,
    this.accountLast4,
    this.balance,
    this.paymentMethod,
    this.referenceNo,
    this.status = 'posted',
  });

  bool get isDebit => transactionType == 'debit';
  bool get isCredit => transactionType == 'credit';
  bool get isPosted => status == 'posted';

  @override
  String toString() =>
      'ParsedSms(amount: $amount, type: $transactionType, merchant: $merchant, '
      'acct: $accountLast4, balance: $balance, method: $paymentMethod, '
      'ref: $referenceNo, status: $status)';
}
