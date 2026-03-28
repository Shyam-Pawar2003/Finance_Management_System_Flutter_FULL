import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  CollectionReference<Map<String, dynamic>> _authLogsRef(String userId) {
    return _userDoc(userId).collection('auth_logs');
  }

  CollectionReference<Map<String, dynamic>> _notificationsRef(String userId) {
    return _userDoc(userId).collection('notifications');
  }

  Future<void> _logAuthEvent({
    required String userId,
    required String action,
    String? email,
    String? fullName,
  }) async {
    await _authLogsRef(userId).add({
      'action': action,
      'email': email ?? '',
      'fullName': fullName ?? '',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _createInAppNotification({
    required String userId,
    required String title,
    required String message,
    String type = 'auth',
  }) async {
    await _notificationsRef(userId).add({
      'title': title,
      'message': message,
      'type': type,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> registerWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(fullName);

    if (credential.user != null) {
      await _userDoc(credential.user!.uid).set(
        {
          'fullName': fullName,
          'email': email,
          'accountStatus': 'active',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await _logAuthEvent(
        userId: credential.user!.uid,
        action: 'register',
        email: email,
        fullName: fullName,
      );

      await _createInAppNotification(
        userId: credential.user!.uid,
        title: 'Account Created',
        message: 'Welcome $fullName. Your account has been created.',
      );
    }

    return credential;
  }

  Future<UserCredential> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user != null) {
      await _userDoc(user.uid).set(
        {
          'fullName': user.displayName ?? '',
          'email': user.email ?? email,
          'accountStatus': 'active',
          'lastLoginAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await _logAuthEvent(
        userId: user.uid,
        action: 'login',
        email: user.email ?? email,
        fullName: user.displayName,
      );

      await _createInAppNotification(
        userId: user.uid,
        title: 'Login Successful',
        message: 'You logged in successfully.',
      );
    }

    return credential;
  }

  Future<void> signOut() async {
    final user = currentUser;

    if (user != null) {
      await _userDoc(user.uid).set(
        {
          'lastLogoutAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await _logAuthEvent(
        userId: user.uid,
        action: 'logout',
        email: user.email,
        fullName: user.displayName,
      );

      await _createInAppNotification(
        userId: user.uid,
        title: 'Logout Recorded',
        message: 'Your logout activity was recorded securely.',
      );
    }

    await _auth.signOut();
  }

  Future<void> ensureUserDocument() async {
    final user = currentUser;
    if (user == null) return;

    await _userDoc(user.uid).set(
      {
        'fullName': user.displayName ?? '',
        'email': user.email ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
