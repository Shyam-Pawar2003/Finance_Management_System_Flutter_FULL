import 'package:flutter/material.dart';
import 'Pages/Report/balance_sheet_card.dart';
import 'Pages/Report/budget_analysis_card.dart';
import 'Pages/Report/cashflow_card.dart';
import 'Pages/Report/expense_report_card.dart';
import 'Pages/Report/income_report_card.dart';
import 'Pages/Report/tax_report_card.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  static const List<_ReportItem> _reportItems = [
    _ReportItem(
      'Income Report',
      Icons.trending_up,
      Colors.green,
      IncomeReportCard(),
    ),
    _ReportItem(
      'Expense Report',
      Icons.trending_down,
      Colors.red,
      ExpenseReportCard(),
    ),
    _ReportItem(
      'Tax Report',
      Icons.receipt_long,
      Colors.blue,
      TaxReportCard(),
    ),
    _ReportItem(
      'Balance Sheet',
      Icons.account_balance,
      Colors.purple,
      BalanceSheetCard(),
    ),
    _ReportItem(
      'Cash Flow',
      Icons.waterfall_chart,
      Colors.amber,
      CashFlowCard(),
    ),
    _ReportItem(
      'Budget Analysis',
      Icons.pie_chart,
      Colors.teal,
      BudgetAnalysisCard(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8FAFF), Color(0xFFEFF4FC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroBanner(),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _InfoPill(
                icon: Icons.description_rounded,
                label: 'Templates',
                value: '6',
                color: Color(0xFF2563EB),
              ),
              _InfoPill(
                icon: Icons.schedule_rounded,
                label: 'Frequency',
                value: 'Weekly + Monthly',
                color: Color(0xFF0F766E),
              ),
              _InfoPill(
                icon: Icons.file_download_done_rounded,
                label: 'Export Ready',
                value: 'PDF / CSV',
                color: Color(0xFFD97706),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Available Reports',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 1100
                    ? 3
                    : constraints.maxWidth >= 700
                        ? 2
                        : 1;

                return GridView.builder(
                  itemCount: _reportItems.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    mainAxisExtent: 220,
                  ),
                  itemBuilder: (context, index) {
                    final report = _reportItems[index];
                    return _buildReportCard(
                      report.title,
                      report.icon,
                      report.color,
                      () => _openReport(context, report),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2C67), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.24),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reports Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Review finance reports with a clean layout and quick access to details.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          _HeroIcon(),
        ],
      ),
    );
  }

  void _openReport(BuildContext context, _ReportItem report) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _ReportDetailsPage(
          title: report.title,
          child: report.child,
        ),
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onOpen,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onOpen,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 24, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _reportSubtitle(title),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.visibility_rounded, size: 16),
                    label: const Text('View Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _reportSubtitle(String title) {
    switch (title) {
      case 'Income Report':
        return 'Revenue trends and source-wise performance snapshot.';
      case 'Expense Report':
        return 'Cost breakdown and operational spend summary.';
      case 'Tax Report':
        return 'Tax liabilities, filing status, and compliance signals.';
      case 'Balance Sheet':
        return 'Assets, liabilities, and equity at a glance.';
      case 'Cash Flow':
        return 'Track inflow, outflow, and cash runway movement.';
      case 'Budget Analysis':
        return 'Budget vs actuals across teams and categories.';
      default:
        return 'Open this report to view detailed financial insights.';
    }
  }
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white30),
      ),
      child: const Icon(
        Icons.insights_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportItem {
  const _ReportItem(this.title, this.icon, this.color, this.child);

  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
}

class _ReportDetailsPage extends StatelessWidget {
  const _ReportDetailsPage({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.insert_chart_rounded, size: 20),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFF), Color(0xFFEEF3FB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
