import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/budget_model.dart';
import '../models/employee_model.dart';
import '../models/notification_model.dart';
import '../models/stock_model.dart';
import '../models/task_model.dart';
import '../models/transaction_model.dart';

class FirebaseService {
  FirebaseService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

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
      await _firestore.collection('users').doc(credential.user!.uid).set(
        {
          'fullName': fullName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    return credential;
  }

  Future<UserCredential> loginWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> ensureUserDocument() async {
    final user = currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set(
      {
        'fullName': user.displayName ?? '',
        'email': user.email ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  CollectionReference<Map<String, dynamic>> _transactionsRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions');
  }

  CollectionReference<Map<String, dynamic>> _budgetsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('budgets');
  }

  CollectionReference<Map<String, dynamic>> _stockAnalysesRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('stock_analyses');
  }

  CollectionReference<Map<String, dynamic>> _notificationsRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications');
  }

  CollectionReference<Map<String, dynamic>> _employeesRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('employees');
  }

  CollectionReference<Map<String, dynamic>> _tasksRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  Stream<List<TransactionModel>> streamTransactions(String userId) {
    return _transactionsRef(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TransactionModel.fromFirestore(doc.id, data);
      }).toList();
    });
  }

  Future<void> addTransaction({
    required String userId,
    required TransactionModel transaction,
  }) async {
    await _transactionsRef(userId)
        .doc(transaction.id)
        .set(transaction.toFirestore());
  }

  Future<void> updateTransaction({
    required String userId,
    required TransactionModel transaction,
  }) async {
    await _transactionsRef(userId)
        .doc(transaction.id)
        .update(transaction.toFirestore());
  }

  Future<void> deleteTransaction({
    required String userId,
    required String transactionId,
  }) async {
    await _transactionsRef(userId).doc(transactionId).delete();
  }

  Stream<List<BudgetModel>> streamBudgets(String userId) {
    return _budgetsRef(userId).orderBy('category').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => BudgetModel.fromMap(doc.data())).toList());
  }

  Future<void> upsertBudget({
    required String userId,
    required BudgetModel budget,
  }) async {
    final docId = budget.category.trim().toLowerCase();
    await _budgetsRef(userId).doc(docId).set(
      {
        ...budget.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> addSpentToBudget({
    required String userId,
    required String category,
    required double amount,
  }) async {
    if (amount <= 0) return;

    final docId = category.trim().toLowerCase();
    final docRef = _budgetsRef(userId).doc(docId);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) {
        tx.set(docRef, {
          'category': category,
          'monthlyLimit': 0.0,
          'spentAmount': amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      final data = snap.data() ?? <String, dynamic>{};
      final current = ((data['spentAmount'] ?? 0) as num).toDouble();
      tx.update(docRef, {
        'spentAmount': current + amount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<StockModel?> streamLatestStockAnalysis(String userId) {
    return _stockAnalysesRef(userId)
        .orderBy('updatedAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return StockModel.fromMap(snapshot.docs.first.data());
    });
  }

  Future<void> upsertStockAnalysis({
    required String userId,
    required StockModel stock,
  }) async {
    final docId = stock.symbol.trim().toUpperCase();
    await _stockAnalysesRef(userId).doc(docId).set(
      {
        ...stock.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Stream<List<AppNotification>> streamNotifications(String userId) {
    return _notificationsRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    String type = 'general',
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

  Future<void> markNotificationAsRead({
    required String userId,
    required String notificationId,
  }) async {
    await _notificationsRef(userId).doc(notificationId).set(
      {
        'isRead': true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> markAllNotificationsAsRead({
    required String userId,
  }) async {
    final unread =
        await _notificationsRef(userId).where('isRead', isEqualTo: false).get();

    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      batch.set(
        doc.reference,
        {
          'isRead': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  Stream<List<EmployeeModel>> streamEmployees(String userId) {
    return _employeesRef(userId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EmployeeModel.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  Future<void> upsertEmployee({
    required String userId,
    required EmployeeModel employee,
  }) async {
    await _employeesRef(userId).doc(employee.id).set(
          employee.toFirestore(),
          SetOptions(merge: true),
        );
  }

  Future<void> deleteEmployee({
    required String userId,
    required String employeeId,
  }) async {
    await _employeesRef(userId).doc(employeeId).delete();
  }

  Stream<List<AppTaskModel>> streamTasks(String userId) {
    return _tasksRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppTaskModel.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  Future<void> upsertTask({
    required String userId,
    required AppTaskModel task,
  }) async {
    await _tasksRef(userId).doc(task.id).set(
          task.toFirestore(),
          SetOptions(merge: true),
        );
  }

  Future<void> updateTaskStatus({
    required String userId,
    required String taskId,
    required String status,
  }) async {
    await _tasksRef(userId).doc(taskId).set(
      {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    await _tasksRef(userId).doc(taskId).delete();
  }
}
