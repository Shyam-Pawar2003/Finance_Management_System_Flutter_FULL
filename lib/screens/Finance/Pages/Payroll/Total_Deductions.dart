import 'package:flutter/material.dart';

class TotalDeductionsPage extends StatefulWidget {
  const TotalDeductionsPage({super.key});

  @override
  State<TotalDeductionsPage> createState() => _TotalDeductionsPageState();
}

class _TotalDeductionsPageState extends State<TotalDeductionsPage> {
  final List<_DeductionRecord> _records = const [
    _DeductionRecord(
      id: 'EMP-101',
      name: 'Rhaenyra Targaryen',
      role: 'Product Designer',
      department: 'Design',
      incomeTax: 280,
      providentFund: 180,
      healthInsurance: 120,
      loanRepayment: 0,
      other: 60,
      payPeriod: 'March 2026',
    ),
    _DeductionRecord(
      id: 'EMP-102',
      name: 'Daemon Targaryen',
      role: 'Finance Manager',
      department: 'Finance',
      incomeTax: 420,
      providentFund: 220,
      healthInsurance: 150,
      loanRepayment: 100,
      other: 0,
      payPeriod: 'March 2026',
    ),
    _DeductionRecord(
      id: 'EMP-103',
      name: 'Jon Snow',
      role: 'Senior Engineer',
      department: 'Engineering',
      incomeTax: 510,
      providentFund: 280,
      healthInsurance: 120,
      loanRepayment: 140,
      other: 0,
      payPeriod: 'March 2026',
    ),
    _DeductionRecord(
      id: 'EMP-104',
      name: 'Arya Stark',
      role: 'QA Engineer',
      department: 'Engineering',
      incomeTax: 320,
      providentFund: 200,
      healthInsurance: 120,
      loanRepayment: 0,
      other: 140,
      payPeriod: 'March 2026',
    ),
    _DeductionRecord(
      id: 'EMP-105',
      name: 'Tyrion Lannister',
      role: 'Operations Lead',
      department: 'Operations',
      incomeTax: 380,
      providentFund: 240,
      healthInsurance: 150,
      loanRepayment: 170,
      other: 0,
      payPeriod: 'March 2026',
    ),
    _DeductionRecord(
      id: 'EMP-106',
      name: 'Sansa Stark',
      role: 'HR Specialist',
      department: 'HR',
      incomeTax: 290,
      providentFund: 180,
      healthInsurance: 120,
      loanRepayment: 0,
      other: 130,
      payPeriod: 'March 2026',
    ),
  ];

