import 'package:flutter/material.dart';

import 'Collection/Golbal_exposure.dart';
import 'Collection/Low_volatility.dart';
import 'Collection/Tax_saver.dart';
import 'Collection/Top_rated.dart';

class MutualFundExploreTab extends StatefulWidget {
  const MutualFundExploreTab({
    super.key,
    required this.onMessage,
  });

  final ValueChanged<String> onMessage;

  @override
  State<MutualFundExploreTab> createState() => _MutualFundExploreTabState();
}

class _MutualFundExploreTabState extends State<MutualFundExploreTab> {
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  static const List<String> _categories = [
    'All',
    'Large Cap',
    'Mid Cap',
    'Small Cap',
    'Index',
  ];

  final List<_ExploreFund> _funds = const [
    _ExploreFund(
      name: 'HDFC Mid Cap Opportunities',
      category: 'Mid Cap',
      threeYearReturn: 24.17,
      riskLabel: 'Moderate',
      icon: Icons.stacked_line_chart_rounded,
    ),
    _ExploreFund(
      name: 'Parag Parikh Flexi Cap',
      category: 'Flexi Cap',
      threeYearReturn: 19.13,
      riskLabel: 'Moderate',
      icon: Icons.public_rounded,
    ),
    _ExploreFund(
      name: 'Bandhan Small Cap Growth',
      category: 'Small Cap',
      threeYearReturn: 29.15,
      riskLabel: 'High',
      icon: Icons.bolt_rounded,
    ),
    _ExploreFund(
      name: 'Nifty 50 Index Direct',
      category: 'Index',
      threeYearReturn: 17.62,
      riskLabel: 'Low',
      icon: Icons.track_changes_rounded,
    ),
  ];

  final List<_CollectionTile> _collections = const [
    _CollectionTile(
      title: 'Top Rated',
      subtitle: 'Strong consistency',
      icon: Icons.verified_rounded,
    ),
    _CollectionTile(
      title: 'Starter SIPs',
      subtitle: 'From 500 monthly',
      icon: Icons.savings_rounded,
    ),
    _CollectionTile(
      title: 'Tax Saver',
      subtitle: 'ELSS focused',
      icon: Icons.receipt_long_rounded,
    ),
    _CollectionTile(
      title: 'Low Volatility',
      subtitle: 'Defensive picks',
      icon: Icons.shield_rounded,
    ),
    _CollectionTile(
      title: 'Global Exposure',
      subtitle: 'International funds',
      icon: Icons.travel_explore_rounded,
    ),
    _CollectionTile(
      title: 'Income Plans',
      subtitle: 'Hybrid debt mix',
      icon: Icons.account_balance_wallet_rounded,
    ),
  ];

  int _selectedCategory = 0;

  List<_ExploreFund> get _visibleFunds {
    final category = _categories[_selectedCategory];
    if (category == 'All') {
      return _funds;
    }

    return _funds.where((fund) {
      final normalized = fund.category.toLowerCase();
      return normalized.contains(category.toLowerCase().replaceAll(' cap', ''));
    }).toList();
  }

  void _openCollection(_CollectionTile collection) {
    if (collection.title == 'Top Rated') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const TopRatedPage(),
        ),
      );
      return;
    }

    if (collection.title == 'Tax Saver') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const TaxSaverPage(),
        ),
      );
      return;
    }

    if (collection.title == 'Low Volatility') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const LowVolatilityPage(),
        ),
      );
      return;
    }

    if (collection.title == 'Global Exposure') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const GlobalExposurePage(),
        ),
      );
      return;
    }

    widget.onMessage('${collection.title} opened.');
  }

  @override
  Widget build(BuildContext context) {
    final visibleFunds = _visibleFunds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroCard(),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_categories.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_categories[index]),
                  selected: _selectedCategory == index,
                  onSelected: (_) {
                    setState(() => _selectedCategory = index);
                  },
                  selectedColor: _lime,
                  backgroundColor: _cardDark,
                  side: BorderSide(color: _lime.withOpacity(0.20)),
                  labelStyle: TextStyle(
                    color: _selectedCategory == index ? _cardDark : _textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        _sectionHeader('Popular Funds', 'View all', () {
          widget.onMessage('Opening all funds list.');
        }),
        const SizedBox(height: 10),
        SizedBox(
          height: 195,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: visibleFunds.length,
            itemBuilder: (_, index) {
              final fund = visibleFunds[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < visibleFunds.length - 1 ? 12 : 0,
                ),
                child: _fundCard(fund),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Collections',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _collections.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (_, index) {
            final collection = _collections[index];
            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _openCollection(collection),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _lime.withOpacity(0.14)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _cardDeep,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(collection.icon, color: _lime, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            collection.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            collection.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_cardDark, _cardDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _lime.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Discover mutual funds curated for your goals.',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Compare performance, risk, and consistency before investing.',
                  style: TextStyle(
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => widget.onMessage('Fund screener opened.'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _lime,
                    foregroundColor: const Color(0xFF102A00),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Open Screener',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: _cardDeep,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _lime.withOpacity(0.20)),
            ),
            child: const Icon(
              Icons.pie_chart_rounded,
              color: _lime,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String action, VoidCallback onTap) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: const TextStyle(
              color: _textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _fundCard(_ExploreFund fund) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _lime.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _cardDeep,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(fund.icon, color: _lime, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            fund.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            '${fund.threeYearReturn.toStringAsFixed(2)}% 3Y',
            style: const TextStyle(
              color: _lime,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${fund.category} | ${fund.riskLabel} risk',
            style: const TextStyle(
              color: _textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => widget.onMessage('${fund.name} added to cart.'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _lime.withOpacity(0.26)),
                foregroundColor: _textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: const Text(
                'Invest',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreFund {
  const _ExploreFund({
    required this.name,
    required this.category,
    required this.threeYearReturn,
    required this.riskLabel,
    required this.icon,
  });

  final String name;
  final String category;
  final double threeYearReturn;
  final String riskLabel;
  final IconData icon;
}

class _CollectionTile {
  const _CollectionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
