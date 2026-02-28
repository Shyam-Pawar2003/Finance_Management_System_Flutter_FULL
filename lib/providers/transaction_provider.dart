import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import 'budget_provider.dart';

class TransactionProvider extends ChangeNotifier {
  final List<TransactionModel> _transactions = [];
  BudgetProvider? _budgetProvider;

  void registerBudgetProvider(BudgetProvider p) {
    _budgetProvider = p;
  }

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  void addTransaction(TransactionModel t) {
    _transactions.insert(0, t);
    // update budget spent amount if budget provider available
    if (_budgetProvider != null && t.type == 'expense') {
      _budgetProvider!.addSpent(t.category, t.amount);
    }
    notifyListeners();
  }

  double get totalIncome => _transactions
      .where((t) => t.type == 'income')
      .fold(0.0, (s, t) => s + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == 'expense')
      .fold(0.0, (s, t) => s + t.amount);

  double get balance => totalIncome - totalExpense;
}
