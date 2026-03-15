import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarEvent {
  CalendarEvent({
    required this.date,
    required this.title,
    required this.type,
    required this.time,
  });

  DateTime date;
  String title;
  String type;
  String time;
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  final List<CalendarEvent> _events = [
    CalendarEvent(
      date: DateTime(2026, 3, 11),
      title: 'Payroll Approval Meeting',
      type: 'Meeting',
      time: '10:30 AM',
    ),
    CalendarEvent(
      date: DateTime(2026, 3, 12),
      title: 'Recruitment Panel Interview',
      type: 'Recruitment',
      time: '02:00 PM',
    ),
    CalendarEvent(
      date: DateTime(2026, 3, 14),
      title: 'Team Leave Planning',
      type: 'Leave',
      time: '11:00 AM',
    ),
    CalendarEvent(
      date: DateTime(2026, 3, 18),
      title: 'Performance Review Deadline',
      type: 'Deadline',
      time: '05:00 PM',
    ),
    CalendarEvent(
      date: DateTime(2026, 3, 21),
      title: 'Annual HR Compliance Workshop',
      type: 'Training',
      time: '09:45 AM',
    ),
  ];

  static const List<String> _weekLabels = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _goToPreviousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  void _jumpToToday() {
    final now = DateTime.now();
    setState(() {
      _focusedMonth = DateTime(now.year, now.month);
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
  }

  List<DateTime> _gridDates() {
    final firstOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startOffset = firstOfMonth.weekday % 7;
    final gridStart = firstOfMonth.subtract(Duration(days: startOffset));
    return List.generate(42, (index) {
      return gridStart.add(Duration(days: index));
    });
  }

  List<CalendarEvent> _eventsForDate(DateTime date) {
    return _events
        .where((event) => DateUtils.isSameDay(event.date, date))
        .toList();
  }

  List<CalendarEvent> get _selectedDateEvents {
    final selected = _eventsForDate(_selectedDate)
      ..sort((a, b) => a.time.compareTo(b.time));
    return selected;
  }

  int get _eventsThisMonth {
    return _events
        .where((event) =>
            event.date.year == _focusedMonth.year &&
            event.date.month == _focusedMonth.month)
        .length;
  }

  int get _upcomingEvents {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _events.where((event) {
      final d = DateTime(event.date.year, event.date.month, event.date.day);
      return d.isAtSameMomentAs(today) || d.isAfter(today);
    }).length;
  }

  int get _daysWithEventsThisMonth {
    final uniqueDays = <String>{};
    for (final event in _events) {
      if (event.date.year == _focusedMonth.year &&
          event.date.month == _focusedMonth.month) {
        uniqueDays
            .add('${event.date.year}-${event.date.month}-${event.date.day}');
      }
    }
    return uniqueDays.length;
  }

  Color _eventTypeColor(String type) {
    switch (type) {
      case 'Meeting':
        return Colors.blue;
      case 'Recruitment':
        return Colors.teal;
      case 'Leave':
        return Colors.deepPurple;
      case 'Deadline':
        return Colors.red;
      case 'Training':
        return Colors.orange;
      default:
        return Colors.indigo;
    }
  }

  void _showCreateEventDialog() {
    final formKey = GlobalKey<FormState>();
    var title = '';
    var type = 'Meeting';
    var time = '10:00 AM';
    var date = _selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Calendar Event'),
          content: Form(
            key: formKey,
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Event title'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter event title';
                          }
                          return null;
                        },
                        onSaved: (value) => title = value!.trim(),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: type,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: const [
                          DropdownMenuItem(
                              value: 'Meeting', child: Text('Meeting')),
                          DropdownMenuItem(
                            value: 'Recruitment',
                            child: Text('Recruitment'),
                          ),
                          DropdownMenuItem(
                              value: 'Leave', child: Text('Leave')),
                          DropdownMenuItem(
                            value: 'Deadline',
                            child: Text('Deadline'),
                          ),
                          DropdownMenuItem(
                            value: 'Training',
                            child: Text('Training'),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            type = value ?? 'Meeting';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: time,
                        decoration: const InputDecoration(labelText: 'Time'),
                        onSaved: (value) => time = value?.trim() ?? '10:00 AM',
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate == null) return;
                          setDialogState(() {
                            date = pickedDate;
                          });
                        },
                        icon: const Icon(Icons.event),
                        label: Text(
                          DateFormat('dd MMM yyyy').format(date),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  formKey.currentState?.save();
                  setState(() {
                    _events.add(
                      CalendarEvent(
                        date: date,
                        title: title,
                        type: type,
                        time: time,
                      ),
                    );
                    _focusedMonth = DateTime(date.year, date.month);
                    _selectedDate = DateTime(date.year, date.month, date.day);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendarGrid() {
    final dates = _gridDates();
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: _weekLabels
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dates.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                final date = dates[index];
                final inFocusedMonth = date.month == _focusedMonth.month;
                final isToday = DateUtils.isSameDay(date, today);
                final isSelected = DateUtils.isSameDay(date, _selectedDate);
                final dateEvents = _eventsForDate(date);

                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() {
                      _selectedDate = DateTime(date.year, date.month, date.day);
                      _focusedMonth = DateTime(date.year, date.month);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFDBEAFE)
                          : isToday
                              ? const Color(0xFFE6F4EA)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue.shade300
                            : isToday
                                ? Colors.green.shade300
                                : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontWeight: isSelected || isToday
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: inFocusedMonth
                                ? Colors.black87
                                : Colors.grey.shade400,
                          ),
                        ),
                        const Spacer(),
                        if (dateEvents.isNotEmpty)
                          Wrap(
                            spacing: 3,
                            runSpacing: 3,
                            children: dateEvents
                                .take(3)
                                .map(
                                  (event) => Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: _eventTypeColor(event.type),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventPanel() {
    final events = _selectedDateEvents;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Events on ${DateFormat('dd MMM yyyy').format(_selectedDate)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (events.isEmpty)
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'No events scheduled for this day.',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: events.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final event = events[index];
                  final color = _eventTypeColor(event.type);

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.24)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${event.time} • ${event.type}',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat.yMMMM().format(_focusedMonth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calendar Center',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Manage meetings, deadlines, and HR schedules in one place.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _showCreateEventDialog,
              icon: const Icon(Icons.add),
              label: const Text('New Event'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth >= 1000
                ? (constraints.maxWidth - 36) / 4
                : constraints.maxWidth >= 700
                    ? (constraints.maxWidth - 12) / 2
                    : constraints.maxWidth;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SummaryCard(
                  width: cardWidth,
                  title: 'Month Events',
                  value: '$_eventsThisMonth',
                  icon: Icons.calendar_month,
                  color: Colors.indigo,
                ),
                _SummaryCard(
                  width: cardWidth,
                  title: 'Upcoming',
                  value: '$_upcomingEvents',
                  icon: Icons.upcoming,
                  color: Colors.teal,
                ),
                _SummaryCard(
                  width: cardWidth,
                  title: 'Busy Days',
                  value: '$_daysWithEventsThisMonth',
                  icon: Icons.event_available,
                  color: Colors.orange,
                ),
                _SummaryCard(
                  width: cardWidth,
                  title: 'Selected Day',
                  value: '${_selectedDateEvents.length} events',
                  icon: Icons.today,
                  color: Colors.blue,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _goToPreviousMonth,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous month',
              ),
              Expanded(
                child: Center(
                  child: Text(
                    monthLabel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _goToNextMonth,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next month',
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: _jumpToToday,
                child: const Text('Today'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 980;

              if (isWide) {
                return Row(
                  children: [
                    Expanded(flex: 7, child: _buildCalendarGrid()),
                    const SizedBox(width: 12),
                    Expanded(flex: 5, child: _buildEventPanel()),
                  ],
                );
              }

              return Column(
                children: [
                  Expanded(flex: 6, child: _buildCalendarGrid()),
                  const SizedBox(height: 12),
                  Expanded(flex: 4, child: _buildEventPanel()),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.width,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final double width;
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
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
