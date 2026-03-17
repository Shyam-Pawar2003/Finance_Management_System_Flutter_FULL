import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MeetingFinancePage extends StatefulWidget {
  const MeetingFinancePage({super.key});

  @override
  State<MeetingFinancePage> createState() => _MeetingFinancePageState();
}

class _MeetingFinancePageState extends State<MeetingFinancePage> {
  String _selectedFilter = 'All';
  String _selectedType = 'All';
  String _searchQuery = '';

  late final TextEditingController _searchController;

  static const List<String> _filters = [
    'All',
    'Today',
    'Upcoming',
    'Completed'
  ];
  static const List<String> _types = [
    'All',
    'Internal',
    'External',
    'Approval',
    'Planning',
  ];

  final List<_FinanceMeeting> _meetings = [
    _FinanceMeeting(
      id: 'MTG-001',
      title: 'Budget Review Meeting',
      date: '2026-03-13',
      time: '10:30 AM',
      room: 'Conference A',
      owner: 'Finance Team',
      type: 'Internal',
      status: 'Upcoming',
      attendees: 8,
      agenda: 'Q2 spend alignment and variance discussion',
    ),
    _FinanceMeeting(
      id: 'MTG-002',
      title: 'Vendor Settlement Call',
      date: '2026-03-13',
      time: '03:00 PM',
      room: 'Online',
      owner: 'AP Desk',
      type: 'External',
      status: 'Upcoming',
      attendees: 4,
      agenda: 'Resolve open settlement and remittance terms',
    ),
    _FinanceMeeting(
      id: 'MTG-003',
      title: 'Payroll Approval Window',
      date: '2026-03-15',
      time: '11:00 AM',
      room: 'Ops Board',
      owner: 'Payroll Team',
      type: 'Approval',
      status: 'Upcoming',
      attendees: 6,
      agenda: 'Approve payroll exceptions and bank validation list',
    ),
    _FinanceMeeting(
      id: 'MTG-004',
      title: 'Tax Filing Checklist Review',
      date: '2026-03-18',
      time: '09:45 AM',
      room: 'Compliance Room',
      owner: 'Tax Cell',
      type: 'Approval',
      status: 'Upcoming',
      attendees: 5,
      agenda: 'Confirm filing package and evidence completeness',
    ),
    _FinanceMeeting(
      id: 'MTG-005',
      title: 'Quarterly Forecast Sync',
      date: '2026-03-22',
      time: '04:30 PM',
      room: 'Conference B',
      owner: 'Finance Leadership',
      type: 'Planning',
      status: 'Upcoming',
      attendees: 9,
      agenda: 'Review growth assumptions and liquidity runway',
    ),
    _FinanceMeeting(
      id: 'MTG-006',
      title: 'Client Billing Reconciliation',
      date: '2026-03-25',
      time: '12:00 PM',
      room: 'Online',
      owner: 'AR Team',
      type: 'External',
      status: 'Upcoming',
      attendees: 3,
      agenda: 'Reconcile disputed line items and due balances',
    ),
    _FinanceMeeting(
      id: 'MTG-007',
      title: 'Cash Position Standup',
      date: '2026-03-11',
      time: '05:00 PM',
      room: 'Finance Hub',
      owner: 'Treasury',
      type: 'Internal',
      status: 'Today',
      attendees: 5,
      agenda: 'Review cash position, inflows, and near-term obligations',
    ),
    _FinanceMeeting(
      id: 'MTG-008',
      title: 'Audit Prep Debrief',
      date: '2026-03-07',
      time: '02:00 PM',
      room: 'Archive Room',
      owner: 'Audit Desk',
      type: 'Internal',
      status: 'Completed',
      attendees: 7,
      agenda: 'Close document gaps before statutory review',
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

  List<_FinanceMeeting> get _filteredMeetings {
    final query = _searchQuery.trim().toLowerCase();
    return _meetings.where((meeting) {
      final matchesQuery = query.isEmpty ||
          meeting.id.toLowerCase().contains(query) ||
          meeting.title.toLowerCase().contains(query) ||
          meeting.owner.toLowerCase().contains(query) ||
          meeting.agenda.toLowerCase().contains(query);
      final matchesType =
          _selectedType == 'All' || meeting.type == _selectedType;
      final matchesFilter =
          _selectedFilter == 'All' || meeting.status == _selectedFilter;
      return matchesQuery && matchesType && matchesFilter;
    }).toList();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _statusForDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final onlyDate = DateTime(date.year, date.month, date.day);

    if (onlyDate.isAtSameMomentAs(today)) {
      return 'Today';
    }
    if (onlyDate.isBefore(today)) {
      return 'Completed';
    }
    return 'Upcoming';
  }

  String _formatMeetingDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatMeetingTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $suffix';
  }

  void _updateMeeting(
      String meetingId, _FinanceMeeting Function(_FinanceMeeting) updater) {
    final index = _meetings.indexWhere((meeting) => meeting.id == meetingId);
    if (index == -1) {
      return;
    }

    setState(() {
      _meetings[index] = updater(_meetings[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 760;
        final isNarrow = width < 1120;
        final meetings = _filteredMeetings;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isCompact),
              const SizedBox(height: 18),
              _buildHeroCard(meetings),
              const SizedBox(height: 16),
              _buildMetrics(width, meetings),
              const SizedBox(height: 16),
              _buildFilters(isCompact),
              const SizedBox(height: 16),
              if (isNarrow) ...[
                _buildMeetingsPanel(meetings, isCompact),
                const SizedBox(height: 14),
                _buildRightPanel(meetings),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildMeetingsPanel(meetings, false),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildRightPanel(meetings),
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
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Meetings',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 6),
        Text(
          'Manage finance meetings, approvals, and planning sessions.',
          style: TextStyle(color: Color(0xFF5F6368)),
        ),
      ],
    );

    final action = ElevatedButton.icon(
      onPressed: _showCreateMeetingDialog,
      icon: const Icon(Icons.video_call_rounded, size: 18),
      label: const Text('Schedule Meeting'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, const SizedBox(height: 12), action],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        const SizedBox(width: 12),
        action,
      ],
    );
  }

  Widget _buildHeroCard(List<_FinanceMeeting> meetings) {
    final upcoming = meetings.where((m) => m.status == 'Upcoming').length;
    final today = meetings.where((m) => m.status == 'Today').length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF123A68), Color(0xFF1A73E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 14,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Meeting Operations Board',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${meetings.length} sessions tracked',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 33,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _heroChip('Today', '$today'),
              _heroChip('Upcoming', '$upcoming'),
              _heroChip('Avg Attendees', '5.9'),
              InkWell(
                onTap: _showLogoDetails,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Finance Ops Logo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String label, String value) {
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
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics(double width, List<_FinanceMeeting> meetings) {
    final crossAxisCount = width >= 1280
        ? 4
        : width >= 860
            ? 2
            : 1;

    final cards = [
      _MeetingMetric(
        title: 'Today',
        value: '${meetings.where((m) => m.status == 'Today').length}',
        subtitle: 'Sessions happening today',
        color: const Color(0xFF1A73E8),
        icon: Icons.today_rounded,
      ),
      _MeetingMetric(
        title: 'Approvals',
        value: '${meetings.where((m) => m.type == 'Approval').length}',
        subtitle: 'Approval meetings in queue',
        color: const Color(0xFFF29900),
        icon: Icons.rule_rounded,
      ),
      _MeetingMetric(
        title: 'External',
        value: '${meetings.where((m) => m.type == 'External').length}',
        subtitle: 'Vendor or client sessions',
        color: const Color(0xFF0F9D58),
        icon: Icons.groups_rounded,
      ),
      _MeetingMetric(
        title: 'Completed',
        value: '${meetings.where((m) => m.status == 'Completed').length}',
        subtitle: 'Sessions already closed',
        color: const Color(0xFF64748B),
        icon: Icons.task_alt_rounded,
      ),
    ];

    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 130,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];
        return _panel(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
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
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      card.subtitle,
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

  Widget _buildFilters(bool isCompact) {
    final search = TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        hintText: 'Search meeting title, owner, agenda, or id',
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
      ),
    );

    final reset = TextButton.icon(
      onPressed: () {
        _searchController.clear();
        setState(() {
          _searchQuery = '';
          _selectedFilter = 'All';
          _selectedType = 'All';
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
          if (isCompact)
            search
          else
            Row(
              children: [
                Expanded(child: search),
                const SizedBox(width: 10),
                reset,
              ],
            ),
          if (isCompact) Align(alignment: Alignment.centerLeft, child: reset),
          const SizedBox(height: 10),
          const Text(
            'Status',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _filters
                .map(
                  (filter) => ChoiceChip(
                    label: Text(filter),
                    selected: _selectedFilter == filter,
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: const Color(0xFF1A73E8),
                    labelStyle: TextStyle(
                      color: _selectedFilter == filter
                          ? Colors.white
                          : const Color(0xFF334155),
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: _selectedFilter == filter
                          ? const Color(0xFF1A73E8)
                          : const Color(0xFFD5DEE9),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          const Text(
            'Type',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _types
                .map(
                  (type) => ChoiceChip(
                    label: Text(type),
                    selected: _selectedType == type,
                    onSelected: (_) {
                      setState(() {
                        _selectedType = type;
                      });
                    },
                    selectedColor: const Color(0xFF0F355B),
                    labelStyle: TextStyle(
                      color: _selectedType == type
                          ? Colors.white
                          : const Color(0xFF334155),
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: _selectedType == type
                          ? const Color(0xFF0F355B)
                          : const Color(0xFFD5DEE9),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingsPanel(List<_FinanceMeeting> meetings, bool isCompact) {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Meeting Queue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${meetings.length} meetings',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (meetings.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'No meetings match the selected filters.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ...meetings
                .map((meeting) => _buildMeetingRow(meeting, isCompact))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildMeetingRow(_FinanceMeeting meeting, bool isCompact) {
    final typeColor = _typeColor(meeting.type);
    final statusColor = _statusColor(meeting.status);

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          meeting.title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 2),
        Text(
          '${meeting.id} | ${meeting.owner}',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          '${meeting.date} | ${meeting.time} | ${meeting.room}',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          meeting.agenda,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      ],
    );

    final chips = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _chip(meeting.type, typeColor),
        _chip(meeting.status, statusColor),
        _chip('${meeting.attendees} attendees', const Color(0xFF123A68)),
      ],
    );

    if (isCompact) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A73E8).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.video_call_rounded,
                    color: Color(0xFF1A73E8),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: details),
              ],
            ),
            const SizedBox(height: 8),
            chips,
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showMeetingDetails(meeting),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Details'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _toggleMeetingCompletion(meeting),
                  icon: Icon(
                    meeting.status == 'Completed'
                        ? Icons.restart_alt_rounded
                        : Icons.task_alt_rounded,
                    size: 16,
                  ),
                  label: Text(
                    meeting.status == 'Completed' ? 'Reopen' : 'Mark Done',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.video_call_rounded,
              color: Color(0xFF1A73E8),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: details),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              chips,
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showMeetingDetails(meeting),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('Details'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => _toggleMeetingCompletion(meeting),
                    icon: Icon(
                      meeting.status == 'Completed'
                          ? Icons.restart_alt_rounded
                          : Icons.task_alt_rounded,
                      size: 16,
                    ),
                    label: Text(
                      meeting.status == 'Completed' ? 'Reopen' : 'Mark Done',
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

  Widget _buildRightPanel(List<_FinanceMeeting> meetings) {
    final groupedOwners = <String, int>{};
    for (final meeting in meetings) {
      groupedOwners.update(meeting.owner, (count) => count + 1,
          ifAbsent: () => 1);
    }
    final ownerEntries = groupedOwners.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        _panel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Owner Workload',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (ownerEntries.isEmpty)
                const Text(
                  'No owner activity found.',
                  style: TextStyle(color: Color(0xFF64748B)),
                )
              else
                ...ownerEntries.take(4).map(
                      (entry) => Container(
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
                                entry.key,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              '${entry.value}',
                              style: const TextStyle(
                                color: Color(0xFF1A73E8),
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
                Icons.add_rounded,
                'Create agenda',
                onPressed: _showCreateAgendaDialog,
              ),
              const SizedBox(height: 8),
              _actionButton(
                Icons.groups_rounded,
                'Invite attendees',
                onPressed: _showInviteAttendeesDialog,
              ),
              const SizedBox(height: 8),
              _actionButton(
                Icons.summarize_rounded,
                'Export minutes',
                onPressed: _exportMeetingMinutes,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, {VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
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

  Color _typeColor(String type) {
    switch (type) {
      case 'External':
        return const Color(0xFF0F9D58);
      case 'Approval':
        return const Color(0xFFF29900);
      case 'Planning':
        return const Color(0xFF1A73E8);
      default:
        return const Color(0xFF123A68);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Today':
        return const Color(0xFF1A73E8);
      case 'Upcoming':
        return const Color(0xFFF29900);
      case 'Completed':
        return const Color(0xFF0F9D58);
      default:
        return const Color(0xFF64748B);
    }
  }

  void _showLogoDetails() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Finance Ops Logo'),
          content: const Text(
            'Finance Meeting Hub branding is active. This module is connected to meeting scheduling, agenda management, and minutes export flows.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showMeetingDetails(_FinanceMeeting meeting) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(meeting.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${meeting.id}'),
              const SizedBox(height: 6),
              Text('Owner: ${meeting.owner}'),
              const SizedBox(height: 6),
              Text('Type: ${meeting.type}'),
              const SizedBox(height: 6),
              Text('Status: ${meeting.status}'),
              const SizedBox(height: 6),
              Text('Schedule: ${meeting.date} | ${meeting.time}'),
              const SizedBox(height: 6),
              Text('Room: ${meeting.room}'),
              const SizedBox(height: 6),
              Text('Attendees: ${meeting.attendees}'),
              const SizedBox(height: 10),
              Text('Agenda: ${meeting.agenda}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            FilledButton.tonal(
              onPressed: () {
                Navigator.of(context).pop();
                _toggleMeetingCompletion(meeting);
              },
              child: Text(
                meeting.status == 'Completed'
                    ? 'Reopen Meeting'
                    : 'Mark Completed',
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleMeetingCompletion(_FinanceMeeting meeting) {
    if (meeting.status == 'Completed') {
      final parsedDate = DateTime.tryParse(meeting.date);
      final fallbackStatus = parsedDate == null
          ? 'Upcoming'
          : (() {
              final status = _statusForDate(parsedDate);
              return status == 'Completed' ? 'Upcoming' : status;
            })();

      _updateMeeting(
        meeting.id,
        (item) => item.copyWith(status: fallbackStatus),
      );
      _showMessage('${meeting.id} reopened.');
      return;
    }

    _updateMeeting(
      meeting.id,
      (item) => item.copyWith(status: 'Completed'),
    );
    _showMessage('${meeting.id} marked as completed.');
  }

  Future<void> _showCreateAgendaDialog() async {
    if (_meetings.isEmpty) {
      _showMessage('No meetings available to update agenda.');
      return;
    }

    String selectedMeetingId = _meetings.first.id;
    final agendaController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create Agenda'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedMeetingId,
                    isExpanded: true,
                    items: _meetings
                        .map(
                          (meeting) => DropdownMenuItem(
                            value: meeting.id,
                            child: Text('${meeting.id} - ${meeting.title}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedMeetingId = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Meeting'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: agendaController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Agenda',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final agenda = agendaController.text.trim();
                    if (agenda.isEmpty) {
                      _showMessage('Please enter agenda details.');
                      return;
                    }

                    _updateMeeting(
                      selectedMeetingId,
                      (meeting) => meeting.copyWith(agenda: agenda),
                    );
                    Navigator.of(dialogContext).pop();
                    _showMessage('Agenda updated for $selectedMeetingId.');
                  },
                  child: const Text('Save Agenda'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showInviteAttendeesDialog() async {
    if (_meetings.isEmpty) {
      _showMessage('No meetings available for invitations.');
      return;
    }

    String selectedMeetingId = _meetings.first.id;
    final inviteController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Invite Attendees'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedMeetingId,
                    isExpanded: true,
                    items: _meetings
                        .map(
                          (meeting) => DropdownMenuItem(
                            value: meeting.id,
                            child: Text('${meeting.id} - ${meeting.title}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedMeetingId = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Meeting'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: inviteController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Emails (comma separated)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final raw = inviteController.text.trim();
                    final emails = raw
                        .split(RegExp(r'[,;\s]+'))
                        .map((item) => item.trim())
                        .where((item) => item.isNotEmpty && item.contains('@'))
                        .toSet()
                        .toList();

                    if (emails.isEmpty) {
                      _showMessage('Enter at least one valid email.');
                      return;
                    }

                    _updateMeeting(
                      selectedMeetingId,
                      (meeting) => meeting.copyWith(
                        attendees: meeting.attendees + emails.length,
                      ),
                    );
                    Navigator.of(dialogContext).pop();
                    _showMessage(
                      '${emails.length} attendee invite(s) sent for $selectedMeetingId.',
                    );
                  },
                  child: const Text('Send Invites'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _exportMeetingMinutes() async {
    final completed =
        _meetings.where((meeting) => meeting.status == 'Completed').toList();
    final source = completed.isEmpty ? _meetings.take(3).toList() : completed;

    if (source.isEmpty) {
      _showMessage('No meetings available to export minutes.');
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('Finance Meeting Minutes Export');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln();

    for (final meeting in source) {
      buffer.writeln('${meeting.id} - ${meeting.title}');
      buffer.writeln('Date: ${meeting.date} | Time: ${meeting.time}');
      buffer.writeln('Owner: ${meeting.owner} | Type: ${meeting.type}');
      buffer.writeln('Agenda: ${meeting.agenda}');
      buffer.writeln('Attendees: ${meeting.attendees}');
      buffer.writeln('Status: ${meeting.status}');
      buffer.writeln('---');
    }

    final exportText = buffer.toString();
    await Clipboard.setData(ClipboardData(text: exportText));

    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Minutes Exported'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: SelectableText(exportText),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );

    _showMessage('Meeting minutes copied to clipboard.');
  }

  void _showCreateMeetingDialog() {
    final titleController = TextEditingController();
    final ownerController = TextEditingController();
    final roomController = TextEditingController(text: 'Conference A');
    final agendaController = TextEditingController();

    String selectedType = 'Internal';
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Schedule Meeting'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Meeting title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: ownerController,
                      decoration: const InputDecoration(
                        labelText: 'Owner / Team',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: roomController,
                      decoration: const InputDecoration(
                        labelText: 'Room / Link',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                      ),
                      items: _types
                          .where((type) => type != 'All')
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: dialogContext,
                                initialDate: selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2035),
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_month_rounded,
                                size: 16),
                            label: Text(_formatMeetingDate(selectedDate)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: dialogContext,
                                initialTime: selectedTime,
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  selectedTime = picked;
                                });
                              }
                            },
                            icon:
                                const Icon(Icons.access_time_rounded, size: 16),
                            label: Text(_formatMeetingTime(selectedTime)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: agendaController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Agenda',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final owner = ownerController.text.trim();
                    final room = roomController.text.trim();
                    final agenda = agendaController.text.trim();

                    if (title.isEmpty ||
                        owner.isEmpty ||
                        room.isEmpty ||
                        agenda.isEmpty) {
                      _showMessage('Please fill all meeting details.');
                      return;
                    }

                    final nextId =
                        'MTG-${(_meetings.length + 1).toString().padLeft(3, '0')}';
                    final status = _statusForDate(selectedDate);

                    setState(() {
                      _meetings.insert(
                        0,
                        _FinanceMeeting(
                          id: nextId,
                          title: title,
                          date: _formatMeetingDate(selectedDate),
                          time: _formatMeetingTime(selectedTime),
                          room: room,
                          owner: owner,
                          type: selectedType,
                          status: status,
                          attendees: 1,
                          agenda: agenda,
                        ),
                      );
                    });

                    Navigator.of(dialogContext).pop();
                    _showMessage('Meeting "$title" scheduled as $nextId.');
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
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

class _FinanceMeeting {
  const _FinanceMeeting({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.room,
    required this.owner,
    required this.type,
    required this.status,
    required this.attendees,
    required this.agenda,
  });

  final String id;
  final String title;
  final String date;
  final String time;
  final String room;
  final String owner;
  final String type;
  final String status;
  final int attendees;
  final String agenda;

  _FinanceMeeting copyWith({
    String? title,
    String? date,
    String? time,
    String? room,
    String? owner,
    String? type,
    String? status,
    int? attendees,
    String? agenda,
  }) {
    return _FinanceMeeting(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      room: room ?? this.room,
      owner: owner ?? this.owner,
      type: type ?? this.type,
      status: status ?? this.status,
      attendees: attendees ?? this.attendees,
      agenda: agenda ?? this.agenda,
    );
  }
}

class _MeetingMetric {
  const _MeetingMetric({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;
}
