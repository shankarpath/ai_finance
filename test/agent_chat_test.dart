import 'dart:convert';

import 'package:ai_finance_assistant/services/ai_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps a Gemini `generateContent` reply whose candidate has [parts].
String _response(List<Map<String, dynamic>> parts) => jsonEncode({
      'candidates': [
        {
          'content': {'parts': parts}
        }
      ]
    });

void main() {
  group('AiService.chatWithActions (function calling)', () {
    test('parses a function call into an AiAction, keeping accompanying text',
        () async {
      final client = MockClient((req) async {
        return http.Response(
          _response([
            {'text': 'Setting your food budget.'},
            {
              'functionCall': {
                'name': 'set_budget',
                'args': {'category': 'Food', 'monthly_limit': 8000},
              }
            },
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final ai = AiService(client: client);

      final result = await ai.chatWithActions(
        apiKey: 'k',
        question: 'set my food budget to 8000',
        contextSummary: '{}',
        tools: const [
          {'name': 'set_budget'}
        ],
      );

      expect(result.text, 'Setting your food budget.');
      expect(result.hasActions, isTrue);
      expect(result.actions.single.name, 'set_budget');
      expect(result.actions.single.args['category'], 'Food');
      expect(result.actions.single.args['monthly_limit'], 8000);
    });

    test('a plain text answer yields no actions', () async {
      final client = MockClient((req) async {
        return http.Response(
          _response([
            {'text': 'You spent ₹1,200 on food this week.'}
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final ai = AiService(client: client);

      final result = await ai.chatWithActions(
        apiKey: 'k',
        question: 'how much on food?',
        contextSummary: '{}',
        tools: const [],
      );

      expect(result.text, 'You spent ₹1,200 on food this week.');
      expect(result.hasActions, isFalse);
    });

    test('surfaces multiple parallel function calls', () async {
      final client = MockClient((req) async {
        return http.Response(
          _response([
            {
              'functionCall': {
                'name': 'set_budget',
                'args': {'category': 'Food', 'monthly_limit': 8000},
              }
            },
            {
              'functionCall': {
                'name': 'recategorize_merchant',
                'args': {'merchant': 'Blinkit', 'category': 'Grocery'},
              }
            },
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final ai = AiService(client: client);

      final result = await ai.chatWithActions(
        apiKey: 'k',
        question: 'cap food at 8k and move blinkit to grocery',
        contextSummary: '{}',
        tools: const [],
      );

      expect(result.actions.length, 2);
      expect(result.actions.map((a) => a.name),
          containsAll(['set_budget', 'recategorize_merchant']));
    });
  });
}
