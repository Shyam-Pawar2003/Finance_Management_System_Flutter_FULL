import 'package:flutter/material.dart';

import '../../../data/dashboard_seed_data.dart';
import '../../../models/dashboard_models.dart';
import 'Quick_Actions_Planner/Setup_Auto_debit.dart';

class GoalsPlannerTab extends StatefulWidget {
  const GoalsPlannerTab({super.key});

  @override
  State<GoalsPlannerTab> createState() => _GoalsPlannerTabState();
}

class _GoalsPlannerTabState extends State<GoalsPlannerTab> {
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);
  static const Color _orange = Color(0xFFFBBF24);
  static const Color _red = Color(0xFFE67A62);

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

  int _daysLeft(DateTime target) {
    final now = DateTime.now();
    return target.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  void _showDeadlineOptions(SavingsGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${goal.name} - Deadline Actions',
              style: const TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            _actionButton(
              icon: Icons.notifications_active_rounded,
              label: 'Set Reminder',
              onTap: () {
                Navigator.pop(context);
                _showMessage('Reminder set for ${goal.name}');
              },
            ),
            _actionButton(
              icon: Icons.edit_calendar_rounded,
              label: 'Change Deadline',
              onTap: () {
                Navigator.pop(context);
                _showMessage('Deadline editor will open soon');
              },
            ),
            _actionButton(
              icon: Icons.speed_rounded,
              label: 'Boost Savings Plan',
              onTap: () {
                Navigator.pop(context);
                _showMessage('Savings boost activated');
              },
            ),
            _actionButton(
              icon: Icons.close_rounded,
              label: 'Close',
              onTap: () => Navigator.pop(context),
              isClose: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isClose = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _cardDeep,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isClose
                  ? _textMuted.withOpacity(0.2)
                  : _lime.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: isClose ? _textMuted : _lime, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isClose ? _textMuted : _textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: isClose ? _textMuted : _lime, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goals = [...seedSavingsGoals]
      ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
    final monthlyPlan =
        goals.fold<double>(0, (sum, goal) => sum + goal.suggestedAutoTransfer);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showMessage('Monthly plan: ${_money(monthlyPlan)}'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_cardDark, _cardDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _lime.withOpacity(0.16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _cardDeep,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: _lime,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Planning Overview',
                            style: TextStyle(
                              color: _textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Recommended monthly transfer: ${_money(monthlyPlan)}',
                            style: const TextStyle(
                              color: _textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Upcoming Deadlines',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 12),
        ...goals.take(5).map(
              (goal) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _deadlineTile(goal),
              ),
            ),
        const SizedBox(height: 20),
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SetupAutoDebitPage(),
              ),
            );
          },
          child: _quickActionCard(
            icon: Icons.auto_awesome_rounded,
            title: 'Setup Auto-Debit',
            subtitle: 'Automate your goal savings',
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showMessage('Alerts configured for all goals'),
          child: _quickActionCard(
            icon: Icons.notifications_none_rounded,
            title: 'Enable Alerts',
            subtitle: 'Get reminders before deadlines',
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showMessage('Dashboard refresh initiated'),
          child: _quickActionCard(
            icon: Icons.refresh_rounded,
            title: 'Refresh Plans',
            subtitle: 'Update all goal calculations',
          ),
        ),
      ],
    );
  }

  Widget _deadlineTile(SavingsGoal goal) {
    final days = _daysLeft(goal.targetDate);
    final isUrgent = days >= 0 && days <= 30;
    final overdue = days < 0;

    final tagColor = overdue
        ? _red
        : isUrgent
            ? _orange
            : _lime;
    final tagText = overdue
        ? 'Overdue'
        : days == 0
            ? 'Due today'
            : '$days days left';

    return GestureDetector(
      onTap: () => _showDeadlineOptions(goal),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: overdue ? _red.withOpacity(0.2) : _lime.withOpacity(0.10),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _cardDeep,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.event_available_rounded,
                color: tagColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.name,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Monthly transfer: ${_money(goal.suggestedAutoTransfer)}',
                    style: const TextStyle(
                      color: _textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tagColor.withOpacity(0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                tagText,
                style: TextStyle(
                  color: tagColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _lime.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _cardDeep,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _lime, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: _textMuted, size: 16),
        ],
      ),
    );
  }
}
