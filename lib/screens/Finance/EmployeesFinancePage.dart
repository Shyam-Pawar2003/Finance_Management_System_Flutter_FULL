import 'package:flutter/material.dart';

class EmployeesFinancePage extends StatefulWidget {
  const EmployeesFinancePage({super.key});

  @override
  State<EmployeesFinancePage> createState() => _EmployeesFinancePageState();
}

class _EmployeesFinancePageState extends State<EmployeesFinancePage> {
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  String _selectedStatus = 'All';

  final List<_FinanceEmployee> _employees = const [
    _FinanceEmployee(
      id: 'EMP-001',
      name: 'John Doe',
      email: 'john@company.com',
      department: 'Finance',
      role: 'Senior Analyst',
      monthlySalary: 5000,
      status: 'Active',
      joinDate: '2023-04-11',
      reimbursementDue: 320,
    ),
    _FinanceEmployee(
      id: 'EMP-002',
      name: 'Jane Smith',
      email: 'jane@company.com',
      department: 'Accounting',
      role: 'Accountant',
      monthlySalary: 4500,
      status: 'Active',
      joinDate: '2022-08-22',
      reimbursementDue: 0,
    ),
    _FinanceEmployee(
      id: 'EMP-003',
      name: 'Mike Johnson',
      email: 'mike@company.com',
      department: 'Finance',
      role: 'Finance Manager',
      monthlySalary: 6000,
      status: 'On Leave',
      joinDate: '2021-02-18',
      reimbursementDue: 180,
    ),
    _FinanceEmployee(
      id: 'EMP-004',
      name: 'Sarah Williams',
      email: 'sarah@company.com',
      department: 'HR',
      role: 'HR Manager',
      monthlySalary: 5500,
      status: 'Active',
      joinDate: '2020-11-03',
      reimbursementDue: 70,
    ),
    _FinanceEmployee(
      id: 'EMP-005',
      name: 'Tom Brown',
      email: 'tom@company.com',
      department: 'Operations',
      role: 'Ops Coordinator',
      monthlySalary: 4800,
      status: 'Probation',
      joinDate: '2025-12-02',
      reimbursementDue: 420,
    ),
    _FinanceEmployee(
      id: 'EMP-006',
      name: 'Aisha Khan',
      email: 'aisha@company.com',
      department: 'Accounting',
      role: 'Payroll Specialist',
      monthlySalary: 4700,
      status: 'Active',
      joinDate: '2024-06-12',
      reimbursementDue: 0,
    ),
  ];

  List<String> get _departments {
    final values = _employees.map((e) => e.department).toSet().toList()..sort();
    return ['All', ...values];
  }

  static const List<String> _statusOptions = [
    'All',
    'Active',
    'On Leave',
    'Probation',
  ];

  List<_FinanceEmployee> get _filteredEmployees {
    final q = _searchQuery.trim().toLowerCase();
    return _employees.where((employee) {
      final matchesSearch = q.isEmpty ||
          employee.name.toLowerCase().contains(q) ||
          employee.email.toLowerCase().contains(q) ||
          employee.id.toLowerCase().contains(q) ||
          employee.role.toLowerCase().contains(q);

      final matchesDepartment = _selectedDepartment == 'All' ||
          employee.department == _selectedDepartment;

      final matchesStatus =
          _selectedStatus == 'All' || employee.status == _selectedStatus;

      return matchesSearch && matchesDepartment && matchesStatus;
    }).toList();
  }

  double _sumSalary(List<_FinanceEmployee> employees) {
    return employees.fold(0, (sum, e) => sum + e.monthlySalary);
  }

  double _sumReimbursements(List<_FinanceEmployee> employees) {
    return employees.fold(0, (sum, e) => sum + e.reimbursementDue);
  }

