import 'package:flutter/material.dart';

import '../../user_dashboard.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  static const Color _bgTop = Color(0xFF081706);
  static const Color _bgBottom = Color(0xFF040A03);
  static const Color _cardDark = Color(0xFF10240C);
  static const Color _cardDarker = Color(0xFF0A1A08);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  static const List<String> _monthNames = [
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

  static const List<String> _weekNames = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  static const List<_PaymentSeed> _seedItems = [
    _PaymentSeed(
      title: 'Internet Bill',
      day: 5,
      amount: 999,
      icon: Icons.wifi_rounded,
      color: Color(0xFF5B6FFF),
      autoPay: true,
      progress: 0.9,
    ),
    _PaymentSeed(
      title: 'Phone Bill',
      day: 12,
      amount: 60,
      icon: Icons.phone_android_rounded,
      color: Colors.orange,
      autoPay: true,
      progress: 0.7,
    ),
    _PaymentSeed(
      title: 'Electricity Bill',
      day: 15,
      amount: 450,
      icon: Icons.flash_on_rounded,
      color: Colors.amber,
      autoPay: false,
      progress: null,
    ),
    _PaymentSeed(
      title: 'Rent',
      day: 20,
      amount: 1600,
      icon: Icons.home_rounded,
      color: Colors.teal,
      autoPay: false,
      progress: null,
    ),
    _PaymentSeed(
      title: 'Gym Membership',
      day: 24,
      amount: 140,
      icon: Icons.fitness_center_rounded,
      color: Color(0xFFAA7BFF),
      autoPay: true,
      progress: 0.2,
    ),
    _PaymentSeed(
      title: 'Student Loan',
      day: 30,
      amount: 200,
      icon: Icons.school_rounded,
      color: Colors.purple,
      autoPay: false,
      progress: 0.45,
    ),
  ];

  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  Future<void> _handleBack() async {
    final popped = await Navigator.maybePop(context);
    if (!popped && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const UserDashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthEntries =
        _entriesForMonth(_focusedMonth.year, _focusedMonth.month);
    final selectedEntries = _entriesForDate(_selectedDate);
    final autoPayCount = monthEntries.where((item) => item.autoPay).length;
    final manualCount = monthEntries.length - autoPayCount;
    final monthTotal =
        monthEntries.fold<double>(0, (sum, item) => sum + item.amount);

    return Scaffold(
      backgroundColor: _bgBottom,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Calendar',
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          onPressed: _handleBack,
          icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
        ),
      ),
      body: Stack(
        children: [
          Positioned(top: -130, right: -80, child: _glow(290)),
          Positioned(bottom: -120, left: -70, child: _glow(220)),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_bgTop, _bgBottom],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCard(
                    monthTotal: monthTotal,
                    autoPayCount: autoPayCount,
                    manualCount: manualCount,
                  ),
                  const SizedBox(height: 18),
                  _buildTipCard(),
                  const SizedBox(height: 14),
                  _buildCalendarCard(monthEntries),
                  const SizedBox(height: 22),
                  _buildScheduleHeader(selectedEntries.length),
                  const SizedBox(height: 12),
                  _buildScheduleList(selectedEntries),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard({
    required double monthTotal,
    required int autoPayCount,
    required int manualCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _lime.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Planner • ${_monthLabel(_focusedMonth)}',
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Track all dues, auto-pay status, and monthly cash outflow.',
            style: TextStyle(
              color: _textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _statChip(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Month Total',
                value: _money(monthTotal),
              ),
              _statChip(
                icon: Icons.autorenew_rounded,
                label: 'Auto-pay',
                value: '$autoPayCount bills',
              ),
              _statChip(
                icon: Icons.edit_calendar_rounded,
                label: 'Manual',
                value: '$manualCount bills',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _lime.withOpacity(0.12)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: _lime, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tip: tap any date to see due bills for that day and stay ahead of payment deadlines.',
              style: TextStyle(
                color: _textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: _cardDarker,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _lime.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _lime),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(List<_CalendarEntry> monthEntries) {
    final entriesByDay = <int, List<_CalendarEntry>>{};
    for (final item in monthEntries) {
      entriesByDay.putIfAbsent(item.dueDate.day, () => []).add(item);
    }

    final firstOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startShift = firstOfMonth.weekday % 7;
    final gridStart = firstOfMonth.subtract(Duration(days: startShift));
    final gridDates = List.generate(42, (i) {
      return DateTime(gridStart.year, gridStart.month, gridStart.day + i);
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _lime.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _navButton(
                icon: Icons.chevron_left_rounded,
                onTap: () {
                  setState(() {
                    _focusedMonth =
                        DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                    _selectedDate =
                        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
                  });
                },
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _monthLabel(_focusedMonth),
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _jumpToToday,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _lime.withOpacity(0.09),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: _lime.withOpacity(0.4)),
                        ),
                        child: const Text(
                          'Today',
                          style: TextStyle(
                            color: _lime,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _navButton(
                icon: Icons.chevron_right_rounded,
                onTap: () {
                  setState(() {
                    _focusedMonth =
                        DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                    _selectedDate =
                        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weekNames
                .map(
                  (name) => SizedBox(
                    width: 40,
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: gridDates.length,
            itemBuilder: (context, index) {
              final date = gridDates[index];
              final isCurrentMonth = date.month == _focusedMonth.month;
              final isSelected = _isSameDate(_selectedDate, date);
              final isToday = _isSameDate(DateTime.now(), date);
              final items = isCurrentMonth
                  ? entriesByDay[date.day] ?? const []
                  : const <_CalendarEntry>[];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                    _focusedMonth = DateTime(date.year, date.month);
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFFC8F24A), Color(0xFFA9DC3B)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : null,
                    color: isSelected
                        ? null
                        : isCurrentMonth
                            ? _cardDarker.withOpacity(0.72)
                            : _cardDarker.withOpacity(0.28),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isToday
                          ? _lime
                          : items.isNotEmpty
                              ? _lime.withOpacity(0.45)
                              : Colors.transparent,
                      width: isToday ? 1.6 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _lime.withOpacity(0.22),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isSelected
                                ? _bgBottom
                                : isCurrentMonth
                                    ? _textPrimary
                                    : _textMuted.withOpacity(0.45),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (items.isNotEmpty)
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _bgBottom.withOpacity(0.85)
                                  : _lime.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? _bgBottom
                                    : _lime.withOpacity(0.45),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${items.length}',
                              style: const TextStyle(
                                color: _lime,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _navButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _lime.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _lime.withOpacity(0.35)),
        ),
        child: Icon(icon, color: _lime),
      ),
    );
  }

  Widget _buildScheduleHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _fullDateLabel(_selectedDate),
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _lime.withOpacity(0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _lime.withOpacity(0.4)),
          ),
          child: Text(
            '$count due',
            style: const TextStyle(
              color: _lime,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleList(List<_CalendarEntry> entries) {
    if (entries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _lime.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 42,
              color: _textMuted.withOpacity(0.55),
            ),
            const SizedBox(height: 10),
            Text(
              'No payments scheduled for this date',
              style: TextStyle(
                color: _textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildEntryTile(entry),
            ),
          )
          .toList(),
    );
  }

  Widget _buildEntryTile(_CalendarEntry item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _lime.withOpacity(0.09)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.autoPay ? 'Auto-pay enabled' : 'Manual payment',
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _money(item.amount),
                style: TextStyle(
                  color: item.color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.autoPay ? 'Auto' : 'Manual',
                  style: TextStyle(
                    color: item.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showMarkedSnack(item.title),
                style: TextButton.styleFrom(
                  foregroundColor: _lime,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Mark Paid',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (item.progress != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: item.progress,
                minHeight: 5,
                backgroundColor: _textMuted.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(item.color),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _jumpToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = now;
      _focusedMonth = DateTime(now.year, now.month);
    });
  }

  void _showMarkedSnack(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title marked as paid'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<_CalendarEntry> _entriesForMonth(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0).day;

    return _seedItems.map((seed) {
      final day = seed.day.clamp(1, lastDay).toInt();
      return _CalendarEntry(
        title: seed.title,
        amount: seed.amount,
        icon: seed.icon,
        color: seed.color,
        autoPay: seed.autoPay,
        progress: seed.progress,
        dueDate: DateTime(year, month, day),
      );
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  List<_CalendarEntry> _entriesForDate(DateTime date) {
    return _entriesForMonth(date.year, date.month)
        .where((item) => _isSameDate(item.dueDate, date))
        .toList();
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _monthLabel(DateTime date) {
    return '${_monthNames[date.month - 1]} ${date.year}';
  }

  String _fullDateLabel(DateTime date) {
    final week = _weekNames[date.weekday % 7];
    return '$week, ${_monthNames[date.month - 1]} ${date.day}';
  }

  String _money(double value) {
    final rounded = value.round().toString();
    final formatted = rounded.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return 'INR $formatted';
  }

  Widget _glow(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _lime.withOpacity(0.08),
      ),
    );
  }
}

class _PaymentSeed {
  const _PaymentSeed({
    required this.title,
    required this.day,
    required this.amount,
    required this.icon,
    required this.color,
    required this.autoPay,
    required this.progress,
  });

  final String title;
  final int day;
  final double amount;
  final IconData icon;
  final Color color;
  final bool autoPay;
  final double? progress;
}

class _CalendarEntry {
  const _CalendarEntry({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.autoPay,
    required this.progress,
    required this.dueDate,
  });

  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final bool autoPay;
  final double? progress;
  final DateTime dueDate;
}
