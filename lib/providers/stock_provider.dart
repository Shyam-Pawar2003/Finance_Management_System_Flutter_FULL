import 'package:flutter/material.dart';
import '../models/stock_model.dart';
import '../services/stock_service.dart';
import '../services/stock_ml_service.dart';

class StockProvider extends ChangeNotifier {
  StockModel? _stock;

  StockModel? get stock => _stock;

  final StockService _service = StockService();
  final StockMlService _ml = StockMlService();

  Future<void> analyze(String symbol) async {
    final data = await _service.fetchStock(symbol);
    final predicted = _ml.predict(data.historicalPrices);
    final recommendation = _ml.recommendation(predicted, data.currentPrice);
    final sentiment = _ml.randomSentiment();

    _stock = StockModel(
      symbol: symbol.toUpperCase(),
      currentPrice: data.currentPrice,
      previousClose: data.previousClose,
      historicalPrices: data.historicalPrices,
      predictionPrice: predicted,
      recommendation: recommendation,
      sentimentScore: sentiment,
    );
    notifyListeners();
  }
}
