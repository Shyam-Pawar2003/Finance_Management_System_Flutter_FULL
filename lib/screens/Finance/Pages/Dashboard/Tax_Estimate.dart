import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TaxEstimateDashboardPage extends StatefulWidget {
  const TaxEstimateDashboardPage({super.key});

  @override
  State<TaxEstimateDashboardPage> createState() =>
      _TaxEstimateDashboardPageState();
}

class _TaxEstimateDashboardPageState extends State<TaxEstimateDashboardPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _scenarioController =
      TextEditingController(text: 'Q${_currentQuarter()} Projection');
  final TextEditingController _revenueController =
      TextEditingController(text: '125000');
  final TextEditingController _deductibleController =
      TextEditingController(text: '34000');
  final TextEditingController _nondeductibleController =
      TextEditingController(text: '6200');
  final TextEditingController _salaryController =
      TextEditingController(text: '28000');
  final TextEditingController _depreciationController =
      TextEditingController(text: '4100');
  final TextEditingController _advanceTaxPaidController =
      TextEditingController(text: '7000');

  final List<_TaxScenarioRecord> _savedScenarios = [];

  String _selectedBusinessType = 'Private Limited';
  bool _applyRAndDCredit = false;
  bool _includeEducationCess = true;

  double _estimatedTax = 0;
  double _estimatedCess = 0;
  double _taxPayable = 0;
  double _effectiveRate = 0;

  static int _currentQuarter() {
    final month = DateTime.now().month;
    if (month <= 3) return 1;
    if (month <= 6) return 2;
    if (month <= 9) return 3;
    return 4;
  }

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  @override
  void dispose() {
    _scenarioController.dispose();
    _revenueController.dispose();
    _deductibleController.dispose();
    _nondeductibleController.dispose();
    _salaryController.dispose();
    _depreciationController.dispose();
    _advanceTaxPaidController.dispose();
    super.dispose();
  }

  double _numFrom(TextEditingController controller) {
    return double.tryParse(controller.text.trim()) ?? 0;
  }

  double get _revenue => _numFrom(_revenueController);
  double get _deductible => _numFrom(_deductibleController);
  double get _nondeductible => _numFrom(_nondeductibleController);
  double get _salary => _numFrom(_salaryController);
  double get _depreciation => _numFrom(_depreciationController);
  double get _advanceTax => _numFrom(_advanceTaxPaidController);

  double get _taxableIncome {
    final base =
        _revenue - _deductible - _salary - _depreciation + _nondeductible;
    return base < 0 ? 0 : base;
  }

  double _taxRateForBusinessType() {
    switch (_selectedBusinessType) {
      case 'Partnership':
        return 0.30;
      case 'Sole Proprietorship':
        return 0.22;
      case 'LLP':
        return 0.25;
      case 'Private Limited':
      default:
        return 0.24;
    }
  }

  void _recalculate() {
    final rate = _taxRateForBusinessType();

    double tax = _taxableIncome * rate;
    if (_applyRAndDCredit) {
      tax = (tax - 1200).clamp(0.0, double.infinity).toDouble();
    }

    final double cess = _includeEducationCess ? tax * 0.04 : 0.0;
    final double payable =
        (tax + cess - _advanceTax).clamp(0.0, double.infinity).toDouble();

    setState(() {
      _estimatedTax = tax;
      _estimatedCess = cess;
      _taxPayable = payable;
      _effectiveRate = _revenue > 0 ? ((tax + cess) / _revenue) * 100 : 0;
    });
  }

  String _money(double value) {
    final rounded = value.toStringAsFixed(2);
    final parts = rounded.split('.');
    final whole = parts[0];
    final decimal = parts[1];
    final buffer = StringBuffer();

    for (var i = 0; i < whole.length; i++) {
      final reverseIndex = whole.length - i;
      buffer.write(whole[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    return '\$${buffer.toString()}.$decimal';
  }

  String _dateLabel(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String? _validateCurrency(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 0) {
      return 'Enter a valid non-negative number';
    }
    return null;
  }

  void _saveScenario() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_scenarioController.text.trim().isEmpty) {
      _showMessage('Please enter a scenario name.');
      return;
    }

    final record = _TaxScenarioRecord(
      name: _scenarioController.text.trim(),
      businessType: _selectedBusinessType,
      taxableIncome: _taxableIncome,
      estimatedTax: _estimatedTax,
      cess: _estimatedCess,
      payable: _taxPayable,
      effectiveRate: _effectiveRate,
      savedAt: DateTime.now(),
    );

    setState(() {
      _savedScenarios.insert(0, record);
    });

    _showMessage('Scenario "${record.name}" saved.');
  }

  Future<void> _copyCurrentEstimate() async {
    final summary = StringBuffer()
      ..writeln('Tax Estimate Summary')
      ..writeln('Scenario: ${_scenarioController.text.trim()}')
      ..writeln('Business Type: $_selectedBusinessType')
      ..writeln('Revenue: ${_money(_revenue)}')
      ..writeln('Taxable Income: ${_money(_taxableIncome)}')
      ..writeln('Estimated Tax: ${_money(_estimatedTax)}')
      ..writeln('Cess: ${_money(_estimatedCess)}')
      ..writeln('Advance Tax Paid: ${_money(_advanceTax)}')
      ..writeln('Tax Payable: ${_money(_taxPayable)}')
      ..writeln('Effective Tax Rate: ${_effectiveRate.toStringAsFixed(2)}%');

    await Clipboard.setData(ClipboardData(text: summary.toString()));
    _showMessage('Current estimate copied to clipboard.');
  }

  void _resetDefaults() {
    setState(() {
      _scenarioController.text = 'Q${_currentQuarter()} Projection';
      _revenueController.text = '125000';
      _deductibleController.text = '34000';
      _nondeductibleController.text = '6200';
      _salaryController.text = '28000';
      _depreciationController.text = '4100';
      _advanceTaxPaidController.text = '7000';
      _selectedBusinessType = 'Private Limited';
      _applyRAndDCredit = false;
      _includeEducationCess = true;
    });
    _recalculate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Tax Estimate',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHero(),
                const SizedBox(height: 14),
                _buildInputPanel(),
                const SizedBox(height: 14),
                _buildResultPanel(),
                const SizedBox(height: 14),
                _buildHistoryPanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF263238), Color(0xFF00796B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          _heroChip('Taxable Income', _money(_taxableIncome)),
          _heroChip('Estimated Tax', _money(_estimatedTax)),
          _heroChip('Tax Payable', _money(_taxPayable)),
          _heroChip('Effective Rate', '${_effectiveRate.toStringAsFixed(2)}%'),
        ],
      ),
    );
  }

  Widget _heroChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputPanel() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estimate Inputs',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _scenarioController,
            decoration: const InputDecoration(
              labelText: 'Scenario Name',
              filled: true,
              fillColor: Color(0xFFF8FAFC),
            ),
            onChanged: (_) => _recalculate(),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedBusinessType,
            decoration: const InputDecoration(
              labelText: 'Business Type',
              filled: true,
              fillColor: Color(0xFFF8FAFC),
            ),
            items: const [
              DropdownMenuItem(
                  value: 'Private Limited', child: Text('Private Limited')),
              DropdownMenuItem(value: 'LLP', child: Text('LLP')),
              DropdownMenuItem(
                  value: 'Partnership', child: Text('Partnership')),
              DropdownMenuItem(
                value: 'Sole Proprietorship',
                child: Text('Sole Proprietorship'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedBusinessType = value;
              });
              _recalculate();
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _currencyField('Revenue', _revenueController),
              _currencyField('Deductible Expenses', _deductibleController),
              _currencyField(
                  'Non-deductible Expenses', _nondeductibleController),
              _currencyField('Salary & Wages', _salaryController),
              _currencyField('Depreciation', _depreciationController),
              _currencyField('Advance Tax Paid', _advanceTaxPaidController),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Apply R&D tax credit (\$1,200)'),
            value: _applyRAndDCredit,
            onChanged: (value) {
              setState(() {
                _applyRAndDCredit = value;
              });
              _recalculate();
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Include education cess (4%)'),
            value: _includeEducationCess,
            onChanged: (value) {
              setState(() {
                _includeEducationCess = value;
              });
              _recalculate();
            },
          ),
        ],
      ),
    );
  }

  Widget _currencyField(String label, TextEditingController controller) {
    return SizedBox(
      width: 220,
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixText: '\$',
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
        ),
        validator: _validateCurrency,
        onChanged: (_) => _recalculate(),
      ),
    );
  }

  Widget _buildResultPanel() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estimated Result',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _resultRow('Taxable Income', _money(_taxableIncome)),
          _resultRow('Estimated Tax', _money(_estimatedTax)),
          _resultRow('Education Cess', _money(_estimatedCess)),
          _resultRow('Advance Tax Paid', _money(_advanceTax)),
          const Divider(height: 20),
          _resultRow('Tax Payable', _money(_taxPayable), emphasis: true),
          _resultRow(
            'Effective Tax Rate',
            '${_effectiveRate.toStringAsFixed(2)}%',
            emphasis: true,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _saveScenario,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save Scenario'),
              ),
              OutlinedButton.icon(
                onPressed: _copyCurrentEstimate,
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy Estimate'),
              ),
              OutlinedButton.icon(
                onPressed: _resetDefaults,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reset Defaults'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value, {bool emphasis = false}) {
    final style = TextStyle(
      fontWeight: emphasis ? FontWeight.w700 : FontWeight.w500,
      color: emphasis ? const Color(0xFF0F172A) : const Color(0xFF334155),
      fontSize: emphasis ? 15 : 14,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(value, style: style),
        ],
      ),
    );
  }

  Widget _buildHistoryPanel() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saved Scenarios',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (_savedScenarios.isEmpty)
            const Text(
              'No scenarios saved yet.',
              style: TextStyle(color: Color(0xFF64748B)),
            )
          else
            ..._savedScenarios.map(
              (record) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
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
                            record.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${record.businessType} | Saved ${_dateLabel(record.savedAt)}',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Payable ${_money(record.payable)} | Effective ${record.effectiveRate.toStringAsFixed(2)}%',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        final text = StringBuffer()
                          ..writeln('Tax Scenario: ${record.name}')
                          ..writeln('Business Type: ${record.businessType}')
                          ..writeln(
                              'Taxable Income: ${_money(record.taxableIncome)}')
                          ..writeln(
                              'Estimated Tax: ${_money(record.estimatedTax)}')
                          ..writeln('Cess: ${_money(record.cess)}')
                          ..writeln('Tax Payable: ${_money(record.payable)}')
                          ..writeln(
                              'Effective Rate: ${record.effectiveRate.toStringAsFixed(2)}%');

                        await Clipboard.setData(
                            ClipboardData(text: text.toString()));
                        _showMessage('Scenario copied to clipboard.');
                      },
                      child: const Text('Copy'),
                    ),
                  ],
                ),
              ),
            ),
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

class _TaxScenarioRecord {
  const _TaxScenarioRecord({
    required this.name,
    required this.businessType,
    required this.taxableIncome,
    required this.estimatedTax,
    required this.cess,
    required this.payable,
    required this.effectiveRate,
    required this.savedAt,
  });

  final String name;
  final String businessType;
  final double taxableIncome;
  final double estimatedTax;
  final double cess;
  final double payable;
  final double effectiveRate;
  final DateTime savedAt;
}
