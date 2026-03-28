import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
  const EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String department;
  final bool isActive;
  final DateTime createdAt;

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'department': department,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory EmployeeModel.fromFirestore(String id, Map<String, dynamic> map) {
    final rawCreated = map['createdAt'];
    return EmployeeModel(
      id: id,
      name: (map['name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      role: (map['role'] ?? 'Employee').toString(),
      department: (map['department'] ?? 'General').toString(),
      isActive: (map['isActive'] ?? true) as bool,
      createdAt: rawCreated is Timestamp
          ? rawCreated.toDate()
          : DateTime.tryParse(rawCreated?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
