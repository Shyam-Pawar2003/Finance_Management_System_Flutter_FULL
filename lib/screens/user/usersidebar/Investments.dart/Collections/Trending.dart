part of '../Collections.dart';

class CollectionsTrendingTab extends StatefulWidget {
  final ValueChanged<String> onMessage;

  const CollectionsTrendingTab({
    required this.onMessage,
    Key? key,
  }) : super(key: key);

  @override
  State<CollectionsTrendingTab> createState() => _CollectionsTrendingTabState();
}

class _CollectionsTrendingTabState extends State<CollectionsTrendingTab> {
  static const Color _bgColor = Color(0xFF050C04);
  static const Color _cardDark = Color(0xFF0D1A0B);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  final List<_TrendingCollection> _trendingCollections = [
    _TrendingCollection(
      id: 'trend_1',
      name: 'AI & Technology Boom',
      description: 'AI and tech sector funds',
      fundCount: 14,
      weeklyGain: 8.5,
      investorCount: 5240,
      rank: 1,
      trend: '📈',
    ),
    _TrendingCollection(
      id: 'trend_2',
      name: 'Healthcare Revolution',
      description: 'Pharma and healthcare',
      fundCount: 10,
      weeklyGain: 6.2,
      investorCount: 3580,
      rank: 2,
      trend: '📈',
    ),
    _TrendingCollection(
      id: 'trend_3',
      name: 'Renewable Energy',
      description: 'Green energy transition',
      fundCount: 8,
      weeklyGain: 5.8,
      investorCount: 2920,
      rank: 3,
      trend: '📈',
    ),
    _TrendingCollection(
      id: 'trend_4',
      name: 'E-Commerce Leaders',
      description: 'Digital commerce growth',
      fundCount: 12,
      weeklyGain: 9.1,
      investorCount: 6150,
      rank: 4,
      trend: '📈',
    ),
    _TrendingCollection(
      id: 'trend_5',
      name: 'Infrastructure Growth',
      description: 'India infra projects',
      fundCount: 9,
      weeklyGain: 4.3,
      investorCount: 4220,
      rank: 5,
      trend: '📊',
    ),
  ];

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
                'Trending Collections',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    '🔥 Most popular this week',
                    style: TextStyle(
                      color: _textMuted,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _trendingCollections.length,
            itemBuilder: (context, index) => _buildTrendingCard(
              _trendingCollections[index],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingCard(_TrendingCollection collection) {
    return GestureDetector(
      onTap: () {
        widget.onMessage(
          'Viewing ${collection.name} - Rank #${collection.rank}',
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
                      Row(
                        children: [
                          Text(
                            '#${collection.rank}',
                            style: const TextStyle(
                              color: _lime,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              collection.name,
                              style: const TextStyle(
                                color: _textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
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
                Text(
                  collection.trend,
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Gain',
                        style: TextStyle(
                          color: _textMuted,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+${collection.weeklyGain}%',
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
                        'Investors',
                        style: TextStyle(
                          color: _textMuted,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(collection.investorCount / 1000).toStringAsFixed(1)}K',
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
                        'Funds',
                        style: TextStyle(
                          color: _textMuted,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${collection.fundCount}',
                        style: const TextStyle(
                          color: _lime,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: collection.investorCount / 7000,
              minHeight: 6,
              backgroundColor: _lime.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(_lime),
              borderRadius: BorderRadius.circular(999),
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
                  'Join Trend',
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

class _TrendingCollection {
  final String id;
  final String name;
  final String description;
  final int fundCount;
  final double weeklyGain;
  final int investorCount;
  final int rank;
  final String trend;

  _TrendingCollection({
    required this.id,
    required this.name,
    required this.description,
    required this.fundCount,
    required this.weeklyGain,
    required this.investorCount,
    required this.rank,
    required this.trend,
  });

  _TrendingCollection copyWith({
    String? id,
    String? name,
    String? description,
    int? fundCount,
    double? weeklyGain,
    int? investorCount,
    int? rank,
    String? trend,
  }) {
    return _TrendingCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      fundCount: fundCount ?? this.fundCount,
      weeklyGain: weeklyGain ?? this.weeklyGain,
      investorCount: investorCount ?? this.investorCount,
      rank: rank ?? this.rank,
      trend: trend ?? this.trend,
    );
  }
}
