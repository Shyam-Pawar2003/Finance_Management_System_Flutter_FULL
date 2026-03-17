import 'package:flutter/material.dart';

/// A 2×2 grid of payroll summary stat cards.
///
/// Pass live [employeesInCycle], [totalOvertime], [totalDeductions], and
/// [bonuses] to display real-time values. All monetary values are in dollars.
class PayrollStatsCards extends StatelessWidget {
  const PayrollStatsCards({
    super.key,
    this.employeesInCycle = 8,
    this.totalOvertime = 1290,
    this.totalDeductions = 5000,
    this.bonuses = 1990,
  });

  final int employeesInCycle;
  final double totalOvertime;
  final double totalDeductions;
  final double bonuses;

  String _fmt(double amount) {
    // Format as $X,XXX with comma separators
    final raw = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final reverseIndex = raw.length - i;
      buffer.write(raw[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) buffer.write(',');
    }
    return '\$${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(
        title: 'Employees in Cycle',
        value: employeesInCycle.toString(),
        subtitle: 'Current filtered set',
        icon: Icons.group_rounded,
        iconColor: const Color(0xFF2563EB),
        iconBg: const Color(0xFFDBEAFE),
      ),
      _StatCard(
        title: 'Total Overtime',
        value: _fmt(totalOvertime),
        subtitle: 'Extra-hours payout',
        icon: Icons.access_time_rounded,
        iconColor: const Color(0xFF16A34A),
        iconBg: const Color(0xFFDCFCE7),
      ),
      _StatCard(
        title: 'Total Deductions',
        value: _fmt(totalDeductions),
        subtitle: 'Tax, PF and adjustments',
        icon: Icons.remove_circle_outline_rounded,
        iconColor: const Color(0xFFDC2626),
        iconBg: const Color(0xFFFFE4E4),
      ),
      _StatCard(
        title: 'Bonuses',
        value: _fmt(bonuses),
        subtitle: 'Incentive allocation',
        icon: Icons.emoji_events_rounded,
        iconColor: const Color(0xFFD97706),
        iconBg: const Color(0xFFFEF3C7),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Two columns always; shrink gracefully on very narrow screens
        final crossAxisCount = constraints.maxWidth < 480 ? 1 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: constraints.maxWidth < 480 ? 4 : 2.6,
          children: cards,
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withOpacity(0.13),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
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
