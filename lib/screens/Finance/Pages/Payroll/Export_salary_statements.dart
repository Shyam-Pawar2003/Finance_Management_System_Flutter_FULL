import 'package:flutter/material.dart';

class ExportSalaryStatementsPage extends StatefulWidget {
  const ExportSalaryStatementsPage({super.key});

  @override
  State<ExportSalaryStatementsPage> createState() =>
      _ExportSalaryStatementsPageState();
}

class _ExportSalaryStatementsPageState
    extends State<ExportSalaryStatementsPage> {
  final List<_SalaryRecord> _records = [
    const _SalaryRecord(
      id: 'EMP-101',
      name: 'Rhaenyra Targaryen',
      role: 'Product Designer',
      department: 'Design',
      baseSalary: 7200,
      overtimePay: 260,
      bonus: 300,
      deductions: 640,
      payPeriod: 'March 2026',
      payDate: '18 Mar 2026',
      status: 'Paid',
      bankLast4: '4821',
    ),
    const _SalaryRecord(
      id: 'EMP-102',
      name: 'Daemon Targaryen',
      role: 'Finance Manager',
      department: 'Finance',
      baseSalary: 8500,
      overtimePay: 0,
      bonus: 500,
      deductions: 890,
      payPeriod: 'March 2026',
      payDate: '18 Mar 2026',
      status: 'Paid',
      bankLast4: '3792',
    ),
    const _SalaryRecord(
      id: 'EMP-103',
      name: 'Jon Snow',
      role: 'Senior Engineer',
      department: 'Engineering',
      baseSalary: 9200,
      overtimePay: 480,
      bonus: 0,
      deductions: 1050,
      payPeriod: 'March 2026',
      payDate: '18 Mar 2026',
      status: 'Pending',
      bankLast4: '6610',
    ),
    const _SalaryRecord(
      id: 'EMP-104',
      name: 'Arya Stark',
      role: 'QA Engineer',
      department: 'Engineering',
      baseSalary: 6800,
      overtimePay: 310,
      bonus: 620,
      deductions: 780,
      payPeriod: 'March 2026',
      payDate: '19 Mar 2026',
      status: 'Processing',
      bankLast4: '1123',
    ),
    const _SalaryRecord(
      id: 'EMP-105',
      name: 'Tyrion Lannister',
      role: 'Operations Lead',
      department: 'Operations',
      baseSalary: 7800,
      overtimePay: 120,
      bonus: 1200,
      deductions: 940,
      payPeriod: 'March 2026',
      payDate: '19 Mar 2026',
      status: 'Pending',
      bankLast4: '5504',
    ),
    const _SalaryRecord(
      id: 'EMP-106',
      name: 'Sansa Stark',
      role: 'HR Specialist',
      department: 'HR',
      baseSalary: 6400,
      overtimePay: 0,
      bonus: 200,
      deductions: 720,
      payPeriod: 'March 2026',
      payDate: '18 Mar 2026',
      status: 'Paid',
      bankLast4: '8847',
    ),
  ];

  final List<_ExportActivity> _activity = [];
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};

  String _searchQuery = '';
  String _selectedDept = 'All';
  String _selectedStatus = 'All';
  String _exportFormat = 'PDF';
  bool _showDetails = false;

  static const List<String> _statuses = [
    'All',
    'Paid',
    'Pending',
    'Processing',
  ];

  static const List<String> _formats = ['PDF', 'CSV', 'Excel'];

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
    final depts = _records.map((r) => r.department).toSet().toList()..sort();
    return ['All', ...depts];
  }

  List<_SalaryRecord> get _filteredRecords {
    final query = _searchQuery.trim().toLowerCase();
    return _records.where((r) {
      final matchesSearch = query.isEmpty ||
          r.name.toLowerCase().contains(query) ||
          r.id.toLowerCase().contains(query) ||
          r.role.toLowerCase().contains(query) ||
          r.department.toLowerCase().contains(query);
      final matchesDept =
          _selectedDept == 'All' || r.department == _selectedDept;
      final matchesStatus =
          _selectedStatus == 'All' || r.status == _selectedStatus;
      return matchesSearch && matchesDept && matchesStatus;
    }).toList();
  }

  String _currency(double amount) {
    final value = amount.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      final reverseIndex = value.length - i;
      buffer.write(value[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) buffer.write(',');
    }
    return '\$${buffer.toString()}';
  }

  double get _selectedNet => _records
      .where((r) => _selectedIds.contains(r.id))
      .fold(0, (sum, r) => sum + r.netPay);

  int get _exportedCount => _activity.length;

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
    final visible = _filteredRecords.map((r) => r.id);
    setState(() {
      if (checked) {
        _selectedIds.addAll(visible);
      } else {
        _selectedIds.removeWhere(visible.contains);
      }
    });
  }

  void _exportSelected() {
    if (_selectedIds.isEmpty) {
      _showMessage('Select at least one employee to export.');
      return;
    }

    final toExport = _records
        .where((r) => _selectedIds.contains(r.id))
        .toList(growable: false);

    setState(() {
      _activity.insertAll(
        0,
        toExport.map(
          (r) => _ExportActivity(
            employeeId: r.id,
            name: r.name,
            format: _exportFormat,
            net: r.netPay,
            timestamp: 'Just now',
          ),
        ),
      );
    });

    _showMessage(
      '${toExport.length} salary statement(s) exported as $_exportFormat.',
    );
  }

  void _exportSingle(_SalaryRecord record) {
    setState(() {
      _activity.insert(
        0,
        _ExportActivity(
          employeeId: record.id,
          name: record.name,
          format: _exportFormat,
          net: record.netPay,
          timestamp: 'Just now',
        ),
      );
    });
    _showMessage('${record.name} statement exported as $_exportFormat.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Paid':
        return const Color(0xFF16A34A);
      case 'Pending':
        return const Color(0xFFD97706);
      case 'Processing':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _filteredRecords;
    final allSelected =
        visible.isNotEmpty && visible.every((r) => _selectedIds.contains(r.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: const Text('Export Salary Statements'),
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
                            child: _buildRecordsPanel(visible, allSelected),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 2,
                            child: _buildActivityPanel(),
                          ),
                        ],
                      )
                    else ...[
                      _buildRecordsPanel(visible, allSelected),
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

  // ── Hero Card ──────────────────────────────────────────────────────────────

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
                      'Salary Statement Export Hub',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 23,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Select employees, choose a format, and generate official payslips for distribution or records.',
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
                  Icons.file_download_done_rounded,
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
              _heroChip('Total Records', '${_records.length} employees'),
              _heroChip('Selected', '${_selectedIds.length} employees'),
              _heroChip('Selected Net', _currency(_selectedNet)),
              _heroChip('Exported Today', '$_exportedCount statements'),
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

  // ── Records Panel ──────────────────────────────────────────────────────────

  Widget _buildRecordsPanel(List<_SalaryRecord> visible, bool allSelected) {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row + details toggle
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Export Queue',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
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
                      label: Text(
                        _showDetails ? 'Hide Details' : 'Show Details',
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Search
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search by name, ID or department…',
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
                        horizontal: 14, vertical: 12),
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
                // Department filter
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _departments.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final dept = _departments[index];
                      final selected = dept == _selectedDept;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDept = dept),
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
                const SizedBox(height: 8),
                // Status filter
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _statuses.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final status = _statuses[index];
                      final selected = status == _selectedStatus;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedStatus = status),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
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
                            status,
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
                // Select all
                Row(
                  children: [
                    Checkbox(
                      value: allSelected,
                      onChanged: (v) => _toggleSelectAll(v ?? false),
                      activeColor: const Color(0xFF2563EB),
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
                      '${visible.length} record(s)',
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
          if (visible.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No records match the current filters.',
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
              itemBuilder: (context, index) => _buildRecordTile(visible[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildRecordTile(_SalaryRecord record) {
    final selected = _selectedIds.contains(record.id);
    final initials =
        record.name.split(' ').take(2).map((w) => w[0]).join().toUpperCase();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: selected
          ? const Color(0xFF2563EB).withOpacity(0.04)
          : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: selected,
                  onChanged: (v) => _toggleSelect(record.id, v ?? false),
                  activeColor: const Color(0xFF2563EB),
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF2563EB).withOpacity(0.12),
                  child: Text(
                    initials,
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
                _chip(record.status, _statusColor(record.status)),
                const SizedBox(width: 8),
                Text(
                  _currency(record.netPay),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 10),
                // Per-item export button
                TextButton(
                  onPressed: () => _exportSingle(record),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB).withOpacity(0.08),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Export',
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (_showDetails) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _detailTag(Icons.calendar_month_rounded,
                        'Pay Date: ${record.payDate}'),
                    _detailTag(Icons.payments_rounded,
                        'Base: ${_currency(record.baseSalary)}'),
                    _detailTag(Icons.access_time_rounded,
                        'OT: ${_currency(record.overtimePay)}'),
                    _detailTag(Icons.emoji_events_rounded,
                        'Bonus: ${_currency(record.bonus)}'),
                    _detailTag(Icons.remove_circle_outline_rounded,
                        'Deductions: ${_currency(record.deductions)}'),
                    _detailTag(Icons.credit_card_rounded,
                        'Bank: ••••${record.bankLast4}'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailTag(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF475569),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── Activity Panel ─────────────────────────────────────────────────────────

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
                    'Export History',
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
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_activity.length}',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
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
                      Icons.file_download_off_rounded,
                      size: 32,
                      color: Color(0xFFCBD5E1),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No exports yet.',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Exported statements will appear here.',
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
                        horizontal: 12, vertical: 10),
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
                            color: _formatColor(item.format).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _formatIcon(item.format),
                            size: 18,
                            color: _formatColor(item.format),
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
                                  fontSize: 13,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                '${item.employeeId}  •  ${item.format}  •  ${_currency(item.net)}',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          item.timestamp,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
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

  // ── Footer ─────────────────────────────────────────────────────────────────

  Widget _buildFooter(bool isWide) {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: isWide
          ? Row(
              children: [
                const Icon(Icons.file_download_done_rounded,
                    color: Color(0xFF2563EB)),
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
                        const TextSpan(text: ' — Net total: '),
                        TextSpan(
                          text: _currency(_selectedNet),
                          style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Format selector
                _formatSelector(),
                const SizedBox(width: 14),
                FilledButton.icon(
                  onPressed: _exportSelected,
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: Text('Export as $_exportFormat'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
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
                    const Icon(Icons.file_download_done_rounded,
                        color: Color(0xFF2563EB)),
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
                            text: _currency(_selectedNet),
                            style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _formatSelector(),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _exportSelected,
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text('Export as $_exportFormat'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
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

  Widget _formatSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _formats.map((fmt) {
        final selected = fmt == _exportFormat;
        return GestureDetector(
          onTap: () => setState(() => _exportFormat = fmt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? _formatColor(fmt) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? _formatColor(fmt) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _formatIcon(fmt),
                  size: 14,
                  color: selected ? Colors.white : const Color(0xFF64748B),
                ),
                const SizedBox(width: 5),
                Text(
                  fmt,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: selected ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Color _formatColor(String fmt) {
    switch (fmt) {
      case 'CSV':
        return const Color(0xFF16A34A);
      case 'Excel':
        return const Color(0xFF0F766E);
      default:
        return const Color(0xFFDC2626);
    }
  }

  IconData _formatIcon(String fmt) {
    switch (fmt) {
      case 'CSV':
        return Icons.table_chart_rounded;
      case 'Excel':
        return Icons.grid_on_rounded;
      default:
        return Icons.picture_as_pdf_rounded;
    }
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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

// ── Data Models ───────────────────────────────────────────────────────────────

class _SalaryRecord {
  const _SalaryRecord({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.baseSalary,
    required this.overtimePay,
    required this.bonus,
    required this.deductions,
    required this.payPeriod,
    required this.payDate,
    required this.status,
    required this.bankLast4,
  });

  final String id;
  final String name;
  final String role;
  final String department;
  final double baseSalary;
  final double overtimePay;
  final double bonus;
  final double deductions;
  final String payPeriod;
  final String payDate;
  final String status;
  final String bankLast4;

  double get netPay => baseSalary + overtimePay + bonus - deductions;
}

class _ExportActivity {
  const _ExportActivity({
    required this.employeeId,
    required this.name,
    required this.format,
    required this.net,
    required this.timestamp,
  });

  final String employeeId;
  final String name;
  final String format;
  final double net;
  final String timestamp;
}
