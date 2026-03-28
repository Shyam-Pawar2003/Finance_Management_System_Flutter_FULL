class StockModel {
  final String symbol;
  final double currentPrice;
  final double previousClose;
  final List<double> historicalPrices;
  final double predictionPrice;
  final String recommendation; // Buy / Hold / Sell
  final int sentimentScore; // 0-100

  StockModel({
    required this.symbol,
    required this.currentPrice,
    required this.previousClose,
    required this.historicalPrices,
    required this.predictionPrice,
    required this.recommendation,
    required this.sentimentScore,
  });

  Map<String, dynamic> toMap() => {
        'symbol': symbol,
        'currentPrice': currentPrice,
        'previousClose': previousClose,
        'historicalPrices': historicalPrices,
        'predictionPrice': predictionPrice,
        'recommendation': recommendation,
        'sentimentScore': sentimentScore,
      };

  factory StockModel.fromMap(Map<String, dynamic> map) {
    final historyRaw = map['historicalPrices'];
    final history = historyRaw is List
        ? historyRaw.map((e) => (e as num).toDouble()).toList()
        : <double>[];

    return StockModel(
      symbol: (map['symbol'] ?? '').toString(),
      currentPrice: ((map['currentPrice'] ?? 0) as num).toDouble(),
      previousClose: ((map['previousClose'] ?? 0) as num).toDouble(),
      historicalPrices: history,
      predictionPrice: ((map['predictionPrice'] ?? 0) as num).toDouble(),
      recommendation: (map['recommendation'] ?? 'Hold').toString(),
      sentimentScore: ((map['sentimentScore'] ?? 0) as num).toInt(),
    );
  }
}