  int _countByStatus(List<_FinanceEmployee> employees, String status) {
    return employees.where((e) => e.status == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 760;
        final isNarrow = width < 1120;
        final employees = _filteredEmployees;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isCompact),
              const SizedBox(height: 18),
              _buildHeroCard(employees),
              const SizedBox(height: 18),
              _buildKpiGrid(width, employees),
              const SizedBox(height: 16),
              _buildFiltersCard(isCompact),
              const SizedBox(height: 16),
              if (isNarrow) ...[
                _buildEmployeesCard(employees, isCompact),
                const SizedBox(height: 16),
                _buildSideInsightsCard(employees),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildEmployeesCard(employees, false),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildSideInsightsCard(employees),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isCompact) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Employees',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 6),
        Text(
          'Monitor payroll, employee status, and reimbursement exposure.',
          style: TextStyle(color: Color(0xFF5F6368)),
        ),
      ],
    );

    final addButton = ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
      label: const Text('Add Employee'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [heading, const SizedBox(height: 12), addButton],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: heading),
        const SizedBox(width: 14),
        addButton,
      ],
    );
  }

  Widget _buildHeroCard(List<_FinanceEmployee> employees) {
    final payroll = _sumSalary(employees);
    final activeCount = _countByStatus(employees, 'Active');
    final leaveCount = _countByStatus(employees, 'On Leave');
    final probationCount = _countByStatus(employees, 'Probation');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F355B), Color(0xFF1A73E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withOpacity(0.26),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 14,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Monthly Payroll Commitment',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${payroll.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _heroBadge('Active', '$activeCount'),
              _heroBadge('On Leave', '$leaveCount'),
              _heroBadge('Probation', '$probationCount'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(double width, List<_FinanceEmployee> employees) {
    final total = employees.length;
    final payroll = _sumSalary(employees);
    final reimbursements = _sumReimbursements(employees);
    final averageSalary = total == 0 ? 0.0 : payroll / total;

    final cards = [
      _KpiCardData(
        title: 'Total Employees',
        value: '$total',
        subtitle: 'Current filtered list',
        color: const Color(0xFF1A73E8),
        icon: Icons.groups_2_rounded,
      ),
      _KpiCardData(
        title: 'Avg Monthly Salary',
        value: '\$${averageSalary.toStringAsFixed(0)}',
        subtitle: 'Per employee average',
        color: const Color(0xFF0F9D58),
        icon: Icons.payments_rounded,
      ),
      _KpiCardData(
        title: 'Total Reimbursements',
        value: '\$${reimbursements.toStringAsFixed(0)}',
        subtitle: 'Pending claims',
        color: const Color(0xFFF29900),
        icon: Icons.receipt_long_rounded,
      ),
      _KpiCardData(
        title: 'Payroll Total',
        value: '\$${payroll.toStringAsFixed(0)}',
        subtitle: 'Monthly payroll base',
        color: const Color(0xFF123A68),
        icon: Icons.account_balance_wallet_rounded,
      ),
    ];

    final crossAxisCount = width >= 1280
        ? 4
        : width >= 860
            ? 2
            : 1;

    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 130,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];
        return _panel(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: card.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(card.icon, color: card.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      card.title,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      card.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFiltersCard(bool isCompact) {
    final search = TextField(
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        hintText: 'Search by name, email, role, or id',
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
        ),
      ),
    );

    final resetButton = TextButton.icon(
      onPressed: () {
        setState(() {
          _searchQuery = '';
          _selectedDepartment = 'All';
          _selectedStatus = 'All';
        });
      },
      icon: const Icon(Icons.restart_alt_rounded, size: 18),
      label: const Text('Reset filters'),
    );

    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (isCompact) ...[
            search,
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerLeft, child: resetButton),
          ] else
            Row(
              children: [
                Expanded(child: search),
                const SizedBox(width: 10),
                resetButton,
              ],
            ),
          const SizedBox(height: 14),
          const Text(
            'Department',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _departments
                .map(
                  (department) => ChoiceChip(
                    label: Text(department),
                    selected: _selectedDepartment == department,
                    onSelected: (_) {
                      setState(() {
                        _selectedDepartment = department;
                      });
                    },
                    selectedColor: const Color(0xFF1A73E8),
                    labelStyle: TextStyle(
                      color: _selectedDepartment == department
                          ? Colors.white
                          : const Color(0xFF334155),
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: _selectedDepartment == department
                          ? const Color(0xFF1A73E8)
                          : const Color(0xFFD5DEE9),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text(
            'Status',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _statusOptions
                .map(
                  (status) => ChoiceChip(
                    label: Text(status),
                    selected: _selectedStatus == status,
                    onSelected: (_) {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                    selectedColor: const Color(0xFF0F355B),
                    labelStyle: TextStyle(
                      color: _selectedStatus == status
                          ? Colors.white
                          : const Color(0xFF334155),
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: _selectedStatus == status
                          ? const Color(0xFF0F355B)
                          : const Color(0xFFD5DEE9),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeesCard(List<_FinanceEmployee> employees, bool isCompact) {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Employee Directory',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${employees.length} records',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Compensation and status overview for finance operations',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          if (employees.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'No employees match the selected filters.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ...employees
                .map((employee) => _buildEmployeeRow(employee, isCompact))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildEmployeeRow(_FinanceEmployee employee, bool isCompact) {
    final statusColor = _statusColor(employee.status);
    final initials = employee.name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join();

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          employee.name,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 2),
        Text(
          '${employee.id} | ${employee.role}',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          employee.email,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      ],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          const Color(0xFF1A73E8).withOpacity(0.14),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Color(0xFF1A73E8),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: details),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip(employee.department, const Color(0xFF123A68)),
                    _chip(employee.status, statusColor),
                    _chip('\$${employee.monthlySalary.toStringAsFixed(0)}/mo',
                        const Color(0xFF0F9D58)),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: const Color(0xFF1A73E8).withOpacity(0.14),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Color(0xFF1A73E8),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: details),
                const SizedBox(width: 8),
                _chip(employee.department, const Color(0xFF123A68)),
                const SizedBox(width: 8),
                _chip(employee.status, statusColor),
                const SizedBox(width: 12),
                SizedBox(
                  width: 110,
                  child: Text(
                    '\$${employee.monthlySalary.toStringAsFixed(0)}',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSideInsightsCard(List<_FinanceEmployee> employees) {
    final payrollByDepartment = <String, double>{};
    for (final employee in employees) {
      payrollByDepartment.update(
        employee.department,
        (value) => value + employee.monthlySalary,
        ifAbsent: () => employee.monthlySalary,
      );
    }

    final sortedDepartments = payrollByDepartment.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxDepartmentValue =
        sortedDepartments.isEmpty ? 1.0 : sortedDepartments.first.value;

    final reimbursements = employees
        .where((e) => e.reimbursementDue > 0)
        .toList()
      ..sort((a, b) => b.reimbursementDue.compareTo(a.reimbursementDue));

    return Column(
      children: [
        _panel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payroll Distribution',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (sortedDepartments.isEmpty)
                const Text(
                  'No data available for selected filters.',
                  style: TextStyle(color: Color(0xFF64748B)),
                )
              else
                ...sortedDepartments.map((entry) {
                  final ratio = entry.value / maxDepartmentValue;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '\$${entry.value.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Color(0xFF334155),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: ratio,
                            color: const Color(0xFF1A73E8),
                            backgroundColor: const Color(0xFFE2E8F0),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _panel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pending Reimbursements',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (reimbursements.isEmpty)
                const Text(
                  'No pending reimbursements.',
                  style: TextStyle(color: Color(0xFF64748B)),
                )
              else
                ...reimbursements.take(4).map(
                      (employee) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    employee.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    employee.department,
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${employee.reimbursementDue.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Color(0xFFF29900),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 6),
              _quickAction(
                icon: Icons.file_download_done_rounded,
                label: 'Export payroll sheet',
                color: const Color(0xFF1A73E8),
              ),
              const SizedBox(height: 8),
              _quickAction(
                icon: Icons.approval_rounded,
                label: 'Approve reimbursements',
                color: const Color(0xFF0F9D58),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 18, color: color),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          side: const BorderSide(color: Color(0xFFD5DEE9)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF0F9D58);
      case 'On Leave':
        return const Color(0xFFF29900);
      case 'Probation':
        return const Color(0xFFDB4437);
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _panel({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EBF3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FinanceEmployee {
  const _FinanceEmployee({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.role,
    required this.monthlySalary,
    required this.status,
    required this.joinDate,
    required this.reimbursementDue,
  });

  final String id;
  final String name;
  final String email;
  final String department;
  final String role;
  final double monthlySalary;
  final String status;
  final String joinDate;
  final double reimbursementDue;
}

class _KpiCardData {
  const _KpiCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;
}
