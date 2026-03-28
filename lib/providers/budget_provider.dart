import 'package:flutter/material.dart';
import 'dart:async';

import '../models/budget_model.dart';
import '../services/firebase_service.dart';

class BudgetProvider extends ChangeNotifier {
  BudgetProvider(this._firebaseService);

  final FirebaseService _firebaseService;
  final List<BudgetModel> _budgets = [];
  StreamSubscription<List<BudgetModel>>? _subscription;
  String? _activeUserId;

  String? _errorMessage;
  bool _isLoading = false;

  List<BudgetModel> get budgets => List.unmodifiable(_budgets);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  String? get activeUserId => _activeUserId;

  void bindToUser(String? userId) {
    if (_activeUserId == userId) return;

    _subscription?.cancel();
    _activeUserId = userId;
    _budgets.clear();
    _errorMessage = null;

    if (userId == null) {
      notifyListeners();
      return;
    }

    _setLoading(true);
    _subscription = _firebaseService.streamBudgets(userId).listen(
      (items) {
        _budgets
          ..clear()
          ..addAll(items);
        _errorMessage = null;
        _setLoading(false);
      },
      onError: (_) {
        _errorMessage = 'Unable to load budgets.';
        _setLoading(false);
      },
    );
  }

  Future<bool> addOrUpdateBudget(BudgetModel b) async {
    if (_activeUserId == null) {
      _errorMessage = 'You must be logged in to save budgets.';
      notifyListeners();
      return false;
    }

    final idx = _budgets.indexWhere((x) => x.category == b.category);
    if (idx >= 0) {
      _budgets[idx].monthlyLimit = b.monthlyLimit;
    } else {
      _budgets.add(b);
    }

    try {
      await _firebaseService.upsertBudget(userId: _activeUserId!, budget: b);
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Failed to save budget.';
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<void> addSpent(String category, double amount) async {
    final idx = _budgets.indexWhere((x) => x.category == category);
    if (idx >= 0) {
      _budgets[idx].spentAmount += amount;
      notifyListeners();
    }

    if (_activeUserId == null) return;

    try {
      await _firebaseService.addSpentToBudget(
        userId: _activeUserId!,
        category: category,
        amount: amount,
      );
    } catch (_) {
      _errorMessage = 'Failed to update spent amount in cloud.';
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
