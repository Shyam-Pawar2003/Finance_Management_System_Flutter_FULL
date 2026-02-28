import 'package:flutter/material.dart';
import '../models/budget_model.dart';

class BudgetProvider extends ChangeNotifier {
  final List<BudgetModel> _budgets = [];

  List<BudgetModel> get budgets => List.unmodifiable(_budgets);

  void addOrUpdateBudget(BudgetModel b) {
    final idx = _budgets.indexWhere((x) => x.category == b.category);
    if (idx >= 0) {
      _budgets[idx].monthlyLimit = b.monthlyLimit;
    } else {
      _budgets.add(b);
    }
    notifyListeners();
  }

  void addSpent(String category, double amount) {
    final idx = _budgets.indexWhere((x) => x.category == category);
    if (idx >= 0) {
      _budgets[idx].spentAmount += amount;
      notifyListeners();
    }
  }

  bool isExceeded(String category) {
    final b = _budgets.firstWhere((x) => x.category == category,
        orElse: () =>
            BudgetModel(category: category, monthlyLimit: 0, spentAmount: 0));
    return b.spentAmount > b.monthlyLimit;
  }

  bool anyExceeded() => _budgets.any((b) => b.spentAmount > b.monthlyLimit);
}
