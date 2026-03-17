import 'package:flutter/material.dart';

import '../../hrmanager/pages/recruitment_page.dart';

class OpenRoleItem {
  final String id;
  final String title;
  final String department;
  final String owner;
  final String priority;
  final String status;
  final int openings;
  final int filled;
  final int daysOpen;

  const OpenRoleItem({
    required this.id,
    required this.title,
    required this.department,
    required this.owner,
    required this.priority,
    required this.status,
    required this.openings,
    required this.filled,
    required this.daysOpen,
  });

  OpenRoleItem copyWith({
    String? status,
    int? filled,
  }) {
    return OpenRoleItem(
      id: id,
      title: title,
      department: department,
      owner: owner,
      priority: priority,
      status: status ?? this.status,
      openings: openings,
      filled: filled ?? this.filled,
      daysOpen: daysOpen,
    );
  }
}

class SubAdminOpenRolePage extends StatefulWidget {
  final List<String> roleSuggestions;
  final List<String> ownerSuggestions;

  const SubAdminOpenRolePage({
    super.key,
    this.roleSuggestions = const [],
    this.ownerSuggestions = const [],
  });

  @override
  State<SubAdminOpenRolePage> createState() => _SubAdminOpenRolePageState();
}

class _SubAdminOpenRolePageState extends State<SubAdminOpenRolePage> {
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  bool _showClosed = false;

  late final TextEditingController _searchController;

