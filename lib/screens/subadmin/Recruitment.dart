import 'package:flutter/material.dart';

import 'Dashboard/Open_Recruiting_Board.dart';
import 'Recruitment/Export_pipeline.dart';
import 'Recruitment/Open_role.dart';
import 'Recruitment/Schedule Drive.dart';

class SubAdminRecruitmentPage extends StatefulWidget {
  const SubAdminRecruitmentPage({super.key});

  @override
  State<SubAdminRecruitmentPage> createState() =>
      _SubAdminRecruitmentPageState();
}

class _SubAdminRecruitmentPageState extends State<SubAdminRecruitmentPage> {
  String _searchQuery = '';
  String _selectedRole = 'All';
  String _selectedStage = 'All';
  String _selectedPriority = 'All';
  String _selectedOwner = 'All';
  bool _hideClosed = false;

  late final TextEditingController _searchController;

  static const List<String> _stageOptions = [
    'All',
    'Applied',
    'Screening',
    'Interview',
    'Offer',
    'Hired',
    'Rejected',
  ];

  static const List<String> _priorityOptions = [
    'All',
    'Critical',
    'High',
    'Normal',
  ];

  final List<_RecruitmentCandidate> _candidates = [
    _RecruitmentCandidate(
      id: 'CAN-901',
      name: 'Ritika Sengar',
      role: 'Payroll Analyst',
      stage: 'Interview',
      priority: 'High',
      owner: 'Sneha Iyer',
      source: 'LinkedIn',
      location: 'Ahmedabad',
      fitScore: 4.5,
      appliedDate: DateTime(2026, 3, 2),
      interviewDate: DateTime(2026, 3, 18, 11, 0),
    ),
    _RecruitmentCandidate(
      id: 'CAN-902',
      name: 'Vikram Nanda',
      role: 'HR Generalist',
      stage: 'Screening',
      priority: 'Normal',
      owner: 'R. Menon',
      source: 'Referral',
      location: 'Remote',
      fitScore: 3.9,
      appliedDate: DateTime(2026, 3, 5),
      interviewDate: null,
    ),
    _RecruitmentCandidate(
      id: 'CAN-903',
      name: 'Nikhil Dutta',
      role: 'Operations Executive',
      stage: 'Offer',
      priority: 'Critical',
      owner: 'P. Sinha',
      source: 'Campus Drive',
      location: 'Mumbai',
      fitScore: 4.7,
      appliedDate: DateTime(2026, 2, 27),
      interviewDate: DateTime(2026, 3, 16, 15, 30),
    ),
    _RecruitmentCandidate(
      id: 'CAN-904',
      name: 'Ananya Bose',
      role: 'Compliance Associate',
      stage: 'Applied',
      priority: 'High',
      owner: 'S. Bhatt',
      source: 'Naukri',
      location: 'Delhi',
      fitScore: 3.6,
      appliedDate: DateTime(2026, 3, 10),
      interviewDate: null,
    ),
    _RecruitmentCandidate(
      id: 'CAN-905',
      name: 'Aman Vohra',
      role: 'Finance Coordinator',
      stage: 'Interview',
      priority: 'Normal',
      owner: 'A. Kapoor',
      source: 'Referral',
      location: 'Pune',
      fitScore: 4.2,
      appliedDate: DateTime(2026, 3, 1),
      interviewDate: DateTime(2026, 3, 19, 10, 15),
    ),
    _RecruitmentCandidate(
      id: 'CAN-906',
      name: 'Shruti Jain',
      role: 'Talent Acquisition Specialist',
      stage: 'Hired',
      priority: 'Normal',
      owner: 'R. Menon',
      source: 'LinkedIn',
      location: 'Ahmedabad',
      fitScore: 4.8,
      appliedDate: DateTime(2026, 2, 12),
      interviewDate: DateTime(2026, 3, 6, 12, 0),
    ),
    _RecruitmentCandidate(
      id: 'CAN-907',
      name: 'Rahul Koli',
      role: 'Support Associate',
      stage: 'Rejected',
      priority: 'High',
      owner: 'P. Sinha',
      source: 'Walk-in',
      location: 'Vadodara',
      fitScore: 2.8,
      appliedDate: DateTime(2026, 2, 22),
      interviewDate: DateTime(2026, 3, 4, 17, 0),
    ),
    _RecruitmentCandidate(
      id: 'CAN-908',
      name: 'Priyanka Sahu',
      role: 'Business Analyst',
      stage: 'Screening',
      priority: 'Critical',
      owner: 'Sneha Iyer',
      source: 'LinkedIn',
      location: 'Remote',
      fitScore: 4.1,
      appliedDate: DateTime(2026, 3, 11),
      interviewDate: null,
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

  void _openRecruitingBoardPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SubAdminOpenRecruitingBoardPage(),
      ),
    );
  }

  List<String> get _roles {
    final values =
        _candidates.map((candidate) => candidate.role).toSet().toList()..sort();
    return ['All', ...values];
  }

  List<String> get _owners {
    final values = _candidates
        .map((candidate) => candidate.owner)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...values];
  }

  List<_RecruitmentCandidate> get _filteredCandidates {
    final query = _searchQuery.trim().toLowerCase();

    final list = _candidates.where((candidate) {
      final matchesSearch = query.isEmpty ||
          candidate.id.toLowerCase().contains(query) ||
          candidate.name.toLowerCase().contains(query) ||
          candidate.role.toLowerCase().contains(query) ||
          candidate.source.toLowerCase().contains(query) ||
          candidate.owner.toLowerCase().contains(query);

      final matchesRole =
          _selectedRole == 'All' || candidate.role == _selectedRole;
      final matchesStage =
          _selectedStage == 'All' || candidate.stage == _selectedStage;
      final matchesPriority =
          _selectedPriority == 'All' || candidate.priority == _selectedPriority;
      final matchesOwner =
          _selectedOwner == 'All' || candidate.owner == _selectedOwner;
      final matchesClosed = !_hideClosed ||
          (candidate.stage != 'Hired' && candidate.stage != 'Rejected');

      return matchesSearch &&
          matchesRole &&
          matchesStage &&
          matchesPriority &&
          matchesOwner &&
          matchesClosed;
    }).toList();

    list.sort((a, b) {
      final stageCompare =
          _stageWeight(a.stage).compareTo(_stageWeight(b.stage));
      if (stageCompare != 0) {
        return stageCompare;
      }
      return b.fitScore.compareTo(a.fitScore);
    });

    return list;
  }

  int _stageWeight(String stage) {
    switch (stage) {
      case 'Applied':
        return 0;
      case 'Screening':
        return 1;
      case 'Interview':
        return 2;
      case 'Offer':
        return 3;
      case 'Hired':
        return 4;
      case 'Rejected':
        return 5;
      default:
        return 9;
    }
  }

  int _countByStage(List<_RecruitmentCandidate> list, String stage) {
    return list.where((candidate) => candidate.stage == stage).length;
  }

  double _averageFitScore(List<_RecruitmentCandidate> list) {
    if (list.isEmpty) {
      return 0;
    }
    final total = list.fold<double>(0, (sum, item) => sum + item.fitScore);
    return total / list.length;
  }

  int _interviewsThisWeek(List<_RecruitmentCandidate> list) {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return list.where((candidate) {
      if (candidate.interviewDate == null) {
        return false;
      }
      final date = candidate.interviewDate!;
      final onlyDate = DateTime(date.year, date.month, date.day);
      return !onlyDate.isBefore(weekStart) && !onlyDate.isAfter(weekEnd);
    }).length;
  }

  Map<String, int> _ownerLoad(List<_RecruitmentCandidate> list) {
    final map = <String, int>{};
    for (final candidate in list) {
      map[candidate.owner] = (map[candidate.owner] ?? 0) + 1;
    }
    return map;
  }

  List<_RecruitmentCandidate> _upcomingInterviews(
      List<_RecruitmentCandidate> list) {
    final now = DateTime.now();
    final result = list.where((candidate) {
      final interview = candidate.interviewDate;
      return interview != null &&
          interview.isAfter(now.subtract(const Duration(days: 1)));
    }).toList();

    result.sort((a, b) => a.interviewDate!.compareTo(b.interviewDate!));
    return result.take(5).toList();
  }

  void _moveCandidateToNextStage(_RecruitmentCandidate candidate) {
    final next = _nextStage(candidate.stage);
    if (next == null) {
      _showSnack('Candidate ${candidate.id} is already in final stage.');
      return;
    }

    final index = _candidates.indexWhere((item) => item.id == candidate.id);
    if (index == -1) {
      return;
    }

    setState(() {
      _candidates[index] = _candidates[index].copyWith(stage: next);
    });

    _showSnack('Candidate ${candidate.id} moved to $next.');
  }

  String? _nextStage(String stage) {
    switch (stage) {
      case 'Applied':
        return 'Screening';
      case 'Screening':
        return 'Interview';
      case 'Interview':
        return 'Offer';
      case 'Offer':
        return 'Hired';
      default:
        return null;
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1A73E8),
      ),
    );
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
            final candidates = _filteredCandidates;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isCompact ? 14 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isCompact),
                  const SizedBox(height: 16),
                  _buildHeroCard(candidates),
                  const SizedBox(height: 16),
                  _buildMetricGrid(width, candidates),
                  const SizedBox(height: 16),
                  if (isNarrow) ...[
                    _buildPipelinePanel(candidates, isCompact),
                    const SizedBox(height: 14),
                    _buildInsightsPanel(candidates),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildPipelinePanel(candidates, false),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: _buildInsightsPanel(candidates),
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
          'Recruitment Pipeline',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 6),
        Text(
          'Plan hiring priorities, manage candidate flow, and fast-track critical roles with stage-level visibility.',
          style: TextStyle(color: Color(0xFF5F6368)),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            final entries = _filteredCandidates
                .map(
                  (candidate) => RecruitmentPipelineEntry(
                    id: candidate.id,
                    name: candidate.name,
                    role: candidate.role,
                    stage: candidate.stage,
                    priority: candidate.priority,
                    owner: candidate.owner,
                    source: candidate.source,
                    location: candidate.location,
                    fitScore: candidate.fitScore,
                    appliedDate: candidate.appliedDate,
                    interviewDate: candidate.interviewDate,
                  ),
                )
                .toList();

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SubAdminExportPipelinePage(entries: entries),
              ),
            );
          },
          icon: const Icon(Icons.file_download_outlined, size: 18),
          label: const Text('Export Pipeline'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0F172A),
            side: const BorderSide(color: Color(0xFFD6DEE8)),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SubAdminOpenRolePage(
                  roleSuggestions:
                      _roles.where((role) => role != 'All').toList(),
                  ownerSuggestions:
                      _owners.where((owner) => owner != 'All').toList(),
                ),
              ),
            );
          },
          icon: const Icon(Icons.work_outline_rounded, size: 18),
          label: const Text('Open Role'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1A73E8),
            side: const BorderSide(color: Color(0xFF1A73E8)),
          ),
        ),
        FilledButton.icon(
          onPressed: _openRecruitingBoardPage,
          icon: const Icon(Icons.grid_view_rounded, size: 18),
          label: const Text('Open Recruiting Board'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0F766E),
          ),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SubAdminScheduleDrivePage(
                  roles: _roles.where((role) => role != 'All').toList(),
                  owners: _owners.where((owner) => owner != 'All').toList(),
                ),
              ),
            );
          },
          icon: const Icon(Icons.event_available_outlined, size: 18),
          label: const Text('Schedule Drive'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1A73E8),
          ),
        ),
      ],
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 12),
          actions,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        actions,
      ],
    );
  }

  Widget _buildHeroCard(List<_RecruitmentCandidate> candidates) {
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
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const SizedBox(
            width: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hiring velocity is stable and offer conversions are improving week over week.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Focus this week: close critical offers and reduce screening backlog for analyst roles.',
                  style: TextStyle(color: Color(0xFFE3F2FD), fontSize: 12),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildHeroBadge(
                icon: Icons.badge_outlined,
                label: 'Open roles: ${_roles.length - 1}',
              ),
              _buildHeroBadge(
                icon: Icons.groups_outlined,
                label: 'Candidates: ${candidates.length}',
              ),
              _buildHeroBadge(
                icon: Icons.calendar_month_outlined,
                label:
                    'Interviews: ${_interviewsThisWeek(candidates)} this week',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBadge({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricGrid(
      double width, List<_RecruitmentCandidate> candidates) {
    final metrics = [
      _RecruitmentMetric(
        label: 'Total Candidates',
        value: '${candidates.length}',
        subtitle: 'Current filtered pipeline',
        icon: Icons.people_alt_outlined,
        color: const Color(0xFF1A73E8),
      ),
      _RecruitmentMetric(
        label: 'Interview Stage',
        value: '${_countByStage(candidates, 'Interview')}',
        subtitle: 'Ready for panel discussion',
        icon: Icons.record_voice_over_outlined,
        color: const Color(0xFFF29900),
      ),
      _RecruitmentMetric(
        label: 'Offer Ready',
        value: '${_countByStage(candidates, 'Offer')}',
        subtitle: 'Awaiting final decision',
        icon: Icons.workspace_premium_outlined,
        color: const Color(0xFF0F9D58),
      ),
      _RecruitmentMetric(
        label: 'Avg Fit Score',
        value: '${_averageFitScore(candidates).toStringAsFixed(1)}/5',
        subtitle: 'Across selected candidates',
        icon: Icons.insights_outlined,
        color: const Color(0xFF7C3AED),
      ),
    ];

    final columns = width >= 1180
        ? 4
        : width >= 720
            ? 2
            : 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 130,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5EAF2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: metric.color.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(metric.icon, color: metric.color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      metric.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                metric.value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                metric.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: metric.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPipelinePanel(
      List<_RecruitmentCandidate> candidates, bool isCompact) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6EBF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Candidate Board',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Filter by role, stage, priority, and owner to focus the hiring queue.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const SizedBox(height: 12),
          _buildFilterBar(isCompact),
          const SizedBox(height: 12),
          if (candidates.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'No candidates match current filters.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            )
          else
            ...candidates.map(
              (candidate) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildCandidateTile(candidate),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(bool isCompact) {
    final searchField = TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: 'Search candidates by id, name, role, owner...',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDCE3EC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDCE3EC)),
        ),
      ),
    );

    if (isCompact) {
      return Column(
        children: [
          searchField,
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: 170,
                child: _buildDropdown(
                  label: 'Role',
                  value: _selectedRole,
                  items: _roles,
                  onChanged: (value) => setState(() => _selectedRole = value),
                ),
              ),
              SizedBox(
                width: 170,
                child: _buildDropdown(
                  label: 'Stage',
                  value: _selectedStage,
                  items: _stageOptions,
                  onChanged: (value) => setState(() => _selectedStage = value),
                ),
              ),
              SizedBox(
                width: 170,
                child: _buildDropdown(
                  label: 'Priority',
                  value: _selectedPriority,
                  items: _priorityOptions,
                  onChanged: (value) =>
                      setState(() => _selectedPriority = value),
                ),
              ),
              SizedBox(
                width: 170,
                child: _buildDropdown(
                  label: 'Owner',
                  value: _selectedOwner,
                  items: _owners,
                  onChanged: (value) => setState(() => _selectedOwner = value),
                ),
              ),
              FilterChip(
                label: const Text('Hide Closed'),
                selected: _hideClosed,
                onSelected: (selected) =>
                    setState(() => _hideClosed = selected),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        searchField,
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SizedBox(
              width: 190,
              child: _buildDropdown(
                label: 'Role',
                value: _selectedRole,
                items: _roles,
                onChanged: (value) => setState(() => _selectedRole = value),
              ),
            ),
            SizedBox(
              width: 170,
              child: _buildDropdown(
                label: 'Stage',
                value: _selectedStage,
                items: _stageOptions,
                onChanged: (value) => setState(() => _selectedStage = value),
              ),
            ),
            SizedBox(
              width: 170,
              child: _buildDropdown(
                label: 'Priority',
                value: _selectedPriority,
                items: _priorityOptions,
                onChanged: (value) => setState(() => _selectedPriority = value),
              ),
            ),
            SizedBox(
              width: 170,
              child: _buildDropdown(
                label: 'Owner',
                value: _selectedOwner,
                items: _owners,
                onChanged: (value) => setState(() => _selectedOwner = value),
              ),
            ),
            FilterChip(
              label: const Text('Hide Closed'),
              selected: _hideClosed,
              onSelected: (selected) => setState(() => _hideClosed = selected),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      selectedItemBuilder: (context) {
        return items
            .map(
              (item) => Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList();
      },
      onChanged: (changed) {
        if (changed != null) {
          onChanged(changed);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDCE3EC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDCE3EC)),
        ),
      ),
    );
  }

  Widget _buildCandidateTile(_RecruitmentCandidate candidate) {
    final nextStage = _nextStage(candidate.stage);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
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
                      candidate.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${candidate.id}  •  ${candidate.role}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _stageColor(candidate.stage).withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  candidate.stage,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _stageColor(candidate.stage),
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
              _buildInfoChip('Owner', candidate.owner),
              _buildInfoChip('Priority', candidate.priority,
                  color: _priorityColor(candidate.priority)),
              _buildInfoChip('Source', candidate.source),
              _buildInfoChip(
                  'Fit', '${candidate.fitScore.toStringAsFixed(1)}/5'),
              _buildInfoChip('Location', candidate.location),
              if (candidate.interviewDate != null)
                _buildInfoChip(
                  'Interview',
                  _formatDate(candidate.interviewDate!),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () =>
                    _showSnack('Opened profile for ${candidate.name}.'),
                icon: const Icon(Icons.person_outline_rounded, size: 17),
                label: const Text('View Profile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F172A),
                  side: const BorderSide(color: Color(0xFFD3DCE7)),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: nextStage == null
                    ? null
                    : () => _moveCandidateToNextStage(candidate),
                icon: const Icon(Icons.trending_flat_rounded, size: 17),
                label: Text(
                    nextStage == null ? 'Final Stage' : 'Move to $nextStage'),
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

  Widget _buildInfoChip(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: (color ?? const Color(0xFF64748B)).withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color ?? const Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildInsightsPanel(List<_RecruitmentCandidate> candidates) {
    return Column(
      children: [
        _buildStageBreakdownCard(candidates),
        const SizedBox(height: 12),
        _buildOwnerLoadCard(candidates),
        const SizedBox(height: 12),
        _buildUpcomingInterviewCard(candidates),
      ],
    );
  }

  Widget _buildStageBreakdownCard(List<_RecruitmentCandidate> candidates) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stage Distribution',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ..._stageOptions.where((stage) => stage != 'All').map((stage) =>
              _buildStageRow(
                  stage, _countByStage(candidates, stage), candidates.length)),
        ],
      ),
    );
  }

  Widget _buildStageRow(String stage, int count, int total) {
    final ratio = total == 0 ? 0.0 : count / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  stage,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _stageColor(stage),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: const Color(0xFFE8EDF5),
              valueColor: AlwaysStoppedAnimation<Color>(_stageColor(stage)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerLoadCard(List<_RecruitmentCandidate> candidates) {
    final ownerLoad = _ownerLoad(candidates).entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recruiter Workload',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (ownerLoad.isEmpty)
            const Text(
              'No recruiter assignments in current filters.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            )
          else
            ...ownerLoad.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${entry.value} candidates',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A73E8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUpcomingInterviewCard(List<_RecruitmentCandidate> candidates) {
    final upcoming = _upcomingInterviews(candidates);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Interviews',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (upcoming.isEmpty)
            const Text(
              'No upcoming interviews scheduled.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            )
          else
            ...upcoming.map(
              (candidate) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.schedule_outlined,
                        size: 16,
                        color: Color(0xFF1A73E8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            candidate.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '${candidate.role}  •  ${_formatDate(candidate.interviewDate!)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _stageColor(String stage) {
    switch (stage) {
      case 'Applied':
        return const Color(0xFF64748B);
      case 'Screening':
        return const Color(0xFF1A73E8);
      case 'Interview':
        return const Color(0xFFF29900);
      case 'Offer':
        return const Color(0xFF0F9D58);
      case 'Hired':
        return const Color(0xFF0B8043);
      case 'Rejected':
        return const Color(0xFFDB4437);
      default:
        return const Color(0xFF64748B);
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
    final month = _monthName(date.month);
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour >= 12 ? 'PM' : 'AM';

    if (date.hour == 0 && date.minute == 0) {
      return '$month ${date.day}, ${date.year}';
    }
    return '$month ${date.day}, ${date.year}  $hour:$minute $suffix';
  }

  String _monthName(int month) {
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
    return months[month - 1];
  }
}

class _RecruitmentMetric {
  const _RecruitmentMetric({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class _RecruitmentCandidate {
  const _RecruitmentCandidate({
    required this.id,
    required this.name,
    required this.role,
    required this.stage,
    required this.priority,
    required this.owner,
    required this.source,
    required this.location,
    required this.fitScore,
    required this.appliedDate,
    required this.interviewDate,
  });

  final String id;
  final String name;
  final String role;
  final String stage;
  final String priority;
  final String owner;
  final String source;
  final String location;
  final double fitScore;
  final DateTime appliedDate;
  final DateTime? interviewDate;

  _RecruitmentCandidate copyWith({
    String? stage,
  }) {
    return _RecruitmentCandidate(
      id: id,
      name: name,
      role: role,
      stage: stage ?? this.stage,
      priority: priority,
      owner: owner,
      source: source,
      location: location,
      fitScore: fitScore,
      appliedDate: appliedDate,
      interviewDate: interviewDate,
    );
  }
}
