import 'package:flutter/material.dart';

class TotalOvertimePage extends StatefulWidget {
  const TotalOvertimePage({super.key});

  @override
  State<TotalOvertimePage> createState() => _TotalOvertimePageState();
}

class _TotalOvertimePageState extends State<TotalOvertimePage> {
  final List<_OvertimeRecord> _records = const [
    _OvertimeRecord(
      id: 'EMP-101',
      name: 'Rhaenyra Targaryen',
      role: 'Product Designer',
      department: 'Design',
      regularOvertimeHours: 5,
      weekendOvertimeHours: 2,
      holidayOvertimeHours: 0,
      overtimeRate: 48,
      primaryType: 'Weekday',
      payPeriod: 'March 2026',
    ),
    _OvertimeRecord(
      id: 'EMP-102',
      name: 'Daemon Targaryen',
      role: 'Finance Manager',
      department: 'Finance',
      regularOvertimeHours: 7,
      weekendOvertimeHours: 1,
      holidayOvertimeHours: 0,
      overtimeRate: 56,
      primaryType: 'Weekday',
      payPeriod: 'March 2026',
    ),
    _OvertimeRecord(
      id: 'EMP-103',
      name: 'Jon Snow',
      role: 'Senior Engineer',
      department: 'Engineering',
      regularOvertimeHours: 6,
      weekendOvertimeHours: 3,
      holidayOvertimeHours: 2,
      overtimeRate: 62,
      primaryType: 'Holiday',
      payPeriod: 'March 2026',
    ),
    _OvertimeRecord(
      id: 'EMP-104',
      name: 'Arya Stark',
      role: 'QA Engineer',
      department: 'Engineering',
      regularOvertimeHours: 4,
      weekendOvertimeHours: 4,
      holidayOvertimeHours: 0,
      overtimeRate: 44,
      primaryType: 'Weekend',
      payPeriod: 'March 2026',
    ),
    _OvertimeRecord(
      id: 'EMP-105',
      name: 'Tyrion Lannister',
      role: 'Operations Lead',
      department: 'Operations',
      regularOvertimeHours: 8,
      weekendOvertimeHours: 2,
      holidayOvertimeHours: 1,
      overtimeRate: 52,
      primaryType: 'Weekday',
      payPeriod: 'March 2026',
    ),
    _OvertimeRecord(
      id: 'EMP-106',
      name: 'Sansa Stark',
      role: 'HR Specialist',
      department: 'HR',
      regularOvertimeHours: 3,
      weekendOvertimeHours: 0,
      holidayOvertimeHours: 1,
      overtimeRate: 38,
      primaryType: 'Holiday',
      payPeriod: 'March 2026',
    ),
  ];

