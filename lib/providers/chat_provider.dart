import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/ai_service.dart';
import '../services/finance_context.dart';
import 'app_providers.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;
  const ChatMessage(this.text, {required this.isUser, this.isError = false});
}

class ChatState {
  final List<ChatMessage> messages;
  final bool sending;
  const ChatState({this.messages = const [], this.sending = false});

  ChatState copyWith({List<ChatMessage>? messages, bool? sending}) => ChatState(
        messages: messages ?? this.messages,
        sending: sending ?? this.sending,
      );
}

final chatProvider =
    NotifierProvider<ChatController, ChatState>(ChatController.new);

class ChatController extends Notifier<ChatState> {
  @override
  ChatState build() => const ChatState();

  static const suggestions = [
    'Where is my money going?',
    'How much did I spend on food this month?',
    'Which merchant took most of my money?',
    'How can I save more this month?',
  ];

  Future<void> send(String question) async {
    final q = question.trim();
    if (q.isEmpty || state.sending) return;

    state = state.copyWith(
      messages: [...state.messages, ChatMessage(q, isUser: true)],
      sending: true,
    );

    try {
      final settings = ref.read(settingsServiceProvider);
      final apiKey = await settings.getApiKey();
      if (apiKey == null || !await settings.hasConsent()) {
        _addError('Connect a Gemini API key and enable cloud AI in Settings to '
            'use the assistant.');
        return;
      }

      final txns = ref.read(allTransactionsProvider).value ?? const [];
      if (txns.isEmpty) {
        _addError('There are no transactions yet to analyse.');
        return;
      }

      final context = FinanceContext.build(txns, now: DateTime.now());
      final answer = await ref.read(aiServiceProvider).chat(
            apiKey: apiKey,
            question: q,
            contextSummary: context,
          );

      state = state.copyWith(
        messages: [...state.messages, ChatMessage(answer, isUser: false)],
        sending: false,
      );
    } on AiException catch (e) {
      _addError(e.message);
    } catch (_) {
      _addError('Something went wrong. Please try again.');
    }
  }

  void _addError(String message) {
    state = state.copyWith(
      messages: [...state.messages, ChatMessage(message, isUser: false, isError: true)],
      sending: false,
    );
  }
}
