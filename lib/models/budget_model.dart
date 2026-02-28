class BudgetModel {
  final String category;
  double monthlyLimit;
  double spentAmount;

  BudgetModel({
    required this.category,
    required this.monthlyLimit,
    this.spentAmount = 0.0,
  });

  double get remainingAmount => monthlyLimit - spentAmount;

  Map<String, dynamic> toMap() => {
        'category': category,
        'monthlyLimit': monthlyLimit,
        'spentAmount': spentAmount,
      };

  factory BudgetModel.fromMap(Map<String, dynamic> m) => BudgetModel(
        category: m['category'] as String,
        monthlyLimit: (m['monthlyLimit'] as num).toDouble(),
        spentAmount: (m['spentAmount'] as num).toDouble(),
      );
}
