import 'package:flutter/material.dart';

import '../../data/dashboard_seed_data.dart';
import '../../models/dashboard_models.dart';
import 'Home/QR.dart';
import 'Home/Rebalance.dart';
import 'Home/Request.dart';
import 'Home/Send.dart';
import 'Home/Setting.dart';
import 'Home/Withdraw.dart';

// ── Standalone page (Navigator.push usage) ───────────────────────────────────
class UserInvestmentsHomePage extends StatelessWidget {
  const UserInvestmentsHomePage({super.key});

  static const Color _bgTop = Color(0xFF0A1A08);
  static const Color _bgBottom = Color(0xFF050C04);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);

  Widget _glow(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _lime.withOpacity(0.08),
        ),
      );

  void _showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBottom,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Investment Home',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                _showMessage(context, 'Search filters will be available soon.'),
            icon: const Icon(Icons.search_rounded, color: _textPrimary),
          ),
          IconButton(
            onPressed: () => _showMessage(
                context, 'Collection view will be available soon.'),
            icon: const Icon(Icons.grid_3x3_rounded, color: _textPrimary),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          Positioned(top: -140, right: -90, child: _glow(300)),
          Positioned(bottom: -130, left: -80, child: _glow(240)),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_bgTop, _bgBottom],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          const SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: UserInvestmentsHomeContent(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Embeddable content widget (no Scaffold / AppBar) ─────────────────────────
// Used by UserInvestmentsHomePage and the Investments tab shell (IndexedStack).
class UserInvestmentsHomeContent extends StatefulWidget {
  const UserInvestmentsHomeContent({super.key});

  @override
  State<UserInvestmentsHomeContent> createState() =>
      _UserInvestmentsHomeContentState();
}

class _UserInvestmentsHomeContentState extends State<UserInvestmentsHomeContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFilter = 0;

  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  static const List<String> _holdingFilters = [
    'All',
    'Equity',
    'Debt',
    'Gold',
    'ETF',
  ];

  final List<_InvestmentCollection> _collections = const [
    _InvestmentCollection(name: 'High return', icon: Icons.trending_up_rounded),
    _InvestmentCollection(name: 'Stable', icon: Icons.shield_outlined),
    _InvestmentCollection(name: 'Dividend', icon: Icons.payments_rounded),
    _InvestmentCollection(
        name: 'Long term', icon: Icons.calendar_month_rounded),
    _InvestmentCollection(
        name: 'Low risk', icon: Icons.health_and_safety_rounded),
    _InvestmentCollection(name: 'Balanced', icon: Icons.balance_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _currencySymbol {
    switch (seededUserProfile.currencyPreference) {
      case 'EUR':
        return 'EUR ';
      case 'GBP':
        return 'GBP ';
      case 'INR':
        return 'INR ';
      case 'AED':
        return 'AED ';
      case 'USD':
      default:
        return r'$';
    }
  }

  String _money(double value, {int decimals = 0}) {
    final isNegative = value < 0;
    final rounded = value.abs().toStringAsFixed(decimals);
    final parts = rounded.split('.');
    final whole = parts[0];
    final decimal = parts.length > 1 ? parts[1] : '';

    final buffer = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      final reverseIndex = whole.length - i;
      buffer.write(whole[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    final number =
        decimals > 0 ? '${buffer.toString()}.$decimal' : buffer.toString();
    return '${isNegative ? '-' : ''}$_currencySymbol$number';
  }

  double get _portfolioInvested => seedInvestmentHoldings.fold<double>(
        0,
        (sum, item) => sum + item.investedAmount,
      );

  double get _portfolioCurrent => seedInvestmentHoldings.fold<double>(
        0,
        (sum, item) => sum + item.currentValue,
      );

  double get _portfolioReturn => _portfolioCurrent - _portfolioInvested;

  double get _portfolioReturnPercent {
    if (_portfolioInvested <= 0) {
      return 0;
    }
    return (_portfolioReturn / _portfolioInvested) * 100;
  }

  List<InvestmentHolding> get _sortedHoldings {
    final holdings = List<InvestmentHolding>.from(seedInvestmentHoldings);
    holdings.sort((a, b) => b.currentValue.compareTo(a.currentValue));
    return holdings;
  }

  List<InvestmentHolding> get _visibleHoldings {
    final holdings = _sortedHoldings;

    if (_selectedFilter == 0) {
      return holdings;
    }

    final filter = _holdingFilters[_selectedFilter].toLowerCase();
    return holdings.where((item) {
      final type = item.assetType.toLowerCase();
      return type.contains(filter);
    }).toList();
  }

  String get _riskLabel {
    int low = 0;
    int medium = 0;
    int high = 0;

    for (final item in seedInvestmentHoldings) {
      switch (item.riskLevel) {
        case 'Low':
          low++;
          break;
        case 'Medium':
          medium++;
          break;
        default:
          high++;
      }
    }

    if (low >= medium && low >= high) {
      return 'Conservative';
    }
    if (medium >= high) {
      return 'Balanced';
    }
    return 'Aggressive';
  }

  Color _returnColor(double value) {
    return value >= 0 ? _lime : const Color(0xFFE67A62);
  }

  String _holdingEmoji(String assetType) {
    final type = assetType.toLowerCase();
    if (type.contains('equity')) {
      return '📈';
    }
    if (type.contains('debt')) {
      return '🏦';
    }
    if (type.contains('gold')) {
      return '🥇';
    }
    if (type.contains('etf')) {
      return '📊';
    }
    if (type.contains('crypto')) {
      return '🪙';
    }
    return '💹';
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topHoldings = _sortedHoldings.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'Investment Home',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
        ),
        _buildTabBar(),
        const SizedBox(height: 20),
        _buildPortfolioPromoCard(),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Top Holdings',
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            GestureDetector(
              onTap: () => _showMessage('Opening all holdings...'),
              child: const Text(
                'View all >',
                style: TextStyle(
                  color: _textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: topHoldings.length,
            itemBuilder: (_, i) => Padding(
              padding:
                  EdgeInsets.only(right: i < topHoldings.length - 1 ? 12 : 0),
              child: _buildHoldingCard(topHoldings[i]),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Collections',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 14,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
          ),
          itemCount: _collections.length,
          itemBuilder: (_, i) => _buildCollectionIcon(_collections[i]),
        ),
        const SizedBox(height: 24),
        const Text(
          'Portfolio Insights',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 12),
        _buildInsightsSection(),
        const SizedBox(height: 24),
        const Text(
          'Products & tools',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 14),
        _buildToolsRow(),
        const SizedBox(height: 24),
        _buildAllHoldingsSection(),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _textMuted.withOpacity(0.20), width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Explore'),
          Tab(text: 'Dashboard'),
          Tab(text: 'SIPs'),
          Tab(text: 'Watchlist'),
        ],
        labelColor: _textPrimary,
        unselectedLabelColor: _textMuted,
        indicatorColor: _lime,
        indicatorWeight: 3,
      ),
    );
  }

  Widget _buildPortfolioPromoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_cardDark, _cardDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _lime.withOpacity(0.16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Track and grow your portfolio every month',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _money(_portfolioCurrent, decimals: 2),
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_portfolioReturn >= 0 ? '+' : '-'}${_portfolioReturnPercent.abs().toStringAsFixed(2)}% total return',
                  style: TextStyle(
                    color: _returnColor(_portfolioReturn),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildStatChip(
                      Icons.account_balance_wallet_outlined,
                      'Invested ${_money(_portfolioInvested, decimals: 0)}',
                    ),
                    _buildStatChip(
                      Icons.pie_chart_rounded,
                      '${seedInvestmentHoldings.length} holdings',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      _showMessage('Add investment flow will open soon.'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1EDC78),
                    foregroundColor: Colors.black,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Add Investment',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF5B6FFF).withOpacity(0.30),
                  const Color(0xFF1EDC78).withOpacity(0.20),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.candlestick_chart_rounded,
              size: 40,
              color: Color(0xFF1EDC78),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _lime),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: _textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingCard(InvestmentHolding item) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _lime.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _cardDeep,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              _holdingEmoji(item.assetType),
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              item.assetName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            _money(item.currentValue, decimals: 0),
            style: const TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          Text(
            '${item.returnPercent >= 0 ? '+' : ''}${item.returnPercent.toStringAsFixed(2)}%',
            style: TextStyle(
              color: _returnColor(item.returnPercent),
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionIcon(_InvestmentCollection collection) {
    return GestureDetector(
      onTap: () => _showMessage('Showing ${collection.name} collection...'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _lime.withOpacity(0.14)),
            ),
            alignment: Alignment.center,
            child: Icon(collection.icon, color: _lime, size: 24),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              collection.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final leftCard = _buildInsightCard(
          title: 'Risk Profile',
          value: _riskLabel,
          subtitle: '${seedInvestmentHoldings.length} assets diversified',
          icon: Icons.shield_moon_outlined,
          accent: const Color(0xFF5B6FFF),
        );

        final rightCard = _buildInsightCard(
          title: 'Total Return',
          value:
              '${_portfolioReturn >= 0 ? '+' : '-'}${_portfolioReturnPercent.abs().toStringAsFixed(2)}%',
          subtitle: _money(_portfolioReturn, decimals: 2),
          icon: _portfolioReturn >= 0
              ? Icons.trending_up_rounded
              : Icons.trending_down_rounded,
          accent: _returnColor(_portfolioReturn),
        );

        if (constraints.maxWidth >= 640) {
          return Row(
            children: [
              Expanded(child: leftCard),
              const SizedBox(width: 10),
              Expanded(child: rightCard),
            ],
          );
        }

        return Column(
          children: [
            leftCard,
            const SizedBox(height: 10),
            rightCard,
          ],
        );
      },
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _lime.withOpacity(0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _cardDeep,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withOpacity(0.45)),
            ),
            child: Icon(icon, color: accent, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsRow() {
    final tools = <(String, IconData, VoidCallback)>[
      (
        'Send',
        Icons.send_rounded,
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const InvestmentSendPage(),
            ),
          );
        },
      ),
      (
        'Request',
        Icons.request_page_rounded,
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const InvestmentRequestPage(),
            ),
          );
        },
      ),
      (
        'Withdraw',
        Icons.outbox_rounded,
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const InvestmentWithdrawPage(),
            ),
          );
        },
      ),
      (
        'Rebalance',
        Icons.balance_rounded,
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const InvestmentRebalancePage(),
            ),
          );
        },
      ),
      (
        'SIP setup',
        Icons.calendar_month_rounded,
        () => _showMessage('SIP setup tools are coming soon.'),
      ),
      (
        'Compare',
        Icons.compare_arrows_rounded,
        () => _showMessage('Compare tools are coming soon.'),
      ),
      (
        'Settings',
        Icons.settings_rounded,
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const InvestmentSettingsPage(),
            ),
          );
        },
      ),
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tools.length,
        itemBuilder: (_, i) {
          final (label, icon, onTap) = tools[i];

          return Padding(
            padding: EdgeInsets.only(right: i < tools.length - 1 ? 14 : 0),
            child: GestureDetector(
              onTap: onTap,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _cardDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _lime.withOpacity(0.16)),
                    ),
                    child: Icon(icon, color: _lime, size: 26),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 66,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllHoldingsSection() {
    final holdings = _visibleHoldings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Holdings',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              _holdingFilters.length,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(_holdingFilters[i]),
                  selected: _selectedFilter == i,
                  onSelected: (_) {
                    setState(() => _selectedFilter = i);
                  },
                  labelStyle: TextStyle(
                    color: _selectedFilter == i ? _cardDark : _textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  backgroundColor: Colors.transparent,
                  selectedColor: _lime,
                  side: BorderSide(
                    color: _selectedFilter == i
                        ? _lime
                        : _textMuted.withOpacity(0.30),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${holdings.length} assets',
              style: const TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const Text(
              'Current value',
              style: TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (holdings.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _lime.withOpacity(0.12)),
            ),
            child: const Text(
              'No holdings found in this category.',
              style: TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          )
        else
          ...holdings.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildHoldingListCard(item),
            ),
          ),
      ],
    );
  }

  Widget _buildHoldingListCard(InvestmentHolding item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _lime.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _cardDeep,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _lime.withOpacity(0.16)),
            ),
            alignment: Alignment.center,
            child: Text(
              _holdingEmoji(item.assetType),
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.assetName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.assetType} • ${item.riskLevel} risk',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _money(item.currentValue, decimals: 0),
                style: const TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.returnPercent >= 0 ? '+' : ''}${item.returnPercent.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: _returnColor(item.returnPercent),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvestmentCollection {
  const _InvestmentCollection({required this.name, required this.icon});

  final String name;
  final IconData icon;
}
