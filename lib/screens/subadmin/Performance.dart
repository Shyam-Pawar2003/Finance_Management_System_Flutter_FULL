import 'package:flutter/material.dart';

import 'Performance/Finalize_manager_review_cycle.dart';
import 'Performance/Download_company_scorecard_Pdf.dart';
import 'Performance/Export_report.dart';
import 'Performance/Open_performance_calibration_board.dart';
import 'Performance/Start_calibration.dart';

class SubAdminPerformancePage extends StatefulWidget {
  const SubAdminPerformancePage({super.key});

  @override
  State<SubAdminPerformancePage> createState() =>
      _SubAdminPerformancePageState();
}

class _SubAdminPerformancePageState extends State<SubAdminPerformancePage> {
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  String _selectedSort = 'Score';
  String _selectedPeriod = 'Quarterly';

  late final TextEditingController _searchController;

  static const List<String> _sortOptions = [
    'Score',
    'Engagement',
    'Delivery',
    'Lowest Risk',
  ];

  static const List<String> _periodOptions = ['Monthly', 'Quarterly', 'YTD'];

  final List<_ManagerPerformance> _managers = const [
    _ManagerPerformance(
      manager: 'A. Kapoor',
      department: 'Finance',
      teamSize: 14,
      projectsDelivered: 12,
      targetAchievement: 0.93,
      qualityScore: 90,
      engagementScore: 88,
      attritionRisk: 0.08,
      reviewCompletion: 0.97,
      trend: 0.06,
    ),
    _ManagerPerformance(
      manager: 'R. Menon',
      department: 'HR',
      teamSize: 10,
      projectsDelivered: 8,
      targetAchievement: 0.89,
      qualityScore: 86,
      engagementScore: 91,
      attritionRisk: 0.09,
      reviewCompletion: 0.94,
      trend: 0.04,
    ),
    _ManagerPerformance(
      manager: 'P. Sinha',
      department: 'Operations',
      teamSize: 18,
      projectsDelivered: 16,
      targetAchievement: 0.87,
      qualityScore: 84,
      engagementScore: 82,
      attritionRisk: 0.13,
      reviewCompletion: 0.9,
      trend: -0.01,
    ),
    _ManagerPerformance(
      manager: 'S. Bhatt',
      department: 'Legal',
      teamSize: 7,
      projectsDelivered: 6,
      targetAchievement: 0.95,
      qualityScore: 93,
      engagementScore: 87,
      attritionRisk: 0.07,
      reviewCompletion: 0.99,
      trend: 0.08,
    ),
    _ManagerPerformance(
      manager: 'M. Arora',
      department: 'Sales',
      teamSize: 12,
      projectsDelivered: 11,
      targetAchievement: 0.91,
      qualityScore: 88,
      engagementScore: 85,
      attritionRisk: 0.1,
      reviewCompletion: 0.92,
      trend: 0.03,
    ),
    _ManagerPerformance(
      manager: 'N. Verma',
      department: 'Support',
      teamSize: 16,
      projectsDelivered: 14,
      targetAchievement: 0.86,
      qualityScore: 82,
      engagementScore: 80,
      attritionRisk: 0.16,
      reviewCompletion: 0.84,
      trend: -0.02,
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
    final values =
        _managers.map((manager) => manager.department).toSet().toList()..sort();
    return ['All', ...values];
  }

  List<_ManagerPerformance> get _filteredManagers {
    final query = _searchQuery.trim().toLowerCase();

    final list = _managers.where((manager) {
      final matchesSearch = query.isEmpty ||
          manager.manager.toLowerCase().contains(query) ||
          manager.department.toLowerCase().contains(query);

      final matchesDepartment = _selectedDepartment == 'All' ||
          manager.department == _selectedDepartment;

      return matchesSearch && matchesDepartment;
    }).toList();

    switch (_selectedSort) {
      case 'Engagement':
        list.sort((a, b) => b.engagementScore.compareTo(a.engagementScore));
        break;
      case 'Delivery':
        list.sort((a, b) => b.targetAchievement.compareTo(a.targetAchievement));
        break;
      case 'Lowest Risk':
        list.sort((a, b) => a.attritionRisk.compareTo(b.attritionRisk));
        break;
      default:
        list.sort(
            (a, b) => _performanceScore(b).compareTo(_performanceScore(a)));
    }

    return list;
  }

  double _performanceScore(_ManagerPerformance manager) {
    final weighted = manager.targetAchievement * 34 +
        (manager.qualityScore / 100) * 28 +
        (manager.engagementScore / 100) * 20 +
        manager.reviewCompletion * 18 -
        manager.attritionRisk * 18;
    return weighted.clamp(0, 100);
  }

  double _avgScore(List<_ManagerPerformance> list) {
    if (list.isEmpty) {
      return 0;
    }
    final total = list.fold<double>(0, (sum, manager) {
      return sum + _performanceScore(manager);
    });
    return total / list.length;
  }

  double _avgEngagement(List<_ManagerPerformance> list) {
    if (list.isEmpty) {
      return 0;
    }
    final total = list.fold<double>(0, (sum, manager) {
      return sum + manager.engagementScore;
    });
    return total / list.length;
  }

  int _teamsAboveTarget(List<_ManagerPerformance> list) {
    return list.where((manager) => manager.targetAchievement >= 0.9).length;
  }

  int _focusTeams(List<_ManagerPerformance> list) {
    return list
        .where((manager) =>
            manager.attritionRisk >= 0.14 || manager.reviewCompletion < 0.88)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 760;
        final isNarrow = width < 1140;
        final managers = _filteredManagers;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isCompact),
              const SizedBox(height: 16),
              _buildHeroCard(managers),
              const SizedBox(height: 16),
              _buildMetricGrid(width, managers),
              const SizedBox(height: 16),
              _buildFilterPanel(isCompact),
              const SizedBox(height: 16),
              if (isNarrow) ...[
                _buildManagersPanel(managers, isCompact),
                const SizedBox(height: 14),
                _buildCompanyInsights(managers),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildManagersPanel(managers, false),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildCompanyInsights(managers),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isCompact) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Performance',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 6),
        Text(
          'Track manager effectiveness and overall company performance health.',
          style: TextStyle(color: Color(0xFF5F6368)),
        ),
      ],
    );

    final actionButtons = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SubAdminExportReportPage(
                  entries: _managers
                      .map((m) => PerformanceReportEntry(
                            manager: m.manager,
                            department: m.department,
                            teamSize: m.teamSize,
                            projectsDelivered: m.projectsDelivered,
                            targetAchievement: m.targetAchievement,
                            qualityScore: m.qualityScore,
                            engagementScore: m.engagementScore,
                            attritionRisk: m.attritionRisk,
                            reviewCompletion: m.reviewCompletion,
                            trend: m.trend,
                            compositeScore: _performanceScore(m),
                          ))
                      .toList(),
                  period: _selectedPeriod,
                ),
              ),
            );
          },
          icon: const Icon(Icons.file_download_outlined, size: 18),
          label: const Text('Export report'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1E293B),
            side: const BorderSide(color: Color(0xFFD5DEE9)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    const SubAdminOpenPerformanceCalibrationBoardPage(),
              ),
            );
          },
          icon: const Icon(Icons.dashboard_customize_rounded, size: 18),
          label: const Text('Calibration Board'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF36B39C),
            side: const BorderSide(color: Color(0xFF36B39C)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SubAdminStartCalibrationPage(),
              ),
            );
          },
          icon: const Icon(Icons.track_changes_rounded, size: 18),
          label: const Text('Start calibration'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF36B39C),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [heading, const SizedBox(height: 10), actionButtons],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: heading),
        const SizedBox(width: 12),
        actionButtons,
      ],
    );
  }

  Widget _buildHeroCard(List<_ManagerPerformance> managers) {
    final score = _avgScore(managers);
    final engagement = _avgEngagement(managers);
    final focus = _focusTeams(managers);

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
            color: const Color(0xFF36B39C).withOpacity(0.22),
            blurRadius: 20,
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
                'Overall Company Performance',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${score.toStringAsFixed(1)} / 100',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Composite index: delivery, quality, engagement, and retention',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _heroChip('Engagement', '${engagement.toStringAsFixed(0)}%'),
              _heroChip('Teams Above Target', '${_teamsAboveTarget(managers)}'),
              _heroChip('Focus Teams', '$focus'),
              _heroChip('Period', _selectedPeriod),
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

  Widget _buildMetricGrid(double width, List<_ManagerPerformance> managers) {
    final crossAxisCount = width >= 1280
        ? 4
        : width >= 860
            ? 2
            : 1;

    final metrics = [
      _PerformanceMetric(
        title: 'Company Score',
        value: _avgScore(managers).toStringAsFixed(1),
        subtitle: 'Weighted performance index',
        icon: Icons.analytics_outlined,
        color: const Color(0xFF1A73E8),
      ),
      _PerformanceMetric(
        title: 'Avg Engagement',
        value: '${_avgEngagement(managers).toStringAsFixed(0)}%',
        subtitle: 'Team pulse across managers',
        icon: Icons.favorite_outline_rounded,
        color: const Color(0xFF36B39C),
      ),
      _PerformanceMetric(
        title: 'Above Target',
        value: '${_teamsAboveTarget(managers)} teams',
        subtitle: 'Delivery >= 90% target',
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF0F9D58),
      ),
      _PerformanceMetric(
        title: 'Improvement Focus',
        value: '${_focusTeams(managers)} teams',
        subtitle: 'Need coaching intervention',
        icon: Icons.flag_rounded,
        color: const Color(0xFFF29900),
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
        hintText: 'Search manager or department',
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
        if (value == null) {
          return;
        }
        setState(() {
          _selectedDepartment = value;
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
        if (value == null) {
          return;
        }
        setState(() {
          _selectedSort = value;
        });
      },
    );

    final period = DropdownButtonFormField<String>(
      value: _selectedPeriod,
      decoration: _inputDecoration(labelText: 'Period'),
      items: _periodOptions
          .map(
            (value) => DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        setState(() {
          _selectedPeriod = value;
        });
      },
    );

    final reset = TextButton.icon(
      onPressed: () {
        _searchController.clear();
        setState(() {
          _searchQuery = '';
          _selectedDepartment = 'All';
          _selectedSort = 'Score';
          _selectedPeriod = 'Quarterly';
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
            sort,
            const SizedBox(height: 10),
            period,
            const SizedBox(height: 8),
            reset,
          ] else
            Row(
              children: [
                Expanded(flex: 4, child: search),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: department),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: sort),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: period),
                const SizedBox(width: 8),
                reset,
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildManagersPanel(List<_ManagerPerformance> list, bool isCompact) {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Manager Scorecards',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${list.length} managers',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (list.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'No manager records match your current filters.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ...list.map((manager) => _managerRow(manager, isCompact)),
        ],
      ),
    );
  }

  Widget _managerRow(_ManagerPerformance manager, bool isCompact) {
    final score = _performanceScore(manager);
    final initials = _initials(manager.manager);

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                manager.manager,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
            _chip(
              score >= 86
                  ? 'High Performing'
                  : score >= 78
                      ? 'Stable'
                      : 'Needs Support',
              score >= 86
                  ? const Color(0xFF0F9D58)
                  : score >= 78
                      ? const Color(0xFF1A73E8)
                      : const Color(0xFFF29900),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${manager.department} | Team size ${manager.teamSize} | ${manager.projectsDelivered} projects',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        const SizedBox(height: 10),
        _progressMetric(
          'Target achievement',
          manager.targetAchievement,
          const Color(0xFF1A73E8),
        ),
        const SizedBox(height: 8),
        _progressMetric(
          'Review completion',
          manager.reviewCompletion,
          const Color(0xFF36B39C),
        ),
        const SizedBox(height: 8),
        _progressMetric(
          'Attrition risk',
          manager.attritionRisk,
          const Color(0xFFDB4437),
          invert: true,
        ),
      ],
    );

    final rightMetrics = Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        _chip('Score ${score.toStringAsFixed(1)}', const Color(0xFF0F355B)),
        _chip('Engagement ${manager.engagementScore.toStringAsFixed(0)}%',
            const Color(0xFF36B39C)),
        _chip(
          manager.trend >= 0
              ? '+${(manager.trend * 100).toStringAsFixed(0)}% trend'
              : '${(manager.trend * 100).toStringAsFixed(0)}% trend',
          manager.trend >= 0
              ? const Color(0xFF0F9D58)
              : const Color(0xFFDB4437),
        ),
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
                      backgroundColor:
                          const Color(0xFF1A73E8).withOpacity(0.12),
                      child: Text(
                        initials,
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
                rightMetrics,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF1A73E8).withOpacity(0.12),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Color(0xFF1A73E8),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: details),
                const SizedBox(width: 10),
                SizedBox(width: 230, child: rightMetrics),
              ],
            ),
    );
  }

  Widget _progressMetric(
    String label,
    double value,
    Color color, {
    bool invert = false,
  }) {
    final normalized = invert ? (1 - value) : value;
    final safe = normalized.clamp(0.0, 1.0);
    final percent = (value * 100).toStringAsFixed(0);

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
              '$percent%',
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
            minHeight: 8,
            value: safe,
            color: color,
            backgroundColor: const Color(0xFFE2E8F0),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyInsights(List<_ManagerPerformance> list) {
    final departmentRows = _departmentAverages(list);

    return Column(
      children: [
        _panel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Department Performance',
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
                  (row) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                row.department,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              row.score.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Color(0xFF1A73E8),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: (row.score / 100).clamp(0.0, 1.0),
                            color: const Color(0xFF1A73E8),
                            backgroundColor: const Color(0xFFE2E8F0),
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
                'Company Trend',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ..._companyTrend.map(
                (entry) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 56,
                        child: Text(
                          entry.label,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 7,
                            value: (entry.score / 100).clamp(0.0, 1.0),
                            color: const Color(0xFF36B39C),
                            backgroundColor: const Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.score.toStringAsFixed(0),
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
                'Quick Actions',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              _actionButton(
                Icons.assignment_turned_in_outlined,
                'Finalize manager review cycle',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const SubAdminFinalizeManagerReviewCyclePage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              _actionButton(
                Icons.bar_chart_rounded,
                'Open performance calibration board',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const SubAdminOpenPerformanceCalibrationBoardPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              _actionButton(
                Icons.file_copy_outlined,
                'Download company scorecard PDF',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SubAdminDownloadCompanyScorecardPdfPage(
                        entries: _managers
                            .map(
                              (m) => CompanyScorecardEntry(
                                manager: m.manager,
                                department: m.department,
                                teamSize: m.teamSize,
                                targetAchievement: m.targetAchievement,
                                qualityScore: m.qualityScore,
                                engagementScore: m.engagementScore,
                                reviewCompletion: m.reviewCompletion,
                                attritionRisk: m.attritionRisk,
                                trend: m.trend,
                                compositeScore: _performanceScore(m),
                              ),
                            )
                            .toList(),
                        period: _selectedPeriod,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<_DepartmentScore> _departmentAverages(List<_ManagerPerformance> list) {
    final grouped = <String, List<_ManagerPerformance>>{};

    for (final manager in list) {
      grouped.putIfAbsent(manager.department, () => []).add(manager);
    }

    final rows = grouped.entries.map((entry) {
      final average = _avgScore(entry.value);
      return _DepartmentScore(entry.key, average);
    }).toList();

    rows.sort((a, b) => b.score.compareTo(a.score));
    return rows;
  }

  Widget _actionButton(IconData icon, String label, {VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed ?? () {},
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  InputDecoration _inputDecoration(
      {String? labelText, String? hintText, Widget? prefixIcon}) {
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

  static const List<_TrendPoint> _companyTrend = [
    _TrendPoint('Nov', 79),
    _TrendPoint('Dec', 81),
    _TrendPoint('Jan', 83),
    _TrendPoint('Feb', 85),
    _TrendPoint('Mar', 87),
  ];
}

class _ManagerPerformance {
  const _ManagerPerformance({
    required this.manager,
    required this.department,
    required this.teamSize,
    required this.projectsDelivered,
    required this.targetAchievement,
    required this.qualityScore,
    required this.engagementScore,
    required this.attritionRisk,
    required this.reviewCompletion,
    required this.trend,
  });

  final String manager;
  final String department;
  final int teamSize;
  final int projectsDelivered;
  final double targetAchievement;
  final double qualityScore;
  final double engagementScore;
  final double attritionRisk;
  final double reviewCompletion;
  final double trend;
}

class _PerformanceMetric {
  const _PerformanceMetric({
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

class _DepartmentScore {
  const _DepartmentScore(this.department, this.score);

  final String department;
  final double score;
}

class _TrendPoint {
  const _TrendPoint(this.label, this.score);

  final String label;
  final double score;
}
