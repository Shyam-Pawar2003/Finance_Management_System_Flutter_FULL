import 'dart:async';

import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/firebase_service.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider(this._firebaseService);

  final FirebaseService _firebaseService;

  final List<AppTaskModel> _tasks = [];
  StreamSubscription<List<AppTaskModel>>? _subscription;
  String? _activeUserId;
  bool _isLoading = false;
  String? _errorMessage;

  List<AppTaskModel> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void bindToUser(String? userId) {
    if (_activeUserId == userId) return;

    _subscription?.cancel();
    _activeUserId = userId;
    _tasks.clear();
    _errorMessage = null;

    if (userId == null) {
      notifyListeners();
      return;
    }

    _setLoading(true);
    _subscription = _firebaseService.streamTasks(userId).listen(
      (items) {
        _tasks
          ..clear()
          ..addAll(items);
        _errorMessage = null;
        _setLoading(false);
      },
      onError: (_) {
        _errorMessage = 'Unable to load tasks.';
        _setLoading(false);
      },
    );
  }

  Future<void> addTask(AppTaskModel task) async {
    final userId = _activeUserId;
    if (userId == null) return;

    try {
      await _firebaseService.upsertTask(userId: userId, task: task);
    } catch (_) {
      _errorMessage = 'Failed to create task.';
      notifyListeners();
    }
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    final userId = _activeUserId;
    if (userId == null) return;

    try {
      await _firebaseService.updateTaskStatus(
        userId: userId,
        taskId: taskId,
        status: status,
      );
    } catch (_) {
      _errorMessage = 'Failed to update task status.';
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    final userId = _activeUserId;
    if (userId == null) return;

    try {
      await _firebaseService.deleteTask(userId: userId, taskId: taskId);
    } catch (_) {
      _errorMessage = 'Failed to delete task.';
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
