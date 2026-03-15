import 'package:flutter/material.dart';

class BalanceSheetCard extends StatelessWidget {
  const BalanceSheetCard({super.key});

  static const double _totalAssets = 425000;
  static const double _totalLiabilities = 168000;
  static const double _totalEquity = 257000;

  static const List<_BalanceLine> _assetLines = [
    _BalanceLine('Cash & Cash Equivalents', 82000),
    _BalanceLine('Accounts Receivable', 124000),
    _BalanceLine('Inventory', 96500),
    _BalanceLine('Fixed Assets', 122500),
  ];

  static const List<_BalanceLine> _liabilityLines = [
    _BalanceLine('Accounts Payable', 58000),
    _BalanceLine('Short-Term Loans', 42000),
    _BalanceLine('Tax Payable', 18000),
    _BalanceLine('Long-Term Debt', 50000),
  ];

  static const List<_BalanceLine> _equityLines = [
    _BalanceLine('Owner Capital', 175000),
    _BalanceLine('Retained Earnings', 82000),
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
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance,
                  color: Colors.purple.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Balance Sheet',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Snapshot as of March 11, 2026',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Balanced',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 820;

              if (isNarrow) {
                return Column(
                  children: const [
                    _BalanceSummary(),
                    SizedBox(height: 16),
                    _BalanceSections(),
                  ],
                );
              }

              return const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _BalanceSummary(),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 7,
                    child: _BalanceSections(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BalanceSummary extends StatelessWidget {
  const _BalanceSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Financial Position',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          _MetricTile(
            label: 'Total Assets',
            value: BalanceSheetCard._totalAssets,
            color: Colors.blue,
            icon: Icons.trending_up,
          ),
          const SizedBox(height: 12),
          _MetricTile(
            label: 'Total Liabilities',
            value: BalanceSheetCard._totalLiabilities,
            color: Colors.red,
            icon: Icons.assignment_late_outlined,
          ),
          const SizedBox(height: 12),
          _MetricTile(
            label: 'Total Equity',
            value: BalanceSheetCard._totalEquity,
            color: Colors.green,
            icon: Icons.account_balance_wallet,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Assets = Liabilities + Equity',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatCurrency(BalanceSheetCard._totalLiabilities +
                    BalanceSheetCard._totalEquity),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceSections extends StatelessWidget {
  const _BalanceSections();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _BalanceGroup(
          title: 'Assets',
          total: BalanceSheetCard._totalAssets,
          accent: Colors.blue,
          lines: BalanceSheetCard._assetLines,
        ),
        SizedBox(height: 16),
        _BalanceGroup(
          title: 'Liabilities',
          total: BalanceSheetCard._totalLiabilities,
          accent: Colors.red,
          lines: BalanceSheetCard._liabilityLines,
        ),
        SizedBox(height: 16),
        _BalanceGroup(
          title: 'Equity',
          total: BalanceSheetCard._totalEquity,
          accent: Colors.green,
          lines: BalanceSheetCard._equityLines,
        ),
      ],
    );
  }
}

class _BalanceGroup extends StatelessWidget {
  const _BalanceGroup({
    required this.title,
    required this.total,
    required this.accent,
    required this.lines,
  });

  final String title;
  final double total;
  final MaterialColor accent;
  final List<_BalanceLine> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: accent.shade500,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                _formatCurrency(total),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: accent.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BalanceRow(
                label: line.label,
                amount: line.amount,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final double value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(value),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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

class _BalanceRow extends StatelessWidget {
  const _BalanceRow({required this.label, required this.amount});

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _formatCurrency(amount),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _BalanceLine {
  const _BalanceLine(this.label, this.amount);

  final String label;
  final double amount;
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
