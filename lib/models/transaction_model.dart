import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type; // 'income' or 'expense'
  final String category;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type,
        'category': category,
        'date': date.toIso8601String(),
      };

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'amount': amount,
        'type': type,
        'category': category,
        'date': Timestamp.fromDate(date),
      };

  factory TransactionModel.fromMap(Map<String, dynamic> m) => TransactionModel(
        id: m['id'] as String,
        title: m['title'] as String,
        amount: (m['amount'] as num).toDouble(),
        type: m['type'] as String,
        category: m['category'] as String,
        date: DateTime.parse(m['date'] as String),
      );

  factory TransactionModel.fromFirestore(String id, Map<String, dynamic> m) {
    final dynamic rawDate = m['date'];

    return TransactionModel(
      id: id,
      title: (m['title'] ?? '') as String,
      amount: ((m['amount'] ?? 0) as num).toDouble(),
      type: (m['type'] ?? 'expense') as String,
      category: (m['category'] ?? 'General') as String,
      date: rawDate is Timestamp
          ? rawDate.toDate()
          : DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
