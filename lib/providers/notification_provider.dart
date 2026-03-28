import 'dart:async';

import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../services/firebase_service.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider(this._firebaseService);

  final FirebaseService _firebaseService;

  final List<AppNotification> _notifications = [];
  StreamSubscription<List<AppNotification>>? _subscription;
  String? _activeUserId;
  bool _isLoading = false;
  String? _errorMessage;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get activeUserId => _activeUserId;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void bindToUser(String? userId) {
    if (_activeUserId == userId) return;

    _subscription?.cancel();
    _activeUserId = userId;
    _notifications.clear();
    _errorMessage = null;

    if (userId == null) {
      notifyListeners();
      return;
    }

    _setLoading(true);
    _subscription = _firebaseService.streamNotifications(userId).listen(
      (items) {
        _notifications
          ..clear()
          ..addAll(items);
        _errorMessage = null;
        _setLoading(false);
      },
      onError: (_) {
        _errorMessage = 'Unable to load notifications.';
        _setLoading(false);
      },
    );
  }

  Future<void> markAsRead(String notificationId) async {
    final userId = _activeUserId;
    if (userId == null) return;

    try {
      await _firebaseService.markNotificationAsRead(
        userId: userId,
        notificationId: notificationId,
      );
    } catch (_) {
      _errorMessage = 'Failed to update notification.';
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    final userId = _activeUserId;
    if (userId == null) return;

    try {
      await _firebaseService.markAllNotificationsAsRead(userId: userId);
    } catch (_) {
      _errorMessage = 'Failed to mark all notifications as read.';
      notifyListeners();
    }
  }

  Future<void> createNotification({
    required String title,
    required String message,
    String type = 'general',
  }) async {
    final userId = _activeUserId;
    if (userId == null) return;

    try {
      await _firebaseService.createNotification(
        userId: userId,
        title: title,
        message: message,
        type: type,
      );
    } catch (_) {
      _errorMessage = 'Failed to create notification.';
      notifyListeners();
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
}
