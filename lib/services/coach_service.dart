import '../models/categories.dart';
import 'ai_service.dart';
import 'database_service.dart';
import 'finance_context.dart';
import 'settings_service.dart';

/// The AI Finance Coach: generates briefings, digests, weekly/monthly reports,
/// dashboard insight cards, and budget suggestions.
///
/// Every generated artifact is cached in the AiInsights table by (kind,
/// periodKey) so a free-tier Gemini key is asked once per period, not on every
/// open. All methods return null gracefully when AI isn't configured or fails —
/// callers must always have an offline fallback.
class CoachService {
  final AiService _ai;
  final SettingsService _settings;
  final AppDatabase _db;

  CoachService({
    required AiService ai,
    required SettingsService settings,
    required AppDatabase db,
  })  : _ai = ai,
        _settings = settings,
        _db = db;

  static const persona =
      'You are FinCoach, a sharp, warm personal-finance coach inside an Indian '
      '(INR, ₹) money app. You are given a JSON summary of the user\'s real '
      'spending. Ground every claim in those numbers — never invent figures. '
      'Be direct, specific and encouraging; short sentences; no corporate '
      'fluff. The user\'s goal is to stop money disappearing unnoticed.';

  // ---- Period keys ---------------------------------------------------------

  static String dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// ISO-8601 week key, e.g. 2026-W28.
  static String weekKey(DateTime d) {
    final thursday = d.add(Duration(days: 4 - (d.weekday == 0 ? 7 : d.weekday)));
    final firstDay = DateTime(thursday.year, 1, 1);
    final week = ((thursday.difference(firstDay).inDays) / 7).floor() + 1;
    return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
  }

  static String monthKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  // ---- Shared plumbing -----------------------------------------------------

  Future<String?> _apiKeyIfReady() async {
    final key = await _settings.getApiKey();
    if (key == null || !await _settings.hasConsent()) return null;
    return key;
  }

  Future<String> _context(DateTime now) async {
    final txns = await _db.allTransactions();
    final budgets = await _db.getBudgets();
    final goal = await _settings.getMonthlySavingsGoal();
    return FinanceContext.build(txns,
        now: now, budgets: budgets, goalMonthlySave: goal);
  }

  /// Cached generate: returns the stored artifact for (kind, periodKey) or
  /// generates + stores it. Returns null when AI is unavailable.
  Future<String?> _cached(
    String kind,
    String periodKey,
    String instruction, {
    int maxTokens = 900,
    bool regenerateIfOlderThan6h = false,
  }) async {
    final existing = await _db.getAiInsight(kind, periodKey);
    if (existing != null) {
      final fresh = !regenerateIfOlderThan6h ||
          DateTime.now().difference(existing.createdAt).inHours < 6;
      if (fresh) return existing.content;
    }

    final apiKey = await _apiKeyIfReady();
    if (apiKey == null) return existing?.content;

    try {
      final content = await _ai.generate(
        apiKey: apiKey,
        systemPrompt: persona,
        userText:
            'Spending data (JSON):\n${await _context(DateTime.now())}\n\n$instruction',
        maxTokens: maxTokens,
      );
      await _db.saveAiInsight(kind, periodKey, content.trim());
      return content.trim();
    } on AiException {
      return existing?.content;
    } catch (_) {
      return existing?.content;
    }
  }

  // ---- Coach artifacts -----------------------------------------------------

  /// The Coach-tab opening briefing (markdown, 3–5 short lines). Daily.
  Future<String?> briefing() {
    return _cached(
      'briefing',
      dayKey(DateTime.now()),
      'Write today\'s coaching briefing for the user. 3–5 short lines of '
      'markdown. Cover: how today/this week is going, the single biggest '
      'thing to watch (a budget nearly used, the projection, or the small-'
      'payment leak), and one concrete action. Address the user as "you". '
      'No heading, no sign-off.',
      regenerateIfOlderThan6h: true,
    );
  }

  /// One-sentence dashboard insight card. Daily.
  Future<String?> dashboardCard() {
    return _cached(
      'card',
      dayKey(DateTime.now()),
      'Write exactly ONE punchy insight sentence (max 20 words) the user most '
      'needs to see right now, derived from the data — e.g. a category pace, '
      'weekend vs weekday pattern, the leak, or the projection. Start with an '
      'emoji. Plain text, no markdown.',
      maxTokens: 100,
    );
  }

