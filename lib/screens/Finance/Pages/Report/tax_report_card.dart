import 'package:flutter/material.dart';

class TaxReportCard extends StatelessWidget {
  const TaxReportCard({super.key});

  static const double _taxDue = 18400;
  static const double _taxPaid = 12000;
  static const double _taxOutstanding = 6400;

  static const List<_TaxLine> _taxLines = [
    _TaxLine('Corporate Tax', 9400, 'Due Apr 15', Colors.red),
    _TaxLine('Payroll Tax', 5100, 'Filed', Colors.green),
    _TaxLine('Sales Tax', 3900, 'Due Apr 05', Colors.orange),
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
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tax Report',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Current liabilities and filing status',
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
              _TaxMetricTile(
                label: 'Tax Due',
                amount: _taxDue,
                color: Colors.red,
              ),
              _TaxMetricTile(
                label: 'Tax Paid',
                amount: _taxPaid,
                color: Colors.green,
              ),
              _TaxMetricTile(
                label: 'Outstanding',
                amount: _taxOutstanding,
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._taxLines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TaxLineTile(line: line),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaxMetricTile extends StatelessWidget {
  const _TaxMetricTile({
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

class _TaxLineTile extends StatelessWidget {
  const _TaxLineTile({required this.line});

  final _TaxLine line;

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
                Text(line.status,
                    style: TextStyle(color: Colors.grey.shade600)),
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

class _TaxLine {
  const _TaxLine(this.label, this.amount, this.status, this.color);

  final String label;
  final double amount;
  final String status;
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
