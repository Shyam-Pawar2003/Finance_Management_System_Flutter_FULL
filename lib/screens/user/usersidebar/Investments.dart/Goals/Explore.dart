import 'package:flutter/material.dart';

import '../../../data/dashboard_seed_data.dart';
import '../../../models/dashboard_models.dart';

class GoalsExploreTab extends StatefulWidget {
  const GoalsExploreTab({super.key, required this.onActionTap});

  final ValueChanged<String> onActionTap;

  @override
  State<GoalsExploreTab> createState() => _GoalsExploreTabState();
}

class _GoalsExploreTabState extends State<GoalsExploreTab> {
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  final List<_GoalTemplate> _templates = [
    _GoalTemplate(
      name: 'Emergency Fund',
      icon: Icons.health_and_safety_rounded,
      description: '3-6 months of essential expenses',
      suggestedAmount: 15000,
    ),
    _GoalTemplate(
      name: 'International Trip',
      icon: Icons.flight_takeoff_rounded,
      description: 'Dream vacation fund',
      suggestedAmount: 5000,
    ),
    _GoalTemplate(
      name: 'First Home',
      icon: Icons.home_work_rounded,
      description: 'Down payment for property',
      suggestedAmount: 100000,
    ),
    _GoalTemplate(
      name: 'Masters Degree',
      icon: Icons.school_rounded,
      description: 'Higher education investment',
      suggestedAmount: 50000,
    ),
    _GoalTemplate(
      name: 'Car Purchase',
      icon: Icons.directions_car_rounded,
      description: 'Dream car savings',
      suggestedAmount: 30000,
    ),
    _GoalTemplate(
      name: 'Wedding',
      icon: Icons.card_giftcard_rounded,
      description: 'Dream wedding fund',
      suggestedAmount: 50000,
    ),
  ];

  void _showTemplateDetail(_GoalTemplate template) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                  child: Icon(template.icon, color: _lime, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        template.description,
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
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _cardDeep,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _lime.withOpacity(0.16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Suggested Target:',
                    style: TextStyle(
                      color: _textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '\$${template.suggestedAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: _lime,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onActionTap(
                    '${template.name} goal template added to your plan!',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _lime,
                  foregroundColor: const Color(0xFF102A00),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add to My Goals',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _lime.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: _textMuted,
                    fontWeight: FontWeight.w800,
                  ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                  Icon(Icons.lightbulb_outline_rounded, color: _lime, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Explore Goal Ideas',
                          style: TextStyle(
                            color: _textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const Text(
                          'Popular goal templates to get started',
                          style: TextStyle(
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
        const SizedBox(height: 18),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: _templates.length,
          itemBuilder: (_, index) {
            final template = _templates[index];
            return GestureDetector(
              onTap: () => _showTemplateDetail(template),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _lime.withOpacity(0.14)),
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
                      ),
                      child: Icon(
                        template.icon,
                        color: _lime,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      template.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${template.suggestedAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: _lime,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to add',
                      style: TextStyle(
                        color: _textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _GoalTemplate {
  const _GoalTemplate({
    required this.name,
    required this.icon,
    required this.description,
    required this.suggestedAmount,
  });

  final String name;
  final IconData icon;
  final String description;
  final double suggestedAmount;
}
