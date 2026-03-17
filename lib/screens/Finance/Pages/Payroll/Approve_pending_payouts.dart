import 'package:flutter/material.dart';

class ApprovePendingPayoutsPage extends StatefulWidget {
  const ApprovePendingPayoutsPage({super.key});

  @override
  State<ApprovePendingPayoutsPage> createState() =>
      _ApprovePendingPayoutsPageState();
}

class _ApprovePendingPayoutsPageState extends State<ApprovePendingPayoutsPage> {
  final List<_PayoutItem> _pending = [
    const _PayoutItem(
      id: 'EMP-103',
      name: 'Alicent Hightower',
      role: 'HR Manager',
      department: 'Human Resources',
      baseSalary: 8400,
      overtimePay: 310,
      bonus: 450,
      deductions: 720,
      payPeriod: 'March 2026',
      bankLast4: '4821',
    ),
    const _PayoutItem(
      id: 'EMP-105',
      name: 'Otto Hightower',
      role: 'Operations Lead',
      department: 'Operations',
      baseSalary: 9500,
      overtimePay: 0,
      bonus: 600,
      deductions: 850,
      payPeriod: 'March 2026',
      bankLast4: '3374',
    ),
    const _PayoutItem(
      id: 'EMP-107',
      name: 'Laena Velaryon',
      role: 'Frontend Engineer',
      department: 'Engineering',
      baseSalary: 7800,
      overtimePay: 520,
      bonus: 200,
      deductions: 690,
      payPeriod: 'March 2026',
      bankLast4: '9012',
    ),
    const _PayoutItem(
      id: 'EMP-109',
      name: 'Criston Cole',
      role: 'IT Security',
      department: 'IT',
      baseSalary: 6900,
      overtimePay: 180,
      bonus: 0,
      deductions: 610,
      payPeriod: 'March 2026',
      bankLast4: '7763',
    ),
    const _PayoutItem(
      id: 'EMP-112',
      name: 'Vaemond Velaryon',
      role: 'Data Analyst',
      department: 'Finance',
      baseSalary: 7200,
      overtimePay: 240,
      bonus: 350,
      deductions: 640,
      payPeriod: 'March 2026',
      bankLast4: '5590',
    ),
  ];

  final List<_ActivityItem> _activity = [];
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  String _searchQuery = '';
  String _filterDept = 'All';
  bool _showBreakdown = false;

  static const List<String> _departments = [
    'All',
    'Engineering',
    'Finance',
    'Human Resources',
    'IT',
    'Operations',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(_pending.map((e) => e.id));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _fmt(double amount) {
    final raw = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final ri = raw.length - i;
      buffer.write(raw[i]);
      if (ri > 1 && ri % 3 == 1) buffer.write(',');
    }
    return '\$${buffer.toString()}';
  }

  List<_PayoutItem> get _filtered {
    final q = _searchQuery.trim().toLowerCase();
    return _pending.where((item) {
      final matchesSearch = q.isEmpty ||
          item.id.toLowerCase().contains(q) ||
          item.name.toLowerCase().contains(q) ||
          item.role.toLowerCase().contains(q) ||
          item.department.toLowerCase().contains(q);
      final matchesDept =
          _filterDept == 'All' || item.department == _filterDept;
      return matchesSearch && matchesDept;
    }).toList();
  }

  double get _selectedTotal => _pending
      .where((e) => _selectedIds.contains(e.id))
      .fold(0, (s, e) => s + e.netPay);

  double get _pendingTotal => _pending.fold(0, (s, e) => s + e.netPay);

  void _approveSelected() {
    if (_selectedIds.isEmpty) {
      _snack('Select at least one payout to approve.');
      return;
    }
    final count = _selectedIds.length;
    final total = _selectedTotal;
    setState(() {
      final approved = _pending.where((e) => _selectedIds.contains(e.id));
      _activity.insertAll(
        0,
        approved.map(
          (e) => _ActivityItem(
            id: e.id,
            name: e.name,
            amount: e.netPay,
            action: 'Approved',
            color: const Color(0xFF16A34A),
            icon: Icons.check_circle_rounded,
          ),
        ),
      );
      _pending.removeWhere((e) => _selectedIds.contains(e.id));
      _selectedIds.clear();
    });
    _snack('$count payout(s) approved — ${_fmt(total)} queued for transfer.');
  }

