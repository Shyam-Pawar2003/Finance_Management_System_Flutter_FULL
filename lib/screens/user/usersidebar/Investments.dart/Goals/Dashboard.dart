import 'package:flutter/material.dart';

import '../../../data/dashboard_seed_data.dart';
import '../../../models/dashboard_models.dart';

class GoalsDashboardTab extends StatefulWidget {
  const GoalsDashboardTab({super.key});

  @override
  State<GoalsDashboardTab> createState() => _GoalsDashboardTabState();
}

class _GoalsDashboardTabState extends State<GoalsDashboardTab> {
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  List<SavingsGoal> get _goals => seedSavingsGoals;

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

  double _progress(SavingsGoal goal) {
    if (goal.targetAmount <= 0) return 0;
    return (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
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

  Color _progressColor(double value) {
    if (value >= 1.0) return const Color(0xFF4ADE80);
    if (value >= 0.7) return _lime;
    if (value >= 0.4) return const Color(0xFFFBBF24);
    return const Color(0xFFE67A62);
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  void _showGoalDetails(SavingsGoal goal) {
    final progress = _progress(goal);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Target: ${_money(goal.targetAmount)}',
                          style: const TextStyle(
                            color: _textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close_rounded,
                      color: _textMuted,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardDeep,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _lime.withOpacity(0.16)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Saved',
                          style: TextStyle(
                            color: _textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _money(goal.currentAmount),
                          style: const TextStyle(
                            color: _textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.black.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _progressColor(progress),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress * 100).toStringAsFixed(1)}% complete',
                          style: TextStyle(
                            color: _progressColor(progress),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${_money((goal.targetAmount - goal.currentAmount).clamp(0, double.infinity))} to go',
                          style: const TextStyle(
                            color: _textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showMessage('Adding funds to ${goal.name}...');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _lime,
                        foregroundColor: const Color(0xFF102A00),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Add Funds',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showMessage('Goal settings opened'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _lime.withOpacity(0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Settings',
                        style: TextStyle(
                          color: _lime,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalTarget =
        _goals.fold<double>(0, (sum, goal) => sum + goal.targetAmount);
    final totalSaved =
        _goals.fold<double>(0, (sum, goal) => sum + goal.currentAmount);
    final completion =
        totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;

    final completedCount =
        _goals.where((goal) => _progress(goal) >= 1.0).length;
    final onTrackCount = _goals
        .where((goal) => _progress(goal) >= 0.6 && _progress(goal) < 1.0)
        .length;

    final sorted = [..._goals]
      ..sort((a, b) => _progress(b).compareTo(_progress(a)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showMessage(
            'Overall progress: ${(completion * 100).toStringAsFixed(0)}%',
          ),
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
                const Text(
                  'Goals Dashboard',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${_money(totalSaved)} of ${_money(totalTarget)} saved',
                  style: TextStyle(
                    color: _progressColor(completion),
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: completion,
                    minHeight: 9,
                    backgroundColor: Colors.black.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(_lime),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    GestureDetector(
                      onTap: () => _showMessage(
                        'Completion: ${(completion * 100).toStringAsFixed(0)}%',
                      ),
                      child: _statChip(Icons.track_changes_rounded,
                          '${(completion * 100).toStringAsFixed(0)}% Complete'),
                    ),
                    GestureDetector(
                      onTap: () => _showMessage(
                        'You have $completedCount achieved goals',
                      ),
                      child: _statChip(
                        Icons.emoji_events_rounded,
                        '$completedCount Achieved',
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showMessage(
                        'You have $onTrackCount goals on track',
                      ),
                      child: _statChip(
                          Icons.trending_up_rounded, '$onTrackCount On Track'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Goal Progress',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 12),
        ...sorted.take(5).map(
              (goal) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _goalTile(goal),
              ),
            ),
      ],
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _lime.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _lime),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _goalTile(SavingsGoal goal) {
    final value = _progress(goal);
    final pColor = _progressColor(value);

    return GestureDetector(
      onTap: () => _showGoalDetails(goal),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _lime.withOpacity(0.10)),
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
              child: Center(
                child: Text(
                  '${(value * 100).toInt()}%',
                  style: TextStyle(
                    color: pColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
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
                  const SizedBox(height: 4),
                  Text(
                    '${_money(goal.currentAmount)} / ${_money(goal.targetAmount)}',
                    style: const TextStyle(
                      color: _textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: _textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}
