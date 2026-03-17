import 'package:flutter/material.dart';

class ReconcilePaidPage extends StatefulWidget {
  const ReconcilePaidPage({super.key});

  @override
  State<ReconcilePaidPage> createState() => _ReconcilePaidPageState();
}

class _ReconcilePaidPageState extends State<ReconcilePaidPage> {
  final List<_ReconcileItem> _items = [
    const _ReconcileItem(
      id: 'INV-001',
      client: 'ACME Corp',
      amount: 2500,
      paymentMethod: 'Bank Transfer',
      paidDate: '12 Mar 2026',
      referenceNo: 'TXN-88201',
    ),
    const _ReconcileItem(
      id: 'INV-005',
      client: 'Atlas Traders',
      amount: 7900,
      paymentMethod: 'UPI',
      paidDate: '13 Mar 2026',
      referenceNo: 'UPI-77412',
    ),
    const _ReconcileItem(
      id: 'INV-008',
      client: 'Sigma Retail',
      amount: 4100,
      paymentMethod: 'Card',
      paidDate: '14 Mar 2026',
      referenceNo: 'CRD-55098',
    ),
    const _ReconcileItem(
      id: 'INV-010',
      client: 'Nimbus Media',
      amount: 980,
      paymentMethod: 'Bank Transfer',
      paidDate: '15 Mar 2026',
      referenceNo: 'TXN-91034',
    ),
  ];

