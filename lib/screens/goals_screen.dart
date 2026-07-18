import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/categories.dart';
import '../providers/app_providers.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// The Goals tab: name something you want to buy, let AI estimate its price,
/// and see how many months of saving it will take — plus a way to save toward it.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(purchaseGoalsProvider);
    final monthly = ref.watch(monthlySavingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addGoal(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New goal'),
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load goals: $e')),
        data: (goals) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            _CapacityCard(amount: monthly.amount, basis: monthly.basis),
            const SizedBox(height: 12),
            if (goals.isEmpty)
              const _EmptyState()
            else
              for (final g in goals)
                _GoalCard(goal: g, monthlySaving: monthly.amount),
          ],
        ),
      ),
    );
  }

  Future<void> _addGoal(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _AddGoalDialog(),
    );
  }
}

/// Shows the monthly amount used to project timelines, and where it came from.
class _CapacityCard extends StatelessWidget {
  final double amount;
  final String basis;
  const _CapacityCard({required this.amount, required this.basis});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final known = amount > 0;
    return Panel(
      gradient: AppTheme.heroGradient,
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        const Icon(Icons.savings, color: AppTheme.mint, size: 30),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                known
                    ? 'Saving about ${formatRupees(amount)} / month'
                    : 'No saving rate yet',
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                known
                    ? 'Timelines are based on $basis.'
                    : 'Set a monthly savings goal in Coach, or add more history, '
                        'to project how long each goal will take.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  final PurchaseGoal goal;
  final double monthlySaving;
  const _GoalCard({required this.goal, required this.monthlySaving});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final remaining =
        (goal.estimatedPrice - goal.saved).clamp(0, double.infinity).toDouble();
    final funded = remaining <= 0;
    final fraction = goal.estimatedPrice <= 0
        ? 0.0
        : (goal.saved / goal.estimatedPrice).clamp(0.0, 1.0);
    final months = (monthlySaving > 0 && remaining > 0)
        ? (remaining / monthlySaving).ceil()
        : null;

    return Panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(goal.name,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  if (goal.priceNote != null && goal.priceNote!.isNotEmpty)
                    Text(goal.priceNote!,
                        style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Text(formatRupees(goal.estimatedPrice),
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            _GoalMenu(goal: goal),
          ]),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(
                  funded ? AppTheme.mint : theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Text('${formatRupees(goal.saved)} saved',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('${(fraction * 100).round()}%',
                style: theme.textTheme.bodySmall),
          ]),
          const SizedBox(height: 10),
          _timeline(theme, funded, months, remaining),
          const SizedBox(height: 12),
          Row(children: [
            FilledButton.tonalIcon(
              onPressed: funded ? null : () => _addSavings(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add saved'),
            ),
          ]),
          if (!funded && monthlySaving > 0)
            _GoalSimulator(
              remaining: remaining,
              monthlySaving: monthlySaving,
            ),
        ],
      ),
    );
  }

  Widget _timeline(
      ThemeData theme, bool funded, int? months, double remaining) {
    if (funded) {
      return Row(children: [
        const Icon(Icons.celebration, size: 18, color: AppTheme.mint),
        const SizedBox(width: 8),
        Expanded(
          child: Text('Fully funded — you can buy this now! 🎉',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ),
      ]);
    }
    if (months == null) {
      return Row(children: [
        Icon(Icons.info_outline, size: 16, color: theme.colorScheme.outline),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${formatRupees(remaining)} to go. Set a savings goal in Coach to '
            'see a timeline.',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ]);
    }
    final ready = DateTime.now();
    final target = DateTime(ready.year, ready.month + months, ready.day);
    return Row(children: [
      const Icon(Icons.schedule, size: 16, color: AppTheme.sky),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          '≈ $months month${months == 1 ? '' : 's'} to go '
          '(around ${formatDayMonth(target)} ${target.year}) — keep saving '
          '${formatRupees(monthlySaving)}/mo.',
          style: theme.textTheme.bodySmall,
        ),
      ),
    ]);
  }

  Future<void> _addSavings(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final remaining =
        (goal.estimatedPrice - goal.saved).clamp(0, double.infinity).toDouble();
    final amount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add to "${goal.name}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${formatRupees(remaining)} left to reach the target.',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                  labelText: 'Amount to set aside', prefixText: '₹ '),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(
                context, double.tryParse(controller.text.trim())),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (amount != null && amount > 0) {
      await ref.read(databaseProvider).addToGoalSavings(goal.id, amount);
    }
  }
}

/// Overflow menu on a goal card: update price or remove.
class _GoalMenu extends ConsumerWidget {
  final PurchaseGoal goal;
  const _GoalMenu({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      onSelected: (v) async {
        if (v == 'price') {
          await _editPrice(context, ref);
        } else if (v == 'remove') {
          await ref.read(databaseProvider).deletePurchaseGoal(goal.id);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'price', child: Text('Update price')),
        PopupMenuItem(value: 'remove', child: Text('Remove goal')),
      ],
    );
  }

  Future<void> _editPrice(BuildContext context, WidgetRef ref) async {
    final controller =
        TextEditingController(text: goal.estimatedPrice.toStringAsFixed(0));
    final price = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update price'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'Price', prefixText: '₹ '),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(
                context, double.tryParse(controller.text.trim())),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (price != null && price > 0) {
      // Manual edit clears the AI note — it no longer describes this figure.
      await ref.read(databaseProvider).updateGoalPrice(goal.id, price, null);
    }
  }
}

