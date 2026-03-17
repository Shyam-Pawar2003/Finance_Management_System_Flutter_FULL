import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/dashboard_seed_data.dart';
import '../models/dashboard_models.dart';
import 'Investments.dart/Goals.dart';
import 'Investments.dart/History.dart';
import 'Investments.dart/Mutal_fund.dart';

class UserInvestmentsPage extends StatefulWidget {
  const UserInvestmentsPage({super.key});

  @override
  State<UserInvestmentsPage> createState() => _UserInvestmentsPageState();
}

class _UserInvestmentsPageState extends State<UserInvestmentsPage> {
  String _selectedRange = '1Y';
  int _activeBottomIndex = 1;

  static const List<String> _rangeOptions = ['1M', '3M', '6M', '1Y', '3Y'];

  // Replace with your API key from https://indianapi.in
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  String _stockName = 'Nifty 50';
  List<_GrowthPoint>? _apiPoints;
  bool _isLoadingChart = false;
  String? _apiError;
  final TextEditingController _stockController =
      TextEditingController(text: 'Nifty 50');

  static const Color _bgTop = Color(0xFF0A1A08);
  static const Color _bgBottom = Color(0xFF050C04);
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _limeSoft = Color(0xFFAAD83D);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  @override
  void initState() {
    super.initState();
    _fetchHistoricalData();
  }

