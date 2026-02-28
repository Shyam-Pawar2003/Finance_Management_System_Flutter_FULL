import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reports',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          childAspectRatio: 1.2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildReportCard('Income Report', Icons.trending_up, Colors.green),
            _buildReportCard('Expense Report', Icons.trending_down, Colors.red),
            _buildReportCard('Tax Report', Icons.receipt_long, Colors.blue),
            _buildReportCard(
                'Balance Sheet', Icons.account_balance, Colors.purple),
            _buildReportCard('Cash Flow', Icons.waterfall_chart, Colors.amber),
            _buildReportCard('Budget Analysis', Icons.pie_chart, Colors.teal),
          ],
        ),
      ],
    );
  }

  Widget _buildReportCard(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('View'),
            ),
          ],
        ),
      ),
    );
  }
}
