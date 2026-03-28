import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService) {
    _authSubscription = _authService.authStateChanges.listen((_) {
      notifyListeners();
    });
  }

  final AuthService _authService;
  late final StreamSubscription<User?> _authSubscription;

  bool _isLoading = false;
  String? _errorMessage;
  bool _demoLoggedIn = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _authService.currentUser;
  bool get isLoggedIn => currentUser != null || _demoLoggedIn;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.loginWithEmailPassword(
        email: email.trim(),
        password: password,
      );
      await _authService.ensureUserDocument();
      return true;
    } on FirebaseAuthException catch (e) {
      if (_shouldUseDebugWebFallback(e)) {
        _demoLoggedIn = true;
        _errorMessage = null;
        notifyListeners();
        return true;
      }
      _errorMessage = _mapAuthError(e);
      return false;
    } catch (_) {
      _errorMessage = 'Login failed. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.registerWithEmailPassword(
        fullName: fullName.trim(),
        email: email.trim(),
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      if (_shouldUseDebugWebFallback(e)) {
        _errorMessage = null;
        return true;
      }
      _errorMessage = _mapAuthError(e);
      return false;
    } catch (_) {
      _errorMessage = 'Registration failed. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      if (_demoLoggedIn) {
        _demoLoggedIn = false;
      } else {
        await _authService.signOut();
      }
    } catch (_) {
      _errorMessage = 'Unable to logout right now.';
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _shouldUseDebugWebFallback(FirebaseAuthException e) {
    if (!kDebugMode || !kIsWeb) return false;
    return e.code == 'configuration-not-found' ||
        e.code == 'operation-not-allowed';
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase Authentication.';
      case 'configuration-not-found':
        final host = Uri.base.host.isEmpty ? 'localhost' : Uri.base.host;
        return 'Firebase Auth configuration not found. Enable Email/Password sign-in in Firebase Console and add $host (and localhost, 127.0.0.1) to Authorized domains.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'user-token-expired':
        return 'Session expired. Please login again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        final details = (e.message ?? '').trim();
        if (details.isEmpty || details.toLowerCase() == 'error') {
          return 'Authentication failed (${e.code}).';
        }
        return 'Authentication failed (${e.code}): $details';
    }
  }
}
