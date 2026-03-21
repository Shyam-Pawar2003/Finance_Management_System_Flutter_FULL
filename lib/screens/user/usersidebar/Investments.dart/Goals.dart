import 'package:flutter/material.dart';

import '../../data/dashboard_seed_data.dart';
import '../../models/dashboard_models.dart';
import 'Goals/Achieved.dart';
import 'Goals/Dashboard.dart';
import 'Goals/Explore.dart';
import 'Goals/Planner.dart';

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
        centerTitle: false,
        title: const Text(
          'Goals',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showMessage('Insights will be available soon.'),
            icon: const Icon(Icons.insights_rounded, color: _textPrimary),
          ),
          IconButton(
            onPressed: () => _showMessage('Goal creation flow will open soon.'),
            icon: const Icon(Icons.add_circle_outline_rounded, color: _lime),
          ),
          const SizedBox(width: 6),
        ],
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
              child: UserGoalsContent(),
            ),
          ),
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

class _UserGoalsContentState extends State<UserGoalsContent>
    with SingleTickerProviderStateMixin {
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  static const List<String> _goalFilters = [
    'All',
    'On Track',
    'Needs Attention',
    'Achieved',
  ];

  final List<_GoalCollection> _collections = const [
    _GoalCollection(name: 'Emergency', icon: Icons.health_and_safety_rounded),
    _GoalCollection(name: 'Vacation', icon: Icons.flight_takeoff_rounded),
    _GoalCollection(name: 'Home', icon: Icons.home_work_rounded),
    _GoalCollection(name: 'Education', icon: Icons.school_rounded),
    _GoalCollection(name: 'Car', icon: Icons.directions_car_filled_rounded),
    _GoalCollection(name: 'Retirement', icon: Icons.workspace_premium_rounded),
  ];

  late final List<_GoalState> _goals;
  late TabController _tabController;
  int _selectedGoalFilter = 0;

  @override
  void initState() {
    super.initState();
    _goals = seedSavingsGoals
        .map((goal) => _GoalState(source: goal, extraAdded: 0))
        .toList();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  double get _totalTarget =>
      _goals.fold<double>(0, (sum, goal) => sum + goal.source.targetAmount);

  double get _totalSaved =>
      _goals.fold<double>(0, (sum, goal) => sum + goal.currentAmount);

  double _goalProgress(_GoalState goal) {
    if (goal.source.targetAmount <= 0) {
      return 0;
    }
    return (goal.currentAmount / goal.source.targetAmount).clamp(0.0, 1.0);
  }

  int _daysLeft(DateTime target) {
    final now = DateTime.now();
    return target.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  Color _progressColor(double progress) {
    if (progress >= 1.0) {
      return const Color(0xFF4ADE80);
    }
    if (progress >= 0.7) {
      return _lime;
    }
    if (progress >= 0.4) {
      return const Color(0xFFFBBF24);
    }
    return const Color(0xFFE67A62);
  }

  List<int> get _visibleGoalIndexes {
    final indexes = <int>[];
    for (int i = 0; i < _goals.length; i++) {
      final progress = _goalProgress(_goals[i]);
      final isOnTrack = progress >= 0.4 && progress < 1.0;
      final needsAttention = progress < 0.4;
      final achieved = progress >= 1.0;

      final include = switch (_selectedGoalFilter) {
        1 => isOnTrack,
        2 => needsAttention,
        3 => achieved,
        _ => true,
      };

      if (include) {
        indexes.add(i);
      }
    }
    return indexes;
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  void _showTopUpSheet(int index) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
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
                  color: _textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: _cardDeep,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _lime.withOpacity(0.28)),
                ),
                child: TextField(
                  controller: controller,
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
                      color: _lime,
                      fontWeight: FontWeight.w700,
                    ),
                    hintText: '0.00',
                    hintStyle: const TextStyle(color: _textMuted),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(controller.text.trim());
                    if (amount != null && amount > 0) {
                      setState(() => _goals[index].extraAdded += amount);
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final overallProgress =
        _totalTarget > 0 ? (_totalSaved / _totalTarget).clamp(0.0, 1.0) : 0.0;
    final visibleGoals = _visibleGoalIndexes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTabBar(),
        const SizedBox(height: 20),
        if (_tabController.index == 1)
          const GoalsDashboardTab()
        else if (_tabController.index == 2)
          const GoalsPlannerTab()
        else if (_tabController.index == 3)
          const GoalsAchievedTab()
        else ...[
          GoalsExploreTab(onActionTap: _showMessage),
          const SizedBox(height: 24),
          _buildGoalsPromoCard(overallProgress),
          const SizedBox(height: 24),
          _buildSectionHeader(
            title: 'Popular Goals',
            onTap: () => _showMessage('Opening your full goals list...'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _goals.length,
              itemBuilder: (_, i) => Padding(
                padding: EdgeInsets.only(right: i < _goals.length - 1 ? 12 : 0),
                child: _buildMiniGoalCard(_goals[i]),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your Goals',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          _buildGoalFilterRow(),
          const SizedBox(height: 12),
          if (visibleGoals.isEmpty)
            _buildEmptyState()
          else
            ...visibleGoals.map(
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildGoalCard(index),
              ),
            ),
          const SizedBox(height: 24),
          const Text(
            'Goal Collections',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 14,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemCount: _collections.length,
            itemBuilder: (_, i) => _buildCollectionIcon(_collections[i]),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tools & insights',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 14),
          _buildToolsRow(),
          const SizedBox(height: 20),
          _buildTipCard(),
        ],
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _textMuted.withOpacity(0.20), width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (_) => setState(() {}),
        tabs: const [
          Tab(text: 'Explore'),
          Tab(text: 'Dashboard'),
          Tab(text: 'Planner'),
          Tab(text: 'Achieved'),
        ],
        labelColor: _textPrimary,
        unselectedLabelColor: _textMuted,
        indicatorColor: _lime,
        indicatorWeight: 3,
      ),
    );
  }

  Widget _buildGoalsPromoCard(double overallProgress) {
    final saved = _totalSaved;
    final target = _totalTarget;
    final remaining = (target - saved).clamp(0.0, double.infinity);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_cardDark, _cardDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _lime.withOpacity(0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.38),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Build your goals with disciplined auto-savings',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _money(saved, decimals: 0),
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'of ${_money(target, decimals: 0)} saved',
                  style: const TextStyle(
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: overallProgress,
                    minHeight: 8,
                    backgroundColor: Colors.black.withOpacity(0.25),
                    valueColor: const AlwaysStoppedAnimation<Color>(_lime),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildStatChip(
                      Icons.flag_outlined,
                      '${(overallProgress * 100).toStringAsFixed(0)}% complete',
                    ),
                    _buildStatChip(
                      Icons.savings_outlined,
                      '${_money(remaining, decimals: 0)} to go',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      _showMessage('Auto-savings setup will open soon.'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1EDC78),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Set Auto-save',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF5B6FFF).withOpacity(0.30),
                  const Color(0xFF1EDC78).withOpacity(0.22),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.flag_circle_rounded,
              size: 42,
              color: Color(0xFF1EDC78),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _lime),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: _textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: const Text(
            'View all >',
            style: TextStyle(
              color: _textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniGoalCard(_GoalState goalState) {
    final progress = _goalProgress(goalState);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _lime.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _cardDeep,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _lime.withOpacity(0.20)),
            ),
            alignment: Alignment.center,
            child:
                const Icon(Icons.track_changes_rounded, color: _lime, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            goalState.source.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              height: 1.3,
            ),
          ),
          const Spacer(),
          Text(
            '${(progress * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              color: _progressColor(progress),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'of ${_money(goalState.source.targetAmount, decimals: 0)}',
            style: const TextStyle(
              color: _textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          _goalFilters.length,
          (i) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_goalFilters[i]),
              selected: _selectedGoalFilter == i,
              onSelected: (_) {
                setState(() => _selectedGoalFilter = i);
              },
              labelStyle: TextStyle(
                color: _selectedGoalFilter == i ? _cardDark : _textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              backgroundColor: Colors.transparent,
              selectedColor: _lime,
              side: BorderSide(
                color: _selectedGoalFilter == i
                    ? _lime
                    : _textMuted.withOpacity(0.30),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _lime.withOpacity(0.12)),
      ),
      child: const Text(
        'No goals in this category yet. Try a different filter.',
        style: TextStyle(
          color: _textMuted,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildGoalCard(int index) {
    final goalState = _goals[index];
    final goal = goalState.source;
    final current = goalState.currentAmount;
    final progress = _goalProgress(goalState);
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
              ? const Color(0xFF4ADE80).withOpacity(0.45)
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
                      color: const Color(0xFF4ADE80).withOpacity(0.4),
                    ),
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
              _buildMetaChip(
                Icons.calendar_today_outlined,
                days < 0
                    ? 'Overdue'
                    : days == 0
                        ? 'Due today'
                        : '$days days left',
                days < 0 ? const Color(0xFFE67A62) : _textMuted,
              ),
              const SizedBox(width: 8),
              _buildMetaChip(
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

  Widget _buildMetaChip(IconData icon, String label, Color color) {
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

  Widget _buildCollectionIcon(_GoalCollection collection) {
    return GestureDetector(
      onTap: () => _showMessage('Showing ${collection.name} goals...'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _lime.withOpacity(0.14)),
            ),
            alignment: Alignment.center,
            child: Icon(collection.icon, color: _lime, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            collection.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsRow() {
    final tools = [
      ('Planner', Icons.event_note_rounded),
      ('Deadline alerts', Icons.notifications_active_rounded),
      ('Top-up history', Icons.history_rounded),
      ('Goal split', Icons.pie_chart_rounded),
      ('Compare', Icons.balance_rounded),
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tools.length,
        itemBuilder: (_, i) {
          final (label, icon) = tools[i];

          return Padding(
            padding: EdgeInsets.only(right: i < tools.length - 1 ? 14 : 0),
            child: GestureDetector(
              onTap: () => _showMessage('$label tools are coming soon.'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _cardDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _lime.withOpacity(0.16)),
                    ),
                    child: Icon(icon, color: _lime, size: 26),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 72,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: _lime,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Automate monthly transfers to reach your goals faster. Even small, consistent amounts compound over time.',
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

class _GoalCollection {
  const _GoalCollection({required this.name, required this.icon});

  final String name;
  final IconData icon;
}

class _GoalState {
  _GoalState({required this.source, required this.extraAdded});

  final SavingsGoal source;
  double extraAdded;

  double get currentAmount => source.currentAmount + extraAdded;
}
