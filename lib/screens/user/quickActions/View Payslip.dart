import 'package:flutter/material.dart';

class ViewPayslipPage extends StatefulWidget {
  const ViewPayslipPage({super.key});

  @override
  State<ViewPayslipPage> createState() => _ViewPayslipPageState();
}

class _ViewPayslipPageState extends State<ViewPayslipPage> {
  final TextEditingController _emailController =
      TextEditingController(text: 'shyam@example.com');

  bool _includeBankDetails = true;
  bool _includeYtdBreakdown = true;
  String _selectedPayslipId = _payslips.first.id;

  static const List<_PayslipRecord> _payslips = [
    _PayslipRecord(
      id: 'PS-2026-03',
      periodLabel: 'March 2026',
      payDate: '2026-03-31',
      status: 'Processed',
      grossPay: 5200,
      netPay: 4430,
      totalDeductions: 770,
      tax: 420,
      bonus: 300,
      basicPay: 3500,
      hra: 900,
      allowance: 500,
      providentFund: 210,
      insurance: 140,
    ),
    _PayslipRecord(
      id: 'PS-2026-02',
      periodLabel: 'February 2026',
      payDate: '2026-02-28',
      status: 'Processed',
      grossPay: 5100,
      netPay: 4355,
      totalDeductions: 745,
      tax: 400,
      bonus: 250,
      basicPay: 3500,
      hra: 900,
      allowance: 450,
      providentFund: 205,
      insurance: 140,
    ),
    _PayslipRecord(
      id: 'PS-2026-01',
      periodLabel: 'January 2026',
      payDate: '2026-01-31',
      status: 'Processed',
      grossPay: 5050,
      netPay: 4310,
      totalDeductions: 740,
      tax: 390,
      bonus: 200,
      basicPay: 3500,
      hra: 900,
      allowance: 450,
      providentFund: 210,
      insurance: 140,
    ),
    _PayslipRecord(
      id: 'PS-2025-12',
      periodLabel: 'December 2025',
      payDate: '2025-12-31',
      status: 'Archived',
      grossPay: 5000,
      netPay: 4280,
      totalDeductions: 720,
      tax: 385,
      bonus: 180,
      basicPay: 3500,
      hra: 880,
      allowance: 440,
      providentFund: 200,
      insurance: 135,
    ),
  ];

