import 'package:flutter/material.dart';

class SubAdminOpenRecruitingBoardPage extends StatefulWidget {
  const SubAdminOpenRecruitingBoardPage({super.key});

  @override
  State<SubAdminOpenRecruitingBoardPage> createState() =>
      _SubAdminOpenRecruitingBoardPageState();
}

class _SubAdminOpenRecruitingBoardPageState
    extends State<SubAdminOpenRecruitingBoardPage> {
  String _searchQuery = '';
  String _selectedStage = 'All';
  String _selectedPriority = 'All';
  String _selectedRole = 'All';
  bool _onlyUrgent = false;

  late final TextEditingController _searchController;

  static const List<String> _stageOptions = [
    'All',
    'Intake',
    'Sourcing',
    'Screening',
    'Interview',
    'Offer',
  ];

  static const List<String> _priorityOptions = [
    'All',
    'Critical',
    'High',
    'Normal',
  ];

  final List<_RecruitingRoleItem> _roles = [
    _RecruitingRoleItem(
      id: 'REQ-1201',
      role: 'Payroll Analyst',
      department: 'Finance',
      hiringManager: 'Rahul Sharma',
      openings: 2,
      stage: 'Interview',
      priority: 'Critical',
      pipelineCount: 14,
      interviewedCount: 6,
      dueDate: DateTime(2026, 3, 20),
      note: 'Cycle close quality issue requires immediate hiring fill.',
    ),
    _RecruitingRoleItem(
      id: 'REQ-1202',
      role: 'HR Generalist',
      department: 'HR',
      hiringManager: 'Sneha Iyer',
      openings: 1,
      stage: 'Screening',
      priority: 'High',
      pipelineCount: 18,
      interviewedCount: 2,
      dueDate: DateTime(2026, 3, 24),
      note: 'Need stronger policy and onboarding execution bandwidth.',
    ),
    _RecruitingRoleItem(
      id: 'REQ-1203',
      role: 'Compliance Associate',
      department: 'Legal',
      hiringManager: 'Ishita Rao',
      openings: 1,
      stage: 'Sourcing',
      priority: 'High',
      pipelineCount: 11,
      interviewedCount: 1,
      dueDate: DateTime(2026, 3, 27),
      note: 'Audit readiness stream needs backfill before quarter close.',
    ),
    _RecruitingRoleItem(
      id: 'REQ-1204',
      role: 'Operations Executive',
      department: 'Operations',
      hiringManager: 'P. Sinha',
      openings: 3,
      stage: 'Interview',
      priority: 'Normal',
      pipelineCount: 22,
      interviewedCount: 8,
      dueDate: DateTime(2026, 3, 31),
      note: 'Ramp-up planned for new service expansion project.',
    ),
    _RecruitingRoleItem(
      id: 'REQ-1205',
      role: 'Talent Acquisition Specialist',
      department: 'HR',
      hiringManager: 'R. Menon',
      openings: 1,
      stage: 'Offer',
      priority: 'Normal',
      pipelineCount: 9,
      interviewedCount: 7,
      dueDate: DateTime(2026, 3, 18),
      note: 'Offer in final approval stage with compensation discussion.',
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

  List<String> get _roleOptions {
    final roles = _roles.map((item) => item.role).toSet().toList()..sort();
    return ['All', ...roles];
  }

  List<_RecruitingRoleItem> get _filteredRoles {
    final now = DateTime.now();
    final query = _searchQuery.trim().toLowerCase();

    final list = _roles.where((item) {
      final matchesSearch = query.isEmpty ||
          item.id.toLowerCase().contains(query) ||
          item.role.toLowerCase().contains(query) ||
          item.hiringManager.toLowerCase().contains(query) ||
          item.department.toLowerCase().contains(query);

      final matchesStage =
          _selectedStage == 'All' || item.stage == _selectedStage;
      final matchesPriority =
          _selectedPriority == 'All' || item.priority == _selectedPriority;
      final matchesRole = _selectedRole == 'All' || item.role == _selectedRole;
      final matchesUrgent = !_onlyUrgent ||
          item.dueDate
                  .difference(DateTime(now.year, now.month, now.day))
                  .inDays <=
              4;

      return matchesSearch &&
          matchesStage &&
          matchesPriority &&
          matchesRole &&
          matchesUrgent;
    }).toList();

    list.sort((a, b) {
      final priorityOrder = {'Critical': 0, 'High': 1, 'Normal': 2};
      final priorityA = priorityOrder[a.priority] ?? 3;
      final priorityB = priorityOrder[b.priority] ?? 3;
      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }
      return a.dueDate.compareTo(b.dueDate);
    });

    return list;
  }

  int _countByStage(List<_RecruitingRoleItem> list, String stage) {
    return list.where((item) => item.stage == stage).length;
  }

  int _totalOpenings(List<_RecruitingRoleItem> list) {
    return list.fold<int>(0, (sum, item) => sum + item.openings);
  }

  int _criticalCount(List<_RecruitingRoleItem> list) {
    return list.where((item) => item.priority == 'Critical').length;
  }

  int _interviewPending(List<_RecruitingRoleItem> list) {
    var total = 0;
    for (final item in list) {
      total += (item.pipelineCount - item.interviewedCount).clamp(0, 9999);
    }
    return total;
  }

  Color _stageColor(String stage) {
    switch (stage) {
      case 'Interview':
        return const Color(0xFF1A73E8);
      case 'Offer':
        return const Color(0xFF0F9D58);
      case 'Screening':
        return const Color(0xFFF29900);
      default:
        return const Color(0xFF5F6368);
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
    final roles = _filteredRoles;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Open Recruiting Board',
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
                        'Open Roles',
                        '${roles.length}',
                        const Color(0xFF1A73E8),
                      ),
                      _metricCard(
                        'Openings',
                        '${_totalOpenings(roles)}',
                        const Color(0xFF0F9D58),
                      ),
                      _metricCard(
                        'Interview Stage',
                        '${_countByStage(roles, 'Interview')}',
                        const Color(0xFF7C3AED),
                      ),
                      _metricCard(
                        'Critical Roles',
                        '${_criticalCount(roles)}',
                        const Color(0xFFDB4437),
                      ),
                      _metricCard(
                        'Pipeline Pending',
                        '${_interviewPending(roles)}',
                        const Color(0xFFF29900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildFilters(isCompact),
                  const SizedBox(height: 14),
                  ...roles.map((role) => _buildRoleCard(role)),
                  if (roles.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFD6DEE8)),
                      ),
                      child: const Text(
                        'No roles match the current filters.',
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
          colors: [Color(0xFF1D4ED8), Color(0xFF0891B2), Color(0xFF22C55E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recruiting Execution Board',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Prioritize urgent roles, monitor pipeline throughput, and close hiring gaps faster.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value, Color accent) {
    return SizedBox(
      width: 200,
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

    final stageDropdown = DropdownButtonFormField<String>(
      value: _selectedStage,
      decoration: _inputDecoration('Stage'),
      isExpanded: true,
      items: _stageOptions
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        setState(() {
          _selectedStage = value;
        });
      },
    );

    final roleDropdown = DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: _inputDecoration('Role'),
      isExpanded: true,
      items: _roleOptions
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        setState(() {
          _selectedRole = value;
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
                _inputDecoration('Search by ID, role, manager').copyWith(
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 10),
          if (isCompact)
            Column(
              children: [
                priorityDropdown,
                const SizedBox(height: 10),
                stageDropdown,
                const SizedBox(height: 10),
                roleDropdown,
              ],
            )
          else
            Row(
              children: [
                Expanded(child: priorityDropdown),
                const SizedBox(width: 10),
                Expanded(child: stageDropdown),
                const SizedBox(width: 10),
                Expanded(child: roleDropdown),
              ],
            ),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Only show urgent roles due in 4 days',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
                fontWeight: FontWeight.w600,
              ),
            ),
            value: _onlyUrgent,
            onChanged: (value) {
              setState(() {
                _onlyUrgent = value;
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

  Widget _buildRoleCard(_RecruitingRoleItem role) {
    final stageColor = _stageColor(role.stage);
    final priorityColor = _priorityColor(role.priority);

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
                      '${role.id}  •  ${role.role}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${role.department} • Manager: ${role.hiringManager}',
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
              _pill(role.stage, stageColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _smallInfo('Priority', role.priority, priorityColor),
              _smallInfo(
                'Openings',
                '${role.openings}',
                const Color(0xFF0F9D58),
              ),
              _smallInfo(
                'Pipeline',
                '${role.pipelineCount}',
                const Color(0xFF1A73E8),
              ),
              _smallInfo(
                'Interviewed',
                '${role.interviewedCount}',
                const Color(0xFF7C3AED),
              ),
              _smallInfo(
                  'Target', _formatDate(role.dueDate), const Color(0xFFF29900)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            role.note,
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
                  'Opening pipeline for ${role.id}.',
                ),
                icon: const Icon(Icons.view_kanban_outlined, size: 18),
                label: const Text('View Pipeline'),
              ),
              FilledButton.icon(
                onPressed: () => _showActionFeedback(
                  '${role.id} moved to next stage.',
                ),
                icon: const Icon(Icons.arrow_circle_right_outlined, size: 18),
                label: const Text('Advance Stage'),
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

class _RecruitingRoleItem {
  final String id;
  final String role;
  final String department;
  final String hiringManager;
  final int openings;
  final String stage;
  final String priority;
  final int pipelineCount;
  final int interviewedCount;
  final DateTime dueDate;
  final String note;

  const _RecruitingRoleItem({
    required this.id,
    required this.role,
    required this.department,
    required this.hiringManager,
    required this.openings,
    required this.stage,
    required this.priority,
    required this.pipelineCount,
    required this.interviewedCount,
    required this.dueDate,
    required this.note,
  });
}
