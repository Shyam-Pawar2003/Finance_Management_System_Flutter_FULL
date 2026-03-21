import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../data/dashboard_seed_data.dart';
import '../../../../models/dashboard_models.dart';

class SetupAutoDebitPage extends StatelessWidget {
  const SetupAutoDebitPage({super.key});

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
          'Setup Auto-Debit',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 26,
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
              child: SetupAutoDebitContent(),
            ),
          ),
        ],
      ),
    );
  }
}

class SetupAutoDebitContent extends StatefulWidget {
  const SetupAutoDebitContent({super.key, this.onPlanSaved});

  final VoidCallback? onPlanSaved;

  @override
  State<SetupAutoDebitContent> createState() => _SetupAutoDebitContentState();
}

class _SetupAutoDebitContentState extends State<SetupAutoDebitContent> {
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  final List<String> _frequencies = const ['Weekly', 'Bi-Weekly', 'Monthly'];
  final List<_FundingAccount> _accounts = const [
    _FundingAccount(name: 'Primary Bank Account', icon: Icons.account_balance),
    _FundingAccount(name: 'Salary Account', icon: Icons.work_outline_rounded),
    _FundingAccount(name: 'Wallet Balance', icon: Icons.account_balance_wallet),
  ];

  late final TextEditingController _amountController;
  late DateTime _startDate;

  bool _autoDebitEnabled = true;
  bool _notifyBefore = true;
  bool _notifySuccess = true;
  bool _notifyFailure = true;
  bool _isSaving = false;

  int _selectedGoalIndex = 0;
  int _selectedAccountIndex = 0;
  int _monthlyDay = 5;
  String _selectedFrequency = 'Monthly';

  List<SavingsGoal> get _goals => seedSavingsGoals;

  SavingsGoal get _selectedGoal {
    if (_goals.isEmpty) {
      return SavingsGoal(
        name: 'No Goal',
        targetAmount: 0,
        currentAmount: 0,
        targetDate: DateTime(2099, 1, 1),
        suggestedAutoTransfer: 0,
      );
    }
    return _goals[_selectedGoalIndex.clamp(0, _goals.length - 1)];
  }

