import 'package:flutter/material.dart';

import 'package:finance_flutter_full/screens/Finance/Pages/Dashboard/Create_Invoice.dart';
import 'package:finance_flutter_full/screens/Finance/Pages/Dashboard/Run_payrol.dart';
import 'package:finance_flutter_full/screens/Finance/Pages/Dashboard/Tax_Estimate.dart';

class DashboardFinancePage extends StatefulWidget {
  const DashboardFinancePage({super.key});

  @override
  State<DashboardFinancePage> createState() => _DashboardFinancePageState();
}

class _DashboardFinancePageState extends State<DashboardFinancePage> {
  int _selectedRangeIndex = 1;

  static const List<String> _ranges = ['7D', '30D', '90D', '1Y'];

  final List<_FinanceMetric> _metrics = const [
    _FinanceMetric(
      title: 'Total Revenue',
      value: '\$254,800',
      trend: '+12.4%',
      color: Color(0xFF0F9D58),
      icon: Icons.north_east_rounded,
    ),
    _FinanceMetric(
      title: 'Total Expenses',
      value: '\$89,200',
      trend: '+4.1%',
      color: Color(0xFFDB4437),
      icon: Icons.south_east_rounded,
    ),
    _FinanceMetric(
      title: 'Net Profit',
      value: '\$165,600',
      trend: '+8.9%',
      color: Color(0xFF1A73E8),
      icon: Icons.account_balance_wallet_rounded,
    ),
    _FinanceMetric(
      title: 'Pending Invoices',
      value: '\$28,450',
      trend: '14 open',
      color: Color(0xFFF29900),
      icon: Icons.receipt_long_rounded,
    ),
  ];

  final List<_TransactionActivity> _recentTransactions = const [
    _TransactionActivity(
      id: 'INV-001',
      title: 'Invoice Payment',
      subtitle: 'Apex Labs',
      amount: '\$5,200',
      isIncome: true,
      time: '2h ago',
    ),
    _TransactionActivity(
      id: 'EXP-045',
      title: 'Office Supplies',
      subtitle: 'Workspace Mart',
      amount: '\$450',
      isIncome: false,
      time: '5h ago',
    ),
    _TransactionActivity(
      id: 'INV-002',
      title: 'Service Income',
      subtitle: 'Northwind Co.',
      amount: '\$3,800',
      isIncome: true,
      time: 'Yesterday',
    ),
    _TransactionActivity(
      id: 'EXP-046',
      title: 'Internet Bill',
      subtitle: 'FiberCom',
      amount: '\$120',
      isIncome: false,
      time: 'Yesterday',
    ),
    _TransactionActivity(
      id: 'INV-003',
      title: 'Annual Retainer',
      subtitle: 'BluePeak Ltd.',
      amount: '\$12,000',
      isIncome: true,
      time: '2 days ago',
    ),
  ];

  final List<_PaymentReminder> _upcomingPayments = const [
    _PaymentReminder(
      title: 'Payroll Batch',
      dueDate: 'Mar 15',
      amount: '\$22,600',
    ),
    _PaymentReminder(
      title: 'Tax Installment',
      dueDate: 'Mar 18',
      amount: '\$6,400',
    ),
    _PaymentReminder(
      title: 'Vendor Settlement',
      dueDate: 'Mar 21',
      amount: '\$3,100',
    ),
  ];

