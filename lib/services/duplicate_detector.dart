import '../models/parsed_sms.dart';
import 'database_service.dart';

/// Decides whether a newly parsed SMS describes a payment that is already
/// stored — the cross-provider case where the bank and a UPI app (or two DLT
/// headers of the same bank) both announce one transaction, so the per-SMS
/// [ParsedSms.smsId] can never catch it.
///
/// Pure and deterministic: the database only supplies candidate rows.
class DuplicateDetector {
  const DuplicateDetector();

  /// Window within which two alerts for the same payment are expected to land.
  static const window = Duration(minutes: 3);

  /// True when [candidate] duplicates any row in [existing]. [existing] should
  /// hold rows that share the candidate's reference number, or its
  /// amount+direction near its timestamp.
  bool isDuplicate(ParsedSms candidate, List<Transaction> existing) {
    for (final t in existing) {
      // The stored row for this very SMS (re-scan) is insertIfNew's job.
      if (t.smsId == candidate.smsId) continue;
      if (_matches(candidate, t)) return true;
    }
    return false;
  }

  bool _matches(ParsedSms c, Transaction t) {
    if (t.transactionType != c.transactionType) return false;
    if ((t.amount - c.amount).abs() > 0.005) return false;

    // A shared bank reference number (UTR) is conclusive either way.
    if (c.referenceNo != null && t.referenceNo != null) {
      return t.referenceNo == c.referenceNo;
    }

    // Without a reference on both sides, require the same account tail and a
    // close timestamp. Conservative on purpose: two genuine same-amount
    // payments must never be collapsed into one.
    if (t.date.difference(c.date).abs() > window) return false;
    if (c.accountLast4 != null && t.accountLast4 != null) {
      return c.accountLast4 == t.accountLast4;
    }
    return false; // can't corroborate -> keep both
  }
}
