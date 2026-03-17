import 'package:flutter/material.dart';

class EmployeeInCyclePage extends StatefulWidget {
  const EmployeeInCyclePage({super.key});

  @override
  State<EmployeeInCyclePage> createState() => _EmployeeInCyclePageState();
}

class _EmployeeInCyclePageState extends State<EmployeeInCyclePage> {
  final List<_CycleEmployee> _employees = [
    const _CycleEmployee(
      id: 'EMP-101',
      name: 'Rhaenyra Targaryen',
      role: 'Product Designer',
      department: 'Design',
      employmentType: 'Full Time',
      cycleStatus: 'Ready',
      workingDays: 22,
      overtimeHours: 6,
      netPay: 7120,
      payDate: '18 Mar 2026',
    ),
    const _CycleEmployee(
      id: 'EMP-103',
      name: 'Jon Snow',
      role: 'Graphic Designer',
      department: 'Design',
      employmentType: 'Contract',
      cycleStatus: 'Needs Review',
      workingDays: 20,
      overtimeHours: 4,
      netPay: 5770,
      payDate: '19 Mar 2026',
    ),
    const _CycleEmployee(
      id: 'EMP-104',
      name: 'Arya Stark',
      role: 'QA Engineer',
      department: 'Engineering',
      employmentType: 'Full Time',
      cycleStatus: 'Adjusted',
      workingDays: 22,
      overtimeHours: 9,
      netPay: 6590,
      payDate: '19 Mar 2026',
    ),
    const _CycleEmployee(
      id: 'EMP-105',
      name: 'Tyrion Lannister',
      role: 'Operations Lead',
      department: 'Operations',
      employmentType: 'Full Time',
      cycleStatus: 'Ready',
      workingDays: 22,
      overtimeHours: 3,
      netPay: 7390,
      payDate: '19 Mar 2026',
    ),
    const _CycleEmployee(
      id: 'EMP-107',
      name: 'Bran Stark',
      role: 'Data Analyst',
      department: 'Finance',
      employmentType: 'Hybrid',
      cycleStatus: 'Needs Review',
      workingDays: 21,
      overtimeHours: 2,
      netPay: 5990,
      payDate: '19 Mar 2026',
    ),
    const _CycleEmployee(
      id: 'EMP-108',
      name: 'Jaime Lannister',
      role: 'Sales Executive',
      department: 'Sales',
      employmentType: 'Full Time',
      cycleStatus: 'Ready',
      workingDays: 22,
      overtimeHours: 1,
      netPay: 5795,
      payDate: '18 Mar 2026',
    ),
  ];

