import 'package:flutter/material.dart';

import 'Active_Projects.dart';
import 'Assign_employee_to_project.dart';
import 'Export_employee_report.dart';
import '../Finance/Pages/Employees/Add_Emloyee.dart';
import 'Finance.dart';
import 'HR.dart';
import 'Legal.dart';
import 'Leave_Management.dart';
import 'Operations.dart';
import 'Send_policy_reminder.dart';

class SubAdminEmployeesPage extends StatefulWidget {
  const SubAdminEmployeesPage({super.key});

  @override
  State<SubAdminEmployeesPage> createState() => _SubAdminEmployeesPageState();
}

class _SubAdminEmployeesPageState extends State<SubAdminEmployeesPage> {
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  String _selectedStatus = 'All';
  String _selectedSort = 'Name';

  late final TextEditingController _searchController;

  static const List<String> _statuses = [
    'All',
    'Active',
    'On Leave',
    'Probation'
  ];

  static const List<String> _sortOptions = [
    'Name',
    'Attendance',
    'Projects',
    'Newest Joiner'
  ];

  final List<_EmployeeRecord> _employees = const [
    _EmployeeRecord(
      id: 'EMP-001',
      name: 'Rahul Sharma',
      role: 'Senior Accountant',
      department: 'Finance',
      status: 'Active',
      attendance: 0.96,
      projects: 3,
      joinDate: '2022-06-14',
      location: 'Mumbai',
      manager: 'A. Kapoor',
      email: 'rahul.sharma@company.com',
    ),
    _EmployeeRecord(
      id: 'EMP-002',
      name: 'Neha Verma',
      role: 'HR Executive',
      department: 'HR',
      status: 'On Leave',
      attendance: 0.91,
      projects: 2,
      joinDate: '2023-01-05',
      location: 'Pune',
      manager: 'R. Menon',
      email: 'neha.verma@company.com',
    ),
    _EmployeeRecord(
      id: 'EMP-003',
      name: 'Arjun Mehta',
      role: 'Operations Analyst',
      department: 'Operations',
      status: 'Active',
      attendance: 0.94,
      projects: 5,
      joinDate: '2021-09-22',
      location: 'Delhi',
      manager: 'P. Sinha',
      email: 'arjun.mehta@company.com',
    ),
    _EmployeeRecord(
      id: 'EMP-004',
      name: 'Sneha Iyer',
      role: 'Recruitment Coordinator',
      department: 'HR',
      status: 'Probation',
      attendance: 0.88,
      projects: 1,
      joinDate: '2025-12-10',
      location: 'Bengaluru',
      manager: 'R. Menon',
      email: 'sneha.iyer@company.com',
    ),
    _EmployeeRecord(
      id: 'EMP-005',
      name: 'Karan Patel',
      role: 'Payroll Specialist',
      department: 'Finance',
      status: 'Active',
      attendance: 0.97,
      projects: 4,
      joinDate: '2020-04-16',
      location: 'Ahmedabad',
      manager: 'A. Kapoor',
      email: 'karan.patel@company.com',
    ),
    _EmployeeRecord(
      id: 'EMP-006',
      name: 'Maya Nair',
      role: 'Data Associate',
      department: 'Operations',
      status: 'Active',
      attendance: 0.93,
      projects: 2,
      joinDate: '2024-08-01',
      location: 'Kochi',
      manager: 'P. Sinha',
      email: 'maya.nair@company.com',
    ),
    _EmployeeRecord(
      id: 'EMP-007',
      name: 'Ishita Rao',
      role: 'Compliance Analyst',
      department: 'Legal',
      status: 'Active',
      attendance: 0.92,
      projects: 3,
      joinDate: '2023-05-19',
      location: 'Hyderabad',
      manager: 'S. Bhatt',
      email: 'ishita.rao@company.com',
    ),
    _EmployeeRecord(
      id: 'EMP-008',
      name: 'Rohan Das',
      role: 'Support Executive',
      department: 'Operations',
      status: 'Probation',
      attendance: 0.86,
      projects: 1,
      joinDate: '2026-01-12',
      location: 'Kolkata',
      manager: 'P. Sinha',
      email: 'rohan.das@company.com',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _departments {
    final values = _employees
        .map((employee) => employee.department)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...values];
  }

  List<_EmployeeRecord> get _filteredEmployees {
    final query = _searchQuery.trim().toLowerCase();

    final list = _employees.where((employee) {
      final matchesQuery = query.isEmpty ||
          employee.id.toLowerCase().contains(query) ||
          employee.name.toLowerCase().contains(query) ||
          employee.role.toLowerCase().contains(query) ||
          employee.email.toLowerCase().contains(query);
      final matchesDepartment = _selectedDepartment == 'All' ||
          employee.department == _selectedDepartment;
      final matchesStatus =
          _selectedStatus == 'All' || employee.status == _selectedStatus;
      return matchesQuery && matchesDepartment && matchesStatus;
    }).toList();

    switch (_selectedSort) {
      case 'Attendance':
        list.sort((a, b) => b.attendance.compareTo(a.attendance));
        break;
      case 'Projects':
        list.sort((a, b) => b.projects.compareTo(a.projects));
        break;
      case 'Newest Joiner':
        list.sort((a, b) => b.joinDate.compareTo(a.joinDate));
        break;
      default:
        list.sort((a, b) => a.name.compareTo(b.name));
    }

    return list;
  }

  int _countByStatus(List<_EmployeeRecord> list, String status) {
    return list.where((employee) => employee.status == status).length;
  }

  double _averageAttendance(List<_EmployeeRecord> list) {
    if (list.isEmpty) {
      return 0;
    }
    final total =
        list.fold<double>(0, (sum, employee) => sum + employee.attendance);
    return total / list.length;
  }

  int _totalProjects(List<_EmployeeRecord> list) {
    return list.fold<int>(0, (sum, employee) => sum + employee.projects);
  }

  void _openActiveProjectsPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SubAdminActiveProjectsPage(),
      ),
    );
  }

  void _openAssignEmployeeToProjectPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SubAdminAssignEmployeeToProjectPage(),
      ),
    );
  }

  void _openExportEmployeeReportPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SubAdminExportEmployeeReportPage(),
      ),
    );
  }

  void _openFinancePage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SubAdminFinancePage(),
      ),
    );
  }

  void _openHrPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SubAdminHRPage(),
      ),
    );
  }

  void _openLegalPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SubAdminLegalPage(),
      ),
    );
  }

  void _openOperationsPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SubAdminOperationsPage(),
      ),
    );
  }

  void _openSendPolicyReminderPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SubAdminSendPolicyReminderPage(),
      ),
    );
  }

  void _openLeaveManagementPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SubAdminLeaveManagementPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 760;
        final isNarrow = width < 1140;
        final list = _filteredEmployees;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isCompact),
              const SizedBox(height: 16),
              _buildHeroCard(list),
              const SizedBox(height: 16),
              _buildMetricGrid(width, list),
              const SizedBox(height: 16),
              _buildFilterPanel(isCompact),
              const SizedBox(height: 16),
              if (isNarrow) ...[
                _buildEmployeesPanel(list, isCompact),
                const SizedBox(height: 14),
                _buildInsightsPanel(list),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildEmployeesPanel(list, false),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildInsightsPanel(list),
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
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Employees',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 6),
        Text(
          'Monitor employee records, attendance trends, and workforce status.',
          style: TextStyle(color: Color(0xFF5F6368)),
        ),
      ],
    );

    final action = ElevatedButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEmployeePage()),
        );
      },
      icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
      label: const Text('Add Employee'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF36B39C),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, const SizedBox(height: 10), action],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        const SizedBox(width: 12),
        action,
      ],
    );
  }

  Widget _buildHeroCard(List<_EmployeeRecord> list) {
    final active = _countByStatus(list, 'Active');
    final onLeave = _countByStatus(list, 'On Leave');
    final probation = _countByStatus(list, 'Probation');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F355B), Color(0xFF36B39C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF36B39C).withOpacity(0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Workforce Snapshot',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${list.length} employees in current view',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _heroChip('Active', '$active'),
              _heroChip('On Leave', '$onLeave'),
              _heroChip('Probation', '$probation'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
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
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricGrid(double width, List<_EmployeeRecord> list) {
    final crossAxisCount = width >= 1280
        ? 4
        : width >= 860
            ? 2
            : 1;

    final metrics = [
      _EmployeeMetric(
        title: 'Average Attendance',
        value: '${(_averageAttendance(list) * 100).round()}%',
        subtitle: 'Monthly consistency',
        icon: Icons.av_timer_rounded,
        color: const Color(0xFF1A73E8),
      ),
      _EmployeeMetric(
        title: 'Active Projects',
        value: '${_totalProjects(list)}',
        subtitle: 'Assigned work items',
        icon: Icons.work_outline_rounded,
        color: const Color(0xFF36B39C),
        onTap: _openActiveProjectsPage,
      ),
      _EmployeeMetric(
        title: 'On Leave',
        value: '${_countByStatus(list, 'On Leave')}',
        subtitle: 'Currently unavailable',
        icon: Icons.event_busy_rounded,
        color: const Color(0xFFF29900),
        onTap: _openLeaveManagementPage,
      ),
      _EmployeeMetric(
        title: 'Probation',
        value: '${_countByStatus(list, 'Probation')}',
        subtitle: 'Need close tracking',
        icon: Icons.timeline_rounded,
        color: const Color(0xFF7C3AED),
      ),
    ];

    return GridView.builder(
      itemCount: metrics.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 124,
      ),
      itemBuilder: (context, index) {
        final metric = metrics[index];
        final panel = _panel(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: metric.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(metric.icon, color: metric.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      metric.title,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      metric.value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      metric.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        if (metric.onTap == null) {
          return panel;
        }

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: metric.onTap,
            child: panel,
          ),
        );
      },
    );
  }

  Widget _buildFilterPanel(bool isCompact) {
    final search = TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: _inputDecoration(
        hintText: 'Search by id, name, role, or email',
        prefixIcon: const Icon(Icons.search_rounded),
      ),
    );

    final department = DropdownButtonFormField<String>(
      value: _selectedDepartment,
      decoration: _inputDecoration(labelText: 'Department'),
      items: _departments
          .map(
            (value) => DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        setState(() {
          _selectedDepartment = value;
        });
      },
    );

    final status = DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: _inputDecoration(labelText: 'Status'),
      items: _statuses
          .map(
            (value) => DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        setState(() {
          _selectedStatus = value;
        });
      },
    );

    final sort = DropdownButtonFormField<String>(
      value: _selectedSort,
      decoration: _inputDecoration(labelText: 'Sort By'),
      items: _sortOptions
          .map(
            (value) => DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        setState(() {
          _selectedSort = value;
        });
      },
    );

    final reset = TextButton.icon(
      onPressed: () {
        _searchController.clear();
        setState(() {
          _searchQuery = '';
          _selectedDepartment = 'All';
          _selectedStatus = 'All';
          _selectedSort = 'Name';
        });
      },
      icon: const Icon(Icons.restart_alt_rounded, size: 18),
      label: const Text('Reset'),
    );

    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCompact) ...[
            search,
            const SizedBox(height: 10),
            department,
            const SizedBox(height: 10),
            status,
            const SizedBox(height: 10),
            sort,
            const SizedBox(height: 8),
            reset,
          ] else
            Row(
              children: [
                Expanded(flex: 4, child: search),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: department),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: status),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: sort),
                const SizedBox(width: 8),
                reset,
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmployeesPanel(List<_EmployeeRecord> list, bool isCompact) {
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
                '${list.length} records',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (list.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'No employee records match your current filters.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ...list.map((employee) => _employeeRow(employee, isCompact)),
        ],
      ),
    );
  }

  Widget _employeeRow(_EmployeeRecord employee, bool isCompact) {
    final initials = _initials(employee.name);
    final statusColor = _statusColor(employee.status);

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          employee.name,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          '${employee.id} | ${employee.role}',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          '${employee.department} | ${employee.location} | Manager: ${employee.manager}',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      ],
    );

    final metrics = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _chip('Attendance ${(employee.attendance * 100).round()}%',
            const Color(0xFF1A73E8)),
        _chip('${employee.projects} projects', const Color(0xFF36B39C)),
        _chip(employee.status, statusColor),
      ],
    );

    if (isCompact) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF1A73E8).withOpacity(0.12),
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
            const SizedBox(height: 8),
            metrics,
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF1A73E8).withOpacity(0.12),
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
          const SizedBox(width: 10),
          metrics,
        ],
      ),
    );
  }

  Widget _buildInsightsPanel(List<_EmployeeRecord> list) {
    final departmentCounts = _departmentCounts(list);

    return Column(
      children: [
        _panel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Department Split',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (departmentCounts.isEmpty)
                const Text(
                  'No department data available.',
                  style: TextStyle(color: Color(0xFF64748B)),
                )
              else
                ...departmentCounts.map(
                  _buildDepartmentTile,
                ),
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
                'Quick Actions',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              _actionButton(
                Icons.assignment_ind_rounded,
                'Assign employee to project',
                onPressed: _openAssignEmployeeToProjectPage,
              ),
              const SizedBox(height: 8),
              _actionButton(
                Icons.notifications_active_rounded,
                'Send policy reminder',
                onPressed: _openSendPolicyReminderPage,
              ),
              const SizedBox(height: 8),
              _actionButton(
                Icons.event_note_rounded,
                'Leave management',
                onPressed: _openLeaveManagementPage,
              ),
              const SizedBox(height: 8),
              _actionButton(
                Icons.download_rounded,
                'Export employee report',
                onPressed: _openExportEmployeeReportPage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<_DepartmentCount> _departmentCounts(List<_EmployeeRecord> list) {
    final counts = <String, int>{};
    for (final employee in list) {
      counts.update(employee.department, (value) => value + 1,
          ifAbsent: () => 1);
    }
    final rows = counts.entries
        .map((entry) => _DepartmentCount(entry.key, entry.value))
        .toList();
    rows.sort((a, b) => b.count.compareTo(a.count));
    return rows;
  }

  Widget _buildDepartmentTile(_DepartmentCount item) {
    final VoidCallback? onTap;
    switch (item.department) {
      case 'Finance':
        onTap = _openFinancePage;
        break;
      case 'HR':
        onTap = _openHrPage;
        break;
      case 'Legal':
        onTap = _openLegalPage;
        break;
      case 'Operations':
        onTap = _openOperationsPage;
        break;
      default:
        onTap = null;
    }

    final isInteractive = onTap != null;

    final child = Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.department,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (isInteractive)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(
                Icons.open_in_new_rounded,
                size: 16,
                color: Color(0xFF1A73E8),
              ),
            ),
          Text(
            '${item.count}',
            style: const TextStyle(
              color: Color(0xFF36B39C),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    if (!isInteractive) {
      return child;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: child,
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label, {
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed ?? () {},
        icon: Icon(icon, size: 18, color: const Color(0xFF1A73E8)),
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

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF0F9D58);
      case 'On Leave':
        return const Color(0xFFF29900);
      case 'Probation':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF64748B);
    }
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

  InputDecoration _inputDecoration(
      {String? labelText, String? hintText, Widget? prefixIcon}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

class _EmployeeRecord {
  const _EmployeeRecord({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.status,
    required this.attendance,
    required this.projects,
    required this.joinDate,
    required this.location,
    required this.manager,
    required this.email,
  });

  final String id;
  final String name;
  final String role;
  final String department;
  final String status;
  final double attendance;
  final int projects;
  final String joinDate;
  final String location;
  final String manager;
  final String email;
}

class _EmployeeMetric {
  const _EmployeeMetric({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
}

class _DepartmentCount {
  const _DepartmentCount(this.department, this.count);

  final String department;
  final int count;
}