  final List<_OvertimeActivity> _activity = [];
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};

  String _searchQuery = '';
  String _selectedDepartment = 'All';
  String _selectedType = 'All';
  bool _showBreakdown = true;

  static const List<String> _overtimeTypes = [
    'All',
    'Weekday',
    'Weekend',
    'Holiday',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(_records.map((r) => r.id));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _departments {
    final values = _records.map((r) => r.department).toSet().toList()..sort();
    return ['All', ...values];
  }

  List<_OvertimeRecord> get _filteredRecords {
    final query = _searchQuery.trim().toLowerCase();
    return _records.where((record) {
      final matchesSearch = query.isEmpty ||
          record.name.toLowerCase().contains(query) ||
          record.id.toLowerCase().contains(query) ||
          record.role.toLowerCase().contains(query) ||
          record.department.toLowerCase().contains(query);

      final matchesDepartment = _selectedDepartment == 'All' ||
          record.department == _selectedDepartment;

      final matchesType = _selectedType == 'All' ||
          (_selectedType == 'Weekday' && record.regularOvertimeHours > 0) ||
          (_selectedType == 'Weekend' && record.weekendOvertimeHours > 0) ||
          (_selectedType == 'Holiday' && record.holidayOvertimeHours > 0);

      return matchesSearch && matchesDepartment && matchesType;
    }).toList();
  }

  String _currency(double amount) {
    final value = amount.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      final reverseIndex = value.length - i;
      buffer.write(value[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return '\$${buffer.toString()}';
  }

  String _hours(double hours) {
    if (hours % 1 == 0) {
      return '${hours.toStringAsFixed(0)}h';
    }
    return '${hours.toStringAsFixed(1)}h';
  }

  double get _totalHours =>
      _records.fold(0, (sum, record) => sum + record.totalOvertimeHours);

  double get _weekdayHours =>
      _records.fold(0, (sum, record) => sum + record.regularOvertimeHours);

  double get _weekendHours =>
      _records.fold(0, (sum, record) => sum + record.weekendOvertimeHours);

  double get _holidayHours =>
      _records.fold(0, (sum, record) => sum + record.holidayOvertimeHours);

  double get _totalPayout =>
      _records.fold(0, (sum, record) => sum + record.overtimePay);

  double get _selectedPayout => _records
      .where((record) => _selectedIds.contains(record.id))
      .fold(0, (sum, record) => sum + record.overtimePay);

  double get _approvedPayout => _activity.fold(
        0,
        (sum, item) => item.action == 'Approved' ? sum + item.amount : sum,
      );

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
    final visibleIds = _filteredRecords.map((record) => record.id);
    setState(() {
      if (checked) {
        _selectedIds.addAll(visibleIds);
      } else {
        _selectedIds.removeWhere(visibleIds.contains);
      }
    });
  }

  void _approveSelected() {
    if (_selectedIds.isEmpty) {
      _showMessage('Select at least one overtime record to approve.');
      return;
    }

    final selected = _records
        .where((record) => _selectedIds.contains(record.id))
        .toList(growable: false);
    final approvedTotal = _selectedPayout;

    setState(() {
      _activity.insertAll(
        0,
        selected.map(
          (record) => _OvertimeActivity(
            employeeId: record.id,
            name: record.name,
            amount: record.overtimePay,
            hours: record.totalOvertimeHours,
            action: 'Approved',
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF16A34A),
          ),
        ),
      );
      _selectedIds.clear();
    });

    _showMessage(
      '${selected.length} overtime request(s) approved - ${_currency(approvedTotal)} confirmed.',
    );
  }

  void _approveItem(_OvertimeRecord record) {
    setState(() {
      _activity.insert(
        0,
        _OvertimeActivity(
          employeeId: record.id,
          name: record.name,
          amount: record.overtimePay,
          hours: record.totalOvertimeHours,
          action: 'Approved',
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF16A34A),
        ),
      );
      _selectedIds.remove(record.id);
    });

    _showMessage(
      '${record.name} overtime approved - ${_currency(record.overtimePay)}.',
    );
  }

  void _flagItem(_OvertimeRecord record) {
    setState(() {
      _activity.insert(
        0,
        _OvertimeActivity(
          employeeId: record.id,
          name: record.name,
          amount: record.overtimePay,
          hours: record.totalOvertimeHours,
          action: 'Flagged',
          icon: Icons.flag_rounded,
          color: const Color(0xFFD97706),
        ),
      );
      _selectedIds.remove(record.id);
    });

    _showMessage('${record.name} overtime flagged for review.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Weekend':
        return const Color(0xFF7C3AED);
      case 'Holiday':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF16A34A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleRecords = _filteredRecords;
    final allVisibleSelected = visibleRecords.isNotEmpty &&
        visibleRecords.every((record) => _selectedIds.contains(record.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: const Text('Total Overtime'),
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
                    _buildSummaryRow(),
                    const SizedBox(height: 14),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildRecordsPanel(
                              visibleRecords,
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
                      _buildRecordsPanel(visibleRecords, allVisibleSelected),
                      const SizedBox(height: 14),
                      _buildActivityPanel(),
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
                      'Overtime Command Center',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 23,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Validate extra-hour claims, track payout impact, and approve records for payroll release.',
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
                  Icons.access_time_filled_rounded,
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
              _heroChip('Overtime Hours', _hours(_totalHours)),
              _heroChip('Total Payout', _currency(_totalPayout)),
              _heroChip('Selected', '${_selectedIds.length} employees'),
              _heroChip('Reviewed', '${_activity.length} records'),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    final summaries = [
      _OvertimeSummary(
        label: 'Weekday Hours',
        value: _hours(_weekdayHours),
        icon: Icons.work_history_rounded,
        color: const Color(0xFF16A34A),
        background: const Color(0xFFDCFCE7),
      ),
      _OvertimeSummary(
        label: 'Weekend Hours',
        value: _hours(_weekendHours),
        icon: Icons.weekend_rounded,
        color: const Color(0xFF7C3AED),
        background: const Color(0xFFEDE9FE),
      ),
      _OvertimeSummary(
        label: 'Holiday Hours',
        value: _hours(_holidayHours),
        icon: Icons.beach_access_rounded,
        color: const Color(0xFFDC2626),
        background: const Color(0xFFFFE4E4),
      ),
      _OvertimeSummary(
        label: 'Overtime Payout',
        value: _currency(_totalPayout),
        icon: Icons.payments_rounded,
        color: const Color(0xFF2563EB),
        background: const Color(0xFFDBEAFE),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 560
                ? 2
                : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: constraints.maxWidth < 560 ? 4 : 2.8,
          children: summaries.map(_summaryCard).toList(),
        );
      },
    );
  }

  Widget _summaryCard(_OvertimeSummary summary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EBF3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: summary.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(summary.icon, color: summary.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  summary.label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  summary.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsPanel(
    List<_OvertimeRecord> visibleRecords,
    bool allVisibleSelected,
  ) {
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
                        'Overtime Queue',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _showBreakdown = !_showBreakdown),
                      icon: Icon(
                        _showBreakdown
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 16,
                        color: const Color(0xFF16A34A),
                      ),
                      label: Text(
                        _showBreakdown ? 'Hide Breakdown' : 'Show Breakdown',
                        style: const TextStyle(
                          color: Color(0xFF16A34A),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search by name, ID or department...',
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
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
                      borderSide: const BorderSide(color: Color(0xFF16A34A)),
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
                      final department = _departments[index];
                      final selected = department == _selectedDepartment;
                      return GestureDetector(
                        onTap: () => setState(
                          () => _selectedDepartment = department,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF0F2C67)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF0F2C67)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            department,
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
                const SizedBox(height: 8),
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _overtimeTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final type = _overtimeTypes[index];
                      final selected = type == _selectedType;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            type,
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: allVisibleSelected,
                      onChanged: (value) => _toggleSelectAll(value ?? false),
                      activeColor: const Color(0xFF16A34A),
                    ),
                    const Text(
                      'Select all visible',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${visibleRecords.length} record(s)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          if (visibleRecords.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No overtime records match the current filters.',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleRecords.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                return _buildRecordTile(visibleRecords[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRecordTile(_OvertimeRecord record) {
    final selected = _selectedIds.contains(record.id);
    final initials = record.name
        .split(' ')
        .take(2)
        .map((word) => word[0])
        .join()
        .toUpperCase();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color:
          selected ? const Color(0xFF16A34A).withOpacity(0.04) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: selected,
                  onChanged: (value) =>
                      _toggleSelect(record.id, value ?? false),
                  activeColor: const Color(0xFF16A34A),
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF16A34A).withOpacity(0.10),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Color(0xFF16A34A),
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
                        record.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${record.id}  •  ${record.role}  •  ${record.department}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _chip(record.primaryType, _typeColor(record.primaryType)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _currency(record.overtimePay),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF16A34A),
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _hours(record.totalOvertimeHours),
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                _actionButton(
                  label: 'Approve',
                  color: const Color(0xFF16A34A),
                  onTap: () => _approveItem(record),
                ),
                const SizedBox(width: 6),
                _actionButton(
                  label: 'Flag',
                  color: const Color(0xFFD97706),
                  onTap: () => _flagItem(record),
                ),
              ],
            ),
            if (_showBreakdown) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (record.regularOvertimeHours > 0)
                      _breakdownTag(
                        'Weekday',
                        _hours(record.regularOvertimeHours),
                        const Color(0xFF16A34A),
                        const Color(0xFFDCFCE7),
                      ),
                    if (record.weekendOvertimeHours > 0)
                      _breakdownTag(
                        'Weekend',
                        _hours(record.weekendOvertimeHours),
                        const Color(0xFF7C3AED),
                        const Color(0xFFEDE9FE),
                      ),
                    if (record.holidayOvertimeHours > 0)
                      _breakdownTag(
                        'Holiday',
                        _hours(record.holidayOvertimeHours),
                        const Color(0xFFDC2626),
                        const Color(0xFFFFE4E4),
                      ),
                    _breakdownTag(
                      'Rate',
                      _currency(record.overtimeRate),
                      const Color(0xFF2563EB),
                      const Color(0xFFDBEAFE),
                    ),
                    _breakdownTag(
                      'Period',
                      record.payPeriod,
                      const Color(0xFF475569),
                      const Color(0xFFF1F5F9),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
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
        backgroundColor: color.withOpacity(0.08),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _breakdownTag(
    String label,
    String value,
    Color color,
    Color background,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityPanel() {
    return _panel(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Review Activity',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_activity.length}',
                    style: const TextStyle(
                      color: Color(0xFF16A34A),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Approved payout: ${_currency(_approvedPayout)}',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            if (_activity.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.pending_actions_rounded,
                      size: 32,
                      color: Color(0xFFCBD5E1),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No reviews yet.',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Approved or flagged overtime records will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activity.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = _activity[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(item.icon, size: 18, color: item.color),
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
                                  fontSize: 13,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                '${item.employeeId}  •  ${item.action}  •  ${_currency(item.amount)}  •  ${_hours(item.hours)}',
                                style: TextStyle(
                                  color: item.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isWide) {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: isWide
          ? Row(
              children: [
                const Icon(
                  Icons.access_time_filled_rounded,
                  color: Color(0xFF16A34A),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          color: Color(0xFF334155), fontSize: 14),
                      children: [
                        TextSpan(
                          text: '${_selectedIds.length} employee(s) selected',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(text: ' — Selected payout: '),
                        TextSpan(
                          text: _currency(_selectedPayout),
                          style: const TextStyle(
                            color: Color(0xFF16A34A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                FilledButton.icon(
                  onPressed: _approveSelected,
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: const Text('Approve Selected'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_filled_rounded,
                      color: Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            color: Color(0xFF334155), fontSize: 13),
                        children: [
                          TextSpan(
                            text: '${_selectedIds.length} selected',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const TextSpan(text: ' — '),
                          TextSpan(
                            text: _currency(_selectedPayout),
                            style: const TextStyle(
                              color: Color(0xFF16A34A),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _approveSelected,
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: const Text('Approve Selected'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
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

class _OvertimeRecord {
  const _OvertimeRecord({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.regularOvertimeHours,
    required this.weekendOvertimeHours,
    required this.holidayOvertimeHours,
    required this.overtimeRate,
    required this.primaryType,
    required this.payPeriod,
  });

  final String id;
  final String name;
  final String role;
  final String department;
  final double regularOvertimeHours;
  final double weekendOvertimeHours;
  final double holidayOvertimeHours;
  final double overtimeRate;
  final String primaryType;
  final String payPeriod;

  double get totalOvertimeHours =>
      regularOvertimeHours + weekendOvertimeHours + holidayOvertimeHours;

  double get overtimePay =>
      (regularOvertimeHours * overtimeRate) +
      (weekendOvertimeHours * overtimeRate * 1.5) +
      (holidayOvertimeHours * overtimeRate * 2);
}

class _OvertimeActivity {
  const _OvertimeActivity({
    required this.employeeId,
    required this.name,
    required this.amount,
    required this.hours,
    required this.action,
    required this.icon,
    required this.color,
  });

  final String employeeId;
  final String name;
  final double amount;
  final double hours;
  final String action;
  final IconData icon;
  final Color color;
}

class _OvertimeSummary {
  const _OvertimeSummary({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;
}
