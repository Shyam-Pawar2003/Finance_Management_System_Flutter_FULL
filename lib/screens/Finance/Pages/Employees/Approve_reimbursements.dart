import 'package:flutter/material.dart';

class ApproveReimbursementsPage extends StatefulWidget {
  const ApproveReimbursementsPage({super.key});

  @override
  State<ApproveReimbursementsPage> createState() =>
      _ApproveReimbursementsPageState();
}

class _ApproveReimbursementsPageState extends State<ApproveReimbursementsPage> {
  final List<_ReimbursementRequest> _pending = [
    const _ReimbursementRequest(
      id: 'RB-801',
      employeeId: 'EMP-001',
      name: 'John Doe',
      department: 'Finance',
      category: 'Travel',
      amount: 120,
      submittedOn: '12 Mar 2026',
      note: 'Client site visit cab and fuel receipts attached.',
    ),
    const _ReimbursementRequest(
      id: 'RB-802',
      employeeId: 'EMP-003',
      name: 'Mike Johnson',
      department: 'Finance',
      category: 'Meals',
      amount: 86,
      submittedOn: '12 Mar 2026',
      note: 'Working dinner during quarter close process.',
    ),
    const _ReimbursementRequest(
      id: 'RB-803',
      employeeId: 'EMP-004',
      name: 'Sarah Williams',
      department: 'HR',
      category: 'Training',
      amount: 260,
      submittedOn: '13 Mar 2026',
      note: 'Leadership workshop registration invoice attached.',
    ),
    const _ReimbursementRequest(
      id: 'RB-804',
      employeeId: 'EMP-005',
      name: 'Tom Brown',
      department: 'Operations',
      category: 'Office Supplies',
      amount: 145,
      submittedOn: '14 Mar 2026',
      note: 'Printer cartridges and paper stock purchase.',
    ),
    const _ReimbursementRequest(
      id: 'RB-805',
      employeeId: 'EMP-006',
      name: 'Aisha Khan',
      department: 'Accounting',
      category: 'Travel',
      amount: 198,
      submittedOn: '14 Mar 2026',
      note: 'Branch office audit trip local transport expenses.',
    ),
  ];

