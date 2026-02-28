import 'package:flutter/material.dart';

class InvoicesPage extends StatelessWidget {
  const InvoicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final invoices = [
      {
        'id': 'INV-001',
        'client': 'ABC Corporation',
        'date': '2026-02-20',
        'amount': 5200.00,
        'status': 'Paid'
      },
      {
        'id': 'INV-002',
        'client': 'XYZ Industries',
        'date': '2026-02-18',
        'amount': 3800.00,
        'status': 'Paid'
      },
      {
        'id': 'INV-003',
        'client': 'Tech Solutions',
        'date': '2026-02-15',
        'amount': 4500.00,
        'status': 'Pending'
      },
      {
        'id': 'INV-004',
        'client': 'Global Enterprises',
        'date': '2026-02-10',
        'amount': 6200.00,
        'status': 'Overdue'
      },
      {
        'id': 'INV-005',
        'client': 'Innovation Labs',
        'date': '2026-02-08',
        'amount': 2800.00,
        'status': 'Pending'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Invoices',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Create Invoice'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final inv = invoices[index];
                final statusColor = inv['status'] == 'Paid'
                    ? Colors.green
                    : inv['status'] == 'Pending'
                        ? Colors.orange
                        : Colors.red;
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.receipt_long, color: Colors.blue),
                      title: Text(inv['id'].toString()),
                      subtitle: Text(
                          '${inv['client'].toString()} • ${inv['date'].toString()}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${inv['amount']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              inv['status'].toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < invoices.length - 1) const Divider(height: 1),
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
