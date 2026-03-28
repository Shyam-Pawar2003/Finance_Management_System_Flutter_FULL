import 'package:flutter/material.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String _selectedRange = '30D';
  String _selectedType = 'All';
  String _selectedStatus = 'All';
  String _selectedCategory = 'All';
  String _searchQuery = '';

  late final TextEditingController _searchController;

  static const List<String> _ranges = ['7D', '30D', '90D', '1Y'];
  static const List<String> _types = ['All', 'Income', 'Expense'];
  static const List<String> _statuses = [
    'All',
    'Completed',
    'Pending',
    'Failed'
  ];

  static const List<_TrendBar> _trend = [
    _TrendBar(month: 'Oct', income: 22400, expense: 15200),
    _TrendBar(month: 'Nov', income: 23600, expense: 16300),
    _TrendBar(month: 'Dec', income: 25200, expense: 17100),
    _TrendBar(month: 'Jan', income: 26800, expense: 18500),
    _TrendBar(month: 'Feb', income: 27950, expense: 19400),
    _TrendBar(month: 'Mar', income: 28700, expense: 20150),
  ];

  final List<_TransactionRecord> _transactions = const [
    _TransactionRecord(
      id: 'TRX-001',
      date: '2026-03-09',
      description: 'Invoice Payment',
      party: 'Apex Labs',
      category: 'Client Payment',
      paymentMethod: 'Bank Transfer',
      type: 'Income',
      status: 'Completed',
      amount: 5200,
      fee: 12,
    ),
    _TransactionRecord(
      id: 'TRX-002',
      date: '2026-03-09',
      description: 'Office Supplies',
      party: 'Workspace Mart',
      category: 'Operations',
      paymentMethod: 'Corporate Card',
      type: 'Expense',
      status: 'Completed',
      amount: 450,
      fee: 0,
    ),
    _TransactionRecord(
      id: 'TRX-003',
      date: '2026-03-08',
      description: 'Service Income',
      party: 'Northwind Co.',
      category: 'Consulting',
      paymentMethod: 'Wire',
      type: 'Income',
      status: 'Completed',
      amount: 3800,
      fee: 8,
    ),
    _TransactionRecord(
      id: 'TRX-004',
      date: '2026-03-08',
      description: 'Internet Bill',
      party: 'FiberCom',
      category: 'Utilities',
      paymentMethod: 'Auto Debit',
      type: 'Expense',
      status: 'Completed',
      amount: 120,
      fee: 0,
    ),
    _TransactionRecord(
      id: 'TRX-005',
      date: '2026-03-07',
      description: 'Consulting Retainer',
      party: 'BluePeak Ltd.',
      category: 'Consulting',
      paymentMethod: 'Bank Transfer',
      type: 'Income',
      status: 'Pending',
      amount: 2500,
      fee: 6,
    ),
    _TransactionRecord(
      id: 'TRX-006',
      date: '2026-03-07',
      description: 'Ad Campaign Spend',
      party: 'AdNetwork',
      category: 'Marketing',
      paymentMethod: 'Corporate Card',
      type: 'Expense',
      status: 'Pending',
      amount: 930,
      fee: 0,
    ),
    _TransactionRecord(
      id: 'TRX-007',
      date: '2026-03-06',
      description: 'Maintenance Contract',
      party: 'CoreOps Systems',
      category: 'Operations',
      paymentMethod: 'Wire',
      type: 'Expense',
      status: 'Completed',
      amount: 640,
      fee: 0,
    ),
    _TransactionRecord(
      id: 'TRX-008',
      date: '2026-03-06',
      description: 'License Renewal',
      party: 'CloudSuite',
      category: 'Software',
      paymentMethod: 'Corporate Card',
      type: 'Expense',
      status: 'Failed',
      amount: 310,
      fee: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _categories {
    final values = _transactions.map((t) => t.category).toSet().toList()
      ..sort();
    return ['All', ...values];
  }

  List<_TransactionRecord> get _filteredTransactions {
    final query = _searchQuery.trim().toLowerCase();
    return _transactions.where((transaction) {
      final matchesSearch = query.isEmpty ||
          transaction.id.toLowerCase().contains(query) ||
          transaction.description.toLowerCase().contains(query) ||
          transaction.party.toLowerCase().contains(query) ||
          transaction.paymentMethod.toLowerCase().contains(query);
      final matchesType =
          _selectedType == 'All' || transaction.type == _selectedType;
      final matchesStatus =
          _selectedStatus == 'All' || transaction.status == _selectedStatus;
      final matchesCategory = _selectedCategory == 'All' ||
          transaction.category == _selectedCategory;
      return matchesSearch && matchesType && matchesStatus && matchesCategory;
    }).toList();
  }

  double _totalIncome(List<_TransactionRecord> list) {
    return list
        .where((t) => t.type == 'Income')
        .fold(0, (sum, t) => sum + t.amount);
  }

  double _totalExpense(List<_TransactionRecord> list) {
    return list
        .where((t) => t.type == 'Expense')
        .fold(0, (sum, t) => sum + t.amount);
  }

  double _totalFees(List<_TransactionRecord> list) {
    return list.fold(0, (sum, t) => sum + t.fee);
  }

  int _countStatus(List<_TransactionRecord> list, String status) {
    return list.where((t) => t.status == status).length;
  }

  String _currency(double amount) {
    final isNegative = amount < 0;
    final value = amount.abs().round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      final reverseIndex = value.length - i;
      buffer.write(value[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return '${isNegative ? '-' : ''}\$${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 760;
        final isNarrow = width < 1140;
        final list = _filteredTransactions;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isCompact),
              const SizedBox(height: 18),
              _buildHeroCard(list),
              const SizedBox(height: 18),
              _buildKpiGrid(width, list),
              const SizedBox(height: 16),
              _buildTrendCard(),
              const SizedBox(height: 16),
              _buildFiltersCard(isCompact),
              const SizedBox(height: 16),
              if (isNarrow) ...[
                _buildTransactionsCard(list, isCompact),
                const SizedBox(height: 16),
                _buildSideInsights(list),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildTransactionsCard(list, false),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildSideInsights(list),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isCompact) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Transactions',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 6),
        Text(
          'Track money movement, fees, and settlement status in real time.',
          style: TextStyle(color: Color(0xFF5F6368)),
        ),
      ],
    );

    final controls = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _ranges
          .map(
            (range) => ChoiceChip(
              label: Text(range),
              selected: _selectedRange == range,
              onSelected: (_) {
                setState(() {
                  _selectedRange = range;
                });
              },
              selectedColor: const Color(0xFF1A73E8),
              labelStyle: TextStyle(
                color: _selectedRange == range
                    ? Colors.white
                    : const Color(0xFF334155),
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: _selectedRange == range
                    ? const Color(0xFF1A73E8)
                    : const Color(0xFFD5DEE9),
              ),
            ),
          )
          .toList(),
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, const SizedBox(height: 12), controls],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        const SizedBox(width: 14),
        controls,
      ],
    );
  }

  Widget _buildHeroCard(List<_TransactionRecord> list) {
    final income = _totalIncome(list);
    final expense = _totalExpense(list);
    final fees = _totalFees(list);
    final net = income - expense - fees;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF123A68), Color(0xFF1A73E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 14,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Net Cash Movement ($_selectedRange)',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currency(net),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _heroBadge('Incoming', _currency(income)),
              _heroBadge('Outgoing', _currency(expense)),
              _heroBadge('Fees', _currency(fees)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(double width, List<_TransactionRecord> list) {
    final cards = [
      _KpiData(
        title: 'Transactions',
        value: '${list.length}',
        subtitle: 'Filtered records',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF1A73E8),
      ),
      _KpiData(
        title: 'Completed',
        value: '${_countStatus(list, 'Completed')}',
        subtitle: 'Settled successfully',
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF0F9D58),
      ),
      _KpiData(
        title: 'Pending',
        value: '${_countStatus(list, 'Pending')}',
        subtitle: 'Awaiting settlement',
        icon: Icons.hourglass_bottom_rounded,
        color: const Color(0xFFF29900),
      ),
      _KpiData(
        title: 'Failed',
        value: '${_countStatus(list, 'Failed')}',
        subtitle: 'Need attention',
        icon: Icons.error_rounded,
        color: const Color(0xFFDB4437),
      ),
    ];

    final crossAxisCount = width >= 1280
        ? 4
        : width >= 860
            ? 2
            : 1;

    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 130,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];
        return _panel(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: card.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(card.icon, color: card.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      card.title,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      card.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendCard() {
    final maxIncome = _trend
        .map((item) => item.income)
        .fold<double>(0, (max, current) => current > max ? current : max);
    final maxExpense = _trend
        .map((item) => item.expense)
        .fold<double>(0, (max, current) => current > max ? current : max);
    final maxValue = maxIncome > maxExpense ? maxIncome : maxExpense;

    return _panel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction Trend',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Incoming vs outgoing movement in recent months',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              _LegendDot(label: 'Income', color: Color(0xFF0F9D58)),
              SizedBox(width: 12),
              _LegendDot(label: 'Expense', color: Color(0xFFDB4437)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _trend
                .map(
                  (item) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 124,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 12,
                                    height: maxValue == 0
                                        ? 0
                                        : (item.income / maxValue) * 112,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F9D58),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    width: 12,
                                    height: maxValue == 0
                                        ? 0
                                        : (item.expense / maxValue) * 112,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDB4437),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.month,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersCard(bool isCompact) {
    final searchInput = TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        hintText: 'Search by id, party, description, or method',
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
        ),
      ),
    );

    final resetButton = TextButton.icon(
      onPressed: () {
        _searchController.clear();
        setState(() {
          _searchQuery = '';
          _selectedType = 'All';
          _selectedStatus = 'All';
          _selectedCategory = 'All';
        });
      },
      icon: const Icon(Icons.restart_alt_rounded, size: 18),
      label: const Text('Reset filters'),
    );

    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (isCompact) ...[
            searchInput,
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerLeft, child: resetButton),
          ] else
            Row(
              children: [
                Expanded(child: searchInput),
                const SizedBox(width: 10),
                resetButton,
              ],
            ),
          const SizedBox(height: 12),
          const Text(
            'Type',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _types
                .map(
                  (type) => ChoiceChip(
                    label: Text(type),
                    selected: _selectedType == type,
                    onSelected: (_) {
                      setState(() {
                        _selectedType = type;
                      });
                    },
                    selectedColor: const Color(0xFF1A73E8),
                    labelStyle: TextStyle(
                      color: _selectedType == type
                          ? Colors.white
                          : const Color(0xFF334155),
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: _selectedType == type
                          ? const Color(0xFF1A73E8)
                          : const Color(0xFFD5DEE9),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text(
            'Status',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _statuses
                .map(
                  (status) => ChoiceChip(
                    label: Text(status),
                    selected: _selectedStatus == status,
                    onSelected: (_) {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                    selectedColor: const Color(0xFF0F355B),
                    labelStyle: TextStyle(
                      color: _selectedStatus == status
                          ? Colors.white
                          : const Color(0xFF334155),
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: _selectedStatus == status
                          ? const Color(0xFF0F355B)
                          : const Color(0xFFD5DEE9),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text(
            'Category',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories
                .map(
                  (category) => ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: const Color(0xFF0F9D58),
                    labelStyle: TextStyle(
                      color: _selectedCategory == category
                          ? Colors.white
                          : const Color(0xFF334155),
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: _selectedCategory == category
                          ? const Color(0xFF0F9D58)
                          : const Color(0xFFD5DEE9),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsCard(List<_TransactionRecord> list, bool isCompact) {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Transaction Records',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${list.length} records',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Detailed list of all incoming and outgoing operations',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          if (list.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'No transactions match the selected filters.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ...list
                .map((transaction) =>
                    _buildTransactionRow(transaction, isCompact))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(_TransactionRecord transaction, bool isCompact) {
    final isIncome = transaction.type == 'Income';
    final statusColor = _statusColor(transaction.status);
    final amountColor =
        isIncome ? const Color(0xFF0F9D58) : const Color(0xFFDB4437);

    final detailBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 2),
        Text(
          '${transaction.id} | ${transaction.party}',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          '${transaction.date} | ${transaction.paymentMethod}',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      ],
    );

    if (isCompact) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: amountColor.withOpacity(0.14),
                  child: Icon(
                    isIncome
                        ? Icons.south_west_rounded
                        : Icons.north_east_rounded,
                    color: amountColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: detailBlock),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(transaction.type, amountColor),
                _chip(transaction.status, statusColor),
                _chip(transaction.category, const Color(0xFF123A68)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: ${_currency(transaction.amount)} | Fee: ${_currency(transaction.fee)}',
              style: const TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: amountColor.withOpacity(0.14),
            child: Icon(
              isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: amountColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: detailBlock),
          _chip(transaction.category, const Color(0xFF123A68)),
          const SizedBox(width: 8),
          _chip(transaction.status, statusColor),
          const SizedBox(width: 8),
          _chip(transaction.type, amountColor),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              '${isIncome ? '+' : '-'}${_currency(transaction.amount)}',
              textAlign: TextAlign.end,
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideInsights(List<_TransactionRecord> list) {
    final categoryMap = <String, double>{};
    for (final item in list) {
      categoryMap.update(
        item.category,
        (value) => value + item.amount,
        ifAbsent: () => item.amount,
      );
    }

    final categories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCategoryAmount = categories.isEmpty ? 1.0 : categories.first.value;

    final pending = list.where((item) => item.status != 'Completed').toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return Column(
      children: [
        _panel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Category Split',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (categories.isEmpty)
                const Text(
                  'No category data for selected filters.',
                  style: TextStyle(color: Color(0xFF64748B)),
                )
              else
                ...categories.map((entry) {
                  final ratio = entry.value / maxCategoryAmount;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              _currency(entry.value),
                              style: const TextStyle(
                                color: Color(0xFF334155),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: ratio,
                            color: const Color(0xFF1A73E8),
                            backgroundColor: const Color(0xFFE2E8F0),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _panel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Needs Attention',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (pending.isEmpty)
                const Text(
                  'All transactions are completed.',
                  style: TextStyle(color: Color(0xFF64748B)),
                )
              else
                ...pending.take(4).map(
                      (item) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.description,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    '${item.status} | ${item.date}',
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _currency(item.amount),
                              style: const TextStyle(
                                color: Color(0xFFF29900),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 8),
              _quickAction(
                icon: Icons.upload_file_rounded,
                label: 'Export transaction ledger',
                color: const Color(0xFF1A73E8),
              ),
              const SizedBox(height: 8),
              _quickAction(
                icon: Icons.rule_rounded,
                label: 'Reconcile pending items',
                color: const Color(0xFF0F9D58),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label started.')),
          );
        },
        icon: Icon(icon, size: 18, color: color),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          side: const BorderSide(color: Color(0xFFD5DEE9)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return const Color(0xFF0F9D58);
      case 'Pending':
        return const Color(0xFFF29900);
      case 'Failed':
        return const Color(0xFFDB4437);
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _panel({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EBF3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TransactionRecord {
  const _TransactionRecord({
    required this.id,
    required this.date,
    required this.description,
    required this.party,
    required this.category,
    required this.paymentMethod,
    required this.type,
    required this.status,
    required this.amount,
    required this.fee,
  });

  final String id;
  final String date;
  final String description;
  final String party;
  final String category;
  final String paymentMethod;
  final String type;
  final String status;
  final double amount;
  final double fee;
}

class _TrendBar {
  const _TrendBar({
    required this.month,
    required this.income,
    required this.expense,
  });

  final String month;
  final double income;
  final double expense;
}

class _KpiData {
  const _KpiData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
