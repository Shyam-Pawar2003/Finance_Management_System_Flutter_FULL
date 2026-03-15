import 'package:flutter/material.dart';

class ExpenseReportCard extends StatelessWidget {
  const ExpenseReportCard({super.key});

  static const double _totalExpenses = 89200;
  static const double _fixedExpenses = 54100;
  static const double _variableExpenses = 35100;

  static const List<_ExpenseLine> _expenseLines = [
    _ExpenseLine('Payroll', 38200, '-2.4%', Colors.blue),
    _ExpenseLine('Rent & Utilities', 16900, '+1.2%', Colors.orange),
    _ExpenseLine('Software & Tools', 12800, '+4.8%', Colors.purple),
    _ExpenseLine('Travel', 7600, '-6.1%', Colors.green),
    _ExpenseLine('Office Supplies', 3700, '+0.9%', Colors.teal),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_down,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expense Report',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Operational costs and monthly variance',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _ExpenseMetricTile(
                label: 'Total Expenses',
                amount: _totalExpenses,
                color: Colors.red,
              ),
              _ExpenseMetricTile(
                label: 'Fixed Expenses',
                amount: _fixedExpenses,
                color: Colors.blue,
              ),
              _ExpenseMetricTile(
                label: 'Variable Expenses',
                amount: _variableExpenses,
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._expenseLines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ExpenseLineTile(line: line),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseMetricTile extends StatelessWidget {
  const _ExpenseMetricTile({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 6),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseLineTile extends StatelessWidget {
  const _ExpenseLineTile({required this.line});

  final _ExpenseLine line;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'MoM ${line.change}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            _formatCurrency(line.amount),
            style: TextStyle(
              color: line.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseLine {
  const _ExpenseLine(this.label, this.amount, this.change, this.color);

  final String label;
  final double amount;
  final String change;
  final Color color;
}

String _formatCurrency(double amount) {
  final roundedAmount = amount.toStringAsFixed(0);
  final buffer = StringBuffer();
  var digitCount = 0;

  for (var index = roundedAmount.length - 1; index >= 0; index--) {
    buffer.write(roundedAmount[index]);
    digitCount++;

    if (digitCount % 3 == 0 && index != 0) {
      buffer.write(',');
    }
  }

  return '\$${buffer.toString().split('').reversed.join()}';
}
