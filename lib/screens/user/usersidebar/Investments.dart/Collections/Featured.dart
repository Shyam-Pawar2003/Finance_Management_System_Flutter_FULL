part of '../Collections.dart';

class CollectionsFeaturedTab extends StatefulWidget {
  final ValueChanged<String> onMessage;

  const CollectionsFeaturedTab({
    required this.onMessage,
    Key? key,
  }) : super(key: key);

  @override
  State<CollectionsFeaturedTab> createState() => _CollectionsFeaturedTabState();
}

class _CollectionsFeaturedTabState extends State<CollectionsFeaturedTab> {
  static const Color _bgColor = Color(0xFF050C04);
  static const Color _cardDark = Color(0xFF0D1A0B);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  final List<_FeaturedCollection> _collections = [
    _FeaturedCollection(
      id: 'feat_1',
      name: 'Tech Growth Leaders',
      description: 'Top-performing tech funds',
      fundCount: 12,
      avgReturn: 34.5,
      imageUrl: '📱',
      funds: ['TCS Fund', 'Infosys Growth', 'HCL Premium'],
    ),
    _FeaturedCollection(
      id: 'feat_2',
      name: 'Banking & Finance',
      description: 'Stable financial sector',
      fundCount: 8,
      avgReturn: 22.3,
      imageUrl: '🏦',
      funds: ['HDFC Bank Fund', 'ICICI Blue', 'Axis Select'],
    ),
    _FeaturedCollection(
      id: 'feat_3',
      name: 'Green Energy',
      description: 'Sustainable future funds',
      fundCount: 10,
      avgReturn: 28.7,
      imageUrl: '🌿',
      funds: ['Renewable Energy', 'Solar Growth', 'Wind Power'],
    ),
    _FeaturedCollection(
      id: 'feat_4',
      name: 'Emerging Markets',
      description: 'High-growth markets',
      fundCount: 15,
      avgReturn: 38.2,
      imageUrl: '🌍',
      funds: ['India Growth', 'Southeast Asia', 'Frontier Markets'],
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
                'Featured Collections',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Curated fund collections by our experts',
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
            itemBuilder: (context, index) => _buildFeaturedCard(
              _collections[index],
              index,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(
    _FeaturedCollection collection,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        widget.onMessage(
          'Viewing ${collection.name} collection',
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
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _lime.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      collection.imageUrl,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${collection.fundCount} Funds',
                      style: TextStyle(
                        color: _textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Avg Return: +${collection.avgReturn}%',
                      style: const TextStyle(
                        color: _lime,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onMessage(
                      'Added ${collection.name} to portfolio',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _lime,
                    foregroundColor: _bgColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Invest',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCollection {
  final String id;
  final String name;
  final String description;
  final int fundCount;
  final double avgReturn;
  final String imageUrl;
  final List<String> funds;

  _FeaturedCollection({
    required this.id,
    required this.name,
    required this.description,
    required this.fundCount,
    required this.avgReturn,
    required this.imageUrl,
    required this.funds,
  });

  _FeaturedCollection copyWith({
    String? id,
    String? name,
    String? description,
    int? fundCount,
    double? avgReturn,
    String? imageUrl,
    List<String>? funds,
  }) {
    return _FeaturedCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      fundCount: fundCount ?? this.fundCount,
      avgReturn: avgReturn ?? this.avgReturn,
      imageUrl: imageUrl ?? this.imageUrl,
      funds: funds ?? this.funds,
    );
  }
}
