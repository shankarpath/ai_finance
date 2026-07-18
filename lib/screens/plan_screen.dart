import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/categories.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/coach_widgets.dart';

/// Interactive AI plan builder: the coach drafts a monthly budget from recent
/// history, the user tweaks each category with a live slider, sees projected
/// savings update in real time, and applies the whole plan at once.
class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  /// category → proposed monthly limit (₹). Mutated live by the sliders.
  final Map<String, double> _limits = {};
  bool _loading = true;
  bool _fromAi = false;
  bool _refining = false;
  bool _edited = false;
  bool _setGoal = true;

  double _monthlyIncome = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(_generate);
  }

  /// Seeds instantly from local 3-month averages so the screen is interactive
  /// right away, then refines with the AI suggestion in the background (with a
  /// timeout) — never blocking the UI on the network.
  Future<void> _generate() async {
    final cap = ref.read(savingsCapacityProvider);
    final local = _localAverages();
    setState(() {
      _monthlyIncome = cap.monthlyIncome;
      _limits
        ..clear()
        ..addAll(local.map((k, v) => MapEntry(k, _round(v))));
      _fromAi = false;
      _edited = false;
      _loading = false;
      _refining = true;
    });

    Map<String, double> ai = const {};
    try {
      ai = await ref
          .read(coachServiceProvider)
          .suggestBudgets()
          .timeout(const Duration(seconds: 25));
    } catch (_) {
      // Keep the local draft on timeout/failure/no-key.
    }
    if (!mounted) return;
    setState(() {
      _refining = false;
      // Only let AI overwrite the draft if the user hasn't started tweaking.
      if (ai.isNotEmpty && !_edited) {
        _limits
          ..clear()
          ..addAll(ai.map((k, v) => MapEntry(k, _round(v))));
        _fromAi = true;
      }
    });
  }

  /// Average monthly spend per (discretionary) category over the last 3 months.
  Map<String, double> _localAverages() {
    final txns = ref.read(allTransactionsProvider).value ?? const [];
    final now = DateTime.now();
    final since = DateTime(now.year, now.month - 3, 1);
    final totals = <String, double>{};
    for (final t in txns) {
      if (t.transactionType != 'debit' || t.status != 'posted') continue;
      if (t.date.isBefore(since)) continue;
      if (AppCategory.isIncome(t.category)) continue;
      if (t.category == AppCategory.transfer) continue;
      totals.update(t.category, (v) => v + t.amount, ifAbsent: () => t.amount);
    }
    return totals.map((k, v) => MapEntry(k, _round(v / 3)));
  }

  double get _budgeted =>
      _limits.values.fold<double>(0, (s, v) => s + v);

  double get _projectedSavings => _monthlyIncome - _budgeted;

  Future<void> _apply() async {
    final db = ref.read(databaseProvider);
    var applied = 0;
    for (final e in _limits.entries) {
      if (e.value > 0) {
        await db.setBudget(e.key, e.value);
        applied++;
      } else {
        await db.removeBudget(e.key);
      }
    }
    if (_setGoal && _monthlyIncome > 0 && _projectedSavings > 0) {
      await ref
          .read(settingsServiceProvider)
          .setMonthlySavingsGoal(_round(_projectedSavings));
      ref.invalidate(savingsGoalProvider);
    }
    ref.invalidate(coachBriefingProvider);
    ref.invalidate(insightCardProvider);
    ref.invalidate(budgetInsightProvider);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Plan applied — $applied budgets set.')),
    );
    Navigator.of(context).pop();
  }

  Future<void> _addCategory() async {
    final present = _limits.keys.toSet();
    final options = AppCategory.all
        .where((c) =>
            !AppCategory.isIncome(c) &&
            c != AppCategory.others &&
            !present.contains(c))
        .toList();
    if (options.isEmpty) return;
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final c in options)
              ListTile(
                leading: Icon(AppCategory.iconFor(c),
                    color: AppCategory.colorFor(c)),
                title: Text(c),
                onTap: () => Navigator.pop(context, c),
              ),
          ],
        ),
      ),
    );
    if (picked != null) {
      setState(() {
        _limits[picked] = 1000;
        _edited = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = _limits.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI plan'),
        actions: [
          IconButton(
            tooltip: 'Regenerate',
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _generate,
          ),
        ],
      ),
      bottomNavigationBar: _loading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton.icon(
                  onPressed: _limits.isEmpty ? null : _apply,
                  icon: const Icon(Icons.check),
                  label: Text('Apply plan (${_limits.length} budgets)'),
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48)),
                ),
              ),
            ),
      body: _loading
          ? const _Generating()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: [
                _ProjectionCard(
                  income: _monthlyIncome,
                  budgeted: _budgeted,
                  savings: _projectedSavings,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _refining
                      ? Row(children: [
                          const SizedBox(
                              width: 13,
                              height: 13,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Drafted from your last 3 months — the coach is '
                              'refining it…',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ])
                      : Text(
                          _fromAi
                              ? 'The coach tuned this from your last 3 months — '
                                  'drag to tweak, then apply.'
                              : 'Drafted from your last 3 months of spending — '
                                  'drag to tweak, then apply.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                ),
                for (final e in entries)
                  _CategorySlider(
                    category: e.key,
                    value: e.value,
                    onChanged: (v) => setState(() {
                      _limits[e.key] = v;
                      _edited = true;
                    }),
                    onRemove: () => setState(() {
                      _limits.remove(e.key);
                      _edited = true;
                    }),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _addCategory,
                  icon: const Icon(Icons.add),
                  label: const Text('Add a category'),
                ),
                if (_monthlyIncome > 0 && _projectedSavings > 0) ...[
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _setGoal,
                    onChanged: (v) => setState(() => _setGoal = v),
                    title: const Text('Also set my monthly savings goal'),
                    subtitle: Text(
                        'To ${formatRupees(_round(_projectedSavings))}/month'),
                  ),
                ],
              ],
            ),
    );
  }

  double _round(double v) => (v / 100).round() * 100;
}

