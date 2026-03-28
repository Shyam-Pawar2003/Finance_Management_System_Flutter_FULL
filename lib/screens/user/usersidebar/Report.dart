import 'package:flutter/material.dart';

import '../../user_dashboard.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  static const Color _bgTop = Color(0xFF0A1A08);
  static const Color _bgBottom = Color(0xFF050C04);
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  String _selectedPeriod = 'Monthly';
  int _selectedReportTab = 0;

  final List<String> _periods = ['Weekly', 'Monthly', 'Quarterly', 'Yearly'];
  final List<String> _reportTypes = [
    'Income',
    'Expenses',
    'Savings',
    'Investments'
  ];

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  void _exportReport() {
    _showMessage(
        '$_selectedPeriod ${_reportTypes[_selectedReportTab]} report exported.');
  }

  Future<void> _handleBack() async {
    final popped = await Navigator.maybePop(context);
    if (!popped && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const UserDashboard()),
      );
    }
  }

  String _averageLabel() {
    final periodPrefix = _selectedPeriod == 'Weekly'
        ? 'Weekly'
        : _selectedPeriod == 'Quarterly'
            ? 'Quarterly'
            : _selectedPeriod == 'Yearly'
                ? 'Yearly'
                : 'Monthly';

    final values = {
      'Income': 'INR 12,500',
      'Expenses': 'INR 7,900',
      'Savings': 'INR 4,600',
      'Investments': 'INR 3,100',
    };

    final report = _reportTypes[_selectedReportTab];
    return '$periodPrefix Average: ${values[report]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBottom,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Reports',
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        leading: IconButton(
          onPressed: _handleBack,
          icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: _exportReport,
            tooltip: 'Export report',
            icon: const Icon(Icons.file_download_rounded, color: _textPrimary),
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
                  _buildTipCard(),
                  const SizedBox(height: 16),
                  // Period Selection
                  _buildPeriodSelector(),
                  const SizedBox(height: 24),

                  // Report Tabs
                  _buildReportTabs(),
                  const SizedBox(height: 20),

                  // Summary Cards
                  _buildSummaryCards(),
                  const SizedBox(height: 24),

                  // Chart
                  _buildChartCard(),
                  const SizedBox(height: 24),

                  // Detailed Breakdown
                  _buildDetailedBreakdown(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
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
          Icon(Icons.insights_outlined, color: _lime, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tip: switch period and tab to compare trends before exporting your final report.',
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

  Widget _buildPeriodSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _periods
            .map((period) => Padding(
                  padding:
                      EdgeInsets.only(right: period != _periods.last ? 10 : 0),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPeriod = period),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedPeriod == period ? _lime : _cardDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedPeriod == period
                              ? _lime
                              : _lime.withOpacity(0.12),
                        ),
                      ),
                      child: Text(
                        period,
                        style: TextStyle(
                          color: _selectedPeriod == period
                              ? _bgBottom
                              : _textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildReportTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_reportTypes.length, (index) {
          final isSelected = _selectedReportTab == index;
          return Padding(
            padding:
                EdgeInsets.only(right: index < _reportTypes.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedReportTab = index),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      isSelected ? _lime.withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? _lime : _lime.withOpacity(0.12),
                  ),
                ),
                child: Text(
                  _reportTypes[index],
                  style: TextStyle(
                    color: isSelected ? _lime : _textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final summaryData = [
      {
        'label': 'Total Income',
        'amount': '₹85,500',
        'change': '+12.5%',
        'icon': Icons.trending_up_rounded,
        'color': _lime,
      },
      {
        'label': 'Total Expenses',
        'amount': '₹45,230',
        'change': '-8.3%',
        'icon': Icons.trending_down_rounded,
        'color': Colors.red.shade400,
      },
      {
        'label': 'Net Savings',
        'amount': '₹40,270',
        'change': '+22.1%',
        'icon': Icons.savings_rounded,
        'color': Colors.green.shade400,
      },
    ];

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: summaryData.length,
        itemBuilder: (_, i) => Padding(
          padding: EdgeInsets.only(right: i < summaryData.length - 1 ? 12 : 0),
          child: _buildSummaryCard(
            label: summaryData[i]['label'] as String,
            amount: summaryData[i]['amount'] as String,
            change: summaryData[i]['change'] as String,
            icon: summaryData[i]['icon'] as IconData,
            color: summaryData[i]['color'] as Color,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String amount,
    required String change,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                amount,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _lime.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _reportTypes[_selectedReportTab],
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(Icons.info_outline_rounded, color: _textMuted, size: 18),
            ],
          ),
          const SizedBox(height: 16),

          // Bar Chart Visualization
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildChartBar('Jan', 0.6),
              _buildChartBar('Feb', 0.75),
              _buildChartBar('Mar', 0.85),
              _buildChartBar('Apr', 0.65),
              _buildChartBar('May', 0.9),
              _buildChartBar('Jun', 0.7),
            ],
          ),
          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _lime,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _averageLabel(),
                style: const TextStyle(
                  color: _textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String label, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: 100 * height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_lime, _lime.withOpacity(0.6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: _textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedBreakdown() {
    final categories = [
      ('Salary', '₹45,000', 0.52, _lime),
      ('Freelance', '₹15,500', 0.18, Colors.blue.shade400),
      ('Investments', '₹12,000', 0.14, Color(0xFF5B6FFF)),
      ('Other', '₹13,000', 0.16, Colors.purple.shade400),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _lime.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category Breakdown',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...categories.map((cat) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildCategoryRow(
                  name: cat.$1,
                  amount: cat.$2,
                  percentage: cat.$3,
                  color: cat.$4,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCategoryRow({
    required String name,
    required String amount,
    required double percentage,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(percentage * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 6,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
