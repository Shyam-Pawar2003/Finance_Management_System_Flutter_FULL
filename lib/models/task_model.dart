import 'package:cloud_firestore/cloud_firestore.dart';

class AppTaskModel {
  const AppTaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.project,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String assignedTo;
  final String project;
  final String priority;
  final String status;
  final DateTime dueDate;
  final DateTime createdAt;

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'project': project,
      'priority': priority,
      'status': status,
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory AppTaskModel.fromFirestore(String id, Map<String, dynamic> map) {
    final rawDueDate = map['dueDate'];
    final rawCreated = map['createdAt'];

    return AppTaskModel(
      id: id,
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      assignedTo: (map['assignedTo'] ?? '').toString(),
      project: (map['project'] ?? '').toString(),
      priority: (map['priority'] ?? 'Medium').toString(),
      status: (map['status'] ?? 'Pending').toString(),
      dueDate: rawDueDate is Timestamp
          ? rawDueDate.toDate()
          : DateTime.tryParse(rawDueDate?.toString() ?? '') ?? DateTime.now(),
      createdAt: rawCreated is Timestamp
          ? rawCreated.toDate()
          : DateTime.tryParse(rawCreated?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
