import '../models/categories.dart';
import '../models/parsed_sms.dart';

/// Result of rule-based categorisation.
class CategoryResult {
  final String category;

  /// 0–100. 0 means "unknown, hand to AI".
  final int confidence;

  /// 'rule' here; AI/user results are written elsewhere.
  final String source;

  const CategoryResult(this.category, this.confidence, [this.source = 'rule']);

  /// Below this confidence the app asks the user instead of silently guessing
  /// (spec: 95–100 auto, 80–94 editable, <80 ask).
  static const reviewThreshold = 80;

  bool get isUnknown => category == AppCategory.others && confidence == 0;

  /// Whether this guess should land in the review queue.
  ///
  /// P2P transfers are exempt: the person-name heuristic labels thousands of
  /// them at low confidence, which would drown the queue and make review
  /// useless. They keep their low-confidence marker on the transaction tile
  /// and stay tap-correctable there.
  bool get needsReview =>
      source != 'user' &&
      confidence < reviewThreshold &&
      category != AppCategory.transfer;
}

/// Assigns a spending [AppCategory] to a parsed transaction using local rules
/// only — no network. Unknown merchants fall through to Others (confidence 0)
/// so the AI layer can label them later.
class CategorizerService {
  const CategorizerService();

  /// Substring merchant → category (matched against the canonical name).
  static const Map<String, String> _merchantMap = {
    'swiggy instamart': AppCategory.grocery,
    'swiggy': AppCategory.food,
    'zomato': AppCategory.food,
    'dominos': AppCategory.food,
    'mcdonald': AppCategory.food,
    'kfc': AppCategory.food,
    'starbucks': AppCategory.food,
    'blinkit': AppCategory.grocery,
    'zepto': AppCategory.grocery,
    'bigbasket': AppCategory.grocery,
    'dmart': AppCategory.grocery,
    'jiomart': AppCategory.grocery,
    'amazon': AppCategory.shopping,
    'flipkart': AppCategory.shopping,
    'myntra': AppCategory.shopping,
    'ajio': AppCategory.shopping,
    'meesho': AppCategory.shopping,
    'nykaa': AppCategory.shopping,
    'uber': AppCategory.travel,
    'ola': AppCategory.travel,
    'rapido': AppCategory.travel,
    'irctc': AppCategory.travel,
    'makemytrip': AppCategory.travel,
    'goibibo': AppCategory.travel,
    'redbus': AppCategory.travel,
    'netflix': AppCategory.entertainment,
    'spotify': AppCategory.entertainment,
    'prime video': AppCategory.entertainment,
    'hotstar': AppCategory.entertainment,
    'bookmyshow': AppCategory.entertainment,
    'youtube': AppCategory.entertainment,
    'pharmeasy': AppCategory.medical,
    'netmeds': AppCategory.medical,
    'apollo': AppCategory.medical,
    '1mg': AppCategory.medical,
    'zerodha': AppCategory.investment,
    'groww': AppCategory.investment,
    'upstox': AppCategory.investment,
    'airtel': AppCategory.bills,
    'jio': AppCategory.bills,
    'vodafone': AppCategory.bills,
  };

  CategoryResult categorize(
    ParsedSms sms,
    String canonicalMerchant, {
    Map<String, String>? memory,
  }) {
    // A user-taught mapping always wins.
    final remembered = memory?[canonicalMerchant];
    if (remembered != null) return CategoryResult(remembered, 100, 'user');

    final body = sms.smsBody.toLowerCase();

    if (sms.isCredit) return _categorizeCredit(body);

    // --- Special debit types (checked before merchant lookup) ---
    if (RegExp(r'\bemi\b').hasMatch(body) ||
        body.contains('equated monthly')) {
      return const CategoryResult(AppCategory.emi, 95);
    }
    if (RegExp(r'\b(charges?|chrg|fee|gst|penalty)\b').hasMatch(body) &&
        !body.contains('recharge')) {
      return const CategoryResult(AppCategory.bankCharges, 90);
    }
    if (body.contains('atm') ||
        body.contains('cash wdl') ||
        body.contains('cash withdrawal') ||
        (body.contains('withdrawn') && body.contains('cash'))) {
      return const CategoryResult(AppCategory.cash, 90);
    }

    // --- Known merchant lookup on the canonical name ---
    final m = canonicalMerchant.toLowerCase();
    for (final entry in _merchantMap.entries) {
      if (m.contains(entry.key) || body.contains(entry.key)) {
        return CategoryResult(entry.value, 95);
      }
    }

    // Utility/recharge hint even without a known brand.
    if (body.contains('recharge') || body.contains('electricity') ||
        body.contains('broadband')) {
      return const CategoryResult(AppCategory.bills, 80);
    }

    // Peer-to-peer UPI to a person-looking payee -> Transfer (low confidence,
    // as the SMS alone can't tell a friend from rent). Handles the bulk of
    // personal UPI without any AI call.
    final isUpi = sms.paymentMethod == 'UPI' || body.contains('upi');
    if (isUpi && _looksLikePersonName(canonicalMerchant)) {
      return const CategoryResult(AppCategory.transfer, 40);
    }

    // Unknown — leave for the AI layer.
    return const CategoryResult(AppCategory.others, 0);
  }

  /// True for names like "Gouni Raju" / "Vamshi Krishna" — 1–4 alphabetic
  /// words. Excludes UPI handles (which carry digits/dots) and "Unknown".
  static bool _looksLikePersonName(String name) {
    if (name == 'Unknown') return false;
    return RegExp(r'^[A-Za-z]{2,}( [A-Za-z]{2,}){0,3}$').hasMatch(name);
  }

  CategoryResult _categorizeCredit(String body) {
    if (body.contains('salary') || body.contains('sal cr')) {
      return const CategoryResult(AppCategory.salary, 95);
    }
    if (body.contains('refund') ||
        body.contains('reversed') ||
        body.contains('reversal')) {
      return const CategoryResult(AppCategory.refund, 90);
    }
    if (body.contains('cashback')) {
      return const CategoryResult(AppCategory.cashback, 90);
    }
    if (body.contains('interest') || body.contains('int cr') ||
        body.contains('int.cr')) {
      return const CategoryResult(AppCategory.interest, 90);
    }
    return const CategoryResult(AppCategory.income, 60);
  }
}
