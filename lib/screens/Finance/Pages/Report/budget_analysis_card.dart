import 'package:flutter/material.dart';

class BudgetAnalysisCard extends StatelessWidget {
  const BudgetAnalysisCard({super.key});

  static const double _allocatedBudget = 210000;
  static const double _actualSpend = 182400;
  static const double _remainingBudget = 27600;

  static const List<_BudgetLine> _budgetLines = [
    _BudgetLine('Marketing', 52000, 48600, Colors.orange),
    _BudgetLine('Operations', 68000, 57200, Colors.blue),
    _BudgetLine('Payroll', 54000, 54800, Colors.red),
    _BudgetLine('Software', 22000, 14800, Colors.teal),
    _BudgetLine('Travel', 14000, 7000, Colors.purple),
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
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.pie_chart,
                  color: Colors.teal.shade700,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Budget Analysis',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Planned versus actual spending by category',
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
              _BudgetMetricTile(
                label: 'Allocated Budget',
                amount: _allocatedBudget,
                color: Colors.blue,
              ),
              _BudgetMetricTile(
                label: 'Actual Spend',
                amount: _actualSpend,
                color: Colors.red,
              ),
              _BudgetMetricTile(
                label: 'Remaining Budget',
                amount: _remainingBudget,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._budgetLines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _BudgetLineTile(line: line),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetMetricTile extends StatelessWidget {
  const _BudgetMetricTile({
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
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
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

class _BudgetLineTile extends StatelessWidget {
  const _BudgetLineTile({required this.line});

  final _BudgetLine line;

  @override
  Widget build(BuildContext context) {
    final usage = line.actual / line.budget;
    final variance = line.budget - line.actual;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                line.label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                variance >= 0
                    ? '${_formatCurrency(variance)} left'
                    : '${_formatCurrency(variance.abs())} over',
                style: TextStyle(
                  color: variance >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: usage.clamp(0, 1.2),
              color: line.color,
              backgroundColor: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Budget: ${_formatCurrency(line.budget)}'),
              Text('Actual: ${_formatCurrency(line.actual)}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetLine {
  const _BudgetLine(this.label, this.budget, this.actual, this.color);

  final String label;
  final double budget;
  final double actual;
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
