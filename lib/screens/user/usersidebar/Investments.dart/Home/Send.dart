import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/dashboard_seed_data.dart';

class InvestmentSendPage extends StatelessWidget {
  const InvestmentSendPage({super.key});

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
          'Send Funds',
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
              child: InvestmentSendContent(),
            ),
          ),
        ],
      ),
    );
  }
}

class InvestmentSendContent extends StatefulWidget {
  const InvestmentSendContent({super.key, this.onSent});

  final VoidCallback? onSent;

  @override
  State<InvestmentSendContent> createState() => _InvestmentSendContentState();
}

class _InvestmentSendContentState extends State<InvestmentSendContent> {
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);
  static const Color _red = Color(0xFFE67A62);

  final List<String> _transferModes = const ['Instant', 'Scheduled', 'SIP'];

  final List<_SendRecipient> _recipients = const [
    _SendRecipient(
      name: 'Aarav Mehta',
      subtitle: 'Co-investor',
      accountHint: 'ID • 9001',
    ),
    _SendRecipient(
      name: 'Maya Johnson',
      subtitle: 'Family Portfolio',
      accountHint: 'ID • 7412',
    ),
    _SendRecipient(
      name: 'Leo Chen',
      subtitle: 'Goal Partner',
      accountHint: 'ID • 3328',
    ),
  ];

  final List<String> _sourceAccounts = const [
    'Investment Wallet',
    'Primary Bank Account',
    'Brokerage Cash Balance',
  ];

  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  int _selectedRecipientIndex = 0;
  int _selectedSourceIndex = 0;
  String _selectedMode = 'Instant';
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 1));

  bool _saveRecipient = false;
  bool _sendConfirmation = true;
  bool _isSending = false;
  String? _referenceId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '1000');
    _noteController = TextEditingController(text: 'Investment transfer');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
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

  double get _availableBalance {
    return seedInvestmentHoldings.fold<double>(
      0,
      (sum, item) => sum + item.currentValue,
    );
  }

  double get _amount => double.tryParse(_amountController.text.trim()) ?? 0;

  _SendRecipient get _recipient {
    return _recipients[
        _selectedRecipientIndex.clamp(0, _recipients.length - 1)];
  }

  double get _fee {
    final amount = _amount;
    if (amount <= 0) {
      return 0;
    }

    switch (_selectedMode) {
      case 'Instant':
        return math.max(2.0, amount * 0.0030);
      case 'Scheduled':
        return math.max(1.0, amount * 0.0010);
      case 'SIP':
        return math.max(1.0, amount * 0.0005);
      default:
        return 0;
    }
  }

  double get _totalDebit => _amount + _fee;

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

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() => _scheduledDate = picked);
    }
  }

  String _buildRef() {
    final code = DateTime.now().millisecondsSinceEpoch % 1000000;
    return 'TXN-${code.toString().padLeft(6, '0')}';
  }

  Future<void> _previewTransfer() async {
    if (_amount <= 0) {
      _showMessage('Enter a valid transfer amount first.');
      return;
    }
    if (_totalDebit > _availableBalance) {
      _showMessage('Insufficient available balance for this transfer.');
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
                'Transfer Preview',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              _previewRow('Mode', _selectedMode),
              _previewRow(
                  'To', '${_recipient.name} (${_recipient.accountHint})'),
              _previewRow('From', _sourceAccounts[_selectedSourceIndex]),
              _previewRow('Amount', _money(_amount, decimals: 2)),
              _previewRow('Fee', _money(_fee, decimals: 2)),
              _previewRow('Total Debit', _money(_totalDebit, decimals: 2)),
              if (_selectedMode != 'Instant')
                _previewRow('Date', _dateLabel(_scheduledDate)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _cardDeep,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _noteController.text.trim().isEmpty
                      ? 'No note added.'
                      : _noteController.text.trim(),
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

  Future<void> _sendNow() async {
    if (_amount <= 0) {
      _showMessage('Enter amount greater than zero.');
      return;
    }
    if (_totalDebit > _availableBalance) {
      _showMessage(
          'Insufficient balance. Lower amount or choose smaller transfer.');
      return;
    }

    setState(() => _isSending = true);
    await Future.delayed(const Duration(milliseconds: 850));
    if (!mounted) {
      return;
    }

    final ref = _buildRef();
    setState(() {
      _isSending = false;
      _referenceId = ref;
    });

    _showMessage(_selectedMode == 'Instant'
        ? 'Transfer sent successfully. Ref: $ref'
        : 'Transfer scheduled successfully. Ref: $ref');

    widget.onSent?.call();
  }

  Future<void> _copyReference() async {
    if (_referenceId == null || _referenceId!.isEmpty) {
      _showMessage('Send a transfer first to copy reference ID.');
      return;
    }
    await Clipboard.setData(ClipboardData(text: _referenceId!));
    _showMessage('Reference copied: $_referenceId');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerCard(),
        const SizedBox(height: 18),
        const Text(
          'Recipient',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 105,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recipients.length,
            itemBuilder: (_, index) {
              final recipient = _recipients[index];
              final selected = index == _selectedRecipientIndex;

              return Padding(
                padding: EdgeInsets.only(
                    right: index < _recipients.length - 1 ? 10 : 0),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRecipientIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 192,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _cardDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? _lime.withOpacity(0.5)
                            : _lime.withOpacity(0.12),
                        width: selected ? 1.6 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: _cardDeep,
                          child: Text(
                            recipient.name.substring(0, 1),
                            style: const TextStyle(
                              color: _lime,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                recipient.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                recipient.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _textMuted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
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
        const SizedBox(height: 18),
        _detailsCard(),
        const SizedBox(height: 8),
        _switchTile(
          title: 'Save recipient for future transfers',
          subtitle: 'Keeps recipient in your frequent transfer list',
          value: _saveRecipient,
          onChanged: (value) => setState(() => _saveRecipient = value),
        ),
        const SizedBox(height: 8),
        _switchTile(
          title: 'Send confirmation notification',
          subtitle: 'Notifies you when transfer is processed',
          value: _sendConfirmation,
          onChanged: (value) => setState(() => _sendConfirmation = value),
        ),
        const SizedBox(height: 12),
        _summaryCard(),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _previewTransfer,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _lime.withOpacity(0.32)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Preview',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _lime,
                  foregroundColor: const Color(0xFF102A00),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF102A00)),
                        ),
                      )
                    : Text(
                        _selectedMode == 'Instant' ? 'Send Now' : 'Schedule',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: _copyReference,
            child: const Text(
              'Copy Reference ID',
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerCard() {
    final available = _availableBalance;
    final lowBalance = available < _totalDebit;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_cardDark, _cardDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _lime.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Move investment funds quickly and securely',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Available: ${_money(available, decimals: 2)}',
            style: TextStyle(
              color: lowBalance ? _red : _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _transferModes
                .map(
                  (mode) => ChoiceChip(
                    label: Text(mode),
                    selected: _selectedMode == mode,
                    onSelected: (_) => setState(() => _selectedMode = mode),
                    selectedColor: _lime,
                    backgroundColor: _cardDeep,
                    labelStyle: TextStyle(
                      color: _selectedMode == mode ? _cardDark : _textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _detailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _lime.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textField(
            controller: _amountController,
            label: 'Amount',
            icon: Icons.payments_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixText: _currencySymbol,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            value: _selectedSourceIndex,
            dropdownColor: _cardDeep,
            iconEnabledColor: _lime,
            style: const TextStyle(color: _textPrimary),
            decoration: InputDecoration(
              labelText: 'Source Account',
              labelStyle: const TextStyle(color: _textMuted),
              filled: true,
              fillColor: _cardDeep,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _lime.withOpacity(0.18)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _lime.withOpacity(0.18)),
              ),
            ),
            items: List.generate(
              _sourceAccounts.length,
              (index) => DropdownMenuItem<int>(
                value: index,
                child: Text(_sourceAccounts[index]),
              ),
            ),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedSourceIndex = value);
              }
            },
          ),
          const SizedBox(height: 10),
          _textField(
            controller: _noteController,
            label: 'Note',
            icon: Icons.notes_rounded,
          ),
          if (_selectedMode != 'Instant') ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _cardDeep,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _lime.withOpacity(0.18)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, color: _lime),
                    const SizedBox(width: 8),
                    const Text(
                      'Transfer Date',
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
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...[100, 250, 500, 1000].map(
                  (v) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text('+${_money(v.toDouble())}'),
                      onPressed: () {
                        final next = _amount + v.toDouble();
                        _amountController.text = next.toStringAsFixed(0);
                        setState(() {});
                      },
                      labelStyle: const TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      backgroundColor: _cardDeep,
                      side: BorderSide(color: _lime.withOpacity(0.25)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? prefixText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: _textPrimary,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textMuted),
        prefixText: prefixText,
        prefixStyle: const TextStyle(
          color: _lime,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Icon(icon, color: _lime, size: 20),
        filled: true,
        fillColor: _cardDeep,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _lime.withOpacity(0.18)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _lime.withOpacity(0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _lime.withOpacity(0.45)),
        ),
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _lime.withOpacity(0.10)),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: _textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: _lime,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  Widget _summaryCard() {
    final availableAfter = _availableBalance - _totalDebit;
    final highImpact = _totalDebit > (_availableBalance * 0.25);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _lime.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transfer Summary',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          _summaryRow('Recipient', _recipient.name),
          _summaryRow('Mode', _selectedMode),
          _summaryRow('Amount', _money(_amount, decimals: 2)),
          _summaryRow('Fee', _money(_fee, decimals: 2)),
          _summaryRow('Total', _money(_totalDebit, decimals: 2)),
          _summaryRow(
            'Balance After',
            _money(availableAfter, decimals: 2),
            valueColor: availableAfter < 0 ? _red : _textPrimary,
          ),
          _summaryRow(
            'Impact',
            highImpact ? 'High' : 'Normal',
            valueColor: highImpact ? const Color(0xFFFBBF24) : _lime,
          ),
          if (_referenceId != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _cardDeep,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Reference: $_referenceId',
                style: const TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    Color valueColor = _textPrimary,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SendRecipient {
  const _SendRecipient({
    required this.name,
    required this.subtitle,
    required this.accountHint,
  });

  final String name;
  final String subtitle;
  final String accountHint;
}