  final List<_CycleActivity> _activity = [];
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};

  String _searchQuery = '';
  String _selectedDepartment = 'All';
  bool _showDetails = true;

  List<String> get _departments {
    final values = _employees.map((item) => item.department).toSet().toList()
      ..sort();
    return ['All', ...values];
  }

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(_employees.map((item) => item.id));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _currency(double amount) {
    final value = amount.round().toString();
    final buffer = StringBuffer();
    for (int index = 0; index < value.length; index++) {
      final reverseIndex = value.length - index;
      buffer.write(value[index]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return '\$${buffer.toString()}';
  }

  List<_CycleEmployee> get _filteredEmployees {
    final query = _searchQuery.trim().toLowerCase();
    return _employees.where((item) {
      final matchesSearch = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.id.toLowerCase().contains(query) ||
          item.role.toLowerCase().contains(query) ||
          item.department.toLowerCase().contains(query) ||
          item.cycleStatus.toLowerCase().contains(query);
      final matchesDepartment = _selectedDepartment == 'All' ||
          item.department == _selectedDepartment;
      return matchesSearch && matchesDepartment;
    }).toList();
  }

  double get _cycleTotal =>
      _employees.fold(0, (sum, item) => sum + item.netPay);

  double get _selectedTotal => _employees
      .where((item) => _selectedIds.contains(item.id))
      .fold(0, (sum, item) => sum + item.netPay);

  double get _activityTotal =>
      _activity.fold(0, (sum, item) => sum + item.amount);

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
    final visibleIds = _filteredEmployees.map((item) => item.id);
    setState(() {
      if (checked) {
        _selectedIds.addAll(visibleIds);
      } else {
        _selectedIds.removeWhere(visibleIds.contains);
      }
    });
  }

  void _confirmSelected() {
    if (_selectedIds.isEmpty) {
      _showMessage('Select at least one employee to confirm for this cycle.');
      return;
    }

    final selected = _employees
        .where((item) => _selectedIds.contains(item.id))
        .toList(growable: false);
    final total = _selectedTotal;

    setState(() {
      _activity.insertAll(
        0,
        selected.map(
          (item) => _CycleActivity(
            id: item.id,
            name: item.name,
            amount: item.netPay,
            action: 'Confirmed',
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF16A34A),
          ),
        ),
      );
      _employees.removeWhere((item) => _selectedIds.contains(item.id));
      _selectedIds.clear();
    });

    _showMessage(
      '${selected.length} employee(s) confirmed - ${_currency(total)} locked for payroll.',
    );
  }

  void _excludeItem(_CycleEmployee item) {
    setState(() {
      _activity.insert(
        0,
        _CycleActivity(
          id: item.id,
          name: item.name,
          amount: item.netPay,
          action: 'Excluded',
          icon: Icons.remove_circle_rounded,
          color: const Color(0xFFDC2626),
        ),
      );
      _employees.remove(item);
      _selectedIds.remove(item.id);
    });

    _showMessage('${item.name} removed from the current payroll cycle.');
  }

  void _confirmItem(_CycleEmployee item) {
    setState(() {
      _activity.insert(
        0,
        _CycleActivity(
          id: item.id,
          name: item.name,
          amount: item.netPay,
          action: 'Confirmed',
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF16A34A),
        ),
      );
      _employees.remove(item);
      _selectedIds.remove(item.id);
    });

    _showMessage(
        '${item.name} confirmed for payroll - ${_currency(item.netPay)}.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Needs Review':
        return const Color(0xFFD97706);
      case 'Adjusted':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF16A34A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleEmployees = _filteredEmployees;
    final allVisibleSelected = visibleEmployees.isNotEmpty &&
        visibleEmployees.every((item) => _selectedIds.contains(item.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: const Text('Employees in Cycle'),
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
                    _buildHeroCard(),
                    const SizedBox(height: 14),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildQueuePanel(
                              visibleEmployees,
                              allVisibleSelected,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 2,
                            child: _buildActivityPanel(),
                          ),
                        ],
                      )
                    else ...[
                      _buildQueuePanel(visibleEmployees, allVisibleSelected),
                      const SizedBox(height: 14),
                      _buildActivityPanel(),
                    ],
                    const SizedBox(height: 14),
                    _buildActionFooter(isWide),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
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
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cycle Review Workspace',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 23,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Validate which employees are locked into the current payroll run before disbursement starts.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(
                  Icons.groups_2_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _heroChip('Employees in queue', '${_employees.length} people'),
              _heroChip('Payroll value', _currency(_cycleTotal)),
              _heroChip('Selected', '${_selectedIds.length} people'),
              _heroChip(
                'Processed today',
                '${_activity.length} | ${_currency(_activityTotal)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String label, String value) {
    return Container(
      constraints: const BoxConstraints(minWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
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
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueuePanel(
    List<_CycleEmployee> visibleEmployees,
    bool allVisibleSelected,
  ) {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Employee Queue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F0FE),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${visibleEmployees.length} visible',
                  style: const TextStyle(
                    color: Color(0xFF1D4ED8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Employees currently included in this payroll cycle.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search employee, id, role, department, or status',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _departments.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final department = _departments[index];
                final isSelected = _selectedDepartment == department;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDepartment = department;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFDDE3EA),
                      ),
                    ),
                    child: Text(
                      department,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : const Color(0xFF475569),
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
          Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: allVisibleSelected,
                  onChanged: (value) {
                    _toggleSelectAll(value ?? false);
                  },
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Select all visible',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showDetails = !_showDetails;
                  });
                },
                child: Row(
                  children: [
                    Text(
                      _showDetails ? 'Hide details' : 'Show details',
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _showDetails
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: const Color(0xFF2563EB),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (_employees.isEmpty)
            _emptyState(
              icon: Icons.verified_rounded,
              color: const Color(0xFF16A34A),
              backgroundColor: const Color(0xFFF0FDF4),
              borderColor: const Color(0xFFBBF7D0),
              message: 'All employees in this cycle have been finalized.',
            )
          else if (visibleEmployees.isEmpty)
            _emptyState(
              icon: Icons.search_off_rounded,
              color: const Color(0xFF64748B),
              backgroundColor: const Color(0xFFF8FAFC),
              borderColor: const Color(0xFFE2E8F0),
              message:
                  'No employees match the current search or department filter.',
            )
          else
            ...visibleEmployees.map(_buildEmployeeCard),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(_CycleEmployee item) {
    final isSelected = _selectedIds.contains(item.id);
    final statusColor = _statusColor(item.cycleStatus);
    final initials = item.name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEDF4FF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFFBFD8FF) : const Color(0xFFE2E8F0),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _toggleSelect(item.id, !isSelected),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      _toggleSelect(item.id, value ?? false);
                    },
                  ),
                  const SizedBox(width: 6),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFDBEAFE),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Color(0xFF1D4ED8),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.id} · ${item.role}',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _currency(item.netPay),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Net Pay',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _pill(item.department, const Color(0xFF123A68)),
                  _pill(item.cycleStatus, statusColor),
                  _pill(item.payDate, const Color(0xFF475569)),
                ],
              ),
              if (_showDetails) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _detailRow('Employment', item.employmentType),
                      _detailRow('Working Days', '${item.workingDays} days'),
                      _detailRow('Overtime', '${item.overtimeHours} hrs'),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _actionButton(
                    label: 'Exclude',
                    color: const Color(0xFFDC2626),
                    backgroundColor: const Color(0xFFFFF1F2),
                    icon: Icons.close_rounded,
                    onTap: () => _excludeItem(item),
                  ),
                  const SizedBox(width: 8),
                  _actionButton(
                    label: 'Confirm',
                    color: const Color(0xFF16A34A),
                    backgroundColor: const Color(0xFFF0FDF4),
                    icon: Icons.check_rounded,
                    onTap: () => _confirmItem(item),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityPanel() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cycle Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Employees confirmed or excluded in this session.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          if (_activity.isEmpty)
            _emptyState(
              icon: Icons.hourglass_empty_rounded,
              color: const Color(0xFF64748B),
              backgroundColor: const Color(0xFFF8FAFC),
              borderColor: const Color(0xFFE2E8F0),
              message: 'No cycle updates have been made yet.',
            )
          else
            ..._activity.map(_buildActivityCard),
        ],
      ),
    );
  }

  Widget _buildActivityCard(_CycleActivity item) {
    final isConfirmed = item.action == 'Confirmed';
    final backgroundColor =
        isConfirmed ? const Color(0xFFF0FDF4) : const Color(0xFFFFF1F2);
    final borderColor =
        isConfirmed ? const Color(0xFFBBF7D0) : const Color(0xFFFFCDD2);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(item.icon, color: item.color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  item.id,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currency(item.amount),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: item.color,
                ),
              ),
              Text(
                item.action,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: item.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionFooter(bool isWide) {
    final summary = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lock Selected Employees',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          '${_selectedIds.length} selected · ${_currency(_selectedTotal)} ready for payroll',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final button = ElevatedButton.icon(
      onPressed: _confirmSelected,
      icon: const Icon(Icons.playlist_add_check_circle_rounded),
      label: const Text('Confirm Selected'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0F355B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    return _panel(
      child: isWide
          ? Row(
              children: [
                Expanded(child: summary),
                const SizedBox(width: 12),
                button,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summary,
                const SizedBox(height: 10),
                SizedBox(width: double.infinity, child: button),
              ],
            ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, Color color) {
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

  Widget _actionButton({
    required String label,
    required Color color,
    required Color backgroundColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withOpacity(0.28)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required Color borderColor,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CycleEmployee {
  const _CycleEmployee({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.employmentType,
    required this.cycleStatus,
    required this.workingDays,
    required this.overtimeHours,
    required this.netPay,
    required this.payDate,
  });

  final String id;
  final String name;
  final String role;
  final String department;
  final String employmentType;
  final String cycleStatus;
  final int workingDays;
  final int overtimeHours;
  final double netPay;
  final String payDate;
}

class _CycleActivity {
  const _CycleActivity({
    required this.id,
    required this.name,
    required this.amount,
    required this.action,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final double amount;
  final String action;
  final IconData icon;
  final Color color;
}
