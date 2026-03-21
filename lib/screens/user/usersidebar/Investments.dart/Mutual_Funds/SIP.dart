import 'package:flutter/material.dart';

class MutualFundSipTab extends StatefulWidget {
  const MutualFundSipTab({
    super.key,
    required this.onMessage,
  });

  final ValueChanged<String> onMessage;

  @override
  State<MutualFundSipTab> createState() => _MutualFundSipTabState();
}

class _MutualFundSipTabState extends State<MutualFundSipTab> {
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  final TextEditingController _amountController =
      TextEditingController(text: '5000');

  final List<String> _frequencies = const ['Weekly', 'Monthly', 'Quarterly'];
  final List<String> _fundOptions = const [
    'HDFC Mid Cap Opportunities',
    'Parag Parikh Flexi Cap',
    'Nifty 50 Index Direct',
  ];

  int _selectedFund = 0;
  String _selectedFrequency = 'Monthly';
  DateTime _startDate = DateTime.now().add(const Duration(days: 5));
  bool _autoIncrease = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
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
      initialDate: _startDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 3),
    );

    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _createSip() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      widget.onMessage('Enter a valid SIP amount.');
      return;
    }

    setState(() => _isSaving = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    widget.onMessage('SIP created successfully.');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                'Create SIP Plan',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _selectedFund,
                dropdownColor: _cardDeep,
                isExpanded: true,
                decoration: _fieldDecoration('Choose fund'),
                items: List.generate(_fundOptions.length, (index) {
                  return DropdownMenuItem(
                    value: index,
                    child: Text(
                      _fundOptions[index],
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedFund = value);
                  }
                },
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
                decoration: _fieldDecoration('Amount').copyWith(
                  prefixText: '\$ ',
                  prefixStyle: const TextStyle(
                    color: _textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _frequencies.map((frequency) {
                  return ChoiceChip(
                    label: Text(frequency),
                    selected: _selectedFrequency == frequency,
                    onSelected: (_) {
                      setState(() => _selectedFrequency = frequency);
                    },
                    selectedColor: _lime,
                    backgroundColor: _cardDeep,
                    side: BorderSide(color: _lime.withOpacity(0.20)),
                    labelStyle: TextStyle(
                      color: _selectedFrequency == frequency
                          ? _cardDark
                          : _textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _cardDeep,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _lime.withOpacity(0.18)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded, color: _lime, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Start Date',
                        style: TextStyle(
                          color: _textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(_startDate),
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
              SwitchListTile.adaptive(
                value: _autoIncrease,
                onChanged: (value) => setState(() => _autoIncrease = value),
                activeColor: _lime,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Annual step-up',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                subtitle: const Text(
                  'Increase SIP by 10% every year.',
                  style: TextStyle(
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _createSip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _lime,
                    foregroundColor: const Color(0xFF102A00),
                    disabledBackgroundColor: _lime.withOpacity(0.55),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.3,
                            color: Color(0xFF102A00),
                          ),
                        )
                      : const Text(
                          'Create SIP',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Upcoming SIPs',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        ..._upcomingPlans().map((plan) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _lime.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _cardDeep,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.schedule_rounded,
                        color: _lime, size: 19),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.fund,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${plan.frequency} | Next ${plan.nextDate}',
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
                    '\$${plan.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: _lime,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: _textMuted,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: _cardDeep,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _lime.withOpacity(0.18)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _lime.withOpacity(0.40)),
      ),
    );
  }

  List<_SipPlan> _upcomingPlans() {
    return const [
      _SipPlan(
        fund: 'HDFC Mid Cap Opportunities',
        amount: 6000,
        frequency: 'Monthly',
        nextDate: 'Mar 25',
      ),
      _SipPlan(
        fund: 'Parag Parikh Flexi Cap',
        amount: 4500,
        frequency: 'Monthly',
        nextDate: 'Mar 29',
      ),
      _SipPlan(
        fund: 'Nifty 50 Index Direct',
        amount: 5000,
        frequency: 'Monthly',
        nextDate: 'Apr 03',
      ),
    ];
  }
}

class _SipPlan {
  const _SipPlan({
    required this.fund,
    required this.amount,
    required this.frequency,
    required this.nextDate,
  });

  final String fund;
  final double amount;
  final String frequency;
  final String nextDate;
}
