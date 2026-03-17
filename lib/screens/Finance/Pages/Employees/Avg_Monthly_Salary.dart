import 'package:flutter/material.dart';

class AvgMonthlySalaryPage extends StatefulWidget {
  const AvgMonthlySalaryPage({super.key});

  @override
  State<AvgMonthlySalaryPage> createState() => _AvgMonthlySalaryPageState();
}

class _AvgMonthlySalaryPageState extends State<AvgMonthlySalaryPage> {
  final List<_SalaryEmployee> _employees = const [
    _SalaryEmployee(
      id: 'EMP-001',
      name: 'John Doe',
      department: 'Finance',
      role: 'Senior Analyst',
      salary: 5000,
      salaryBand: 'L2',
    ),
    _SalaryEmployee(
      id: 'EMP-002',
      name: 'Jane Smith',
      department: 'Accounting',
      role: 'Accountant',
      salary: 4500,
      salaryBand: 'L2',
    ),
    _SalaryEmployee(
      id: 'EMP-003',
      name: 'Mike Johnson',
      department: 'Finance',
      role: 'Finance Manager',
      salary: 6000,
      salaryBand: 'L3',
    ),
    _SalaryEmployee(
      id: 'EMP-004',
      name: 'Sarah Williams',
      department: 'HR',
      role: 'HR Manager',
      salary: 5500,
      salaryBand: 'L3',
    ),
    _SalaryEmployee(
      id: 'EMP-005',
      name: 'Tom Brown',
      department: 'Operations',
      role: 'Ops Coordinator',
      salary: 4800,
      salaryBand: 'L2',
    ),
    _SalaryEmployee(
      id: 'EMP-006',
      name: 'Aisha Khan',
      department: 'Accounting',
      role: 'Payroll Specialist',
      salary: 4700,
      salaryBand: 'L2',
    ),
    _SalaryEmployee(
      id: 'EMP-007',
      name: 'Bran Stark',
      department: 'Finance',
      role: 'Data Analyst',
      salary: 5200,
      salaryBand: 'L2',
    ),
    _SalaryEmployee(
      id: 'EMP-008',
      name: 'Arya Stark',
      department: 'Operations',
      role: 'Quality Lead',
      salary: 5600,
      salaryBand: 'L3',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  bool _showTopEarnersOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _departments {
    final values = _employees.map((e) => e.department).toSet().toList()..sort();
    return ['All', ...values];
  }

  List<_SalaryEmployee> get _filteredEmployees {
    final q = _searchQuery.trim().toLowerCase();
    final avg = _averageSalary(_employees);

    return _employees.where((employee) {
      final matchesQuery = q.isEmpty ||
          employee.name.toLowerCase().contains(q) ||
          employee.id.toLowerCase().contains(q) ||
          employee.role.toLowerCase().contains(q) ||
          employee.department.toLowerCase().contains(q);

      final matchesDepartment = _selectedDepartment == 'All' ||
          employee.department == _selectedDepartment;

      final matchesTop = !_showTopEarnersOnly || employee.salary >= avg;

      return matchesQuery && matchesDepartment && matchesTop;
    }).toList()
      ..sort((a, b) => b.salary.compareTo(a.salary));
  }

  double _averageSalary(List<_SalaryEmployee> employees) {
    if (employees.isEmpty) return 0;
    return employees.fold(0.0, (sum, e) => sum + e.salary) / employees.length;
  }

  String _currency(double amount) {
    final raw = amount.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final reverseIndex = raw.length - i;
      buffer.write(raw[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return '\$${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final visible = _filteredEmployees;
    final averageAll = _averageSalary(_employees);
    final averageVisible = _averageSalary(visible);
    final maxSalary = _employees.isEmpty
        ? 0.0
        : _employees.map((e) => e.salary).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: const Text('Average Monthly Salary'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFF), Color(0xFFEEF3FB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 980;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(averageAll, averageVisible, maxSalary),
                    const SizedBox(height: 14),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 3, child: _buildSalaryListPanel(visible)),
                          const SizedBox(width: 14),
                          Expanded(flex: 2, child: _buildInsightsPanel()),
                        ],
                      )
                    else ...[
                      _buildSalaryListPanel(visible),
                      const SizedBox(height: 14),
                      _buildInsightsPanel(),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHero(
      double averageAll, double averageVisible, double maxSalary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2C67), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Salary Intelligence',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 23,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Track average salary by filter, compare departments, and identify top compensation bands.',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _heroChip('Org Average', _currency(averageAll)),
              _heroChip('Visible Average', _currency(averageVisible)),
              _heroChip('Max Salary', _currency(maxSalary)),
              _heroChip('Employees', '${_employees.length}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSalaryListPanel(List<_SalaryEmployee> visible) {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Employee Salary Directory',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search by employee, id, role or department...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF94A3B8),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2563EB)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _departments.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final dept = _departments[index];
                      final selected = dept == _selectedDepartment;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDepartment = dept),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            dept,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF475569),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _showTopEarnersOnly,
                  onChanged: (value) =>
                      setState(() => _showTopEarnersOnly = value),
                  title: const Text(
                    'Show top earners only (>= average)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF334155),
                    ),
                  ),
                  activeColor: const Color(0xFF2563EB),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          if (visible.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Text(
                  'No employees match current filters.',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visible.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) => _buildSalaryRow(visible[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildSalaryRow(_SalaryEmployee employee) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF2563EB).withOpacity(0.12),
            child: Text(
              employee.name
                  .split(' ')
                  .take(2)
                  .map((part) => part[0])
                  .join()
                  .toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${employee.id}  |  ${employee.role}  |  ${employee.department}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _chip(employee.salaryBand, const Color(0xFF7C3AED)),
          const SizedBox(width: 10),
          Text(
            _currency(employee.salary),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsPanel() {
    final byDepartment = <String, List<_SalaryEmployee>>{};
    for (final employee in _employees) {
      byDepartment.putIfAbsent(employee.department, () => []).add(employee);
    }

    final departmentAverages = byDepartment.entries.map((entry) {
      final avg = _averageSalary(entry.value);
      return _DepartmentAvg(entry.key, avg);
    }).toList()
      ..sort((a, b) => b.average.compareTo(a.average));

    final topAvg =
        departmentAverages.isEmpty ? 1.0 : departmentAverages.first.average;
    final topEarners = [..._employees]
      ..sort((a, b) => b.salary.compareTo(a.salary));

    return Column(
      children: [
        _panel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Department Average Salary',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ...departmentAverages.map((item) {
                final ratio = item.average / topAvg;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.department,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            _currency(item.average),
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
                          color: const Color(0xFF2563EB),
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
                'Top Earners',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ...topEarners.take(4).map(
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
                                      fontWeight: FontWeight.w700),
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
                            _currency(employee.salary),
                            style: const TextStyle(
                              color: Color(0xFF16A34A),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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

class _SalaryEmployee {
  const _SalaryEmployee({
    required this.id,
    required this.name,
    required this.department,
    required this.role,
    required this.salary,
    required this.salaryBand,
  });

  final String id;
  final String name;
  final String department;
  final String role;
  final double salary;
  final String salaryBand;
}

class _DepartmentAvg {
  const _DepartmentAvg(this.department, this.average);

  final String department;
  final double average;
}
