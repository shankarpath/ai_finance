import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/categories.dart';
import '../providers/app_providers.dart';
import '../services/database_service.dart';
import '../widgets/transaction_tile.dart';

/// Full transaction history with search and filters.
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _query = '';
  String? _category; // null = all
  bool _debitsOnly = false;

  List<Transaction> _filter(List<Transaction> txns) {
    final q = _query.trim().toLowerCase();
    return txns.where((t) {
      if (_debitsOnly && t.transactionType != 'debit') return false;
      if (_category != null && t.category != _category) return false;
      if (q.isEmpty) return true;
      final merchant = (t.merchantCanonical ?? t.merchant).toLowerCase();
      return merchant.contains(q) ||
          t.category.toLowerCase().contains(q) ||
          (t.paymentMethod?.toLowerCase().contains(q) ?? false) ||
          (t.referenceNo?.contains(q) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(allTransactionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('All transactions')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search merchant, category, reference…',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                FilterChip(
                  label: const Text('Spending only'),
                  selected: _debitsOnly,
                  onSelected: (v) => setState(() => _debitsOnly = v),
                ),
                const SizedBox(width: 8),
                for (final c in AppCategory.all) ...[
                  FilterChip(
                    label: Text(c),
                    selected: _category == c,
                    avatar: Icon(AppCategory.iconFor(c),
                        size: 16, color: AppCategory.colorFor(c)),
                    onSelected: (v) =>
                        setState(() => _category = v ? c : null),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Could not load: $e')),
              data: (txns) {
                final filtered = _filter(txns);
                if (filtered.isEmpty) {
                  return Center(
                    child: Text('No matching transactions.',
                        style: theme.textTheme.bodyMedium),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) =>
                      TransactionTile(txn: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
