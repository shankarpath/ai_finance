/// A category budget paired with the current month's spend against it.
class BudgetProgress {
  final String category;
  final double limit;
  final double spent;

  const BudgetProgress({
    required this.category,
    required this.limit,
    required this.spent,
  });

  double get remaining => limit - spent;
  double get fraction => limit <= 0 ? 0 : spent / limit;
  bool get isOver => spent > limit;

  /// Near the limit (>= 80%) but not yet over.
  bool get isNear => !isOver && fraction >= 0.8;
}
