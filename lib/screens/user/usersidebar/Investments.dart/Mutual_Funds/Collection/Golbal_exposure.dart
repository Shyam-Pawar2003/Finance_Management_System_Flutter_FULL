import 'package:flutter/material.dart';

class GlobalExposurePage extends StatefulWidget {
  const GlobalExposurePage({super.key});

  @override
  State<GlobalExposurePage> createState() => _GlobalExposurePageState();
}

class _GlobalExposurePageState extends State<GlobalExposurePage> {
  static const Color _bgTop = Color(0xFF0A1A08);
  static const Color _bgBottom = Color(0xFF050C04);
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  static const List<String> _regions = [
    'All',
    'US',
    'Europe',
    'Japan',
    'Emerging',
  ];

  final List<_GlobalFund> _funds = const [
    _GlobalFund(
      name: 'Nasdaq 100 Feeder Fund',
      region: 'US',
      category: 'Index',
      expenseRatio: 0.65,
      oneYearReturn: 24.9,
      threeYearReturn: 18.2,
      riskScore: 7.2,
    ),
    _GlobalFund(
      name: 'S&P 500 Global Index Fund',
      region: 'US',
      category: 'Index',
      expenseRatio: 0.52,
      oneYearReturn: 20.4,
      threeYearReturn: 15.8,
      riskScore: 6.8,
    ),
    _GlobalFund(
      name: 'Developed Markets Feeder',
      region: 'Europe',
      category: 'Diversified',
      expenseRatio: 0.74,
      oneYearReturn: 16.9,
      threeYearReturn: 12.4,
      riskScore: 6.1,
    ),
    _GlobalFund(
      name: 'Japan Equity Opportunities',
      region: 'Japan',
      category: 'Active',
      expenseRatio: 0.93,
      oneYearReturn: 14.1,
      threeYearReturn: 10.7,
      riskScore: 6.0,
    ),
    _GlobalFund(
      name: 'Emerging World Equity Fund',
      region: 'Emerging',
      category: 'Active',
      expenseRatio: 1.08,
      oneYearReturn: 27.3,
      threeYearReturn: 16.1,
      riskScore: 8.0,
    ),
  ];

  int _selectedRegion = 0;

  List<_GlobalFund> get _visibleFunds {
    final region = _regions[_selectedRegion];
    if (region == 'All') {
      return _funds;
    }
    return _funds.where((fund) => fund.region == region).toList();
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
          'Global Exposure',
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
              _summaryCard(),
              const SizedBox(height: 16),
              const Text(
                'Choose Region',
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
                  children: List.generate(_regions.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < _regions.length - 1 ? 8 : 0,
                      ),
                      child: ChoiceChip(
                        label: Text(_regions[index]),
                        selected: _selectedRegion == index,
                        onSelected: (_) {
                          setState(() => _selectedRegion = index);
                        },
                        selectedColor: _lime,
                        backgroundColor: _cardDark,
                        side: BorderSide(color: _lime.withOpacity(0.20)),
                        labelStyle: TextStyle(
                          color:
                              _selectedRegion == index ? _cardDark : _textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Funds (${funds.length})',
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

  Widget _summaryCard() {
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
            'International Diversification',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Reduce local market concentration by spreading investments across geographies.',
            style: TextStyle(
              color: _textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          _allocationBar('US', 46),
          const SizedBox(height: 8),
          _allocationBar('Europe', 21),
          const SizedBox(height: 8),
          _allocationBar('Japan', 13),
          const SizedBox(height: 8),
          _allocationBar('Emerging', 20),
        ],
      ),
    );
  }

  Widget _allocationBar(String label, int percent) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(
              color: _textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 8,
              backgroundColor: _cardDeep,
              valueColor: const AlwaysStoppedAnimation<Color>(_lime),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$percent%',
          style: const TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _fundCard(_GlobalFund fund) {
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
                  fund.region,
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
                    'Expense', '${fund.expenseRatio.toStringAsFixed(2)}%'),
              ),
              Expanded(
                child: _metric('Risk', _riskLabel(fund.riskScore)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
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

  String _riskLabel(double score) {
    if (score >= 7.5) {
      return 'High';
    }
    if (score >= 6.0) {
      return 'Moderate';
    }
    return 'Low';
  }
}

class _GlobalFund {
  final String name;
  final String region;
  final String category;
  final double expenseRatio;
  final double oneYearReturn;
  final double threeYearReturn;
  final double riskScore;

  const _GlobalFund({
    required this.name,
    required this.region,
    required this.category,
    required this.expenseRatio,
    required this.oneYearReturn,
    required this.threeYearReturn,
    required this.riskScore,
  });
}
