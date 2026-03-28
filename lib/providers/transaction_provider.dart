import 'package:flutter/material.dart';
import 'dart:async';

import '../models/transaction_model.dart';
import '../services/firebase_service.dart';
import 'budget_provider.dart';

class TransactionProvider extends ChangeNotifier {
  TransactionProvider(this._firebaseService);

  final FirebaseService _firebaseService;

  final List<TransactionModel> _transactions = [];
  StreamSubscription<List<TransactionModel>>? _subscription;
  String? _activeUserId;
  bool _isLoading = false;
  String? _errorMessage;

  BudgetProvider? _budgetProvider;

  void registerBudgetProvider(BudgetProvider p) {
    _budgetProvider = p;
  }

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get activeUserId => _activeUserId;

  Stream<List<TransactionModel>> streamForCurrentUser() {
    final userId = _activeUserId;
    if (userId == null) {
      return const Stream<List<TransactionModel>>.empty();
    }

    return _firebaseService.streamTransactions(userId);
  }

  void bindToUser(String? userId) {
    if (_activeUserId == userId) return;

    _subscription?.cancel();
    _activeUserId = userId;
    _transactions.clear();
    _errorMessage = null;

    if (userId == null) {
      notifyListeners();
      return;
    }

    _setLoading(true);
    _subscription = _firebaseService.streamTransactions(userId).listen(
      (items) {
        _transactions
          ..clear()
          ..addAll(items);
        _errorMessage = null;
        _setLoading(false);
      },
      onError: (_) {
        _errorMessage = 'Unable to load transactions.';
        _setLoading(false);
      },
    );
  }

  Future<bool> addTransaction(TransactionModel t) async {
    if (_activeUserId == null) {
      _errorMessage = 'You must be logged in to add a transaction.';
      notifyListeners();
      return false;
    }

    try {
      await _firebaseService.addTransaction(
          userId: _activeUserId!, transaction: t);
      if (_budgetProvider != null && t.type == 'expense') {
        _budgetProvider!.addSpent(t.category, t.amount);
      }
      return true;
    } catch (_) {
      _errorMessage = 'Failed to save transaction.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction(TransactionModel t) async {
    if (_activeUserId == null) {
      _errorMessage = 'You must be logged in to update a transaction.';
      notifyListeners();
      return false;
    }

    try {
      await _firebaseService.updateTransaction(
          userId: _activeUserId!, transaction: t);
      return true;
    } catch (_) {
      _errorMessage = 'Failed to update transaction.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(String transactionId) async {
    if (_activeUserId == null) {
      _errorMessage = 'You must be logged in to delete a transaction.';
      notifyListeners();
      return false;
    }

    try {
      await _firebaseService.deleteTransaction(
        userId: _activeUserId!,
        transactionId: transactionId,
      );
      return true;
    } catch (_) {
      _errorMessage = 'Failed to delete transaction.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  double get totalIncome => _transactions
      .where((t) => t.type == 'income')
      .fold(0.0, (s, t) => s + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == 'expense')
      .fold(0.0, (s, t) => s + t.amount);

  double get balance => totalIncome - totalExpense;
}
