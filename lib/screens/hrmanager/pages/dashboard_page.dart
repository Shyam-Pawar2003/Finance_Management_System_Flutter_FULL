import 'package:flutter/material.dart';

class HRDashboardPage extends StatelessWidget {
  const HRDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 960;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isCompact),
              const SizedBox(height: 16),
              _buildHeroCard(isCompact),
              const SizedBox(height: 16),
              _buildKpiGrid(width),
              const SizedBox(height: 16),
              if (isCompact) ...[
                _buildAttendancePanel(),
                const SizedBox(height: 14),
                _buildHiringPanel(),
                const SizedBox(height: 14),
                _buildAlertsPanel(),
                const SizedBox(height: 14),
                _buildActionsPanel(),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildAttendancePanel(),
                          const SizedBox(height: 14),
                          _buildHiringPanel(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildAlertsPanel(),
                          const SizedBox(height: 14),
                          _buildActionsPanel(),
                        ],
                      ),
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
    final today = DateTime.now();
    final dateLabel =
        '${_weekdayName(today.weekday)}, ${_monthName(today.month)} ${today.day}, ${today.year}';

    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'People Operations Dashboard',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Live view of workforce health, hiring velocity, and approvals.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.file_download_outlined, size: 18),
          label: const Text('Export Snapshot'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            foregroundColor: const Color(0xFF1E293B),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.group_add_rounded, size: 18),
          label: const Text('Add Employee'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A73E8),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading,
          const SizedBox(height: 10),
          Text(
            dateLabel,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          actions,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading,
              const SizedBox(height: 10),
              Text(
                dateLabel,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        actions,
      ],
    );
  }

  Widget _buildHeroCard(bool isCompact) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF123A68), Color(0xFF1A73E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withOpacity(0.24),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today at a glance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '245 Team Members Tracked',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _HeroPill(label: 'Present', value: '227'),
                    _HeroPill(label: 'On Leave', value: '18'),
                    _HeroPill(label: 'Interviews', value: '7'),
                    _HeroPill(label: 'Offers Pending', value: '4'),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today at a glance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '245 Team Members Tracked',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 34,
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    _HeroPill(label: 'Present', value: '227'),
                    _HeroPill(label: 'On Leave', value: '18'),
                    _HeroPill(label: 'Interviews', value: '7'),
                    _HeroPill(label: 'Offers Pending', value: '4'),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildKpiGrid(double width) {
    final cards = const [
      _KpiData(
        title: 'Total Employees',
        value: '245',
        delta: '+6 this month',
        icon: Icons.groups_rounded,
        color: Color(0xFF1A73E8),
      ),
      _KpiData(
        title: 'Attendance Rate',
        value: '92.6%',
        delta: '+1.3% vs last week',
        icon: Icons.event_available_rounded,
        color: Color(0xFF0F9D58),
      ),
      _KpiData(
        title: 'Open Positions',
        value: '14',
        delta: '3 urgent openings',
        icon: Icons.work_outline_rounded,
        color: Color(0xFFF29900),
      ),
      _KpiData(
        title: 'Attrition Risk',
        value: '5.4%',
        delta: '-0.8% improvement',
        icon: Icons.shield_moon_outlined,
        color: Color(0xFFDB4437),
      ),
    ];

    final crossAxisCount = width >= 1320
        ? 4
        : width >= 820
            ? 2
            : 1;

    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 126,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];
        return _panel(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: card.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(card.icon, color: card.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      card.title,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.value,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      card.delta,
                      style: TextStyle(
                        color: card.color,
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
    );
  }

  Widget _buildAttendancePanel() {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Momentum',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Daily attendance trend for the current work week.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          ..._attendanceTrend.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 42,
                    child: Text(
                      entry.day,
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: entry.rate,
                        minHeight: 9,
                        color: const Color(0xFF1A73E8),
                        backgroundColor: const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 70,
                    child: Text(
                      '${(entry.rate * 100).toStringAsFixed(0)}% (${entry.present})',
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
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

  Widget _buildHiringPanel() {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hiring Funnel',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Candidate movement across active recruitment stages.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          ..._funnelStages.map(
            (stage) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          stage.name,
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${stage.count}',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: stage.count / _maxFunnelCount,
                      minHeight: 9,
                      color: stage.color,
                      backgroundColor: const Color(0xFFE2E8F0),
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

  Widget _buildAlertsPanel() {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Priority Alerts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Operational items that need attention today.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          ..._alerts.map(
            (alert) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: alert.severity.color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: alert.severity.color.withOpacity(0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(alert.severity.icon, color: alert.severity.color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          alert.message,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
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

  Widget _buildActionsPanel() {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Calendar milestones for HR operations this week.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          ..._actions.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A73E8).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.time,
                      style: const TextStyle(
                        color: Color(0xFF1A73E8),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.description,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
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

  Widget _panel({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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

  String _weekdayName(int weekday) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[(weekday - 1).clamp(0, 6)];
  }

  String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[(month - 1).clamp(0, 11)];
  }

  double get _maxFunnelCount {
    final counts = _funnelStages.map((stage) => stage.count).toList();
    counts.sort((a, b) => b.compareTo(a));
    return counts.isEmpty ? 1 : counts.first.toDouble();
  }

  static const List<_AttendanceData> _attendanceTrend = [
    _AttendanceData(day: 'Mon', rate: 0.93, present: 228),
    _AttendanceData(day: 'Tue', rate: 0.91, present: 223),
    _AttendanceData(day: 'Wed', rate: 0.94, present: 230),
    _AttendanceData(day: 'Thu', rate: 0.92, present: 226),
    _AttendanceData(day: 'Fri', rate: 0.89, present: 219),
  ];

  static const List<_FunnelStage> _funnelStages = [
    _FunnelStage(name: 'Applied', count: 86, color: Color(0xFF1A73E8)),
    _FunnelStage(name: 'Screened', count: 52, color: Color(0xFF0F9D58)),
    _FunnelStage(name: 'Interview', count: 24, color: Color(0xFFF29900)),
    _FunnelStage(name: 'Offer', count: 9, color: Color(0xFF9333EA)),
  ];

  static const List<_AlertData> _alerts = [
    _AlertData(
      title: 'Leave approvals pending',
      message: '5 requests will auto-escalate in 18 hours.',
      severity: _AlertSeverity.high,
    ),
    _AlertData(
      title: 'Interview feedback overdue',
      message: '4 candidate scorecards are waiting for reviewer input.',
      severity: _AlertSeverity.medium,
    ),
    _AlertData(
      title: 'Policy document update',
      message: 'Remote work policy draft needs legal confirmation.',
      severity: _AlertSeverity.low,
    ),
  ];

  static const List<_ActionData> _actions = [
    _ActionData(
      time: '09:30',
      title: 'Hiring panel sync',
      description: 'Backend Engineer interview round 2.',
    ),
    _ActionData(
      time: '11:15',
      title: 'Attendance exception review',
      description: 'Finalize missing check-in resolutions.',
    ),
    _ActionData(
      time: '14:00',
      title: 'Compensation calibration',
      description: 'Review market correction proposal for FY26.',
    ),
    _ActionData(
      time: '16:30',
      title: 'Offer approval board',
      description: 'Approve final 3 shortlisted candidate offers.',
    ),
  ];
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
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
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiData {
  const _KpiData({
    required this.title,
    required this.value,
    required this.delta,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String delta;
  final IconData icon;
  final Color color;
}

class _AttendanceData {
  const _AttendanceData({
    required this.day,
    required this.rate,
    required this.present,
  });

  final String day;
  final double rate;
  final int present;
}

class _FunnelStage {
  const _FunnelStage({
    required this.name,
    required this.count,
    required this.color,
  });

  final String name;
  final int count;
  final Color color;
}

class _AlertData {
  const _AlertData({
    required this.title,
    required this.message,
    required this.severity,
  });

  final String title;
  final String message;
  final _AlertSeverity severity;
}

enum _AlertSeverity {
  high(
    color: Color(0xFFDB4437),
    icon: Icons.priority_high_rounded,
  ),
  medium(
    color: Color(0xFFF29900),
    icon: Icons.report_gmailerrorred_rounded,
  ),
  low(
    color: Color(0xFF1A73E8),
    icon: Icons.info_outline_rounded,
  );

  const _AlertSeverity({required this.color, required this.icon});

  final Color color;
  final IconData icon;
}

class _ActionData {
  const _ActionData({
    required this.time,
    required this.title,
    required this.description,
  });

  final String time;
  final String title;
  final String description;
}
