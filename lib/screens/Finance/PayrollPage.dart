import 'package:flutter/material.dart';

class PayrollPage extends StatefulWidget {
  const PayrollPage({super.key});

  @override
  State<PayrollPage> createState() => _PayrollPageState();
}

class _PayrollPageState extends State<PayrollPage> {
  String _selectedMonth = 'March 2026';
  String _selectedDepartment = 'All';
  String _selectedStatus = 'All';
  String _searchQuery = '';

  late final TextEditingController _searchController;

  static const List<String> _months = [
    'March 2026',
    'February 2026',
    'January 2026',
    'December 2025',
  ];

  static const List<String> _statusOptions = [
    'All',
    'Paid',
    'Pending',
    'Processing',
  ];

  static const List<_PayrollTrend> _trend = [
    _PayrollTrend(label: 'Oct', amount: 40200),
    _PayrollTrend(label: 'Nov', amount: 41500),
    _PayrollTrend(label: 'Dec', amount: 43800),
    _PayrollTrend(label: 'Jan', amount: 44600),
    _PayrollTrend(label: 'Feb', amount: 45150),
    _PayrollTrend(label: 'Mar', amount: 47240),
  ];

  final List<_PayrollSchedule> _schedule = const [
    _PayrollSchedule(
      title: 'Payroll Lock Date',
      date: 'Mar 14',
      note: 'Timesheets and overtime cutoff',
    ),
    _PayrollSchedule(
      title: 'Finance Review',
      date: 'Mar 16',
      note: 'Final validation and approvals',
    ),
    _PayrollSchedule(
      title: 'Disbursement',
      date: 'Mar 18',
      note: 'Salary transfer to all active staff',
    ),
  ];

