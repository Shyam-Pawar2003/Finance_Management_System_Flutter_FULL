import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.isDesktop,
    required this.ranges,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  final bool isDesktop;
  final List<String> ranges;
  final String selectedRange;
  final ValueChanged<String> onRangeChanged;

  @override
  Widget build(BuildContext context) {
    final greeting = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Welcome back, Shyam',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 6),
        Text(
          'Here is your personal performance and workload snapshot.',
          style: TextStyle(color: Color(0xFF5F6368)),
        ),
      ],
    );

    final desktopRight = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RangeFilter(
          ranges: ranges,
          selectedRange: selectedRange,
          onRangeChanged: onRangeChanged,
        ),
        const SizedBox(width: 10),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: 'Notifications',
        ),
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFF1A73E8),
          child: Text(
            'S',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );

    if (!isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu_rounded),
                ),
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: Text(
                  'User Dashboard',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF1A73E8),
                child: Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          greeting,
          const SizedBox(height: 10),
          _RangeFilter(
            ranges: ranges,
            selectedRange: selectedRange,
            onRangeChanged: onRangeChanged,
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: greeting),
        const SizedBox(width: 12),
        desktopRight,
      ],
    );
  }
}

class _RangeFilter extends StatelessWidget {
  const _RangeFilter({
    required this.ranges,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  final List<String> ranges;
  final String selectedRange;
  final ValueChanged<String> onRangeChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ranges
          .map(
            (range) => ChoiceChip(
              label: Text(range),
              selected: selectedRange == range,
              onSelected: (_) => onRangeChanged(range),
              selectedColor: const Color(0xFF1A73E8),
              labelStyle: TextStyle(
                color: selectedRange == range
                    ? Colors.white
                    : const Color(0xFF334155),
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: selectedRange == range
                    ? const Color(0xFF1A73E8)
                    : const Color(0xFFD5DEE9),
              ),
            ),
          )
          .toList(),
    );
  }
}
