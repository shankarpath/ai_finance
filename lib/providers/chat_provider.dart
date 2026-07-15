import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/categories.dart';
import '../services/ai_service.dart';
import '../services/finance_context.dart';
import '../utils/formatters.dart';
import 'app_providers.dart';

/// A concrete action the coach proposed and the user can apply or dismiss.
/// Mirrors an [AiAction] but validated and given a human-readable [label].
class ProposedAction {
  final String kind; // set_budget | remove_budget | set_savings_goal | recategorize_merchant
  final String label;
  final Map<String, dynamic> args;
  const ProposedAction(this.kind, this.label, this.args);
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;

  /// Proposed actions awaiting confirmation (assistant messages only).
  final List<ProposedAction> actions;

  /// null = pending, true = applied, false = dismissed. Only meaningful when
  /// [actions] is non-empty.
  final bool? applied;

  const ChatMessage(
    this.text, {
    required this.isUser,
    this.isError = false,
    this.actions = const [],
    this.applied,
  });

  bool get actionsResolved => applied != null;

  ChatMessage copyWith({bool? applied}) => ChatMessage(
        text,
        isUser: isUser,
        isError: isError,
        actions: actions,
        applied: applied ?? this.applied,
      );
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
    'Set my food budget to ₹8000',
    'Which merchant took most of my money?',
    'How can I save more this month?',
  ];

  /// Categories the coach may set a budget for (spending categories only).
  static const _budgetCategories = AppCategory.aiChoosable;

  /// Gemini function-declarations describing the actions the coach can take.
  static final List<Map<String, dynamic>> _tools = [
    {
      'name': 'set_budget',
      'description':
          'Set or update the user\'s monthly spending limit (in ₹) for a category.',
      'parameters': {
        'type': 'object',
        'properties': {
          'category': {'type': 'string', 'enum': _budgetCategories},
          'monthly_limit': {
            'type': 'number',
            'description': 'Monthly limit in rupees; must be greater than 0.'
          },
        },
        'required': ['category', 'monthly_limit'],
      },
    },
    {
      'name': 'remove_budget',
      'description': 'Remove the monthly budget for a category.',
      'parameters': {
        'type': 'object',
        'properties': {
          'category': {'type': 'string', 'enum': _budgetCategories},
        },
        'required': ['category'],
      },
    },
    {
      'name': 'set_savings_goal',
      'description':
          'Set the user\'s monthly savings goal in ₹. Pass 0 to clear it.',
      'parameters': {
        'type': 'object',
        'properties': {
          'amount': {'type': 'number'},
        },
        'required': ['amount'],
      },
    },
    {
      'name': 'recategorize_merchant',
      'description':
          'Reassign a merchant to a category for all of its transactions and '
              'remember the choice for the future.',
      'parameters': {
        'type': 'object',
        'properties': {
          'merchant': {'type': 'string'},
          'category': {'type': 'string', 'enum': AppCategory.all},
        },
        'required': ['merchant', 'category'],
      },
    },
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

      final db = ref.read(databaseProvider);
      final context = FinanceContext.build(
        txns,
        now: DateTime.now(),
        budgets: await db.getBudgets(),
        goalMonthlySave: await settings.getMonthlySavingsGoal(),
      );
      final result = await ref.read(aiServiceProvider).chatWithActions(
            apiKey: apiKey,
            question: q,
            contextSummary: context,
            tools: _tools,
          );

      final actions = result.actions
          .map(_toProposed)
          .whereType<ProposedAction>()
          .toList();

      // Fall back to a friendly line if the model only returned tool calls.
      final text = result.text ??
          (actions.isEmpty
              ? 'Sorry, I couldn\'t work that out.'
              : 'Here\'s what I can do — confirm to apply:');

      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(text, isUser: false, actions: actions),
        ],
        sending: false,
      );
    } on AiException catch (e) {
      _addError(e.message);
    } catch (_) {
      _addError('Something went wrong. Please try again.');
    }
  }

  /// Applies every action attached to the message at [index], then posts a
  /// confirmation summarising what changed.
  Future<void> applyProposed(int index) async {
    final messages = state.messages;
    if (index < 0 || index >= messages.length) return;
    final msg = messages[index];
    if (msg.actions.isEmpty || msg.actionsResolved) return;

    final done = <String>[];
    for (final action in msg.actions) {
      final summary = await _execute(action);
      if (summary != null) done.add(summary);
    }

    // Changing budgets/goal/categories changes the coaching picture.
    ref.invalidate(coachBriefingProvider);
    ref.invalidate(insightCardProvider);

    final updated = [...messages];
    updated[index] = msg.copyWith(applied: true);
    final confirmation = done.isEmpty
        ? 'Nothing changed — I couldn\'t apply those.'
        : 'Done:\n${done.map((d) => '• $d').join('\n')}';
    state = state.copyWith(
      messages: [...updated, ChatMessage(confirmation, isUser: false)],
    );
  }

  void dismissProposed(int index) {
    final messages = state.messages;
    if (index < 0 || index >= messages.length) return;
    final msg = messages[index];
    if (msg.actions.isEmpty || msg.actionsResolved) return;
    final updated = [...messages];
    updated[index] = msg.copyWith(applied: false);
    state = state.copyWith(messages: updated);
  }

  /// Validates a raw [AiAction] into a [ProposedAction], or null if it's
  /// malformed (unknown tool, bad category, non-positive amount, …).
  ProposedAction? _toProposed(AiAction a) {
    switch (a.name) {
      case 'set_budget':
        final category = _asCategory(a.args['category'], AppCategory.aiChoosable);
        final limit = _asPositiveAmount(a.args['monthly_limit']);
        if (category == null || limit == null) return null;
        return ProposedAction('set_budget',
            'Set $category budget to ${formatRupees(limit)}',
            {'category': category, 'monthly_limit': limit});
      case 'remove_budget':
        final category = _asCategory(a.args['category'], AppCategory.aiChoosable);
        if (category == null) return null;
        return ProposedAction(
            'remove_budget', 'Remove the $category budget', {'category': category});
      case 'set_savings_goal':
        final amount = (a.args['amount'] as num?)?.toDouble();
        if (amount == null || amount < 0) return null;
        final label = amount == 0
            ? 'Clear the monthly savings goal'
            : 'Set the monthly savings goal to ${formatRupees(amount)}';
        return ProposedAction('set_savings_goal', label, {'amount': amount});
      case 'recategorize_merchant':
        final merchant = (a.args['merchant'] as String?)?.trim();
        final category = _asCategory(a.args['category'], AppCategory.all);
        if (merchant == null || merchant.isEmpty || category == null) return null;
        return ProposedAction('recategorize_merchant',
            'Move "$merchant" to $category',
            {'merchant': merchant, 'category': category});
      default:
        return null;
    }
  }

  /// Runs one validated action against the local store. Returns a short
  /// summary for the confirmation message, or null if it was a no-op.
  Future<String?> _execute(ProposedAction a) async {
    final db = ref.read(databaseProvider);
    final settings = ref.read(settingsServiceProvider);
    switch (a.kind) {
      case 'set_budget':
        final category = a.args['category'] as String;
        final limit = a.args['monthly_limit'] as double;
        await db.setBudget(category, limit);
        return '$category budget set to ${formatRupees(limit)}';
      case 'remove_budget':
        final category = a.args['category'] as String;
        await db.removeBudget(category);
        return '$category budget removed';
      case 'set_savings_goal':
        final amount = a.args['amount'] as double;
        await settings.setMonthlySavingsGoal(amount <= 0 ? null : amount);
        return amount <= 0
            ? 'Savings goal cleared'
            : 'Savings goal set to ${formatRupees(amount)}';
      case 'recategorize_merchant':
        final merchant = a.args['merchant'] as String;
        final category = a.args['category'] as String;
        final canonical = _resolveMerchant(merchant);
        await ref
            .read(transactionRepositoryProvider)
            .setUserCategory(canonical, category);
        return '"$canonical" moved to $category';
      default:
        return null;
    }
  }

  /// Matches the model's free-text merchant name to a canonical name we
  /// actually store (case-insensitive), so the recategorisation lands. Falls
  /// back to the given name when there's no match.
  String _resolveMerchant(String name) {
    final txns = ref.read(allTransactionsProvider).value ?? const [];
    final lower = name.toLowerCase();
    for (final t in txns) {
      final canonical = t.merchantCanonical;
      if (canonical != null && canonical.toLowerCase() == lower) return canonical;
    }
    // Loose contains-match as a second chance (e.g. "blinkit" ~ "Blinkit").
    for (final t in txns) {
      final canonical = t.merchantCanonical;
      if (canonical != null &&
          canonical.toLowerCase().contains(lower) &&
          lower.length >= 3) {
        return canonical;
      }
    }
    return name;
  }

  String? _asCategory(dynamic raw, List<String> allowed) {
    if (raw is! String) return null;
    final lower = raw.trim().toLowerCase();
    for (final c in allowed) {
      if (c.toLowerCase() == lower) return c;
    }
    return null;
  }

  double? _asPositiveAmount(dynamic raw) {
    final v = (raw is num) ? raw.toDouble() : double.tryParse('$raw');
    if (v == null || v <= 0) return null;
    return v;
  }

  void _addError(String message) {
    state = state.copyWith(
      messages: [...state.messages, ChatMessage(message, isUser: false, isError: true)],
      sending: false,
    );
  }
}
