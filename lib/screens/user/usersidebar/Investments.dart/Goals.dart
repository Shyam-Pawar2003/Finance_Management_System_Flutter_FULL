import 'package:flutter/material.dart';

import '../../data/dashboard_seed_data.dart';
import '../../models/dashboard_models.dart';

// ── Standalone page (Navigator.push usage) ───────────────────────────────────
class UserGoalsPage extends StatefulWidget {
  const UserGoalsPage({super.key});

  @override
  State<UserGoalsPage> createState() => _UserGoalsPageState();
}

class _UserGoalsPageState extends State<UserGoalsPage> {
  static const Color _bgTop = Color(0xFF0A1A08);
  static const Color _bgBottom = Color(0xFF050C04);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);

  Widget _glow(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _lime.withOpacity(0.09),
        ),
      );

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBottom,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Goals',
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: _lime),
            onPressed: () => _showMessage('Create goal flow will open soon.'),
            tooltip: 'New Goal',
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          Positioned(top: -100, right: -60, child: _glow(260)),
          Positioned(bottom: -100, left: -60, child: _glow(200)),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_bgTop, _bgBottom],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          const SafeArea(child: UserGoalsContent()),
        ],
      ),
    );
  }
}

// ── Embeddable content widget (no Scaffold / AppBar) ─────────────────────────
// Used by UserGoalsPage and the Investments tab shell (IndexedStack).
class UserGoalsContent extends StatefulWidget {
  const UserGoalsContent({super.key});

  @override
  State<UserGoalsContent> createState() => _UserGoalsContentState();
}

class _UserGoalsContentState extends State<UserGoalsContent> {
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  late final List<_GoalState> _goals;

  @override
  void initState() {
    super.initState();
    _goals = seedSavingsGoals
        .map((g) => _GoalState(source: g, extraAdded: 0))
        .toList();
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
      final ri = whole.length - i;
      buf.write(whole[i]);
      if (ri > 1 && ri % 3 == 1) buf.write(',');
    }
    final num = decimals > 0 ? '${buf.toString()}.$dec' : buf.toString();
    return '${isNeg ? '-' : ''}$_currencySymbol$num';
  }

  double get _totalTarget =>
      _goals.fold(0, (s, g) => s + g.source.targetAmount);

  double get _totalSaved => _goals.fold(0, (s, g) => s + g.currentAmount);

  int _daysLeft(DateTime target) {
    final now = DateTime.now();
    return target.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  Color _progressColor(double progress) {
    if (progress >= 1.0) return const Color(0xFF4ADE80);
    if (progress >= 0.7) return _lime;
    if (progress >= 0.4) return const Color(0xFFFBBF24);
    return const Color(0xFFE67A62);
  }

  void _showTopUpSheet(int index) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top-up: ${_goals[index].source.name}',
              style: const TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Current: ${_money(_goals[index].currentAmount, decimals: 2)}  '
              '/ Target: ${_money(_goals[index].source.targetAmount, decimals: 2)}',
              style: const TextStyle(
                  color: _textMuted, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: _cardDeep,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _lime.withOpacity(0.28)),
              ),
              child: TextField(
                controller: ctrl,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  prefixText: _currencySymbol,
                  prefixStyle: const TextStyle(
                      color: _lime, fontWeight: FontWeight.w700),
                  hintText: '0.00',
                  hintStyle: const TextStyle(color: _textMuted),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final val = double.tryParse(ctrl.text.trim());
                  if (val != null && val > 0) {
                    setState(() => _goals[index].extraAdded += val);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _lime,
                  foregroundColor: const Color(0xFF102A00),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Add Savings',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final overallProgress =
        _totalTarget > 0 ? (_totalSaved / _totalTarget).clamp(0.0, 1.0) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(overallProgress),
          const SizedBox(height: 18),
          const Text(
            'Your Goals',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(
            _goals.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildGoalCard(i),
            ),
          ),
          const SizedBox(height: 4),
          _buildTipCard(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double overallProgress) {
    final saved = _totalSaved;
    final target = _totalTarget;
    final remaining = (target - saved).clamp(0.0, double.infinity);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _lime,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _lime.withOpacity(0.32),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Savings Progress',
            style: TextStyle(
              color: Color(0xFF2A4600),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _money(saved, decimals: 0),
            style: const TextStyle(
              color: Color(0xFF102A00),
              fontWeight: FontWeight.w900,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'of ${_money(target, decimals: 0)} target',
            style: const TextStyle(
              color: Color(0xFF3A5A00),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: overallProgress,
              minHeight: 10,
              backgroundColor: Colors.black.withOpacity(0.15),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF2A4600)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _summaryChip(
                Icons.savings_outlined,
                '${(overallProgress * 100).toStringAsFixed(0)}% saved',
              ),
              const SizedBox(width: 8),
              _summaryChip(
                Icons.flag_outlined,
                '${_money(remaining, decimals: 0)} left',
              ),
              const SizedBox(width: 8),
              _summaryChip(
                Icons.list_alt_rounded,
                '${_goals.length} goals',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF2A4600)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF2A4600),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(int index) {
    final gs = _goals[index];
    final goal = gs.source;
    final current = gs.currentAmount;
    final progress = (current / goal.targetAmount).clamp(0.0, 1.0);
    final pColor = _progressColor(progress);
    final days = _daysLeft(goal.targetDate);
    final completed = progress >= 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: completed
              ? const Color(0xFF4ADE80).withOpacity(0.5)
              : _lime.withOpacity(0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: pColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        goal.name,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (completed)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ADE80).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: const Color(0xFF4ADE80).withOpacity(0.4)),
                  ),
                  child: const Text(
                    'ACHIEVED',
                    style: TextStyle(
                      color: Color(0xFF4ADE80),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _money(current, decimals: 0),
                style: const TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '/ ${_money(goal.targetAmount, decimals: 0)}',
                  style: const TextStyle(
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: pColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.black.withOpacity(0.25),
              valueColor: AlwaysStoppedAnimation<Color>(pColor),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metaChip(
                Icons.calendar_today_outlined,
                days < 0
                    ? 'Overdue'
                    : days == 0
                        ? 'Due today'
                        : '$days days left',
                days < 0 ? const Color(0xFFE67A62) : _textMuted,
              ),
              const SizedBox(width: 8),
              _metaChip(
                Icons.autorenew_rounded,
                '${_money(goal.suggestedAutoTransfer)}/mo',
                _textMuted,
              ),
              const Spacer(),
              if (!completed)
                GestureDetector(
                  onTap: () => _showTopUpSheet(index),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _lime,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '+ Top Up',
                      style: TextStyle(
                        color: Color(0xFF102A00),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
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

  Widget _metaChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _lime.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _lime.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lightbulb_outline_rounded,
                color: _lime, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Automate monthly transfers to reach your goals faster. Even small consistent amounts compound over time.',
              style: TextStyle(
                color: _textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalState {
  _GoalState({required this.source, required this.extraAdded});
  final SavingsGoal source;
  double extraAdded;
  double get currentAmount => source.currentAmount + extraAdded;
}
