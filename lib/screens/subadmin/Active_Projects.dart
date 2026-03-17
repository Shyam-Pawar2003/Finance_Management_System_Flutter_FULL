import 'package:flutter/material.dart';

class SubAdminActiveProjectsPage extends StatefulWidget {
  const SubAdminActiveProjectsPage({super.key});

  @override
  State<SubAdminActiveProjectsPage> createState() =>
      _SubAdminActiveProjectsPageState();
}

class _SubAdminActiveProjectsPageState extends State<SubAdminActiveProjectsPage> {
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  String _selectedStatus = 'All';
  String _selectedSort = 'Priority';
  bool _highPriorityOnly = false;

  late final TextEditingController _searchController;

  static const List<String> _statusOptions = [
    'All',
    'On Track',
    'At Risk',
    'Delayed',
    'Completed',
  ];

  static const List<String> _sortOptions = [
    'Priority',
    'Progress',
    'Budget Utilization',
    'Deadline',
  ];

  final List<_ProjectRecord> _projects = [
    _ProjectRecord(
      id: 'PRJ-1042',
      name: 'Payroll Automation Phase 2',
      department: 'Finance',
      manager: 'A. Kapoor',
      status: 'On Track',
      priority: 'High',
      progress: 0.74,
      budgetUsed: 82000,
      budgetTotal: 110000,
      teamSize: 7,
      milestoneCount: 9,
      nextDeadline: DateTime(2026, 3, 22),
    ),
    _ProjectRecord(
      id: 'PRJ-1049',
      name: 'Hiring Pipeline Revamp',
      department: 'HR',
      manager: 'R. Menon',
      status: 'At Risk',
      priority: 'High',
      progress: 0.58,
      budgetUsed: 64000,
      budgetTotal: 90000,
      teamSize: 6,
      milestoneCount: 8,
      nextDeadline: DateTime(2026, 3, 19),
    ),
    _ProjectRecord(
      id: 'PRJ-1058',
      name: 'Attendance Analytics Dashboard',
      department: 'Operations',
      manager: 'P. Sinha',
      status: 'Delayed',
      priority: 'Medium',
      progress: 0.41,
      budgetUsed: 53000,
      budgetTotal: 70000,
      teamSize: 5,
      milestoneCount: 7,
      nextDeadline: DateTime(2026, 3, 17),
    ),
    _ProjectRecord(
      id: 'PRJ-1061',
      name: 'Policy Compliance Assistant',
      department: 'Legal',
      manager: 'S. Bhatt',
      status: 'On Track',
      priority: 'Medium',
      progress: 0.66,
      budgetUsed: 39000,
      budgetTotal: 60000,
      teamSize: 4,
      milestoneCount: 6,
      nextDeadline: DateTime(2026, 3, 28),
    ),
    _ProjectRecord(
      id: 'PRJ-1064',
      name: 'Compensation Benchmark Engine',
      department: 'Finance',
      manager: 'K. Patel',
      status: 'On Track',
      priority: 'Low',
      progress: 0.83,
      budgetUsed: 47000,
      budgetTotal: 62000,
      teamSize: 4,
      milestoneCount: 5,
      nextDeadline: DateTime(2026, 4, 2),
    ),
    _ProjectRecord(
      id: 'PRJ-1069',
      name: 'Employee Service Portal',
      department: 'Operations',
      manager: 'M. Nair',
      status: 'Completed',
      priority: 'Medium',
      progress: 1.0,
      budgetUsed: 77000,
      budgetTotal: 77000,
      teamSize: 6,
      milestoneCount: 11,
      nextDeadline: DateTime(2026, 3, 8),
    ),
    _ProjectRecord(
      id: 'PRJ-1074',
      name: 'Offer Approval Workflow',
      department: 'HR',
      manager: 'N. Verma',
      status: 'On Track',
      priority: 'High',
      progress: 0.69,
      budgetUsed: 28000,
      budgetTotal: 45000,
      teamSize: 3,
      milestoneCount: 6,
      nextDeadline: DateTime(2026, 3, 24),
    ),
    _ProjectRecord(
      id: 'PRJ-1082',
      name: 'Regional Support Capacity Planner',
      department: 'Support',
      manager: 'T. Deshmukh',
      status: 'At Risk',
      priority: 'High',
      progress: 0.52,
      budgetUsed: 35000,
      budgetTotal: 50000,
      teamSize: 5,
      milestoneCount: 7,
      nextDeadline: DateTime(2026, 3, 20),
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
    final values = _projects.map((project) => project.department).toSet().toList()
      ..sort();
    return ['All', ...values];
  }

  List<_ProjectRecord> get _filteredProjects {
    final query = _searchQuery.trim().toLowerCase();

    final list = _projects.where((project) {
      final matchesSearch = query.isEmpty ||
          project.id.toLowerCase().contains(query) ||
          project.name.toLowerCase().contains(query) ||
          project.department.toLowerCase().contains(query) ||
          project.manager.toLowerCase().contains(query);

      final matchesDepartment =
          _selectedDepartment == 'All' || project.department == _selectedDepartment;

      final matchesStatus = _selectedStatus == 'All' || project.status == _selectedStatus;

      final matchesPriority = !_highPriorityOnly || project.priority == 'High';

      return matchesSearch && matchesDepartment && matchesStatus && matchesPriority;
    }).toList();

    switch (_selectedSort) {
      case 'Progress':
        list.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case 'Budget Utilization':
        list.sort((a, b) => _budgetUsage(b).compareTo(_budgetUsage(a)));
        break;
      case 'Deadline':
        list.sort((a, b) => a.nextDeadline.compareTo(b.nextDeadline));
        break;
      default:
        list.sort((a, b) => _priorityWeight(b.priority).compareTo(_priorityWeight(a.priority)));
    }

    return list;
  }

  int _priorityWeight(String priority) {
    switch (priority) {
      case 'High':
        return 3;
      case 'Medium':
        return 2;
      case 'Low':
        return 1;
      default:
        return 0;
    }
  }

  double _budgetUsage(_ProjectRecord project) {
    if (project.budgetTotal <= 0) {
      return 0;
    }
    return project.budgetUsed / project.budgetTotal;
  }

  int _countByStatus(List<_ProjectRecord> list, String status) {
    return list.where((project) => project.status == status).length;
  }

  double _averageProgress(List<_ProjectRecord> list) {
    if (list.isEmpty) {
      return 0;
    }
    final total = list.fold<double>(0, (sum, project) => sum + project.progress);
    return total / list.length;
  }

  double _totalBudget(List<_ProjectRecord> list) {
    return list.fold<double>(0, (sum, project) => sum + project.budgetTotal);
  }

  double _usedBudget(List<_ProjectRecord> list) {
    return list.fold<double>(0, (sum, project) => sum + project.budgetUsed);
  }

  int _totalTeamMembers(List<_ProjectRecord> list) {
    return list.fold<int>(0, (sum, project) => sum + project.teamSize);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isCompact = width < 760;
            final isNarrow = width < 1140;
            final projects = _filteredProjects;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isCompact),
                  const SizedBox(height: 16),
                  _buildHeroCard(projects),
                  const SizedBox(height: 16),
                  _buildMetricGrid(width, projects),
                  const SizedBox(height: 16),
                  _buildFilterPanel(isCompact),
                  const SizedBox(height: 16),
                  if (isNarrow) ...[
                    _buildProjectsPanel(projects, isCompact),
                    const SizedBox(height: 14),
                    _buildInsightsPanel(projects),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildProjectsPanel(projects, false),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: _buildInsightsPanel(projects),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isCompact) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Active Projects',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 6),
        Text(
          'Track execution health, budget usage, and delivery risks across teams.',
          style: TextStyle(color: Color(0xFF5F6368)),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.file_download_outlined, size: 18),
          label: const Text('Export Plan'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1E293B),
            side: const BorderSide(color: Color(0xFFD5DEE9)),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_task_rounded, size: 18),
          label: const Text('Create Project'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF36B39C),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, const SizedBox(height: 10), actions],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        const SizedBox(width: 12),
        actions,
      ],
    );
  }

  Widget _buildHeroCard(List<_ProjectRecord> projects) {
    final budgetTotal = _totalBudget(projects);
    final budgetUsed = _usedBudget(projects);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F355B), Color(0xFF36B39C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF36B39C).withOpacity(0.24),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Execution Snapshot',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${projects.length} active projects in view',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Budget used ${_currency(budgetUsed)} of ${_currency(budgetTotal)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _heroChip('On Track', '${_countByStatus(projects, 'On Track')}'),
              _heroChip('At Risk', '${_countByStatus(projects, 'At Risk')}'),
              _heroChip('Delayed', '${_countByStatus(projects, 'Delayed')}'),
              _heroChip('Completed', '${_countByStatus(projects, 'Completed')}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricGrid(double width, List<_ProjectRecord> projects) {
    final crossAxisCount = width >= 1280
        ? 4
        : width >= 860
            ? 2
            : 1;

    final metrics = [
      _ProjectMetric(
        title: 'Average Progress',
        value: '${(_averageProgress(projects) * 100).toStringAsFixed(0)}%',
        subtitle: 'Across current projects',
        icon: Icons.stacked_line_chart_rounded,
        color: const Color(0xFF1A73E8),
      ),
      _ProjectMetric(
        title: 'Total Team Members',
        value: '${_totalTeamMembers(projects)}',
        subtitle: 'Assigned resources',
        icon: Icons.groups_2_outlined,
        color: const Color(0xFF36B39C),
      ),
      _ProjectMetric(
        title: 'High Priority',
        value: '${projects.where((e) => e.priority == 'High').length}',
        subtitle: 'Critical initiatives',
        icon: Icons.priority_high_rounded,
        color: const Color(0xFFF29900),
      ),
      _ProjectMetric(
        title: 'Budget Utilization',
        value: '${(_usedBudget(projects) / (_totalBudget(projects) == 0 ? 1 : _totalBudget(projects)) * 100).toStringAsFixed(0)}%',
        subtitle: 'Current burn rate',
        icon: Icons.account_balance_wallet_outlined,
        color: const Color(0xFF7C3AED),
      ),
    ];

    return GridView.builder(
      itemCount: metrics.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 124,
      ),
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return _panel(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: metric.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(metric.icon, color: metric.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      metric.title,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      metric.value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      metric.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
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

  Widget _buildFilterPanel(bool isCompact) {
    final search = TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: _inputDecoration(
        hintText: 'Search by project id, name, manager, or department',
        prefixIcon: const Icon(Icons.search_rounded),
      ),
    );

    final department = DropdownButtonFormField<String>(
      value: _selectedDepartment,
      decoration: _inputDecoration(labelText: 'Department'),
      items: _departments
          .map(
            (value) => DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _selectedDepartment = value;
        });
      },
    );

    final status = DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: _inputDecoration(labelText: 'Status'),
      items: _statusOptions
          .map(
            (value) => DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _selectedStatus = value;
        });
      },
    );

    final sort = DropdownButtonFormField<String>(
      value: _selectedSort,
      decoration: _inputDecoration(labelText: 'Sort By'),
      items: _sortOptions
          .map(
            (value) => DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _selectedSort = value;
        });
      },
    );

    final highPriorityOnly = FilterChip(
      label: const Text('High priority only'),
      selected: _highPriorityOnly,
      onSelected: (value) {
        setState(() {
          _highPriorityOnly = value;
        });
      },
      selectedColor: const Color(0xFFDB4437).withOpacity(0.14),
      side: const BorderSide(color: Color(0xFFD5DEE9)),
      labelStyle: TextStyle(
        color: _highPriorityOnly ? const Color(0xFFDB4437) : const Color(0xFF334155),
        fontWeight: FontWeight.w600,
      ),
    );

    final reset = TextButton.icon(
      onPressed: () {
        _searchController.clear();
        setState(() {
          _searchQuery = '';
          _selectedDepartment = 'All';
          _selectedStatus = 'All';
          _selectedSort = 'Priority';
          _highPriorityOnly = false;
        });
      },
      icon: const Icon(Icons.restart_alt_rounded, size: 18),
      label: const Text('Reset'),
    );

    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCompact) ...[
            search,
            const SizedBox(height: 10),
            department,
            const SizedBox(height: 10),
            status,
            const SizedBox(height: 10),
            sort,
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [highPriorityOnly, reset]),
          ] else ...[
            Row(
              children: [
                Expanded(flex: 4, child: search),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: department),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: status),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: sort),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [highPriorityOnly, reset]),
          ],
        ],
      ),
    );
  }

  Widget _buildProjectsPanel(List<_ProjectRecord> projects, bool isCompact) {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Project Register',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${projects.length} projects',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (projects.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'No projects match the current filters.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ...projects.map((project) => _projectRow(project, isCompact)),
        ],
      ),
    );
  }

  Widget _projectRow(_ProjectRecord project, bool isCompact) {
    final statusColor = _statusColor(project.status);
    final priorityColor = _priorityColor(project.priority);
    final budgetUsage = _budgetUsage(project);

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project.name,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          '${project.id} | ${project.department} | Manager: ${project.manager}',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        const SizedBox(height: 8),
        _progressLine(
          'Progress',
          project.progress,
          const Color(0xFF1A73E8),
        ),
        const SizedBox(height: 6),
        _progressLine(
          'Budget usage',
          budgetUsage,
          budgetUsage >= 0.9
              ? const Color(0xFFDB4437)
              : const Color(0xFF36B39C),
        ),
      ],
    );

    final chips = Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        _chip(project.priority, priorityColor),
        _chip(project.status, statusColor),
        _chip('${project.teamSize} members', const Color(0xFF334155)),
        _chip(_dateLabel(project.nextDeadline), const Color(0xFF7C3AED)),
      ],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF1A73E8).withOpacity(0.12),
                      child: Text(
                        _initials(project.name),
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
                const SizedBox(height: 8),
                chips,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF1A73E8).withOpacity(0.12),
                  child: Text(
                    _initials(project.name),
                    style: const TextStyle(
                      color: Color(0xFF1A73E8),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: details),
                const SizedBox(width: 10),
                SizedBox(width: 220, child: chips),
              ],
            ),
    );
  }

  Widget _progressLine(String label, double value, Color color) {
    final safe = value.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${(safe * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 7,
            value: safe,
            color: color,
            backgroundColor: const Color(0xFFE2E8F0),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsPanel(List<_ProjectRecord> projects) {
    final departmentRows = _departmentRows(projects);
    final topDeadlines = [...projects]..sort((a, b) => a.nextDeadline.compareTo(b.nextDeadline));

    return Column(
      children: [
        _panel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Department Load',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (departmentRows.isEmpty)
                const Text(
                  'No department data available.',
                  style: TextStyle(color: Color(0xFF64748B)),
                )
              else
                ...departmentRows.map(
                  (row) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            row.department,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '${row.count}',
                          style: const TextStyle(
                            color: Color(0xFF36B39C),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                'Upcoming Deadlines',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (topDeadlines.isEmpty)
                const Text(
                  'No upcoming deadlines.',
                  style: TextStyle(color: Color(0xFF64748B)),
                )
              else
                ...topDeadlines.take(5).map(
                  (project) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
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
                                project.name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                project.department,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _dateLabel(project.nextDeadline),
                          style: const TextStyle(
                            color: Color(0xFF7C3AED),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                'Quick Actions',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              _actionButton(Icons.timeline_rounded, 'Open project timeline board'),
              const SizedBox(height: 8),
              _actionButton(Icons.warning_amber_rounded, 'Review high-risk projects'),
              const SizedBox(height: 8),
              _actionButton(Icons.download_rounded, 'Export active projects report'),
            ],
          ),
        ),
      ],
    );
  }

  List<_DepartmentRow> _departmentRows(List<_ProjectRecord> list) {
    final counts = <String, int>{};
    for (final project in list) {
      counts.update(project.department, (value) => value + 1, ifAbsent: () => 1);
    }
    final rows = counts.entries
        .map((entry) => _DepartmentRow(entry.key, entry.value))
        .toList();
    rows.sort((a, b) => b.count.compareTo(a.count));
    return rows;
  }

  Widget _actionButton(IconData icon, String label) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 18, color: const Color(0xFF1A73E8)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  String _currency(double value) {
    return '\$${value.toStringAsFixed(0)}';
  }

  String _dateLabel(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'On Track':
        return const Color(0xFF0F9D58);
      case 'At Risk':
        return const Color(0xFFF29900);
      case 'Delayed':
        return const Color(0xFFDB4437);
      case 'Completed':
        return const Color(0xFF1A73E8);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFDB4437);
      case 'Medium':
        return const Color(0xFFF29900);
      case 'Low':
        return const Color(0xFF36B39C);
      default:
        return const Color(0xFF64748B);
    }
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

  InputDecoration _inputDecoration({String? labelText, String? hintText, Widget? prefixIcon}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

class _ProjectRecord {
  const _ProjectRecord({
    required this.id,
    required this.name,
    required this.department,
    required this.manager,
    required this.status,
    required this.priority,
    required this.progress,
    required this.budgetUsed,
    required this.budgetTotal,
    required this.teamSize,
    required this.milestoneCount,
    required this.nextDeadline,
  });

  final String id;
  final String name;
  final String department;
  final String manager;
  final String status;
  final String priority;
  final double progress;
  final double budgetUsed;
  final double budgetTotal;
  final int teamSize;
  final int milestoneCount;
  final DateTime nextDeadline;
}

class _ProjectMetric {
  const _ProjectMetric({
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

class _DepartmentRow {
  const _DepartmentRow(this.department, this.count);

  final String department;
  final int count;
}
