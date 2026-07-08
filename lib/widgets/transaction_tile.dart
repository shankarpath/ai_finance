import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/categories.dart';
import '../providers/app_providers.dart';
import '../services/database_service.dart';
import '../utils/formatters.dart';
import 'category_picker.dart';

/// A single transaction row. Tapping it opens a category picker so the user can
/// correct the category — which is remembered for that merchant going forward.
class TransactionTile extends ConsumerWidget {
  final Transaction txn;
  const TransactionTile({super.key, required this.txn});

  String get _displayMerchant => txn.merchantCanonical ?? txn.merchant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = AppCategory.colorFor(txn.category);
    final isDebit = txn.transactionType == 'debit';
    final notPosted = txn.status != 'posted';
    final sign = isDebit ? '-' : '+';
    final amountColor = notPosted
        ? theme.disabledColor
        : isDebit
            ? theme.colorScheme.onSurface
            : const Color(0xFF37B24D);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      onTap: () => _openPicker(context, ref),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: notPosted ? 0.06 : 0.15),
        child: Icon(AppCategory.iconFor(txn.category),
            color: notPosted ? theme.disabledColor : color, size: 20),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              _displayMerchant,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: notPosted ? theme.disabledColor : null,
              ),
            ),
          ),
          if (notPosted)
            _StatusChip(
              label: txn.status == 'failed' ? 'FAILED' : 'REVERSED',
              color: txn.status == 'failed'
                  ? theme.colorScheme.error
                  : const Color(0xFFFFA94D),
            ),
          if (txn.needsReview && !notPosted)
            const _StatusChip(label: 'REVIEW', color: Color(0xFF4DABF7)),
          if (txn.isSubscription)
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(Icons.autorenew, size: 14, color: Color(0xFF845EF7)),
            ),
        ],
      ),
      subtitle: Text(
        '${txn.category} • ${formatDateTime(txn.date)}'
        '${txn.paymentMethod != null ? ' • ${txn.paymentMethod}' : ''}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        '$sign${formatRupeesPrecise(txn.amount)}',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: amountColor,
          decoration: notPosted ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context, WidgetRef ref) async {
    final chosen = await showCategoryPicker(
      context,
      merchant: _displayMerchant,
      current: txn.category,
    );
    if (chosen != null && chosen != txn.category) {
      await ref
          .read(transactionRepositoryProvider)
          .setUserCategory(_displayMerchant, chosen);
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 9, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
