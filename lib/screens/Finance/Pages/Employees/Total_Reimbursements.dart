import 'package:flutter/material.dart';

class TotalReimbursementsPage extends StatefulWidget {
  const TotalReimbursementsPage({super.key});

  @override
  State<TotalReimbursementsPage> createState() =>
      _TotalReimbursementsPageState();
}

class _TotalReimbursementsPageState extends State<TotalReimbursementsPage> {
  final List<_ReimbursementItem> _items = [
    const _ReimbursementItem(
      id: 'RB-801',
      employeeId: 'EMP-001',
      name: 'John Doe',
      department: 'Finance',
      category: 'Travel',
      amount: 120,
      status: 'Pending',
      submittedOn: '12 Mar 2026',
    ),
    const _ReimbursementItem(
      id: 'RB-802',
      employeeId: 'EMP-003',
      name: 'Mike Johnson',
      department: 'Finance',
      category: 'Meals',
      amount: 86,
      status: 'Pending',
      submittedOn: '12 Mar 2026',
    ),
    const _ReimbursementItem(
      id: 'RB-803',
      employeeId: 'EMP-004',
      name: 'Sarah Williams',
      department: 'HR',
      category: 'Training',
      amount: 260,
      status: 'Approved',
      submittedOn: '13 Mar 2026',
    ),
    const _ReimbursementItem(
      id: 'RB-804',
      employeeId: 'EMP-005',
      name: 'Tom Brown',
      department: 'Operations',
      category: 'Office Supplies',
      amount: 145,
      status: 'Pending',
      submittedOn: '14 Mar 2026',
    ),
    const _ReimbursementItem(
      id: 'RB-805',
      employeeId: 'EMP-006',
      name: 'Aisha Khan',
      department: 'Accounting',
      category: 'Travel',
      amount: 198,
      status: 'Approved',
      submittedOn: '14 Mar 2026',
    ),
    const _ReimbursementItem(
      id: 'RB-806',
      employeeId: 'EMP-002',
      name: 'Jane Smith',
      department: 'Accounting',
      category: 'Training',
      amount: 210,
      status: 'Pending',
      submittedOn: '15 Mar 2026',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  final List<_ReimbursementActivity> _activity = [];

  String _searchQuery = '';
  String _selectedDepartment = 'All';
  String _selectedStatus = 'All';

  static const List<String> _statuses = ['All', 'Pending', 'Approved'];

  @override
  void initState() {
    super.initState();
    _selectedIds
        .addAll(_items.where((e) => e.status == 'Pending').map((e) => e.id));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _departments {
    final values = _items.map((e) => e.department).toSet().toList()..sort();
    return ['All', ...values];
  }

  List<_ReimbursementItem> get _filteredItems {
    final q = _searchQuery.trim().toLowerCase();
    return _items.where((item) {
      final matchesSearch = q.isEmpty ||
          item.name.toLowerCase().contains(q) ||
          item.employeeId.toLowerCase().contains(q) ||
          item.id.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q);

      final matchesDepartment = _selectedDepartment == 'All' ||
          item.department == _selectedDepartment;

      final matchesStatus =
          _selectedStatus == 'All' || item.status == _selectedStatus;

      return matchesSearch && matchesDepartment && matchesStatus;
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

  double get _totalAmount => _items.fold(0, (sum, item) => sum + item.amount);

  double get _pendingAmount => _items
      .where((item) => item.status == 'Pending')
      .fold(0, (sum, item) => sum + item.amount);

  double get _approvedAmount => _items
      .where((item) => item.status == 'Approved')
      .fold(0, (sum, item) => sum + item.amount);

  double get _selectedAmount => _items
      .where((item) => _selectedIds.contains(item.id))
      .fold(0, (sum, item) => sum + item.amount);

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
    final visiblePendingIds = _filteredItems
        .where((item) => item.status == 'Pending')
        .map((item) => item.id);

    setState(() {
      if (checked) {
        _selectedIds.addAll(visiblePendingIds);
      } else {
        _selectedIds.removeWhere(visiblePendingIds.contains);
      }
    });
  }

  void _approveSelected() {
    if (_selectedIds.isEmpty) {
      _showMessage('Select at least one pending reimbursement.');
      return;
    }

    final selected =
        _items.where((item) => _selectedIds.contains(item.id)).toList();
    final total = _selectedAmount;

    setState(() {
      for (final item in selected) {
        final index = _items.indexOf(item);
        if (index >= 0) {
          _items[index] = item.copyWith(status: 'Approved');
        }
      }
      _activity.insertAll(
        0,
        selected.map(
          (item) => _ReimbursementActivity(
            employeeId: item.employeeId,
            name: item.name,
            action: 'Approved',
            amount: item.amount,
            color: const Color(0xFF16A34A),
            icon: Icons.check_circle_rounded,
          ),
        ),
      );
      _selectedIds.clear();
    });

    _showMessage(
        '${selected.length} reimbursements approved - ${_currency(total)}.');
  }

  void _approveSingle(_ReimbursementItem item) {
    setState(() {
      final index = _items.indexOf(item);
      if (index >= 0) {
        _items[index] = item.copyWith(status: 'Approved');
      }
      _selectedIds.remove(item.id);
      _activity.insert(
        0,
        _ReimbursementActivity(
          employeeId: item.employeeId,
          name: item.name,
          action: 'Approved',
          amount: item.amount,
          color: const Color(0xFF16A34A),
          icon: Icons.check_circle_rounded,
        ),
      );
    });
    _showMessage('${item.name} reimbursement approved.');
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return const Color(0xFF16A34A);
      case 'Pending':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Travel':
        return const Color(0xFF2563EB);
      case 'Meals':
        return const Color(0xFF7C3AED);
      case 'Training':
        return const Color(0xFF0F766E);
      default:
        return const Color(0xFFD97706);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _filteredItems;
    final pendingVisible =
        visible.where((item) => item.status == 'Pending').toList();
    final allVisiblePendingSelected = pendingVisible.isNotEmpty &&
        pendingVisible.every((item) => _selectedIds.contains(item.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: const Text('Total Reimbursements'),
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
                              child: _buildListPanel(
                                  visible, allVisiblePendingSelected)),
                          const SizedBox(width: 14),
                          Expanded(flex: 2, child: _buildActivityPanel()),
                        ],
                      )
                    else ...[
                      _buildListPanel(visible, allVisiblePendingSelected),
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
            'Reimbursement Totals',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 23,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Monitor total reimbursement liability and close pending requests quickly.',
            style:
                TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _heroChip('Total', _currency(_totalAmount)),
              _heroChip('Pending', _currency(_pendingAmount)),
              _heroChip('Approved', _currency(_approvedAmount)),
              _heroChip('Selected', _currency(_selectedAmount)),
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

  Widget _buildListPanel(
      List<_ReimbursementItem> visible, bool allVisiblePendingSelected) {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reimbursement Register',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search by employee, id, category...',
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
                      value: allVisiblePendingSelected,
                      onChanged: (value) => _toggleSelectAll(value ?? false),
                      activeColor: const Color(0xFF2563EB),
                    ),
                    const Text('Select pending visible'),
                    const Spacer(),
                    Text(
                      '${visible.length} request(s)',
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
                  'No reimbursement records match current filters.',
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
              itemBuilder: (context, index) => _buildRow(visible[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(_ReimbursementItem item) {
    final statusColor = _statusColor(item.status);
    final canApprove = item.status == 'Pending';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Checkbox(
            value: _selectedIds.contains(item.id),
            onChanged: canApprove
                ? (value) => _toggleSelect(item.id, value ?? false)
                : null,
            activeColor: const Color(0xFF2563EB),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  '${item.employeeId}  |  ${item.id}  |  ${item.submittedOn}',
                  style:
                      const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
              ],
            ),
          ),
          _chip(item.category, _categoryColor(item.category)),
          const SizedBox(width: 8),
          _chip(item.status, statusColor),
          const SizedBox(width: 10),
          Text(
            _currency(item.amount),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 10),
          if (canApprove)
            TextButton.icon(
              onPressed: () => _approveSingle(item),
              icon: const Icon(Icons.check_circle_rounded, size: 16),
              label: const Text('Approve'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF16A34A),
                backgroundColor: const Color(0xFF16A34A).withOpacity(0.10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityPanel() {
    final byCategory = <String, double>{};
    for (final item in _items) {
      byCategory.update(item.category, (value) => value + item.amount,
          ifAbsent: () => item.amount);
    }

    final categoryEntries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCategory =
        categoryEntries.isEmpty ? 1.0 : categoryEntries.first.value;

    return Column(
      children: [
        _panel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Category Distribution',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ...categoryEntries.map((entry) {
                final ratio = entry.value / maxCategory;
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
                          Text(_currency(entry.value),
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
                          color: _categoryColor(entry.key),
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
                'Approval Activity',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (_activity.isEmpty)
                const Text('No activity yet.',
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
                            Icon(item.icon, size: 16, color: item.color),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${item.name}  |  ${item.action}  |  ${_currency(item.amount)}',
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
                    '${_selectedIds.length} pending selected  |  ${_currency(_selectedAmount)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _approveSelected,
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: const Text('Approve Selected'),
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
                  '${_selectedIds.length} pending selected  |  ${_currency(_selectedAmount)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
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
              color:
                  selected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
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

class _ReimbursementItem {
  const _ReimbursementItem({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.department,
    required this.category,
    required this.amount,
    required this.status,
    required this.submittedOn,
  });

  final String id;
  final String employeeId;
  final String name;
  final String department;
  final String category;
  final double amount;
  final String status;
  final String submittedOn;

  _ReimbursementItem copyWith({String? status}) {
    return _ReimbursementItem(
      id: id,
      employeeId: employeeId,
      name: name,
      department: department,
      category: category,
      amount: amount,
      status: status ?? this.status,
      submittedOn: submittedOn,
    );
  }
}

class _ReimbursementActivity {
  const _ReimbursementActivity({
    required this.employeeId,
    required this.name,
    required this.action,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String employeeId;
  final String name;
  final String action;
  final double amount;
  final Color color;
  final IconData icon;
}
