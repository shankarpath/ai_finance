import 'package:flutter/material.dart';

import '../models/categories.dart';

/// Bottom-sheet category chooser. Returns the picked category via
/// `Navigator.pop`, or null when dismissed.
Future<String?> showCategoryPicker(
  BuildContext context, {
  required String merchant,
  required String current,
}) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => CategoryPickerSheet(merchant: merchant, current: current),
  );
}

class CategoryPickerSheet extends StatelessWidget {
  final String merchant;
  final String current;
  const CategoryPickerSheet(
      {super.key, required this.merchant, required this.current});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Cap the sheet so it can't exceed ~70% of the screen; the chips scroll.
    final maxHeight = MediaQuery.of(context).size.height * 0.7;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Categorize “$merchant”',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                  'Applied to all transactions from this merchant, and remembered.',
                  style: theme.textTheme.bodySmall),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in AppCategory.all)
                        ChoiceChip(
                          label: Text(c),
                          selected: c == current,
                          avatar: Icon(AppCategory.iconFor(c),
                              size: 18, color: AppCategory.colorFor(c)),
                          onSelected: (_) => Navigator.of(context).pop(c),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
