import 'package:flutter/material.dart';

class DashboardFinancePage extends StatelessWidget {
  const DashboardFinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Finance Dashboard',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildCard(
                  'Total Revenue',
                  '\$254,800',
                  Colors.green,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCard(
                  'Total Expenses',
                  '\$89,200',
                  Colors.red,
                  Icons.trending_down,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCard(
                  'Net Profit',
                  '\$165,600',
                  Colors.blue,
                  Icons.account_balance_wallet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildTransactionRow(
                    'INV-001', 'Invoice Payment', '\$5,200', Colors.green),
                _buildTransactionRow(
                    'EXP-045', 'Office Supplies', '-\$450', Colors.red),
                _buildTransactionRow(
                    'INV-002', 'Service Income', '\$3,800', Colors.green),
                _buildTransactionRow(
                    'EXP-046', 'Internet Bill', '-\$120', Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(
      String id, String desc, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(id, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(desc,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
          Text(amount,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
