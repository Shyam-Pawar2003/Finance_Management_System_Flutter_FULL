import 'package:flutter/material.dart';
import 'Toprated/Hdfc.dart';
import 'Toprated/Icici.dart';
import 'Toprated/Mirae.dart';
import 'Toprated/Nifty.dart';
import 'Toprated/ParagTrack.dart';

class TopRatedPage extends StatefulWidget {
  const TopRatedPage({super.key});

  @override
  State<TopRatedPage> createState() => _TopRatedPageState();
}

class _TopRatedPageState extends State<TopRatedPage> {
  static const Color _bgTop = Color(0xFF0A1A08);
  static const Color _bgBottom = Color(0xFF050C04);
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  static const List<String> _categories = [
    'All',
    'Equity',
    'Hybrid',
    'Index',
  ];

  final List<_RatedFund> _funds = const [
    _RatedFund(
      name: 'Parag Parikh Flexi Cap',
      category: 'Equity',
      starRating: 5,
      consistencyScore: 92,
      oneYearReturn: 19.1,
      threeYearReturn: 18.3,
      expenseRatio: 0.74,
      downsideCapture: 72,
    ),
    _RatedFund(
      name: 'HDFC Balanced Advantage',
      category: 'Hybrid',
      starRating: 5,
      consistencyScore: 89,
      oneYearReturn: 15.2,
      threeYearReturn: 14.1,
      expenseRatio: 0.82,
      downsideCapture: 66,
    ),
    _RatedFund(
      name: 'Nifty 50 Index Direct',
      category: 'Index',
      starRating: 4,
      consistencyScore: 86,
      oneYearReturn: 17.6,
      threeYearReturn: 16.9,
      expenseRatio: 0.21,
      downsideCapture: 81,
    ),
    _RatedFund(
      name: 'Mirae Asset Large Cap',
      category: 'Equity',
      starRating: 4,
      consistencyScore: 84,
      oneYearReturn: 16.9,
      threeYearReturn: 15.4,
      expenseRatio: 0.59,
      downsideCapture: 78,
    ),
    _RatedFund(
      name: 'ICICI Multi Asset Fund',
      category: 'Hybrid',
      starRating: 5,
      consistencyScore: 90,
      oneYearReturn: 14.7,
      threeYearReturn: 13.8,
      expenseRatio: 0.87,
      downsideCapture: 63,
    ),
  ];

  int _selectedCategory = 0;

  List<_RatedFund> get _visibleFunds {
    final category = _categories[_selectedCategory];
    if (category == 'All') {
      return _funds;
    }
    return _funds.where((fund) => fund.category == category).toList();
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
          'Top Rated Funds',
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
            'Consistency First Ranking',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Top-rated funds are filtered by return consistency, downside behavior, and cost efficiency.',
            style: TextStyle(
              color: _textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _miniMetric('Avg Rating', '4.6 / 5')),
              Expanded(child: _miniMetric('Avg 3Y', '15.7%')),
              Expanded(child: _miniMetric('Avg Expense', '0.65%')),
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

  Widget _fundCard(_RatedFund fund) {
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
                  fund.category,
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
          Row(
            children: List.generate(5, (index) {
              final isFilled = index < fund.starRating;
              return Icon(
                isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 18,
                color: isFilled ? _lime : _textMuted,
              );
            }),
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
                child: _metric('Consistency', '${fund.consistencyScore}%'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Downside Capture: ${fund.downsideCapture}% (lower is better)',
            style: const TextStyle(
              color: _textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
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
                'Track Fund',
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

    if (lowerName.contains('parag')) {
      page = const ParagTrackTopRatedPage();
    } else if (lowerName.contains('hdfc')) {
      page = const HdfcTopRatedPage();
    } else if (lowerName.contains('nifty')) {
      page = const NiftyTopRatedPage();
    } else if (lowerName.contains('mirae')) {
      page = const MiraeTopRatedPage();
    } else {
      page = const IciciTopRatedPage();
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

class _RatedFund {
  final String name;
  final String category;
  final int starRating;
  final int consistencyScore;
  final double oneYearReturn;
  final double threeYearReturn;
  final double expenseRatio;
  final int downsideCapture;

  const _RatedFund({
    required this.name,
    required this.category,
    required this.starRating,
    required this.consistencyScore,
    required this.oneYearReturn,
    required this.threeYearReturn,
    required this.expenseRatio,
    required this.downsideCapture,
  });
}
