import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thrown when a Gemini request fails, with a user-presentable [message].
class AiException implements Exception {
  final String message;
  AiException(this.message);
  @override
  String toString() => message;
}

/// Internal: a 429/quota failure for a specific model, used to drive the
/// model-fallback loop. Not surfaced to the UI directly.
class _QuotaException implements Exception {
  final String message;
  _QuotaException(this.message);
}

/// A tool call the model wants to make on the user's behalf (e.g. set a
/// budget). Raw name + args; the caller validates and executes it.
class AiAction {
  final String name;
  final Map<String, dynamic> args;
  const AiAction(this.name, this.args);
}

/// The outcome of an agentic chat turn: the model's natural-language reply
/// and/or a list of proposed [AiAction]s awaiting user confirmation.
class AiChatResult {
  final String? text;
  final List<AiAction> actions;
  const AiChatResult(this.text, this.actions);

  bool get hasActions => actions.isNotEmpty;
}

/// Minimal client for Google's Gemini `generateContent` REST API.
///
/// This class only performs the HTTP call — the caller is responsible for
/// building a privacy-safe prompt (see `finance_context.dart`). The API key is
/// supplied per call so it can live in secure storage rather than in the client.
class AiService {
  final http.Client _client;
  AiService({http.Client? client}) : _client = client ?? http.Client();

  static const _base =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// Tried in order; the first model whose free tier accepts the request wins.
  /// Different keys/regions have a free-tier `limit: 0` on some models, so we
  /// fall through until one works.
  static const _models = [
    'gemini-2.5-flash',
    'gemini-2.0-flash-lite',
    'gemini-2.5-flash-lite',
    'gemini-2.0-flash',
  ];

  static const _chatSystemPrompt =
      'You are FinCoach, a sharp, warm personal-finance coach inside an Indian '
      'rupee (INR, ₹) money app. You are given a JSON summary of the user\'s '
      'real spending (budgets, safe-to-spend, projections included). Answer '
      'using ONLY that data — never invent numbers. Be direct, specific and '
      'encouraging; short paragraphs or bullets; markdown allowed. When the '
      'user asks for advice, give concrete ₹ amounts and actions. If the data '
      'cannot answer, say so plainly.';

  /// Sends [question] together with a pre-built [contextSummary] (safe,
  /// aggregated spending data) and returns the model's answer text.
  Future<String> chat({
    required String apiKey,
    required String question,
    required String contextSummary,
  }) {
    return _callWithFallback(
      apiKey: apiKey,
      systemPrompt: _chatSystemPrompt,
      userText: 'Spending summary (JSON):\n$contextSummary\n\nQuestion: $question',
      temperature: 0.3,
      maxTokens: 800,
    );
  }

  static const _agentSystemPrompt =
      'You are FinCoach, a sharp, warm personal-finance coach inside an Indian '
      'rupee (INR, ₹) money app. You are given a JSON summary of the user\'s '
      'real spending (budgets, safe-to-spend, projections). Answer using ONLY '
      'that data — never invent numbers. You can also ACT for the user by '
      'calling the provided tools: set or remove a category budget, set the '
      'monthly savings goal, or recategorise a merchant. Call a tool ONLY when '
      'the user clearly asks to change one of those things — otherwise just '
      'answer. The app shows the user a confirmation before anything is '
      'applied, so when you call a tool, also add one short line saying what '
      'you\'re proposing and why. Be direct and specific; markdown allowed.';

  /// Agentic chat: like [chat], but the model may also return tool calls
  /// (from [tools], in Gemini function-declaration form). Returns the reply
  /// text and any proposed [AiAction]s. Actions are NOT executed here — the
  /// caller confirms with the user first.
  Future<AiChatResult> chatWithActions({
    required String apiKey,
    required String question,
    required String contextSummary,
    required List<Map<String, dynamic>> tools,
  }) async {
    final parts = await _generatePartsWithFallback(
      apiKey: apiKey,
      systemPrompt: _agentSystemPrompt,
      userText:
          'Spending summary (JSON):\n$contextSummary\n\nUser: $question',
      temperature: 0.3,
      maxTokens: 800,
      tools: tools.isEmpty
          ? null
          : [
              {'function_declarations': tools}
            ],
    );

    final buffer = StringBuffer();
    final actions = <AiAction>[];
    for (final part in parts) {
      if (part is! Map<String, dynamic>) continue;
      final call = part['functionCall'];
      if (call is Map<String, dynamic>) {
        final name = call['name'] as String?;
        final args = (call['args'] as Map?)?.cast<String, dynamic>() ?? {};
        if (name != null && name.isNotEmpty) actions.add(AiAction(name, args));
      } else {
        final text = part['text'] as String?;
        if (text != null) buffer.write(text);
      }
    }
    final text = buffer.toString().trim();
    return AiChatResult(text.isEmpty ? null : text, actions);
  }

