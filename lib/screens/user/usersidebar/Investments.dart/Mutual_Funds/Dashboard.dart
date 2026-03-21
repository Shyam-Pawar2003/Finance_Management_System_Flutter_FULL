import 'package:flutter/material.dart';

class MutualFundDashboardTab extends StatelessWidget {
  const MutualFundDashboardTab({
    super.key,
    required this.onMessage,
  });

  final ValueChanged<String> onMessage;

  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  static const List<_Holding> _holdings = [
    _Holding(
      name: 'HDFC Mid Cap Opportunities',
      invested: 180000,
      current: 232400,
      monthlySIP: 6000,
      risk: 'Moderate',
    ),
    _Holding(
      name: 'Parag Parikh Flexi Cap',
      invested: 125000,
      current: 149600,
      monthlySIP: 4500,
      risk: 'Moderate',
    ),
    _Holding(
      name: 'Bandhan Small Cap Growth',
      invested: 95000,
      current: 121300,
      monthlySIP: 3500,
      risk: 'High',
    ),
    _Holding(
      name: 'Nifty 50 Index Direct',
      invested: 160000,
      current: 188800,
      monthlySIP: 5000,
      risk: 'Low',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final invested = _holdings.fold<double>(0, (sum, h) => sum + h.invested);
    final current = _holdings.fold<double>(0, (sum, h) => sum + h.current);
    final monthlySip =
        _holdings.fold<double>(0, (sum, h) => sum + h.monthlySIP);
    final gain = current - invested;
    final gainPct = invested <= 0 ? 0 : (gain / invested) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _metricCard(
              title: 'Portfolio Value',
              value: _money(current),
              caption: '${gain >= 0 ? '+' : ''}${gainPct.toStringAsFixed(2)}%',
              captionColor: gain >= 0 ? _lime : const Color(0xFFE67A62),
              icon: Icons.account_balance_wallet_rounded,
            ),
            _metricCard(
              title: 'Total Invested',
              value: _money(invested),
              caption: 'Across ${_holdings.length} funds',
              captionColor: _textMuted,
              icon: Icons.savings_rounded,
            ),
            _metricCard(
              title: 'Monthly SIP',
              value: _money(monthlySip),
              caption: 'Auto debit enabled',
              captionColor: _textMuted,
              icon: Icons.calendar_month_rounded,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _lime.withOpacity(0.14)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Allocation Summary',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              ..._holdings.map((holding) {
                final weight = current <= 0 ? 0.0 : (holding.current / current);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              holding.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(weight * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: _textMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: weight,
                        minHeight: 7,
                        backgroundColor: _cardDeep,
                        valueColor: const AlwaysStoppedAnimation<Color>(_lime),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Top Holdings',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        ..._holdings.map((holding) {
          final fundGain = holding.current - holding.invested;
          final fundGainPct =
              holding.invested <= 0 ? 0 : (fundGain / holding.invested) * 100;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onMessage('${holding.name} details opened.'),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _lime.withOpacity(0.12)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _cardDeep,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.assessment_rounded,
                        color: _lime,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            holding.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${holding.risk} risk | SIP ${_money(holding.monthlySIP)}',
                            style: const TextStyle(
                              color: _textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _money(holding.current),
                          style: const TextStyle(
                            color: _textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${fundGainPct >= 0 ? '+' : ''}${fundGainPct.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: fundGainPct >= 0
                                ? _lime
                                : const Color(0xFFE67A62),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String caption,
    required Color captionColor,
    required IconData icon,
  }) {
    return SizedBox(
      width: 210,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _lime.withOpacity(0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: _lime, size: 20),
            const SizedBox(height: 8),
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
              style: const TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              caption,
              style: TextStyle(
                color: captionColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _money(double value) {
    final rounded = value.toStringAsFixed(0);
    final chars = rounded.split('');
    final out = StringBuffer();

    for (int i = 0; i < chars.length; i++) {
      final reverse = chars.length - i;
      out.write(chars[i]);
      if (reverse > 1 && reverse % 3 == 1) {
        out.write(',');
      }
    }

    return '\$${out.toString()}';
  }
}

class _Holding {
  const _Holding({
    required this.name,
    required this.invested,
    required this.current,
    required this.monthlySIP,
    required this.risk,
  });

  final String name;
  final double invested;
  final double current;
  final double monthlySIP;
  final String risk;
}
