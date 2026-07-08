import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/categories.dart';
import '../providers/app_providers.dart';
import '../services/database_service.dart';
import '../utils/formatters.dart';
import '../widgets/category_picker.dart';

/// Low-confidence categorizations waiting for the user's confirmation —
/// the "never silently guess" queue. Confirming or correcting an item also
/// teaches the merchant memory, so the same payee never comes back here.
class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(reviewQueueProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Review transactions')),
      body: queue.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_outlined,
                      size: 56, color: Color(0xFF37B24D)),
                  const SizedBox(height: 12),
                  const Text('All caught up!'),
                  const SizedBox(height: 4),
                  Text(
                    'Uncertain categorizations will appear here.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: queue.length,
              itemBuilder: (context, i) => _ReviewCard(txn: queue[i]),
            ),
    );
  }
}

class _ReviewCard extends ConsumerWidget {
  final Transaction txn;
  const _ReviewCard({required this.txn});

  String get _merchant => txn.merchantCanonical ?? txn.merchant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = AppCategory.colorFor(txn.category);
    final isDebit = txn.transactionType == 'debit';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _merchant,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '${isDebit ? '-' : '+'}${formatRupeesPrecise(txn.amount)}',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${formatDateTime(txn.date)}'
              '${txn.paymentMethod != null ? ' • ${txn.paymentMethod}' : ''}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(AppCategory.iconFor(txn.category), size: 16, color: color),
                const SizedBox(width: 5),
                Text(txn.category,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600, color: color)),
                const SizedBox(width: 6),
                Text(
                  '${txn.confidence ?? 0}% sure',
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _change(context, ref),
                  child: const Text('Change'),
                ),
                FilledButton.tonal(
                  onPressed: () =>
                      ref.read(transactionRepositoryProvider).confirmReview(txn),
                  child: const Text('Correct'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _change(BuildContext context, WidgetRef ref) async {
    final chosen = await showCategoryPicker(
      context,
      merchant: _merchant,
      current: txn.category,
    );
    if (chosen == null) return;
    await ref.read(transactionRepositoryProvider).correctReview(txn, chosen);
  }
}
