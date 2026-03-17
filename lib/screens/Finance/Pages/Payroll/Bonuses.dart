import 'package:flutter/material.dart';

class BonusesPage extends StatefulWidget {
  const BonusesPage({super.key});

  @override
  State<BonusesPage> createState() => _BonusesPageState();
}

class _BonusesPageState extends State<BonusesPage> {
  final List<_BonusItem> _pending = [
    const _BonusItem(
      id: 'BON-301',
      employeeId: 'EMP-101',
      name: 'Rhaenyra Targaryen',
      role: 'Product Designer',
      department: 'Design',
      category: 'Performance',
      reason: 'Exceeded quarterly campaign goals and led design refresh.',
      amount: 850,
      awardDate: '18 Mar 2026',
    ),
    const _BonusItem(
      id: 'BON-302',
      employeeId: 'EMP-104',
      name: 'Arya Stark',
      role: 'QA Engineer',
      department: 'Engineering',
      category: 'Spot Award',
      reason: 'Closed critical release blockers ahead of deadline.',
      amount: 620,
      awardDate: '18 Mar 2026',
    ),
    const _BonusItem(
      id: 'BON-303',
      employeeId: 'EMP-105',
      name: 'Tyrion Lannister',
      role: 'Operations Lead',
      department: 'Operations',
      category: 'Retention',
      reason: 'Outstanding cross-team leadership during cost optimization.',
      amount: 1200,
      awardDate: '19 Mar 2026',
    ),
    const _BonusItem(
      id: 'BON-304',
      employeeId: 'EMP-107',
      name: 'Bran Stark',
      role: 'Data Analyst',
      department: 'Finance',
      category: 'Project',
      reason: 'Delivered high-impact forecasting dashboards for finance.',
      amount: 780,
      awardDate: '19 Mar 2026',
    ),
    const _BonusItem(
      id: 'BON-305',
      employeeId: 'EMP-108',
      name: 'Jaime Lannister',
      role: 'Sales Executive',
      department: 'Sales',
      category: 'Performance',
      reason: 'Top revenue contributor for the current payroll cycle.',
      amount: 990,
      awardDate: '20 Mar 2026',
    ),
  ];

