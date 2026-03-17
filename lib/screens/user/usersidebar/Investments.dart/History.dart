import 'package:flutter/material.dart';

// ── Standalone page (Navigator.push usage) ───────────────────────────────────
class InvestmentHistoryPage extends StatelessWidget {
  const InvestmentHistoryPage({super.key});

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
          'Investment History',
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
          const SafeArea(child: InvestmentHistoryContent()),
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
class InvestmentHistoryContent extends StatelessWidget {
  const InvestmentHistoryContent({super.key});

  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Section
          const Text(
            'Transaction History',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          // Sample Transaction List
          ..._buildTransactionList(),
        ],
      ),
    );
  }

  List<Widget> _buildTransactionList() {
    final transactions = [
      {
        'date': 'Today • 2:30 PM',
        'title': 'Bought NIFTY 50 ETF',
        'amount': '+₹5,000',
        'icon': Icons.trending_up_rounded,
        'isPositive': true,
      },
      {
        'date': 'Yesterday • 10:15 AM',
        'title': 'Sold Gold Fund',
        'amount': '-₹2,500',
        'icon': Icons.trending_down_rounded,
        'isPositive': false,
      },
      {
        'date': 'Mar 15 • 3:45 PM',
        'title': 'Dividend Received',
        'amount': '+₹1,250',
        'icon': Icons.monetization_on_rounded,
        'isPositive': true,
      },
      {
        'date': 'Mar 14 • 9:20 AM',
        'title': 'Rebalanced Portfolio',
        'amount': '+₹3,800',
        'icon': Icons.balance_rounded,
        'isPositive': true,
      },
      {
        'date': 'Mar 13 • 4:10 PM',
        'title': 'Bought Mutual Fund',
        'amount': '+₹10,000',
        'icon': Icons.trending_up_rounded,
        'isPositive': true,
      },
    ];

    return transactions.map((txn) => _buildTransactionTile(txn)).toList();
  }

  Widget _buildTransactionTile(Map<String, dynamic> txn) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _lime.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _cardDeep,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              txn['icon'] as IconData,
              color: txn['isPositive'] ? _lime : Colors.red.shade400,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Title & Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn['title'] as String,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  txn['date'] as String,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            txn['amount'] as String,
            style: TextStyle(
              color: txn['isPositive'] ? _lime : Colors.red.shade400,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