/// Add-goal dialog: name the item, optionally let AI estimate the price.
class _AddGoalDialog extends ConsumerStatefulWidget {
  const _AddGoalDialog();

  @override
  ConsumerState<_AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends ConsumerState<_AddGoalDialog> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  String? _note;
  bool _estimating = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _estimate() async {
    final item = _name.text.trim();
    if (item.isEmpty) {
      setState(() => _error = 'Enter what you want to buy first.');
      return;
    }
    final settings = ref.read(settingsServiceProvider);
    final apiKey = await settings.getApiKey();
    if (apiKey == null || !await settings.hasConsent()) {
      setState(() => _error =
          'Add a Gemini key in Settings to estimate prices, or type one in.');
      return;
    }
    setState(() {
      _estimating = true;
      _error = null;
    });
    try {
      final result =
          await ref.read(aiServiceProvider).estimatePrice(apiKey: apiKey, item: item);
      if (!mounted) return;
      setState(() {
        _price.text = result.price.toStringAsFixed(0);
        _note = result.note.isEmpty ? null : result.note;
      });
    } on AiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not estimate. Try again.');
    } finally {
      if (mounted) setState(() => _estimating = false);
    }
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final price = double.tryParse(_price.text.trim()) ?? 0;
    if (name.isEmpty || price <= 0) {
      setState(() => _error = 'Enter an item and a price above zero.');
      return;
    }
    await ref
        .read(databaseProvider)
        .addPurchaseGoal(name: name, estimatedPrice: price, note: _note);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('New goal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'What do you want to buy?',
              hintText: 'e.g. Royal Enfield bike, 55" TV, 1.5 ton AC',
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _price,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                    labelText: 'Price', prefixText: '₹ '),
              ),
            ),
            const SizedBox(width: 8),
            _estimating
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : TextButton.icon(
                    onPressed: _estimate,
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('Estimate'),
                  ),
          ]),
          if (_note != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('AI: $_note',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontStyle: FontStyle.italic)),
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.error)),
            ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Add goal')),
      ],
    );
  }
}

/// "What gets me there faster?" — sliders that simulate cutting the top
/// discretionary categories and instantly recompute the goal timeline.
class _GoalSimulator extends ConsumerStatefulWidget {
  final double remaining;
  final double monthlySaving;
  const _GoalSimulator({required this.remaining, required this.monthlySaving});

  @override
  ConsumerState<_GoalSimulator> createState() => _GoalSimulatorState();
}

class _GoalSimulatorState extends ConsumerState<_GoalSimulator> {
  bool _open = false;

  /// category → cut fraction (0.0–0.5).
  final Map<String, double> _cuts = {};

  static const _discretionary = {
    AppCategory.food,
    AppCategory.grocery,
    AppCategory.shopping,
    AppCategory.entertainment,
    AppCategory.travel,
  };

  /// Top discretionary categories by average monthly spend (last 3 months).
  Map<String, double> _averages() {
    final txns = ref.read(allTransactionsProvider).value ?? const [];
    final now = DateTime.now();
    final since = DateTime(now.year, now.month - 3, 1);
    final totals = <String, double>{};
    for (final t in txns) {
      if (t.transactionType != 'debit' || t.status != 'posted') continue;
      if (t.date.isBefore(since)) continue;
      if (!_discretionary.contains(t.category)) continue;
      totals.update(t.category, (v) => v + t.amount, ifAbsent: () => t.amount);
    }
    final entries = totals.entries
        .map((e) => MapEntry(e.key, e.value / 3))
        .where((e) => e.value >= 500)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final e in entries.take(3)) e.key: e.value};
  }

  int _months(double monthly) =>
      monthly <= 0 ? 999 : (widget.remaining / monthly).ceil();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final averages = _averages();
    if (averages.isEmpty) return const SizedBox.shrink();

    final extra = averages.entries
        .fold<double>(0, (s, e) => s + e.value * (_cuts[e.key] ?? 0));
    final baseMonths = _months(widget.monthlySaving);
    final simMonths = _months(widget.monthlySaving + extra);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        InkWell(
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              const Icon(Icons.bolt, size: 16, color: AppTheme.amber),
              const SizedBox(width: 6),
              Text('Get there faster',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Icon(_open ? Icons.expand_less : Icons.expand_more, size: 18),
            ]),
          ),
        ),
        if (_open) ...[
          for (final e in averages.entries) ...[
            Row(children: [
              Icon(AppCategory.iconFor(e.key),
                  size: 15, color: AppCategory.colorFor(e.key)),
              const SizedBox(width: 6),
              Text('Cut ${e.key}', style: theme.textTheme.bodySmall),
              const Spacer(),
              Text(
                '−${((_cuts[e.key] ?? 0) * 100).round()}% '
                '(+${formatRupees(e.value * (_cuts[e.key] ?? 0))}/mo)',
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ]),
            Slider(
              value: _cuts[e.key] ?? 0,
              min: 0,
              max: 0.5,
              divisions: 10,
              onChanged: (v) => setState(() => _cuts[e.key] = v),
            ),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.mint.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              extra <= 0
                  ? 'Buy in ≈ $baseMonths month${baseMonths == 1 ? '' : 's'} '
                      '— drag a slider to speed that up.'
                  : 'Buy in ≈ $baseMonths mo → '
                      '$simMonths mo, saving '
                      '${formatRupees(widget.monthlySaving + extra)}/mo.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
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
          Icon(Icons.shopping_bag_outlined,
              size: 56, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text('No goals yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text(
            'Add something you want to buy — a bike, a TV, an AC — and the '
            'coach will price it and tell you how long it will take to save for.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