  /// General-purpose generation with the model-fallback chain. Powers the
  /// coach features (briefings, digests, reports). The caller owns the prompt;
  /// the privacy boundary stays in FinanceContext.
  Future<String> generate({
    required String apiKey,
    required String systemPrompt,
    required String userText,
    double temperature = 0.4,
    int maxTokens = 1000,
  }) {
    return _callWithFallback(
      apiKey: apiKey,
      systemPrompt: systemPrompt,
      userText: userText,
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }

  /// Asks the model to propose monthly budget limits per category from
  /// 3-month average spend aggregates. Returns category → suggested ₹ limit.
  Future<Map<String, double>> suggestBudgets({
    required String apiKey,
    required Map<String, double> monthlyCategoryAverages,
    required List<String> allowedCategories,
  }) async {
    final system =
        'You are a budgeting expert for an Indian (INR) personal finance app. '
        'Given average monthly spend per category, propose a realistic monthly '
        'budget limit per category: slightly below the average for '
        'discretionary categories (Food, Shopping, Entertainment, Grocery, '
        'Travel), at/near the average for fixed ones (Bills, EMI). Round to '
        'friendly numbers (nearest 100). Only include categories from this '
        'list: ${allowedCategories.join(", ")}. Skip categories with trivial '
        'spend (<200). Reply with ONLY a JSON object {"Category": limit, ...} '
        'with numeric values. No prose.';
    final raw = await _callWithFallback(
      apiKey: apiKey,
      systemPrompt: system,
      userText: 'Average monthly spend (₹):\n${jsonEncode(monthlyCategoryAverages)}',
      temperature: 0.0,
      maxTokens: 600,
    );
    final allowed = allowedCategories.toSet();
    final result = <String, double>{};
    try {
      final map = jsonDecode(_extractJsonBlock(raw)) as Map<String, dynamic>;
      map.forEach((category, value) {
        if (!allowed.contains(category)) return;
        final limit = (value is num) ? value.toDouble() : null;
        if (limit != null && limit > 0) result[category] = limit;
      });
    } catch (_) {}
    return result;
  }

  /// Asks the model to categorise a list of merchant names into the app's
  /// categories. Returns merchant → (category, confidence 0–100).
  /// Only merchant names are sent — no amounts, dates, or SMS text.
  Future<Map<String, ({String category, int confidence})>> categorizeMerchants({
    required String apiKey,
    required List<String> merchants,
    required List<String> allowedCategories,
  }) async {
    final system =
        'You categorise Indian merchant/payee names for a budgeting app. '
        'For each name choose exactly one category from this list: '
        '${allowedCategories.join(", ")}. '
        'A person\'s name or peer UPI id (money sent to an individual) is "Transfer". '
        'Reply with ONLY a JSON object mapping each input name to '
        '{"category": <one of the list>, "confidence": <0-100>}. No prose.';
    final userText = 'Names:\n${jsonEncode(merchants)}';

    final raw = await _callWithFallback(
      apiKey: apiKey,
      systemPrompt: system,
      userText: userText,
      temperature: 0.0,
      maxTokens: 2000,
    );
    return _parseMerchantMap(raw, allowedCategories);
  }

  Future<String> _callWithFallback({
    required String apiKey,
    required String systemPrompt,
    required String userText,
    required double temperature,
    required int maxTokens,
  }) async {
    AiException? lastQuotaError;
    for (final model in _models) {
      try {
        return await _generate(
          model: model,
          apiKey: apiKey,
          systemPrompt: systemPrompt,
          userText: userText,
          temperature: temperature,
          maxTokens: maxTokens,
        );
      } on _QuotaException catch (e) {
        lastQuotaError = AiException(e.message);
      }
    }
    throw lastQuotaError ??
        AiException('No available Gemini model for this key.');
  }

  /// Like [_callWithFallback] but returns the raw response `parts` (so the
  /// caller can read `functionCall` parts). Used by [chatWithActions].
  Future<List<dynamic>> _generatePartsWithFallback({
    required String apiKey,
    required String systemPrompt,
    required String userText,
    required double temperature,
    required int maxTokens,
    List<Map<String, dynamic>>? tools,
  }) async {
    AiException? lastQuotaError;
    for (final model in _models) {
      try {
        return await _generateParts(
          model: model,
          apiKey: apiKey,
          systemPrompt: systemPrompt,
          userText: userText,
          temperature: temperature,
          maxTokens: maxTokens,
          tools: tools,
        );
      } on _QuotaException catch (e) {
        lastQuotaError = AiException(e.message);
      }
    }
    throw lastQuotaError ??
        AiException('No available Gemini model for this key.');
  }

  Future<List<dynamic>> _generateParts({
    required String model,
    required String apiKey,
    required String systemPrompt,
    required String userText,
    required double temperature,
    required int maxTokens,
    List<Map<String, dynamic>>? tools,
  }) async {
    final uri = Uri.parse('$_base/$model:generateContent?key=$apiKey');
    final generationConfig = <String, dynamic>{
      'temperature': temperature,
      'maxOutputTokens': maxTokens,
    };
    if (model.contains('2.5')) {
      generationConfig['thinkingConfig'] = {'thinkingBudget': 0};
    }
    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': systemPrompt}
        ]
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': userText}
          ]
        }
      ],
      'generationConfig': generationConfig,
      'tools': ?tools,
    });

    http.Response res;
    try {
      res = await _client
          .post(uri,
              headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw AiException('Network error contacting Gemini. Check your connection.');
    }

    if (res.statusCode == 429 || res.statusCode >= 500) {
      throw _QuotaException(_errorMessage(res.statusCode, res.body));
    }
    if (res.statusCode != 200) {
      throw AiException(_errorMessage(res.statusCode, res.body));
    }

    try {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final candidates = json['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw AiException('Gemini returned no answer.');
      }
      final parts = (candidates.first['content']?['parts']) as List<dynamic>?;
      return parts ?? const [];
    } on AiException {
      rethrow;
    } catch (_) {
      throw AiException('Could not parse the Gemini response.');
    }
  }

  Future<String> _generate({
    required String model,
    required String apiKey,
    required String systemPrompt,
    required String userText,
    required double temperature,
    required int maxTokens,
  }) async {
    final uri = Uri.parse('$_base/$model:generateContent?key=$apiKey');
    final generationConfig = <String, dynamic>{
      'temperature': temperature,
      'maxOutputTokens': maxTokens,
    };
    // 2.5 models "think" by default, which can consume the whole output budget
    // and return empty text. Disable it for our short, structured responses.
    if (model.contains('2.5')) {
      generationConfig['thinkingConfig'] = {'thinkingBudget': 0};
    }
    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': systemPrompt}
        ]
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': userText}
          ]
        }
      ],
      'generationConfig': generationConfig,
    });

    http.Response res;
    try {
      res = await _client
          .post(uri,
              headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw AiException('Network error contacting Gemini. Check your connection.');
    }

    // 429 = quota/limit, 5xx = server overloaded/unavailable. Both are worth
    // trying another model for rather than failing outright.
    if (res.statusCode == 429 || res.statusCode >= 500) {
      throw _QuotaException(_errorMessage(res.statusCode, res.body));
    }
    if (res.statusCode != 200) {
      throw AiException(_errorMessage(res.statusCode, res.body));
    }

    return _extractText(res.body);
  }

  /// Builds a helpful message from Gemini's error body, which looks like:
  /// `{"error":{"code":429,"message":"...","status":"RESOURCE_EXHAUSTED"}}`.
  String _errorMessage(int status, String body) {
    String? detail;
    try {
      final err = (jsonDecode(body) as Map<String, dynamic>)['error']
          as Map<String, dynamic>?;
      detail = err?['message'] as String?;
    } catch (_) {}

    final base = switch (status) {
      400 || 403 =>
        'Gemini rejected the request — your API key may be invalid or lacks '
            'access to this model.',
      429 =>
        'Gemini quota/rate limit hit (429). On the free tier this often means '
            'the daily quota for the model is exhausted.',
      404 => 'Model not found (404).',
      >= 500 => 'Gemini is temporarily overloaded ($status). Try again shortly.',
      _ => 'Gemini error $status.',
    };
    return detail == null ? base : '$base\n\nDetails: $detail';
  }

  String _extractText(String responseBody) {
    try {
      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      final candidates = json['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        // Often a safety block or empty completion.
        throw AiException('Gemini returned no answer for that question.');
      }
      final parts = (candidates.first['content']?['parts']) as List<dynamic>?;
      final text = parts
          ?.map((p) => (p as Map<String, dynamic>)['text'] as String? ?? '')
          .join()
          .trim();
      if (text == null || text.isEmpty) {
        throw AiException('Gemini returned an empty answer.');
      }
      return text;
    } on AiException {
      rethrow;
    } catch (_) {
      throw AiException('Could not parse the Gemini response.');
    }
  }

  /// Extracts the JSON payload from a model reply, tolerating ```json fences
  /// and surrounding prose.
  String _extractJsonBlock(String raw) {
    var text = raw.trim();
    final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(text);
    if (fence != null) return fence.group(1)!.trim();
    final brace = RegExp(r'\{[\s\S]*\}').firstMatch(text);
    return brace?.group(0) ?? text;
  }

  /// Parses the merchant→category JSON, matching categories
  /// case-insensitively against [allowed].
  Map<String, ({String category, int confidence})> _parseMerchantMap(
      String raw, List<String> allowed) {
    // Case-insensitive lookup from the model's category string to our canonical.
    final byLower = {for (final c in allowed) c.toLowerCase(): c};
    final text = _extractJsonBlock(raw);

    final result = <String, ({String category, int confidence})>{};
    try {
      final map = jsonDecode(text) as Map<String, dynamic>;
      map.forEach((merchant, value) {
        if (value is! Map) return;
        final category = (value['category'] as String?)?.trim().toLowerCase();
        final canonical = category == null ? null : byLower[category];
        if (canonical == null) return;
        final conf = (value['confidence'] as num?)?.round() ?? 50;
        result[merchant] = (category: canonical, confidence: conf.clamp(0, 100));
      });
    } catch (_) {
      // Malformed JSON — return whatever we could parse (possibly empty).
    }
    return result;
  }
}