  @override
  void dispose() {
    _stockController.dispose();
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

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  double get _portfolioInvested {
    return seedInvestmentHoldings.fold<double>(
      0,
      (sum, item) => sum + item.investedAmount,
    );
  }

  double get _portfolioCurrent {
    return seedInvestmentHoldings.fold<double>(
      0,
      (sum, item) => sum + item.currentValue,
    );
  }

  double get _portfolioReturnAmount => _portfolioCurrent - _portfolioInvested;

  double get _portfolioReturnPercent {
    if (_portfolioInvested <= 0) {
      return 0;
    }
    return (_portfolioReturnAmount / _portfolioInvested) * 100;
  }

  double get _riskScore {
    double weighted = 0;
    double total = 0;

    for (final item in seedInvestmentHoldings) {
      final weight = item.currentValue;
      final level = _riskValue(item.riskLevel);
      weighted += weight * level;
      total += weight;
    }

    if (total <= 0) {
      return 0;
    }
    return weighted / total;
  }

  int _riskValue(String riskLevel) {
    switch (riskLevel) {
      case 'Low':
        return 1;
      case 'Medium':
        return 2;
      case 'High':
      default:
        return 3;
    }
  }

  String get _riskLabel {
    if (_riskScore <= 1.4) {
      return 'Low Risk';
    }
    if (_riskScore <= 2.2) {
      return 'Balanced';
    }
    return 'High Risk';
  }

  String _rangeToPeriod(String range) {
    switch (range) {
      case '1M':
        return '1m';
      case '3M':
        return '1m';
      case '6M':
        return '6m';
      case '3Y':
        return '3yr';
      case '1Y':
      default:
        return '1yr';
    }
  }

  Future<void> _fetchHistoricalData() async {
    setState(() {
      _isLoadingChart = true;
      _apiError = null;
    });
    try {
      final uri = Uri.parse(
        'https://stock.indianapi.in/historical_data'
        '?stock_name=${Uri.encodeQueryComponent(_stockName)}'
        '&period=${_rangeToPeriod(_selectedRange)}'
        '&filter=price',
      );
      final response = await http.get(
        uri,
        headers: {'x-api-key': _apiKey},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final points = _parseHistoricalData(data);
        setState(() {
          _apiPoints = points;
          _isLoadingChart = false;
        });
      } else {
        setState(() {
          _apiError =
              'API error ${response.statusCode}: ${response.reasonPhrase}';
          _apiPoints = null;
          _isLoadingChart = false;
        });
      }
    } catch (_) {
      setState(() {
        _apiError = 'Network error — showing local data.';
        _apiPoints = null;
        _isLoadingChart = false;
      });
    }
  }

  List<_GrowthPoint> _parseHistoricalData(dynamic data) {
    try {
      // Format A: { "datasets":[{"metric":"Close","data":[[ts,val],...]}], "timeLabels":[...] }
      if (data is Map && data['datasets'] is List) {
        final datasets = data['datasets'] as List;
        final rawLabels = data['timeLabels'];
        final timeLabels = rawLabels is List
            ? rawLabels.map((e) => e.toString()).toList()
            : <String>[];
        Map<String, dynamic>? closeSet;
        for (final ds in datasets) {
          if (ds is Map) {
            final metric =
                (ds['metric'] ?? ds['label'] ?? '').toString().toLowerCase();
            if (metric.contains('close') || metric.contains('price')) {
              closeSet = Map<String, dynamic>.from(ds);
              break;
            }
          }
        }
        closeSet ??= datasets.isNotEmpty
            ? Map<String, dynamic>.from(datasets.first as Map)
            : null;
        if (closeSet != null && closeSet['data'] is List) {
          final rawData = closeSet['data'] as List;
          final points = <_GrowthPoint>[];
          for (int i = 0; i < rawData.length; i++) {
            final item = rawData[i];
            double? value;
            final label = timeLabels.length > i ? timeLabels[i] : 'P\${i + 1}';
            if (item is List && item.length >= 2) {
              value = (item[1] as num?)?.toDouble();
            } else if (item is Map) {
              value = ((item['y'] ?? item['value'] ?? item['close']) as num?)
                  ?.toDouble();
            } else if (item is num) {
              value = item.toDouble();
            }
            if (value != null) {
              points.add(_GrowthPoint(label: label, value: value));
            }
          }
          return points;
        }
      }
      // Format B: [ { "date": "...", "close": ... } ]
      if (data is List) {
        final points = <_GrowthPoint>[];
        for (final item in data) {
          if (item is Map) {
            final val = (item['close'] ??
                item['price'] ??
                item['value'] ??
                item['last']) as num?;
            final label = (item['date'] ?? item['label'] ?? item['time'] ?? '')
                .toString();
            if (val != null) {
              points.add(_GrowthPoint(label: label, value: val.toDouble()));
            }
          }
        }
        return points;
      }
    } catch (_) {}
    return [];
  }

  List<_GrowthPoint> get _growthSeries {
    int length;
    switch (_selectedRange) {
      case '1M':
        length = 2;
        break;
      case '3M':
        length = 3;
        break;
      case '6M':
        length = 6;
        break;
      case '3Y':
        length = seedMonthlyReportSeries.length;
        break;
      case '1Y':
      default:
        length = math.min(12, seedMonthlyReportSeries.length);
        break;
    }

    if (seedMonthlyReportSeries.isEmpty) {
      return const [];
    }

    final safeLength =
        math.max(2, math.min(length, seedMonthlyReportSeries.length));
    final source = seedMonthlyReportSeries.sublist(
      seedMonthlyReportSeries.length - safeLength,
    );

    double value = _portfolioInvested * 0.74;
    final points = <_GrowthPoint>[];
    for (int i = 0; i < source.length; i++) {
      final month = source[i];
      final monthlyContribution = math.max(0.0, month.income - month.expense);
      final drift = 1.004 + ((i % 5) * 0.0014);
      value = (value + (monthlyContribution * 0.2)) * drift;
      points.add(_GrowthPoint(label: month.label, value: value));
    }

    return points;
  }

  BudgetPlan get _monthlyBudget {
    return seedBudgetPlans.firstWhere(
      (item) => item.cadence == 'Monthly',
      orElse: () => seedBudgetPlans.first,
    );
  }

  BudgetPlan get _weeklyBudget {
    return seedBudgetPlans.firstWhere(
      (item) => item.cadence == 'Weekly',
      orElse: () => seedBudgetPlans.last,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isWide = width >= 1024;

        return Scaffold(
          backgroundColor: _bgBottom,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            title: const Text(
              'Investments',
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
            ),
            actions: [
              IconButton(
                onPressed: () => _showMessage('No new investment alerts.'),
                tooltip: 'Investment alerts',
                icon: const Icon(Icons.notifications_none_rounded,
                    color: _textPrimary),
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
                    color: _lime.withOpacity(0.10),
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
                    color: _lime.withOpacity(0.08),
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
                child: Column(
                  children: [
                    Expanded(
                      child: IndexedStack(
                        index: _activeBottomIndex,
                        children: [
                          // Index 0: Home
                          SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              isWide ? 24 : 16,
                              8,
                              isWide ? 24 : 16,
                              12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildProfileRow(),
                                const SizedBox(height: 12),
                                _buildBalanceCard(),
                                const SizedBox(height: 12),
                                _buildQuickActions(),
                                const SizedBox(height: 14),
                                if (isWide)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          flex: 3, child: _buildHoldingsCard()),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          flex: 2, child: _buildGrowthCard()),
                                    ],
                                  )
                                else ...[
                                  _buildHoldingsCard(),
                                  const SizedBox(height: 12),
                                  _buildGrowthCard(),
                                ],
                                const SizedBox(height: 12),
                                if (isWide)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: _buildBudgetSnapshotCard()),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: _buildSavingsSnapshotCard()),
                                    ],
                                  )
                                else ...[
                                  _buildBudgetSnapshotCard(),
                                  const SizedBox(height: 12),
                                  _buildSavingsSnapshotCard(),
                                ],
                              ],
                            ),
                          ),
                          // Index 1: Invest (Mutual Funds)
                          SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              isWide ? 24 : 16,
                              8,
                              isWide ? 24 : 16,
                              12,
                            ),
                            child: const MutualFundsContent(),
                          ),
                          // Index 2: Goals
                          SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              isWide ? 24 : 16,
                              8,
                              isWide ? 24 : 16,
                              12,
                            ),
                            child: const UserGoalsContent(),
                          ),
                          // Index 3: History
                          SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              isWide ? 24 : 16,
                              8,
                              isWide ? 24 : 16,
                              12,
                            ),
                            child: const InvestmentHistoryContent(),
                          ),
                        ],
                      ),
                    ),
                    _buildBottomNav(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileRow() {
    return Row(
      children: [
        CircleAvatar(
          radius: 19,
          backgroundColor: _lime,
          child: Text(
            seededUserProfile.name.substring(0, 1),
            style: const TextStyle(
              color: _bgBottom,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Growth Portfolio',
                style: TextStyle(
                  color: _textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                seededUserProfile.name,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        _iconBubble(Icons.qr_code_scanner_rounded),
        const SizedBox(width: 8),
        _iconBubble(Icons.settings_outlined),
      ],
    );
  }

  Widget _iconBubble(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _lime.withOpacity(0.18)),
      ),
      child: Icon(icon, size: 18, color: _textPrimary),
    );
  }

  Widget _buildBalanceCard() {
    final up = _portfolioReturnAmount >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _lime,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _lime.withOpacity(0.34),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(
                  color: Color(0xFF2A4600),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Icon(Icons.more_horiz_rounded,
                  color: const Color(0xFF2A4600).withOpacity(0.8)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _money(_portfolioCurrent, decimals: 2),
            style: const TextStyle(
              color: Color(0xFF102A00),
              fontWeight: FontWeight.w900,
              fontSize: 34,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${up ? '+' : ''}${_portfolioReturnPercent.toStringAsFixed(2)}% this month',
              style: const TextStyle(
                color: Color(0xFF234300),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Risk Profile: $_riskLabel (${_riskScore.toStringAsFixed(1)}/3)',
            style: const TextStyle(
              color: Color(0xFF2A4600),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return _darkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _actionButton(Icons.north_east_rounded, 'Send')),
              const SizedBox(width: 8),
              Expanded(
                  child: _actionButton(Icons.call_received_rounded, 'Request')),
              const SizedBox(width: 8),
              Expanded(
                child: _actionButton(Icons.auto_graph_rounded, 'Rebalance'),
              ),
              const SizedBox(width: 8),
              Expanded(
                  child: _actionButton(Icons.payments_outlined, 'Withdraw')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return InkWell(
      onTap: () => _showMessage('$label tools will be available soon.'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _cardDeep,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _lime.withOpacity(0.16)),
        ),
        child: Column(
          children: [
            Icon(icon, color: _lime, size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoldingsCard() {
    final holdings = List<InvestmentHolding>.from(seedInvestmentHoldings)
      ..sort((a, b) => b.currentValue.compareTo(a.currentValue));

    return _darkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Holdings',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showMessage('Opening all holdings...'),
                child: const Text(
                  'View all',
                  style: TextStyle(color: _lime),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...holdings.map((item) {
            final weight = _portfolioCurrent == 0
                ? 0.0
                : (item.currentValue / _portfolioCurrent).clamp(0.0, 1.0);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cardDeep,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _lime.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.assetName,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${item.returnPercent.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: item.returnAmount >= 0
                              ? _limeSoft
                              : const Color(0xFFE67A62),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${item.assetType} | ${item.riskLevel} risk | ${_money(item.currentValue)}',
                    style: const TextStyle(
                      color: _textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: weight,
                      minHeight: 7,
                      backgroundColor: Colors.black.withOpacity(0.25),
                      valueColor: const AlwaysStoppedAnimation<Color>(_lime),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGrowthCard() {
    final growth = (_apiPoints != null && _apiPoints!.isNotEmpty)
        ? _apiPoints!
        : _growthSeries;

    final minValue = growth.isEmpty
        ? 0.0
        : growth.map((item) => item.value).reduce(math.min);
    final maxValue = growth.isEmpty
        ? 1.0
        : growth.map((item) => item.value).reduce(math.max);

    return _darkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Growth Trend',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              const Spacer(),
              if (_isLoadingChart)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(_lime),
                  ),
                )
              else if (_apiPoints != null && _apiPoints!.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _lime.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _lime.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: _lime,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Stock search bar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: _cardDeep,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _lime.withOpacity(0.22)),
                  ),
                  child: TextField(
                    controller: _stockController,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Nifty 50, Tata Steel...',
                      hintStyle: TextStyle(
                        color: _textMuted,
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: _lime,
                        size: 18,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                    ),
                    onSubmitted: (val) {
                      final trimmed = val.trim();
                      if (trimmed.isNotEmpty) {
                        setState(() => _stockName = trimmed);
                        _fetchHistoricalData();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  final val = _stockController.text.trim();
                  if (val.isNotEmpty) {
                    setState(() => _stockName = val);
                    _fetchHistoricalData();
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: _lime,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: _bgBottom,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Range chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _rangeOptions.map((item) {
              final selected = item == _selectedRange;
              return ChoiceChip(
                label: Text(item),
                selected: selected,
                onSelected: (_) {
                  setState(() => _selectedRange = item);
                  _fetchHistoricalData();
                },
                selectedColor: _lime,
                backgroundColor: _cardDeep,
                side: BorderSide(color: _lime.withOpacity(0.18)),
                labelStyle: TextStyle(
                  color: selected ? _bgBottom : _textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Error banner
          if (_apiError != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE67A62).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFFE67A62).withOpacity(0.28)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFE67A62), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _apiError!,
                      style: const TextStyle(
                        color: Color(0xFFE67A62),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Chart
          SizedBox(
            height: 190,
            child: _isLoadingChart
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_lime),
                    ),
                  )
                : growth.length < 2
                    ? const Center(
                        child: Text(
                          'Not enough data points',
                          style: TextStyle(color: _textMuted),
                        ),
                      )
                    : CustomPaint(
                        size: Size.infinite,
                        painter: _NeonGrowthPainter(
                          points: growth,
                          minValue: minValue,
                          maxValue: maxValue,
                          lineColor: _lime,
                        ),
                      ),
          ),
          const SizedBox(height: 8),
          // High / Low
          Text(
            'High ${_money(maxValue)}   \u2022   Low ${_money(minValue)}',
            style: const TextStyle(
              color: _textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSnapshotCard() {
    return _darkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Budgeting Snapshot',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 10),
          _budgetTile(_monthlyBudget),
          const SizedBox(height: 8),
          _budgetTile(_weeklyBudget),
        ],
      ),
    );
  }

  Widget _budgetTile(BudgetPlan plan) {
    final nearLimit = plan.utilization >= 0.9;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardDeep,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _lime.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${plan.cadence} Budget',
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${(plan.utilization * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: nearLimit ? const Color(0xFFE67A62) : _lime,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${_money(plan.totalSpent)} of ${_money(plan.totalLimit)}',
            style: const TextStyle(
              color: _textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: plan.utilization.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.black.withOpacity(0.24),
              valueColor: AlwaysStoppedAnimation<Color>(
                nearLimit ? const Color(0xFFE67A62) : _lime,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsSnapshotCard() {
    final goals = List<SavingsGoal>.from(seedSavingsGoals)
      ..sort((a, b) => b.progress.compareTo(a.progress));

    return _darkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Savings Goals',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 10),
          ...goals.take(3).map((goal) {
            final progress = goal.progress.clamp(0.0, 1.0).toDouble();
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cardDeep,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _lime.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          goal.name,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: _lime,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_money(goal.currentAmount)} / ${_money(goal.targetAmount)}',
                    style: const TextStyle(
                      color: _textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.black.withOpacity(0.24),
                      valueColor: const AlwaysStoppedAnimation<Color>(_lime),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Auto transfer ${_money(goal.suggestedAutoTransfer)} / month',
                    style: const TextStyle(
                      color: _textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _darkCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _lime.withOpacity(0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildBottomNav() {
    final items = const [
      _BottomNavItem(icon: Icons.home_outlined, label: 'Home'),
      _BottomNavItem(icon: Icons.candlestick_chart_rounded, label: 'Invest'),
      _BottomNavItem(icon: Icons.savings_outlined, label: 'Goals'),
      _BottomNavItem(icon: Icons.history_rounded, label: 'History'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _lime.withOpacity(0.16)),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final selected = index == _activeBottomIndex;
          final item = items[index];

          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() => _activeBottomIndex = index);
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color:
                      selected ? _lime.withOpacity(0.20) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 19,
                      color: selected ? _lime : _textMuted,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: selected ? _lime : _textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _GrowthPoint {
  const _GrowthPoint({required this.label, required this.value});

  final String label;
  final double value;
}

class _BottomNavItem {
  const _BottomNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _NeonGrowthPainter extends CustomPainter {
  _NeonGrowthPainter({
    required this.points,
    required this.minValue,
    required this.maxValue,
    required this.lineColor,
  });

  final List<_GrowthPoint> points;
  final double minValue;
  final double maxValue;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }

    final leftPadding = 10.0;
    final topPadding = 10.0;
    final chartWidth = size.width - (leftPadding * 2);
    final chartHeight = size.height - (topPadding * 2);

    final diff = (maxValue - minValue).abs() < 1 ? 1.0 : (maxValue - minValue);

    Offset pointOffset(int index) {
      final x = leftPadding + (chartWidth * (index / (points.length - 1)));
      final normalized = (points[index].value - minValue) / diff;
      final y = topPadding + ((1 - normalized) * chartHeight);
      return Offset(x, y);
    }

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final y = topPadding + ((chartHeight / 4) * i);
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - leftPadding, y),
        gridPaint,
      );
    }

    final linePath = Path()..moveTo(pointOffset(0).dx, pointOffset(0).dy);
    for (int i = 1; i < points.length; i++) {
      final current = pointOffset(i);
      final previous = pointOffset(i - 1);
      final controlX = (previous.dx + current.dx) / 2;
      linePath.cubicTo(
        controlX,
        previous.dy,
        controlX,
        current.dy,
        current.dx,
        current.dy,
      );
    }

    final fillPath = Path.from(linePath)
      ..lineTo(pointOffset(points.length - 1).dx, size.height - topPadding)
      ..lineTo(pointOffset(0).dx, size.height - topPadding)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [lineColor.withOpacity(0.26), lineColor.withOpacity(0.02)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    final glowPaint = Paint()
      ..color = lineColor.withOpacity(0.35)
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7)
      ..style = PaintingStyle.stroke;
    canvas.drawPath(linePath, glowPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke;
    canvas.drawPath(linePath, linePaint);

    final dotPaint = Paint()..color = lineColor;
    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(pointOffset(i), 2.7, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _NeonGrowthPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.minValue != minValue ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.lineColor != lineColor;
  }
}
