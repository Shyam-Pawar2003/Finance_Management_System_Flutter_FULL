import 'package:flutter/material.dart';

import '../../data/dashboard_seed_data.dart';

// ── Standalone page (Navigator.push usage) ───────────────────────────────────
class InvestmentHistoryPage extends StatelessWidget {
  const InvestmentHistoryPage({super.key});

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
          'Investment History',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                _showMessage(context, 'Search and filters are coming soon.'),
            icon: const Icon(Icons.search_rounded, color: _textPrimary),
          ),
          IconButton(
            onPressed: () =>
                _showMessage(context, 'Export statement will open soon.'),
            icon: const Icon(Icons.file_download_outlined, color: _textPrimary),
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
              child: InvestmentHistoryContent(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Embeddable content widget (no Scaffold / AppBar) ─────────────────────────
class InvestmentHistoryContent extends StatefulWidget {
  const InvestmentHistoryContent({super.key});

  @override
  State<InvestmentHistoryContent> createState() =>
      _InvestmentHistoryContentState();
}

class _InvestmentHistoryContentState extends State<InvestmentHistoryContent>
    with SingleTickerProviderStateMixin {
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  static const List<String> _filters = [
    'All',
    'Buy',
    'Sell',
    'Dividend',
    'SIP',
    'Rebalance',
  ];

  final List<_HistoryCollection> _collections = const [
    _HistoryCollection(name: 'Buys', icon: Icons.north_east_rounded),
    _HistoryCollection(name: 'Sells', icon: Icons.south_west_rounded),
    _HistoryCollection(name: 'Dividends', icon: Icons.payments_outlined),
    _HistoryCollection(name: 'SIP', icon: Icons.calendar_month_rounded),
    _HistoryCollection(name: 'Tax', icon: Icons.receipt_long_rounded),
    _HistoryCollection(
        name: 'Fees', icon: Icons.account_balance_wallet_rounded),
  ];

  late TabController _tabController;
  late final List<_HistoryTransaction> _transactions;
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _transactions = _buildSeedTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_HistoryTransaction> _buildSeedTransactions() {
    final now = DateTime.now();

    return [
      _HistoryTransaction(
        timestamp: now.subtract(const Duration(hours: 2)),
        title: 'Bought NIFTY 50 ETF',
        subtitle: 'NSE • 12 units',
        action: 'Buy',
        status: 'Completed',
        amount: -5000,
        icon: Icons.north_east_rounded,
      ),
      _HistoryTransaction(
        timestamp: now.subtract(const Duration(hours: 6)),
        title: 'Dividend Received',
        subtitle: 'S&P 500 ETF',
        action: 'Dividend',
        status: 'Completed',
        amount: 1250,
        icon: Icons.payments_rounded,
      ),
      _HistoryTransaction(
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
        title: 'Sold Gold Fund',
        subtitle: 'Partial exit',
        action: 'Sell',
        status: 'Completed',
        amount: 2500,
        icon: Icons.south_west_rounded,
      ),
      _HistoryTransaction(
        timestamp: now.subtract(const Duration(days: 1, hours: 7)),
        title: 'SIP Auto Debit',
        subtitle: 'Large Cap Growth',
        action: 'SIP',
        status: 'Completed',
        amount: -3000,
        icon: Icons.repeat_rounded,
      ),
      _HistoryTransaction(
        timestamp: now.subtract(const Duration(days: 2, hours: 2)),
        title: 'Portfolio Rebalanced',
        subtitle: 'Across 3 holdings',
        action: 'Rebalance',
        status: 'Completed',
        amount: 0,
        icon: Icons.balance_rounded,
      ),
      _HistoryTransaction(
        timestamp: now.subtract(const Duration(days: 2, hours: 5)),
        title: 'Bought Midcap Fund',
        subtitle: 'Lumpsum order',
        action: 'Buy',
        status: 'Completed',
        amount: -3800,
        icon: Icons.north_east_rounded,
      ),
      _HistoryTransaction(
        timestamp: now.subtract(const Duration(days: 3, hours: 1)),
        title: 'Sold Banking ETF',
        subtitle: 'Order executed',
        action: 'Sell',
        status: 'Completed',
        amount: 6100,
        icon: Icons.south_west_rounded,
      ),
      _HistoryTransaction(
        timestamp: now.subtract(const Duration(days: 3, hours: 8)),
        title: 'SIP Auto Debit',
        subtitle: 'Flexi Cap Fund',
        action: 'SIP',
        status: 'Completed',
        amount: -2200,
        icon: Icons.repeat_rounded,
      ),
      _HistoryTransaction(
        timestamp: now.subtract(const Duration(days: 4, hours: 4)),
        title: 'Brokerage Fee',
        subtitle: 'Trade settlement',
        action: 'Fee',
        status: 'Completed',
        amount: -120,
        icon: Icons.receipt_long_rounded,
      ),
      _HistoryTransaction(
        timestamp: now.subtract(const Duration(days: 5, hours: 2)),
        title: 'Dividend Received',
        subtitle: 'Global Tech Mutual Fund',
        action: 'Dividend',
        status: 'Completed',
        amount: 640,
        icon: Icons.payments_rounded,
      ),
    ];
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

  String _signedMoney(double amount, {int decimals = 0}) {
    if (amount == 0) {
      return _money(amount, decimals: decimals);
    }

    final sign = amount > 0 ? '+' : '-';
    return '$sign${_money(amount.abs(), decimals: decimals)}';
  }

  String _timeLabel(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final meridiem = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $meridiem';
  }

  String _dayLabel(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final diff = today.difference(date).inDays;

    if (diff == 0) {
      return 'Today';
    }
    if (diff == 1) {
      return 'Yesterday';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return _lime;
      case 'Pending':
        return const Color(0xFFFBBF24);
      default:
        return const Color(0xFFE67A62);
    }
  }

  Color _amountColor(double amount) {
    if (amount > 0) {
      return _lime;
    }
    if (amount < 0) {
      return const Color(0xFFE67A62);
    }
    return _textMuted;
  }

  List<_HistoryTransaction> get _visibleTransactions {
    final filtered = _selectedFilter == 0
        ? List<_HistoryTransaction>.from(_transactions)
        : _transactions
            .where((item) =>
                item.action.toLowerCase() ==
                _filters[_selectedFilter].toLowerCase())
            .toList();

    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return filtered;
  }

  double get _totalInflow => _transactions
      .where((item) => item.amount > 0)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get _totalOutflow => _transactions
      .where((item) => item.amount < 0)
      .fold(0.0, (sum, item) => sum + item.amount.abs());

  double get _netFlow => _totalInflow - _totalOutflow;

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final highlights = _visibleTransactions.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'Investment History',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
        ),
        _buildTabBar(),
        const SizedBox(height: 20),
        _buildSummaryCard(),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            GestureDetector(
              onTap: () => _showMessage('Opening complete history...'),
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
            itemCount: highlights.length,
            itemBuilder: (_, i) => Padding(
              padding:
                  EdgeInsets.only(right: i < highlights.length - 1 ? 12 : 0),
              child: _buildHighlightCard(highlights[i]),
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
        _buildAllTransactionsSection(),
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
          Tab(text: 'Logs'),
          Tab(text: 'Statements'),
        ],
        labelColor: _textPrimary,
        unselectedLabelColor: _textMuted,
        indicatorColor: _lime,
        indicatorWeight: 3,
      ),
    );
  }

  Widget _buildSummaryCard() {
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
                  'Track every transaction in one timeline',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _signedMoney(_netFlow, decimals: 0),
                  style: TextStyle(
                    color: _amountColor(_netFlow),
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_transactions.length} total entries',
                  style: const TextStyle(
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _statChip(Icons.north_east_rounded,
                        'Inflow ${_money(_totalInflow, decimals: 0)}'),
                    _statChip(Icons.south_west_rounded,
                        'Outflow ${_money(_totalOutflow, decimals: 0)}'),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _showMessage('Export statement started.'),
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
                    'Export Statement',
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
              Icons.receipt_long_rounded,
              size: 40,
              color: Color(0xFF1EDC78),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String text) {
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

  Widget _buildHighlightCard(_HistoryTransaction tx) {
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
            child: Icon(
              tx.icon,
              color: _amountColor(tx.amount),
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              tx.title,
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
            _signedMoney(tx.amount, decimals: 0),
            style: TextStyle(
              color: _amountColor(tx.amount),
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          Text(
            _dayLabel(tx.timestamp),
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

  Widget _buildCollectionIcon(_HistoryCollection collection) {
    return GestureDetector(
      onTap: () => _showMessage('Opening ${collection.name} collection...'),
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

  Widget _buildToolsRow() {
    final tools = [
      ('Export', Icons.file_download_outlined),
      ('Filter', Icons.tune_rounded),
      ('Tax report', Icons.request_page_outlined),
      ('Alerts', Icons.notifications_active_outlined),
      ('Compare', Icons.compare_arrows_rounded),
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
            child: GestureDetector(
              onTap: () => _showMessage('$label tools are coming soon.'),
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
                    width: 72,
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

  Widget _buildAllTransactionsSection() {
    final items = _visibleTransactions;
    final grouped = <String, List<_HistoryTransaction>>{};

    for (final tx in items) {
      final key = _dayLabel(tx.timestamp);
      grouped.putIfAbsent(key, () => <_HistoryTransaction>[]).add(tx);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Transactions',
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
              _filters.length,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(_filters[i]),
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
              '${items.length} entries',
              style: const TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const Text(
              'Latest first',
              style: TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _lime.withOpacity(0.12)),
            ),
            child: const Text(
              'No transactions found in this category.',
              style: TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          )
        else
          ...grouped.entries.expand((entry) {
            final section = <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 8),
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ];

            section.addAll(entry.value.map(
              (tx) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildTransactionTile(tx),
              ),
            ));

            return section;
          }),
      ],
    );
  }

  Widget _buildTransactionTile(_HistoryTransaction tx) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _lime.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _cardDeep,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              tx.icon,
              color: _amountColor(tx.amount),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tx.subtitle,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(tx.status).withOpacity(0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        tx.status,
                        style: TextStyle(
                          color: _statusColor(tx.status),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${tx.action} • ${_timeLabel(tx.timestamp)}',
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _signedMoney(tx.amount, decimals: 0),
            style: TextStyle(
              color: _amountColor(tx.amount),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCollection {
  const _HistoryCollection({required this.name, required this.icon});

  final String name;
  final IconData icon;
}

class _HistoryTransaction {
  _HistoryTransaction({
    required this.timestamp,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.status,
    required this.amount,
    required this.icon,
  });

  final DateTime timestamp;
  final String title;
  final String subtitle;
  final String action;
  final String status;
  final double amount;
  final IconData icon;
}
