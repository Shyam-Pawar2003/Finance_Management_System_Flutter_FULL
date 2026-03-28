import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory AppNotification.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final rawCreated = data['createdAt'];
    return AppNotification(
      id: id,
      title: (data['title'] ?? 'Notification').toString(),
      message: (data['message'] ?? '').toString(),
      type: (data['type'] ?? 'general').toString(),
      isRead: (data['isRead'] ?? false) as bool,
      createdAt: rawCreated is Timestamp
          ? rawCreated.toDate()
          : DateTime.tryParse(rawCreated?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
