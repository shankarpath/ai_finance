import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/categories.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';
import '../services/finance_context.dart';
import '../services/transaction_query.dart';
import '../utils/formatters.dart';
import 'affordability.dart';
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
    'Can I afford a PS5?',
    'Where is my money going?',
    'Set my food budget to ₹8000',
    'How can I save more this month?',
  ];

  /// Categories the coach may set a budget for (spending categories only).
  static const _budgetCategories = AppCategory.aiChoosable;

  /// Cap on model↔tool round-trips per question — bounds latency and quota.
  static const _maxTurns = 4;

  static const _readToolNames = {
    'search_transactions',
    'spending_summary',
    'can_i_afford',
    'estimate_item_price',
  };

  /// READ tools: let the coach query the *full* transaction history locally so
  /// it can answer any question with exact figures (not just the summary).
  static final List<Map<String, dynamic>> _readTools = [
    {
      'name': 'search_transactions',
      'description':
          'Search the user\'s transactions and get the matching rows plus the '
              'total. Use for specific questions like "how much at Dominos in '
              'March" or "my biggest expenses last week". All filters optional.',
      'parameters': {
        'type': 'object',
        'properties': {
          'category': {'type': 'string', 'enum': AppCategory.all},
          'merchant': {
            'type': 'string',
            'description': 'Merchant name or part of it (case-insensitive).'
          },
          'type': {
            'type': 'string',
            'enum': ['debit', 'credit']
          },
          'start_date': {
            'type': 'string',
            'description': 'Inclusive start, ISO date YYYY-MM-DD.'
          },
          'end_date': {
            'type': 'string',
            'description': 'Inclusive end, ISO date YYYY-MM-DD.'
          },
          'min_amount': {'type': 'number'},
          'max_amount': {'type': 'number'},
          'limit': {
            'type': 'integer',
            'description': 'Max rows to return (default 20, max 50).'
          },
        },
      },
    },
    {
      'name': 'can_i_afford',
      'description':
          'Check whether the user can afford a purchase right now. Uses their '
              'real balance, upcoming subscriptions/EMIs, safety buffer, '
              'savings goal, and next salary date. ALWAYS call this for "can I '
              'buy/afford X" questions instead of guessing.',
      'parameters': {
        'type': 'object',
        'properties': {
          'price': {
            'type': 'number',
            'description': 'Purchase price in rupees. If the user did not give '
                'one, call estimate_item_price first.'
          },
          'item': {'type': 'string', 'description': 'What they want to buy.'},
        },
        'required': ['price'],
      },
    },
    {
      'name': 'estimate_item_price',
      'description':
          'Estimate the current typical retail price (₹, India) of a consumer '
              'product, e.g. "PS5", "iPhone 16", "1.5 ton AC". Use before '
              'can_i_afford when the user names an item without a price.',
      'parameters': {
        'type': 'object',
        'properties': {
          'item': {'type': 'string'},
        },
        'required': ['item'],
      },
    },
    {
      'name': 'spending_summary',
      'description':
          'Get totals grouped by category, merchant, month, or day (with '
              'optional filters). Use for "where did my money go", "top '
              'merchants", or "spend per month".',
      'parameters': {
        'type': 'object',
        'properties': {
          'group_by': {
            'type': 'string',
            'enum': ['category', 'merchant', 'month', 'day']
          },
          'category': {'type': 'string', 'enum': AppCategory.all},
          'merchant': {'type': 'string'},
          'type': {
            'type': 'string',
            'enum': ['debit', 'credit']
          },
          'start_date': {'type': 'string'},
          'end_date': {'type': 'string'},
        },
        'required': ['group_by'],
      },
    },
  ];

  /// All tools handed to the model = read tools + write/action tools.
  static final List<Map<String, dynamic>> _allTools = [..._readTools, ..._tools];

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
      final now = DateTime.now();
      final summary = FinanceContext.build(
        txns,
        now: now,
        budgets: await db.getBudgets(),
        goalMonthlySave: await settings.getMonthlySavingsGoal(),
      );

      final ai = ref.read(aiServiceProvider);
      final contents = <Map<String, dynamic>>[
        {
          'role': 'user',
          'parts': [
            {
              'text': 'High-level summary (JSON):\n$summary\n\n'
                  'User question: $q'
            }
          ]
        }
      ];

      final proposed = <ProposedAction>[];
      String? finalText;

      // Multi-turn tool loop: the model calls read tools (answered locally from
      // the full history) and/or proposes write actions, until it replies with
      // text or we hit the turn cap.
      for (var turn = 0; turn < _maxTurns; turn++) {
        final parts = await ai.agentTurn(
          apiKey: apiKey,
          systemPrompt: _systemPrompt(now),
          contents: contents,
          tools: _allTools,
        );
        final split = AiService.splitParts(parts);
        if (split.text != null) finalText = split.text;
        if (split.calls.isEmpty) break;

        // Echo the model's tool-call turn back verbatim (required by the API).
        contents.add({'role': 'model', 'parts': parts});

        final responses = <Map<String, dynamic>>[];
        for (final call in split.calls) {
          if (_readToolNames.contains(call.name)) {
            responses.add({
              'functionResponse': {
                'name': call.name,
                'response': await _runReadTool(call, txns, apiKey),
              }
            });
          } else {
            final p = _toProposed(call);
            if (p != null) proposed.add(p);
            responses.add({
              'functionResponse': {
                'name': call.name,
                'response': {
                  'status': p == null
                      ? 'rejected: invalid arguments'
                      : 'queued — the user will confirm before it is applied',
                }
              }
            });
          }
        }
        contents.add({'role': 'user', 'parts': responses});
      }

      final text = finalText ??
          (proposed.isEmpty
              ? 'I couldn\'t work that out from your data.'
              : 'Here\'s what I can do — confirm to apply:');

      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(text, isUser: false, actions: proposed),
        ],
        sending: false,
      );
    } on AiException catch (e) {
      _addError(e.message);
    } catch (_) {
      _addError('Something went wrong. Please try again.');
    }
  }

  String _systemPrompt(DateTime now) {
    final today = now.toIso8601String().split('T').first;
    return 'You are FinCoach, a sharp, warm personal-finance coach in an Indian '
        'rupee (₹) money app. Today is $today. You have a high-level JSON '
        'summary of the user\'s finances, and you can call TOOLS to look up the '
        'exact answer to ANY question about their money:\n'
        '- search_transactions / spending_summary READ the full transaction '
        'history — use them for specific figures, date ranges, merchants or '
        'categories instead of guessing from the summary.\n'
        '- For "can I buy/afford X": call estimate_item_price if no price was '
        'given, then can_i_afford. Answer verdict-first ("Yes." / "Tight." / '
        '"No."), then what buying leaves after upcoming bills, the savings-goal '
        'delay in days, and — when tight or no — the smarter alternative '
        '(e.g. "wait N days until salary").\n'
        '- set_budget / remove_budget / set_savings_goal / recategorize_merchant '
        'ACT on the user\'s data.\n'
        'Rules: prefer a tool call over guessing; ground every number in tool '
        'results or the summary and never invent figures. Convert relative '
        'dates ("last month", "since Diwali") into concrete YYYY-MM-DD ranges '
        'from today\'s date. When you have enough to answer, reply in short, '
        'direct markdown with ₹ amounts. For actions, the app asks the user to '
        'confirm first, so briefly state what you\'re proposing.';
  }

  /// Executes a read tool against the in-memory [txns] (plus, for price
  /// estimation, one Gemini call) and returns the JSON-able result to feed
  /// back to the model.
  Future<Map<String, dynamic>> _runReadTool(
      AiAction call, List<Transaction> txns, String apiKey) async {
    if (call.name == 'estimate_item_price') {
      final item = (call.args['item'] as String?)?.trim() ?? '';
      if (item.isEmpty) return {'error': 'no item given'};
      try {
        final r = await ref
            .read(aiServiceProvider)
            .estimatePrice(apiKey: apiKey, item: item);
        return {'item': item, 'price': r.price, 'note': r.note};
      } catch (_) {
        return {'error': 'could not estimate — ask the user for the price'};
      }
    }

    if (call.name == 'can_i_afford') {
      final price = (call.args['price'] as num?)?.toDouble();
      if (price == null || price <= 0) return {'error': 'invalid price'};
      final saving = ref.read(monthlySavingProvider);
      final cap = ref.read(savingsCapacityProvider);
      final r = Affordability.check(
        txns,
        price: price,
        now: DateTime.now(),
        monthlySaving: saving.amount,
        monthlyIncome: cap.monthlyIncome,
      );
      return {
        'verdict': r.verdict.name,
        'price': _round(r.price),
        'known_balance': _round(r.knownBalance),
        'accounts_counted': r.accountsCounted,
        'upcoming_recurring_this_month': _round(r.upcomingRecurring),
        'upcoming_charges': [
          for (final u in r.upcomingCharges.take(6))
            {'merchant': u.merchant, 'amount': _round(u.amount)},
        ],
        'left_after_purchase_and_bills': _round(r.leftAfter),
        'safety_buffer': _round(r.buffer),
        'savings_goal_delay_days': r.goalDelayDays,
        'days_until_next_salary': r.daysUntilSalary,
      };
    }

    final filter = _filterFromArgs(call.args);
    if (call.name == 'spending_summary') {
      final groupBy = (call.args['group_by'] as String?) ?? 'category';
      final totals = TransactionQuery.aggregate(txns, filter, groupBy);
      final capped = <String, double>{};
      for (final e in totals.entries.take(25)) {
        capped[e.key] = _round(e.value);
      }
      return {'group_by': groupBy, 'totals': capped};
    }
    // search_transactions (default)
    final limit = (call.args['limit'] as num?)?.toInt() ?? 20;
    final r = TransactionQuery.search(txns, filter, limit: limit.clamp(1, 50));
    return {
      'match_count': r.count,
      'total_amount': _round(r.total),
      'transactions': [
        for (final t in r.rows)
          {
            'date': t.date.toIso8601String().split('T').first,
            'merchant': t.merchantCanonical ?? t.merchant,
            'category': t.category,
            'type': t.transactionType,
            'amount': _round(t.amount),
          }
      ],
    };
  }

  TxnFilter _filterFromArgs(Map<String, dynamic> a) {
    DateTime? parse(dynamic v, {bool endOfDay = false}) {
      if (v is! String || v.trim().isEmpty) return null;
      final d = DateTime.tryParse(v.trim());
      if (d == null) return null;
      return endOfDay
          ? DateTime(d.year, d.month, d.day, 23, 59, 59)
          : DateTime(d.year, d.month, d.day);
    }

    final type = (a['type'] as String?)?.toLowerCase();
    return TxnFilter(
      category: _asCategory(a['category'], AppCategory.all),
      merchant: (a['merchant'] as String?)?.trim(),
      type: (type == 'debit' || type == 'credit') ? type : null,
      start: parse(a['start_date']),
      end: parse(a['end_date'], endOfDay: true),
      minAmount: (a['min_amount'] as num?)?.toDouble(),
      maxAmount: (a['max_amount'] as num?)?.toDouble(),
    );
  }

  double _round(double v) => (v * 100).roundToDouble() / 100;

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
