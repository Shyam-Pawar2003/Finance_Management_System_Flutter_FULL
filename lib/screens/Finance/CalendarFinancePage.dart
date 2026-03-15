import 'package:flutter/material.dart';

class CalendarFinancePage extends StatefulWidget {
  const CalendarFinancePage({super.key});

  @override
  State<CalendarFinancePage> createState() => _CalendarFinancePageState();
}

class _CalendarFinancePageState extends State<CalendarFinancePage> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;
  String _view = 'Month';

  final List<_MeetingEvent> _events = const [
    _MeetingEvent(
      title: 'Budget Review Meeting',
      date: '2026-03-13',
      time: '10:30 AM',
      room: 'Conference A',
      owner: 'Finance Team',
      type: 'Internal',
    ),
    _MeetingEvent(
      title: 'Vendor Settlement Call',
      date: '2026-03-13',
      time: '03:00 PM',
      room: 'Online',
      owner: 'AP Desk',
      type: 'External',
    ),
    _MeetingEvent(
      title: 'Payroll Approval Window',
      date: '2026-03-15',
      time: '11:00 AM',
      room: 'Ops Board',
      owner: 'Payroll Team',
      type: 'Approval',
    ),
    _MeetingEvent(
      title: 'Tax Filing Checklist',
      date: '2026-03-18',
      time: '09:45 AM',
      room: 'Compliance Room',
      owner: 'Tax Cell',
      type: 'Compliance',
    ),
    _MeetingEvent(
      title: 'Quarterly Forecast Sync',
      date: '2026-03-22',
      time: '04:30 PM',
      room: 'Conference B',
      owner: 'Finance Leadership',
      type: 'Planning',
    ),
    _MeetingEvent(
      title: 'Client Billing Reconciliation',
      date: '2026-03-25',
      time: '12:00 PM',
      room: 'Online',
      owner: 'AR Team',
      type: 'External',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  List<_MeetingEvent> get _selectedDayEvents {
    return _events
        .where((event) => event.date == _dateKey(_selectedDay))
        .toList();
  }

  List<_MeetingEvent> get _upcomingEvents {
    final now = DateTime.now();
    final upcoming = _events.where((event) {
      final date = _parseDate(event.date);
      return date.isAfter(DateTime(now.year, now.month, now.day - 1));
    }).toList();
    upcoming.sort((a, b) => a.date.compareTo(b.date));
    return upcoming;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 760;
        final isNarrow = width < 1100;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isCompact),
              const SizedBox(height: 18),
              _buildHeroCard(),
              const SizedBox(height: 16),
              _buildMetrics(width),
              const SizedBox(height: 16),
              if (isNarrow) ...[
                _buildCalendarPanel(),
                const SizedBox(height: 14),
                _buildSchedulePanel(),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildCalendarPanel()),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: _buildSchedulePanel()),
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
          'Calendar',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 6),
        Text(
          'Track deadlines, planning windows, and scheduled finance events.',
          style: TextStyle(color: Color(0xFF5F6368)),
        ),
      ],
    );

    final controls = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ['Month', 'Week']
          .map(
            (view) => ChoiceChip(
              label: Text(view),
              selected: _view == view,
              onSelected: (_) {
                setState(() {
                  _view = view;
                });
              },
              selectedColor: const Color(0xFF1A73E8),
              labelStyle: TextStyle(
                color: _view == view ? Colors.white : const Color(0xFF334155),
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: _view == view
                    ? const Color(0xFF1A73E8)
                    : const Color(0xFFD5DEE9),
              ),
            ),
          )
          .toList(),
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, const SizedBox(height: 12), controls],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        const SizedBox(width: 12),
        controls,
      ],
    );
  }

  Widget _buildHeroCard() {
    final upcoming = _upcomingEvents.length;
    final selected = _selectedDayEvents.length;

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
                'Finance Planning Window',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _monthLabel(_focusedMonth),
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
              _heroChip('Upcoming', '$upcoming'),
              _heroChip('Selected Day', '$selected'),
              _heroChip('Type', _view),
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

  Widget _buildMetrics(double width) {
    final crossAxisCount = width >= 1280
        ? 4
        : width >= 860
            ? 2
            : 1;

    final cards = [
      _CalendarMetric(
        title: 'Upcoming Meetings',
        value: '${_upcomingEvents.length}',
        subtitle: 'Future scheduled sessions',
        color: const Color(0xFF1A73E8),
        icon: Icons.event_available_rounded,
      ),
      _CalendarMetric(
        title: 'Compliance Events',
        value: '${_events.where((e) => e.type == 'Compliance').length}',
        subtitle: 'Regulatory checkpoints',
        color: const Color(0xFFDB4437),
        icon: Icons.gavel_rounded,
      ),
      _CalendarMetric(
        title: 'Approvals',
        value: '${_events.where((e) => e.type == 'Approval').length}',
        subtitle: 'Approval windows',
        color: const Color(0xFFF29900),
        icon: Icons.rule_rounded,
      ),
      _CalendarMetric(
        title: 'External Calls',
        value: '${_events.where((e) => e.type == 'External').length}',
        subtitle: 'Client/vendor meetings',
        color: const Color(0xFF0F9D58),
        icon: Icons.groups_rounded,
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

  Widget _buildCalendarPanel() {
    final days = _buildMonthGrid(_focusedMonth);

    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedMonth =
                        DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                  });
                },
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _monthLabel(_focusedMonth),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedMonth =
                        DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                  });
                },
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              _WeekDay('Mon'),
              _WeekDay('Tue'),
              _WeekDay('Wed'),
              _WeekDay('Thu'),
              _WeekDay('Fri'),
              _WeekDay('Sat'),
              _WeekDay('Sun'),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(6, (week) {
            return Row(
              children: List.generate(7, (day) {
                final index = (week * 7) + day;
                final date = days[index];
                final inMonth = date.month == _focusedMonth.month;
                final selected = _isSameDate(date, _selectedDay);
                final hasEvent =
                    _events.any((event) => event.date == _dateKey(date));

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDay = date;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      height: 62,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF1A73E8).withOpacity(0.16)
                            : inMonth
                                ? const Color(0xFFF8FAFC)
                                : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF1A73E8)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: inMonth
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 3),
                          if (hasEvent)
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1A73E8),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSchedulePanel() {
    final selected = _selectedDayEvents;
    final upcoming = _upcomingEvents;

    return Column(
      children: [
        _panel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected Day: ${_dateKey(_selectedDay)}',
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (selected.isEmpty)
                const Text(
                  'No meetings planned for this day.',
                  style: TextStyle(color: Color(0xFF64748B)),
                )
              else
                ...selected.map((event) => _eventTile(event)),
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
                'Upcoming Schedule',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ...upcoming.take(4).map((event) => _eventTile(event)),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _showAddMeetingDialog,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Meeting'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD5DEE9)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _eventTile(_MeetingEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8).withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.event_note_rounded,
              color: Color(0xFF1A73E8),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${event.date} | ${event.time} | ${event.room}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${event.owner} | ${event.type}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<DateTime> _buildMonthGrid(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final firstWeekday = (first.weekday + 6) % 7;
    final start = first.subtract(Duration(days: firstWeekday));
    return List.generate(42, (index) => start.add(Duration(days: index)));
  }

  String _monthLabel(DateTime month) {
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
    return '${names[month.month - 1]} ${month.year}';
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  DateTime _parseDate(String value) {
    final parts = value.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  void _showAddMeetingDialog() {
    final titleController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Meeting'),
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
                          ? 'Meeting creation placeholder triggered.'
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

class _MeetingEvent {
  const _MeetingEvent({
    required this.title,
    required this.date,
    required this.time,
    required this.room,
    required this.owner,
    required this.type,
  });

  final String title;
  final String date;
  final String time;
  final String room;
  final String owner;
  final String type;
}

class _CalendarMetric {
  const _CalendarMetric({
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

class _WeekDay extends StatelessWidget {
  const _WeekDay(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
