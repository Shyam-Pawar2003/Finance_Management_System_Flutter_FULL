import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/employee_model.dart';
import '../providers/employee_provider.dart';
import '../providers/task_provider.dart';
import '../providers/transaction_provider.dart';

class CompanyManagementScreen extends StatefulWidget {
  const CompanyManagementScreen({super.key});

  @override
  State<CompanyManagementScreen> createState() =>
      _CompanyManagementScreenState();
}

class _CompanyManagementScreenState extends State<CompanyManagementScreen> {
  int _selectedIndex = 0;

  final _employeeFormKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _roleCtrl = TextEditingController(text: 'Employee');
  final _departmentCtrl = TextEditingController(text: 'General');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _roleCtrl.dispose();
    _departmentCtrl.dispose();
    super.dispose();
  }

  Future<void> _showAddEmployeeDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Employee'),
          content: Form(
            key: _employeeFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Name required'
                        : null,
                  ),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Email required';
                      if (!v.contains('@')) return 'Enter valid email';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _roleCtrl,
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                  TextFormField(
                    controller: _departmentCtrl,
                    decoration: const InputDecoration(labelText: 'Department'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!_employeeFormKey.currentState!.validate()) return;

                final employee = EmployeeModel(
                  id: const Uuid().v4(),
                  name: _nameCtrl.text.trim(),
                  email: _emailCtrl.text.trim(),
                  role: _roleCtrl.text.trim().isEmpty
                      ? 'Employee'
                      : _roleCtrl.text.trim(),
                  department: _departmentCtrl.text.trim().isEmpty
                      ? 'General'
                      : _departmentCtrl.text.trim(),
                  isActive: true,
                  createdAt: DateTime.now(),
                );

                await context.read<EmployeeProvider>().addEmployee(employee);
                if (!mounted) return;
                Navigator.pop(context);
                _nameCtrl.clear();
                _emailCtrl.clear();
                _roleCtrl.text = 'Employee';
                _departmentCtrl.text = 'General';
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Management'),
      ),
      floatingActionButton: _selectedIndex == 3
          ? FloatingActionButton.extended(
              onPressed: _showAddEmployeeDialog,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add Employee'),
            )
          : null,
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.business), label: 'Projects'),
          BottomNavigationBarItem(
              icon: Icon(Icons.trending_up), label: 'Finance'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Employees'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 1:
        return _buildProjects();
      case 2:
        return _buildFinance();
      case 3:
        return _buildEmployees();
      case 0:
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    final tx = context.watch<TransactionProvider>();
    final tasks = context.watch<TaskProvider>();
    final employees = context.watch<EmployeeProvider>();

    final income = tx.totalIncome;
    final expense = tx.totalExpense;
    final balance = tx.balance;
    final pendingTasks =
        tasks.tasks.where((element) => element.status != 'Completed').length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Company Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _metricTile('Employees', '${employees.employees.length}', Icons.people,
            Colors.indigo),
        _metricTile(
            'Open Tasks', '$pendingTasks', Icons.assignment, Colors.orange),
        _metricTile('Income', 'USD ${income.toStringAsFixed(2)}',
            Icons.trending_up, Colors.green),
        _metricTile('Expense', 'USD ${expense.toStringAsFixed(2)}',
            Icons.trending_down, Colors.red),
        _metricTile('Net Balance', 'USD ${balance.toStringAsFixed(2)}',
            Icons.account_balance_wallet, Colors.blue),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Role Management'),
            subtitle: const Text('Manage user roles and access permissions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).pushNamed('/roles'),
          ),
        ),
      ],
    );
  }

  Widget _buildProjects() {
    final tasks = context.watch<TaskProvider>().tasks;
    final byProject = <String, int>{};
    for (final task in tasks) {
      byProject[task.project] = (byProject[task.project] ?? 0) + 1;
    }

    if (byProject.isEmpty) {
      return const Center(child: Text('No project activity yet.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: byProject.entries
          .map(
            (entry) => Card(
              child: ListTile(
                leading: const Icon(Icons.work_outline),
                title: Text(entry.key),
                subtitle: Text('${entry.value} tasks linked'),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildFinance() {
    final tx = context.watch<TransactionProvider>();
    final incomeTx =
        tx.transactions.where((element) => element.type == 'income').length;
    final expenseTx =
        tx.transactions.where((element) => element.type == 'expense').length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _metricTile('Transactions', '${tx.transactions.length}',
            Icons.receipt_long, Colors.blueGrey),
        _metricTile(
            'Income Entries', '$incomeTx', Icons.call_received, Colors.green),
        _metricTile(
            'Expense Entries', '$expenseTx', Icons.call_made, Colors.red),
        _metricTile('Current Balance', 'USD ${tx.balance.toStringAsFixed(2)}',
            Icons.savings, Colors.teal),
      ],
    );
  }

  Widget _buildEmployees() {
    final provider = context.watch<EmployeeProvider>();
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final employees = provider.employees;
    if (employees.isEmpty) {
      return const Center(child: Text('No employees yet. Add your first one.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                employee.name.isNotEmpty ? employee.name[0].toUpperCase() : 'E',
              ),
            ),
            title: Text(employee.name),
            subtitle: Text(
                '${employee.role} • ${employee.department}\n${employee.email}'),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () =>
                  context.read<EmployeeProvider>().deleteEmployee(employee.id),
            ),
          ),
        );
      },
    );
  }

  Widget _metricTile(String label, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
