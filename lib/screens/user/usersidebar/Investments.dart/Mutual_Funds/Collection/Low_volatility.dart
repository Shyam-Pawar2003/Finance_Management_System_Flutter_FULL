import 'package:flutter/material.dart';

class LowVolatilityPage extends StatefulWidget {
  const LowVolatilityPage({super.key});

  @override
  State<LowVolatilityPage> createState() => _LowVolatilityPageState();
}

class _LowVolatilityPageState extends State<LowVolatilityPage> {
  static const Color _bgTop = Color(0xFF0A1A08);
  static const Color _bgBottom = Color(0xFF050C04);
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  static const List<String> _stabilityFilters = [
    'All',
    'Ultra Stable',
    'Stable',
    'Balanced',
  ];

  final List<_DefensiveFund> _funds = const [
    _DefensiveFund(
      name: 'Corporate Bond Low Duration',
      category: 'Debt',
      stability: 'Ultra Stable',
      oneYearReturn: 8.2,
      threeYearReturn: 7.5,
      stdDeviation: 2.1,
      drawdown: -2.8,
      expenseRatio: 0.42,
    ),
    _DefensiveFund(
      name: 'Balanced Advantage Shield',
      category: 'Hybrid',
      stability: 'Stable',
      oneYearReturn: 11.9,
      threeYearReturn: 10.8,
      stdDeviation: 5.3,
      drawdown: -6.9,
      expenseRatio: 0.78,
    ),
    _DefensiveFund(
      name: 'Large Cap Defensive Equity',
      category: 'Equity',
      stability: 'Balanced',
      oneYearReturn: 14.6,
      threeYearReturn: 12.2,
      stdDeviation: 8.2,
      drawdown: -9.1,
      expenseRatio: 0.93,
    ),
    _DefensiveFund(
      name: 'Conservative Hybrid Income',
      category: 'Hybrid',
      stability: 'Ultra Stable',
      oneYearReturn: 9.1,
      threeYearReturn: 8.4,
      stdDeviation: 3.7,
      drawdown: -4.2,
      expenseRatio: 0.61,
    ),
    _DefensiveFund(
      name: 'Short Term Treasury Plus',
      category: 'Debt',
      stability: 'Stable',
      oneYearReturn: 7.8,
      threeYearReturn: 7.1,
      stdDeviation: 2.9,
      drawdown: -3.4,
      expenseRatio: 0.35,
    ),
  ];

  int _selectedFilter = 0;

  List<_DefensiveFund> get _visibleFunds {
    final filter = _stabilityFilters[_selectedFilter];
    if (filter == 'All') {
      return _funds;
    }
    return _funds.where((fund) => fund.stability == filter).toList();
  }

  void _showMessage(String text) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final funds = _visibleFunds;

    return Scaffold(
      backgroundColor: _bgBottom,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Low Volatility',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_bgTop, _bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _overviewCard(),
              const SizedBox(height: 16),
              const Text(
                'Stability Focus',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_stabilityFilters.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < _stabilityFilters.length - 1 ? 8 : 0,
                      ),
                      child: ChoiceChip(
                        label: Text(_stabilityFilters[index]),
                        selected: _selectedFilter == index,
                        onSelected: (_) {
                          setState(() => _selectedFilter = index);
                        },
                        selectedColor: _lime,
                        backgroundColor: _cardDark,
                        side: BorderSide(color: _lime.withOpacity(0.20)),
                        labelStyle: TextStyle(
                          color:
                              _selectedFilter == index ? _cardDark : _textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Defensive Funds (${funds.length})',
                style: const TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              ...funds.map(_fundCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_cardDark, _cardDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _lime.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Protect During Volatile Phases',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'These funds prioritize smoother returns with lower drawdowns and better risk-adjusted performance.',
            style: TextStyle(
              color: _textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _miniMetric('Portfolio Beta', '0.62'),
              ),
              Expanded(
                child: _miniMetric('Max Drawdown', '-6.4%'),
              ),
              Expanded(
                child: _miniMetric('Sharpe', '1.34'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: _lime,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _fundCard(_DefensiveFund fund) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _lime.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  fund.name,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _cardDeep,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  fund.stability,
                  style: const TextStyle(
                    color: _lime,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Category: ${fund.category}',
            style: const TextStyle(
              color: _textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child:
                    _metric('1Y', '${fund.oneYearReturn.toStringAsFixed(1)}%'),
              ),
              Expanded(
                child: _metric(
                    '3Y', '${fund.threeYearReturn.toStringAsFixed(1)}%'),
              ),
              Expanded(
                child: _metric(
                    'Volatility', '${fund.stdDeviation.toStringAsFixed(1)}'),
              ),
              Expanded(
                child:
                    _metric('Drawdown', '${fund.drawdown.toStringAsFixed(1)}%'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Expense Ratio: ${fund.expenseRatio.toStringAsFixed(2)}%',
                  style: const TextStyle(
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _showMessage('Added ${fund.name} to watchlist.');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _lime,
                  foregroundColor: _cardDeep,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Track Fund',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _DefensiveFund {
  final String name;
  final String category;
  final String stability;
  final double oneYearReturn;
  final double threeYearReturn;
  final double stdDeviation;
  final double drawdown;
  final double expenseRatio;

  const _DefensiveFund({
    required this.name,
    required this.category,
    required this.stability,
    required this.oneYearReturn,
    required this.threeYearReturn,
    required this.stdDeviation,
    required this.drawdown,
    required this.expenseRatio,
  });
}
