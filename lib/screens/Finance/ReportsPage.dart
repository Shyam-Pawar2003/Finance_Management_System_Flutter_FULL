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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reports',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
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
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  mainAxisExtent: 190,
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
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onOpen,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('View'),
            ),
          ],
        ),
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
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: child,
          ),
        ),
      ),
    );
  }
}
