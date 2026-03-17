import 'package:flutter/material.dart';

class SubAdminOpenPerformanceCalibrationBoardPage extends StatefulWidget {
  const SubAdminOpenPerformanceCalibrationBoardPage({super.key});

  @override
  State<SubAdminOpenPerformanceCalibrationBoardPage> createState() =>
      _SubAdminOpenPerformanceCalibrationBoardPageState();
}

class _SubAdminOpenPerformanceCalibrationBoardPageState
    extends State<SubAdminOpenPerformanceCalibrationBoardPage> {
  // ── Filters ───────────────────────────────────────────────────────────────
  String _searchQuery = '';
  String _selectedStatus = 'All';
  String _selectedCycle = 'All';
  bool _onlyActive = false;
  late final TextEditingController _searchController;

  static const List<String> _statusOptions = [
    'All',
    'Active',
    'Pending',
    'Completed',
    'Closed',
  ];

  static const List<String> _cycleOptions = [
    'All',
    'Q1 2026',
    'Q2 2026',
    'Q3 2026',
    'Annual 2025',
  ];

  // ── Sample calibration sessions ───────────────────────────────────────────
  final List<_CalibrationSession> _sessions = [
    _CalibrationSession(
      id: 'CAL-101',
      title: 'Q1 2026 Performance Calibration',
      cycle: 'Q1 2026',
      scope: 'All Departments',
      method: 'Forced Distribution',
      status: 'Active',
      managersEnrolled: 6,
      submissionsReceived: 4,
      deadline: DateTime(2026, 4, 15),
      launchedAt: DateTime(2026, 3, 1),
      ratingChanges: 3,
      notifyEnabled: true,
      lockEnabled: false,
    ),
    _CalibrationSession(
      id: 'CAL-100',
      title: 'Annual 2025 Performance Review',
      cycle: 'Annual 2025',
      scope: 'All Departments',
      method: 'Rating Scale',
      status: 'Completed',
      managersEnrolled: 6,
      submissionsReceived: 6,
      deadline: DateTime(2026, 1, 31),
      launchedAt: DateTime(2026, 1, 5),
      ratingChanges: 7,
      notifyEnabled: true,
      lockEnabled: true,
    ),
    _CalibrationSession(
      id: 'CAL-099',
      title: 'Q4 2025 Calibration — Finance & Legal',
      cycle: 'Q3 2026',
      scope: 'Finance',
      method: 'Ranking',
      status: 'Closed',
      managersEnrolled: 2,
      submissionsReceived: 2,
      deadline: DateTime(2025, 11, 30),
      launchedAt: DateTime(2025, 11, 1),
      ratingChanges: 1,
      notifyEnabled: false,
      lockEnabled: true,
    ),
    _CalibrationSession(
      id: 'CAL-102',
      title: 'Q2 2026 Mid-Year Check',
      cycle: 'Q2 2026',
      scope: 'HR',
      method: 'MBO (Management by Objectives)',
      status: 'Pending',
      managersEnrolled: 3,
      submissionsReceived: 0,
      deadline: DateTime(2026, 7, 10),
      launchedAt: DateTime(2026, 6, 1),
      ratingChanges: 0,
      notifyEnabled: true,
      lockEnabled: false,
    ),
    _CalibrationSession(
      id: 'CAL-098',
      title: 'Q3 2025 Operations Review',
      cycle: 'Q3 2026',
      scope: 'Operations',
      method: 'Forced Distribution',
      status: 'Closed',
      managersEnrolled: 2,
      submissionsReceived: 2,
      deadline: DateTime(2025, 9, 30),
      launchedAt: DateTime(2025, 9, 1),
      ratingChanges: 2,
      notifyEnabled: true,
      lockEnabled: true,
    ),
  ];

  // ── Computed ──────────────────────────────────────────────────────────────
  List<_CalibrationSession> get _filtered {
    final q = _searchQuery.trim().toLowerCase();
    return _sessions.where((s) {
      final matchSearch = q.isEmpty ||
          s.title.toLowerCase().contains(q) ||
          s.id.toLowerCase().contains(q) ||
          s.scope.toLowerCase().contains(q) ||
          s.method.toLowerCase().contains(q);
      final matchStatus =
          _selectedStatus == 'All' || s.status == _selectedStatus;
      final matchCycle = _selectedCycle == 'All' || s.cycle == _selectedCycle;
      final matchActive = !_onlyActive || s.status == 'Active';
      return matchSearch && matchStatus && matchCycle && matchActive;
    }).toList()
      ..sort((a, b) => b.launchedAt.compareTo(a.launchedAt));
  }

  int get _activeCount => _sessions.where((s) => s.status == 'Active').length;
  int get _pendingCount => _sessions.where((s) => s.status == 'Pending').length;
  int get _completedCount =>
      _sessions.where((s) => s.status == 'Completed').length;
  int get _totalManagers =>
      _sessions.fold(0, (sum, s) => sum + s.managersEnrolled);

  // ── Helpers ───────────────────────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF0F9D58);
      case 'Pending':
        return const Color(0xFF1A73E8);
      case 'Completed':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Active':
        return Icons.play_circle_outline_rounded;
      case 'Pending':
        return Icons.schedule_rounded;
      case 'Completed':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.lock_outline_rounded;
    }
  }

  String _monthName(int month) {
    const months = [
      '',
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
    return months[month];
  }

  String _formatDate(DateTime d) => '${d.day} ${_monthName(d.month)} ${d.year}';

  String _deadlineLabel(DateTime deadline, String status) {
    if (status == 'Completed' || status == 'Closed') {
      return 'Closed ${_formatDate(deadline)}';
    }
    final days = deadline.difference(DateTime.now()).inDays;
    if (days < 0) return 'Overdue by ${-days}d';
    if (days == 0) return 'Due Today';
    return 'Due in ${days}d';
  }

  Color _deadlineColor(DateTime deadline, String status) {
    if (status == 'Completed' || status == 'Closed') {
      return const Color(0xFF94A3B8);
    }
    final days = deadline.difference(DateTime.now()).inDays;
    if (days < 0) return const Color(0xFFDC2626);
    if (days <= 7) return const Color(0xFFF29900);
    return const Color(0xFF0F9D58);
  }

  InputDecoration _inputDecoration({
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF36B39C), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _panel({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────
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

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
        title: const Text(
          'Performance Calibration Board',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 760;
            final sessions = _filtered;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroBanner(),
                  const SizedBox(height: 16),
                  _buildMetricCards(constraints.maxWidth),
                  const SizedBox(height: 16),
                  _buildFilterPanel(isCompact),
                  const SizedBox(height: 16),
                  _buildSessionsList(sessions, isCompact),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Hero banner ──────────────────────────────────────────────────────────
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(Icons.dashboard_customize_rounded,
              color: Colors.white, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Performance Calibration Board',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_sessions.length} total sessions · ${_activeCount} currently active',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _heroChip('Active', '$_activeCount'),
              _heroChip('Pending', '$_pendingCount'),
              _heroChip('Completed', '$_completedCount'),
              _heroChip('Managers', '$_totalManagers'),
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

  // ── Metric cards ──────────────────────────────────────────────────────────
  Widget _buildMetricCards(double width) {
    final cols = width >= 1280
        ? 4
        : width >= 860
            ? 2
            : 1;

    final items = [
      _MetricItem(
        title: 'Active Sessions',
        value: '$_activeCount',
        subtitle: 'Currently running',
        icon: Icons.play_circle_outline_rounded,
        color: const Color(0xFF0F9D58),
      ),
      _MetricItem(
        title: 'Pending Launch',
        value: '$_pendingCount',
        subtitle: 'Scheduled, not started',
        icon: Icons.schedule_rounded,
        color: const Color(0xFF1A73E8),
      ),
      _MetricItem(
        title: 'Completed',
        value: '$_completedCount',
        subtitle: 'Sessions finalised',
        icon: Icons.check_circle_outline_rounded,
        color: const Color(0xFF7C3AED),
      ),
      _MetricItem(
        title: 'Total Managers',
        value: '$_totalManagers',
        subtitle: 'Across all sessions',
        icon: Icons.group_rounded,
        color: const Color(0xFF36B39C),
      ),
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 112,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _panel(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      item.subtitle,
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

  // ── Filter panel ──────────────────────────────────────────────────────────
  Widget _buildFilterPanel(bool isCompact) {
    final search = TextField(
      controller: _searchController,
      onChanged: (v) => setState(() => _searchQuery = v),
      decoration: _inputDecoration(
        hintText: 'Search session, scope, or method…',
        prefixIcon: const Icon(Icons.search_rounded),
      ),
    );

    final statusDrop = DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: _inputDecoration(labelText: 'Status'),
      items: _statusOptions
          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
          .toList(),
      onChanged: (v) {
        if (v != null) setState(() => _selectedStatus = v);
      },
    );

    final cycleDrop = DropdownButtonFormField<String>(
      value: _selectedCycle,
      decoration: _inputDecoration(labelText: 'Cycle'),
      items: _cycleOptions
          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
          .toList(),
      onChanged: (v) {
        if (v != null) setState(() => _selectedCycle = v);
      },
    );

    final activeToggle = SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: const Text(
        'Active only',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      value: _onlyActive,
      onChanged: (v) => setState(() => _onlyActive = v),
      activeColor: const Color(0xFF36B39C),
    );

    final reset = TextButton.icon(
      onPressed: () {
        _searchController.clear();
        setState(() {
          _searchQuery = '';
          _selectedStatus = 'All';
          _selectedCycle = 'All';
          _onlyActive = false;
        });
      },
      icon: const Icon(Icons.restart_alt_rounded, size: 18),
      label: const Text('Reset'),
    );

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCompact) ...[
            search,
            const SizedBox(height: 10),
            statusDrop,
            const SizedBox(height: 10),
            cycleDrop,
            const SizedBox(height: 4),
            activeToggle,
            reset,
          ] else
            Row(
              children: [
                Expanded(flex: 4, child: search),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: statusDrop),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: cycleDrop),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: activeToggle),
                const SizedBox(width: 8),
                reset,
              ],
            ),
        ],
      ),
    );
  }

  // ── Sessions list ─────────────────────────────────────────────────────────
  Widget _buildSessionsList(
      List<_CalibrationSession> sessions, bool isCompact) {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Calibration Sessions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${sessions.length} session${sessions.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (sessions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'No calibration sessions match your current filters.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ...sessions.map((s) => _sessionCard(s, isCompact)),
        ],
      ),
    );
  }

  Widget _sessionCard(_CalibrationSession s, bool isCompact) {
    final progress = s.managersEnrolled == 0
        ? 0.0
        : s.submissionsReceived / s.managersEnrolled;
    final deadlineColor = _deadlineColor(s.deadline, s.status);
    final deadlineLabel = _deadlineLabel(s.deadline, s.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: ID + title + status badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF36B39C).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            s.id,
                            style: const TextStyle(
                              color: Color(0xFF36B39C),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statusColor(s.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_statusIcon(s.status),
                                  size: 11, color: _statusColor(s.status)),
                              const SizedBox(width: 4),
                              Text(
                                s.status,
                                style: TextStyle(
                                  color: _statusColor(s.status),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${s.cycle} · ${s.scope} · ${s.method}',
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Submissions: ${s.submissionsReceived} / ${s.managersEnrolled}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _statusColor(s.status),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(_statusColor(s.status)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Meta row
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _metaChip(
                Icons.calendar_today_rounded,
                'Launched ${_formatDate(s.launchedAt)}',
                const Color(0xFF64748B),
              ),
              _metaChip(
                Icons.flag_rounded,
                deadlineLabel,
                deadlineColor,
              ),
              _metaChip(
                Icons.group_rounded,
                '${s.managersEnrolled} managers',
                const Color(0xFF64748B),
              ),
              if (s.ratingChanges > 0)
                _metaChip(
                  Icons.swap_horiz_rounded,
                  '${s.ratingChanges} rating changes',
                  const Color(0xFFF29900),
                ),
              if (s.notifyEnabled)
                _metaChip(
                  Icons.email_rounded,
                  'Notified',
                  const Color(0xFF1A73E8),
                ),
              if (s.lockEnabled)
                _metaChip(
                  Icons.lock_rounded,
                  'Locked',
                  const Color(0xFF7C3AED),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Action buttons
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _showSessionDetail(s),
                icon: const Icon(Icons.visibility_rounded, size: 15),
                label: const Text('View Details'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1E293B),
                  side: const BorderSide(color: Color(0xFFD5DEE9)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              if (s.status == 'Active')
                FilledButton.icon(
                  onPressed: () => _showFinalizeDialog(s),
                  icon: const Icon(Icons.check_rounded, size: 15),
                  label: const Text('Finalise'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F9D58),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                )
              else if (s.status == 'Pending')
                FilledButton.icon(
                  onPressed: () => _showLaunchConfirm(s),
                  icon: const Icon(Icons.rocket_launch_rounded, size: 15),
                  label: const Text('Launch Now'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────
  void _showSessionDetail(_CalibrationSession s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final progress = s.managersEnrolled == 0
            ? 0.0
            : s.submissionsReceived / s.managersEnrolled;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.title,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(s.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        s.status,
                        style: TextStyle(
                          color: _statusColor(s.status),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _detailRow('Session ID', s.id),
                _detailRow('Cycle', s.cycle),
                _detailRow('Scope', s.scope),
                _detailRow('Method', s.method),
                _detailRow('Launched', _formatDate(s.launchedAt)),
                _detailRow('Deadline', _formatDate(s.deadline)),
                _detailRow('Managers', '${s.managersEnrolled}'),
                _detailRow(
                    'Submissions',
                    '${s.submissionsReceived} / ${s.managersEnrolled} '
                        '(${(progress * 100).toStringAsFixed(0)}%)'),
                _detailRow('Rating Changes',
                    s.ratingChanges > 0 ? '${s.ratingChanges}' : 'None'),
                _detailRow('Notify Managers', s.notifyEnabled ? 'Yes' : 'No'),
                _detailRow('Scores Locked', s.lockEnabled ? 'Yes' : 'No'),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _showFinalizeDialog(_CalibrationSession s) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Finalise Calibration',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: Text(
            'Mark "${s.title}" as Completed? '
            'This will lock all ratings and notify stakeholders.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('"${s.title}" has been finalised successfully.'),
                    backgroundColor: const Color(0xFF0F9D58),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F9D58)),
              child: const Text('Finalise'),
            ),
          ],
        );
      },
    );
  }

  void _showLaunchConfirm(_CalibrationSession s) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Launch Session',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: Text(
            'Launch "${s.title}" now? '
            'Managers will be notified and the calibration will begin immediately.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('"${s.title}" has been launched successfully.'),
                    backgroundColor: const Color(0xFF1A73E8),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8)),
              child: const Text('Launch'),
            ),
          ],
        );
      },
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────
class _CalibrationSession {
  final String id;
  final String title;
  final String cycle;
  final String scope;
  final String method;
  final String status;
  final int managersEnrolled;
  final int submissionsReceived;
  final DateTime deadline;
  final DateTime launchedAt;
  final int ratingChanges;
  final bool notifyEnabled;
  final bool lockEnabled;

  const _CalibrationSession({
    required this.id,
    required this.title,
    required this.cycle,
    required this.scope,
    required this.method,
    required this.status,
    required this.managersEnrolled,
    required this.submissionsReceived,
    required this.deadline,
    required this.launchedAt,
    required this.ratingChanges,
    required this.notifyEnabled,
    required this.lockEnabled,
  });
}

class _MetricItem {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _MetricItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
