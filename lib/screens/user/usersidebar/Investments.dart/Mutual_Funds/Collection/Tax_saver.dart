import 'package:flutter/material.dart';

import '../../Mutal_fund.dart';
import 'TaxSaver/Axis.dart';
import 'TaxSaver/Canara.dart';
import 'TaxSaver/Mirae.dart';
import 'TaxSaver/Parag.dart';
import 'TaxSaver/Quant.dart';

class TaxSaverPage extends StatefulWidget {
  const TaxSaverPage({super.key});

  @override
  State<TaxSaverPage> createState() => _TaxSaverPageState();
}

class _TaxSaverPageState extends State<TaxSaverPage> {
  static const Color _bgTop = Color(0xFF0A1A08);
  static const Color _bgBottom = Color(0xFF050C04);
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  static const List<String> _styles = [
    'All',
    'Large Cap',
    'Flexi Cap',
    'Mid Cap',
  ];

  static const List<double> _taxSlabs = [
    5,
    20,
    30,
  ];

  final List<_ElssFund> _funds = const [
    _ElssFund(
      name: 'Axis Long Term Equity ELSS',
      style: 'Large Cap',
      oneYearReturn: 17.4,
      threeYearReturn: 15.2,
      fiveYearReturn: 14.1,
      expenseRatio: 0.81,
      riskLabel: 'Moderate',
    ),
    _ElssFund(
      name: 'Mirae Asset Tax Saver',
      style: 'Large Cap',
      oneYearReturn: 19.1,
      threeYearReturn: 16.4,
      fiveYearReturn: 14.8,
      expenseRatio: 0.63,
      riskLabel: 'Moderate',
    ),
    _ElssFund(
      name: 'Parag Parikh ELSS Tax Saver',
      style: 'Flexi Cap',
      oneYearReturn: 16.6,
      threeYearReturn: 14.9,
      fiveYearReturn: 13.8,
      expenseRatio: 0.88,
      riskLabel: 'Moderate',
    ),
    _ElssFund(
      name: 'Canara Robeco Equity Tax Saver',
      style: 'Large Cap',
      oneYearReturn: 18.2,
      threeYearReturn: 15.6,
      fiveYearReturn: 14.2,
      expenseRatio: 0.74,
      riskLabel: 'Moderate',
    ),
    _ElssFund(
      name: 'Quant ELSS Tax Saver',
      style: 'Mid Cap',
      oneYearReturn: 24.7,
      threeYearReturn: 19.3,
      fiveYearReturn: 18.1,
      expenseRatio: 0.96,
      riskLabel: 'High',
    ),
  ];

  int _selectedStyle = 0;
  int _selectedTaxSlab = 1;
  double _plannedInvestment = 120000;

  List<_ElssFund> get _visibleFunds {
    final style = _styles[_selectedStyle];
    if (style == 'All') {
      return _funds;
    }
    return _funds.where((fund) => fund.style == style).toList();
  }

  double get _remaining80C {
    const limit = 150000.0;
    return (limit - _plannedInvestment).clamp(0.0, limit);
  }

  double get _estimatedTaxSaved {
    return _plannedInvestment * (_taxSlabs[_selectedTaxSlab] / 100);
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

  Future<void> _handleBack() async {
    final popped = await Navigator.maybePop(context);
    if (!popped && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MutualFundsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final funds = _visibleFunds;

    return Scaffold(
      backgroundColor: _bgBottom,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: _handleBack,
          icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
        ),
        title: const Text(
          'Tax Saver (ELSS)',
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
              _taxSummaryCard(),
              const SizedBox(height: 16),
              const Text(
                'Tax Slab',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(_taxSlabs.length, (index) {
                  final isSelected = _selectedTaxSlab == index;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < _taxSlabs.length - 1 ? 8 : 0,
                    ),
                    child: ChoiceChip(
                      label: Text('${_taxSlabs[index].toStringAsFixed(0)}%'),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedTaxSlab = index);
                      },
                      selectedColor: _lime,
                      backgroundColor: _cardDark,
                      side: BorderSide(color: _lime.withOpacity(0.20)),
                      labelStyle: TextStyle(
                        color: isSelected ? _cardDark : _textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              const Text(
                'Fund Style',
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
                  children: List.generate(_styles.length, (index) {
                    final isSelected = _selectedStyle == index;
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < _styles.length - 1 ? 8 : 0,
                      ),
                      child: ChoiceChip(
                        label: Text(_styles[index]),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedStyle = index);
                        },
                        selectedColor: _lime,
                        backgroundColor: _cardDark,
                        side: BorderSide(color: _lime.withOpacity(0.20)),
                        labelStyle: TextStyle(
                          color: isSelected ? _cardDark : _textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ELSS Funds (${funds.length})',
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

  Widget _taxSummaryCard() {
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
            'Section 80C Planner',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'ELSS has a 3-year lock-in and helps reduce taxable income under Section 80C.',
            style: TextStyle(
              color: _textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Planned ELSS Investment: ₹${_plannedInvestment.toStringAsFixed(0)}',
            style: const TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          Slider(
            value: _plannedInvestment,
            min: 0,
            max: 150000,
            divisions: 30,
            activeColor: _lime,
            inactiveColor: _cardDeep,
            label: _plannedInvestment.toStringAsFixed(0),
            onChanged: (value) {
              setState(() => _plannedInvestment = value);
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _miniMetric(
                  'Estimated Tax Saved',
                  '₹${_estimatedTaxSaved.toStringAsFixed(0)}',
                ),
              ),
              Expanded(
                child: _miniMetric(
                  'Remaining 80C',
                  '₹${_remaining80C.toStringAsFixed(0)}',
                ),
              ),
              Expanded(
                child: _miniMetric(
                  'Lock-in',
                  '3 Years',
                ),
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _lime,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _fundCard(_ElssFund fund) {
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
                  fund.riskLabel,
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
            'Style: ${fund.style}',
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
                child:
                    _metric('5Y', '${fund.fiveYearReturn.toStringAsFixed(1)}%'),
              ),
              Expanded(
                child: _metric(
                    'Expense', '${fund.expenseRatio.toStringAsFixed(2)}%'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                _openFundDetails(fund.name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _lime,
                foregroundColor: _cardDeep,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Add to Plan',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFundDetails(String fundName) {
    Widget page;
    final lowerName = fundName.toLowerCase();

    if (lowerName.contains('axis')) {
      page = const AxisTaxSaverPage();
    } else if (lowerName.contains('canara')) {
      page = const CanaraTaxSaverPage();
    } else if (lowerName.contains('mirae')) {
      page = const MiraeTaxSaverPage();
    } else if (lowerName.contains('parag')) {
      page = const ParagTaxSaverPage();
    } else {
      page = const QuantTaxSaverPage();
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
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

class _ElssFund {
  final String name;
  final String style;
  final double oneYearReturn;
  final double threeYearReturn;
  final double fiveYearReturn;
  final double expenseRatio;
  final String riskLabel;

  const _ElssFund({
    required this.name,
    required this.style,
    required this.oneYearReturn,
    required this.threeYearReturn,
    required this.fiveYearReturn,
    required this.expenseRatio,
    required this.riskLabel,
  });
}
