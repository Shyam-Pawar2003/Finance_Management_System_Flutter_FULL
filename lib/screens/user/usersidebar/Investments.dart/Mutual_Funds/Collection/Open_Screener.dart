import 'package:flutter/material.dart';

class OpenScreenerPage extends StatefulWidget {
  const OpenScreenerPage({super.key});

  @override
  State<OpenScreenerPage> createState() => _OpenScreenerPageState();
}

class _OpenScreenerPageState extends State<OpenScreenerPage> {
  static const Color _bgTop = Color(0xFF0A1A08);
  static const Color _bgBottom = Color(0xFF050C04);
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  static const List<String> _categories = [
    'All',
    'Large Cap',
    'Flexi Cap',
    'Mid Cap',
    'Small Cap',
    'Index',
    'Hybrid',
    'Debt',
  ];

  static const List<String> _riskLevels = [
    'All',
    'Low',
    'Moderate',
    'High',
  ];

  final List<_ScreenFund> _funds = const [
    _ScreenFund(
      name: 'Nifty 50 Index Direct',
      category: 'Index',
      risk: 'Low',
      oneYearReturn: 17.6,
      threeYearReturn: 16.9,
      expenseRatio: 0.21,
      aumCr: 14320,
    ),
    _ScreenFund(
      name: 'Parag Parikh Flexi Cap',
      category: 'Flexi Cap',
      risk: 'Moderate',
      oneYearReturn: 19.1,
      threeYearReturn: 18.3,
      expenseRatio: 0.74,
      aumCr: 62310,
    ),
    _ScreenFund(
      name: 'HDFC Mid Cap Opportunities',
      category: 'Mid Cap',
      risk: 'Moderate',
      oneYearReturn: 24.2,
      threeYearReturn: 22.8,
      expenseRatio: 0.89,
      aumCr: 58320,
    ),
    _ScreenFund(
      name: 'Bandhan Small Cap Growth',
      category: 'Small Cap',
      risk: 'High',
      oneYearReturn: 29.1,
      threeYearReturn: 27.6,
      expenseRatio: 1.06,
      aumCr: 11240,
    ),
    _ScreenFund(
      name: 'ICICI Balanced Advantage',
      category: 'Hybrid',
      risk: 'Moderate',
      oneYearReturn: 14.7,
      threeYearReturn: 13.8,
      expenseRatio: 0.87,
      aumCr: 68210,
    ),
    _ScreenFund(
      name: 'Corporate Bond Low Duration',
      category: 'Debt',
      risk: 'Low',
      oneYearReturn: 8.2,
      threeYearReturn: 7.5,
      expenseRatio: 0.42,
      aumCr: 8310,
    ),
  ];

  int _selectedCategory = 0;
  int _selectedRisk = 0;
  double _minThreeYearReturn = 10;
  double _maxExpenseRatio = 1.20;
  String _sortBy = '3Y Return';

