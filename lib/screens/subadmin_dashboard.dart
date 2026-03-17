import 'package:flutter/material.dart';

import '../Dashboard/Admin/Inbox_Page.dart';
import '../Dashboard/Admin/calendar_page.dart';
import 'subadmin/Employees.dart';
import 'subadmin/Dashboard/Open_Recruiting_Board.dart';
import 'subadmin/Dashboard/Review_Approvals.dart';
import 'subadmin/Performance.dart';
import 'subadmin/Payroll.dart';
import 'subadmin/Profile.dart';
import 'subadmin/Recruitment.dart';
import 'subadmin/Settings.dart';

class SubAdminDashboard extends StatefulWidget {
  const SubAdminDashboard({super.key});

  @override
  State<SubAdminDashboard> createState() => _SubAdminDashboardState();
}

class _SubAdminDashboardState extends State<SubAdminDashboard> {
  int selectedIndex = 0;

  void _openProfilePage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SubAdminProfilePage()),
    );
  }

  void _openReviewApprovalsPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SubAdminReviewApprovalsPage()),
    );
  }

  void _openRecruitingBoardPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SubAdminOpenRecruitingBoardPage(),
      ),
    );
  }

  final List<_SubAdminNavItem> _menuItems = const [
    _SubAdminNavItem('Dashboard', Icons.space_dashboard_rounded),
    _SubAdminNavItem('Inbox', Icons.mail_outline_rounded),
    _SubAdminNavItem('Calendar', Icons.calendar_month_outlined),
    _SubAdminNavItem('Employees', Icons.groups_2_outlined),
    _SubAdminNavItem('Attendance', Icons.access_time_filled_outlined),
    _SubAdminNavItem('Performance', Icons.insights_outlined),
    _SubAdminNavItem('Payroll', Icons.account_balance_wallet_outlined),
    _SubAdminNavItem('Leave Management', Icons.event_note_outlined),
    _SubAdminNavItem('Recruitment', Icons.person_search_outlined),
    _SubAdminNavItem('Settings', Icons.settings_outlined),
  ];

  final List<_DashboardMetric> _metrics = const [
    _DashboardMetric(
      label: 'Total Employees',
      value: '58',
      trend: '+6 this month',
      icon: Icons.groups_2_outlined,
      accent: Color(0xFF2563EB),
    ),
    _DashboardMetric(
      label: 'Active Tasks',
      value: '134',
      trend: '18 due today',
      icon: Icons.fact_check_outlined,
      accent: Color(0xFF0EA5A4),
    ),
    _DashboardMetric(
      label: 'Attendance Rate',
      value: '96.1%',
      trend: '+1.8% vs last week',
      icon: Icons.pie_chart_outline_rounded,
      accent: Color(0xFFF97316),
    ),
    _DashboardMetric(
      label: 'Open Recruitments',
      value: '07',
      trend: '3 interviews today',
      icon: Icons.work_outline_rounded,
      accent: Color(0xFF7C3AED),
    ),
  ];

  final List<_ActivityEntry> _recentActivities = const [
    _ActivityEntry(
      title: 'Payroll approvals completed for March cycle',
      time: '10 min ago',
      icon: Icons.check_circle_outline_rounded,
      accent: Color(0xFF0EA5A4),
    ),
    _ActivityEntry(
      title: '2 new candidates moved to final interview stage',
      time: '42 min ago',
      icon: Icons.person_add_alt_1_outlined,
      accent: Color(0xFF2563EB),
    ),
    _ActivityEntry(
      title: 'Leave request submitted by Operations team',
      time: '1 hour ago',
      icon: Icons.event_note_outlined,
      accent: Color(0xFFF97316),
    ),
    _ActivityEntry(
      title: 'Compliance checklist updated for Q2 onboarding',
      time: 'Today, 08:30 AM',
      icon: Icons.verified_user_outlined,
      accent: Color(0xFF7C3AED),
    ),
  ];

  final List<_TeamHealthRow> _teamHealth = const [
    _TeamHealthRow('Support', 0.92, Color(0xFF2563EB), 'Stable response time'),
    _TeamHealthRow(
        'Finance Ops', 0.84, Color(0xFF0EA5A4), 'Pending review load'),
    _TeamHealthRow(
        'HR Shared', 0.76, Color(0xFFF97316), 'Interviews in progress'),
    _TeamHealthRow('Compliance', 0.89, Color(0xFF7C3AED), 'Audit ready'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1080;
    final isTablet = width >= 760;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3FA),
      drawer: isDesktop
          ? null
          : Drawer(
              child: _buildSidebar(isDesktop: false),
            ),
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop)
              SizedBox(
                width: 290,
                child: _buildSidebar(isDesktop: true),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 30 : 14,
                  isTablet ? 24 : 12,
                  isTablet ? 30 : 14,
                  isTablet ? 20 : 12,
                ),
                child: Column(
                  children: [
                    _buildTopBar(isDesktop: isDesktop),
                    const SizedBox(height: 18),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: Container(
                          key: ValueKey(selectedIndex),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(isTablet ? 20 : 14),
                          child: _buildContent(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar({required bool isDesktop}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFF22D3EE),
                      child: Icon(
                        Icons.admin_panel_settings_outlined,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sub Admin Panel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Operations Command Center',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0891B2).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_graph_rounded,
                        color: Color(0xFF67E8F9), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Weekly completion: 86%',
                        style:
                            TextStyle(color: Color(0xFFE0F2FE), fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  itemCount: _menuItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final item = _menuItems[index];
                    final isActive = selectedIndex == index;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                          if (!isDesktop) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF22D3EE).withOpacity(0.18)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isActive
                                  ? const Color(0xFF67E8F9).withOpacity(0.55)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                color: isActive
                                    ? const Color(0xFF67E8F9)
                                    : Colors.white70,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isActive
                                        ? Colors.white
                                        : Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    if (!isDesktop) {
                      Navigator.of(context).pop();
                    }
                    _openProfilePage();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFF6366F1),
                          child: Icon(Icons.person_outline_rounded,
                              color: Colors.white, size: 18),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shyam Patel',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                'Sub Admin',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white70, size: 14),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar({required bool isDesktop}) {
    final currentSection = _menuItems[selectedIndex].label;
    final subtitle = selectedIndex == 0
        ? 'Monitor people operations, approvals, and team activity in one place.'
        : 'Manage $currentSection workflows and keep execution aligned.';

    return Row(
      children: [
        if (!isDesktop)
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu_rounded),
              );
            },
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentSection,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0EA5A4).withOpacity(0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            children: [
              Icon(Icons.bolt_rounded, size: 16, color: Color(0xFF0F766E)),
              SizedBox(width: 6),
              Text(
                'System Healthy',
                style: TextStyle(
                  color: Color(0xFF0F766E),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _openProfilePage,
            borderRadius: BorderRadius.circular(999),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: CircleAvatar(
                radius: 19,
                backgroundColor: Color(0xFF1D4ED8),
                child: Icon(Icons.person_rounded, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return _buildDashboardContent();

      case 1:
        return const InboxPage();

      case 2:
        return const CalendarPage();

      case 3:
        return const SubAdminEmployeesPage();

      case 4:
        return _buildPlaceholderPage(
          title: 'Attendance Insights',
          description:
              'Track punctuality trends, shift adherence, and department level attendance in real time.',
          icon: Icons.access_time_filled_outlined,
          accent: const Color(0xFF0EA5A4),
          highlights: const [
            'Live attendance board',
            'Late check-in monitor',
            'Shift compliance summary',
          ],
        );

      case 5:
        return const SubAdminPerformancePage();

      case 6:
        return const SubAdminPayrollPage();

      case 7:
        return _buildPlaceholderPage(
          title: 'Leave Management',
          description:
              'Approve requests faster with policy-aware balances, team overlap alerts, and holiday sync.',
          icon: Icons.event_note_outlined,
          accent: const Color(0xFFF97316),
          highlights: const [
            'Approval workflow board',
            'Policy breach alerts',
            'Team overlap heatmap',
          ],
        );

      case 8:
        return const SubAdminRecruitmentPage();

      case 9:
        return const SubAdminSettingsPage();

      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1120;
        final isMid = constraints.maxWidth >= 760;
        final cardWidth = constraints.maxWidth >= 1120
            ? (constraints.maxWidth - 36) / 4
            : constraints.maxWidth >= 760
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1D4ED8), Color(0xFF0891B2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back, Shyam',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your teams are running smoothly today. Focus areas: payroll confirmation and final interview scheduling.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.88),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _heroButton(
                          label: 'Review Approvals',
                          icon: Icons.rule_folder_outlined,
                          foreground: const Color(0xFF0F172A),
                          background: Colors.white,
                          onTap: _openReviewApprovalsPage,
                        ),
                        _heroButton(
                          label: 'Open Recruiting Board',
                          icon: Icons.grid_view_rounded,
                          foreground: Colors.white,
                          background: Colors.white.withOpacity(0.16),
                          onTap: _openRecruitingBoardPage,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _metrics
                    .map((metric) => _buildMetricCard(metric, cardWidth))
                    .toList(),
              ),
              const SizedBox(height: 16),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: _buildActivityCard()),
                    const SizedBox(width: 12),
                    Expanded(flex: 5, child: _buildTeamHealthCard()),
                  ],
                )
              else
                Column(
                  children: [
                    _buildActivityCard(),
                    const SizedBox(height: 12),
                    _buildTeamHealthCard(),
                  ],
                ),
              if (isMid) const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _heroButton({
    required String label,
    required IconData icon,
    required Color foreground,
    required Color background,
    VoidCallback? onTap,
  }) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: content,
      ),
    );
  }

  Widget _buildMetricCard(_DashboardMetric metric, double width) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: metric.accent.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(metric.icon, color: metric.accent, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    metric.label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              metric.value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              metric.trend,
              style: TextStyle(
                fontSize: 12,
                color: metric.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Latest actions across payroll, recruitment, and team management.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const SizedBox(height: 12),
          ..._recentActivities.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ActivityTile(entry: entry),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamHealthCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Team Health',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Capacity and throughput snapshot by functional team.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const SizedBox(height: 14),
          ..._teamHealth.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          row.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Text(
                        '${(row.progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: row.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: row.progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(row.accent),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    row.note,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
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

  Widget _buildPlaceholderPage({
    required String title,
    required String description,
    required IconData icon,
    required Color accent,
    required List<String> highlights,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 940;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, const Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: highlights
                    .map(
                      (item) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: accent.withOpacity(0.32)),
                        ),
                        child: Text(
                          item,
                          style: TextStyle(
                            color: accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildRoadmapCard(accent: accent)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickSummaryCard(
                        accent: accent,
                        title: title,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildRoadmapCard(accent: accent),
                    const SizedBox(height: 12),
                    _buildQuickSummaryCard(accent: accent, title: title),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoadmapCard({required Color accent}) {
    final roadmapItems = [
      'Data sync and validation checks',
      'Approvals and exception handling',
      'Final review and team communication',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Execution Roadmap',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          ...roadmapItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 13,
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

  Widget _buildQuickSummaryCard(
      {required Color accent, required String title}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$title module is ready for deeper workflow implementation.',
            style: const TextStyle(color: Color(0xFF334155), fontSize: 13),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Tip: Keep these cards while your backend APIs are in progress, then replace them with live widgets.',
              style: TextStyle(
                color: Color(0xFF334155),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubAdminNavItem {
  final String label;
  final IconData icon;

  const _SubAdminNavItem(this.label, this.icon);
}

class _DashboardMetric {
  final String label;
  final String value;
  final String trend;
  final IconData icon;
  final Color accent;

  const _DashboardMetric({
    required this.label,
    required this.value,
    required this.trend,
    required this.icon,
    required this.accent,
  });
}

class _ActivityEntry {
  final String title;
  final String time;
  final IconData icon;
  final Color accent;

  const _ActivityEntry({
    required this.title,
    required this.time,
    required this.icon,
    required this.accent,
  });
}

class _TeamHealthRow {
  final String label;
  final double progress;
  final Color accent;
  final String note;

  const _TeamHealthRow(this.label, this.progress, this.accent, this.note);
}

class _ActivityTile extends StatelessWidget {
  final _ActivityEntry entry;

  const _ActivityTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: entry.accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(entry.icon, color: entry.accent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.time,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
