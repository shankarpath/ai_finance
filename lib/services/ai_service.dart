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
      'You are a concise personal-finance assistant inside an Indian rupee (INR) '
      'budgeting app. You are given a JSON summary of the user\'s recent spending. '
      'Answer their question using ONLY that data. Be brief and specific, use ₹ for '
      'amounts, and never invent numbers that are not derivable from the summary. '
      'If the data cannot answer the question, say so plainly.';

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

  /// Parses the merchant→category JSON, tolerating ```json code fences and
  /// matching categories case-insensitively against [allowed].
  Map<String, ({String category, int confidence})> _parseMerchantMap(
      String raw, List<String> allowed) {
    // Case-insensitive lookup from the model's category string to our canonical.
    final byLower = {for (final c in allowed) c.toLowerCase(): c};

    var text = raw.trim();
    // Prefer a fenced block, else the first {...} object in the text.
    final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(text);
    if (fence != null) {
      text = fence.group(1)!.trim();
    } else {
      final brace = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (brace != null) text = brace.group(0)!;
    }

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
