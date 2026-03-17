import 'package:flutter/material.dart';

import 'Payroll/Approve_pending_payroll_records.dart';
import 'Payroll/Download_payroll_summary.dart';
import 'Payroll/Export_Sheet.dart';
import 'Payroll/Generate_bank_file.dart';

class SubAdminPayrollPage extends StatefulWidget {
  const SubAdminPayrollPage({super.key});

  @override
  State<SubAdminPayrollPage> createState() => _SubAdminPayrollPageState();
}

class _SubAdminPayrollPageState extends State<SubAdminPayrollPage> {
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  String _selectedStatus = 'All';
  String _selectedCycle = 'Mar 2026';

  late final TextEditingController _searchController;

  static const List<String> _statusOptions = [
    'All',
    'Ready',
    'Pending Review',
    'On Hold',
    'Processed',
  ];

  static const List<String> _cycleOptions = [
    'Mar 2026',
    'Feb 2026',
    'Jan 2026'
  ];

  final List<_PayrollRecord> _records = const [
    _PayrollRecord(
      id: 'PAY-2401',
      employee: 'Rahul Sharma',
      department: 'Finance',
      baseSalary: 8200,
      overtime: 420,
      bonus: 650,
      deduction: 380,
      status: 'Ready',
      bankStatus: 'Verified',
    ),
    _PayrollRecord(
      id: 'PAY-2402',
      employee: 'Neha Verma',
      department: 'HR',
      baseSalary: 7400,
      overtime: 210,
      bonus: 300,
      deduction: 460,
      status: 'Pending Review',
      bankStatus: 'Awaiting KYC',
    ),
    _PayrollRecord(
      id: 'PAY-2403',
      employee: 'Arjun Mehta',
      department: 'Operations',
      baseSalary: 6900,
      overtime: 520,
      bonus: 220,
      deduction: 510,
      status: 'Processed',
      bankStatus: 'Verified',
    ),
    _PayrollRecord(
      id: 'PAY-2404',
      employee: 'Sneha Iyer',
      department: 'HR',
      baseSalary: 6100,
      overtime: 160,
      bonus: 180,
      deduction: 260,
      status: 'Ready',
      bankStatus: 'Verified',
    ),
    _PayrollRecord(
      id: 'PAY-2405',
      employee: 'Karan Patel',
      department: 'Finance',
      baseSalary: 7800,
      overtime: 260,
      bonus: 500,
      deduction: 340,
      status: 'Processed',
      bankStatus: 'Verified',
    ),
    _PayrollRecord(
      id: 'PAY-2406',
      employee: 'Maya Nair',
      department: 'Operations',
      baseSalary: 6400,
      overtime: 380,
      bonus: 200,
      deduction: 430,
      status: 'On Hold',
      bankStatus: 'Bank mismatch',
    ),
    _PayrollRecord(
      id: 'PAY-2407',
      employee: 'Ishita Rao',
      department: 'Legal',
      baseSalary: 7100,
      overtime: 190,
      bonus: 340,
      deduction: 270,
      status: 'Ready',
      bankStatus: 'Verified',
    ),
    _PayrollRecord(
      id: 'PAY-2408',
      employee: 'Rohan Das',
      department: 'Operations',
      baseSalary: 5600,
      overtime: 240,
      bonus: 110,
      deduction: 320,
      status: 'Pending Review',
      bankStatus: 'Pending documents',
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

  void _openApprovePendingPayrollRecordsPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SubAdminApprovePendingPayrollRecordsPage(),
      ),
    );
  }

  void _openGenerateBankFilePage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SubAdminGenerateBankFilePage(),
      ),
    );
  }

  void _openDownloadPayrollSummaryPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SubAdminDownloadPayrollSummaryPage(),
      ),
    );
  }

  void _openExportSheetPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SubAdminExportSheetPage(),
      ),
    );
  }

  List<String> get _departments {
    final values = _records.map((record) => record.department).toSet().toList()
      ..sort();
    return ['All', ...values];
  }

  List<_PayrollRecord> get _filteredRecords {
    final query = _searchQuery.trim().toLowerCase();

    final list = _records.where((record) {
      final matchesSearch = query.isEmpty ||
          record.id.toLowerCase().contains(query) ||
          record.employee.toLowerCase().contains(query) ||
          record.department.toLowerCase().contains(query) ||
          record.bankStatus.toLowerCase().contains(query);

      final matchesDepartment = _selectedDepartment == 'All' ||
          record.department == _selectedDepartment;

      final matchesStatus =
          _selectedStatus == 'All' || record.status == _selectedStatus;

      return matchesSearch && matchesDepartment && matchesStatus;
    }).toList();

    list.sort((a, b) => _netPay(b).compareTo(_netPay(a)));
    return list;
  }

  double _grossPay(_PayrollRecord record) {
    return record.baseSalary + record.overtime + record.bonus;
  }

  double _netPay(_PayrollRecord record) {
    return _grossPay(record) - record.deduction;
  }

  double _totalNet(List<_PayrollRecord> list) {
    return list.fold<double>(0, (sum, record) => sum + _netPay(record));
  }

  double _totalDeductions(List<_PayrollRecord> list) {
    return list.fold<double>(0, (sum, record) => sum + record.deduction);
  }

  double _totalOvertime(List<_PayrollRecord> list) {
    return list.fold<double>(0, (sum, record) => sum + record.overtime);
  }

  double _totalBonus(List<_PayrollRecord> list) {
    return list.fold<double>(0, (sum, record) => sum + record.bonus);
  }

  int _countByStatus(List<_PayrollRecord> list, String status) {
    return list.where((record) => record.status == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 760;
        final isNarrow = width < 1140;
        final records = _filteredRecords;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isCompact),
              const SizedBox(height: 16),
              _buildHeroCard(records),
              const SizedBox(height: 16),
              _buildMetricGrid(width, records),
              const SizedBox(height: 16),
              _buildFilterPanel(isCompact),
              const SizedBox(height: 16),
              if (isNarrow) ...[
                _buildPayrollPanel(records, isCompact),
                const SizedBox(height: 14),
                _buildInsightsPanel(records),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildPayrollPanel(records, false),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildInsightsPanel(records),
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
          'Payroll',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 6),
        Text(
          'Manage salary cycles, validate payout quality, and resolve payroll exceptions.',
          style: TextStyle(color: Color(0xFF5F6368)),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: _openExportSheetPage,
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('Export Sheet'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1E293B),
            side: const BorderSide(color: Color(0xFFD5DEE9)),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
          label: const Text('Run Payroll'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF36B39C),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, const SizedBox(height: 10), actions],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        const SizedBox(width: 12),
        actions,
      ],
    );
  }

  Widget _buildHeroCard(List<_PayrollRecord> records) {
    final totalNet = _totalNet(records);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F355B), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.24),
            blurRadius: 22,
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
                'Active Payroll Cycle',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedCycle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Net payout ${_currency(totalNet)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _heroChip('Employees', '${records.length}'),
              _heroChip('Pending Review',
                  '${_countByStatus(records, 'Pending Review')}'),
              _heroChip('On Hold', '${_countByStatus(records, 'On Hold')}'),
              _heroChip('Processed', '${_countByStatus(records, 'Processed')}'),
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

  Widget _buildMetricGrid(double width, List<_PayrollRecord> records) {
    final crossAxisCount = width >= 1280
        ? 4
        : width >= 860
            ? 2
            : 1;

    final metrics = [
      _PayrollMetric(
        title: 'Total Net Payout',
        value: _currency(_totalNet(records)),
        subtitle: 'After deductions',
        icon: Icons.account_balance_wallet_outlined,
        color: const Color(0xFF1A73E8),
      ),
      _PayrollMetric(
        title: 'Total Deductions',
        value: _currency(_totalDeductions(records)),
        subtitle: 'Tax and compliance',
        icon: Icons.remove_circle_outline_rounded,
        color: const Color(0xFFF29900),
      ),
      _PayrollMetric(
        title: 'Overtime Cost',
        value: _currency(_totalOvertime(records)),
        subtitle: 'Additional shift cost',
        icon: Icons.access_time_filled_outlined,
        color: const Color(0xFF36B39C),
      ),
      _PayrollMetric(
        title: 'Bonus Allocation',
        value: _currency(_totalBonus(records)),
        subtitle: 'Performance rewards',
        icon: Icons.workspace_premium_outlined,
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
        return _panel(
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
        hintText: 'Search by employee, id, department, or bank status',
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
        if (value == null) return;
        setState(() {
          _selectedDepartment = value;
        });
      },
    );

    final status = DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: _inputDecoration(labelText: 'Status'),
      items: _statusOptions
          .map(
            (value) => DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _selectedStatus = value;
        });
      },
    );

    final cycle = DropdownButtonFormField<String>(
      value: _selectedCycle,
      decoration: _inputDecoration(labelText: 'Payroll Cycle'),
      items: _cycleOptions
          .map(
            (value) => DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _selectedCycle = value;
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
          _selectedCycle = 'Mar 2026';
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
            cycle,
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
                Expanded(flex: 2, child: cycle),
                const SizedBox(width: 8),
                reset,
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPayrollPanel(List<_PayrollRecord> records, bool isCompact) {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Payroll Register',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${records.length} records',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (records.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'No payroll records match your current filters.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ...records.map((record) => _payrollRow(record, isCompact)),
        ],
      ),
    );
  }

  Widget _payrollRow(_PayrollRecord record, bool isCompact) {
    final statusColor = _statusColor(record.status);
    final gross = _grossPay(record);
    final net = _netPay(record);

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          record.employee,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          '${record.id} | ${record.department} | Bank: ${record.bankStatus}',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _chip('Gross ${_currency(gross)}', const Color(0xFF1A73E8)),
            _chip('Deduction ${_currency(record.deduction)}',
                const Color(0xFFF29900)),
            _chip('Net ${_currency(net)}', const Color(0xFF0F9D58)),
          ],
        ),
      ],
    );

    final statusSection = Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        _chip(record.status, statusColor),
        _chip(record.bankStatus, const Color(0xFF334155)),
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
                          const Color(0xFF1A73E8).withOpacity(0.12),
                      child: Text(
                        _initials(record.employee),
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
                statusSection,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF1A73E8).withOpacity(0.12),
                  child: Text(
                    _initials(record.employee),
                    style: const TextStyle(
                      color: Color(0xFF1A73E8),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: details),
                const SizedBox(width: 10),
                SizedBox(width: 220, child: statusSection),
              ],
            ),
    );
  }

  Widget _buildInsightsPanel(List<_PayrollRecord> records) {
    final departmentTotals = _departmentTotals(records);
    final maxDepartmentValue =
        departmentTotals.isEmpty ? 1.0 : departmentTotals.first.total;
    final exceptionQueue = records
        .where((record) =>
            record.status == 'Pending Review' || record.status == 'On Hold')
        .toList();

    return Column(
      children: [
        _panel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Department Cost Split',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (departmentTotals.isEmpty)
                const Text(
                  'No department totals available.',
                  style: TextStyle(color: Color(0xFF64748B)),
                )
              else
                ...departmentTotals.map(
                  (row) {
                    final ratio = row.total / maxDepartmentValue;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  row.department,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                _currency(row.total),
                                style: const TextStyle(
                                  color: Color(0xFF1A73E8),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
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
                  },
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
                'Exception Queue',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (exceptionQueue.isEmpty)
                const Text(
                  'No exceptions pending. Great job.',
                  style: TextStyle(color: Color(0xFF64748B)),
                )
              else
                ...exceptionQueue.take(5).map(
                      (record) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
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
                                    record.employee,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${record.status} | ${record.bankStatus}',
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _currency(_netPay(record)),
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
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
                Icons.file_present_outlined,
                'Generate bank file',
                onPressed: _openGenerateBankFilePage,
              ),
              const SizedBox(height: 8),
              _actionButton(
                Icons.approval_rounded,
                'Approve pending payroll records',
                onPressed: _openApprovePendingPayrollRecordsPage,
              ),
              const SizedBox(height: 8),
              _actionButton(
                Icons.download_rounded,
                'Download payroll summary',
                onPressed: _openDownloadPayrollSummaryPage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<_DepartmentPayroll> _departmentTotals(List<_PayrollRecord> records) {
    final totals = <String, double>{};

    for (final record in records) {
      totals.update(
        record.department,
        (value) => value + _netPay(record),
        ifAbsent: () => _netPay(record),
      );
    }

    final rows = totals.entries
        .map((entry) => _DepartmentPayroll(entry.key, entry.value))
        .toList();
    rows.sort((a, b) => b.total.compareTo(a.total));
    return rows;
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

  String _currency(double value) {
    return '\$${value.toStringAsFixed(0)}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Ready':
        return const Color(0xFF1A73E8);
      case 'Pending Review':
        return const Color(0xFFF29900);
      case 'On Hold':
        return const Color(0xFFDB4437);
      case 'Processed':
        return const Color(0xFF0F9D58);
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

class _PayrollRecord {
  const _PayrollRecord({
    required this.id,
    required this.employee,
    required this.department,
    required this.baseSalary,
    required this.overtime,
    required this.bonus,
    required this.deduction,
    required this.status,
    required this.bankStatus,
  });

  final String id;
  final String employee;
  final String department;
  final double baseSalary;
  final double overtime;
  final double bonus;
  final double deduction;
  final String status;
  final String bankStatus;
}

class _PayrollMetric {
  const _PayrollMetric({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class _DepartmentPayroll {
  const _DepartmentPayroll(this.department, this.total);

  final String department;
  final double total;
}
