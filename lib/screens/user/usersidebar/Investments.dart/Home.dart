import 'package:flutter/material.dart';

import '../../data/dashboard_seed_data.dart';
import '../../models/dashboard_models.dart';

// ── Standalone page (Navigator.push usage) ───────────────────────────────────
class UserInvestmentsHomePage extends StatelessWidget {
  const UserInvestmentsHomePage({super.key});

  static const Color _bgTop = Color(0xFF0A1A08);
  static const Color _bgBottom = Color(0xFF050C04);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBottom,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Investment Home',
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
        ),
      ),
      body: Stack(
        children: [
          Positioned(top: -130, right: -80, child: _glow(280)),
          Positioned(bottom: -120, left: -70, child: _glow(220)),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_bgTop, _bgBottom],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          const SafeArea(child: UserInvestmentsHomeContent()),
        ],
      ),
    );
  }

  Widget _glow(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _lime.withOpacity(0.09),
        ),
      );
}

// ── Embeddable content widget (no Scaffold / AppBar) ─────────────────────────
// Used by UserInvestmentsHomePage and the Investments tab shell (IndexedStack).
class UserInvestmentsHomeContent extends StatelessWidget {
  const UserInvestmentsHomeContent({super.key});

  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

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
      if (reverseIndex > 1 && reverseIndex % 3 == 1) buffer.write(',');
    }
    final number =
        decimals > 0 ? '${buffer.toString()}.$decimal' : buffer.toString();
    return '${isNegative ? '-' : ''}$_currencySymbol$number';
  }

  double get _portfolioInvested => seedInvestmentHoldings.fold<double>(
        0,
        (s, h) => s + h.investedAmount,
      );

  double get _portfolioCurrent => seedInvestmentHoldings.fold<double>(
        0,
        (s, h) => s + h.currentValue,
      );

  double get _portfolioReturn => _portfolioCurrent - _portfolioInvested;

  double get _returnPercent {
    if (_portfolioInvested <= 0) return 0;
    return (_portfolioReturn / _portfolioInvested) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final isUp = _portfolioReturn >= 0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        return SingleChildScrollView(
          padding:
              EdgeInsets.fromLTRB(isWide ? 24 : 16, 8, isWide ? 24 : 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(isUp),
              const SizedBox(height: 12),
              if (isWide)
                Row(
                  children: [
                    Expanded(
                      child: _metricCard(
                        'Invested',
                        _money(_portfolioInvested),
                        Icons.account_balance_wallet_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _metricCard(
                        'Current',
                        _money(_portfolioCurrent),
                        Icons.candlestick_chart_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _metricCard(
                        'Return',
                        '${isUp ? '+' : ''}${_returnPercent.toStringAsFixed(2)}%',
                        isUp
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _metricCard(
                      'Invested',
                      _money(_portfolioInvested),
                      Icons.account_balance_wallet_outlined,
                    ),
                    const SizedBox(height: 10),
                    _metricCard(
                      'Current',
                      _money(_portfolioCurrent),
                      Icons.candlestick_chart_rounded,
                    ),
                    const SizedBox(height: 10),
                    _metricCard(
                      'Return',
                      '${isUp ? '+' : ''}${_returnPercent.toStringAsFixed(2)}%',
                      isUp
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              _buildHoldingsSummaryCard(),
              const SizedBox(height: 12),
              _buildTopAssetsCard(),
              const SizedBox(height: 12),
              _buildRiskSplitCard(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroCard(bool isUp) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _lime,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _lime.withOpacity(0.34),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Portfolio Snapshot',
            style: TextStyle(
              color: Color(0xFF2A4600),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _money(_portfolioCurrent, decimals: 2),
            style: const TextStyle(
              color: Color(0xFF102A00),
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${isUp ? '+' : ''}${_returnPercent.toStringAsFixed(2)}% total return',
              style: const TextStyle(
                color: Color(0xFF234300),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _lime.withOpacity(0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _cardDeep,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _lime, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingsSummaryCard() {
    final totalHoldings = seedInvestmentHoldings.length;
    final current = _portfolioCurrent;
    final invested = _portfolioInvested;
    final totalReturn = _portfolioReturn;
    final totalReturnPct = _returnPercent;

    // Daily movement is approximated because seed data has no explicit 1D change.
    final oneDayPct = (totalReturnPct / 14).clamp(-5.0, 5.0);
    final oneDayReturn = current * (oneDayPct / 100);

    Color gainColor(double value) =>
        value >= 0 ? _lime : const Color(0xFFE67A62);

    String signedMoney(double value, {int decimals = 2}) {
      final abs = _money(value.abs(), decimals: decimals);
      return '${value >= 0 ? '+' : '-'}$abs';
    }

    String signedPercent(double value) {
      return '${value >= 0 ? '+' : '-'}${value.abs().toStringAsFixed(2)}%';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _lime.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'HOLDINGS ($totalHoldings)',
                style: const TextStyle(
                  color: _textMuted,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  color: _textMuted, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _money(current, decimals: 2),
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 38,
                    height: 1,
                  ),
                ),
              ),
              _circleIcon(Icons.remove_red_eye_outlined),
              const SizedBox(width: 8),
              _circleIcon(Icons.stacked_line_chart_rounded),
              const SizedBox(width: 8),
              _circleIcon(Icons.more_vert_rounded),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: _textMuted.withOpacity(0.20), height: 1),
          const SizedBox(height: 14),
          _holdingValueRow(
            label: '1D returns',
            value: signedMoney(oneDayReturn),
            percent: signedPercent(oneDayPct),
            valueColor: gainColor(oneDayReturn),
          ),
          const SizedBox(height: 10),
          _holdingValueRow(
            label: 'Total returns',
            value: signedMoney(totalReturn),
            percent: signedPercent(totalReturnPct),
            valueColor: gainColor(totalReturn),
          ),
          const SizedBox(height: 10),
          _holdingValueRow(
            label: 'Invested',
            value: _money(invested, decimals: 2),
            valueColor: _textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: _cardDeep,
        shape: BoxShape.circle,
        border: Border.all(color: _textMuted.withOpacity(0.20)),
      ),
      child: Icon(icon, color: _textMuted, size: 20),
    );
  }

  Widget _holdingValueRow({
    required String label,
    required String value,
    String? percent,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textMuted,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          percent == null ? value : '$value ($percent)',
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildTopAssetsCard() {
    final holdings = List<InvestmentHolding>.from(seedInvestmentHoldings)
      ..sort((a, b) => b.currentValue.compareTo(a.currentValue));
    final top = holdings.take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _lime.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Assets',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 8),
          ...top.map((item) {
            final up = item.returnAmount >= 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cardDeep,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _lime.withOpacity(0.10)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.assetName,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.assetType} | ${item.riskLevel} risk',
                          style: const TextStyle(
                            color: _textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _money(item.currentValue),
                        style: const TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${up ? '+' : ''}${item.returnPercent.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: up ? _lime : const Color(0xFFE67A62),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRiskSplitCard() {
    int low = 0, medium = 0, high = 0;
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _lime.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Risk Split',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 10),
          _riskRow('Low', low, const Color(0xFF4ADE80)),
          const SizedBox(height: 8),
          _riskRow('Medium', medium, const Color(0xFFFBBF24)),
          const SizedBox(height: 8),
          _riskRow('High', high, const Color(0xFFE67A62)),
        ],
      ),
    );
  }

  Widget _riskRow(String label, int count, Color color) {
    final total = seedInvestmentHoldings.length;
    final value = total == 0 ? 0.0 : count / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$label Risk',
              style: const TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '$count assets',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: Colors.black.withOpacity(0.24),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