  final List<OpenRoleItem> _openRoles = [
    const OpenRoleItem(
      id: 'ROL-301',
      title: 'Payroll Analyst',
      department: 'Finance',
      owner: 'A. Kapoor',
      priority: 'High',
      status: 'Active',
      openings: 2,
      filled: 1,
      daysOpen: 14,
    ),
    const OpenRoleItem(
      id: 'ROL-302',
      title: 'HR Generalist',
      department: 'HR',
      owner: 'R. Menon',
      priority: 'Normal',
      status: 'Active',
      openings: 1,
      filled: 0,
      daysOpen: 9,
    ),
    const OpenRoleItem(
      id: 'ROL-303',
      title: 'Operations Executive',
      department: 'Operations',
      owner: 'P. Sinha',
      priority: 'Critical',
      status: 'Active',
      openings: 3,
      filled: 1,
      daysOpen: 18,
    ),
    const OpenRoleItem(
      id: 'ROL-304',
      title: 'Compliance Associate',
      department: 'Legal',
      owner: 'S. Bhatt',
      priority: 'High',
      status: 'Paused',
      openings: 1,
      filled: 0,
      daysOpen: 21,
    ),
    const OpenRoleItem(
      id: 'ROL-305',
      title: 'Support Associate',
      department: 'Operations',
      owner: 'P. Sinha',
      priority: 'Normal',
      status: 'Closed',
      openings: 4,
      filled: 4,
      daysOpen: 33,
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
    final set = _openRoles.map((e) => e.department).toSet().toList()..sort();
    return ['All', ...set];
  }

  List<OpenRoleItem> get _filteredRoles {
    final query = _searchQuery.trim().toLowerCase();
    return _openRoles.where((role) {
      final matchesSearch = query.isEmpty ||
          role.id.toLowerCase().contains(query) ||
          role.title.toLowerCase().contains(query) ||
          role.owner.toLowerCase().contains(query);
      final matchesDept = _selectedDepartment == 'All' ||
          role.department == _selectedDepartment;
      final matchesClosed = _showClosed || role.status != 'Closed';
      return matchesSearch && matchesDept && matchesClosed;
    }).toList();
  }

  void _toggleRoleStatus(OpenRoleItem role) {
    final index = _openRoles.indexWhere((item) => item.id == role.id);
    if (index == -1) return;

    final current = _openRoles[index];
    final next = current.status == 'Active' ? 'Paused' : 'Active';

    setState(() {
      _openRoles[index] = current.copyWith(status: next);
    });

    _showSnack('${role.id} status updated to $next.');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1A73E8),
      ),
    );
  }

  String _mapRoleStatusToHrStatus(String status) {
    switch (status) {
      case 'Closed':
        return 'Closed';
      case 'Paused':
        return 'Interviewing';
      default:
        return 'Open';
    }
  }

  String _mapRolePriorityToHrPriority(String priority) {
    switch (priority) {
      case 'Critical':
      case 'High':
        return 'High';
      case 'Normal':
        return 'Medium';
      default:
        return 'Low';
    }
  }

  void _openHrRecruitmentPage(OpenRoleItem role) {
    final seededJob = JobPosting(
      title: role.title,
      department: role.department,
      description:
          'Created from SubAdmin Open Role flow (${role.id}) and assigned to ${role.owner}.',
      status: _mapRoleStatusToHrStatus(role.status),
      priority: _mapRolePriorityToHrPriority(role.priority),
      openings: role.openings,
      applicants: 0,
      postedOn: DateTime.now(),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: const Color(0xFFF4F7FC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 1,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: const Text(
              'HR Recruitment',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: SafeArea(
            child: RecruitmentPage(
              seededJobs: [seededJob],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateRoleDialog() async {
    final titleController = TextEditingController();
    final openingsController = TextEditingController(text: '1');

    final titleOptions = widget.roleSuggestions.isEmpty
        ? <String>[
            'Business Analyst',
            'Finance Coordinator',
            'HR Executive',
            'Operations Associate',
          ]
        : widget.roleSuggestions;

    final ownerOptions = widget.ownerSuggestions.isEmpty
        ? <String>['A. Kapoor', 'R. Menon', 'P. Sinha', 'S. Bhatt']
        : widget.ownerSuggestions;

    String roleTitle = titleOptions.first;
    String owner = ownerOptions.first;
    String priority = 'Normal';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create Open Role'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: roleTitle,
                      items: titleOptions
                          .map((item) =>
                              DropdownMenuItem(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => roleTitle = value);
                        }
                      },
                      decoration:
                          const InputDecoration(labelText: 'Role Title'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Custom Title (optional)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: owner,
                      items: ownerOptions
                          .map((item) =>
                              DropdownMenuItem(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => owner = value);
                        }
                      },
                      decoration:
                          const InputDecoration(labelText: 'Hiring Owner'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: priority,
                      items: const ['Critical', 'High', 'Normal']
                          .map((item) =>
                              DropdownMenuItem(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => priority = value);
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Priority'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: openingsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Openings'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final openings =
                        int.tryParse(openingsController.text.trim());
                    if (openings == null || openings <= 0) {
                      _showSnack('Please enter a valid openings count.');
                      return;
                    }

                    final finalTitle = titleController.text.trim().isEmpty
                        ? roleTitle
                        : titleController.text.trim();

                    final newRole = OpenRoleItem(
                      id: 'ROL-${300 + _openRoles.length + 1}',
                      title: finalTitle,
                      department: _selectedDepartment == 'All'
                          ? 'Operations'
                          : _selectedDepartment,
                      owner: owner,
                      priority: priority,
                      status: 'Active',
                      openings: openings,
                      filled: 0,
                      daysOpen: 0,
                    );

                    setState(() {
                      _openRoles.insert(0, newRole);
                    });

                    Navigator.of(dialogContext).pop();
                    _showSnack('${newRole.id} created successfully.');
                    if (!mounted) return;
                    _openHrRecruitmentPage(newRole);
                  },
                  child: const Text('Create Role'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final roles = _filteredRoles;
    final activeCount = _openRoles.where((e) => e.status == 'Active').length;
    final totalOpenings =
        _openRoles.fold<int>(0, (sum, role) => sum + role.openings);
    final totalFilled =
        _openRoles.fold<int>(0, (sum, role) => sum + role.filled);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Open Role Management',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilledButton.icon(
              onPressed: _showCreateRoleDialog,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Create Role'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F5ED7), Color(0xFF36B39C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _heroStat('Active Roles', '$activeCount'),
                    _heroStat('Total Openings', '$totalOpenings'),
                    _heroStat('Filled', '$totalFilled'),
                    _heroStat(
                      'Fill Ratio',
                      totalOpenings == 0
                          ? '0%'
                          : '${((totalFilled / totalOpenings) * 100).toStringAsFixed(0)}%',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search by role title, id, or owner',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFDCE3EC)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFDCE3EC)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        SizedBox(
                          width: 200,
                          child: DropdownButtonFormField<String>(
                            value: _selectedDepartment,
                            isExpanded: true,
                            items: _departments
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedDepartment = value);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Department',
                              filled: true,
                              fillColor: Color(0xFFF8FAFC),
                            ),
                          ),
                        ),
                        FilterChip(
                          label: const Text('Show Closed'),
                          selected: _showClosed,
                          onSelected: (value) =>
                              setState(() => _showClosed = value),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (roles.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Text(
                    'No roles match current filters.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                ...roles.map(
                  (role) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildRoleCard(role),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(OpenRoleItem role) {
    final fillPercent = role.openings == 0 ? 0.0 : role.filled / role.openings;
    final stageColor = _statusColor(role.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                      role.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${role.id}  -  ${role.department}  -  Owner: ${role.owner}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: stageColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  role.status,
                  style: TextStyle(
                    color: stageColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill(
                  'Priority: ${role.priority}', _priorityColor(role.priority)),
              _pill('Openings: ${role.openings}', const Color(0xFF1A73E8)),
              _pill('Filled: ${role.filled}', const Color(0xFF0F9D58)),
              _pill('Days Open: ${role.daysOpen}', const Color(0xFF64748B)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: fillPercent,
              minHeight: 8,
              backgroundColor: const Color(0xFFE8EDF5),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF0F9D58)),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showSnack('Opening details for ${role.id}.'),
                icon: const Icon(Icons.description_outlined, size: 17),
                label: const Text('View JD'),
              ),
              FilledButton.tonalIcon(
                onPressed: role.status == 'Closed'
                    ? null
                    : () => _toggleRoleStatus(role),
                icon: const Icon(Icons.sync_alt_rounded, size: 17),
                label: Text(
                    role.status == 'Active' ? 'Pause Role' : 'Activate Role'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE8F0FE),
                  foregroundColor: const Color(0xFF1A73E8),
                ),
              ),
            ],
          ),
        ],
      ),
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

  Color _statusColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF0F9D58);
      case 'Paused':
        return const Color(0xFFF29900);
      case 'Closed':
        return const Color(0xFF64748B);
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
}
