import 'package:flutter/material.dart';

class SubAdminReviewApprovalsPage extends StatefulWidget {
  const SubAdminReviewApprovalsPage({super.key});

  @override
  State<SubAdminReviewApprovalsPage> createState() =>
      _SubAdminReviewApprovalsPageState();
}

class _SubAdminReviewApprovalsPageState
    extends State<SubAdminReviewApprovalsPage> {
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  String _selectedStatus = 'All';
  String _selectedPriority = 'All';
  bool _onlyOverdue = false;

  late final TextEditingController _searchController;

  static const List<String> _statusOptions = [
    'All',
    'Pending',
    'Escalated',
    'On Hold',
    'Approved',
  ];

  static const List<String> _priorityOptions = [
    'All',
    'Critical',
    'High',
    'Normal',
  ];

  final List<_ApprovalItem> _approvals = [
    _ApprovalItem(
      id: 'APR-601',
      title: 'High value vendor payout',
      requestedBy: 'A. Kapoor',
      department: 'Finance',
      amountK: 180,
      status: 'Pending',
      priority: 'Critical',
      submittedAt: DateTime(2026, 3, 15, 9, 20),
      dueAt: DateTime(2026, 3, 17, 17, 0),
      note: 'Advance release requested for infrastructure vendor settlement.',
    ),
    _ApprovalItem(
      id: 'APR-602',
      title: 'Recruitment budget variance',
      requestedBy: 'S. Iyer',
      department: 'HR',
      amountK: 64,
      status: 'Escalated',
      priority: 'High',
      submittedAt: DateTime(2026, 3, 14, 13, 10),
      dueAt: DateTime(2026, 3, 16, 18, 0),
      note: 'Open role hiring surge crossed monthly budget guardrail.',
    ),
    _ApprovalItem(
      id: 'APR-603',
      title: 'Q1 travel reimbursement batch',
      requestedBy: 'R. Menon',
      department: 'Operations',
      amountK: 38,
      status: 'Pending',
      priority: 'Normal',
      submittedAt: DateTime(2026, 3, 16, 10, 45),
      dueAt: DateTime(2026, 3, 19, 17, 0),
      note: 'Consolidated travel claims validated by ops finance partner.',
    ),
    _ApprovalItem(
      id: 'APR-604',
      title: 'Compliance tool renewal',
      requestedBy: 'I. Rao',
      department: 'Legal',
      amountK: 92,
      status: 'On Hold',
      priority: 'High',
      submittedAt: DateTime(2026, 3, 12, 15, 5),
      dueAt: DateTime(2026, 3, 20, 12, 0),
      note: 'Waiting for revised legal terms from the vendor.',
    ),
    _ApprovalItem(
      id: 'APR-605',
      title: 'Payroll correction adjustments',
      requestedBy: 'P. Sinha',
      department: 'Payroll',
      amountK: 27,
      status: 'Approved',
      priority: 'Normal',
      submittedAt: DateTime(2026, 3, 11, 11, 0),
      dueAt: DateTime(2026, 3, 15, 16, 0),
      note: 'Correction run for missed overtime claims from previous cycle.',
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

  List<String> get _departmentOptions {
    final departments = _approvals
        .map((approval) => approval.department)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...departments];
  }

  List<_ApprovalItem> get _filteredApprovals {
    final now = DateTime.now();
    final query = _searchQuery.trim().toLowerCase();

    final list = _approvals.where((approval) {
      final matchesSearch = query.isEmpty ||
          approval.id.toLowerCase().contains(query) ||
          approval.title.toLowerCase().contains(query) ||
          approval.requestedBy.toLowerCase().contains(query) ||
          approval.department.toLowerCase().contains(query);

      final matchesDepartment = _selectedDepartment == 'All' ||
          approval.department == _selectedDepartment;
      final matchesStatus =
          _selectedStatus == 'All' || approval.status == _selectedStatus;
      final matchesPriority =
          _selectedPriority == 'All' || approval.priority == _selectedPriority;
      final matchesOverdue = !_onlyOverdue ||
          (approval.dueAt.isBefore(now) &&
              approval.status != 'Approved' &&
              approval.status != 'Rejected');

      return matchesSearch &&
          matchesDepartment &&
          matchesStatus &&
          matchesPriority &&
          matchesOverdue;
    }).toList();

    list.sort((a, b) {
      final priorityOrder = {'Critical': 0, 'High': 1, 'Normal': 2};
      final priorityA = priorityOrder[a.priority] ?? 3;
      final priorityB = priorityOrder[b.priority] ?? 3;
      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }
      return a.dueAt.compareTo(b.dueAt);
    });

    return list;
  }

  int _statusCount(List<_ApprovalItem> list, String status) {
    return list.where((approval) => approval.status == status).length;
  }

  int _overdueCount(List<_ApprovalItem> list) {
    final now = DateTime.now();
    return list
        .where(
          (approval) =>
              approval.dueAt.isBefore(now) &&
              approval.status != 'Approved' &&
              approval.status != 'Rejected',
        )
        .length;
  }

  double _totalAmount(List<_ApprovalItem> list) {
    return list.fold<double>(0, (sum, item) => sum + item.amountK);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Escalated':
        return const Color(0xFFDB4437);
      case 'On Hold':
        return const Color(0xFFF29900);
      case 'Approved':
        return const Color(0xFF0F9D58);
      default:
        return const Color(0xFF1A73E8);
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'Critical':
        return const Color(0xFFDB4437);
      case 'High':
        return const Color(0xFFF29900);
      default:
        return const Color(0xFF1A73E8);
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  void _showActionFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final approvals = _filteredApprovals;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Review Approvals',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 820;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isCompact ? 14 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _metricCard(
                        'Pending',
                        '${_statusCount(approvals, 'Pending')}',
                        const Color(0xFF1A73E8),
                      ),
                      _metricCard(
                        'Escalated',
                        '${_statusCount(approvals, 'Escalated')}',
                        const Color(0xFFDB4437),
                      ),
                      _metricCard(
                        'Overdue',
                        '${_overdueCount(approvals)}',
                        const Color(0xFFF29900),
                      ),
                      _metricCard(
                        'Amount in Queue',
                        '${_totalAmount(approvals).toStringAsFixed(0)}K',
                        const Color(0xFF0F9D58),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildFilters(isCompact),
                  const SizedBox(height: 14),
                  ...approvals.map((approval) => _buildApprovalCard(approval)),
                  if (approvals.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFD6DEE8)),
                      ),
                      child: const Text(
                        'No approvals match the selected filters.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F5ED7), Color(0xFF1A73E8), Color(0xFF36B39C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Approvals Control Queue',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Review high-impact requests, prioritize escalations, and keep audit-ready approvals flowing.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value, Color accent) {
    return SizedBox(
      width: 210,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD6DEE8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: accent,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(bool isCompact) {
    final priorityDropdown = DropdownButtonFormField<String>(
      value: _selectedPriority,
      decoration: _inputDecoration('Priority'),
      isExpanded: true,
      items: _priorityOptions
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        setState(() {
          _selectedPriority = value;
        });
      },
    );

    final statusDropdown = DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: _inputDecoration('Status'),
      isExpanded: true,
      items: _statusOptions
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        setState(() {
          _selectedStatus = value;
        });
      },
    );

    final departmentDropdown = DropdownButtonFormField<String>(
      value: _selectedDepartment,
      decoration: _inputDecoration('Department'),
      isExpanded: true,
      items: _departmentOptions
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        setState(() {
          _selectedDepartment = value;
        });
      },
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6DEE8)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration:
                _inputDecoration('Search by ID, title, requester').copyWith(
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 10),
          if (isCompact)
            Column(
              children: [
                priorityDropdown,
                const SizedBox(height: 10),
                statusDropdown,
                const SizedBox(height: 10),
                departmentDropdown,
              ],
            )
          else
            Row(
              children: [
                Expanded(child: priorityDropdown),
                const SizedBox(width: 10),
                Expanded(child: statusDropdown),
                const SizedBox(width: 10),
                Expanded(child: departmentDropdown),
              ],
            ),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Only show overdue approvals',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
                fontWeight: FontWeight.w600,
              ),
            ),
            value: _onlyOverdue,
            onChanged: (value) {
              setState(() {
                _onlyOverdue = value;
              });
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD6DEE8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD6DEE8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1A73E8)),
      ),
    );
  }

  Widget _buildApprovalCard(_ApprovalItem approval) {
    final statusColor = _statusColor(approval.status);
    final priorityColor = _priorityColor(approval.priority);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6DEE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${approval.id}  •  ${approval.title}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Requested by ${approval.requestedBy} • ${approval.department}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _pill(approval.status, statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _smallInfo('Priority', approval.priority, priorityColor),
              _smallInfo('Amount', '${approval.amountK.toStringAsFixed(0)}K',
                  const Color(0xFF0F9D58)),
              _smallInfo('Submitted', _formatDate(approval.submittedAt),
                  const Color(0xFF1A73E8)),
              _smallInfo(
                  'Due', _formatDate(approval.dueAt), const Color(0xFFF29900)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            approval.note,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showActionFeedback(
                  '${approval.id} marked for detailed review.',
                ),
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('Review'),
              ),
              FilledButton.icon(
                onPressed: approval.status == 'Approved'
                    ? null
                    : () => _showActionFeedback('${approval.id} approved.'),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Approve'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _smallInfo(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 11),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApprovalItem {
  final String id;
  final String title;
  final String requestedBy;
  final String department;
  final double amountK;
  final String status;
  final String priority;
  final DateTime submittedAt;
  final DateTime dueAt;
  final String note;

  const _ApprovalItem({
    required this.id,
    required this.title,
    required this.requestedBy,
    required this.department,
    required this.amountK,
    required this.status,
    required this.priority,
    required this.submittedAt,
    required this.dueAt,
    required this.note,
  });
}
