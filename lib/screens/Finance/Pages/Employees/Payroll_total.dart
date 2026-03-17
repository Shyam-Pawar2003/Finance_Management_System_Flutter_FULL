import 'package:flutter/material.dart';

class PayrollTotalPage extends StatefulWidget {
  const PayrollTotalPage({super.key});

  @override
  State<PayrollTotalPage> createState() => _PayrollTotalPageState();
}

class _PayrollTotalPageState extends State<PayrollTotalPage> {
  final List<_DepartmentPayroll> _departments = [
    const _DepartmentPayroll(
      id: 'DPT-01',
      department: 'Finance',
      headcount: 12,
      basePayroll: 64200,
      overtime: 2900,
      reimbursements: 1800,
      deductions: 5200,
      status: 'Ready',
    ),
    const _DepartmentPayroll(
      id: 'DPT-02',
      department: 'Accounting',
      headcount: 10,
      basePayroll: 49600,
      overtime: 1600,
      reimbursements: 900,
      deductions: 4300,
      status: 'Adjusted',
    ),
    const _DepartmentPayroll(
      id: 'DPT-03',
      department: 'HR',
      headcount: 7,
      basePayroll: 37100,
      overtime: 700,
      reimbursements: 500,
      deductions: 2900,
      status: 'Ready',
    ),
    const _DepartmentPayroll(
      id: 'DPT-04',
      department: 'Operations',
      headcount: 14,
      basePayroll: 68500,
      overtime: 3400,
      reimbursements: 2400,
      deductions: 6100,
      status: 'Needs Review',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  final List<_PayrollActivity> _activity = [];

  String _searchQuery = '';
  String _selectedStatus = 'All';
  bool _showBreakdown = true;

  static const List<String> _statuses = [
    'All',
    'Ready',
    'Adjusted',
    'Needs Review',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(_departments.map((e) => e.id));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_DepartmentPayroll> get _filteredDepartments {
    final q = _searchQuery.trim().toLowerCase();
    return _departments.where((item) {
      final matchesSearch = q.isEmpty ||
          item.department.toLowerCase().contains(q) ||
          item.id.toLowerCase().contains(q);
      final matchesStatus =
          _selectedStatus == 'All' || item.status == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();
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

  int get _totalHeadcount =>
      _departments.fold(0, (sum, item) => sum + item.headcount);

  double get _totalBase =>
      _departments.fold(0, (sum, item) => sum + item.basePayroll);

  double get _totalOvertime =>
      _departments.fold(0, (sum, item) => sum + item.overtime);

  double get _totalNet =>
      _departments.fold(0, (sum, item) => sum + item.netPayroll);

  double get _selectedNet => _departments
      .where((item) => _selectedIds.contains(item.id))
      .fold(0, (sum, item) => sum + item.netPayroll);

  double get _confirmedTotal => _activity.fold(
        0,
        (sum, item) => item.action == 'Confirmed' ? sum + item.amount : sum,
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
    final visibleIds = _filteredDepartments.map((e) => e.id);
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
      _showMessage('Select at least one department payroll total.');
      return;
    }

    final selected =
        _departments.where((item) => _selectedIds.contains(item.id)).toList();
    final total = _selectedNet;

    setState(() {
      _activity.insertAll(
        0,
        selected.map(
          (item) => _PayrollActivity(
            department: item.department,
            action: 'Confirmed',
            amount: item.netPayroll,
            color: const Color(0xFF16A34A),
            icon: Icons.check_circle_rounded,
          ),
        ),
      );
      _selectedIds.clear();
    });

    _showMessage(
      '${selected.length} payroll total(s) confirmed - ${_currency(total)}.',
    );
  }

  void _confirmItem(_DepartmentPayroll item) {
    setState(() {
      _activity.insert(
        0,
        _PayrollActivity(
          department: item.department,
          action: 'Confirmed',
          amount: item.netPayroll,
          color: const Color(0xFF16A34A),
          icon: Icons.check_circle_rounded,
        ),
      );
      _selectedIds.remove(item.id);
    });
    _showMessage('${item.department} payroll total confirmed.');
  }

  void _flagItem(_DepartmentPayroll item) {
    setState(() {
      _activity.insert(
        0,
        _PayrollActivity(
          department: item.department,
          action: 'Flagged',
          amount: item.netPayroll,
          color: const Color(0xFFD97706),
          icon: Icons.flag_rounded,
        ),
      );
      _selectedIds.remove(item.id);
    });
    _showMessage('${item.department} payroll flagged for review.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Ready':
        return const Color(0xFF16A34A);
      case 'Adjusted':
        return const Color(0xFF7C3AED);
      case 'Needs Review':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _filteredDepartments;
    final allVisibleSelected = visible.isNotEmpty &&
        visible.every((item) => _selectedIds.contains(item.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: const Text('Payroll Total'),
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
                              child: _buildDepartmentPanel(
                                  visible, allVisibleSelected)),
                          const SizedBox(width: 14),
                          Expanded(flex: 2, child: _buildActivityPanel()),
                        ],
                      )
                    else ...[
                      _buildDepartmentPanel(visible, allVisibleSelected),
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
            'Payroll Consolidation',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 23,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Review payroll totals by department before cycle lock and disbursement.',
            style:
                TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _heroChip('Headcount', '$_totalHeadcount'),
              _heroChip('Base Payroll', _currency(_totalBase)),
              _heroChip('Overtime', _currency(_totalOvertime)),
              _heroChip('Net Payroll', _currency(_totalNet)),
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

  Widget _buildDepartmentPanel(
      List<_DepartmentPayroll> visible, bool allVisibleSelected) {
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
                        'Department Payroll Totals',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
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
                        color: const Color(0xFF2563EB),
                      ),
                      label: Text(
                          _showBreakdown ? 'Hide Breakdown' : 'Show Breakdown'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search by department or code...',
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
                      '${visible.length} department(s)',
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
                  'No department totals match current filters.',
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
                  _buildDepartmentRow(visible[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildDepartmentRow(_DepartmentPayroll item) {
    final statusColor = _statusColor(item.status);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: _selectedIds.contains(item.id),
                onChanged: (value) => _toggleSelect(item.id, value ?? false),
                activeColor: const Color(0xFF2563EB),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.department,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                      '${item.id}  |  ${item.headcount} employees',
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              ),
              _chip(item.status, statusColor),
              const SizedBox(width: 10),
              Text(
                _currency(item.netPayroll),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 8),
              _actionButton(
                label: 'Confirm',
                color: const Color(0xFF16A34A),
                onTap: () => _confirmItem(item),
              ),
              const SizedBox(width: 6),
              _actionButton(
                label: 'Flag',
                color: const Color(0xFFD97706),
                onTap: () => _flagItem(item),
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
                  _smallChip('Base ${_currency(item.basePayroll)}',
                      const Color(0xFF2563EB), const Color(0xFFDBEAFE)),
                  _smallChip('OT ${_currency(item.overtime)}',
                      const Color(0xFF16A34A), const Color(0xFFDCFCE7)),
                  _smallChip('Reimb ${_currency(item.reimbursements)}',
                      const Color(0xFF7C3AED), const Color(0xFFEDE9FE)),
                  _smallChip('Deduct ${_currency(item.deductions)}',
                      const Color(0xFFDC2626), const Color(0xFFFFE4E4)),
                ],
              ),
            ),
          ],
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
            const Text(
              'Verification Activity',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Confirmed value: ${_currency(_confirmedTotal)}',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
            const SizedBox(height: 12),
            if (_activity.isEmpty)
              const Text('No verification actions yet.',
                  style: TextStyle(color: Color(0xFF94A3B8)))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activity.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = _activity[index];
                  return Container(
                    padding: const EdgeInsets.all(10),
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
                          child: Icon(item.icon, color: item.color, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${item.department}  |  ${item.action}  |  ${_currency(item.amount)}',
                            style: TextStyle(
                                color: item.color,
                                fontWeight: FontWeight.w700,
                                fontSize: 12),
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
                Expanded(
                  child: Text(
                    '${_selectedIds.length} selected  |  ${_currency(_selectedNet)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _confirmSelected,
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: const Text('Confirm Selected'),
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
                  '${_selectedIds.length} selected  |  ${_currency(_selectedNet)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _confirmSelected,
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: const Text('Confirm Selected'),
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

  Widget _smallChip(String text, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
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

class _DepartmentPayroll {
  const _DepartmentPayroll({
    required this.id,
    required this.department,
    required this.headcount,
    required this.basePayroll,
    required this.overtime,
    required this.reimbursements,
    required this.deductions,
    required this.status,
  });

  final String id;
  final String department;
  final int headcount;
  final double basePayroll;
  final double overtime;
  final double reimbursements;
  final double deductions;
  final String status;

  double get netPayroll => basePayroll + overtime + reimbursements - deductions;
}

class _PayrollActivity {
  const _PayrollActivity({
    required this.department,
    required this.action,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String department;
  final String action;
  final double amount;
  final Color color;
  final IconData icon;
}
