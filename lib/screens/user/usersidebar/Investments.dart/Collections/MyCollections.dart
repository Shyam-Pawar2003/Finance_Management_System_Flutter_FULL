part of '../Collections.dart';

class CollectionsMyCollectionsTab extends StatefulWidget {
  final ValueChanged<String> onMessage;

  const CollectionsMyCollectionsTab({
    required this.onMessage,
    Key? key,
  }) : super(key: key);

  @override
  State<CollectionsMyCollectionsTab> createState() =>
      _CollectionsMyCollectionsTabState();
}

class _CollectionsMyCollectionsTabState
    extends State<CollectionsMyCollectionsTab> {
  static const Color _bgColor = Color(0xFF050C04);
  static const Color _cardDark = Color(0xFF0D1A0B);
  static const Color _cardDeep = Color(0xFF081208);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  late List<_MyCollection> _myCollections;

  @override
  void initState() {
    super.initState();
    _myCollections = [
      _MyCollection(
        id: 'my_1',
        name: 'My Retirement Fund',
        description: 'Long-term portfolio',
        fundCount: 8,
        totalValue: 450000,
        monthlyContribution: 15000,
        allocation: {
          'Equity': 60,
          'Debt': 30,
          'Gold': 10,
        },
      ),
      _MyCollection(
        id: 'my_2',
        name: 'Short-Term Goals',
        description: '2-3 year investments',
        fundCount: 5,
        totalValue: 125000,
        monthlyContribution: 5000,
        allocation: {
          'Balanced': 70,
          'Debt': 30,
        },
      ),
      _MyCollection(
        id: 'my_3',
        name: 'Child Education',
        description: '15+ year horizon',
        fundCount: 4,
        totalValue: 320000,
        monthlyContribution: 10000,
        allocation: {
          'Growth': 80,
          'Equity': 20,
        },
      ),
    ];
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardDark,
        title: const Text(
          'Delete Collection?',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${_myCollections[index].name}"?',
          style: const TextStyle(
            color: _textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: _lime,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => _myCollections.removeAt(index));
              Navigator.pop(context);
              widget.onMessage(
                'Collection deleted',
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Color(0xFFF44336),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Collections',
                    style: TextStyle(
                      color: _textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_myCollections.length} active collections',
                    style: TextStyle(
                      color: _textMuted,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  widget.onMessage('Create new collection');
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _lime,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: _bgColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _myCollections.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '📭',
                        style: TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No collections yet',
                        style: TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create one to organize your funds',
                        style: TextStyle(
                          color: _textMuted,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _myCollections.length,
                  itemBuilder: (context, index) =>
                      _buildMyCollectionCard(_myCollections[index], index),
                ),
        ),
      ],
    );
  }

  Widget _buildMyCollectionCard(_MyCollection collection, int index) {
    return GestureDetector(
      onTap: () {
        widget.onMessage('Viewing ${collection.name}');
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
                PopupMenuButton(
                  color: _cardDeep,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        widget.onMessage(
                          'Editing ${collection.name}',
                        );
                      },
                    ),
                    PopupMenuItem(
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Color(0xFFF44336),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () => _showDeleteDialog(index),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '₹${(collection.totalValue / 100000).toStringAsFixed(1)}L Total Value',
              style: const TextStyle(
                color: _lime,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Monthly Contribution: ₹${(collection.monthlyContribution / 1000).toStringAsFixed(0)}K',
              style: TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: collection.allocation.entries
                  .map((e) => Chip(
                        label: Text(
                          '${e.key}: ${e.value}%',
                          style: const TextStyle(
                            color: _bgColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                        backgroundColor: _lime.withOpacity(0.8),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Text(
              'Funds: ${collection.fundCount}',
              style: TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyCollection {
  final String id;
  final String name;
  final String description;
  final int fundCount;
  final double totalValue;
  final double monthlyContribution;
  final Map<String, int> allocation;

  _MyCollection({
    required this.id,
    required this.name,
    required this.description,
    required this.fundCount,
    required this.totalValue,
    required this.monthlyContribution,
    required this.allocation,
  });

  _MyCollection copyWith({
    String? id,
    String? name,
    String? description,
    int? fundCount,
    double? totalValue,
    double? monthlyContribution,
    Map<String, int>? allocation,
  }) {
    return _MyCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      fundCount: fundCount ?? this.fundCount,
      totalValue: totalValue ?? this.totalValue,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      allocation: allocation ?? this.allocation,
    );
  }
}
