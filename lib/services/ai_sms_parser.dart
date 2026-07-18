import 'package:drift/drift.dart';

import '../models/parsed_sms.dart';
import 'ai_service.dart';
import 'categorizer_service.dart';
import 'database_service.dart';
import 'merchant_normalizer.dart';
import 'settings_service.dart';

/// Opt-in AI parsing of the never-drop queue: takes bank SMS the regex couldn't
/// read and asks Gemini to extract the transaction. Turns successful ones into
/// real transactions, marks OTP/promo/reminder false-positives as ignored, and
/// leaves genuine failures for another attempt (bounded).
///
/// PRIVACY: this sends the *raw SMS text* to the cloud, so it is gated on BOTH
/// cloud-AI consent and the separate, explicit SMS-parse consent. It no-ops
/// unless the user turned that on.
class AiSmsParser {
  final AiService _ai;
  final SettingsService _settings;
  final AppDatabase _db;
  final MerchantNormalizer _normalizer;
  final CategorizerService _categorizer;

  AiSmsParser({
    required AiService ai,
    required SettingsService settings,
    required AppDatabase db,
    MerchantNormalizer normalizer = const MerchantNormalizer(),
    CategorizerService categorizer = const CategorizerService(),
  })  : _ai = ai,
        _settings = settings,
        _db = db,
        _normalizer = normalizer,
        _categorizer = categorizer;

  /// Processes up to a handful of pending unparsed messages. Best-effort.
  Future<void> parseUnparsed() async {
    final apiKey = await _settings.getApiKey();
    if (apiKey == null ||
        !await _settings.hasConsent() ||
        !await _settings.hasSmsParseConsent()) {
      return;
    }

    final rows = await _db.unparsedForAi(maxAttempts: 2, limit: 10);
    if (rows.isEmpty) return;

    final memory = await _db.merchantMemoryMap();
    final aliases = await _db.merchantAliasMap();
    for (final row in rows) {
      await _db.bumpUnparsedAiAttempt(row.id);
      try {
        final result = await _ai.parseSms(apiKey: apiKey, body: row.body);
        if (result == null) continue; // unreadable — retry until maxAttempts.
        if (!result.isTxn) {
          await _db.setUnparsedStatus(row.id, 'ignored');
          continue;
        }
        await _insertFromAi(row, result, memory, aliases);
        await _db.setUnparsedStatus(row.id, 'resolved');
      } catch (_) {
        // Network/quota error — leave the row for a later run.
      }
    }
  }

  Future<void> _insertFromAi(
    UnparsedMessage row,
    ({bool isTxn, double? amount, String? type, String? merchant}) r,
    Map<String, String> memory,
    Map<String, String> aliases,
  ) async {
    final canonical =
        _normalizer.normalize(r.merchant ?? 'Unknown', aliases: aliases);
    // Teach the alias DB so this messy raw string resolves instantly next time.
    final raw = r.merchant?.trim() ?? '';
    if (raw.isNotEmpty && raw.toLowerCase() != canonical.toLowerCase()) {
      await _db.rememberMerchantAlias(raw, canonical, source: 'ai');
    }
    final parsed = ParsedSms(
      amount: r.amount!,
      transactionType: r.type!,
      date: row.receivedAt,
      smsBody: row.body,
      smsId: row.smsId,
      merchant: r.merchant,
      status: 'posted',
    );
    final cat = _categorizer.categorize(parsed, canonical, memory: memory);
    await _db.insertIfNew(TransactionsCompanion.insert(
      amount: parsed.amount,
      transactionType: parsed.transactionType,
      date: parsed.date,
      smsBody: parsed.smsBody,
      smsId: parsed.smsId,
      merchant: Value(r.merchant ?? 'Unknown'),
      merchantCanonical: Value(canonical),
      category: Value(cat.category),
      confidence: Value(cat.confidence),
      // Parsed by AI from the raw SMS — distinct provenance from the regex path.
      categorySource: const Value('ai'),
      status: const Value('posted'),
      needsReview: Value(cat.needsReview),
    ));
  }
}