  Future<void> _openCreateInvoice() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CreateInvoiceDashboardPage(),
      ),
    );
  }

  Future<void> _openRunPayroll() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RunPayrollDashboardPage(),
      ),
    );
  }

  Future<void> _openTaxEstimate() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TaxEstimateDashboardPage(),
      ),
    );
  }

  Future<void> _openExportStatements() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Export Statements',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose statement type to generate export package.',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.calendar_view_month_rounded),
                  title: const Text('Monthly Statement'),
                  onTap: () => Navigator.of(context).pop('Monthly'),
                ),
                ListTile(
                  leading: const Icon(Icons.date_range_rounded),
                  title: const Text('Quarterly Statement'),
                  onTap: () => Navigator.of(context).pop('Quarterly'),
                ),
                ListTile(
                  leading: const Icon(Icons.summarize_rounded),
                  title: const Text('Annual Statement'),
                  onTap: () => Navigator.of(context).pop('Annual'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || choice == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$choice statement export has started.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isNarrow = width < 1050;
        final isCompact = width < 700;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isCompact),
              const SizedBox(height: 20),
              _buildHeroCard(),
              const SizedBox(height: 18),
              _buildMetricsGrid(width),
              const SizedBox(height: 18),
              if (isNarrow) ...[
                _buildCashFlowCard(),
                const SizedBox(height: 16),
                _buildBudgetCard(),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildCashFlowCard()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildBudgetCard()),
                  ],
                ),
              const SizedBox(height: 18),
              if (isNarrow) ...[
                _buildTransactionsCard(),
                const SizedBox(height: 16),
                _buildQuickActionsCard(),
                const SizedBox(height: 16),
                _buildUpcomingPaymentsCard(),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildTransactionsCard()),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildQuickActionsCard(),
                          const SizedBox(height: 16),
                          _buildUpcomingPaymentsCard(),
                        ],
                      ),
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
    final titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Finance Dashboard',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 6),
        Text(
          'Track revenue, spending, and upcoming obligations in one place.',
          style: TextStyle(color: Color(0xFF5F6368)),
        ),
      ],
    );

    final rangeFilters = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_ranges.length, (index) {
        final isSelected = _selectedRangeIndex == index;
        return ChoiceChip(
          label: Text(_ranges[index]),
          selected: isSelected,
          onSelected: (_) {
            setState(() {
              _selectedRangeIndex = index;
            });
          },
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
          selectedColor: const Color(0xFF1A73E8),
          backgroundColor: Colors.white,
          side: BorderSide(
            color:
                isSelected ? const Color(0xFF1A73E8) : const Color(0xFFD9E1EA),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        );
      }),
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleSection,
          const SizedBox(height: 14),
          rangeFilters,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: titleSection),
        const SizedBox(width: 16),
        rangeFilters,
      ],
    );
  }

  Widget _buildHeroCard() {
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
            color: const Color(0xFF1A73E8).withOpacity(0.26),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        runSpacing: 14,
        spacing: 18,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '\$165,600.00',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 33,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            children: const [
              _HeroStat(label: 'Collection Rate', value: '92.8%'),
              _HeroStat(label: 'Current Burn', value: '\$18.6k'),
              _HeroStat(label: 'Runway', value: '11.4 mo'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(double width) {
    final crossAxisCount = width >= 1280
        ? 4
        : width >= 840
            ? 2
            : 1;

    return GridView.builder(
      itemCount: _metrics.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 138,
      ),
      itemBuilder: (context, index) {
        final metric = _metrics[index];
        return _panel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: metric.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(metric.icon, size: 20, color: metric.color),
                  ),
                  const Spacer(),
                  Text(
                    metric.trend,
                    style: TextStyle(
                      color: metric.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                metric.title,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                metric.value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCashFlowCard() {
    const flow = [
      _MonthlyFlow(label: 'Nov', income: 78, expense: 52),
      _MonthlyFlow(label: 'Dec', income: 83, expense: 58),
      _MonthlyFlow(label: 'Jan', income: 88, expense: 60),
      _MonthlyFlow(label: 'Feb', income: 94, expense: 62),
      _MonthlyFlow(label: 'Mar', income: 90, expense: 54),
    ];

    return _panel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cash Flow Snapshot',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Income vs expense over recent months',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildLegend(const Color(0xFF0F9D58), 'Income'),
              const SizedBox(width: 14),
              _buildLegend(const Color(0xFFDB4437), 'Expense'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: flow
                .map(
                  (item) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 108,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _bar(item.income, const Color(0xFF0F9D58)),
                                  const SizedBox(width: 5),
                                  _bar(item.expense, const Color(0xFFDB4437)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.label,
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

  Widget _buildBudgetCard() {
    const budgets = [
      _BudgetLine(name: 'Operations', used: 72, amount: '\$54,000 / \$75,000'),
      _BudgetLine(name: 'Marketing', used: 61, amount: '\$28,700 / \$47,000'),
      _BudgetLine(name: 'Salaries', used: 83, amount: '\$96,200 / \$116,000'),
      _BudgetLine(name: 'R&D', used: 49, amount: '\$21,500 / \$44,000'),
    ];

    return _panel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Budget Utilization',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Departmental spend against approved budget',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 14),
          ...budgets.map(
            (budget) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          budget.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '${budget.used}%',
                        style: TextStyle(
                          color: budget.used >= 80
                              ? const Color(0xFFDB4437)
                              : const Color(0xFF0F9D58),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: budget.used / 100,
                      minHeight: 8,
                      color: budget.used >= 80
                          ? const Color(0xFFDB4437)
                          : const Color(0xFF1A73E8),
                      backgroundColor: const Color(0xFFE6ECF3),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    budget.amount,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsCard() {
    return _panel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening full transaction list soon.'),
                    ),
                  );
                },
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Latest incoming and outgoing transactions',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          ..._recentTransactions.map((transaction) {
            final isIncome = transaction.isIncome;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isIncome
                    ? const Color(0xFF0F9D58).withOpacity(0.08)
                    : const Color(0xFFDB4437).withOpacity(0.08),
                border: Border.all(
                  color: isIncome
                      ? const Color(0xFF0F9D58).withOpacity(0.16)
                      : const Color(0xFFDB4437).withOpacity(0.16),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: isIncome
                        ? const Color(0xFF0F9D58).withOpacity(0.18)
                        : const Color(0xFFDB4437).withOpacity(0.18),
                    child: Icon(
                      isIncome
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      size: 18,
                      color: isIncome
                          ? const Color(0xFF0F9D58)
                          : const Color(0xFFDB4437),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${transaction.id}  |  ${transaction.subtitle}',
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
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
                        '${isIncome ? '+' : '-'}${transaction.amount}',
                        style: TextStyle(
                          color: isIncome
                              ? const Color(0xFF0F9D58)
                              : const Color(0xFFDB4437),
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        transaction.time,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
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

  Widget _buildQuickActionsCard() {
    return _panel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _actionButton(
            icon: Icons.add_card_rounded,
            label: 'Create Invoice',
            color: const Color(0xFF1A73E8),
            onPressed: _openCreateInvoice,
          ),
          const SizedBox(height: 10),
          _actionButton(
            icon: Icons.account_balance_rounded,
            label: 'Run Payroll',
            color: const Color(0xFF123A68),
            onPressed: _openRunPayroll,
          ),
          const SizedBox(height: 10),
          _actionButton(
            icon: Icons.file_download_done_rounded,
            label: 'Export Statements',
            color: const Color(0xFF0F9D58),
            onPressed: _openExportStatements,
          ),
          const SizedBox(height: 10),
          _actionButton(
            icon: Icons.calculate_rounded,
            label: 'Tax Estimate',
            color: const Color(0xFFF29900),
            onPressed: _openTaxEstimate,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingPaymentsCard() {
    return _panel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Payments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Keep upcoming obligations on track',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          ..._upcomingPayments.map(
            (payment) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.event_note_rounded,
                      color: Color(0xFF334155),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Due ${payment.dueDate}',
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    payment.amount,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

  Widget _bar(int value, Color color) {
    return Container(
      width: 12,
      height: value.toDouble(),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
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

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceMetric {
  const _FinanceMetric({
    required this.title,
    required this.value,
    required this.trend,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String trend;
  final Color color;
  final IconData icon;
}

class _MonthlyFlow {
  const _MonthlyFlow({
    required this.label,
    required this.income,
    required this.expense,
  });

  final String label;
  final int income;
  final int expense;
}

class _BudgetLine {
  const _BudgetLine({
    required this.name,
    required this.used,
    required this.amount,
  });

  final String name;
  final int used;
  final String amount;
}

class _TransactionActivity {
  const _TransactionActivity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    required this.time,
  });

  final String id;
  final String title;
  final String subtitle;
  final String amount;
  final bool isIncome;
  final String time;
}

class _PaymentReminder {
  const _PaymentReminder({
    required this.title,
    required this.dueDate,
    required this.amount,
  });

  final String title;
  final String dueDate;
  final String amount;
}
