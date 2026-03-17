import 'package:flutter/material.dart';

import 'Pages/Invoice/export_statement_page.dart';
import 'Pages/Invoice/reconcile_paid_page.dart';
import 'Pages/Invoice/send_reminder_page.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  String _selectedRange = '30D';
  String _selectedStatus = 'All';
  String _selectedClient = 'All';
  String _searchQuery = '';

  late final TextEditingController _searchController;

  static const List<String> _ranges = ['7D', '30D', '90D', '1Y'];
  static const List<String> _statuses = ['All', 'Paid', 'Pending', 'Overdue'];

  static const List<_InvoiceTrend> _trend = [
    _InvoiceTrend(month: 'Oct', invoiced: 24600, collected: 21200),
    _InvoiceTrend(month: 'Nov', invoiced: 25700, collected: 22650),
    _InvoiceTrend(month: 'Dec', invoiced: 27100, collected: 23300),
    _InvoiceTrend(month: 'Jan', invoiced: 28400, collected: 24400),
    _InvoiceTrend(month: 'Feb', invoiced: 29800, collected: 25950),
    _InvoiceTrend(month: 'Mar', invoiced: 31200, collected: 27100),
  ];

  final List<_InvoiceRecord> _invoices = const [
    _InvoiceRecord(
      id: 'INV-001',
      client: 'ABC Corporation',
      owner: 'Amit Rana',
      issueDate: '2026-03-01',
      dueDate: '2026-03-15',
      amount: 5200,
      paidAmount: 5200,
      tax: 520,
      status: 'Paid',
      channel: 'Email',
    ),
    _InvoiceRecord(
      id: 'INV-002',
      client: 'XYZ Industries',
      owner: 'Sonal Mehta',
      issueDate: '2026-03-02',
      dueDate: '2026-03-18',
      amount: 3800,
      paidAmount: 2500,
      tax: 380,
      status: 'Pending',
      channel: 'Portal',
    ),
    _InvoiceRecord(
      id: 'INV-003',
      client: 'Tech Solutions',
      owner: 'Rohan Verma',
      issueDate: '2026-02-26',
      dueDate: '2026-03-10',
      amount: 4500,
      paidAmount: 0,
      tax: 450,
      status: 'Overdue',
      channel: 'Email',
    ),
    _InvoiceRecord(
      id: 'INV-004',
      client: 'Global Enterprises',
      owner: 'Amit Rana',
      issueDate: '2026-03-04',
      dueDate: '2026-03-21',
      amount: 6200,
      paidAmount: 3000,
      tax: 620,
      status: 'Pending',
      channel: 'Portal',
    ),
    _InvoiceRecord(
      id: 'INV-005',
      client: 'Innovation Labs',
      owner: 'Sonal Mehta',
      issueDate: '2026-02-20',
      dueDate: '2026-03-05',
      amount: 2800,
      paidAmount: 2800,
      tax: 280,
      status: 'Paid',
      channel: 'Email',
    ),
    _InvoiceRecord(
      id: 'INV-006',
      client: 'Northbridge LLP',
      owner: 'Rohan Verma',
      issueDate: '2026-03-05',
      dueDate: '2026-03-25',
      amount: 7100,
      paidAmount: 0,
      tax: 710,
      status: 'Pending',
      channel: 'Portal',
    ),
    _InvoiceRecord(
      id: 'INV-007',
      client: 'Prime Logistics',
      owner: 'Amit Rana',
      issueDate: '2026-02-17',
      dueDate: '2026-03-01',
      amount: 3300,
      paidAmount: 0,
      tax: 330,
      status: 'Overdue',
      channel: 'Email',
    ),
    _InvoiceRecord(
      id: 'INV-008',
      client: 'Meridian Retail',
      owner: 'Sonal Mehta',
      issueDate: '2026-03-07',
      dueDate: '2026-03-28',
      amount: 2600,
      paidAmount: 1800,
      tax: 260,
      status: 'Pending',
      channel: 'Portal',
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

  List<String> get _clients {
    final values = _invoices.map((invoice) => invoice.client).toSet().toList()
      ..sort();
    return ['All', ...values];
  }

  List<_InvoiceRecord> get _filteredInvoices {
    final query = _searchQuery.trim().toLowerCase();
    return _invoices.where((invoice) {
      final matchesSearch = query.isEmpty ||
          invoice.id.toLowerCase().contains(query) ||
          invoice.client.toLowerCase().contains(query) ||
          invoice.owner.toLowerCase().contains(query) ||
          invoice.channel.toLowerCase().contains(query);
      final matchesStatus =
          _selectedStatus == 'All' || invoice.status == _selectedStatus;
      final matchesClient =
          _selectedClient == 'All' || invoice.client == _selectedClient;
      return matchesSearch && matchesStatus && matchesClient;
    }).toList();
  }

  double _sumAmount(List<_InvoiceRecord> list) {
    return list.fold(0, (sum, invoice) => sum + invoice.amount);
  }

  double _sumCollected(List<_InvoiceRecord> list) {
    return list.fold(0, (sum, invoice) => sum + invoice.paidAmount);
  }

  double _sumOutstanding(List<_InvoiceRecord> list) {
    return list.fold(0, (sum, invoice) {
      return sum + (invoice.amount - invoice.paidAmount);
    });
  }

  double _sumOverdueOutstanding(List<_InvoiceRecord> list) {
    return list
        .where((invoice) => invoice.status == 'Overdue')
        .fold(0, (sum, invoice) => sum + (invoice.amount - invoice.paidAmount));
  }

  int _countByStatus(List<_InvoiceRecord> list, String status) {
    return list.where((invoice) => invoice.status == status).length;
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

  void _openSendReminders() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SendReminderPage()),
    );
  }

  void _openExportStatement() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ExportStatementPage()),
    );
  }

  void _openReconcilePaid() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ReconcilePaidPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 760;
        final isNarrow = width < 1140;
        final list = _filteredInvoices;

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
                _buildInvoicesCard(list, isCompact),
                const SizedBox(height: 16),
                _buildSideInsights(list),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildInvoicesCard(list, false),
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
          'Invoices',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 6),
        Text(
          'Manage billing lifecycle, collection status, and overdue risk.',
          style: TextStyle(color: Color(0xFF5F6368)),
        ),
      ],
    );

    final controls = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ..._ranges.map(
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
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Create Invoice'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F355B),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
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

  Widget _buildHeroCard(List<_InvoiceRecord> list) {
    final billed = _sumAmount(list);
    final collected = _sumCollected(list);
    final outstanding = _sumOutstanding(list);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F355B), Color(0xFF1A73E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withOpacity(0.24),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 14,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Invoice Command Center',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currency(billed),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Total invoiced in current view',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _heroChip('Collected', _currency(collected)),
              _heroChip('Outstanding', _currency(outstanding)),
              _heroChip('Collection Rate',
                  '${billed <= 0 ? 0 : ((collected / billed) * 100).round()}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String label, String value) {
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
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(double width, List<_InvoiceRecord> list) {
    final crossAxisCount = width >= 1280
        ? 4
        : width >= 860
            ? 2
            : 1;

    final cards = [
      _InvoiceKpi(
        title: 'Paid',
        value: '${_countByStatus(list, 'Paid')}',
        subtitle: 'Invoices fully settled',
        color: const Color(0xFF0F9D58),
        icon: Icons.task_alt_rounded,
      ),
      _InvoiceKpi(
        title: 'Pending',
        value: '${_countByStatus(list, 'Pending')}',
        subtitle: 'Awaiting collections',
        color: const Color(0xFFF29900),
        icon: Icons.pending_actions_rounded,
      ),
      _InvoiceKpi(
        title: 'Overdue',
        value: '${_countByStatus(list, 'Overdue')}',
        subtitle: 'Past due invoices',
        color: const Color(0xFFDC2626),
        icon: Icons.warning_amber_rounded,
      ),
      _InvoiceKpi(
        title: 'Overdue Value',
        value: _currency(_sumOverdueOutstanding(list)),
        subtitle: 'Outstanding past due amount',
        color: const Color(0xFF7C3AED),
        icon: Icons.account_balance_rounded,
      ),
    ];

    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 128,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];
        return _panel(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
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
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      card.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
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
    final maxInvoiced = _trend
        .map((point) => point.invoiced)
        .fold<double>(0, (prev, amount) => amount > prev ? amount : prev);

    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Invoice Trend',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Monthly billed vs collected amounts.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              _LegendDot(color: Color(0xFF1A73E8), label: 'Invoiced'),
              SizedBox(width: 12),
              _LegendDot(color: Color(0xFF0F9D58), label: 'Collected'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 170,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _trend
                  .map(
                    (point) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _bar(
                                  point.invoiced / maxInvoiced,
                                  const Color(0xFF1A73E8),
                                ),
                                const SizedBox(width: 4),
                                _bar(
                                  point.collected / maxInvoiced,
                                  const Color(0xFF0F9D58),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              point.month,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(double ratio, Color color) {
    final clamped = ratio.clamp(0.0, 1.0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      width: 15,
      height: 130 * clamped,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildFiltersCard(bool isCompact) {
    final search = TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Search invoice id, client, owner, or channel',
        prefixIcon: const Icon(Icons.search_rounded),
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

    final statusFilter = DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Status',
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
      items: _statuses
          .map((status) => DropdownMenuItem(value: status, child: Text(status)))
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        setState(() {
          _selectedStatus = value;
        });
      },
    );

    final clientFilter = DropdownButtonFormField<String>(
      value: _selectedClient,
      decoration: InputDecoration(
        labelText: 'Client',
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
      items: _clients
          .map((client) => DropdownMenuItem(value: client, child: Text(client)))
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        setState(() {
          _selectedClient = value;
        });
      },
    );

    final reset = TextButton.icon(
      onPressed: () {
        _searchController.clear();
        setState(() {
          _searchQuery = '';
          _selectedStatus = 'All';
          _selectedClient = 'All';
        });
      },
      icon: const Icon(Icons.restart_alt_rounded, size: 18),
      label: const Text('Reset'),
    );

    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCompact) ...[
            search,
            const SizedBox(height: 10),
            statusFilter,
            const SizedBox(height: 10),
            clientFilter,
            const SizedBox(height: 8),
            reset,
          ] else
            Row(
              children: [
                Expanded(flex: 4, child: search),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: statusFilter),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: clientFilter),
                const SizedBox(width: 8),
                reset,
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInvoicesCard(List<_InvoiceRecord> list, bool isCompact) {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Invoice Queue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${list.length} invoices',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (list.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'No invoices match the selected filters.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ...list
                .map((invoice) => _buildInvoiceRow(invoice, isCompact))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(_InvoiceRecord invoice, bool isCompact) {
    final statusColor = _statusColor(invoice.status);
    final pending = invoice.amount - invoice.paidAmount;

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          invoice.id,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 2),
        Text(
          '${invoice.client} | Owner: ${invoice.owner}',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          'Issued ${invoice.issueDate} | Due ${invoice.dueDate} | ${invoice.channel}',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      ],
    );

    final chips = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _chip(invoice.status, statusColor),
        _chip('Tax ${_currency(invoice.tax)}', const Color(0xFF7C3AED)),
        _chip('Pending ${_currency(pending)}', const Color(0xFF0F355B)),
      ],
    );

    final amounts = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _currency(invoice.amount),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 2),
        Text(
          'Collected ${_currency(invoice.paidAmount)}',
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
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A73E8).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: Color(0xFF1A73E8),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: details),
              ],
            ),
            const SizedBox(height: 8),
            amounts,
            const SizedBox(height: 8),
            chips,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFF1A73E8),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: details),
          const SizedBox(width: 12),
          amounts,
          const SizedBox(width: 12),
          chips,
        ],
      ),
    );
  }

  Widget _buildSideInsights(List<_InvoiceRecord> list) {
    final buckets = [
      _AgingBucket(
        label: 'Due in 0-7 days',
        value: list.where((invoice) => invoice.status == 'Pending').fold(
            0, (sum, invoice) => sum + (invoice.amount - invoice.paidAmount)),
        color: const Color(0xFF1A73E8),
      ),
      _AgingBucket(
        label: '8-15 days overdue',
        value: list
            .where((invoice) => invoice.status == 'Overdue')
            .take(1)
            .fold(0,
                (sum, invoice) => sum + (invoice.amount - invoice.paidAmount)),
        color: const Color(0xFFF29900),
      ),
      _AgingBucket(
        label: '16+ days overdue',
        value: list
            .where((invoice) => invoice.status == 'Overdue')
            .skip(1)
            .fold(0,
                (sum, invoice) => sum + (invoice.amount - invoice.paidAmount)),
        color: const Color(0xFFDC2626),
      ),
    ];

    return Column(
      children: [
        _panel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aging Snapshot',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ...buckets.map(
                (bucket) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: bucket.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bucket.label,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        _currency(bucket.value),
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                'Quick Actions',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              _actionButton(
                Icons.mark_email_unread_rounded,
                'Send reminders',
                onPressed: _openSendReminders,
              ),
              const SizedBox(height: 8),
              _actionButton(
                Icons.file_download_rounded,
                'Export statement',
                onPressed: _openExportStatement,
              ),
              const SizedBox(height: 8),
              _actionButton(
                Icons.assignment_turned_in_rounded,
                'Reconcile paid',
                onPressed: _openReconcilePaid,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
    IconData icon,
    String label, {
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: const Color(0xFF1A73E8)),
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

  Color _statusColor(String status) {
    switch (status) {
      case 'Paid':
        return const Color(0xFF0F9D58);
      case 'Pending':
        return const Color(0xFFF29900);
      case 'Overdue':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF64748B);
    }
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

class _InvoiceRecord {
  const _InvoiceRecord({
    required this.id,
    required this.client,
    required this.owner,
    required this.issueDate,
    required this.dueDate,
    required this.amount,
    required this.paidAmount,
    required this.tax,
    required this.status,
    required this.channel,
  });

  final String id;
  final String client;
  final String owner;
  final String issueDate;
  final String dueDate;
  final double amount;
  final double paidAmount;
  final double tax;
  final String status;
  final String channel;
}

class _InvoiceTrend {
  const _InvoiceTrend({
    required this.month,
    required this.invoiced,
    required this.collected,
  });

  final String month;
  final double invoiced;
  final double collected;
}

class _InvoiceKpi {
  const _InvoiceKpi({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;
}

class _AgingBucket {
  const _AgingBucket({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
