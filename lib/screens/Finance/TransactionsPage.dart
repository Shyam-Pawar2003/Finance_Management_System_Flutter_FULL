import 'package:flutter/material.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final List<Map<String, dynamic>> transactions = [
    {
      'id': 'TRX-001',
      'date': '2026-02-25',
      'desc': 'Invoice Payment',
      'amount': 5200.00,
      'type': 'income'
    },
    {
      'id': 'TRX-002',
      'date': '2026-02-25',
      'desc': 'Office Supplies',
      'amount': 450.00,
      'type': 'expense'
    },
    {
      'id': 'TRX-003',
      'date': '2026-02-24',
      'desc': 'Service Income',
      'amount': 3800.00,
      'type': 'income'
    },
    {
      'id': 'TRX-004',
      'date': '2026-02-24',
      'desc': 'Internet Bill',
      'amount': 120.00,
      'type': 'expense'
    },
    {
      'id': 'TRX-005',
      'date': '2026-02-23',
      'desc': 'Consulting Fee',
      'amount': 2500.00,
      'type': 'income'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transactions',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final txn = transactions[index];
                final isIncome = txn['type'] == 'income';
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        isIncome ? Icons.add_circle : Icons.remove_circle,
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                      title: Text(txn['desc'].toString()),
                      subtitle: Text(
                          '${txn['id'].toString()} • ${txn['date'].toString()}'),
                      trailing: Text(
                        '${isIncome ? '+' : '-'}\$${txn['amount']}',
                        style: TextStyle(
                          color: isIncome ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (index < transactions.length - 1)
                      const Divider(height: 1),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
