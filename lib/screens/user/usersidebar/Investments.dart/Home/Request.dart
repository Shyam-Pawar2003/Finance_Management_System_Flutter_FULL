import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/dashboard_seed_data.dart';
import '../../../models/dashboard_models.dart';

class InvestmentRequestPage extends StatelessWidget {
  const InvestmentRequestPage({super.key});

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
          'Request Funds',
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
              child: InvestmentRequestContent(),
            ),
          ),
        ],
      ),
    );
  }
}

class InvestmentRequestContent extends StatefulWidget {
  const InvestmentRequestContent({super.key, this.onRequestCreated});

  final VoidCallback? onRequestCreated;

  @override
  State<InvestmentRequestContent> createState() =>
      _InvestmentRequestContentState();
}

class _InvestmentRequestContentState extends State<InvestmentRequestContent> {
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);
  static const Color _red = Color(0xFFE67A62);

  final List<String> _requestTypes = const [
    'Contribution',
    'Settlement',
    'Custom',
  ];

  final List<_RequestContact> _contacts = const [
    _RequestContact(
      name: 'Alex Morgan',
      subtitle: 'Investment Partner',
      email: 'alex@example.com',
    ),
    _RequestContact(
      name: 'Nina Shah',
      subtitle: 'Family Wallet',
      email: 'nina@example.com',
    ),
    _RequestContact(
      name: 'Ryan Patel',
      subtitle: 'SIP Group',
      email: 'ryan@example.com',
    ),
  ];

  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  int _selectedContactIndex = 0;
  int _selectedGoalIndex = 0;
  String _selectedType = 'Contribution';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));

  bool _allowPartialPayment = false;
  bool _sendReminder = true;
  bool _isCreating = false;
  String? _createdCode;

  @override
  void initState() {
    super.initState();
    final initialAmount = seedSavingsGoals.isNotEmpty
        ? seedSavingsGoals.first.suggestedAutoTransfer
        : 500;
    _amountController =
        TextEditingController(text: initialAmount.toStringAsFixed(0));
    _noteController =
        TextEditingController(text: 'Monthly investment contribution');
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

  SavingsGoal? get _selectedGoal {
    if (seedSavingsGoals.isEmpty) {
      return null;
    }
    return seedSavingsGoals[
        _selectedGoalIndex.clamp(0, seedSavingsGoals.length - 1)];
  }

  _RequestContact get _selectedContact {
    return _contacts[_selectedContactIndex.clamp(0, _contacts.length - 1)];
  }

  double get _amount {
    return double.tryParse(_amountController.text.trim()) ?? 0;
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

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  String _buildRequestCode() {
    final millis = DateTime.now().millisecondsSinceEpoch;
    final suffix = millis % 100000;
    return 'REQ-${suffix.toString().padLeft(5, '0')}';
  }

  Future<void> _previewRequest() async {
    if (_amount <= 0) {
      _showMessage('Enter a valid amount first.');
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
                'Request Preview',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              _previewRow('Type', _selectedType),
              _previewRow('To', _selectedContact.name),
              _previewRow('Amount', _money(_amount, decimals: 2)),
              _previewRow(
                'Goal',
                _selectedGoal?.name ?? 'General Portfolio',
              ),
              _previewRow('Due Date', _dateLabel(_dueDate)),
              _previewRow(
                  'Partial Payment', _allowPartialPayment ? 'Allowed' : 'No'),
              _previewRow('Reminder', _sendReminder ? 'Enabled' : 'Disabled'),
              const SizedBox(height: 12),
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
                    height: 1.35,
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

  Future<void> _createRequest() async {
    if (_amount <= 0) {
      _showMessage('Enter amount greater than zero.');
      return;
    }

    if (_contacts.isEmpty) {
      _showMessage('No recipient available for this request.');
      return;
    }

    setState(() => _isCreating = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) {
      return;
    }

    final code = _buildRequestCode();
    setState(() {
      _isCreating = false;
      _createdCode = code;
    });

    _showMessage('Request created successfully. Code: $code');
    widget.onRequestCreated?.call();
  }

  Future<void> _copyCode() async {
    if (_createdCode == null || _createdCode!.isEmpty) {
      _showMessage('Create a request first to copy the code.');
      return;
    }
    await Clipboard.setData(ClipboardData(text: _createdCode!));
    _showMessage('Request code copied: $_createdCode');
  }

  void _sendReminderNow() {
    if (_createdCode == null) {
      _showMessage('Create a request before sending reminder.');
      return;
    }
    _showMessage('Reminder sent to ${_selectedContact.name}.');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerCard(),
        const SizedBox(height: 18),
        const Text(
          'Select Recipient',
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
            itemCount: _contacts.length,
            itemBuilder: (_, index) {
              final contact = _contacts[index];
              final selected = index == _selectedContactIndex;

              return Padding(
                padding: EdgeInsets.only(
                    right: index < _contacts.length - 1 ? 10 : 0),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedContactIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 190,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _cardDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? _lime.withOpacity(0.50)
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
                            contact.name.substring(0, 1),
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
                                contact.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                contact.subtitle,
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
        _requestDetailsCard(),
        const SizedBox(height: 12),
        _switchCard(
          title: 'Allow partial payment',
          subtitle: 'Recipient can pay in multiple parts',
          value: _allowPartialPayment,
          onChanged: (value) => setState(() => _allowPartialPayment = value),
        ),
        const SizedBox(height: 8),
        _switchCard(
          title: 'Send auto reminder before due date',
          subtitle: 'A reminder is sent 24 hours before deadline',
          value: _sendReminder,
          onChanged: (value) => setState(() => _sendReminder = value),
        ),
        const SizedBox(height: 14),
        _summaryCard(),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _previewRequest,
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
                onPressed: _isCreating ? null : _createRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _lime,
                  foregroundColor: const Color(0xFF102A00),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCreating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF102A00)),
                        ),
                      )
                    : const Text(
                        'Create Request',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _copyCode,
                child: const Text(
                  'Copy Code',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: _sendReminderNow,
                child: const Text(
                  'Send Reminder',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _headerCard() {
    final amount = _amount;
    final urgencyDays = _dueDate.difference(DateTime.now()).inDays;

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
            'Create an investment request with smart reminders',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount > 0 ? _money(amount, decimals: 2) : _money(0, decimals: 2),
            style: const TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            urgencyDays < 0
                ? 'Due date passed'
                : urgencyDays == 0
                    ? 'Due today'
                    : 'Due in $urgencyDays days',
            style: TextStyle(
              color: urgencyDays <= 2 ? _red : _textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _requestTypes
                .map(
                  (type) => ChoiceChip(
                    label: Text(type),
                    selected: _selectedType == type,
                    onSelected: (_) => setState(() => _selectedType = type),
                    selectedColor: _lime,
                    backgroundColor: _cardDeep,
                    labelStyle: TextStyle(
                      color: _selectedType == type ? _cardDark : _textMuted,
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

  Widget _requestDetailsCard() {
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
            label: 'Request Amount',
            icon: Icons.payments_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixText: _currencySymbol,
          ),
          const SizedBox(height: 10),
          if (seedSavingsGoals.isNotEmpty)
            DropdownButtonFormField<int>(
              value: _selectedGoalIndex,
              dropdownColor: _cardDeep,
              iconEnabledColor: _lime,
              style: const TextStyle(color: _textPrimary),
              decoration: InputDecoration(
                labelText: 'Linked Goal',
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
                seedSavingsGoals.length,
                (index) => DropdownMenuItem<int>(
                  value: index,
                  child: Text(seedSavingsGoals[index].name),
                ),
              ),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _selectedGoalIndex = value;
                  _amountController.text = seedSavingsGoals[value]
                      .suggestedAutoTransfer
                      .toStringAsFixed(0);
                });
              },
            ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickDueDate,
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
                    'Due Date',
                    style: TextStyle(
                      color: _textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _dateLabel(_dueDate),
                    style: const TextStyle(
                      color: _textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _textField(
            controller: _noteController,
            label: 'Note',
            icon: Icons.notes_rounded,
          ),
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
                ActionChip(
                  label: const Text('Suggested'),
                  onPressed: () {
                    final suggested =
                        _selectedGoal?.suggestedAutoTransfer ?? 500;
                    _amountController.text = suggested.toStringAsFixed(0);
                    setState(() {});
                  },
                  labelStyle: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  backgroundColor: _cardDeep,
                  side: BorderSide(color: _lime.withOpacity(0.25)),
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

  Widget _switchCard({
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
    final daysLeft = _dueDate.difference(DateTime.now()).inDays;

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
            'Request Summary',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          _summaryRow('Recipient', _selectedContact.name),
          _summaryRow('Amount', _money(math.max(0.0, _amount), decimals: 2)),
          _summaryRow('Type', _selectedType),
          _summaryRow('Due', _dateLabel(_dueDate)),
          _summaryRow(
            'Status',
            daysLeft < 0
                ? 'Expired'
                : daysLeft <= 2
                    ? 'Urgent'
                    : 'Scheduled',
            valueColor: daysLeft < 0
                ? _red
                : daysLeft <= 2
                    ? const Color(0xFFFBBF24)
                    : _lime,
          ),
          if (_createdCode != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _cardDeep,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Request Code: $_createdCode',
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

class _RequestContact {
  const _RequestContact({
    required this.name,
    required this.subtitle,
    required this.email,
  });

  final String name;
  final String subtitle;
  final String email;
}
