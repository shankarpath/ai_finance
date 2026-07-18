import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/categories.dart';
import '../providers/app_providers.dart';
import '../services/database_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// "Message health" diagnostics: proves nothing is dropped. Shows the last scan
/// tally, the never-drop review queue, and lets the user turn queued messages
/// into transactions (or dismiss them) — plus add a transaction by hand.
class DiagnosticsScreen extends ConsumerWidget {
  const DiagnosticsScreen({super.key});

  static String _reasonLabel(String reason) => switch (reason) {
        'needsType' || 'needs_type' => 'Couldn\'t tell debit vs credit',
        'needsAmount' || 'needs_amount' => 'No amount found',
        'needsStructure' ||
        'needs_structure' =>
          'No account / reference to confirm it',
        'unknownSender' => 'Looks like a transaction, unknown sender',
        _ => 'Needs review',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final queue = ref.watch(needsAttentionProvider);
    final lastScan = ref.watch(lastScanProvider);
    final txnCount =
        (ref.watch(allTransactionsProvider).value ?? const []).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Message health')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addManual(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add manually'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          lastScan.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (s) => _TallyCard(summary: s, txnCount: txnCount),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Text('Needs attention',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 4),
          Text(
            'Bank messages we couldn\'t read automatically. Nothing here was '
            'dropped — resolve or dismiss each one.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          queue.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Could not load: $e'),
            data: (rows) => rows.isEmpty
                ? _AllClear()
                : Column(
                    children: [
                      for (final r in rows)
                        _QueueTile(
                          row: r,
                          reason: _reasonLabel(r.reason),
                          onResolve: () => _resolve(context, ref, r),
                          onDismiss: () =>
                              ref.read(transactionRepositoryProvider)
                                  .dismissUnparsed(r.id),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _addManual(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<_TxnDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _TxnEditorSheet(title: 'Add transaction'),
    );
    if (result != null) {
      await ref.read(transactionRepositoryProvider).addManualTransaction(
            amount: result.amount,
            transactionType: result.type,
            merchant: result.merchant,
            category: result.category,
            date: result.date,
          );
    }
  }

  Future<void> _resolve(
      BuildContext context, WidgetRef ref, UnparsedMessage row) async {
    final result = await showModalBottomSheet<_TxnDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _TxnEditorSheet(
        title: 'Add as transaction',
        smsBody: row.body,
        initialDate: row.receivedAt,
      ),
    );
    if (result != null) {
      await ref.read(transactionRepositoryProvider).resolveUnparsed(
            row,
            amount: result.amount,
            transactionType: result.type,
            merchant: result.merchant,
            category: result.category,
          );
    }
  }
}

class _TallyCard extends StatelessWidget {
  final ScanSummary summary;
  final int txnCount;
  const _TallyCard({required this.summary, required this.txnCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Panel(
      gradient: AppTheme.heroGradient,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LAST INBOX SCAN',
              style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white54,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(children: [
            _stat(theme, '$txnCount', 'Logged', AppTheme.mint),
            _stat(theme, '${summary.needsAttention}', 'To review',
                AppTheme.amber),
            _stat(theme, '${summary.ignored}', 'Ignored', Colors.white70),
          ]),
          if (summary.at != null) ...[
            const SizedBox(height: 12),
            Text(
              '${summary.scanned} messages scanned · '
              '${formatDateTime(summary.at!)}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.white60),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stat(ThemeData theme, String value, String label, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w900)),
          Text(label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _QueueTile extends StatelessWidget {
  final UnparsedMessage row;
  final String reason;
  final VoidCallback onResolve;
  final VoidCallback onDismiss;
  const _QueueTile({
    required this.row,
    required this.reason,
    required this.onResolve,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Panel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.help_outline, size: 16, color: AppTheme.amber),
            const SizedBox(width: 6),
            Expanded(
              child: Text(reason,
                  style: theme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.amber, fontWeight: FontWeight.w700)),
            ),
            Text(
                row.sender == null || row.sender!.isEmpty
                    ? formatDayMonth(row.receivedAt)
                    : '${row.sender} · ${formatDayMonth(row.receivedAt)}',
                style: theme.textTheme.bodySmall),
          ]),
          const SizedBox(height: 8),
          Text(row.body,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: 10),
          Row(children: [
            FilledButton.tonalIcon(
              onPressed: onResolve,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add transaction'),
            ),
            const Spacer(),
            TextButton(
                onPressed: onDismiss, child: const Text('Not a transaction')),
          ]),
        ],
      ),
      ),
    );
  }
}

class _AllClear extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(children: [
        const Icon(Icons.verified_outlined, size: 52, color: AppTheme.mint),
        const SizedBox(height: 12),
        Text('All caught up', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text('Every bank message has been accounted for.',
            style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
      ]),
    );
  }
}

/// The values produced by the transaction editor sheet.
class _TxnDraft {
  final double amount;
  final String type;
  final String merchant;
  final String category;
  final DateTime date;
  const _TxnDraft(this.amount, this.type, this.merchant, this.category,
      this.date);
}

/// Shared editor for manual entry and queue repair. Shows the original SMS when
/// resolving a queued message, to make the fields easy to fill in.
class _TxnEditorSheet extends StatefulWidget {
  final String title;
  final String? smsBody;
  final DateTime? initialDate;
  const _TxnEditorSheet({
    required this.title,
    this.smsBody,
    this.initialDate,
  });

  @override
  State<_TxnEditorSheet> createState() => _TxnEditorSheetState();
}

class _TxnEditorSheetState extends State<_TxnEditorSheet> {
  final _amount = TextEditingController();
  final _merchant = TextEditingController();
  String _type = 'debit';
  String _category = AppCategory.food;
  late DateTime _date = widget.initialDate ?? DateTime.now();

  static const _categories = AppCategory.all;

  @override
  void dispose() {
    _amount.dispose();
    _merchant.dispose();
    super.dispose();
  }

  void _save() {
    final amount = double.tryParse(_amount.text.trim()) ?? 0;
    if (amount <= 0) return;
    Navigator.pop(
      context,
      _TxnDraft(amount, _type, _merchant.text.trim(), _category, _date),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            if (widget.smsBody != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(widget.smsBody!,
                    style: theme.textTheme.bodySmall),
              ),
            ],
            const SizedBox(height: 14),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'debit', label: Text('Spent')),
                ButtonSegment(value: 'credit', label: Text('Received')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _amount,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                  labelText: 'Amount', prefixText: '₹ ',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _merchant,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                  labelText: 'Merchant / who', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                  labelText: 'Category', border: OutlineInputBorder()),
              items: [
                for (final c in _categories)
                  DropdownMenuItem(
                    value: c,
                    child: Row(children: [
                      Icon(AppCategory.iconFor(c),
                          size: 18, color: AppCategory.colorFor(c)),
                      const SizedBox(width: 8),
                      Text(c),
                    ]),
                  ),
              ],
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
              icon: const Icon(Icons.event),
              label: Text(formatDayMonth(_date)),
            ),
            const SizedBox(height: 16),
            Row(children: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              const Spacer(),
              FilledButton(onPressed: _save, child: const Text('Save')),
            ]),
          ],
        ),
      ),
    );
  }
}
