import 'package:flutter/material.dart';

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

  final List<_FinanceMeeting> _meetings = const [
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
          chips,
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
              _actionButton(Icons.add_rounded, 'Create agenda'),
              const SizedBox(height: 8),
              _actionButton(Icons.groups_rounded, 'Invite attendees'),
              const SizedBox(height: 8),
              _actionButton(Icons.summarize_rounded, 'Export minutes'),
            ],
          ),
        ),
      ],
    );
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

  void _showCreateMeetingDialog() {
    final titleController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Schedule Meeting'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Meeting title',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(
                      titleController.text.trim().isEmpty
                          ? 'Meeting scheduling placeholder triggered.'
                          : 'Meeting "${titleController.text.trim()}" captured.',
                    ),
                  ),
                );
              },
              child: const Text('Create'),
            ),
          ],
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
