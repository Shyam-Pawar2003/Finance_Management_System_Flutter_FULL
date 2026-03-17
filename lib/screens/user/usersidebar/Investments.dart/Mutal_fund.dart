import 'package:flutter/material.dart';

class MutualFundsPage extends StatefulWidget {
  const MutualFundsPage({super.key});

  @override
  State<MutualFundsPage> createState() => _MutualFundsPageState();
}

class _MutualFundsPageState extends State<MutualFundsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFundFilter = 0;

  static const Color _bgTop = Color(0xFF0A1A08);
  static const Color _bgBottom = Color(0xFF050C04);
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  final List<MutualFund> popularFunds = [
    const MutualFund(
      name: 'HDFC Silver ETF FoF Direct - Growth',
      icon: '📊',
      returns: 51.46,
      period: '3Y',
      category: 'Commodities Silver',
    ),
    const MutualFund(
      name: 'Bandhan Small Cap Fund',
      icon: '🔥',
      returns: 29.15,
      period: '3Y',
      category: 'Equity Small Cap',
    ),
    const MutualFund(
      name: 'HDFC Mid Cap Fund',
      icon: '📊',
      returns: 24.17,
      period: '3Y',
      category: 'Equity Mid Cap',
    ),
    const MutualFund(
      name: 'Parag Parikh Flexi Cap Fund',
      icon: '🌾',
      returns: 19.13,
      period: '3Y',
      category: 'Equity Flexi Cap',
    ),
  ];

  final List<FundCollection> collections = [
    const FundCollection(name: 'High return', icon: '🏛️'),
    const FundCollection(name: 'SIP with ₹100', icon: '📊'),
    const FundCollection(name: 'Gold & Silver Funds', icon: '🏛️'),
    const FundCollection(name: 'Large Cap', icon: '🏢'),
    const FundCollection(name: 'Mid Cap', icon: '📦'),
    const FundCollection(name: 'Small Cap', icon: '🏪'),
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

  void _showMessage(String text) {
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
          'Mutual Funds',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                _showMessage('Search filters will be available soon.'),
            icon: const Icon(Icons.search_rounded, color: _textPrimary),
          ),
          IconButton(
            onPressed: () =>
                _showMessage('Collection view will be available soon.'),
            icon: const Icon(Icons.grid_3x3_rounded, color: _textPrimary),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -140,
            right: -90,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _lime.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -130,
            left: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _lime.withOpacity(0.06),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_bgTop, _bgBottom],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tabs
                  _buildTabBar(),
                  const SizedBox(height: 20),

                  // SIP Promo Card
                  _buildSIPPromoCard(),
                  const SizedBox(height: 24),

                  // Popular Funds
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Popular Funds',
                        style: TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            _showMessage('Opening all mutual funds...'),
                        child: const Text(
                          'View all >',
                          style: TextStyle(
                            color: _textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: popularFunds.length,
                      itemBuilder: (_, i) => Padding(
                        padding: EdgeInsets.only(
                            right: i < popularFunds.length - 1 ? 12 : 0),
                        child: _buildFundCard(popularFunds[i]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Collections
                  const Text(
                    'Collections',
                    style: TextStyle(
                      color: _textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 14),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.05,
                    ),
                    itemCount: collections.length,
                    itemBuilder: (_, i) => _buildCollectionIcon(collections[i]),
                  ),
                  const SizedBox(height: 24),

                  // Funds by Groww (placeholder)
                  const Text(
                    'Funds by Groww',
                    style: TextStyle(
                      color: _textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildChartCard('NFO')),
                      const SizedBox(width: 10),
                      Expanded(child: _buildChartCard('')),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Products & Tools
                  const Text(
                    'Products & tools',
                    style: TextStyle(
                      color: _textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildToolsRow(),
                  const SizedBox(height: 24),

                  // All Mutual Funds
                  _buildAllFundsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildSIPPromoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _cardDark,
            _cardDeep,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _lime.withOpacity(0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.40),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Invest every month and grow\nyour wealth with SIP',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () =>
                      _showMessage('SIP setup flow will open soon.'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1EDC78),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Start a SIP',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF5B6FFF).withOpacity(0.40),
                  const Color(0xFF1EDC78).withOpacity(0.30),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              size: 50,
              color: Color(0xFF1EDC78),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundCard(MutualFund fund) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _lime.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _cardDeep,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _lime.withOpacity(0.20)),
            ),
            alignment: Alignment.center,
            child: Text(fund.icon, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 10),
          Text(
            fund.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              height: 1.3,
            ),
          ),
          const Spacer(),
          Text(
            '+${fund.returns.toStringAsFixed(2)}%',
            style: const TextStyle(
              color: _lime,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            fund.period,
            style: const TextStyle(
              color: _textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionIcon(FundCollection collection) {
    return GestureDetector(
      onTap: () => _showMessage('Showing ${collection.name} funds...'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _lime.withOpacity(0.14)),
            ),
            alignment: Alignment.center,
            child: Text(
              collection.icon,
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            collection.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String badge) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _lime.withOpacity(0.14)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (badge.isNotEmpty)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B6FFF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          Icon(
            Icons.pie_chart_rounded,
            size: 60,
            color: _lime.withOpacity(0.40),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsRow() {
    final tools = [
      ('Import\nfunds', Icons.arrow_downward_rounded),
      ('NFOs', Icons.notification_important_rounded),
      ('SIP\ncalculator', Icons.calculate_rounded),
      ('Compare\nfunds', Icons.balance_rounded),
      ('Cart', Icons.shopping_basket_rounded),
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tools.length,
        itemBuilder: (_, i) {
          final (label, icon) = tools[i];
          return Padding(
            padding: EdgeInsets.only(right: i < tools.length - 1 ? 14 : 0),
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
                  width: 56,
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
          );
        },
      ),
    );
  }

  Widget _buildAllFundsSection() {
    final filters = ['All', 'Sort by', 'Index only', 'Flexi Cap', 'Sector'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Mutual Funds',
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
              filters.length,
              (i) => Padding(
                padding: EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filters[i]),
                  selected: _selectedFundFilter == i,
                  onSelected: (sel) {
                    setState(() => _selectedFundFilter = i);
                  },
                  labelStyle: TextStyle(
                    color: _selectedFundFilter == i ? _cardDark : _textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  backgroundColor: Colors.transparent,
                  selectedColor: _lime,
                  side: BorderSide(
                    color: _selectedFundFilter == i
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
          children: const [
            Text(
              '1,680 funds',
              style: TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Text(
              '< > 3Y Returns',
              style: TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._buildFundListItems(),
      ],
    );
  }

  List<Widget> _buildFundListItems() {
    final funds = [
      (
        'HDFC Silver ETF FoF Direct - Growth',
        '📊',
        '51.46%',
        '3Y',
        'Commodities Silver'
      ),
      (
        'Parag Parikh Flexi Cap Fund',
        '🌾',
        '19.3%',
        '3Y',
        'Equity Flexi Cap • 5 ★'
      ),
      (
        'Bandhan Small Cap Fund',
        '🔥',
        '29.15%',
        '3Y',
        'Equity Small Cap • 5 ★'
      ),
    ];

    return funds
        .map(
          (f) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
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
                    child: Text(f.$2, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.$1,
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
                          f.$5,
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
                        f.$3,
                        style: const TextStyle(
                          color: _lime,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        f.$4,
                        style: const TextStyle(
                          color: _textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }
}

class MutualFund {
  const MutualFund({
    required this.name,
    required this.icon,
    required this.returns,
    required this.period,
    required this.category,
  });

  final String name;
  final String icon;
  final double returns;
  final String period;
  final String category;
}

class FundCollection {
  const FundCollection({
    required this.name,
    required this.icon,
  });

  final String name;
  final String icon;
}

// ── Content-only widget (no Scaffold/AppBar) ──────────────────────────────────
class MutualFundsContent extends StatefulWidget {
  const MutualFundsContent({super.key});

  @override
  State<MutualFundsContent> createState() => _MutualFundsContentState();
}

class _MutualFundsContentState extends State<MutualFundsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  final List<MutualFund> popularFunds = [
    const MutualFund(
      name: 'HDFC Silver ETF FoF Direct - Growth',
      icon: '📊',
      returns: 51.46,
      period: '3Y',
      category: 'Commodities Silver',
    ),
    const MutualFund(
      name: 'Bandhan Small Cap Fund',
      icon: '🔥',
      returns: 29.15,
      period: '3Y',
      category: 'Equity Small Cap',
    ),
    const MutualFund(
      name: 'HDFC Mid Cap Fund',
      icon: '📊',
      returns: 24.17,
      period: '3Y',
      category: 'Equity Mid Cap',
    ),
    const MutualFund(
      name: 'Parag Parikh Flexi Cap Fund',
      icon: '🌾',
      returns: 19.13,
      period: '3Y',
      category: 'Equity Flexi Cap',
    ),
  ];

  final List<FundCollection> collections = [
    const FundCollection(name: 'High return', icon: '🏛️'),
    const FundCollection(name: 'SIP with ₹100', icon: '📊'),
    const FundCollection(name: 'Gold & Silver Funds', icon: '🏛️'),
    const FundCollection(name: 'Large Cap', icon: '🏢'),
    const FundCollection(name: 'Mid Cap', icon: '📦'),
    const FundCollection(name: 'Small Cap', icon: '🏪'),
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

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'Mutual Funds',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
        ),

        // Tabs
        _buildTabBar(),
        const SizedBox(height: 20),

        // SIP Promo Card
        _buildSIPPromoCard(),
        const SizedBox(height: 24),

        // Popular Funds
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Popular Funds',
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            GestureDetector(
              onTap: () => _showMessage('Opening all mutual funds...'),
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
            itemCount: popularFunds.length,
            itemBuilder: (_, i) => Padding(
              padding:
                  EdgeInsets.only(right: i < popularFunds.length - 1 ? 12 : 0),
              child: _buildFundCard(popularFunds[i]),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Collections
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
          itemCount: collections.length,
          itemBuilder: (_, i) => _buildCollectionIcon(collections[i]),
        ),
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

  Widget _buildSIPPromoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
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
                  'Invest every month and grow',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      _showMessage('SIP setup flow will open soon.'),
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
                    'Start a SIP',
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
              Icons.calendar_month_rounded,
              size: 40,
              color: Color(0xFF1EDC78),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundCard(MutualFund fund) {
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
            child: Text(fund.icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              fund.name,
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
            '+${fund.returns.toStringAsFixed(2)}%',
            style: const TextStyle(
              color: _lime,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          Text(
            fund.period,
            style: const TextStyle(
              color: _textMuted,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionIcon(FundCollection collection) {
    return GestureDetector(
      onTap: () => _showMessage('Showing ${collection.name} funds...'),
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
            child: Text(
              collection.icon,
              style: const TextStyle(fontSize: 24),
            ),
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
}
