import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/dashboard_seed_data.dart';
import '../../../models/dashboard_models.dart';

class InvestmentWithdrawPage extends StatelessWidget {
  const InvestmentWithdrawPage({super.key});

  static const Color _bgTop = Color(0xFF0A1A08);
  static const Color _bgBottom = Color(0xFF050C04);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);

  Widget _glow(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _lime.withOpacity(0.08),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBottom,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Withdraw Funds',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(top: -120, right: -70, child: _glow(280)),
          Positioned(bottom: -110, left: -70, child: _glow(230)),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_bgTop, _bgBottom],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          const SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: InvestmentWithdrawContent(),
            ),
          ),
        ],
      ),
    );
  }
}

class InvestmentWithdrawContent extends StatefulWidget {
  const InvestmentWithdrawContent({super.key, this.onWithdrawn});

  final VoidCallback? onWithdrawn;

  @override
  State<InvestmentWithdrawContent> createState() =>
      _InvestmentWithdrawContentState();
}

class _InvestmentWithdrawContentState extends State<InvestmentWithdrawContent> {
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);
  static const Color _red = Color(0xFFE67A62);

  final List<String> _modes = const ['Standard', 'Instant', 'Scheduled'];

  final List<_WithdrawDestination> _destinations = const [
    _WithdrawDestination(
      title: 'Primary Bank',
      subtitle: 'HDFC •••• 8219',
      eta: 'T+1 day',
      icon: Icons.account_balance_rounded,
    ),
    _WithdrawDestination(
      title: 'Salary Account',
      subtitle: 'ICICI •••• 4772',
      eta: 'Same day',
      icon: Icons.account_balance_wallet_rounded,
    ),
    _WithdrawDestination(
      title: 'UPI Wallet',
      subtitle: 'john@upi',
      eta: 'Within 30 min',
      icon: Icons.qr_code_2_rounded,
    ),
  ];

  late final List<_SourceOption> _sourceOptions;
  late final TextEditingController _amountController;
  late final TextEditingController _remarkController;

  int _selectedSourceIndex = 0;
  int _selectedDestinationIndex = 0;
  String _selectedMode = 'Standard';
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 1));

  bool _notifyEmail = true;
  bool _saveAsTemplate = false;
  bool _isProcessing = false;
  String? _receiptId;

  @override
  void initState() {
    super.initState();
    _sourceOptions = _buildSourceOptions(seedInvestmentHoldings);
    final defaultAmount = _sourceOptions.isEmpty
        ? 250
        : math.max(100, _liquidAvailable(_sourceOptions.first) * 0.15);
    _amountController =
        TextEditingController(text: defaultAmount.toStringAsFixed(0));
    _remarkController =
        TextEditingController(text: 'Monthly profit withdrawal');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  String get _currencySymbol {
    switch (seededUserProfile.currencyPreference) {
      case 'EUR':
        return 'EUR ';
      case 'GBP':
        return 'GBP ';
      case 'INR':
        return 'INR ';
      case 'AED':
        return 'AED ';
      case 'USD':
      default:
        return r'$';
    }
  }

  _SourceOption get _source {
    if (_sourceOptions.isEmpty) {
      return const _SourceOption(
        assetType: 'General',
        currentValue: 0,
        investedValue: 0,
      );
    }
    return _sourceOptions[
        _selectedSourceIndex.clamp(0, _sourceOptions.length - 1)];
  }

  _WithdrawDestination get _destination {
    return _destinations[
        _selectedDestinationIndex.clamp(0, _destinations.length - 1)];
  }

  double get _amount => double.tryParse(_amountController.text.trim()) ?? 0;

  double _liquidityRatio(String assetType) {
    final lower = assetType.toLowerCase();
    if (lower.contains('bond') ||
        lower.contains('debt') ||
        lower.contains('gold')) {
      return 0.84;
    }
    if (lower.contains('stock') ||
        lower.contains('equity') ||
        lower.contains('etf')) {
      return 0.70;
    }
    if (lower.contains('crypto')) {
      return 0.55;
    }
    return 0.65;
  }

  double _liquidAvailable(_SourceOption option) {
    return option.currentValue * _liquidityRatio(option.assetType);
  }

  double get _availableToWithdraw => _liquidAvailable(_source);

  double get _fee {
    if (_amount <= 0) {
      return 0;
    }

    switch (_selectedMode) {
      case 'Instant':
        return math.max(2.5, _amount * 0.0040);
      case 'Scheduled':
        return math.max(0.5, _amount * 0.0008);
      case 'Standard':
      default:
        return math.max(1.0, _amount * 0.0016);
    }
  }

  double get _gainRatio {
    if (_source.currentValue <= 0) {
      return 0;
    }
    final gain = (_source.currentValue - _source.investedValue)
        .clamp(0, _source.currentValue)
        .toDouble();
    return gain / _source.currentValue;
  }

  double get _taxEstimate {
    if (_amount <= 0) {
      return 0;
    }
    return _amount * _gainRatio * 0.15;
  }

  double get _netCredit {
    return (_amount - _fee - _taxEstimate).clamp(0, double.infinity).toDouble();
  }

  double get _bufferAfterWithdrawal {
    return (_availableToWithdraw - _amount)
        .clamp(0, double.infinity)
        .toDouble();
  }

  List<_SourceOption> _buildSourceOptions(List<InvestmentHolding> holdings) {
    final grouped = <String, _SourceOption>{};

    for (final holding in holdings) {
      final existing = grouped[holding.assetType];
      if (existing == null) {
        grouped[holding.assetType] = _SourceOption(
          assetType: holding.assetType,
          currentValue: holding.currentValue,
          investedValue: holding.investedAmount,
        );
      } else {
        grouped[holding.assetType] = _SourceOption(
          assetType: holding.assetType,
          currentValue: existing.currentValue + holding.currentValue,
          investedValue: existing.investedValue + holding.investedAmount,
        );
      }
    }

    final options = grouped.values.toList()
      ..sort((a, b) => b.currentValue.compareTo(a.currentValue));

    if (options.isEmpty) {
      options.add(
        const _SourceOption(
          assetType: 'General',
          currentValue: 0,
          investedValue: 0,
        ),
      );
    }

    return options;
  }

  String _money(double value, {int decimals = 0}) {
    final isNegative = value < 0;
    final rounded = value.abs().toStringAsFixed(decimals);
    final parts = rounded.split('.');
    final whole = parts[0];
    final decimal = parts.length > 1 ? parts[1] : '';

    final buffer = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      final reverseIndex = whole.length - i;
      buffer.write(whole[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    final number =
        decimals > 0 ? '${buffer.toString()}.$decimal' : buffer.toString();
    return '${isNegative ? '-' : ''}$_currencySymbol$number';
  }

  List<double> _quickAmounts() {
    final available = _availableToWithdraw;
    final candidates = <double>[
      250,
      500,
      1000,
      available * 0.25,
      available * 0.50,
    ];

    final unique = <int>{};
    final result = <double>[];

    for (final value in candidates) {
      final rounded = ((value / 10).round() * 10).toInt();
      if (rounded <= 0 || rounded >= available) {
        continue;
      }
      if (unique.add(rounded)) {
        result.add(rounded.toDouble());
      }
      if (result.length == 4) {
        break;
      }
    }

    if (result.isEmpty && available > 10) {
      result.add((available * 0.25).clamp(10, available).toDouble());
    }

    return result;
  }

  String _dateLabel(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _buildReceiptId() {
    final code = DateTime.now().millisecondsSinceEpoch % 1000000;
    return 'WD-${code.toString().padLeft(6, '0')}';
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _pickScheduledDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime(now.year, now.month, now.day + 1),
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() => _scheduledDate = picked);
    }
  }

  bool _validateForSubmission({required bool showMessage}) {
    if (_amount <= 0) {
      if (showMessage) {
        _showMessage('Enter a withdrawal amount greater than zero.');
      }
      return false;
    }

    if (_amount > _availableToWithdraw) {
      if (showMessage) {
        _showMessage(
          'Amount exceeds available balance in selected source.',
        );
      }
      return false;
    }

    if (_netCredit <= 0) {
      if (showMessage) {
        _showMessage('Net credited amount must be positive. Reduce amount.');
      }
      return false;
    }

    return true;
  }

  Future<void> _previewWithdrawal() async {
    if (!_validateForSubmission(showMessage: true)) {
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Withdrawal Preview',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              _previewRow('Source', '${_source.assetType} Pool'),
              _previewRow('Destination', _destination.subtitle),
              _previewRow('Mode', _selectedMode),
              _previewRow('Gross Amount', _money(_amount, decimals: 2)),
              _previewRow('Platform Fee', _money(_fee, decimals: 2)),
              _previewRow('Tax Estimate', _money(_taxEstimate, decimals: 2)),
              _previewRow('Net Credit', _money(_netCredit, decimals: 2)),
              if (_selectedMode == 'Scheduled')
                _previewRow('Payout Date', _dateLabel(_scheduledDate)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _cardDeep,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _remarkController.text.trim().isEmpty
                      ? 'No remark added.'
                      : _remarkController.text.trim(),
                  style: const TextStyle(
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _lime,
                    foregroundColor: const Color(0xFF102A00),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close Preview',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _previewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitWithdrawal() async {
    if (!_validateForSubmission(showMessage: true)) {
      return;
    }

    setState(() => _isProcessing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    if (!mounted) {
      return;
    }

    final receipt = _buildReceiptId();
    setState(() {
      _isProcessing = false;
      _receiptId = receipt;
    });

    _showMessage(
      _selectedMode == 'Scheduled'
          ? 'Withdrawal scheduled successfully.'
          : 'Withdrawal submitted successfully.',
    );

    widget.onWithdrawn?.call();
  }

  Future<void> _copyReceipt() async {
    final receipt = _receiptId;
    if (receipt == null) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: receipt));
    _showMessage('Receipt id copied.');
  }

  @override
  Widget build(BuildContext context) {
    final quickAmounts = _quickAmounts();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Move invested gains to your bank or wallet in a few taps.',
          style: TextStyle(
            color: _textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _lime.withOpacity(0.14)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available to Withdraw',
                style: TextStyle(
                  color: _textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _money(_availableToWithdraw, decimals: 2),
                style: const TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _pill('Source ${_source.assetType}'),
                  _pill('Net ${_money(_netCredit, decimals: 2)}'),
                  _pill(_selectedMode),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Source allocation',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 112,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _sourceOptions.length,
            itemBuilder: (_, i) {
              final source = _sourceOptions[i];
              final selected = i == _selectedSourceIndex;
              return Padding(
                padding: EdgeInsets.only(
                    right: i < _sourceOptions.length - 1 ? 10 : 0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSourceIndex = i;
                      _receiptId = null;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 168,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected ? _cardDeep : _cardDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? _lime.withOpacity(0.55)
                            : _lime.withOpacity(0.14),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          source.assetType,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Current ${_money(source.currentValue, decimals: 0)}',
                          style: const TextStyle(
                            color: _textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Liquid ${_money(_liquidAvailable(source), decimals: 0)}',
                          style: TextStyle(
                            color: selected ? _lime : _textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _lime.withOpacity(0.14)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Amount to withdraw',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  prefixText: _currencySymbol,
                  prefixStyle: const TextStyle(
                    color: _textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                  hintText: '0.00',
                  hintStyle: TextStyle(color: _textMuted.withOpacity(0.55)),
                  filled: true,
                  fillColor: _cardDeep,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) => setState(() {
                  _receiptId = null;
                }),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: quickAmounts
                    .map(
                      (value) => ActionChip(
                        onPressed: () {
                          _amountController.text = value.toStringAsFixed(0);
                          setState(() {
                            _receiptId = null;
                          });
                        },
                        backgroundColor: _cardDeep,
                        side: BorderSide(color: _lime.withOpacity(0.18)),
                        label: Text(
                          _money(value, decimals: 0),
                          style: const TextStyle(
                            color: _textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _remarkController,
                maxLines: 2,
                style: const TextStyle(color: _textPrimary),
                decoration: InputDecoration(
                  hintText: 'Remark (optional)',
                  hintStyle: TextStyle(color: _textMuted.withOpacity(0.55)),
                  filled: true,
                  fillColor: _cardDeep,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Destination',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: List.generate(_destinations.length, (i) {
            final item = _destinations[i];
            final selected = i == _selectedDestinationIndex;

            return Padding(
              padding: EdgeInsets.only(
                  bottom: i < _destinations.length - 1 ? 10 : 0),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  setState(() {
                    _selectedDestinationIndex = i;
                    _receiptId = null;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected ? _cardDeep : _cardDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? _lime.withOpacity(0.55)
                          : _lime.withOpacity(0.14),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, color: _lime, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                color: _textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle,
                              style: const TextStyle(
                                color: _textMuted,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        item.eta,
                        style: const TextStyle(
                          color: _textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        const Text(
          'Withdrawal mode',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _modes
              .map(
                (mode) => ChoiceChip(
                  label: Text(mode),
                  selected: _selectedMode == mode,
                  onSelected: (_) {
                    setState(() {
                      _selectedMode = mode;
                      _receiptId = null;
                    });
                  },
                  selectedColor: _lime,
                  backgroundColor: _cardDark,
                  side: BorderSide(color: _lime.withOpacity(0.20)),
                  labelStyle: TextStyle(
                    color: _selectedMode == mode ? _cardDark : _textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
              .toList(),
        ),
        if (_selectedMode == 'Scheduled') ...[
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _pickScheduledDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _cardDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _lime.withOpacity(0.14)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_rounded, color: _lime),
                  const SizedBox(width: 10),
                  const Text(
                    'Payout date',
                    style: TextStyle(
                      color: _textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _dateLabel(_scheduledDate),
                    style: const TextStyle(
                      color: _textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _lime.withOpacity(0.12)),
          ),
          child: Column(
            children: [
              SwitchListTile.adaptive(
                value: _notifyEmail,
                onChanged: (value) => setState(() => _notifyEmail = value),
                activeColor: _lime,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Email confirmation',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: const Text(
                  'Send payout receipt to your email.',
                  style: TextStyle(
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Divider(height: 6, color: Color(0xFF22361A)),
              SwitchListTile.adaptive(
                value: _saveAsTemplate,
                onChanged: (value) => setState(() => _saveAsTemplate = value),
                activeColor: _lime,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Save as quick template',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: const Text(
                  'Reuse source and destination next time.',
                  style: TextStyle(
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _lime.withOpacity(0.14)),
          ),
          child: Column(
            children: [
              _summaryRow('Withdraw Amount', _money(_amount, decimals: 2)),
              _summaryRow('Platform Fee', _money(_fee, decimals: 2)),
              _summaryRow('Tax Estimate', _money(_taxEstimate, decimals: 2)),
              _summaryRow('Net Credit', _money(_netCredit, decimals: 2),
                  valueColor: _lime),
              const Divider(height: 18, color: Color(0xFF22361A)),
              _summaryRow(
                'Balance After',
                _money(_bufferAfterWithdrawal, decimals: 2),
                valueColor: _bufferAfterWithdrawal >= 0 ? _textPrimary : _red,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _previewWithdrawal,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _textPrimary,
                  side: BorderSide(color: _lime.withOpacity(0.30)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Preview',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _submitWithdrawal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _lime,
                  foregroundColor: const Color(0xFF102A00),
                  disabledBackgroundColor: _lime.withOpacity(0.55),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Color(0xFF102A00),
                        ),
                      )
                    : Text(
                        _selectedMode == 'Scheduled' ? 'Schedule' : 'Withdraw',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ],
        ),
        if (_receiptId != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _lime.withOpacity(0.24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Latest Withdrawal',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Receipt $_receiptId',
                  style: const TextStyle(
                    color: _textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _copyReceipt,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _cardDeep,
                          foregroundColor: _textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text(
                          'Copy Receipt',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _cardDeep,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _lime.withOpacity(0.16)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _textMuted,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? _textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _WithdrawDestination {
  const _WithdrawDestination({
    required this.title,
    required this.subtitle,
    required this.eta,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String eta;
  final IconData icon;
}

class _SourceOption {
  const _SourceOption({
    required this.assetType,
    required this.currentValue,
    required this.investedValue,
  });

  final String assetType;
  final double currentValue;
  final double investedValue;
}