  /// Plain-text body for the nightly digest notification. Regenerated at most
  /// every 6h so it reflects the latest data by evening.
  Future<String?> dailyDigest() {
    return _cached(
      'daily',
      dayKey(DateTime.now()),
      'Write tonight\'s spending digest as ONE plain-text notification '
      '(max 220 characters, no markdown, no quotes). Include today\'s total, '
      'a comparison (vs the week\'s pace or a budget), and one coaching nudge '
      'for tomorrow.',
      maxTokens: 120,
      regenerateIfOlderThan6h: true,
    );
  }

  /// Proactive budget-health line for the Budgets screen. Names the category
  /// most at risk (pace vs days left) and one concrete move. Daily, refreshed
  /// through the day so it tracks new spending.
  Future<String?> budgetInsight() {
    return _cached(
      'budget_card',
      dayKey(DateTime.now()),
      'Study the budgets vs this-month spend in the data. Write ONE or TWO '
      'short sentences (max 30 words) coaching the user on their budget health '
      'right now: name the single category most at risk (spend pace vs days '
      'left this month) and one concrete ₹ move. If there are no budgets, '
      'encourage setting one for the top spend category. Start with an emoji. '
      'Plain text, no markdown, no quotes.',
      maxTokens: 120,
      regenerateIfOlderThan6h: true,
    );
  }

  /// Proactive "how this month is going" line for the Reports screen. Daily.
  Future<String?> monthProgressInsight() {
    return _cached(
      'month_progress',
      dayKey(DateTime.now()),
      'Summarise how THIS month is going so far in 2 short sentences (max 35 '
      'words): total spent and whether the pace is above or below last month, '
      'plus the one category driving it. End with whether they are on track. '
      'Start with an emoji. Plain text, no markdown, no quotes.',
      maxTokens: 140,
      regenerateIfOlderThan6h: true,
    );
  }

  /// The Sunday report card (markdown). First line MUST be "Grade: X".
  Future<String?> weeklyReport() {
    return _cached(
      'weekly',
      weekKey(DateTime.now()),
      'Write this week\'s report card in markdown. FIRST line exactly '
      '"Grade: <A/B/C/D/F with optional +/->" judging the week\'s discipline '
      'against budgets/goal. Then sections: "## Wins" (1–2 bullets), '
      '"## Leaks" (1–2 bullets with ₹ amounts), "## Next week" (one concrete, '
      'numeric plan). Keep the whole thing under 140 words.',
      maxTokens: 500,
    );
  }

  /// The monthly report (markdown) for [key] like '2026-07'.
  Future<String?> monthlyReport(String key) {
    return _cached(
      'monthly',
      key,
      'Write the monthly money report in markdown for month $key. Sections: '
      '"## Overview" (total spent vs last month, income vs spend), '
      '"## Where it went" (top 3 categories with ₹ and vs-last-month %), '
      '"## Subscriptions" (monthly cost if any), '
      '"## Coach\'s orders" (2 numbered actions with ₹ amounts). '
      'Under 180 words.',
      maxTokens: 600,
    );
  }

  /// AI-proposed budget limits from ~3 months of category averages.
  Future<Map<String, double>> suggestBudgets() async {
    final apiKey = await _apiKeyIfReady();
    if (apiKey == null) return {};

    final now = DateTime.now();
    final since = DateTime(now.year, now.month - 3, 1);
    final totals = <String, double>{};
    for (final t in await _db.allTransactions()) {
      if (t.transactionType != 'debit' || t.status != 'posted') continue;
      if (t.date.isBefore(since)) continue;
      if (AppCategory.isIncome(t.category)) continue;
      totals.update(t.category, (v) => v + t.amount, ifAbsent: () => t.amount);
    }
    if (totals.isEmpty) return {};
    // Convert ~3 months of totals into a monthly average.
    final months = ((now.difference(since).inDays) / 30).clamp(1, 4);
    final averages =
        totals.map((k, v) => MapEntry(k, (v / months * 100).round() / 100));

    try {
      return await _ai.suggestBudgets(
        apiKey: apiKey,
        monthlyCategoryAverages: averages,
        allowedCategories: AppCategory.all
            .where((c) => !AppCategory.isIncome(c) && c != AppCategory.others)
            .toList(),
      );
    } on AiException {
      return {};
    }
  }
}
