import 'package:flutter/material.dart';

import '../../user_dashboard.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  static const Color _bgTop = Color(0xFF0A1A08);
  static const Color _bgBottom = Color(0xFF050C04);
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  final TextEditingController _searchController = TextEditingController();
  final List<String> _filterLabels = ['All', 'Income', 'Expense', 'Transfers'];

  String _selectedFilter = 'All';

  final List<_TransactionItem> _transactions = [
    _TransactionItem(
      title: 'Salary Deposit',
      subtitle: 'Monthly salary',
      amount: 45000,
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFFC8F24A),
      dateLabel: 'Today • 9:30 AM',
      type: 'Income',
    ),
    _TransactionItem(
      title: 'Electricity Bill',
      subtitle: 'Power consumption',
      amount: 3450,
      icon: Icons.flash_on_rounded,
      color: Color(0xFFEF5350),
      dateLabel: 'Today • 2:15 PM',
      type: 'Expense',
    ),
    _TransactionItem(
      title: 'Mutual Fund SIP',
      subtitle: 'HDFC Flexi Cap',
      amount: 5000,
      icon: Icons.trending_up_rounded,
      color: Color(0xFF5B6FFF),
      dateLabel: 'Yesterday • 10:00 AM',
      type: 'Expense',
    ),
    _TransactionItem(
      title: 'Wallet to Bank Transfer',
      subtitle: 'Internal transfer',
      amount: 2500,
      icon: Icons.compare_arrows_rounded,
      color: Color(0xFF29B6F6),
      dateLabel: 'Mar 15 • 4:10 PM',
      type: 'Transfers',
    ),
    _TransactionItem(
      title: 'Dividend Credit',
      subtitle: 'Stock dividend',
      amount: 1240,
      icon: Icons.monetization_on_rounded,
      color: Color(0xFFC8F24A),
      dateLabel: 'Mar 14 • 4:45 PM',
      type: 'Income',
    ),
    _TransactionItem(
      title: 'Restaurant',
      subtitle: 'Dinner with friends',
      amount: 2100,
      icon: Icons.restaurant_rounded,
      color: Color(0xFFE91E63),
      dateLabel: 'Mar 13 • 9:00 PM',
      type: 'Expense',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_TransactionItem> get _filteredTransactions {
    final query = _searchController.text.trim().toLowerCase();

    return _transactions.where((txn) {
      final filterMatch =
          _selectedFilter == 'All' ? true : txn.type == _selectedFilter;

      if (!filterMatch) return false;
      if (query.isEmpty) return true;

      return txn.title.toLowerCase().contains(query) ||
          txn.subtitle.toLowerCase().contains(query) ||
          txn.type.toLowerCase().contains(query);
    }).toList();
  }

  double get _totalIncome {
    return _transactions
        .where((item) => item.type == 'Income')
        .fold<double>(0, (sum, item) => sum + item.amount);
  }

  double get _totalExpense {
    return _transactions
        .where((item) => item.type == 'Expense')
        .fold<double>(0, (sum, item) => sum + item.amount);
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  void _exportTransactions() {
    _showMessage('Exported ${_filteredTransactions.length} transactions.');
  }

  Future<void> _handleBack() async {
    final popped = await Navigator.maybePop(context);
    if (!popped && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const UserDashboard()),
      );
    }
  }

  String _money(double amount, {bool signed = false, bool isIncome = false}) {
    final rounded = amount.toStringAsFixed(0);
    final parts = rounded.split('');
    final output = StringBuffer();

    for (int i = 0; i < parts.length; i++) {
      final reverseIndex = parts.length - i;
      output.write(parts[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        output.write(',');
      }
    }

    final prefix = signed ? (isIncome ? '+' : '-') : '';
    return '${prefix}INR ${output.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBottom,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Transactions',
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          onPressed: _handleBack,
          icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: _exportTransactions,
            tooltip: 'Export list',
            icon: const Icon(Icons.download_rounded, color: _textPrimary),
          ),
          const SizedBox(width: 6),
        ],
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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(),
                  const SizedBox(height: 20),
                  _buildTipCard(),
                  const SizedBox(height: 14),
                  _buildSearchBar(),
                  const SizedBox(height: 14),
                  _buildFilterTabs(),
                  const SizedBox(height: 18),
                  _buildTransactionsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _lime.withOpacity(0.09),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Spent',
            amount: _money(_totalExpense),
            subtitle: 'This month',
            icon: Icons.trending_down_rounded,
            color: Colors.red.shade400,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Total Income',
            amount: _money(_totalIncome),
            subtitle: 'This month',
            icon: Icons.trending_up_rounded,
            color: _lime,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String amount,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _lime.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: _textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _lime.withOpacity(0.12)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: _textPrimary),
        decoration: InputDecoration(
          hintText: 'Search by title, category, or type',
          hintStyle: const TextStyle(color: _textMuted),
          prefixIcon: const Icon(Icons.search_rounded, color: _textMuted),
          suffixIcon: _searchController.text.trim().isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.close_rounded, color: _textMuted),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _lime.withOpacity(0.12)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: _lime, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tip: use filters to quickly separate income and expense entries before exporting.',
              style: TextStyle(
                color: _textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filterLabels
            .map(
              (label) => Padding(
                padding: EdgeInsets.only(
                  right: label == _filterLabels.last ? 0 : 8,
                ),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedFilter = label),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedFilter == label ? _lime : _cardDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _selectedFilter == label
                            ? _lime
                            : _lime.withOpacity(0.12),
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color:
                            _selectedFilter == label ? _bgBottom : _textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildTransactionsList() {
    final visibleItems = _filteredTransactions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _lime.withOpacity(0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${visibleItems.length}',
                style: const TextStyle(
                  color: _lime,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (visibleItems.isEmpty) _buildEmptyState(),
        ...visibleItems.map(
          (txn) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildTransactionTile(txn),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _lime.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            color: _textMuted.withOpacity(0.75),
            size: 36,
          ),
          const SizedBox(height: 10),
          const Text(
            'No transactions match your search.',
            style: TextStyle(
              color: _textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFilter = 'All';
                _searchController.clear();
              });
            },
            child: const Text('Clear filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(_TransactionItem txn) {
    final isIncome = txn.type == 'Income';
    final amountText = _money(txn.amount, signed: true, isIncome: isIncome);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _lime.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: txn.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(txn.icon, color: txn.color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  txn.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
                        color: txn.color.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        txn.type,
                        style: TextStyle(
                          color: txn.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      txn.dateLabel,
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amountText,
            style: TextStyle(
              color: isIncome ? _lime : txn.color,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionItem {
  const _TransactionItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.color,
    required this.dateLabel,
    required this.type,
  });

  final String title;
  final String subtitle;
  final double amount;
  final IconData icon;
  final Color color;
  final String dateLabel;
  final String type;
}