  double get _amount => double.tryParse(_amountController.text.trim()) ?? 0;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().add(const Duration(days: 1));
    _monthlyDay = math.min(28, math.max(1, _startDate.day));
    _amountController = TextEditingController(
      text: _selectedGoal.suggestedAutoTransfer.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
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

  String _money(double value, {int decimals = 0}) {
    final isNeg = value < 0;
    final rounded = value.abs().toStringAsFixed(decimals);
    final parts = rounded.split('.');
    final whole = parts[0];
    final dec = parts.length > 1 ? parts[1] : '';
    final buf = StringBuffer();

    for (int i = 0; i < whole.length; i++) {
      final reverseIndex = whole.length - i;
      buf.write(whole[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buf.write(',');
      }
    }

    final number = decimals > 0 ? '${buf.toString()}.$dec' : buf.toString();
    return '${isNeg ? '-' : ''}$_currencySymbol$number';
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  DateTime get _anchorDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
    return start.isAfter(today) ? start : today;
  }

  DateTime get _nextDebitDate {
    final anchor = _anchorDate;

    if (_selectedFrequency != 'Monthly') {
      return anchor;
    }

    DateTime candidate = DateTime(
      anchor.year,
      anchor.month,
      _safeDay(anchor.year, anchor.month, _monthlyDay),
    );

    if (candidate.isBefore(anchor)) {
      candidate = DateTime(
        anchor.year,
        anchor.month + 1,
        _safeDay(anchor.year, anchor.month + 1, _monthlyDay),
      );
    }

    return candidate;
  }

  int _safeDay(int year, int month, int day) {
    final last = DateTime(year, month + 1, 0).day;
    return math.min(day, last);
  }

  double get _yearlyContribution {
    final multiplier = switch (_selectedFrequency) {
      'Weekly' => 52,
      'Bi-Weekly' => 26,
      _ => 12,
    };
    return _amount * multiplier;
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_selectedFrequency == 'Monthly') {
          _monthlyDay = math.min(28, math.max(1, _startDate.day));
        }
      });
    }
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

  Future<void> _previewPlan() async {
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
                'Plan Preview',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 14),
              _previewRow('Goal', _selectedGoal.name),
              _previewRow('Amount', _money(_amount, decimals: 2)),
              _previewRow('Frequency', _selectedFrequency),
              _previewRow(
                  'From account', _accounts[_selectedAccountIndex].name),
              _previewRow('Start date', _dateLabel(_startDate)),
              _previewRow('Next debit', _dateLabel(_nextDebitDate)),
              _previewRow('Yearly contribution', _money(_yearlyContribution)),
              const SizedBox(height: 16),
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
          const SizedBox(width: 10),
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

  Future<void> _savePlan() async {
    if (!_autoDebitEnabled) {
      _showMessage('Enable auto-debit first to save this plan.');
      return;
    }
    if (_amount <= 0) {
      _showMessage('Enter a valid amount greater than zero.');
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    _showMessage('Auto-debit plan saved successfully.');
    widget.onPlanSaved?.call();
  }

  void _runTestDebit() {
    if (!_autoDebitEnabled) {
      _showMessage('Enable auto-debit to test a debit run.');
      return;
    }
    if (_amount <= 0) {
      _showMessage('Set a valid debit amount first.');
      return;
    }
    _showMessage('Test debit initiated for ${_money(_amount)}.');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _autoDebitEnabled = !_autoDebitEnabled),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_cardDark, _cardDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _lime.withOpacity(0.18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _cardDeep,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.autorenew_rounded,
                    color: _autoDebitEnabled ? _lime : _textMuted,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto-debit Status',
                        style: TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tap card or switch to enable/disable',
                        style: TextStyle(
                          color: _textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _autoDebitEnabled,
                  onChanged: (value) =>
                      setState(() => _autoDebitEnabled = value),
                  activeColor: _lime,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Choose Goal',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 145,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _goals.length,
            itemBuilder: (_, index) {
              final goal = _goals[index];
              final selected = index == _selectedGoalIndex;
              final progress = goal.progress.clamp(0.0, 1.0);
              return Padding(
                padding:
                    EdgeInsets.only(right: index < _goals.length - 1 ? 10 : 0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGoalIndex = index;
                      _amountController.text =
                          goal.suggestedAutoTransfer.toStringAsFixed(0);
                    });
                    _showMessage('${goal.name} selected for auto-debit.');
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 190,
                    padding: const EdgeInsets.all(12),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Suggested ${_money(goal.suggestedAutoTransfer)}',
                          style: const TextStyle(
                            color: _textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: Colors.black.withOpacity(0.25),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(_lime),
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
        const SizedBox(height: 22),
        const Text(
          'Debit Configuration',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        Container(
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
              TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  labelText: 'Debit Amount',
                  labelStyle: const TextStyle(color: _textMuted),
                  prefixText: _currencySymbol,
                  prefixStyle: const TextStyle(
                    color: _lime,
                    fontWeight: FontWeight.w700,
                  ),
                  filled: true,
                  fillColor: _cardDeep,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _lime.withOpacity(0.20)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _lime.withOpacity(0.20)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _lime.withOpacity(0.40)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ActionChip(
                      label: const Text('Use Suggested'),
                      onPressed: () {
                        _amountController.text = _selectedGoal
                            .suggestedAutoTransfer
                            .toStringAsFixed(0);
                        setState(() {});
                      },
                      labelStyle: const TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      backgroundColor: _cardDeep,
                      side: BorderSide(color: _lime.withOpacity(0.20)),
                    ),
                    const SizedBox(width: 8),
                    ...[100, 250, 500, 1000].map(
                      (value) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text('+${_money(value.toDouble())}'),
                          onPressed: () {
                            final next = _amount + value.toDouble();
                            _amountController.text = next.toStringAsFixed(0);
                            setState(() {});
                          },
                          labelStyle: const TextStyle(
                            color: _textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          backgroundColor: _cardDeep,
                          side: BorderSide(color: _lime.withOpacity(0.20)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _frequencies
                    .map(
                      (item) => ChoiceChip(
                        label: Text(item),
                        selected: _selectedFrequency == item,
                        onSelected: (_) =>
                            setState(() => _selectedFrequency = item),
                        selectedColor: _lime,
                        backgroundColor: _cardDeep,
                        labelStyle: TextStyle(
                          color: _selectedFrequency == item
                              ? _cardDark
                              : _textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                    .toList(),
              ),
              if (_selectedFrequency == 'Monthly') ...[
                const SizedBox(height: 12),
                Text(
                  'Debit day: $_monthlyDay',
                  style: const TextStyle(
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Slider(
                  value: _monthlyDay.toDouble(),
                  min: 1,
                  max: 28,
                  divisions: 27,
                  activeColor: _lime,
                  inactiveColor: _textMuted.withOpacity(0.25),
                  label: _monthlyDay.toString(),
                  onChanged: (value) =>
                      setState(() => _monthlyDay = value.round()),
                ),
              ],
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickStartDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _cardDeep,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _lime.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: _lime),
                      const SizedBox(width: 8),
                      const Text(
                        'Start date',
                        style: TextStyle(
                          color: _textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _dateLabel(_startDate),
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
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Funding Account',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        ...List.generate(_accounts.length, (index) {
          final account = _accounts[index];
          final selected = index == _selectedAccountIndex;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedAccountIndex = index);
                _showMessage('${account.name} selected.');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? _lime.withOpacity(0.45)
                        : _lime.withOpacity(0.12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(account.icon, color: selected ? _lime : _textMuted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        account.name,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: selected ? _lime : _textMuted,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 14),
        const Text(
          'Notifications',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        _notificationTile(
          label: 'Notify 24 hours before debit',
          value: _notifyBefore,
          onChanged: (value) => setState(() => _notifyBefore = value),
        ),
        _notificationTile(
          label: 'Notify after successful debit',
          value: _notifySuccess,
          onChanged: (value) => setState(() => _notifySuccess = value),
        ),
        _notificationTile(
          label: 'Notify on failed debit',
          value: _notifyFailure,
          onChanged: (value) => setState(() => _notifyFailure = value),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: _previewPlan,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _lime.withOpacity(0.14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Plan Preview',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Next debit: ${_dateLabel(_nextDebitDate)}',
                  style: const TextStyle(
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Estimated yearly contribution: ${_money(_yearlyContribution)}',
                  style: const TextStyle(
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.visibility_rounded, color: _lime, size: 16),
                    const SizedBox(width: 6),
                    const Text(
                      'Tap to review full plan',
                      style: TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _runTestDebit,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _lime.withOpacity(0.35)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Run Test',
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
                onPressed: _isSaving ? null : _savePlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _lime,
                  foregroundColor: const Color(0xFF102A00),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
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
                        'Save Plan',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _notificationTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _lime.withOpacity(0.10)),
        ),
        child: SwitchListTile(
          title: Text(
            label,
            style: const TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          value: value,
          onChanged: onChanged,
          activeColor: _lime,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}

class _FundingAccount {
  const _FundingAccount({required this.name, required this.icon});

  final String name;
  final IconData icon;
}
