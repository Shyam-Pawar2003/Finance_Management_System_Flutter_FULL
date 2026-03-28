import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  static const String _apiBaseUrl =
      'https://military-jobye-haiqstudios-14f59639.koyeb.app';
  static const String _defaultSymbols = 'RELIANCE,TCS,INFY,HDFCBANK,ITC';

  static const List<String> _growwApiBaseUrls = [
    'http://localhost:3001',
    'http://127.0.0.1:3001',
  ];

  static const List<_LiveMarketStock> _fallbackStocks = [
    _LiveMarketStock(
      symbol: 'RELIANCE',
      exchange: 'NSE',
      companyName: 'Reliance Industries Limited',
      lastPrice: 2456.75,
      change: 12.30,
      percentChange: 0.50,
      sector: 'Energy',
    ),
    _LiveMarketStock(
      symbol: 'TCS',
      exchange: 'NSE',
      companyName: 'Tata Consultancy Services Limited',
      lastPrice: 3456.75,
      change: -12.50,
      percentChange: -0.36,
      sector: 'Technology',
    ),
    _LiveMarketStock(
      symbol: 'INFY',
      exchange: 'NSE',
      companyName: 'Infosys Limited',
      lastPrice: 1567.80,
      change: 8.90,
      percentChange: 0.57,
      sector: 'Technology',
    ),
    _LiveMarketStock(
      symbol: 'HDFCBANK',
      exchange: 'NSE',
      companyName: 'HDFC Bank Limited',
      lastPrice: 1645.75,
      change: -5.25,
      percentChange: -0.32,
      sector: 'Financial Services',
    ),
    _LiveMarketStock(
      symbol: 'ITC',
      exchange: 'NSE',
      companyName: 'ITC Limited',
      lastPrice: 445.50,
      change: 2.30,
      percentChange: 0.52,
      sector: 'Consumer Defensive',
    ),
  ];

  static const _GrowwAlgoSnapshot _fallbackGrowwSnapshot = _GrowwAlgoSnapshot(
    source: 'Fallback from repository structure',
    backendStatus: 'offline',
    templatesCount: 5,
    templateNames: [
      'Moving Average Crossover',
      'RSI Mean Reversion',
      'Breakout Momentum',
      'Bollinger Reversal',
      'Volume Spike Entry',
    ],
    authMethods: [
      'Access Token',
      'API Key + Secret',
      'API Key + TOTP',
    ],
    keyEndpoints: [
      '/health',
      '/api/auth/token/direct',
      '/api/auth/token/approval',
      '/api/auth/token/totp',
      '/api/market-data/quote',
      '/api/market-data/ltp',
      '/api/market-data/ohlc',
      '/api/market-data/instruments/search',
      '/api/portfolio/positions',
      '/api/portfolio/holdings',
      '/api/portfolio/margin',
      '/api/orders/create',
      '/api/orders/list',
      '/api/orders/detail/:growwOrderId',
      '/api/orders/modify',
      '/api/orders/cancel',
      '/api/strategies/create',
      '/api/strategies/list',
      '/api/strategies/:strategyId',
      '/api/indicators/calculate',
      '/api/templates/list',
      '/api/templates/generate',
      '/api/watchlist',
      '/api/monitoring',
      '/api/risk',
      '/api/backtesting',
    ],
    sampleQuote: _GrowwQuoteSample(
      tradingSymbol: 'RELIANCE',
      ltp: 2500,
      open: 2480,
      high: 2520,
      low: 2470,
      close: 2500,
      volume: 1000000,
    ),
  );

  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  bool _isLoadingMarket = false;
  String? _marketError;
  String? _marketNotice;
  List<_LiveMarketStock> _marketStocks = const [];

  bool _isLoadingGrowwData = false;
  String? _growwDataError;
  String? _growwDataNotice;
  _GrowwAlgoSnapshot? _growwSnapshot;

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

  @override
  void initState() {
    super.initState();
    _fetchLiveMarketData();
    _loadGrowwAlgoData();
  }

  Future<void> _loadGrowwAlgoData() async {
    setState(() {
      _isLoadingGrowwData = true;
      _growwDataError = null;
      _growwDataNotice = null;
    });

    for (final baseUrl in _growwApiBaseUrls) {
      try {
        final healthUri = Uri.parse('$baseUrl/health');
        final healthResponse =
            await http.get(healthUri).timeout(const Duration(seconds: 5));

        if (healthResponse.statusCode != 200) {
          continue;
        }

        final healthJson = jsonDecode(healthResponse.body);
        final backendStatus =
            (healthJson is Map ? healthJson['status'] : 'unknown').toString();

        List<String> templateNames = const [];
        int templatesCount = 0;

        final templatesUri = Uri.parse('$baseUrl/api/templates/list');
        final templatesResponse =
            await http.get(templatesUri).timeout(const Duration(seconds: 6));

        if (templatesResponse.statusCode == 200) {
          final templatesJson = jsonDecode(templatesResponse.body);
          if (templatesJson is Map<String, dynamic>) {
            final payload = templatesJson['payload'];
            if (payload is List) {
              templatesCount = payload.length;
              templateNames = payload
                  .whereType<Map<String, dynamic>>()
                  .map((item) => (item['name'] ?? 'Template').toString())
                  .take(8)
                  .toList();
            }
          }
        }

        if (!mounted) {
          return;
        }

        setState(() {
          _growwSnapshot = _fallbackGrowwSnapshot.copyWith(
            source: 'Live backend: $baseUrl',
            backendStatus: backendStatus,
            templatesCount: templatesCount,
            templateNames: templateNames.isEmpty
                ? _fallbackGrowwSnapshot.templateNames
                : templateNames,
          );
          _isLoadingGrowwData = false;
        });
        return;
      } catch (_) {
        continue;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _growwSnapshot = _fallbackGrowwSnapshot;
      _growwDataNotice =
          'Local Groww backend not reachable. Showing complete dataset from repository schema and route map.';
      _isLoadingGrowwData = false;
    });
  }

  Future<void> _fetchLiveMarketData() async {
    setState(() {
      _isLoadingMarket = true;
      _marketError = null;
      _marketNotice = null;
    });

    try {
      final uri = Uri.parse(
        '$_apiBaseUrl/stock/list?symbols=$_defaultSymbols&res=num',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('API request failed (${response.statusCode})');
      }

      final jsonBody = jsonDecode(response.body);
      if (jsonBody is! Map<String, dynamic>) {
        throw Exception('Unexpected API response');
      }

      final status = (jsonBody['status'] ?? '').toString().toLowerCase();
      if (status != 'success') {
        final message =
            (jsonBody['message'] ?? 'Unable to fetch market data').toString();
        throw Exception(message);
      }

      final stocksJson = jsonBody['stocks'];
      if (stocksJson is! List) {
        throw Exception('No market stocks found');
      }

      final stocks = stocksJson
          .whereType<Map<String, dynamic>>()
          .map(_LiveMarketStock.fromJson)
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _marketStocks = stocks;
        _isLoadingMarket = false;
        _marketNotice = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      final shouldUseFallback = errorMessage.contains('No active service') ||
          errorMessage.contains('404') ||
          errorMessage.contains('Failed host lookup') ||
          errorMessage.contains('ClientException') ||
          errorMessage.contains('TimeoutException');

      setState(() {
        if (shouldUseFallback) {
          _marketStocks = _fallbackStocks;
          _marketError = null;
          _marketNotice =
              'Live API is temporarily unavailable. Showing documented sample data from the Indian Stock Market API.';
        } else {
          _marketError = errorMessage;
        }
        _isLoadingMarket = false;
      });
    }
  }

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
        _sectionHeader('Live Indian Market', 'Refresh', _fetchLiveMarketData),
        const SizedBox(height: 10),
        _buildLiveMarketSection(),
        const SizedBox(height: 16),
        _sectionHeader(
            'Groww Trading Algo Data', 'Refresh', _loadGrowwAlgoData),
        const SizedBox(height: 10),
        _buildGrowwAlgoSection(),
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

  Widget _buildLiveMarketSection() {
    if (_isLoadingMarket) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _lime.withOpacity(0.14)),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_marketError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.redAccent.withOpacity(0.30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unable to load live market data',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _marketError!,
              style: const TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _fetchLiveMarketData,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _lime.withOpacity(0.26)),
                foregroundColor: _textPrimary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_marketStocks.isEmpty) {
      return const Text(
        'No live stocks available right now.',
        style: TextStyle(color: _textMuted),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_marketNotice != null) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _lime.withOpacity(0.20)),
            ),
            child: Text(
              _marketNotice!,
              style: const TextStyle(
                color: _textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        SizedBox(
          height: 165,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _marketStocks.length,
            itemBuilder: (_, index) {
              final stock = _marketStocks[index];
              final isPositive = stock.change >= 0;
              final accent = isPositive ? _lime : Colors.redAccent;
              final sign = isPositive ? '+' : '';

              return Padding(
                padding: EdgeInsets.only(
                  right: index < _marketStocks.length - 1 ? 12 : 0,
                ),
                child: Container(
                  width: 210,
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
                        '${stock.symbol} (${stock.exchange})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stock.companyName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'INR ${stock.lastPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$sign${stock.change.toStringAsFixed(2)}  ($sign${stock.percentChange.toStringAsFixed(2)}%)',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        stock.sector,
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGrowwAlgoSection() {
    if (_isLoadingGrowwData) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _lime.withOpacity(0.14)),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_growwDataError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.redAccent.withOpacity(0.30)),
        ),
        child: Text(
          _growwDataError!,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    final snapshot = _growwSnapshot;
    if (snapshot == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_growwDataNotice != null) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _lime.withOpacity(0.20)),
            ),
            child: Text(
              _growwDataNotice!,
              style: const TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
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
                snapshot.source,
                style: const TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Backend: ${snapshot.backendStatus.toUpperCase()} | Templates: ${snapshot.templatesCount} | Endpoints: ${snapshot.keyEndpoints.length}',
                style: const TextStyle(
                  color: _textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: snapshot.authMethods
                    .map(
                      (method) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _cardDeep,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _lime.withOpacity(0.18)),
                        ),
                        child: Text(
                          method,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 132,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.templateNames.length,
            itemBuilder: (_, index) {
              final name = snapshot.templateNames[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < snapshot.templateNames.length - 1 ? 10 : 0,
                ),
                child: Container(
                  width: 180,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _cardDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _lime.withOpacity(0.14)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_graph_rounded,
                          color: _lime, size: 20),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
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
              const Text(
                'Sample Market Quote (Repo Test Data)',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${snapshot.sampleQuote.tradingSymbol} | LTP ${snapshot.sampleQuote.ltp.toStringAsFixed(2)} | O:${snapshot.sampleQuote.open.toStringAsFixed(2)} H:${snapshot.sampleQuote.high.toStringAsFixed(2)} L:${snapshot.sampleQuote.low.toStringAsFixed(2)} C:${snapshot.sampleQuote.close.toStringAsFixed(2)} | Vol ${snapshot.sampleQuote.volume}',
                style: const TextStyle(
                  color: _textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'All Available API Routes',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: snapshot.keyEndpoints
              .map(
                (endpoint) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _cardDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _lime.withOpacity(0.14)),
                  ),
                  child: Text(
                    endpoint,
                    style: const TextStyle(
                      color: _textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _GrowwQuoteSample {
  const _GrowwQuoteSample({
    required this.tradingSymbol,
    required this.ltp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  final String tradingSymbol;
  final double ltp;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;
}

class _GrowwAlgoSnapshot {
  const _GrowwAlgoSnapshot({
    required this.source,
    required this.backendStatus,
    required this.templatesCount,
    required this.templateNames,
    required this.authMethods,
    required this.keyEndpoints,
    required this.sampleQuote,
  });

  final String source;
  final String backendStatus;
  final int templatesCount;
  final List<String> templateNames;
  final List<String> authMethods;
  final List<String> keyEndpoints;
  final _GrowwQuoteSample sampleQuote;

  _GrowwAlgoSnapshot copyWith({
    String? source,
    String? backendStatus,
    int? templatesCount,
    List<String>? templateNames,
    List<String>? authMethods,
    List<String>? keyEndpoints,
    _GrowwQuoteSample? sampleQuote,
  }) {
    return _GrowwAlgoSnapshot(
      source: source ?? this.source,
      backendStatus: backendStatus ?? this.backendStatus,
      templatesCount: templatesCount ?? this.templatesCount,
      templateNames: templateNames ?? this.templateNames,
      authMethods: authMethods ?? this.authMethods,
      keyEndpoints: keyEndpoints ?? this.keyEndpoints,
      sampleQuote: sampleQuote ?? this.sampleQuote,
    );
  }
}

class _LiveMarketStock {
  const _LiveMarketStock({
    required this.symbol,
    required this.exchange,
    required this.companyName,
    required this.lastPrice,
    required this.change,
    required this.percentChange,
    required this.sector,
  });

  final String symbol;
  final String exchange;
  final String companyName;
  final double lastPrice;
  final double change;
  final double percentChange;
  final String sector;

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  factory _LiveMarketStock.fromJson(Map<String, dynamic> json) {
    return _LiveMarketStock(
      symbol: (json['symbol'] ?? '-').toString(),
      exchange: (json['exchange'] ?? 'NSE').toString(),
      companyName: (json['company_name'] ?? 'Unknown Company').toString(),
      lastPrice: _toDouble(json['last_price']),
      change: _toDouble(json['change']),
      percentChange: _toDouble(json['percent_change']),
      sector: (json['sector'] ?? 'Sector N/A').toString(),
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
