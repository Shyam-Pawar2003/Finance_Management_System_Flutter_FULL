import 'package:flutter/material.dart';

class CashFlowCard extends StatelessWidget {
  const CashFlowCard({super.key});

  static const List<_CashFlowEntry> _cashFlowEntries = [
    _CashFlowEntry('Operating Activities', 86000, Colors.green),
    _CashFlowEntry('Investing Activities', -18500, Colors.red),
    _CashFlowEntry('Financing Activities', 12000, Colors.blue),
    _CashFlowEntry('Net Cash Movement', 79500, Colors.teal),
  ];

  static const List<_MonthlyFlow> _monthlyFlows = [
    _MonthlyFlow('Jan', 24000, 14800),
    _MonthlyFlow('Feb', 27800, 16600),
    _MonthlyFlow('Mar', 31200, 19400),
    _MonthlyFlow('Apr', 28400, 17100),
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
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.waterfall_chart,
                  color: Colors.amber.shade800,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cash Flow Report',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Inflows and outflows across the current quarter',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._cashFlowEntries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CashFlowSummaryTile(entry: entry),
            ),
          ),
          const SizedBox(height: 8),
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
                  'Monthly Cash Position',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                ..._monthlyFlows.map(
                  (flow) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MonthlyFlowRow(flow: flow),
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

class _CashFlowSummaryTile extends StatelessWidget {
  const _CashFlowSummaryTile({required this.entry});

  final _CashFlowEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: entry.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              entry.label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${entry.amount >= 0 ? '+' : '-'}${_formatCurrency(entry.amount.abs())}',
            style: TextStyle(
              color: entry.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyFlowRow extends StatelessWidget {
  const _MonthlyFlowRow({required this.flow});

  final _MonthlyFlow flow;

  @override
  Widget build(BuildContext context) {
    final total = flow.inflow + flow.outflow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(flow.month,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              'Net ${_formatCurrency(flow.inflow - flow.outflow)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: total == 0 ? 0 : flow.inflow / total,
            color: Colors.green,
            backgroundColor: Colors.red.shade200,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Inflow ${_formatCurrency(flow.inflow)}'),
            Text('Outflow ${_formatCurrency(flow.outflow)}'),
          ],
        ),
      ],
    );
  }
}

class _CashFlowEntry {
  const _CashFlowEntry(this.label, this.amount, this.color);

  final String label;
  final double amount;
  final Color color;
}

class _MonthlyFlow {
  const _MonthlyFlow(this.month, this.inflow, this.outflow);

  final String month;
  final double inflow;
  final double outflow;
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
