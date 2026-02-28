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
}