  List<_ScreenFund> get _visibleFunds {
    final category = _categories[_selectedCategory];
    final risk = _riskLevels[_selectedRisk];

    var filtered = _funds.where((fund) {
      final byCategory = category == 'All' || fund.category == category;
      final byRisk = risk == 'All' || fund.risk == risk;
      final byReturn = fund.threeYearReturn >= _minThreeYearReturn;
      final byExpense = fund.expenseRatio <= _maxExpenseRatio;
      return byCategory && byRisk && byReturn && byExpense;
    }).toList();

    switch (_sortBy) {
      case 'Expense Ratio':
        filtered.sort((a, b) => a.expenseRatio.compareTo(b.expenseRatio));
        break;
      case 'AUM':
        filtered.sort((a, b) => b.aumCr.compareTo(a.aumCr));
        break;
      case '1Y Return':
        filtered.sort((a, b) => b.oneYearReturn.compareTo(a.oneYearReturn));
        break;
      case '3Y Return':
      default:
        filtered.sort((a, b) => b.threeYearReturn.compareTo(a.threeYearReturn));
        break;
    }

    return filtered;
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
    final results = _visibleFunds;

    return Scaffold(
      backgroundColor: _bgBottom,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Open Screener',
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
                'Category',
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
                  children: List.generate(_categories.length, (index) {
                    final selected = _selectedCategory == index;
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < _categories.length - 1 ? 8 : 0,
                      ),
                      child: ChoiceChip(
                        label: Text(_categories[index]),
                        selected: selected,
                        onSelected: (_) {
                          setState(() => _selectedCategory = index);
                        },
                        selectedColor: _lime,
                        backgroundColor: _cardDark,
                        side: BorderSide(color: _lime.withOpacity(0.20)),
                        labelStyle: TextStyle(
                          color: selected ? _cardDark : _textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Risk',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(_riskLevels.length, (index) {
                  final selected = _selectedRisk == index;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < _riskLevels.length - 1 ? 8 : 0,
                    ),
                    child: ChoiceChip(
                      label: Text(_riskLevels[index]),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _selectedRisk = index);
                      },
                      selectedColor: _lime,
                      backgroundColor: _cardDark,
                      side: BorderSide(color: _lime.withOpacity(0.20)),
                      labelStyle: TextStyle(
                        color: selected ? _cardDark : _textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _lime.withOpacity(0.14)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Minimum 3Y Return: ${_minThreeYearReturn.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Slider(
                      value: _minThreeYearReturn,
                      min: 0,
                      max: 30,
                      divisions: 30,
                      activeColor: _lime,
                      inactiveColor: _cardDeep,
                      onChanged: (value) {
                        setState(() => _minThreeYearReturn = value);
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Maximum Expense Ratio: ${_maxExpenseRatio.toStringAsFixed(2)}%',
                      style: const TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Slider(
                      value: _maxExpenseRatio,
                      min: 0.10,
                      max: 1.50,
                      divisions: 28,
                      activeColor: _lime,
                      inactiveColor: _cardDeep,
                      onChanged: (value) {
                        setState(() => _maxExpenseRatio = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _sortBy,
                      dropdownColor: _cardDeep,
                      decoration: InputDecoration(
                        labelText: 'Sort by',
                        labelStyle: const TextStyle(color: _textMuted),
                        filled: true,
                        fillColor: _cardDeep,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: _lime.withOpacity(0.16)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: _lime.withOpacity(0.16)),
                        ),
                      ),
                      iconEnabledColor: _lime,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: '3Y Return',
                          child: Text('3Y Return'),
                        ),
                        DropdownMenuItem(
                          value: '1Y Return',
                          child: Text('1Y Return'),
                        ),
                        DropdownMenuItem(
                          value: 'Expense Ratio',
                          child: Text('Expense Ratio'),
                        ),
                        DropdownMenuItem(
                          value: 'AUM',
                          child: Text('AUM'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() => _sortBy = value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Results (${results.length})',
                style: const TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              if (results.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _cardDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _lime.withOpacity(0.14)),
                  ),
                  child: const Text(
                    'No funds matched these filters. Try relaxing return or expense criteria.',
                    style: TextStyle(
                      color: _textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                ...results.map(_fundCard),
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Build Your Own Mutual Fund Filter',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Screen by category, risk, return and cost to discover funds that fit your strategy.',
            style: TextStyle(
              color: _textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fundCard(_ScreenFund fund) {
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
                  fund.risk,
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
                child: _metric('AUM', '₹${fund.aumCr}Cr'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                _showMessage('Added ${fund.name} to shortlist.');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _lime,
                foregroundColor: _cardDeep,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Shortlist',
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
}

class _ScreenFund {
  final String name;
  final String category;
  final String risk;
  final double oneYearReturn;
  final double threeYearReturn;
  final double expenseRatio;
  final int aumCr;

  const _ScreenFund({
    required this.name,
    required this.category,
    required this.risk,
    required this.oneYearReturn,
    required this.threeYearReturn,
    required this.expenseRatio,
    required this.aumCr,
  });
}
