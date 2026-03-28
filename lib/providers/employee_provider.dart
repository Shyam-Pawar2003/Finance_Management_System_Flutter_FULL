import 'dart:async';

import 'package:flutter/material.dart';

import '../models/employee_model.dart';
import '../services/firebase_service.dart';

class EmployeeProvider extends ChangeNotifier {
  EmployeeProvider(this._firebaseService);

  final FirebaseService _firebaseService;

  final List<EmployeeModel> _employees = [];
  StreamSubscription<List<EmployeeModel>>? _subscription;
  String? _activeUserId;
  bool _isLoading = false;
  String? _errorMessage;

  List<EmployeeModel> get employees => List.unmodifiable(_employees);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void bindToUser(String? userId) {
    if (_activeUserId == userId) return;

    _subscription?.cancel();
    _activeUserId = userId;
    _employees.clear();
    _errorMessage = null;

    if (userId == null) {
      notifyListeners();
      return;
    }

    _setLoading(true);
    _subscription = _firebaseService.streamEmployees(userId).listen(
      (items) {
        _employees
          ..clear()
          ..addAll(items);
        _errorMessage = null;
        _setLoading(false);
      },
      onError: (_) {
        _errorMessage = 'Unable to load employees.';
        _setLoading(false);
      },
    );
  }

  Future<void> addEmployee(EmployeeModel employee) async {
    final userId = _activeUserId;
    if (userId == null) return;

    try {
      await _firebaseService.upsertEmployee(userId: userId, employee: employee);
    } catch (_) {
      _errorMessage = 'Failed to add employee.';
      notifyListeners();
    }
  }

  Future<void> deleteEmployee(String employeeId) async {
    final userId = _activeUserId;
    if (userId == null) return;

    try {
      await _firebaseService.deleteEmployee(
          userId: userId, employeeId: employeeId);
    } catch (_) {
      _errorMessage = 'Failed to remove employee.';
      notifyListeners();
    }
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
}
