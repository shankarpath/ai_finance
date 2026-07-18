/// Collapses the many raw forms of a merchant/payee into one canonical name so
/// analytics don't fragment (e.g. "SWIGGY*ONLINE", "upiswiggy@icici",
/// "SWIGGYBLR" all become "Swiggy").
///
/// Purely offline and deterministic.
class MerchantNormalizer {
  const MerchantNormalizer();

  /// Ordered brand rules: the first whose key appears in the cleaned string
  /// wins. More specific keys must come before their prefixes.
  static const List<MapEntry<String, String>> _brands = [
    MapEntry('swiggyinstamart', 'Swiggy Instamart'),
    MapEntry('instamart', 'Swiggy Instamart'),
    MapEntry('swiggy', 'Swiggy'),
    MapEntry('zomato', 'Zomato'),
    MapEntry('blinkit', 'Blinkit'),
    MapEntry('zepto', 'Zepto'),
    MapEntry('bigbasket', 'BigBasket'),
    MapEntry('dmart', 'DMart'),
    MapEntry('jiomart', 'JioMart'),
    MapEntry('amazon', 'Amazon'),
    MapEntry('amzn', 'Amazon'),
    MapEntry('flipkart', 'Flipkart'),
    MapEntry('myntra', 'Myntra'),
    MapEntry('ajio', 'Ajio'),
    MapEntry('meesho', 'Meesho'),
    MapEntry('nykaa', 'Nykaa'),
    MapEntry('uber', 'Uber'),
    MapEntry('olacabs', 'Ola'),
    MapEntry('ola', 'Ola'),
    MapEntry('rapido', 'Rapido'),
    MapEntry('irctc', 'IRCTC'),
    MapEntry('makemytrip', 'MakeMyTrip'),
    MapEntry('goibibo', 'Goibibo'),
    MapEntry('redbus', 'RedBus'),
    MapEntry('netflix', 'Netflix'),
    MapEntry('spotify', 'Spotify'),
    MapEntry('primevideo', 'Prime Video'),
    MapEntry('hotstar', 'Hotstar'),
    MapEntry('bookmyshow', 'BookMyShow'),
    MapEntry('youtube', 'YouTube'),
    MapEntry('pharmeasy', 'PharmEasy'),
    MapEntry('netmeds', 'Netmeds'),
    MapEntry('apollo', 'Apollo'),
    MapEntry('1mg', '1mg'),
    MapEntry('zerodha', 'Zerodha'),
    MapEntry('groww', 'Groww'),
    MapEntry('upstox', 'Upstox'),
    MapEntry('airtel', 'Airtel'),
    MapEntry('jio', 'Jio'),
    MapEntry('vodafone', 'Vodafone'),
  ];

  /// Noise words stripped from an otherwise-unknown merchant before title-casing.
  static final _noise = RegExp(
    r'\b(limited|ltd|pvt|private|india|online|payment|store|services?|'
    r'retail|enterprises?|technologies|solutions|blr|hyd|mum|del|blore|'
    r'bengaluru|mumbai|delhi|chennai|hyderabad)\b',
    caseSensitive: false,
  );

  /// Returns the canonical display name for [raw]. [raw] is the merchant string
  /// detected by the parser. [aliases] is the learned raw→canonical map from
  /// the database (lowercased keys) and always wins over the static rules, so
  /// user/AI corrections extend normalization without an app update.
  String normalize(String raw, {Map<String, String>? aliases}) {
    var s = raw.trim().toLowerCase();
    if (s.isEmpty) return 'Unknown';

    final learned = aliases?[s];
    if (learned != null && learned.isNotEmpty) return learned;

    // Drop the UPI handle domain: "upiswiggy@icici" -> "upiswiggy".
    final at = s.indexOf('@');
    if (at > 0) s = s.substring(0, at);

    // Collapse a compact key for brand matching (letters+digits only).
    final key = s.replaceAll(RegExp(r'[^a-z0-9]'), '');
    for (final b in _brands) {
      if (key.contains(b.key)) return b.value;
    }

    // Not a known brand — clean and title-case (person name / unknown payee).
    var cleaned = s
        .replaceAll(RegExp(r'[*_/\\|]+'), ' ')
        .replaceAll(_noise, ' ')
        // Strip common UPI prefixes/suffixes that aren't part of the name.
        .replaceAll(RegExp(r'\b(upi|pay|vpa)\b', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
    if (cleaned.isEmpty) cleaned = s.trim();

    return _titleCase(cleaned);
  }

  String _titleCase(String s) {
    return s
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w.length == 1
            ? w.toUpperCase()
            : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
