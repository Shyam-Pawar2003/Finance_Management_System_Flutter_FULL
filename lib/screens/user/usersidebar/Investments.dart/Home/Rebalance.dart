
import 'package:flutter/material.dart';

import '../../../data/dashboard_seed_data.dart';
import '../../../models/dashboard_models.dart';

class InvestmentRebalancePage extends StatelessWidget {
  const InvestmentRebalancePage({super.key});

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
          'Rebalance Portfolio',
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
              child: InvestmentRebalanceContent(),
            ),
          ),
        ],
      ),
    );
  }
}

class InvestmentRebalanceContent extends StatefulWidget {
  const InvestmentRebalanceContent({super.key, this.onExecuted});

  final VoidCallback? onExecuted;

  @override
  State<InvestmentRebalanceContent> createState() =>
      _InvestmentRebalanceContentState();
}

class _InvestmentRebalanceContentState
    extends State<InvestmentRebalanceContent> {
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);
  static const Color _red = Color(0xFFE67A62);
  static const Color _amber = Color(0xFFFBBF24);

  late final List<_AssetBucket> _buckets;
  late final Map<String, double> _targetPercentRaw;

  bool _notifyAfterExecution = true;
  bool _isExecuting = false;
  String _activePreset = 'Custom';

  @override
  void initState() {
    super.initState();
    _buckets = _buildBuckets(seedInvestmentHoldings);
    _targetPercentRaw = {
      for (final bucket in _buckets) bucket.type: _currentPercent(bucket),
    };
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

  double get _portfolioTotal {
    return _buckets.fold<double>(0, (sum, bucket) => sum + bucket.currentValue);
  }

  double get _rawTargetTotal {
    return _targetPercentRaw.values
        .fold<double>(0, (sum, value) => sum + value);
  }

  List<_AssetBucket> _buildBuckets(List<InvestmentHolding> holdings) {
    final map = <String, double>{};
    for (final holding in holdings) {
      map.update(
        holding.assetType,
        (existing) => existing + holding.currentValue,
        ifAbsent: () => holding.currentValue,
      );
    }

    final list = map.entries
        .map((e) => _AssetBucket(type: e.key, currentValue: e.value))
        .toList();
    list.sort((a, b) => b.currentValue.compareTo(a.currentValue));
    return list;
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

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  double _currentPercent(_AssetBucket bucket) {
    if (_portfolioTotal <= 0) {
      return 0;
    }
    return (bucket.currentValue / _portfolioTotal) * 100;
  }

  double _normalizedTargetPercent(String type) {
    final raw = _targetPercentRaw[type] ?? 0;
    final total = _rawTargetTotal;

    if (total <= 0 && _buckets.isNotEmpty) {
      return 100 / _buckets.length;
    }
    if (total <= 0) {
      return 0;
    }
    return (raw / total) * 100;
  }

  String _bucketRiskClass(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('bond') ||
        lower.contains('debt') ||
        lower.contains('gold')) {
      return 'low';
    }
    if (lower.contains('crypto')) {
      return 'high';
    }
    return 'medium';
  }

  void _applyPreset(String preset) {
    if (_buckets.isEmpty) {
      return;
    }

    final groups = {
      'low': <String>[],
      'medium': <String>[],
      'high': <String>[],
    };

    for (final bucket in _buckets) {
      groups[_bucketRiskClass(bucket.type)]!.add(bucket.type);
    }

    Map<String, double> split;
    switch (preset) {
      case 'Conservative':
        split = {'low': 55, 'medium': 35, 'high': 10};
        break;
      case 'Growth':
        split = {'low': 15, 'medium': 45, 'high': 40};
        break;
      case 'Balanced':
      default:
        split = {'low': 30, 'medium': 50, 'high': 20};
    }

    final allocation = <String, double>{};
    final working = Map<String, double>.from(split);

    if (groups['medium']!.isNotEmpty) {
      for (final klass in ['low', 'high']) {
        if (groups[klass]!.isEmpty) {
          working['medium'] = working['medium']! + working[klass]!;
          working[klass] = 0;
        }
      }
    }

    for (final klass in ['low', 'medium', 'high']) {
      final items = groups[klass]!;
      if (items.isEmpty) {
        continue;
      }
      final perItem = working[klass]! / items.length;
      for (final type in items) {
        allocation[type] = perItem;
      }
    }

    if (allocation.isEmpty) {
      final equal = 100 / _buckets.length;
      for (final bucket in _buckets) {
        allocation[bucket.type] = equal;
      }
    }

    setState(() {
      _activePreset = preset;
      _targetPercentRaw
        ..clear()
        ..addAll(allocation);
    });

    _showMessage('$preset preset applied.');
  }

  void _normalizeTargets() {
    final total = _rawTargetTotal;
    if (total <= 0 && _buckets.isNotEmpty) {
      final equal = 100 / _buckets.length;
      setState(() {
        _activePreset = 'Custom';
        for (final bucket in _buckets) {
          _targetPercentRaw[bucket.type] = equal;
        }
      });
      return;
    }
    if (total <= 0) {
      return;
    }

    setState(() {
      _activePreset = 'Custom';
      for (final type in _targetPercentRaw.keys.toList()) {
        _targetPercentRaw[type] = (_targetPercentRaw[type]! / total) * 100;
      }
    });
    _showMessage('Targets normalized to 100%.');
  }

  List<_OrderPlan> _plans() {
    final plans = <_OrderPlan>[];
    for (final bucket in _buckets) {
      final currentPct = _currentPercent(bucket);
      final targetPct = _normalizedTargetPercent(bucket.type);
      final drift = targetPct - currentPct;
      final amount = (drift / 100) * _portfolioTotal;

      final action = amount > 1
          ? 'BUY'
          : amount < -1
              ? 'SELL'
              : 'HOLD';

      plans.add(
        _OrderPlan(
          type: bucket.type,
          action: action,
          amount: amount,
          currentPercent: currentPct,
          targetPercent: targetPct,
        ),
      );
    }
    return plans;
  }

  double get _turnover {
    return _plans().fold<double>(0, (sum, plan) => sum + plan.amount.abs()) / 2;
  }

  Future<void> _previewOrders() async {
    final plans = _plans();
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
                'Rebalance Preview',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Estimated turnover ${_money(_turnover, decimals: 2)}',
                style: const TextStyle(
                  color: _textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              ...plans.map(
                (plan) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _previewOrderTile(plan),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _lime,
                    foregroundColor: const Color(0xFF102A00),
                    padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _previewOrderTile(_OrderPlan plan) {
    final color = plan.action == 'BUY'
        ? _lime
        : plan.action == 'SELL'
            ? _red
            : _textMuted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardDeep,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.type,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Current ${plan.currentPercent.toStringAsFixed(1)}%  ->  Target ${plan.targetPercent.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                plan.action,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _money(plan.amount.abs(), decimals: 2),
                style: const TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _execute() async {
    if (_buckets.isEmpty) {
      _showMessage('No assets found for rebalancing.');
      return;
    }

    if (_turnover <= 0.01) {
      _showMessage('Portfolio is already close to target allocation.');
      return;
    }

    setState(() => _isExecuting = true);
    await Future.delayed(const Duration(milliseconds: 850));
    if (!mounted) {
      return;
    }
    setState(() => _isExecuting = false);

    if (_notifyAfterExecution) {
      _showMessage('Rebalance executed successfully.');
    }
    widget.onExecuted?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryCard(),
        const SizedBox(height: 18),
        const Text(
          'Strategy Presets',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _presetChip('Conservative'),
            _presetChip('Balanced'),
            _presetChip('Growth'),
            ActionChip(
              label: const Text('Normalize'),
              onPressed: _normalizeTargets,
              labelStyle: const TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w700,
              ),
              backgroundColor: _cardDeep,
              side: BorderSide(color: _lime.withOpacity(0.28)),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'Target Allocation',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        ..._buckets.map(
          (bucket) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _allocationCard(bucket),
          ),
        ),
        const SizedBox(height: 10),
        _notificationCard(),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _previewOrders,
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
                onPressed: _isExecuting ? null : _execute,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _lime,
                  foregroundColor: const Color(0xFF102A00),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isExecuting
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
                        'Execute',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final targetTotal = _rawTargetTotal;
    final targetOk = (targetTotal - 100).abs() <= 0.01;

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
            'Portfolio Rebalance Summary',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Current value ${_money(_portfolioTotal, decimals: 2)}',
            style: const TextStyle(
              color: _textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(
                icon: Icons.tune_rounded,
                text: 'Preset $_activePreset',
                color: _lime,
              ),
              _chip(
                icon: targetOk
                    ? Icons.check_circle_outline_rounded
                    : Icons.warning_amber_rounded,
                text: 'Target ${targetTotal.toStringAsFixed(1)}%',
                color: targetOk ? _lime : _amber,
              ),
              _chip(
                icon: Icons.swap_horiz_rounded,
                text: 'Turnover ${_money(_turnover, decimals: 0)}',
                color: _textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _presetChip(String label) {
    final selected = _activePreset == label;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => _applyPreset(label),
      selectedColor: _lime,
      backgroundColor: _cardDeep,
      labelStyle: TextStyle(
        color: selected ? _cardDark : _textMuted,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _chip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: _textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _allocationCard(_AssetBucket bucket) {
    final current = _currentPercent(bucket);
    final target = _normalizedTargetPercent(bucket.type);
    final drift = target - current;
    final amount = (drift / 100) * _portfolioTotal;
    final direction = amount > 1
        ? 'Buy'
        : amount < -1
            ? 'Sell'
            : 'Keep';
    final amountColor = amount > 1
        ? _lime
        : amount < -1
            ? _red
            : _textMuted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _lime.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  bucket.type,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                direction,
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Current ${current.toStringAsFixed(1)}%  |  Target ${target.toStringAsFixed(1)}%',
            style: const TextStyle(
              color: _textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${direction == 'Keep' ? 'No trade needed' : '$direction ${_money(amount.abs(), decimals: 2)}'}',
            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: (_targetPercentRaw[bucket.type] ?? 0).clamp(0.0, 100.0),
            min: 0,
            max: 100,
            divisions: 100,
            activeColor: _lime,
            inactiveColor: _textMuted.withOpacity(0.28),
            label:
                '${(_targetPercentRaw[bucket.type] ?? 0).toStringAsFixed(0)}%',
            onChanged: (value) {
              setState(() {
                _activePreset = 'Custom';
                _targetPercentRaw[bucket.type] = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _notificationCard() {
    return Container(
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _lime.withOpacity(0.10)),
      ),
      child: SwitchListTile(
        title: const Text(
          'Notify after successful rebalance',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        subtitle: const Text(
          'You will receive a confirmation toast after execution.',
          style: TextStyle(
            color: _textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        value: _notifyAfterExecution,
        onChanged: (value) => setState(() => _notifyAfterExecution = value),
        activeColor: _lime,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}

class _AssetBucket {
  const _AssetBucket({required this.type, required this.currentValue});

  final String type;
  final double currentValue;
}

class _OrderPlan {
  const _OrderPlan({
    required this.type,
    required this.action,
    required this.amount,
    required this.currentPercent,
    required this.targetPercent,
  });

  final String type;
  final String action;
  final double amount;
  final double currentPercent;
  final double targetPercent;
}