/// Live projection: income vs budgeted vs savings, colour-coded.
class _ProjectionCard extends StatelessWidget {
  final double income;
  final double budgeted;
  final double savings;
  const _ProjectionCard(
      {required this.income, required this.budgeted, required this.savings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final over = income > 0 && savings < 0;
    return Panel(
      gradient: over ? AppTheme.dangerGradient : AppTheme.heroGradient,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MONTHLY PLAN',
              style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white54,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _row(theme, 'Budgeted', formatRupees(budgeted), Colors.white),
          if (income > 0) ...[
            _row(theme, 'Est. monthly income', formatRupees(income),
                Colors.white70),
            const Divider(height: 18, color: Colors.white24),
            _row(
              theme,
              over ? 'Over income by' : 'Projected savings',
              formatRupees(savings.abs()),
              over ? AppTheme.coral : AppTheme.mint,
              bold: true,
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Add more income history to see projected savings.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.white60)),
            ),
        ],
      ),
    );
  }

  Widget _row(ThemeData theme, String label, String value, Color color,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Expanded(
          child: Text(label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
        ),
        Text(value,
            style: (bold
                    ? theme.textTheme.titleMedium
                    : theme.textTheme.bodyLarge)
                ?.copyWith(color: color, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

class _CategorySlider extends StatelessWidget {
  final String category;
  final double value;
  final ValueChanged<double> onChanged;
  final VoidCallback onRemove;

  const _CategorySlider({
    required this.category,
    required this.value,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppCategory.colorFor(category);
    // A sensible slider ceiling: well above the seeded value, rounded.
    final max = (value <= 0 ? 5000.0 : value * 2.5)
        .clamp(2000.0, 100000.0)
        .toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(AppCategory.iconFor(category), size: 18, color: color),
            const SizedBox(width: 8),
            Text(category,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            Text(formatRupees(value),
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800, color: color)),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close, size: 18),
              onPressed: onRemove,
              tooltip: 'Remove',
            ),
          ]),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.15),
            ),
            child: Slider(
              value: value.clamp(0, max),
              min: 0,
              max: max,
              divisions: (max / 100).round(),
              label: formatRupees(value),
              onChanged: (v) => onChanged((v / 100).round() * 100),
            ),
          ),
        ],
      ),
    );
  }
}

class _Generating extends StatelessWidget {
  const _Generating();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 10),
          Text('Coach is drafting your plan…',
              style: Theme.of(context).textTheme.bodyMedium),
        ]),
        const SizedBox(height: 16),
        const SkeletonBox(height: 120),
        const SizedBox(height: 12),
        for (var i = 0; i < 5; i++) ...[
          const SkeletonBox(height: 52),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
