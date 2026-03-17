import 'package:flutter/material.dart';

class TotalEmployeesPage extends StatefulWidget {
  const TotalEmployeesPage({super.key});

  @override
  State<TotalEmployeesPage> createState() => _TotalEmployeesPageState();
}

class _TotalEmployeesPageState extends State<TotalEmployeesPage> {
  final List<_EmployeeProfile> _employees = const [
    _EmployeeProfile(
      id: 'EMP-001',
      name: 'John Doe',
      department: 'Finance',
      role: 'Senior Analyst',
      status: 'Active',
      joinDate: '2023-04-11',
      employmentType: 'Full-Time',
    ),
    _EmployeeProfile(
      id: 'EMP-002',
      name: 'Jane Smith',
      department: 'Accounting',
      role: 'Accountant',
      status: 'Active',
      joinDate: '2022-08-22',
      employmentType: 'Full-Time',
    ),
    _EmployeeProfile(
      id: 'EMP-003',
      name: 'Mike Johnson',
      department: 'Finance',
      role: 'Finance Manager',
      status: 'On Leave',
      joinDate: '2021-02-18',
      employmentType: 'Full-Time',
    ),
    _EmployeeProfile(
      id: 'EMP-004',
      name: 'Sarah Williams',
      department: 'HR',
      role: 'HR Manager',
      status: 'Active',
      joinDate: '2020-11-03',
      employmentType: 'Full-Time',
    ),
    _EmployeeProfile(
      id: 'EMP-005',
      name: 'Tom Brown',
      department: 'Operations',
      role: 'Ops Coordinator',
      status: 'Probation',
      joinDate: '2025-12-02',
      employmentType: 'Contract',
    ),
    _EmployeeProfile(
      id: 'EMP-006',
      name: 'Aisha Khan',
      department: 'Accounting',
      role: 'Payroll Specialist',
      status: 'Active',
      joinDate: '2024-06-12',
      employmentType: 'Full-Time',
    ),
    _EmployeeProfile(
      id: 'EMP-007',
      name: 'Arya Stark',
      department: 'Operations',
      role: 'Quality Lead',
      status: 'Active',
      joinDate: '2022-01-06',
      employmentType: 'Full-Time',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  final List<_EmployeeActivity> _activity = [];

  String _searchQuery = '';
  String _selectedDepartment = 'All';
  String _selectedStatus = 'All';
  bool _showDetails = true;

  static const List<String> _statuses = [
    'All',
    'Active',
    'On Leave',
    'Probation',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(_employees.map((e) => e.id));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _departments {
    final values = _employees.map((e) => e.department).toSet().toList()..sort();
    return ['All', ...values];
  }

  List<_EmployeeProfile> get _filteredEmployees {
    final q = _searchQuery.trim().toLowerCase();
    return _employees.where((employee) {
      final matchesSearch = q.isEmpty ||
          employee.name.toLowerCase().contains(q) ||
          employee.id.toLowerCase().contains(q) ||
          employee.role.toLowerCase().contains(q) ||
          employee.department.toLowerCase().contains(q);

      final matchesDepartment = _selectedDepartment == 'All' ||
          employee.department == _selectedDepartment;

      final matchesStatus =
          _selectedStatus == 'All' || employee.status == _selectedStatus;

      return matchesSearch && matchesDepartment && matchesStatus;
    }).toList();
  }

  int get _activeCount => _employees.where((e) => e.status == 'Active').length;

  int get _leaveCount => _employees.where((e) => e.status == 'On Leave').length;

  int get _probationCount =>
      _employees.where((e) => e.status == 'Probation').length;

  void _toggleSelect(String id, bool checked) {
    setState(() {
      if (checked) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _toggleSelectAll(bool checked) {
    final visibleIds = _filteredEmployees.map((e) => e.id);
    setState(() {
      if (checked) {
        _selectedIds.addAll(visibleIds);
      } else {
        _selectedIds.removeWhere(visibleIds.contains);
      }
    });
  }

  void _markSelectedReviewed() {
    if (_selectedIds.isEmpty) {
      _showMessage('Select at least one employee profile.');
      return;
    }

    final selected =
        _employees.where((e) => _selectedIds.contains(e.id)).toList();
    setState(() {
      _activity.insertAll(
        0,
        selected.map(
          (e) => _EmployeeActivity(
            employeeId: e.id,
            name: e.name,
            action: 'Reviewed',
            icon: Icons.fact_check_rounded,
            color: const Color(0xFF16A34A),
          ),
        ),
      );
      _selectedIds.clear();
    });
    _showMessage('${selected.length} employee profile(s) marked reviewed.');
  }

  void _markSingleReviewed(_EmployeeProfile employee) {
    setState(() {
      _activity.insert(
        0,
        _EmployeeActivity(
          employeeId: employee.id,
          name: employee.name,
          action: 'Reviewed',
          icon: Icons.fact_check_rounded,
          color: const Color(0xFF16A34A),
        ),
      );
      _selectedIds.remove(employee.id);
    });
    _showMessage('${employee.name} marked as reviewed.');
  }

  void _flagProfile(_EmployeeProfile employee) {
    setState(() {
      _activity.insert(
        0,
        _EmployeeActivity(
          employeeId: employee.id,
          name: employee.name,
          action: 'Flagged',
          icon: Icons.flag_rounded,
          color: const Color(0xFFD97706),
        ),
      );
      _selectedIds.remove(employee.id);
    });
    _showMessage('${employee.name} profile flagged for follow-up.');
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF16A34A);
      case 'On Leave':
        return const Color(0xFF2563EB);
      case 'Probation':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _filteredEmployees;
    final allVisibleSelected =
        visible.isNotEmpty && visible.every((e) => _selectedIds.contains(e.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: const Text('Total Employees'),
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
                    _buildHero(),
                    const SizedBox(height: 14),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 3,
                              child: _buildDirectoryPanel(
                                  visible, allVisibleSelected)),
                          const SizedBox(width: 14),
                          Expanded(flex: 2, child: _buildInsightsPanel()),
                        ],
                      )
                    else ...[
                      _buildDirectoryPanel(visible, allVisibleSelected),
                      const SizedBox(height: 14),
                      _buildInsightsPanel(),
                    ],
                    const SizedBox(height: 14),
                    _buildFooter(isWide),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
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
            'Employee Count Console',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 23,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Track workforce distribution, status mix, and profile review actions.',
            style:
                TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _heroChip('Total', '${_employees.length}'),
              _heroChip('Active', '$_activeCount'),
              _heroChip('On Leave', '$_leaveCount'),
              _heroChip('Probation', '$_probationCount'),
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

  Widget _buildDirectoryPanel(
      List<_EmployeeProfile> visible, bool allVisibleSelected) {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Employee Directory',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _showDetails = !_showDetails),
                      icon: Icon(
                        _showDetails
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 16,
                        color: const Color(0xFF2563EB),
                      ),
                      label:
                          Text(_showDetails ? 'Hide Details' : 'Show Details'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search by name, id, role, or department...',
                    prefixIcon: const Icon(Icons.search_rounded),
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
                      return _filterChip(
                        label: dept,
                        selected: selected,
                        onTap: () => setState(() => _selectedDepartment = dept),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _statuses.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final status = _statuses[index];
                      final selected = status == _selectedStatus;
                      return _filterChip(
                        label: status,
                        selected: selected,
                        onTap: () => setState(() => _selectedStatus = status),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: allVisibleSelected,
                      onChanged: (value) => _toggleSelectAll(value ?? false),
                      activeColor: const Color(0xFF2563EB),
                    ),
                    const Text('Select all visible'),
                    const Spacer(),
                    Text(
                      '${visible.length} employee(s)',
                      style: const TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                  ],
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
                  'No employee records match current filters.',
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
              itemBuilder: (context, index) =>
                  _buildEmployeeRow(visible[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildEmployeeRow(_EmployeeProfile employee) {
    final statusColor = _statusColor(employee.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: _selectedIds.contains(employee.id),
                onChanged: (value) =>
                    _toggleSelect(employee.id, value ?? false),
                activeColor: const Color(0xFF2563EB),
              ),
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
                    Text(employee.name,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                      '${employee.id}  |  ${employee.role}  |  ${employee.department}',
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              ),
              _chip(employee.status, statusColor),
              const SizedBox(width: 8),
              _actionButton(
                label: 'Review',
                color: const Color(0xFF16A34A),
                onTap: () => _markSingleReviewed(employee),
              ),
              const SizedBox(width: 6),
              _actionButton(
                label: 'Flag',
                color: const Color(0xFFD97706),
                onTap: () => _flagProfile(employee),
              ),
            ],
          ),
          if (_showDetails) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: Text(
                '${employee.employmentType}  |  Joined: ${employee.joinDate}',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightsPanel() {
    final byDepartment = <String, int>{};
    for (final employee in _employees) {
      byDepartment.update(employee.department, (value) => value + 1,
          ifAbsent: () => 1);
    }

    final entries = byDepartment.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = entries.isEmpty ? 1 : entries.first.value;

    return Column(
      children: [
        _panel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Department Headcount',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ...entries.map((entry) {
                final ratio = entry.value / maxCount;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(entry.key,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600))),
                          Text('${entry.value}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
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
                'Review Activity',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (_activity.isEmpty)
                const Text('No review actions yet.',
                    style: TextStyle(color: Color(0xFF94A3B8)))
              else
                ..._activity.take(6).map(
                      (item) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Icon(item.icon, color: item.color, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${item.name}  |  ${item.action}',
                                style: TextStyle(
                                    color: item.color,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12),
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

  Widget _buildFooter(bool isWide) {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: isWide
          ? Row(
              children: [
                Expanded(
                  child: Text(
                    '${_selectedIds.length} profile(s) selected',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _markSelectedReviewed,
                  icon: const Icon(Icons.fact_check_rounded, size: 18),
                  label: const Text('Mark Reviewed'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedIds.length} profile(s) selected',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _markSelectedReviewed,
                    icon: const Icon(Icons.fact_check_rounded, size: 18),
                    label: const Text('Mark Reviewed'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF475569),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
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
        style:
            TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: color.withOpacity(0.10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
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

class _EmployeeProfile {
  const _EmployeeProfile({
    required this.id,
    required this.name,
    required this.department,
    required this.role,
    required this.status,
    required this.joinDate,
    required this.employmentType,
  });

  final String id;
  final String name;
  final String department;
  final String role;
  final String status;
  final String joinDate;
  final String employmentType;
}

class _EmployeeActivity {
  const _EmployeeActivity({
    required this.employeeId,
    required this.name,
    required this.action,
    required this.icon,
    required this.color,
  });

  final String employeeId;
  final String name;
  final String action;
  final IconData icon;
  final Color color;
}
