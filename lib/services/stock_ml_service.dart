import 'dart:math';

class StockMlService {
  // Simple linear regression to predict next price from historicalPrices
  double predict(List<double> prices) {
    if (prices.length < 2) return prices.isNotEmpty ? prices.last : 0.0;
    final n = prices.length;
    final xs = List<double>.generate(n, (i) => i.toDouble());
    final ys = prices;
    final xMean = xs.reduce((a, b) => a + b) / n;
    final yMean = ys.reduce((a, b) => a + b) / n;
    double num = 0.0, den = 0.0;
    for (var i = 0; i < n; i++) {
      num += (xs[i] - xMean) * (ys[i] - yMean);
      den += (xs[i] - xMean) * (xs[i] - xMean);
    }
    final slope = den == 0 ? 0.0 : num / den;
    final intercept = yMean - slope * xMean;
    final nextX = n.toDouble();
    return intercept + slope * nextX;
  }

  String recommendation(double predicted, double current) {
    if (predicted > current * 1.03) return 'Buy';
    if (predicted < current * 0.97) return 'Sell';
    return 'Hold';
  }

  int randomSentiment() {
    final rnd = Random();
    return rnd.nextInt(101);
  }
}
