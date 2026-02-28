import 'package:flutter/material.dart';

class PayrollPage extends StatelessWidget {
  const PayrollPage({super.key});

  @override
  Widget build(BuildContext context) {
    final payroll = [
      {
        'id': 'EMP-001',
        'name': 'John Doe',
        'salary': 5000.00,
        'status': 'Paid'
      },
      {
        'id': 'EMP-002',
        'name': 'Jane Smith',
        'salary': 4500.00,
        'status': 'Pending'
      },
      {
        'id': 'EMP-003',
        'name': 'Mike Johnson',
        'salary': 6000.00,
        'status': 'Paid'
      },
      {
        'id': 'EMP-004',
        'name': 'Sarah Williams',
        'salary': 5500.00,
        'status': 'Paid'
      },
      {
        'id': 'EMP-005',
        'name': 'Tom Brown',
        'salary': 4800.00,
        'status': 'Pending'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payroll',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Payroll (This Month)',
                      style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  const Text('\$25,800',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue)),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Process Payroll'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              itemCount: payroll.length,
              itemBuilder: (context, index) {
                final emp = payroll[index];
                final isPaid = emp['status'] == 'Paid';
                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        child: Text(emp['name'].toString().split(' ')[0][0]),
                      ),
                      title: Text(emp['name'].toString()),
                      subtitle: Text(emp['id'].toString()),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${emp['salary']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPaid
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              emp['status'].toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: isPaid ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < payroll.length - 1) const Divider(height: 1),
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
