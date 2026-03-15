import 'package:flutter/material.dart';

import 'user/data/dashboard_seed_data.dart';
import 'user/models/dashboard_models.dart';
import 'user/quickActions/Apply Leave.dart';
import 'user/quickActions/Submit Report.dart';
import 'user/quickActions/View Payslip.dart';
import 'user/widgets/attendance_panel.dart';
import 'user/widgets/dashboard_header.dart';
import 'user/widgets/hero_overview_card.dart';
import 'user/widgets/metrics_section.dart';
import 'user/widgets/quick_actions_panel.dart';
import 'user/widgets/salary_panel.dart';
import 'user/widgets/schedule_panel.dart';
import 'user/widgets/sidebar_navigation.dart';
import 'user/widgets/task_panel.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedMenuIndex = 0;
  String _selectedRange = dashboardRanges[1];

  int get _completedTasks {
    return dashboardTasks.where((task) => task.status == 'Completed').length;
  }

  int get _pendingTasks {
    return dashboardTasks.where((task) => task.status == 'Pending').length;
  }

  double get _completionRate {
    if (dashboardTasks.isEmpty) {
      return 0;
    }
    return _completedTasks / dashboardTasks.length;
  }

  String _currency(double amount) {
    final isNegative = amount < 0;
    final value = amount.abs().round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      final reverseIndex = value.length - i;
      buffer.write(value[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return '${isNegative ? '-' : ''}\$${buffer.toString()}';
  }

  List<DashboardMetric> get _metrics {
    return [
      DashboardMetric(
        title: 'Assigned Tasks',
        value: '${dashboardTasks.length}',
        caption: 'Current task queue',
        color: const Color(0xFF1A73E8),
        icon: Icons.assignment_rounded,
      ),
      DashboardMetric(
        title: 'Completed',
        value: '$_completedTasks',
        caption: 'Closed this cycle',
        color: const Color(0xFF0F9D58),
        icon: Icons.task_alt_rounded,
      ),
      DashboardMetric(
        title: 'Pending',
        value: '$_pendingTasks',
        caption: 'Needs attention',
        color: const Color(0xFFF29900),
        icon: Icons.pending_actions_rounded,
      ),
      const DashboardMetric(
        title: 'Leave Balance',
        value: '8 Days',
        caption: 'Available this quarter',
        color: Color(0xFF0F355B),
        icon: Icons.event_available_rounded,
      ),
    ];
  }

  void _openQuickAction(BuildContext context, QuickActionData action) {
    Widget? destination;
    switch (action.label) {
      case 'Apply Leave':
        destination = const ApplyLeavePage();
        break;
      case 'Submit Report':
        destination = const SubmitReportPage();
        break;
      case 'View Payslip':
        destination = const ViewPayslipPage();
        break;
      default:
        destination = null;
    }

    if (destination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${action.label} will be available soon.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => destination!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1100;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7FB),
          drawer: isDesktop
              ? null
              : Drawer(
                  child: SafeArea(
                    child: SidebarNavigation(
                      items: dashboardNavItems,
                      selectedIndex: _selectedMenuIndex,
                      compact: true,
                      onSelect: (index) {
                        setState(() {
                          _selectedMenuIndex = index;
                        });
                      },
                    ),
                  ),
                ),
          body: SafeArea(
            child: Row(
              children: [
                if (isDesktop)
                  Container(
                    width: 248,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border:
                          Border(right: BorderSide(color: Color(0xFFE6ECF5))),
                    ),
                    child: SidebarNavigation(
                      items: dashboardNavItems,
                      selectedIndex: _selectedMenuIndex,
                      compact: false,
                      onSelect: (index) {
                        setState(() {
                          _selectedMenuIndex = index;
                        });
                      },
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 24 : 16,
                      16,
                      isDesktop ? 24 : 16,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DashboardHeader(
                          isDesktop: isDesktop,
                          ranges: dashboardRanges,
                          selectedRange: _selectedRange,
                          onRangeChanged: (range) {
                            setState(() {
                              _selectedRange = range;
                            });
                          },
                        ),
                        const SizedBox(height: 18),
                        HeroOverviewCard(
                          completionRate: _completionRate,
                          focusTasks: _pendingTasks,
                          hoursToday: '8.2h',
                        ),
                        const SizedBox(height: 16),
                        MetricsSection(metrics: _metrics, width: width),
                        const SizedBox(height: 16),
                        _buildMainPanels(width),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainPanels(double width) {
    final isNarrow = width < 1180;
    if (isNarrow) {
      return Column(
        children: [
          const TaskPanel(tasks: dashboardTasks),
          const SizedBox(height: 14),
          QuickActionsPanel(
            actions: dashboardQuickActions,
            onActionTap: (action) => _openQuickAction(context, action),
          ),
          const SizedBox(height: 14),
          const AttendancePanel(
            days: dashboardAttendance,
            checkIn: '09:01 AM',
            checkOut: '06:04 PM',
          ),
          const SizedBox(height: 14),
          SalaryPanel(
            currency: _currency,
            basic: 3500,
            allowance: 700,
            deductions: 400,
          ),
          const SizedBox(height: 14),
          const SchedulePanel(events: dashboardEvents),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              const TaskPanel(tasks: dashboardTasks),
              const SizedBox(height: 14),
              QuickActionsPanel(
                actions: dashboardQuickActions,
                onActionTap: (action) => _openQuickAction(context, action),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              const AttendancePanel(
                days: dashboardAttendance,
                checkIn: '09:01 AM',
                checkOut: '06:04 PM',
              ),
              const SizedBox(height: 14),
              SalaryPanel(
                currency: _currency,
                basic: 3500,
                allowance: 700,
                deductions: 400,
              ),
              const SizedBox(height: 14),
              const SchedulePanel(events: dashboardEvents),
            ],
          ),
        ),
      ],
    );
  }
}
