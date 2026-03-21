import 'package:flutter/material.dart';

import 'Mutual_Funds/Dashboard.dart';
import 'Mutual_Funds/Explore.dart';
import 'Mutual_Funds/SIP.dart';
import 'Mutual_Funds/Watchlist.dart';
import 'Mutual_Funds/Collection/Golbal_exposure.dart';
import 'Mutual_Funds/Collection/Low_volatility.dart';
import 'Mutual_Funds/Collection/Open_Screener.dart';
import 'Mutual_Funds/Collection/Tax_saver.dart';
import 'Mutual_Funds/Collection/Top_rated.dart';

class MutualFundsPage extends StatelessWidget {
  const MutualFundsPage({super.key});

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
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OpenScreenerPage(),
                ),
              );
            },
            icon: const Icon(Icons.tune_rounded),
            color: _lime,
            tooltip: 'Open Screener',
          ),
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
              child: MutualFundsContent(),
            ),
          ),
        ],
      ),
    );
  }
}

class MutualFundsContent extends StatefulWidget {
  const MutualFundsContent({super.key});

  @override
  State<MutualFundsContent> createState() => _MutualFundsContentState();
}

class _MutualFundsContentState extends State<MutualFundsContent>
    with SingleTickerProviderStateMixin {
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  late TabController _tabController;
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this)
      ..addListener(() {
        if (_activeTab != _tabController.index &&
            !_tabController.indexIsChanging) {
          setState(() => _activeTab = _tabController.index);
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  void _openGlobalExposure() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const GlobalExposurePage(),
      ),
    );
  }

  void _openLowVolatility() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LowVolatilityPage(),
      ),
    );
  }

  void _openTaxSaver() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TaxSaverPage(),
      ),
    );
  }

  void _openTopRated() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TopRatedPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Mutual Funds',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _openTopRated,
                style: TextButton.styleFrom(
                  foregroundColor: _lime,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
                icon: const Icon(Icons.star_rounded, size: 16),
                label: const Text(
                  'Top',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton.icon(
                onPressed: _openTaxSaver,
                style: TextButton.styleFrom(
                  foregroundColor: _lime,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
                icon: const Icon(Icons.receipt_long_rounded, size: 16),
                label: const Text(
                  'Tax Saver',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton.icon(
                onPressed: _openLowVolatility,
                style: TextButton.styleFrom(
                  foregroundColor: _lime,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
                icon: const Icon(Icons.shield_rounded, size: 16),
                label: const Text(
                  'Low Vol',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton.icon(
                onPressed: _openGlobalExposure,
                style: TextButton.styleFrom(
                  foregroundColor: _lime,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
                icon: const Icon(Icons.public_rounded, size: 16),
                label: const Text(
                  'Global',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        _buildTabBar(),
        const SizedBox(height: 18),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: KeyedSubtree(
            key: ValueKey(_activeTab),
            child: _activeWidget(),
          ),
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

  Widget _activeWidget() {
    switch (_activeTab) {
      case 0:
        return MutualFundExploreTab(onMessage: _showMessage);
      case 1:
        return MutualFundDashboardTab(onMessage: _showMessage);
      case 2:
        return MutualFundSipTab(onMessage: _showMessage);
      case 3:
      default:
        return MutualFundWatchlistTab(onMessage: _showMessage);
    }
  }
}