  _PayslipRecord get _currentRecord {
    return _payslips.firstWhere(
      (record) => record.id == _selectedPayslipId,
      orElse: () => _payslips.first,
    );
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

  double _ytdNetPay() {
    return _payslips.fold(0, (sum, item) => sum + item.netPay);
  }

  double _ytdTax() {
    return _payslips.fold(0, (sum, item) => sum + item.tax);
  }

  int _deliveryReadiness() {
    var score = 65;
    if (_includeBankDetails) score += 15;
    if (_includeYtdBreakdown) score += 15;
    if (_emailController.text.trim().contains('@')) score += 5;
    return score.clamp(0, 100);
  }

  void _downloadPayslip() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Payslip ${_currentRecord.periodLabel} download started.'),
      ),
    );
  }

  void _emailPayslip() {
    final email = _emailController.text.trim();
    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payslip sent to $email')),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1040;
        final record = _currentRecord;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7FB),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isDesktop ? 24 : 16,
                16,
                isDesktop ? 24 : 16,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildHeroCard(record),
                  const SizedBox(height: 16),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildPayslipPanel(record)),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: _buildSidePanel(record)),
                      ],
                    )
                  else ...[
                    _buildPayslipPanel(record),
                    const SizedBox(height: 16),
                    _buildSidePanel(record),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
        const SizedBox(width: 4),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'View Payslip',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4),
              Text(
                'Review salary details, deductions, and securely share payslips.',
                style: TextStyle(color: Color(0xFF5F6368)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(_PayslipRecord record) {
    final readiness = _deliveryReadiness();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F355B), Color(0xFF1A73E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withOpacity(0.24),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Salary Access Hub',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                record.periodLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Net Pay ${_currency(record.netPay)} | Pay Date ${record.payDate}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _heroBadge('Gross', _currency(record.grossPay)),
              _heroBadge('Deductions', _currency(record.totalDeductions)),
              _heroBadge('Readiness', '$readiness%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
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
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayslipPanel(_PayslipRecord record) {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payslip Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedPayslipId,
            decoration: _inputDecoration('Select Payslip Period'),
            items: _payslips
                .map(
                  (item) => DropdownMenuItem(
                    value: item.id,
                    child: Text('${item.periodLabel} (${item.status})'),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _selectedPayslipId = value;
              });
            },
          ),
          const SizedBox(height: 10),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Include bank details',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Show account details in exported file'),
            value: _includeBankDetails,
            onChanged: (value) {
              setState(() {
                _includeBankDetails = value;
              });
            },
            activeColor: const Color(0xFF1A73E8),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Include YTD breakdown',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Attach year-to-date totals in document'),
            value: _includeYtdBreakdown,
            onChanged: (value) {
              setState(() {
                _includeYtdBreakdown = value;
              });
            },
            activeColor: const Color(0xFF1A73E8),
          ),
          const SizedBox(height: 8),
          _sectionTitle('Earnings'),
          const SizedBox(height: 8),
          _valueTile(
              'Basic Pay', _currency(record.basicPay), const Color(0xFF1A73E8)),
          _valueTile('HRA', _currency(record.hra), const Color(0xFF0F9D58)),
          _valueTile('Allowance', _currency(record.allowance),
              const Color(0xFFF29900)),
          _valueTile('Bonus', _currency(record.bonus), const Color(0xFF7C3AED)),
          const SizedBox(height: 12),
          _sectionTitle('Deductions'),
          const SizedBox(height: 8),
          _valueTile('Tax', _currency(-record.tax), const Color(0xFFDC2626)),
          _valueTile(
            'Provident Fund',
            _currency(-record.providentFund),
            const Color(0xFFDC2626),
          ),
          _valueTile('Insurance', _currency(-record.insurance),
              const Color(0xFFDC2626)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            decoration: _inputDecoration('Delivery Email'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _downloadPayslip,
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: Color(0xFFD5DEE9)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _emailPayslip,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Email Payslip'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidePanel(_PayslipRecord record) {
    return Column(
      children: [
        _panel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'YTD Summary',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              _statTile('Net Pay YTD', _currency(_ytdNetPay())),
              const SizedBox(height: 8),
              _statTile('Tax Paid YTD', _currency(_ytdTax())),
              const SizedBox(height: 8),
              _statTile('Current Status', record.status),
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
                'Recent Payslips',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ..._payslips.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
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
                              item.periodLabel,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Net ${_currency(item.netPay)} | ${item.payDate}',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _statusChip(item.status),
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
                'Support Actions',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              _actionButton(Icons.lock_reset_rounded, 'Reset payslip password'),
              const SizedBox(height: 8),
              _actionButton(Icons.help_outline_rounded, 'Raise HR request'),
              const SizedBox(height: 8),
              _actionButton(
                  Icons.download_for_offline_rounded, 'Download all (ZIP)'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label request submitted.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
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

  Widget _sectionTitle(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }

  Widget _valueTile(String label, String value, Color valueColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
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
      case 'Processed':
        return const Color(0xFF0F9D58);
      case 'Archived':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFFF29900);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 1.4),
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

class _PayslipRecord {
  const _PayslipRecord({
    required this.id,
    required this.periodLabel,
    required this.payDate,
    required this.status,
    required this.grossPay,
    required this.netPay,
    required this.totalDeductions,
    required this.tax,
    required this.bonus,
    required this.basicPay,
    required this.hra,
    required this.allowance,
    required this.providentFund,
    required this.insurance,
  });

  final String id;
  final String periodLabel;
  final String payDate;
  final String status;
  final double grossPay;
  final double netPay;
  final double totalDeductions;
  final double tax;
  final double bonus;
  final double basicPay;
  final double hra;
  final double allowance;
  final double providentFund;
  final double insurance;
}
