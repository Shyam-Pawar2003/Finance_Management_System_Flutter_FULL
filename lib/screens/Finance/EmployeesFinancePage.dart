import 'package:flutter/material.dart';

class EmployeesFinancePage extends StatelessWidget {
  const EmployeesFinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final employees = [
      {
        'id': 'EMP-001',
        'name': 'John Doe',
        'email': 'john@company.com',
        'dept': 'Finance',
        'salary': 5000.00
      },
      {
        'id': 'EMP-002',
        'name': 'Jane Smith',
        'email': 'jane@company.com',
        'dept': 'Accounting',
        'salary': 4500.00
      },
      {
        'id': 'EMP-003',
        'name': 'Mike Johnson',
        'email': 'mike@company.com',
        'dept': 'Finance',
        'salary': 6000.00
      },
      {
        'id': 'EMP-004',
        'name': 'Sarah Williams',
        'email': 'sarah@company.com',
        'dept': 'HR',
        'salary': 5500.00
      },
      {
        'id': 'EMP-005',
        'name': 'Tom Brown',
        'email': 'tom@company.com',
        'dept': 'Operations',
        'salary': 4800.00
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Employees',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final emp = employees[index];
                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          emp['name'].toString().split(' ')[0][0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(emp['name'].toString()),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(emp['email'].toString(),
                              style: const TextStyle(fontSize: 12)),
                          Text(emp['dept'].toString(),
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                      trailing: Text(
                        '\$${emp['salary']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (index < employees.length - 1) const Divider(height: 1),
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
