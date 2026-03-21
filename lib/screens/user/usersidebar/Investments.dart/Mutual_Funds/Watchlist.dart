import 'package:flutter/material.dart';

class MutualFundWatchlistTab extends StatefulWidget {
  const MutualFundWatchlistTab({
    super.key,
    required this.onMessage,
  });

  final ValueChanged<String> onMessage;

  @override
  State<MutualFundWatchlistTab> createState() => _MutualFundWatchlistTabState();
}

class _MutualFundWatchlistTabState extends State<MutualFundWatchlistTab> {
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);
  static const Color _red = Color(0xFFE67A62);

  final TextEditingController _searchController = TextEditingController();

  final List<_WatchFund> _funds = [
    const _WatchFund(
      name: 'Parag Parikh Flexi Cap',
      nav: 72.24,
      oneDayChange: 0.44,
      alertEnabled: true,
    ),
    const _WatchFund(
      name: 'Bandhan Small Cap Growth',
      nav: 49.72,
      oneDayChange: -0.31,
      alertEnabled: false,
    ),
    const _WatchFund(
      name: 'Nifty 50 Index Direct',
      nav: 38.55,
      oneDayChange: 0.18,
      alertEnabled: true,
    ),
    const _WatchFund(
      name: 'HDFC Mid Cap Opportunities',
      nav: 61.19,
      oneDayChange: 0.59,
      alertEnabled: false,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_WatchFund> get _visibleFunds {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _funds;
    }
    return _funds.where((fund) {
      return fund.name.toLowerCase().contains(query);
    }).toList();
  }

  void _toggleAlert(int index) {
    final current = _funds[index];
    setState(() {
      _funds[index] = current.copyWith(alertEnabled: !current.alertEnabled);
    });
    widget.onMessage(
      current.alertEnabled
          ? 'Alert disabled for ${current.name}.'
          : 'Alert enabled for ${current.name}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleFunds = _visibleFunds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _lime.withOpacity(0.14)),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: 'Search watchlist fund',
              hintStyle: TextStyle(color: _textMuted.withOpacity(0.70)),
              prefixIcon: const Icon(Icons.search_rounded, color: _lime),
              filled: true,
              fillColor: _cardDeep,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _lime.withOpacity(0.16)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _lime.withOpacity(0.38)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Text(
              'Watchlist',
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            Text(
              '${visibleFunds.length} funds',
              style: const TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (visibleFunds.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _lime.withOpacity(0.12)),
            ),
            child: const Text(
              'No funds matched your search.',
              style: TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          ...List.generate(visibleFunds.length, (visibleIndex) {
            final fund = visibleFunds[visibleIndex];
            final index = _funds.indexOf(fund);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _cardDeep,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.remove_red_eye_outlined,
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
                            fund.name,
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
                            'NAV \$${fund.nav.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: _textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${fund.oneDayChange >= 0 ? '+' : ''}${fund.oneDayChange.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: fund.oneDayChange >= 0 ? _lime : _red,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _toggleAlert(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: fund.alertEnabled
                                  ? _lime.withOpacity(0.20)
                                  : _cardDeep,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: fund.alertEnabled
                                    ? _lime.withOpacity(0.40)
                                    : _lime.withOpacity(0.16),
                              ),
                            ),
                            child: Text(
                              fund.alertEnabled ? 'Alert On' : 'Alert Off',
                              style: TextStyle(
                                color: fund.alertEnabled ? _lime : _textMuted,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _WatchFund {
  const _WatchFund({
    required this.name,
    required this.nav,
    required this.oneDayChange,
    required this.alertEnabled,
  });

  final String name;
  final double nav;
  final double oneDayChange;
  final bool alertEnabled;

  _WatchFund copyWith({
    String? name,
    double? nav,
    double? oneDayChange,
    bool? alertEnabled,
  }) {
    return _WatchFund(
      name: name ?? this.name,
      nav: nav ?? this.nav,
      oneDayChange: oneDayChange ?? this.oneDayChange,
      alertEnabled: alertEnabled ?? this.alertEnabled,
    );
  }
}
