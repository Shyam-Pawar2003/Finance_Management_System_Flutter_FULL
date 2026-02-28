import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedMonth = DateTime.now();

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

  List<Widget> _buildWeekDays() {
    final labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return labels
        .map((e) => Expanded(
                child: Center(
              child: Text(e,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            )))
        .toList();
  }

  List<Widget> _buildDays() {
    final firstOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final weekdayOfFirst = firstOfMonth.weekday % 7; // Sunday=0
    final totalCells = weekdayOfFirst + daysInMonth;
    final rows = (totalCells / 7).ceil();

    List<Widget> dayRows = [];
    int dayCounter = 1 - weekdayOfFirst;

    for (int r = 0; r < rows; r++) {
      List<Widget> weekCells = [];
      for (int c = 0; c < 7; c++) {
        if (dayCounter < 1 || dayCounter > daysInMonth) {
          weekCells.add(const Expanded(child: SizedBox()));
        } else {
          final date =
              DateTime(_focusedMonth.year, _focusedMonth.month, dayCounter);
          bool isToday = DateUtils.isSameDay(date, DateTime.now());
          weekCells.add(Expanded(
              child: Container(
            margin: const EdgeInsets.all(4),
            decoration: isToday
                ? BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(6))
                : null,
            child: Center(
                child: Text(
              dayCounter.toString(),
              style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? Colors.blue : Colors.black87),
            )),
          )));
        }
        dayCounter++;
      }
      dayRows.add(Row(children: weekCells));
    }
    return dayRows;
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat.yMMMM().format(_focusedMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: _goToPreviousMonth,
                    icon: const Icon(Icons.chevron_left)),
                Text(monthLabel,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                    onPressed: _goToNextMonth,
                    icon: const Icon(Icons.chevron_right)),
              ],
            ),
            const SizedBox(height: 8),
            Row(children: _buildWeekDays()),
            const Divider(),
            ..._buildDays(),
          ],
        ),
      ),
    );
  }
}
