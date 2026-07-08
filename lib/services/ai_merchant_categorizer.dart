import '../models/categories.dart';
import 'ai_service.dart';
import 'categorizer_service.dart';
import 'database_service.dart';
import 'settings_service.dart';

/// Labels still-unknown (rule-categorised "Others") merchants using Gemini,
/// then writes the result back to every matching transaction.
///
/// Best-effort and privacy-scoped: only the *canonical merchant names* are sent
/// — never amounts, dates, or SMS text. No-ops unless the user enabled cloud AI.
class AiMerchantCategorizer {
  final AiService _ai;
  final SettingsService _settings;
  final AppDatabase _db;

  AiMerchantCategorizer({
    required AiService ai,
    required SettingsService settings,
    required AppDatabase db,
  })  : _ai = ai,
        _settings = settings,
        _db = db;

  Future<void> categorizeUnknowns() async {
    final apiKey = await _settings.getApiKey();
    if (apiKey == null || !await _settings.hasConsent()) return;

    final merchants = await _db.merchantsNeedingCategory();
    if (merchants.isEmpty) return;

    // Cap the batch so a single prompt stays reasonable; remaining unknowns are
    // picked up on subsequent syncs/reprocesses.
    final batch = merchants.take(80).toList();

    try {
      final map = await _ai.categorizeMerchants(
        apiKey: apiKey,
        merchants: batch,
        allowedCategories: AppCategory.aiChoosable,
      );
      for (final entry in map.entries) {
        // Persist even "Others"/"Transfer" so we don't re-query the same name.
        // Low-confidence AI guesses go to the review queue instead of being
        // silently trusted.
        await _db.applyCategoryToMerchant(
          merchantCanonical: entry.key,
          category: entry.value.category,
          confidence: entry.value.confidence,
          source: 'ai',
          needsReview:
              entry.value.confidence < CategoryResult.reviewThreshold,
        );
      }
    } catch (_) {
      // AI enrichment is best-effort; never block ingestion on it.
    }
  }
}