  final List<_DeductionActivity> _activity = [];
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};

  String _searchQuery = '';
  String _selectedDept = 'All';
  String _selectedType = 'All';
  bool _showBreakdown = true;

  static const List<String> _deductionTypes = [
    'All',
    'Income Tax',
    'Provident Fund',
    'Health Insurance',
    'Loan Repayment',
    'Other',
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
    final depts = _records.map((r) => r.department).toSet().toList()..sort();
    return ['All', ...depts];
  }

  List<_DeductionRecord> get _filteredRecords {
    final query = _searchQuery.trim().toLowerCase();
    return _records.where((r) {
      final matchesSearch = query.isEmpty ||
          r.name.toLowerCase().contains(query) ||
          r.id.toLowerCase().contains(query) ||
          r.role.toLowerCase().contains(query) ||
          r.department.toLowerCase().contains(query);
      final matchesDept =
          _selectedDept == 'All' || r.department == _selectedDept;
      final matchesType = _selectedType == 'All' ||
          (_selectedType == 'Income Tax' && r.incomeTax > 0) ||
          (_selectedType == 'Provident Fund' && r.providentFund > 0) ||
          (_selectedType == 'Health Insurance' && r.healthInsurance > 0) ||
          (_selectedType == 'Loan Repayment' && r.loanRepayment > 0) ||
          (_selectedType == 'Other' && r.other > 0);
      return matchesSearch && matchesDept && matchesType;
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

  double get _totalDeductions => _records.fold(0, (sum, r) => sum + r.total);

  double get _selectedDeductions => _records
      .where((r) => _selectedIds.contains(r.id))
      .fold(0, (sum, r) => sum + r.total);

  double get _reviewedTotal => _activity.fold(
      0, (sum, a) => a.action == 'Approved' ? sum + a.amount : sum);

  double get _totalTax => _records.fold(0, (sum, r) => sum + r.incomeTax);
  double get _totalPF => _records.fold(0, (sum, r) => sum + r.providentFund);
  double get _totalInsurance =>
      _records.fold(0, (sum, r) => sum + r.healthInsurance);
  double get _totalLoan => _records.fold(0, (sum, r) => sum + r.loanRepayment);

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

  void _approveSelected() {
    if (_selectedIds.isEmpty) {
      _showMessage('Select at least one record to approve.');
      return;
    }
    final toApprove = _records
        .where((r) => _selectedIds.contains(r.id))
        .toList(growable: false);

    setState(() {
      _activity.insertAll(
        0,
        toApprove.map(
          (r) => _DeductionActivity(
            employeeId: r.id,
            name: r.name,
            amount: r.total,
            action: 'Approved',
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF16A34A),
          ),
        ),
      );
    });

    _showMessage(
        '${toApprove.length} deduction record(s) approved — ${_currency(_selectedDeductions)} confirmed.');
  }

  void _approveItem(_DeductionRecord record) {
    setState(() {
      _activity.insert(
        0,
        _DeductionActivity(
          employeeId: record.id,
          name: record.name,
          amount: record.total,
          action: 'Approved',
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF16A34A),
        ),
      );
    });
    _showMessage(
        '${record.name} deductions approved — ${_currency(record.total)}.');
  }

  void _flagItem(_DeductionRecord record) {
    setState(() {
      _activity.insert(
        0,
        _DeductionActivity(
          employeeId: record.id,
          name: record.name,
          amount: record.total,
          action: 'Flagged',
          icon: Icons.flag_rounded,
          color: const Color(0xFFD97706),
        ),
      );
    });
    _showMessage('${record.name} deductions flagged for review.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _filteredRecords;
    final allSelected =
        visible.isNotEmpty && visible.every((r) => _selectedIds.contains(r.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: const Text('Total Deductions'),
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
                      'Deductions Review Center',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 23,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Audit tax, provident fund, insurance and loan deductions before finalising the payroll cycle.',
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
                  Icons.remove_circle_outline_rounded,
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
              _heroChip('Total Deductions', _currency(_totalDeductions)),
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

  // ── Summary Row ────────────────────────────────────────────────────────────

  Widget _buildSummaryRow() {
    final summaries = [
      _Summary('Income Tax', _totalTax, Icons.account_balance_rounded,
          const Color(0xFFDC2626), const Color(0xFFFFE4E4)),
      _Summary('Provident Fund', _totalPF, Icons.savings_rounded,
          const Color(0xFF2563EB), const Color(0xFFDBEAFE)),
      _Summary(
          'Health Insurance',
          _totalInsurance,
          Icons.health_and_safety_rounded,
          const Color(0xFF0F766E),
          const Color(0xFFCCFBF1)),
      _Summary('Loan Repayment', _totalLoan, Icons.receipt_long_rounded,
          const Color(0xFFD97706), const Color(0xFFFEF3C7)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 560
                ? 2
                : 1;
        return GridView.count(
          crossAxisCount: crossCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: constraints.maxWidth < 560 ? 4 : 2.8,
          children: summaries.map((s) => _summaryCard(s)).toList(),
        );
      },
    );
  }

  Widget _summaryCard(_Summary s) {
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
              color: s.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(s.icon, color: s.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  s.label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currency(s.amount),
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

  // ── Records Panel ──────────────────────────────────────────────────────────

  Widget _buildRecordsPanel(List<_DeductionRecord> visible, bool allSelected) {
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
                        'Deduction Records',
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
                        color: const Color(0xFFDC2626),
                      ),
                      label: Text(
                        _showBreakdown ? 'Hide Breakdown' : 'Show Breakdown',
                        style: const TextStyle(
                          color: Color(0xFFDC2626),
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
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search by name, ID or department…',
                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Color(0xFF94A3B8)),
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
                      borderSide: const BorderSide(color: Color(0xFFDC2626)),
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
                // Deduction type filter
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _deductionTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final type = _deductionTypes[index];
                      final selected = type == _selectedType;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFDC2626)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFFDC2626)
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
                      value: allSelected,
                      onChanged: (v) => _toggleSelectAll(v ?? false),
                      activeColor: const Color(0xFFDC2626),
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

  Widget _buildRecordTile(_DeductionRecord record) {
    final selected = _selectedIds.contains(record.id);
    final initials =
        record.name.split(' ').take(2).map((w) => w[0]).join().toUpperCase();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: selected
          ? const Color(0xFFDC2626).withOpacity(0.03)
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
                  activeColor: const Color(0xFFDC2626),
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFDC2626).withOpacity(0.10),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Color(0xFFDC2626),
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
                Text(
                  _currency(record.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFDC2626),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 10),
                // Approve button
                _actionBtn(
                  label: 'Approve',
                  color: const Color(0xFF16A34A),
                  onTap: () => _approveItem(record),
                ),
                const SizedBox(width: 6),
                // Flag button
                _actionBtn(
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
                    if (record.incomeTax > 0)
                      _breakdownTag('Tax', record.incomeTax,
                          const Color(0xFFDC2626), const Color(0xFFFFE4E4)),
                    if (record.providentFund > 0)
                      _breakdownTag('PF', record.providentFund,
                          const Color(0xFF2563EB), const Color(0xFFDBEAFE)),
                    if (record.healthInsurance > 0)
                      _breakdownTag('Health', record.healthInsurance,
                          const Color(0xFF0F766E), const Color(0xFFCCFBF1)),
                    if (record.loanRepayment > 0)
                      _breakdownTag('Loan', record.loanRepayment,
                          const Color(0xFFD97706), const Color(0xFFFEF3C7)),
                    if (record.other > 0)
                      _breakdownTag('Other', record.other,
                          const Color(0xFF7C3AED), const Color(0xFFEDE9FE)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _breakdownTag(String label, double amount, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            _currency(amount),
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

  Widget _actionBtn({
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
                    color: const Color(0xFFDC2626).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_activity.length}',
                    style: const TextStyle(
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Approved deductions: ${_currency(_reviewedTotal)}',
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
                      'Approved or flagged records will appear here.',
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
                                '${item.employeeId}  •  ${item.action}  •  ${_currency(item.amount)}',
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

  // ── Footer ─────────────────────────────────────────────────────────────────

  Widget _buildFooter(bool isWide) {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: isWide
          ? Row(
              children: [
                const Icon(Icons.remove_circle_outline_rounded,
                    color: Color(0xFFDC2626)),
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
                        const TextSpan(text: ' — Selected deductions: '),
                        TextSpan(
                          text: _currency(_selectedDeductions),
                          style: const TextStyle(
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.w700),
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
                    const Icon(Icons.remove_circle_outline_rounded,
                        color: Color(0xFFDC2626)),
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
                            text: _currency(_selectedDeductions),
                            style: const TextStyle(
                                color: Color(0xFFDC2626),
                                fontWeight: FontWeight.w700),
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

  // ── Shared helpers ─────────────────────────────────────────────────────────

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

class _DeductionRecord {
  const _DeductionRecord({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.incomeTax,
    required this.providentFund,
    required this.healthInsurance,
    required this.loanRepayment,
    required this.other,
    required this.payPeriod,
  });

  final String id;
  final String name;
  final String role;
  final String department;
  final double incomeTax;
  final double providentFund;
  final double healthInsurance;
  final double loanRepayment;
  final double other;
  final String payPeriod;

  double get total =>
      incomeTax + providentFund + healthInsurance + loanRepayment + other;
}

class _DeductionActivity {
  const _DeductionActivity({
    required this.employeeId,
    required this.name,
    required this.amount,
    required this.action,
    required this.icon,
    required this.color,
  });

  final String employeeId;
  final String name;
  final double amount;
  final String action;
  final IconData icon;
  final Color color;
}

class _Summary {
  const _Summary(this.label, this.amount, this.icon, this.color, this.bg);
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final Color bg;
}
