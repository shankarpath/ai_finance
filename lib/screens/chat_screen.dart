import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

import '../providers/app_providers.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/coach_widgets.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

/// The Coach tab: a daily AI briefing on top, a coaching conversation below.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    _controller.clear();
    ref.read(chatProvider.notifier).send(text);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _setGoal() async {
    final settings = ref.read(settingsServiceProvider);
    final current = await settings.getMonthlySavingsGoal();
    if (!mounted) return;
    final controller = TextEditingController(
        text: current == null ? '' : current.toStringAsFixed(0));
    final saved = await showDialog<double?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Monthly savings goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
              labelText: 'Save per month', prefixText: '₹ '),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, 0.0),
              child: const Text('Clear')),
          FilledButton(
            onPressed: () => Navigator.pop(
                context, double.tryParse(controller.text.trim())),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved != null) {
      await settings.setMonthlySavingsGoal(saved <= 0 ? null : saved);
      // A new goal changes the coaching context — refresh the briefing.
      ref.invalidate(coachBriefingProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider);
    final aiReady = ref.watch(aiReadyProvider).value ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach'),
        actions: [
          IconButton(
            tooltip: 'Savings goal',
            icon: const Icon(Icons.flag_outlined),
            onPressed: _setGoal,
          ),
          IconButton(
            tooltip: 'Reports',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReportsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!aiReady) const _NotReadyBanner(),
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              children: [
                if (aiReady) const _BriefingCard(),
                const SizedBox(height: 12),
                if (state.messages.isEmpty)
                  _Suggestions(onTap: _send)
                else
                  for (final (i, m) in state.messages.indexed) ...[
                    if (m.isUser || m.text.isNotEmpty) _Bubble(message: m),
                    if (m.actions.isNotEmpty) _ProposalCard(index: i, message: m),
                  ],
                if (state.sending)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(children: [
                      const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 10),
                      Text('Coach is thinking…',
                          style: Theme.of(context).textTheme.bodySmall),
                    ]).animate(onPlay: (c) => c.repeat(reverse: true)).fade(
                        begin: 0.5, end: 1, duration: 700.ms),
                  ),
              ],
            ),
          ),
          _Composer(
              controller: _controller,
              onSend: _send,
              enabled: !state.sending),
        ],
      ),
    );
  }
}

/// Today's coach briefing (cached daily).
class _BriefingCard extends ConsumerWidget {
  const _BriefingCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final briefing = ref.watch(coachBriefingProvider);
    final theme = Theme.of(context);

    return Panel(
      gradient: AppTheme.heroGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.auto_awesome, color: AppTheme.mint, size: 18),
            const SizedBox(width: 8),
            Text('TODAY\'S BRIEFING',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w800,
                  color: Colors.white54,
                )),
          ]),
          const SizedBox(height: 10),
          briefing.when(
            loading: () => const Column(children: [
              SkeletonBox(height: 14),
              SizedBox(height: 8),
              SkeletonBox(height: 14),
              SizedBox(height: 8),
              SkeletonBox(height: 14, width: 180),
            ]),
            error: (_, __) => Text('Briefing unavailable right now.',
                style: theme.textTheme.bodyMedium),
            data: (text) => text == null
                ? Text('The coach needs a few transactions to work with.',
                    style: theme.textTheme.bodyMedium)
                : GptMarkdown(text,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45)),
          ),
        ],
      ),
    );
  }
}

class _NotReadyBanner extends StatelessWidget {
  const _NotReadyBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.errorContainer,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            const Icon(Icons.info_outline, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Add a Gemini API key and enable cloud AI in Settings to '
                'unlock your coach.',
                style: theme.textTheme.bodySmall,
              ),
            ),
            const Icon(Icons.chevron_right),
          ]),
        ),
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  final void Function(String) onTap;
  const _Suggestions({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Text('Ask your coach',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ),
        for (final s in ChatController.suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              onPressed: () => onTap(s),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              ),
              child: Text(s),
            ),
          ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    final color = message.isError
        ? theme.colorScheme.errorContainer
        : isUser
            ? theme.colorScheme.primary.withValues(alpha: 0.16)
            : theme.colorScheme.surfaceContainerHighest;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.84),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: isUser
            ? Text(message.text)
            : GptMarkdown(message.text,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.45)),
      ),
    );
  }
}

/// A confirmation card for coach-proposed actions (set budget, recategorise,
/// …). Nothing is written until the user taps Apply.
class _ProposalCard extends ConsumerWidget {
  final int index;
  final ChatMessage message;
  const _ProposalCard({required this.index, required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final resolved = message.actionsResolved;
    final applied = message.applied == true;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.auto_fix_high,
                  size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text('Proposed changes',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 8),
            for (final a in message.actions)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  '),
                    Expanded(
                        child: Text(a.label,
                            style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            if (!resolved)
              Row(children: [
                FilledButton.icon(
                  onPressed: () =>
                      ref.read(chatProvider.notifier).applyProposed(index),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Apply'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () =>
                      ref.read(chatProvider.notifier).dismissProposed(index),
                  child: const Text('Dismiss'),
                ),
              ])
            else
              Row(children: [
                Icon(applied ? Icons.check_circle : Icons.cancel_outlined,
                    size: 16,
                    color: applied
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline),
                const SizedBox(width: 6),
                Text(applied ? 'Applied' : 'Dismissed',
                    style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.outline)),
              ]),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onSend;
  final bool enabled;
  const _Composer(
      {required this.controller, required this.onSend, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              textInputAction: TextInputAction.send,
              onSubmitted: onSend,
              decoration: InputDecoration(
                hintText: 'Ask about your money…',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: enabled ? () => onSend(controller.text) : null,
            icon: const Icon(Icons.arrow_upward),
          ),
        ]),
      ),
    );
  }
}