  final List<_BonusActivity> _activity = [];
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};

  static const List<String> _categories = [
    'All',
    'Performance',
    'Spot Award',
    'Retention',
    'Project',
  ];

  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _showReason = true;

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

  List<_BonusItem> get _filteredItems {
    final query = _searchQuery.trim().toLowerCase();
    return _pending.where((item) {
      final matchesSearch = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.employeeId.toLowerCase().contains(query) ||
          item.role.toLowerCase().contains(query) ||
          item.department.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query);
      final matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  double get _pendingTotal =>
      _pending.fold(0, (sum, item) => sum + item.amount);

  double get _selectedTotal => _pending
      .where((item) => _selectedIds.contains(item.id))
      .fold(0, (sum, item) => sum + item.amount);

  double get _approvedTotal =>
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
      _showMessage('Select at least one bonus request to approve.');
      return;
    }

    final total = _selectedTotal;
    final approved = _pending
        .where((item) => _selectedIds.contains(item.id))
        .toList(growable: false);

    setState(() {
      _activity.insertAll(
        0,
        approved.map(
          (item) => _BonusActivity(
            id: item.id,
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
      '${approved.length} bonus request(s) approved - ${_currency(total)} released.',
    );
  }

  void _rejectItem(_BonusItem item) {
    setState(() {
      _activity.insert(
        0,
        _BonusActivity(
          id: item.id,
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

    _showMessage('${item.name} bonus request rejected.');
  }

  void _approveItem(_BonusItem item) {
    setState(() {
      _activity.insert(
        0,
        _BonusActivity(
          id: item.id,
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

    _showMessage('${item.name} bonus approved - ${_currency(item.amount)}.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Spot Award':
        return const Color(0xFF7C3AED);
      case 'Retention':
        return const Color(0xFF0F766E);
      case 'Project':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF2563EB);
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
        title: const Text('Bonuses'),
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
                              visibleItems,
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
                      _buildQueuePanel(visibleItems, allVisibleSelected),
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
                      'Bonus Allocation Studio',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 23,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Review incentive recommendations, approve awards, and keep payouts aligned to policy.',
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
                  Icons.workspace_premium_rounded,
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
              _heroChip('Pending awards', '${_pending.length} requests'),
              _heroChip('Pending value', _currency(_pendingTotal)),
              _heroChip('Selected', '${_selectedIds.length} requests'),
              _heroChip(
                'Processed today',
                '${_activity.length} | ${_currency(_approvedTotal)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String label, String value) {
    return Container(
      constraints: const BoxConstraints(minWidth: 132),
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
    List<_BonusItem> visibleItems,
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
                  'Bonus Queue',
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
                  '${visibleItems.length} visible',
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
            'Recommended awards awaiting manager approval.',
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
              hintText: 'Search employee, role, department, or category',
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
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
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
                      category,
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
                    _showReason = !_showReason;
                  });
                },
                child: Row(
                  children: [
                    Text(
                      _showReason ? 'Hide notes' : 'Show notes',
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _showReason
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
              backgroundColor: const Color(0xFFF0FDF4),
              borderColor: const Color(0xFFBBF7D0),
              message: 'All bonus requests have been processed.',
            )
          else if (visibleItems.isEmpty)
            _emptyState(
              icon: Icons.search_off_rounded,
              color: const Color(0xFF64748B),
              backgroundColor: const Color(0xFFF8FAFC),
              borderColor: const Color(0xFFE2E8F0),
              message: 'No bonus requests match the current search or filter.',
            )
          else
            ...visibleItems.map(_buildBonusCard),
        ],
      ),
    );
  }

  Widget _buildBonusCard(_BonusItem item) {
    final isSelected = _selectedIds.contains(item.id);
    final categoryColor = _categoryColor(item.category);
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
                          '${item.employeeId} · ${item.role}',
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
                        _currency(item.amount),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Bonus',
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
                  _pill(item.category, categoryColor),
                  _pill(item.awardDate, const Color(0xFF475569)),
                ],
              ),
              if (_showReason) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    item.reason,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _actionButton(
                    label: 'Reject',
                    color: const Color(0xFFDC2626),
                    backgroundColor: const Color(0xFFFFF1F2),
                    icon: Icons.close_rounded,
                    onTap: () => _rejectItem(item),
                  ),
                  const SizedBox(width: 8),
                  _actionButton(
                    label: 'Approve',
                    color: const Color(0xFF16A34A),
                    backgroundColor: const Color(0xFFF0FDF4),
                    icon: Icons.check_rounded,
                    onTap: () => _approveItem(item),
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
            'Bonus Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Requests approved or rejected in this session.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          if (_activity.isEmpty)
            _emptyState(
              icon: Icons.hourglass_empty_rounded,
              color: const Color(0xFF64748B),
              backgroundColor: const Color(0xFFF8FAFC),
              borderColor: const Color(0xFFE2E8F0),
              message: 'No bonus actions have been taken yet.',
            )
          else
            ..._activity.map(_buildActivityCard),
        ],
      ),
    );
  }

  Widget _buildActivityCard(_BonusActivity item) {
    final isApproved = item.action == 'Approved';
    final backgroundColor =
        isApproved ? const Color(0xFFF0FDF4) : const Color(0xFFFFF1F2);
    final borderColor =
        isApproved ? const Color(0xFFBBF7D0) : const Color(0xFFFFCDD2);

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
          'Bulk Approval',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          '${_selectedIds.length} selected · ${_currency(_selectedTotal)} pending release',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final button = ElevatedButton.icon(
      onPressed: _approveSelected,
      icon: const Icon(Icons.workspace_premium_rounded),
      label: const Text('Approve Selected'),
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
}

class _BonusItem {
  const _BonusItem({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.role,
    required this.department,
    required this.category,
    required this.reason,
    required this.amount,
    required this.awardDate,
  });

  final String id;
  final String employeeId;
  final String name;
  final String role;
  final String department;
  final String category;
  final String reason;
  final double amount;
  final String awardDate;
}

class _BonusActivity {
  const _BonusActivity({
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
