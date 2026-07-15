import '../models/categories.dart';
import 'ai_service.dart';
import 'categorizer_service.dart';
import 'database_service.dart';
import 'settings_service.dart';

/// Current best label for a canonical merchant, as stored on its transactions.
class _MerchantState {
  final String category;
  final int confidence;
  final String source; // 'rule' | 'ai' | 'user'
  const _MerchantState(this.category, this.confidence, this.source);

  bool get isUser => source == 'user';
}

/// The decided label to persist after weighing the AI verdict against the
/// existing rule/AI label.
class _Decision {
  final String category;
  final int confidence;
  final String source;
  final bool needsReview;

  /// When false the merchant already has the right label — only the AI cache is
  /// updated, sparing a redundant table write.
  final bool apply;

  const _Decision(
    this.category,
    this.confidence,
    this.source,
    this.needsReview, {
    this.apply = true,
  });
}

/// Drives categorisation with the cloud AI: every merchant the app has seen is
/// labelled by Gemini, with the offline rules acting only as the instant
/// fallback underneath. Each merchant name is sent at most once (see
/// [AppDatabase.cachedMerchants]) so a free-tier key survives a large inbox.
///
/// Privacy-scoped: only *canonical merchant names* are sent — never amounts,
/// dates, account numbers, or SMS text. No-ops unless the user enabled cloud AI.
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

  /// Merchants sent to the model per enrichment pass. The rest are picked up on
  /// subsequent syncs, keeping any single request small and rate-limit-friendly.
  static const _batchSize = 60;

  /// A rule label at or above this confidence is trusted enough that a merely
  /// *uncertain* AI guess should not be allowed to overwrite it.
  static const _strongRuleConfidence = 90;

  /// Categorises every not-yet-asked merchant. Best-effort: never throws, and
  /// always leaves the offline rule labels intact when AI is unavailable.
  Future<void> categorizeAll() async {
    final apiKey = await _settings.getApiKey();
    if (apiKey == null || !await _settings.hasConsent()) return;

    final cached = await _db.cachedMerchants();
    final snapshot = await _merchantSnapshot();

    // Candidates: real merchants that are not user-settled and not already
    // asked. This now includes rule-classified names (not just "Others"), which
    // is what makes AI the driver rather than a fallback for unknowns.
    //
    // Deliberately excluded: person-to-person UPI payees. The offline rules
    // label these "Transfer" from the person-name heuristic, and a real inbox
    // holds *thousands* of them — sending every friend's name to the cloud
    // would exhaust a free-tier key and teach the AI nothing it can act on. A
    // genuine business mis-tagged as a person is still tap-correctable.
    final candidates = snapshot.entries
        .where((e) =>
            !e.value.isUser &&
            !cached.contains(e.key) &&
            !_isPersonTransfer(e.value))
        .map((e) => e.key)
        .toList();
    if (candidates.isEmpty) return;

    final batch = candidates.take(_batchSize).toList();

    try {
      final map = await _ai.categorizeMerchants(
        apiKey: apiKey,
        merchants: batch,
        allowedCategories: AppCategory.aiChoosable,
      );
      for (final name in batch) {
        final verdict = map[name];
        // No answer for this name — leave it uncached so it retries next pass.
        if (verdict == null) continue;

        final decision = _decide(verdict, snapshot[name]!);
        if (decision.apply) {
          await _db.applyCategoryToMerchant(
            merchantCanonical: name,
            category: decision.category,
            confidence: decision.confidence,
            source: decision.source,
            needsReview: decision.needsReview,
          );
        }
        // Cache the AI's own verdict (not the decided one) so we never re-query
        // this merchant regardless of which label ultimately won.
        await _db.cacheMerchantCategory(
            name, verdict.category, verdict.confidence);
      }
    } catch (_) {
      // AI enrichment is best-effort; never block ingestion on it.
    }
  }

  /// A rule-assigned, low-confidence Transfer — i.e. the person-name UPI
  /// heuristic. These are kept out of the AI sweep on purpose (see candidates).
  bool _isPersonTransfer(_MerchantState s) =>
      s.source == 'rule' &&
      s.category == AppCategory.transfer &&
      s.confidence < CategoryResult.reviewThreshold;

  /// Weighs the AI verdict against the merchant's current rule/AI label.
  ///
  /// - Confident AI (≥ [CategoryResult.reviewThreshold]) always wins.
  /// - An uncertain AI guess must not degrade a strong rule label — keep the
  ///   rule (cache only, no write).
  /// - Otherwise both are weak: take the AI guess but flag it for review.
  _Decision _decide(
      ({String category, int confidence}) ai, _MerchantState current) {
    if (ai.confidence >= CategoryResult.reviewThreshold) {
      return _Decision(ai.category, ai.confidence, 'ai', false);
    }
    if (current.confidence >= _strongRuleConfidence &&
        current.category != AppCategory.others) {
      return _Decision(
          current.category, current.confidence, current.source, false,
          apply: false);
    }
    return _Decision(ai.category, ai.confidence, 'ai', true);
  }

  /// Builds a per-merchant view of the current best label. A user-set label on
  /// any transaction marks the whole merchant as settled.
  Future<Map<String, _MerchantState>> _merchantSnapshot() async {
    final txns = await _db.allTransactions();
    final snapshot = <String, _MerchantState>{};
    for (final t in txns) {
      final name = t.merchantCanonical;
      if (name == null || name.trim().isEmpty || name == 'Unknown') continue;

      final source = t.categorySource ?? 'rule';
      if (source == 'user') {
        snapshot[name] = _MerchantState(t.category, 100, 'user');
        continue;
      }
      // Don't overwrite a user verdict recorded from another row of this
      // merchant; otherwise keep the highest-confidence label seen.
      final existing = snapshot[name];
      if (existing != null && existing.isUser) continue;
      if (existing == null || (t.confidence ?? 0) > existing.confidence) {
        snapshot[name] = _MerchantState(t.category, t.confidence ?? 0, source);
      }
    }
    return snapshot;
  }
}
