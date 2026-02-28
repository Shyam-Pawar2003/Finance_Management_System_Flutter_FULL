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

  factory TransactionModel.fromMap(Map<String, dynamic> m) => TransactionModel(
        id: m['id'] as String,
        title: m['title'] as String,
        amount: (m['amount'] as num).toDouble(),
        type: m['type'] as String,
        category: m['category'] as String,
        date: DateTime.parse(m['date'] as String),
      );
}
