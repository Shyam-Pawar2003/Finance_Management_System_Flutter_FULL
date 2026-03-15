import 'package:flutter/material.dart';

import 'dashboard_panel.dart';

class SalaryPanel extends StatelessWidget {
  const SalaryPanel({
    super.key,
    required this.currency,
    required this.basic,
    required this.allowance,
    required this.deductions,
  });

  final String Function(double) currency;
  final double basic;
  final double allowance;
  final double deductions;

  @override
  Widget build(BuildContext context) {
    final netPay = basic + allowance - deductions;

    Widget row(String label, double value, Color color) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              currency(value),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return DashboardPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Salary Snapshot',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Net Pay',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currency(netPay),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          row('Basic Pay', basic, const Color(0xFF1A73E8)),
          row('Allowances', allowance, const Color(0xFF0F9D58)),
          row('Deductions', -deductions, const Color(0xFFDC2626)),
        ],
      ),
    );
  }
}
