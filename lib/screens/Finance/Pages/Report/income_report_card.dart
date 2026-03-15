import 'package:flutter/material.dart';

class IncomeReportCard extends StatelessWidget {
  const IncomeReportCard({super.key});

  static const double _totalIncome = 184500;
  static const double _collectedIncome = 156400;
  static const double _outstandingIncome = 28100;

  static const List<_IncomeSource> _incomeSources = [
    _IncomeSource('Client Retainers', 68500, 0.37),
    _IncomeSource('Consulting Services', 47200, 0.26),
    _IncomeSource('Annual Contracts', 39500, 0.21),
    _IncomeSource('Support Packages', 29300, 0.16),
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
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Income Report',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Revenue channels and collection status',
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
              _IncomeMetricTile(
                label: 'Total Income',
                amount: _totalIncome,
                color: Colors.green,
              ),
              _IncomeMetricTile(
                label: 'Collected',
                amount: _collectedIncome,
                color: Colors.blue,
              ),
              _IncomeMetricTile(
                label: 'Outstanding',
                amount: _outstandingIncome,
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Revenue Sources',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                ..._incomeSources.map(
                  (source) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _IncomeSourceTile(source: source),
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

class _IncomeMetricTile extends StatelessWidget {
  const _IncomeMetricTile({
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

class _IncomeSourceTile extends StatelessWidget {
  const _IncomeSourceTile({required this.source});

  final _IncomeSource source;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              source.label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              _formatCurrency(source.amount),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: source.share,
            color: Colors.green,
            backgroundColor: Colors.green.shade100,
          ),
        ),
      ],
    );
  }
}

class _IncomeSource {
  const _IncomeSource(this.label, this.amount, this.share);

  final String label;
  final double amount;
  final double share;
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