  final List<_PayrollRecord> _records = const [
    _PayrollRecord(
      id: 'EMP-101',
      name: 'Rhaenyra Targaryen',
      email: 'rhaenyra@company.com',
      role: 'Product Designer',
      department: 'Design',
      status: 'Paid',
      baseSalary: 7200,
      overtimePay: 260,
      bonus: 300,
      deductions: 640,
      payDate: '2026-03-18',
    ),
    _PayrollRecord(
      id: 'EMP-102',
      name: 'Daemon Targaryen',
      email: 'daemon@company.com',
      role: 'Finance Manager',
      department: 'Finance',
      status: 'Paid',
      baseSalary: 9100,
      overtimePay: 120,
      bonus: 500,
      deductions: 820,
      payDate: '2026-03-18',
    ),
    _PayrollRecord(
      id: 'EMP-103',
      name: 'Jon Snow',
      email: 'jon@company.com',
      role: 'Graphic Designer',
      department: 'Design',
      status: 'Pending',
      baseSalary: 6100,
      overtimePay: 210,
      bonus: 0,
      deductions: 540,
      payDate: '2026-03-19',
    ),
    _PayrollRecord(
      id: 'EMP-104',
      name: 'Arya Stark',
      email: 'arya@company.com',
      role: 'QA Engineer',
      department: 'Engineering',
      status: 'Processing',
      baseSalary: 6700,
      overtimePay: 320,
      bonus: 180,
      deductions: 610,
      payDate: '2026-03-19',
    ),
    _PayrollRecord(
      id: 'EMP-105',
      name: 'Tyrion Lannister',
      email: 'tyrion@company.com',
      role: 'Operations Lead',
      department: 'Operations',
      status: 'Pending',
      baseSalary: 7600,
      overtimePay: 140,
      bonus: 350,
      deductions: 700,
      payDate: '2026-03-19',
    ),
    _PayrollRecord(
      id: 'EMP-106',
      name: 'Sansa Stark',
      email: 'sansa@company.com',
      role: 'HR Manager',
      department: 'HR',
      status: 'Paid',
      baseSalary: 6900,
      overtimePay: 0,
      bonus: 240,
      deductions: 615,
      payDate: '2026-03-18',
    ),
    _PayrollRecord(
      id: 'EMP-107',
      name: 'Bran Stark',
      email: 'bran@company.com',
      role: 'Data Analyst',
      department: 'Finance',
      status: 'Processing',
      baseSalary: 6400,
      overtimePay: 150,
      bonus: 0,
      deductions: 560,
      payDate: '2026-03-19',
    ),
    _PayrollRecord(
      id: 'EMP-108',
      name: 'Jaime Lannister',
      email: 'jaime@company.com',
      role: 'Sales Executive',
      department: 'Sales',
      status: 'Paid',
      baseSalary: 5800,
      overtimePay: 90,
      bonus: 420,
      deductions: 515,
      payDate: '2026-03-18',
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
    final values = _records.map((e) => e.department).toSet().toList()..sort();
    return ['All', ...values];
  }

  List<_PayrollRecord> get _filteredRecords {
    final query = _searchQuery.trim().toLowerCase();
    return _records.where((record) {
      final matchesSearch = query.isEmpty ||
          record.name.toLowerCase().contains(query) ||
          record.id.toLowerCase().contains(query) ||
          record.email.toLowerCase().contains(query) ||
          record.role.toLowerCase().contains(query);
      final matchesDepartment = _selectedDepartment == 'All' ||
          record.department == _selectedDepartment;
      final matchesStatus =
          _selectedStatus == 'All' || record.status == _selectedStatus;
      return matchesSearch && matchesDepartment && matchesStatus;
    }).toList();
  }

  double _sumNetPay(List<_PayrollRecord> records) {
    return records.fold(0, (sum, record) => sum + record.netPay);
  }

  double _sumOvertime(List<_PayrollRecord> records) {
    return records.fold(0, (sum, record) => sum + record.overtimePay);
  }

  double _sumDeductions(List<_PayrollRecord> records) {
    return records.fold(0, (sum, record) => sum + record.deductions);
  }

  double _sumBonus(List<_PayrollRecord> records) {
    return records.fold(0, (sum, record) => sum + record.bonus);
  }

  int _countStatus(List<_PayrollRecord> records, String status) {
    return records.where((record) => record.status == status).length;
  }

  String _currency(double amount) {
    final isNegative = amount < 0;
    final value = amount.abs().round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      final reverseIndex = value.length - i;
      buffer.write(value[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return '${isNegative ? '-' : ''}\$${buffer.toString()}';
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
              const SizedBox(height: 18),
              _buildHeroCard(records),
              const SizedBox(height: 18),
              _buildKpiGrid(width, records),
              const SizedBox(height: 16),
              _buildTrendCard(),
              const SizedBox(height: 16),
              _buildFiltersCard(isCompact),
              const SizedBox(height: 16),
              if (isNarrow) ...[
                _buildPayrollRecordsCard(records, isCompact),
                const SizedBox(height: 16),
                _buildSideInsights(records),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildPayrollRecordsCard(records, false),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildSideInsights(records),
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
          'Manage salary cycles, disbursement status, and payroll risk.',
          style: TextStyle(color: Color(0xFF5F6368)),
        ),
      ],
    );

    final controls = Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<String>(
            value: _selectedMonth,
            items: _months
                .map((month) =>
                    DropdownMenuItem(value: month, child: Text(month)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedMonth = value;
                });
              }
            },
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
              ),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.playlist_add_check_rounded, size: 18),
          label: const Text('Run Payroll'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A73E8),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, const SizedBox(height: 12), controls],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        const SizedBox(width: 14),
        controls,
      ],
    );
  }

  Widget _buildHeroCard(List<_PayrollRecord> records) {
    final netPay = _sumNetPay(records);
    final paid = _countStatus(records, 'Paid');
    final pending = _countStatus(records, 'Pending');
    final processing = _countStatus(records, 'Processing');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF123A68), Color(0xFF1A73E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withOpacity(0.25),
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
              Text(
                'Net Payroll for $_selectedMonth',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currency(netPay),
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
              _heroBadge('Paid', '$paid'),
              _heroBadge('Pending', '$pending'),
              _heroBadge('Processing', '$processing'),
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

  Widget _buildKpiGrid(double width, List<_PayrollRecord> records) {
    final cards = [
      _PayrollKpiData(
        title: 'Employees in Cycle',
        value: '${records.length}',
        subtitle: 'Current filtered set',
        icon: Icons.groups_2_rounded,
        color: const Color(0xFF1A73E8),
      ),
      _PayrollKpiData(
        title: 'Total Overtime',
        value: _currency(_sumOvertime(records)),
        subtitle: 'Extra-hours payout',
        icon: Icons.schedule_rounded,
        color: const Color(0xFF0F9D58),
      ),
      _PayrollKpiData(
        title: 'Total Deductions',
        value: _currency(_sumDeductions(records)),
        subtitle: 'Tax, PF and adjustments',
        icon: Icons.remove_circle_outline_rounded,
        color: const Color(0xFFDB4437),
      ),
      _PayrollKpiData(
        title: 'Bonuses',
        value: _currency(_sumBonus(records)),
        subtitle: 'Incentive allocation',
        icon: Icons.workspace_premium_rounded,
        color: const Color(0xFFF29900),
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

  Widget _buildTrendCard() {
    final maxAmount = _trend
        .map((item) => item.amount)
        .fold<double>(0, (max, current) => current > max ? current : max);

    return _panel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payroll Trend',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Net payroll movement over the last 6 months',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _trend
                .map(
                  (item) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 130,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: 18,
                                height: maxAmount == 0
                                    ? 0
                                    : (item.amount / maxAmount) * 120,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1A73E8),
                                      Color(0xFF79AFFF),
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.label,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _currency(item.amount),
                            style: const TextStyle(
                              color: Color(0xFF334155),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersCard(bool isCompact) {
    final searchInput = TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        hintText: 'Search by employee, id, email, or role',
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
        _searchController.clear();
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
            searchInput,
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerLeft, child: resetButton),
          ] else
            Row(
              children: [
                Expanded(child: searchInput),
                const SizedBox(width: 10),
                resetButton,
              ],
            ),
          const SizedBox(height: 12),
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

  Widget _buildPayrollRecordsCard(
      List<_PayrollRecord> records, bool isCompact) {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Payroll Records',
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
          const SizedBox(height: 6),
          const Text(
            'Breakdown of salary, deductions, and payout status',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          if (records.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'No payroll records match the selected filters.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ...records
                .map((record) => _buildPayrollRecordRow(record, isCompact))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildPayrollRecordRow(_PayrollRecord record, bool isCompact) {
    final statusColor = _statusColor(record.status);
    final initials = record.name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join();

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          record.name,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 2),
        Text(
          '${record.id} | ${record.role}',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          '${record.email} | Pay date: ${record.payDate}',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
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
                  backgroundColor: const Color(0xFF1A73E8).withOpacity(0.14),
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
                _chip(record.department, const Color(0xFF123A68)),
                _chip(record.status, statusColor),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Base: ${_currency(record.baseSalary)} | Overtime: ${_currency(record.overtimePay)}',
              style: const TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Deductions: ${_currency(record.deductions)} | Net: ${_currency(record.netPay)}',
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
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
          _chip(record.department, const Color(0xFF123A68)),
          const SizedBox(width: 8),
          _chip(record.status, statusColor),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              _currency(record.netPay),
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideInsights(List<_PayrollRecord> records) {
    final byDepartment = <String, double>{};
    for (final record in records) {
      byDepartment.update(
        record.department,
        (value) => value + record.netPay,
        ifAbsent: () => record.netPay,
      );
    }

    final deptList = byDepartment.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxDept = deptList.isEmpty ? 1.0 : deptList.first.value;

    final pending = records.where((record) => record.status != 'Paid').toList()
      ..sort((a, b) => b.netPay.compareTo(a.netPay));

    return Column(
      children: [
        _panel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Department Payroll Load',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (deptList.isEmpty)
                const Text(
                  'No data available for selected filters.',
                  style: TextStyle(color: Color(0xFF64748B)),
                )
              else
                ...deptList.map((entry) {
                  final ratio = entry.value / maxDept;
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
                              _currency(entry.value),
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
                'Pending Disbursements',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (pending.isEmpty)
                const Text(
                  'All payroll records are paid.',
                  style: TextStyle(color: Color(0xFF64748B)),
                )
              else
                ...pending.take(4).map(
                      (record) => Container(
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
                                    record.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${record.status} | ${record.payDate}',
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _currency(record.netPay),
                              style: const TextStyle(
                                color: Color(0xFFF29900),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 4),
              const Text(
                'Cycle Calendar',
                style: TextStyle(
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ..._schedule.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFF1A73E8).withOpacity(0.12),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.event_note_rounded,
                          color: Color(0xFF1A73E8),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${item.date} | ${item.note}',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _quickAction(
                icon: Icons.file_download_done_rounded,
                label: 'Export salary statements',
                color: const Color(0xFF1A73E8),
              ),
              const SizedBox(height: 8),
              _quickAction(
                icon: Icons.fact_check_rounded,
                label: 'Approve pending payouts',
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
      case 'Paid':
        return const Color(0xFF0F9D58);
      case 'Pending':
        return const Color(0xFFF29900);
      case 'Processing':
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

class _PayrollRecord {
  const _PayrollRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.status,
    required this.baseSalary,
    required this.overtimePay,
    required this.bonus,
    required this.deductions,
    required this.payDate,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String department;
  final String status;
  final double baseSalary;
  final double overtimePay;
  final double bonus;
  final double deductions;
  final String payDate;

  double get netPay => baseSalary + overtimePay + bonus - deductions;
}

class _PayrollKpiData {
  const _PayrollKpiData({
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

class _PayrollTrend {
  const _PayrollTrend({required this.label, required this.amount});

  final String label;
  final double amount;
}

class _PayrollSchedule {
  const _PayrollSchedule({
    required this.title,
    required this.date,
    required this.note,
  });

  final String title;
  final String date;
  final String note;
}