  final List<_ReimbursementActivity> _activity = [];
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};

  String _searchQuery = '';
  String _selectedDepartment = 'All';
  String _selectedCategory = 'All';
  bool _showNotes = true;

  static const List<String> _categories = [
    'All',
    'Travel',
    'Meals',
    'Training',
    'Office Supplies',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(_pending.map((item) => item.id));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _departments {
    final values = _pending.map((e) => e.department).toSet().toList()..sort();
    return ['All', ...values];
  }

  List<_ReimbursementRequest> get _filteredItems {
    final query = _searchQuery.trim().toLowerCase();
    return _pending.where((item) {
      final matchesSearch = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.employeeId.toLowerCase().contains(query) ||
          item.id.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query);

      final matchesDepartment = _selectedDepartment == 'All' ||
          item.department == _selectedDepartment;

      final matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;

      return matchesSearch && matchesDepartment && matchesCategory;
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

  double get _pendingTotal =>
      _pending.fold(0, (sum, item) => sum + item.amount);

  double get _selectedTotal => _pending
      .where((item) => _selectedIds.contains(item.id))
      .fold(0, (sum, item) => sum + item.amount);

  double get _approvedTotal => _activity.fold(
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
    final visibleIds = _filteredItems.map((item) => item.id);
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
      _showMessage('Select at least one reimbursement request.');
      return;
    }

    final selectedItems =
        _pending.where((item) => _selectedIds.contains(item.id)).toList();
    final total = _selectedTotal;

    setState(() {
      _activity.insertAll(
        0,
        selectedItems.map(
          (item) => _ReimbursementActivity(
            requestId: item.id,
            name: item.name,
            amount: item.amount,
            action: 'Approved',
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF16A34A),
          ),
        ),
      );
      _pending.removeWhere((item) => _selectedIds.contains(item.id));
      _selectedIds.clear();
    });

    _showMessage(
      '${selectedItems.length} reimbursement(s) approved - ${_currency(total)}.',
    );
  }

  void _approveItem(_ReimbursementRequest item) {
    setState(() {
      _activity.insert(
        0,
        _ReimbursementActivity(
          requestId: item.id,
          name: item.name,
          amount: item.amount,
          action: 'Approved',
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF16A34A),
        ),
      );
      _pending.remove(item);
      _selectedIds.remove(item.id);
    });
    _showMessage('${item.name} reimbursement approved.');
  }

  void _rejectItem(_ReimbursementRequest item) {
    setState(() {
      _activity.insert(
        0,
        _ReimbursementActivity(
          requestId: item.id,
          name: item.name,
          amount: item.amount,
          action: 'Rejected',
          icon: Icons.cancel_rounded,
          color: const Color(0xFFDC2626),
        ),
      );
      _pending.remove(item);
      _selectedIds.remove(item.id);
    });
    _showMessage('${item.name} reimbursement rejected.');
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
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
    final visibleItems = _filteredItems;
    final allVisibleSelected = visibleItems.isNotEmpty &&
        visibleItems.every((item) => _selectedIds.contains(item.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: const Text('Approve Reimbursements'),
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
                                visibleItems, allVisibleSelected),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 2,
                            child: _buildActivityPanel(),
                          ),
                        ],
                      )
                    else ...[
                      _buildQueuePanel(visibleItems, allVisibleSelected),
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
          const Text(
            'Reimbursement Approval Desk',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 23,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Review employee reimbursement claims, validate notes, and confirm payouts.',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _heroChip('Pending', '${_pending.length} requests'),
              _heroChip('Pending Value', _currency(_pendingTotal)),
              _heroChip('Selected', '${_selectedIds.length} requests'),
              _heroChip('Approved Today', _currency(_approvedTotal)),
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

  Widget _buildQueuePanel(
    List<_ReimbursementRequest> visibleItems,
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
                        'Approval Queue',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => setState(() => _showNotes = !_showNotes),
                      icon: Icon(
                        _showNotes
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 16,
                        color: const Color(0xFF2563EB),
                      ),
                      label: Text(
                        _showNotes ? 'Hide Notes' : 'Show Notes',
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
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search by employee, request id or category...',
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
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _departments.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final department = _departments[index];
                      final selected = department == _selectedDepartment;
                      return _filterChip(
                        label: department,
                        selected: selected,
                        onTap: () =>
                            setState(() => _selectedDepartment = department),
                        selectedColor: const Color(0xFF0F2C67),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final selected = category == _selectedCategory;
                      return _filterChip(
                        label: category,
                        selected: selected,
                        onTap: () =>
                            setState(() => _selectedCategory = category),
                        selectedColor: const Color(0xFF2563EB),
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
                      '${visibleItems.length} request(s)',
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
          if (visibleItems.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No reimbursement requests match current filters.',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleItems.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) =>
                  _buildItemTile(visibleItems[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildItemTile(_ReimbursementRequest item) {
    final selected = _selectedIds.contains(item.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color:
          selected ? const Color(0xFF2563EB).withOpacity(0.04) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: selected,
                  onChanged: (value) => _toggleSelect(item.id, value ?? false),
                  activeColor: const Color(0xFF2563EB),
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF2563EB).withOpacity(0.12),
                  child: Text(
                    item.name
                        .split(' ')
                        .take(2)
                        .map((w) => w[0])
                        .join()
                        .toUpperCase(),
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
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '${item.employeeId}  |  ${item.id}  |  ${item.department}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _chip(item.category, _categoryColor(item.category)),
                const SizedBox(width: 10),
                Text(
                  _currency(item.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                _actionButton(
                  label: 'Approve',
                  color: const Color(0xFF16A34A),
                  onTap: () => _approveItem(item),
                ),
                const SizedBox(width: 6),
                _actionButton(
                  label: 'Reject',
                  color: const Color(0xFFDC2626),
                  onTap: () => _rejectItem(item),
                ),
              ],
            ),
            if (_showNotes) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Text(
                  '${item.submittedOn}  -  ${item.note}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
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
                    'Approval Activity',
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
                    color: const Color(0xFF2563EB).withOpacity(0.10),
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
            const SizedBox(height: 8),
            Text(
              'Approved value: ${_currency(_approvedTotal)}',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
                fontSize: 12,
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
                      'No actions yet.',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
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
                                  color: Color(0xFF0F172A),
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${item.requestId}  |  ${item.action}  |  ${_currency(item.amount)}',
                                style: TextStyle(
                                  color: item.color,
                                  fontWeight: FontWeight.w600,
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
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isWide) {
    final summary = RichText(
      text: TextSpan(
        style: const TextStyle(color: Color(0xFF334155), fontSize: 14),
        children: [
          TextSpan(
            text: '${_selectedIds.length} selected',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const TextSpan(text: '  -  '),
          TextSpan(
            text: _currency(_selectedTotal),
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    return _panel(
      padding: const EdgeInsets.all(16),
      child: isWide
          ? Row(
              children: [
                const Icon(Icons.approval_rounded, color: Color(0xFF2563EB)),
                const SizedBox(width: 10),
                Expanded(child: summary),
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
                summary,
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
                        borderRadius: BorderRadius.circular(10),
                      ),
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
    required Color selectedColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? selectedColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? selectedColor : const Color(0xFFE2E8F0),
          ),
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
        color: color.withOpacity(0.11),
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
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
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

class _ReimbursementRequest {
  const _ReimbursementRequest({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.department,
    required this.category,
    required this.amount,
    required this.submittedOn,
    required this.note,
  });

  final String id;
  final String employeeId;
  final String name;
  final String department;
  final String category;
  final double amount;
  final String submittedOn;
  final String note;
}

class _ReimbursementActivity {
  const _ReimbursementActivity({
    required this.requestId,
    required this.name,
    required this.amount,
    required this.action,
    required this.icon,
    required this.color,
  });

  final String requestId;
  final String name;
  final double amount;
  final String action;
  final IconData icon;
  final Color color;
}
