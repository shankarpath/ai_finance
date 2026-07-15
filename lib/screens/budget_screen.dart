import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/categories.dart';
import '../providers/app_providers.dart';
import '../providers/budget_progress.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/coach_widgets.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(budgetProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            tooltip: 'Let the coach suggest budgets',
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => _suggestWithAi(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editBudget(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add budget'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        children: [
          const _BudgetInsight(),
          const SizedBox(height: 12),
          if (progress.isEmpty)
            const _EmptyState()
          else
            for (final p in progress)
              _BudgetTile(
                progress: p,
                onTap: () => _editBudget(context, ref, existing: p),
              ),
        ],
      ),
    );
  }

  /// Asks the coach to propose limits from ~3 months of history, previews
  /// them, and applies on confirm.
  Future<void> _suggestWithAi(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
        const SnackBar(content: Text('Coach is studying your history…')));
    final suggestions = await ref.read(coachServiceProvider).suggestBudgets();
    if (!context.mounted) return;
    if (suggestions.isEmpty) {
      messenger.showSnackBar(const SnackBar(
          content: Text(
              'No suggestions — check your Gemini key in Settings, or add '
              'more transaction history.')));
      return;
    }

    final apply = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coach\'s suggested budgets'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final e in suggestions.entries)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(AppCategory.iconFor(e.key),
                      color: AppCategory.colorFor(e.key), size: 20),
                  title: Text(e.key),
                  trailing: Text(formatRupees(e.value),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Apply all')),
        ],
      ),
    );

    if (apply == true) {
      final db = ref.read(databaseProvider);
      for (final e in suggestions.entries) {
        await db.setBudget(e.key, e.value);
      }
      messenger.showSnackBar(SnackBar(
          content:
              Text('${suggestions.length} budgets set — safe-to-spend is live.')));
    }
  }

  Future<void> _editBudget(
    BuildContext context,
    WidgetRef ref, {
    BudgetProgress? existing,
  }) async {
    final taken = ref
        .read(budgetProgressProvider)
        .map((p) => p.category)
        .toSet();
    await showDialog<void>(
      context: context,
      builder: (_) => _BudgetDialog(existing: existing, taken: taken),
    );
  }
}

/// Proactive AI budget-health line at the top of the Budgets screen.
class _BudgetInsight extends ConsumerWidget {
  const _BudgetInsight();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CoachInsightCard(
      insight: ref.watch(budgetInsightProvider),
      icon: Icons.savings_outlined,
      accent: AppTheme.mint,
      emptyText: 'Add your Gemini key in Settings and the coach will watch '
          'your budgets for you.',
    );
  }
}

class _BudgetTile extends StatelessWidget {
  final BudgetProgress progress;
  final VoidCallback onTap;
  const _BudgetTile({required this.progress, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = AppCategory.colorFor(progress.category);
    final barColor = progress.isOver
        ? theme.colorScheme.error
        : progress.isNear
            ? const Color(0xFFFFA94D)
            : base;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(AppCategory.iconFor(progress.category), color: base, size: 20),
                  const SizedBox(width: 8),
                  Text(progress.category,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(
                    '${formatRupees(progress.spent)} / ${formatRupees(progress.limit)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress.fraction.clamp(0, 1).toDouble(),
                  minHeight: 8,
                  backgroundColor:
                      theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(barColor),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (progress.isOver)
                    Text('Over by ${formatRupees(-progress.remaining)}',
                        style: TextStyle(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600))
                  else
                    Text('${formatRupees(progress.remaining)} left'),
                  const Spacer(),
                  Text('${(progress.fraction * 100).round()}%',
                      style: TextStyle(color: barColor, fontWeight: FontWeight.w600)),
                ],
              ),
              if (progress.isNear || progress.isOver)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 16, color: barColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          progress.isOver
                              ? 'You have exceeded this budget.'
                              : 'You are close to this budget limit.',
                          style: theme.textTheme.bodySmall?.copyWith(color: barColor),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetDialog extends ConsumerStatefulWidget {
  final BudgetProgress? existing;
  final Set<String> taken;
  const _BudgetDialog({required this.existing, required this.taken});

  @override
  ConsumerState<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends ConsumerState<_BudgetDialog> {
  late String _category;
  late final TextEditingController _amount;

  @override
  void initState() {
    super.initState();
    _category = widget.existing?.category ?? _availableCategories().first;
    _amount = TextEditingController(
      text: widget.existing != null
          ? widget.existing!.limit.toStringAsFixed(0)
          : '',
    );
  }

  /// Spending categories (exclude income), plus the one being edited.
  List<String> _availableCategories() {
    return AppCategory.all
        .where((c) => !AppCategory.isIncome(c) && c != AppCategory.others)
        .where((c) => c == widget.existing?.category || !widget.taken.contains(c))
        .toList();
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final options = _availableCategories();
    return AlertDialog(
      title: Text(isEdit ? 'Edit budget' : 'Add budget'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [
              for (final c in options)
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: isEdit
                ? null
                : (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Monthly limit',
              prefixText: '₹ ',
            ),
          ),
        ],
      ),
      actions: [
        if (isEdit)
          TextButton(
            onPressed: () async {
              await ref.read(databaseProvider).removeBudget(_category);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text('Remove',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            final limit = double.tryParse(_amount.text.trim()) ?? 0;
            if (limit <= 0) return;
            await ref.read(databaseProvider).setBudget(_category, limit);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.savings_outlined,
              size: 56, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text('No budgets yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text(
            'Set a monthly limit per category to track your spending.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
