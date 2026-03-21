part of '../Collections.dart';

class CollectionsRecommendedTab extends StatefulWidget {
  final ValueChanged<String> onMessage;

  const CollectionsRecommendedTab({
    required this.onMessage,
    Key? key,
  }) : super(key: key);

  @override
  State<CollectionsRecommendedTab> createState() =>
      _CollectionsRecommendedTabState();
}

class _CollectionsRecommendedTabState extends State<CollectionsRecommendedTab> {
  static const Color _bgColor = Color(0xFF050C04);
  static const Color _cardDark = Color(0xFF0D1A0B);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  final List<_RecommendedCollection> _collections = [
    _RecommendedCollection(
      id: 'rec_1',
      name: 'For Conservative Investors',
      description: 'Low-risk, stable returns',
      matchScore: 95,
      expectedReturn: 12.5,
      riskLevel: 'Low',
      reason: 'Based on your profile',
    ),
    _RecommendedCollection(
      id: 'rec_2',
      name: 'Balanced Growth',
      description: 'Mix of stability and growth',
      matchScore: 88,
      expectedReturn: 18.3,
      riskLevel: 'Medium',
      reason: 'Complements your portfolio',
    ),
    _RecommendedCollection(
      id: 'rec_3',
      name: 'Aggressive Growth',
      description: 'High-growth potential',
      matchScore: 82,
      expectedReturn: 28.5,
      riskLevel: 'High',
      reason: 'Trending in your sector',
    ),
    _RecommendedCollection(
      id: 'rec_4',
      name: 'Dividend Yielders',
      description: 'Income-focused funds',
      matchScore: 90,
      expectedReturn: 15.2,
      riskLevel: 'Low',
      reason: 'Suggested by AI advisor',
    ),
  ];

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'Low':
        return const Color(0xFF4CAF50);
      case 'Medium':
        return const Color(0xFFFFC107);
      case 'High':
        return const Color(0xFFF44336);
      default:
        return _lime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recommended For You',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Personalized suggestions based on your profile',
                style: TextStyle(
                  color: _textMuted,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _collections.length,
            itemBuilder: (context, index) => _buildRecommendationCard(
              _collections[index],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(_RecommendedCollection collection) {
    return GestureDetector(
      onTap: () {
        widget.onMessage(
          'Viewing ${collection.name} - Match: ${collection.matchScore}%',
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _lime.withOpacity(0.15),
          ),
        ),
        child: Column(
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
                        collection.name,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        collection.description,
                        style: TextStyle(
                          color: _textMuted,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _lime.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${collection.matchScore}% Match',
                        style: const TextStyle(
                          color: _lime,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      collection.reason,
                      style: TextStyle(
                        color: _textMuted,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expected Return',
                        style: TextStyle(
                          color: _textMuted,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+${collection.expectedReturn}% p.a.',
                        style: const TextStyle(
                          color: _lime,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Risk Level',
                        style: TextStyle(
                          color: _textMuted,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _getRiskColor(collection.riskLevel)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          collection.riskLevel,
                          style: TextStyle(
                            color: _getRiskColor(collection.riskLevel),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onMessage(
                    'Adding ${collection.name} to portfolio',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _lime,
                  foregroundColor: _bgColor,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add to Portfolio',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedCollection {
  final String id;
  final String name;
  final String description;
  final int matchScore;
  final double expectedReturn;
  final String riskLevel;
  final String reason;

  _RecommendedCollection({
    required this.id,
    required this.name,
    required this.description,
    required this.matchScore,
    required this.expectedReturn,
    required this.riskLevel,
    required this.reason,
  });

  _RecommendedCollection copyWith({
    String? id,
    String? name,
    String? description,
    int? matchScore,
    double? expectedReturn,
    String? riskLevel,
    String? reason,
  }) {
    return _RecommendedCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      matchScore: matchScore ?? this.matchScore,
      expectedReturn: expectedReturn ?? this.expectedReturn,
      riskLevel: riskLevel ?? this.riskLevel,
      reason: reason ?? this.reason,
    );
  }
}