  final List<_ReconcileItem> _reconciled = [];
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = <String>{};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(_items.map((e) => e.id));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _currency(double amount) {
    final value = amount.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      final reverseIndex = value.length - i;
      buffer.write(value[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return '\$${buffer.toString()}';
  }

  double get _selectedTotal {
    return _items
        .where((item) => _selectedIds.contains(item.id))
        .fold(0, (sum, item) => sum + item.amount);
  }

  double get _queueTotal {
    return _items.fold(0, (sum, item) => sum + item.amount);
  }

  double get _reconciledTotal {
    return _reconciled.fold(0, (sum, item) => sum + item.amount);
  }

  List<_ReconcileItem> get _filteredItems {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _items;
    return _items.where((item) {
      return item.id.toLowerCase().contains(query) ||
          item.client.toLowerCase().contains(query) ||
          item.referenceNo.toLowerCase().contains(query) ||
          item.paymentMethod.toLowerCase().contains(query);
    }).toList();
  }

  void _toggleSelection(String id, bool checked) {
    setState(() {
      if (checked) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _toggleSelectAll(bool checked) {
    final visibleIds = _filteredItems.map((item) => item.id);
    setState(() {
      if (checked) {
        _selectedIds.addAll(visibleIds);
      } else {
        _selectedIds.removeWhere(visibleIds.contains);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _reconcileSelected() {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select invoices to reconcile.')),
      );
      return;
    }

    final count = _selectedIds.length;
    final total = _selectedTotal;

    setState(() {
      final done =
          _items.where((item) => _selectedIds.contains(item.id)).toList();
      _reconciled.insertAll(0, done);
      _items.removeWhere((item) => _selectedIds.contains(item.id));
      _selectedIds.clear();
      _clearSearch();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$count invoice(s) reconciled — ${_currency(total)} matched to ledger.',
        ),
      ),
    );
  }

  IconData _methodIcon(String method) {
    switch (method) {
      case 'UPI':
        return Icons.qr_code_rounded;
      case 'Card':
        return Icons.credit_card_rounded;
      default:
        return Icons.account_balance_rounded;
    }
  }

  Color _methodColor(String method) {
    switch (method) {
      case 'UPI':
        return const Color(0xFF7C3AED);
      case 'Card':
        return const Color(0xFF0F766E);
      default:
        return const Color(0xFF1D4ED8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = _filteredItems;
    final allVisibleSelected = visibleItems.isNotEmpty &&
        visibleItems.every((item) => _selectedIds.contains(item.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: const Text('Reconcile Paid Invoices'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFF), Color(0xFFEEF3FB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 980;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroCard(),
                    const SizedBox(height: 14),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildQueuePanel(
                              visibleItems,
                              allVisibleSelected,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 2,
                            child: _buildReconciledPanel(),
                          ),
                        ],
                      )
                    else ...[
                      _buildQueuePanel(visibleItems, allVisibleSelected),
                      const SizedBox(height: 14),
                      _buildReconciledPanel(),
                    ],
                    const SizedBox(height: 14),
                    _buildActionFooter(isWide),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2C67), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reconciliation Studio',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 23,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Match incoming payments to open invoices and close your receivables loop.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(
                  Icons.fact_check_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _heroChip('In queue', '${_items.length} invoices'),
              _heroChip('Queue value', _currency(_queueTotal)),
              _heroChip('Selected', '${_selectedIds.length} invoices'),
              _heroChip(
                'Reconciled today',
                '${_reconciled.length} | ${_currency(_reconciledTotal)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String label, String value) {
    return Container(
      constraints: const BoxConstraints(minWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
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
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueuePanel(
    List<_ReconcileItem> visibleItems,
    bool allVisibleSelected,
  ) {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Auto-Match Queue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F0FE),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${visibleItems.length} visible',
                  style: const TextStyle(
                    color: Color(0xFF1D4ED8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Paid invoices awaiting ledger confirmation.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search invoice, client, reference, or method',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: allVisibleSelected,
                  onChanged: (value) {
                    _toggleSelectAll(value ?? false);
                  },
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Select all visible',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (_items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A)),
                  SizedBox(width: 10),
                  Text(
                    'All invoices reconciled. Queue is clear.',
                    style: TextStyle(
                      color: Color(0xFF166534),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          else if (visibleItems.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'No items match your search.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ...visibleItems.map(_buildQueueCard),
        ],
      ),
    );
  }

  Widget _buildQueueCard(_ReconcileItem item) {
    final isSelected = _selectedIds.contains(item.id);
    final methodColor = _methodColor(item.paymentMethod);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEDF4FF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFFBFD8FF) : const Color(0xFFE2E8F0),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _toggleSelection(item.id, !isSelected),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  _toggleSelection(item.id, value ?? false);
                },
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: methodColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _methodIcon(item.paymentMethod),
                  color: methodColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.id} — ${item.client}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Ref: ${item.referenceNo} | ${item.paidDate}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _currency(item.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: methodColor.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.paymentMethod,
                      style: TextStyle(
                        color: methodColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReconciledPanel() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reconciled This Session',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Invoices matched to ledger entries in this session.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          if (_reconciled.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'No reconciliations made yet this session.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ..._reconciled.map(_buildReconciledCard),
        ],
      ),
    );
  }

  Widget _buildReconciledCard(_ReconcileItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withOpacity(0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF16A34A),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.id} — ${item.client}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.referenceNo,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _currency(item.amount),
            style: const TextStyle(
              color: Color(0xFF166534),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionFooter(bool isWide) {
    final summary = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ready to reconcile?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          '${_selectedIds.length} selected | ${_currency(_selectedTotal)} to match',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final reconcileButton = ElevatedButton.icon(
      onPressed: _reconcileSelected,
      icon: const Icon(Icons.fact_check_rounded),
      label: const Text('Reconcile Selected'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0F355B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    return _panel(
      child: isWide
          ? Row(
              children: [
                Expanded(child: summary),
                const SizedBox(width: 12),
                reconcileButton,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summary,
                const SizedBox(height: 10),
                SizedBox(width: double.infinity, child: reconcileButton),
              ],
            ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ReconcileItem {
  const _ReconcileItem({
    required this.id,
    required this.client,
    required this.amount,
    required this.paymentMethod,
    required this.paidDate,
    required this.referenceNo,
  });

  final String id;
  final String client;
  final double amount;
  final String paymentMethod;
  final String paidDate;
  final String referenceNo;
}