  void _rejectItem(_PayoutItem item) {
    setState(() {
      _activity.insert(
        0,
        _ActivityItem(
          id: item.id,
          name: item.name,
          amount: item.netPay,
          action: 'Rejected',
          color: const Color(0xFFDC2626),
          icon: Icons.cancel_rounded,
        ),
      );
      _pending.remove(item);
      _selectedIds.remove(item.id);
    });
    _snack('${item.name}\'s payout rejected.');
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

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
    final visibleIds = _filtered.map((e) => e.id);
    setState(() {
      if (checked) {
        _selectedIds.addAll(visibleIds);
      } else {
        _selectedIds.removeWhere(visibleIds.contains);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _filtered;
    final allSelected =
        visible.isNotEmpty && visible.every((e) => _selectedIds.contains(e.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: const Text('Approve Pending Payouts'),
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
                            child: _buildQueuePanel(visible, allSelected),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 2,
                            child: _buildActivityPanel(),
                          ),
                        ],
                      )
                    else ...[
                      _buildQueuePanel(visible, allSelected),
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

  // ── Hero card ─────────────────────────────────────────────────────────────

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
                      'Payout Approval Hub',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 23,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Review, select and approve pending salary disbursements before they are transferred.',
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
                  Icons.approval_rounded,
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
              _heroChip('Awaiting approval', '${_pending.length}'),
              _heroChip('Pending total', _fmt(_pendingTotal)),
              _heroChip('Selected', '${_selectedIds.length}'),
              _heroChip(
                'Actioned',
                '${_activity.length} | ${_fmt(_activity.fold(0, (s, e) => s + e.amount))}',
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

  // ── Queue panel ───────────────────────────────────────────────────────────

  Widget _buildQueuePanel(List<_PayoutItem> visible, bool allSelected) {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Pending Queue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${visible.length} visible',
                  style: const TextStyle(
                    color: Color(0xFFD97706),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Salary disbursements awaiting your approval.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          // Search
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search by name, role, department or ID',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
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
          // Dept filter chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _departments.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final dept = _departments[i];
                final active = _filterDept == dept;
                return GestureDetector(
                  onTap: () => setState(() => _filterDept = dept),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: active
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFDDE3EA),
                      ),
                    ),
                    child: Text(
                      dept,
                      style: TextStyle(
                        color: active ? Colors.white : const Color(0xFF475569),
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
          // Select all + breakdown toggle
          Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: allSelected,
                  onChanged: (v) => _toggleSelectAll(v ?? false),
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
                onTap: () => setState(() => _showBreakdown = !_showBreakdown),
                child: Row(
                  children: [
                    Text(
                      _showBreakdown ? 'Hide breakdown' : 'Show breakdown',
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _showBreakdown
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
          if (_pending.isEmpty)
            _emptyState(
              icon: Icons.verified_rounded,
              color: const Color(0xFF16A34A),
              bg: const Color(0xFFF0FDF4),
              border: const Color(0xFFBBF7D0),
              message: 'All payouts approved. Queue is clear.',
            )
          else if (visible.isEmpty)
            _emptyState(
              icon: Icons.search_off_rounded,
              color: const Color(0xFF64748B),
              bg: const Color(0xFFF8FAFC),
              border: const Color(0xFFE2E8F0),
              message: 'No payouts match your search or filter.',
            )
          else
            ...visible.map((item) => _buildQueueCard(item)),
        ],
      ),
    );
  }

  Widget _buildQueueCard(_PayoutItem item) {
    final isSelected = _selectedIds.contains(item.id);
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
                    onChanged: (v) => _toggleSelect(item.id, v ?? false),
                  ),
                  const SizedBox(width: 6),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFDBEAFE),
                    child: Text(
                      item.name.split(' ').map((w) => w[0]).take(2).join(),
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
                          '${item.role} · ${item.department}',
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
                        _fmt(item.netPay),
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
              if (_showBreakdown) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _breakdownRow('Base Salary', item.baseSalary,
                          isDeduction: false),
                      if (item.overtimePay > 0)
                        _breakdownRow('Overtime', item.overtimePay,
                            isDeduction: false),
                      if (item.bonus > 0)
                        _breakdownRow('Bonus', item.bonus, isDeduction: false),
                      _breakdownRow('Deductions', item.deductions,
                          isDeduction: true),
                      const Divider(height: 14),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Net Pay',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          Text(
                            _fmt(item.netPay),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bank ···· ${item.bankLast4}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      item.payPeriod,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _actionBtn(
                    label: 'Reject',
                    color: const Color(0xFFDC2626),
                    bg: const Color(0xFFFFF1F2),
                    icon: Icons.close_rounded,
                    onTap: () => _rejectItem(item),
                  ),
                  const SizedBox(width: 8),
                  _actionBtn(
                    label: 'Approve',
                    color: const Color(0xFF16A34A),
                    bg: const Color(0xFFF0FDF4),
                    icon: Icons.check_rounded,
                    onTap: () {
                      _toggleSelect(item.id, true);
                      setState(() {
                        final done =
                            _pending.where((e) => e.id == item.id).toList();
                        _activity.insertAll(
                          0,
                          done.map(
                            (e) => _ActivityItem(
                              id: e.id,
                              name: e.name,
                              amount: e.netPay,
                              action: 'Approved',
                              color: const Color(0xFF16A34A),
                              icon: Icons.check_circle_rounded,
                            ),
                          ),
                        );
                        _pending.removeWhere((e) => e.id == item.id);
                        _selectedIds.remove(item.id);
                      });
                      _snack(
                          '${item.name}\'s payout approved — ${_fmt(item.netPay)}.');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _breakdownRow(String label, double amount,
      {required bool isDeduction}) {
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
            '${isDeduction ? '-' : '+'}${_fmt(amount)}',
            style: TextStyle(
              color: isDeduction
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF16A34A),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required String label,
    required Color color,
    required Color bg,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
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

  // ── Activity panel ────────────────────────────────────────────────────────

  Widget _buildActivityPanel() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity This Session',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Payouts approved or rejected during this session.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          if (_activity.isEmpty)
            _emptyState(
              icon: Icons.hourglass_empty_rounded,
              color: const Color(0xFF64748B),
              bg: const Color(0xFFF8FAFC),
              border: const Color(0xFFE2E8F0),
              message: 'No actions taken yet this session.',
            )
          else
            ..._activity.map(_buildActivityCard),
        ],
      ),
    );
  }

  Widget _buildActivityCard(_ActivityItem item) {
    final isApproved = item.action == 'Approved';
    final bg = isApproved ? const Color(0xFFF0FDF4) : const Color(0xFFFFF1F2);
    final border =
        isApproved ? const Color(0xFFBBF7D0) : const Color(0xFFFFCDD2);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
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
                _fmt(item.amount),
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

  // ── Footer ────────────────────────────────────────────────────────────────

  Widget _buildActionFooter(bool isWide) {
    final summary = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bulk Approve',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          '${_selectedIds.length} selected · ${_fmt(_selectedTotal)} net pay',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final approveBtn = ElevatedButton.icon(
      onPressed: _approveSelected,
      icon: const Icon(Icons.approval_rounded),
      label: const Text('Approve Selected'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0F355B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    return _panel(
      child: isWide
          ? Row(
              children: [
                Expanded(child: summary),
                const SizedBox(width: 12),
                approveBtn,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summary,
                const SizedBox(height: 10),
                SizedBox(width: double.infinity, child: approveBtn),
              ],
            ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _emptyState({
    required IconData icon,
    required Color color,
    required Color bg,
    required Color border,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
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

// ── Data models ──────────────────────────────────────────────────────────────

class _PayoutItem {
  const _PayoutItem({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.baseSalary,
    required this.overtimePay,
    required this.bonus,
    required this.deductions,
    required this.payPeriod,
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
  final String bankLast4;

  double get netPay => baseSalary + overtimePay + bonus - deductions;
}

class _ActivityItem {
  const _ActivityItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.action,
    required this.color,
    required this.icon,
  });

  final String id;
  final String name;
  final double amount;
  final String action;
  final Color color;
  final IconData icon;
}
