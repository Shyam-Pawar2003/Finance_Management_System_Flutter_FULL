import 'package:flutter/material.dart';

class SubAdminFinalizeManagerReviewCyclePage extends StatefulWidget {
  const SubAdminFinalizeManagerReviewCyclePage({super.key});

  @override
  State<SubAdminFinalizeManagerReviewCyclePage> createState() =>
      _SubAdminFinalizeManagerReviewCyclePageState();
}

class _SubAdminFinalizeManagerReviewCyclePageState
    extends State<SubAdminFinalizeManagerReviewCyclePage> {
  // ── Filters ───────────────────────────────────────────────────────────────
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  String _selectedStatus = 'All';
  bool _onlyPending = false;
  late final TextEditingController _searchController;

  static const List<String> _statusOptions = [
    'All',
    'Draft',
    'In Review',
    'Awaiting Approval',
    'Finalized',
  ];

  // ── Review cycle data ─────────────────────────────────────────────────────
  final List<_ReviewCycle> _cycles = [
    _ReviewCycle(
      id: 'RC-2026-Q1',
      title: 'Q1 2026 Performance Review',
      manager: 'A. Kapoor',
      department: 'Finance',
      teamSize: 14,
      reviewsCompleted: 14,
      totalReviews: 14,
      status: 'Awaiting Approval',
      submittedAt: DateTime(2026, 3, 10),
      dueDate: DateTime(2026, 3, 31),
      avgRating: 4.3,
      overallRating: 'Exceeds',
      notes: 'All reviews submitted. Pending final sign-off.',
    ),
    _ReviewCycle(
      id: 'RC-2026-Q1-HR',
      title: 'Q1 2026 Performance Review',
      manager: 'R. Menon',
      department: 'HR',
      teamSize: 10,
      reviewsCompleted: 9,
      totalReviews: 10,
      status: 'In Review',
      submittedAt: DateTime(2026, 3, 8),
      dueDate: DateTime(2026, 3, 31),
      avgRating: 4.1,
      overallRating: 'Meets',
      notes: '1 review still in progress.',
    ),
    _ReviewCycle(
      id: 'RC-2026-Q1-OPS',
      title: 'Q1 2026 Performance Review',
      manager: 'P. Sinha',
      department: 'Operations',
      teamSize: 18,
      reviewsCompleted: 18,
      totalReviews: 18,
      status: 'Awaiting Approval',
      submittedAt: DateTime(2026, 3, 12),
      dueDate: DateTime(2026, 3, 31),
      avgRating: 3.9,
      overallRating: 'Meets',
      notes: 'Ready for finalization.',
    ),
    _ReviewCycle(
      id: 'RC-2026-Q1-LEG',
      title: 'Q1 2026 Performance Review',
      manager: 'S. Bhatt',
      department: 'Legal',
      teamSize: 7,
      reviewsCompleted: 7,
      totalReviews: 7,
      status: 'Finalized',
      submittedAt: DateTime(2026, 3, 5),
      dueDate: DateTime(2026, 3, 31),
      avgRating: 4.7,
      overallRating: 'Outstanding',
      notes: 'Finalized on 14 Mar 2026.',
    ),
    _ReviewCycle(
      id: 'RC-2026-Q1-SAL',
      title: 'Q1 2026 Performance Review',
      manager: 'M. Arora',
      department: 'Sales',
      teamSize: 12,
      reviewsCompleted: 6,
      totalReviews: 12,
      status: 'In Review',
      submittedAt: DateTime(2026, 3, 1),
      dueDate: DateTime(2026, 3, 31),
      avgRating: 4.0,
      overallRating: 'Meets',
      notes: '6 reviews pending manager submission.',
    ),
    _ReviewCycle(
      id: 'RC-2026-Q1-SUP',
      title: 'Q1 2026 Performance Review',
      manager: 'N. Verma',
      department: 'Support',
      teamSize: 16,
      reviewsCompleted: 2,
      totalReviews: 16,
      status: 'Draft',
      submittedAt: DateTime(2026, 3, 14),
      dueDate: DateTime(2026, 3, 31),
      avgRating: 3.5,
      overallRating: 'Needs Improvement',
      notes: 'Review cycle not yet fully started.',
    ),
  ];

  // ── Finalized tracking (mutable set of IDs) ───────────────────────────────
  final Set<String> _finalizedIds = {};

  // ── Computed ──────────────────────────────────────────────────────────────
  List<String> get _departments {
    final deps = _cycles.map((c) => c.department).toSet().toList()..sort();
    return ['All', ...deps];
  }

  List<_ReviewCycle> get _filtered {
    final q = _searchQuery.trim().toLowerCase();
    return _cycles.where((c) {
      final effectiveStatus =
          _finalizedIds.contains(c.id) ? 'Finalized' : c.status;
      final matchSearch = q.isEmpty ||
          c.title.toLowerCase().contains(q) ||
          c.manager.toLowerCase().contains(q) ||
          c.department.toLowerCase().contains(q) ||
          c.id.toLowerCase().contains(q);
      final matchDept =
          _selectedDepartment == 'All' || c.department == _selectedDepartment;
      final matchStatus =
          _selectedStatus == 'All' || effectiveStatus == _selectedStatus;
      final matchPending = !_onlyPending || (effectiveStatus != 'Finalized');
      return matchSearch && matchDept && matchStatus && matchPending;
    }).toList()
      ..sort((a, b) {
        final aFin = _finalizedIds.contains(a.id) || a.status == 'Finalized';
        final bFin = _finalizedIds.contains(b.id) || b.status == 'Finalized';
        if (aFin != bFin) return aFin ? 1 : -1;
        return a.dueDate.compareTo(b.dueDate);
      });
  }

  int get _awaitingCount => _cycles
      .where((c) =>
          !_finalizedIds.contains(c.id) && c.status == 'Awaiting Approval')
      .length;

  int get _finalizedCount => _cycles
      .where((c) => _finalizedIds.contains(c.id) || c.status == 'Finalized')
      .length;

  int get _inReviewCount => _cycles
      .where((c) => !_finalizedIds.contains(c.id) && c.status == 'In Review')
      .length;

  int get _draftCount => _cycles
      .where((c) => !_finalizedIds.contains(c.id) && c.status == 'Draft')
      .length;

  // ── Helpers ───────────────────────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status) {
      case 'Finalized':
        return const Color(0xFF0F9D58);
      case 'Awaiting Approval':
        return const Color(0xFF7C3AED);
      case 'In Review':
        return const Color(0xFF1A73E8);
      case 'Draft':
        return const Color(0xFF94A3B8);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Finalized':
        return Icons.check_circle_rounded;
      case 'Awaiting Approval':
        return Icons.pending_actions_rounded;
      case 'In Review':
        return Icons.rate_review_rounded;
      default:
        return Icons.edit_note_rounded;
    }
  }

  Color _ratingColor(String rating) {
    switch (rating) {
      case 'Outstanding':
        return const Color(0xFF7C3AED);
      case 'Exceeds':
        return const Color(0xFF0F9D58);
      case 'Meets':
        return const Color(0xFF1A73E8);
      case 'Needs Improvement':
        return const Color(0xFFF29900);
      default:
        return const Color(0xFFDC2626);
    }
  }

  String _formatDate(DateTime d) {
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
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  String _dueLabel(DateTime due) {
    final days = due.difference(DateTime.now()).inDays;
    if (days < 0) return 'Overdue by ${-days}d';
    if (days == 0) return 'Due Today';
    return 'Due in ${days}d';
  }

  Color _dueColor(DateTime due) {
    final days = due.difference(DateTime.now()).inDays;
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
          'Finalize Manager Review Cycle',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 760;
            final list = _filtered;
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
                  _buildCycleList(list, isCompact),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Hero banner ───────────────────────────────────────────────────────────
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
          const Icon(Icons.assignment_turned_in_outlined,
              color: Colors.white, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manager Review Cycle Finalization',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_cycles.length} managers · $_awaitingCount awaiting your approval',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _heroChip('Awaiting', '$_awaitingCount'),
              _heroChip('In Review', '$_inReviewCount'),
              _heroChip('Finalized', '$_finalizedCount'),
              _heroChip('Draft', '$_draftCount'),
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
          Text(label,
              style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13)),
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
      _MetricItem('Awaiting Approval', '$_awaitingCount', 'Ready to finalize',
          Icons.pending_actions_rounded, const Color(0xFF7C3AED)),
      _MetricItem('In Review', '$_inReviewCount', 'Manager submissions pending',
          Icons.rate_review_rounded, const Color(0xFF1A73E8)),
      _MetricItem('Finalized', '$_finalizedCount', 'Cycles completed',
          Icons.check_circle_outline_rounded, const Color(0xFF0F9D58)),
      _MetricItem('Draft', '$_draftCount', 'Not yet started',
          Icons.edit_note_rounded, const Color(0xFF94A3B8)),
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
                    Text(item.title,
                        style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(item.value,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800)),
                    Text(item.subtitle,
                        style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
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
        hintText: 'Search manager, department or cycle ID…',
        prefixIcon: const Icon(Icons.search_rounded),
      ),
    );

    final deptDrop = DropdownButtonFormField<String>(
      value: _selectedDepartment,
      decoration: _inputDecoration(labelText: 'Department'),
      items: _departments
          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
          .toList(),
      onChanged: (v) {
        if (v != null) setState(() => _selectedDepartment = v);
      },
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

    final pendingToggle = SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: const Text('Pending only',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      value: _onlyPending,
      onChanged: (v) => setState(() => _onlyPending = v),
      activeColor: const Color(0xFF36B39C),
    );

    final reset = TextButton.icon(
      onPressed: () {
        _searchController.clear();
        setState(() {
          _searchQuery = '';
          _selectedDepartment = 'All';
          _selectedStatus = 'All';
          _onlyPending = false;
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
            deptDrop,
            const SizedBox(height: 10),
            statusDrop,
            const SizedBox(height: 4),
            pendingToggle,
            reset,
          ] else
            Row(
              children: [
                Expanded(flex: 4, child: search),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: deptDrop),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: statusDrop),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: pendingToggle),
                const SizedBox(width: 8),
                reset,
              ],
            ),
        ],
      ),
    );
  }

  // ── Cycle list ─────────────────────────────────────────────────────────────
  Widget _buildCycleList(List<_ReviewCycle> list, bool isCompact) {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Review Cycles',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              Text('${list.length} cycle${list.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                      color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          if (list.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'No review cycles match your current filters.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            )
          else
            ...list.map((c) => _cycleCard(c)),
        ],
      ),
    );
  }

  Widget _cycleCard(_ReviewCycle c) {
    final isFinalized = _finalizedIds.contains(c.id) || c.status == 'Finalized';
    final effectiveStatus = isFinalized ? 'Finalized' : c.status;
    final progress =
        c.totalReviews == 0 ? 0.0 : c.reviewsCompleted / c.totalReviews;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFinalized ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFinalized
              ? const Color(0xFF0F9D58).withOpacity(0.3)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _statusColor(effectiveStatus).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _initials(c.manager),
                    style: TextStyle(
                      color: _statusColor(effectiveStatus),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                          child: Text(c.id,
                              style: const TextStyle(
                                  color: Color(0xFF36B39C),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color:
                                _statusColor(effectiveStatus).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_statusIcon(effectiveStatus),
                                  size: 11,
                                  color: _statusColor(effectiveStatus)),
                              const SizedBox(width: 4),
                              Text(effectiveStatus,
                                  style: TextStyle(
                                      color: _statusColor(effectiveStatus),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(c.manager,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    Text(
                      '${c.department} · ${c.title} · Team: ${c.teamSize}',
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Rating badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _ratingColor(c.overallRating).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: _ratingColor(c.overallRating).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      c.avgRating.toStringAsFixed(1),
                      style: TextStyle(
                        color: _ratingColor(c.overallRating),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      c.overallRating,
                      style: TextStyle(
                        color: _ratingColor(c.overallRating),
                        fontWeight: FontWeight.w600,
                        fontSize: 9,
                      ),
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
                    'Reviews: ${c.reviewsCompleted} / ${c.totalReviews}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B)),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _statusColor(effectiveStatus)),
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
                  valueColor: AlwaysStoppedAnimation<Color>(
                      _statusColor(effectiveStatus)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Meta chips
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _metaChip(
                  Icons.calendar_today_rounded,
                  'Submitted ${_formatDate(c.submittedAt)}',
                  const Color(0xFF64748B)),
              _metaChip(Icons.flag_rounded, _dueLabel(c.dueDate),
                  isFinalized ? const Color(0xFF94A3B8) : _dueColor(c.dueDate)),
              if (c.notes.isNotEmpty)
                _metaChip(Icons.info_outline_rounded, c.notes,
                    const Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 12),
          // Actions
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _showCycleDetails(c, effectiveStatus),
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
              if (!isFinalized && effectiveStatus == 'Awaiting Approval')
                FilledButton.icon(
                  onPressed: () => _showFinalizeConfirm(c),
                  icon: const Icon(Icons.check_rounded, size: 15),
                  label: const Text('Finalize'),
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
              else if (!isFinalized && effectiveStatus == 'In Review')
                FilledButton.icon(
                  onPressed: () => _showSendReminder(c),
                  icon: const Icon(Icons.send_rounded, size: 15),
                  label: const Text('Send Reminder'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                )
              else if (isFinalized)
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF0F9D58), size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'Finalized',
                      style: TextStyle(
                        color: Color(0xFF0F9D58),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
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
        Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────
  void _showFinalizeConfirm(_ReviewCycle c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Finalize Review Cycle',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          'Finalize the review cycle for ${c.manager} (${c.department})?\n\n'
          'This will lock all submitted reviews and notify the manager.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _finalizedIds.add(c.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('${c.manager}\'s review cycle has been finalized.'),
                  backgroundColor: const Color(0xFF0F9D58),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0F9D58)),
            child: const Text('Finalize'),
          ),
        ],
      ),
    );
  }

  void _showSendReminder(_ReviewCycle c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Send Reminder',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          'Send a reminder to ${c.manager} to complete '
          '${c.totalReviews - c.reviewsCompleted} pending review(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reminder sent to ${c.manager}.'),
                  backgroundColor: const Color(0xFF1A73E8),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8)),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showCycleDetails(_ReviewCycle c, String effectiveStatus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final progress =
            c.totalReviews == 0 ? 0.0 : c.reviewsCompleted / c.totalReviews;
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
                      child: Text(c.title,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(effectiveStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(effectiveStatus,
                          style: TextStyle(
                              color: _statusColor(effectiveStatus),
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _detailRow('Cycle ID', c.id),
                _detailRow('Manager', c.manager),
                _detailRow('Department', c.department),
                _detailRow('Team Size', '${c.teamSize}'),
                _detailRow('Reviews',
                    '${c.reviewsCompleted} / ${c.totalReviews} (${(progress * 100).toStringAsFixed(0)}%)'),
                _detailRow('Avg Rating', c.avgRating.toStringAsFixed(1)),
                _detailRow('Overall Rating', c.overallRating),
                _detailRow('Submitted', _formatDate(c.submittedAt)),
                _detailRow('Due Date', _formatDate(c.dueDate)),
                if (c.notes.isNotEmpty) _detailRow('Notes', c.notes),
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
            width: 130,
            child: Text(label,
                style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ── Utilities ─────────────────────────────────────────────────────────────
  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

// ── Data models ───────────────────────────────────────────────────────────────
class _ReviewCycle {
  final String id;
  final String title;
  final String manager;
  final String department;
  final int teamSize;
  final int reviewsCompleted;
  final int totalReviews;
  final String status;
  final DateTime submittedAt;
  final DateTime dueDate;
  final double avgRating;
  final String overallRating;
  final String notes;

  const _ReviewCycle({
    required this.id,
    required this.title,
    required this.manager,
    required this.department,
    required this.teamSize,
    required this.reviewsCompleted,
    required this.totalReviews,
    required this.status,
    required this.submittedAt,
    required this.dueDate,
    required this.avgRating,
    required this.overallRating,
    required this.notes,
  });
}

class _MetricItem {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _MetricItem(
      this.title, this.value, this.subtitle, this.icon, this.color);
}
