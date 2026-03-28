import 'package:flutter/material.dart';
import 'dart:async';

import '../models/stock_model.dart';
import '../services/firebase_service.dart';
import '../services/stock_service.dart';
import '../services/stock_ml_service.dart';

class StockProvider extends ChangeNotifier {
  StockProvider(this._firebaseService);

  final FirebaseService _firebaseService;
  StockModel? _stock;
  StreamSubscription<StockModel?>? _subscription;
  String? _activeUserId;
  String? _errorMessage;

  StockModel? get stock => _stock;
  String? get errorMessage => _errorMessage;
  String? get activeUserId => _activeUserId;

  final StockService _service = StockService();
  final StockMlService _ml = StockMlService();

  void bindToUser(String? userId) {
    if (_activeUserId == userId) return;

    _subscription?.cancel();
    _activeUserId = userId;
    _stock = null;
    _errorMessage = null;

    if (userId == null) {
      notifyListeners();
      return;
    }

    _subscription = _firebaseService.streamLatestStockAnalysis(userId).listen(
      (item) {
        if (item != null) {
          _stock = item;
          notifyListeners();
        }
      },
      onError: (_) {
        _errorMessage = 'Unable to load saved stock analysis.';
        notifyListeners();
      },
    );
  }

  Future<void> analyze(String symbol) async {
    _errorMessage = null;
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

    if (_activeUserId != null) {
      try {
        await _firebaseService.upsertStockAnalysis(
          userId: _activeUserId!,
          stock: _stock!,
        );
      } catch (_) {
        _errorMessage = 'Analysis created, but cloud save failed.';
      }
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
