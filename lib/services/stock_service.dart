import 'dart:math';

class _StockRaw {
  final double currentPrice;
  final double previousClose;
  final List<double> historicalPrices;

  _StockRaw(
      {required this.currentPrice,
      required this.previousClose,
      required this.historicalPrices});
}

class StockService {
  // Mock fetching stock data. In production replace with AlphaVantage/http logic.
  Future<_StockRaw> fetchStock(String symbol) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final rnd = Random(symbol.hashCode);
    final base = 100 + rnd.nextDouble() * 200;
    final hist = List<double>.generate(
        30,
        (i) =>
            base +
            (rnd.nextDouble() - 0.5) * 10 +
            i * (rnd.nextDouble() - 0.5));
    final current = hist.last;
    final prev = hist[hist.length - 2];
    return _StockRaw(
        currentPrice: current, previousClose: prev, historicalPrices: hist);
  }
}
