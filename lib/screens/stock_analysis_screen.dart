import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/stock_provider.dart';

class StockAnalysisScreen extends StatefulWidget {
  const StockAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<StockAnalysisScreen> createState() => _StockAnalysisScreenState();
}

class _StockAnalysisScreenState extends State<StockAnalysisScreen> {
  final _symCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final sp = Provider.of<StockProvider>(context);
    final s = sp.stock;
    return Scaffold(
      appBar: AppBar(title: const Text('Stock Analysis')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          Row(children: [
            Expanded(
                child: TextField(
                    controller: _symCtrl,
                    decoration: const InputDecoration(labelText: 'Symbol'))),
            ElevatedButton(
                onPressed: () => sp.analyze(_symCtrl.text.trim()),
                child: const Text('Analyze'))
          ]),
          const SizedBox(height: 12),
          if (s != null) ...[
            Text('Symbol: ${s.symbol}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
                'Current: ${s.currentPrice.toStringAsFixed(2)}  Prev: ${s.previousClose.toStringAsFixed(2)}'),
            Text('Predicted: ${s.predictionPrice.toStringAsFixed(2)}',
                style: TextStyle(
                    color: s.recommendation == 'Buy'
                        ? Colors.green
                        : s.recommendation == 'Sell'
                            ? Colors.red
                            : Colors.black)),
            Chip(
                label: Text(s.recommendation),
                backgroundColor: s.recommendation == 'Buy'
                    ? Colors.green[100]
                    : s.recommendation == 'Sell'
                        ? Colors.red[100]
                        : Colors.grey[200]),
            Text('Sentiment: ${s.sentimentScore}%'),
            const SizedBox(height: 12),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LineChart(_buildChart(s))))
          ]
        ]),
      ),
    );
  }

  LineChartData _buildChart(s) {
    final history = s.historicalPrices;
    final spots =
        List.generate(history.length, (i) => FlSpot(i.toDouble(), history[i]));
    final predX = history.length.toDouble();
    final predY = s.predictionPrice as double;

    return LineChartData(
      titlesData: FlTitlesData(show: false),
      lineBarsData: [
        LineChartBarData(
            spots: spots,
            isCurved: false,
            color: Colors.blue,
            dotData: FlDotData(show: false)),
        LineChartBarData(
            spots: [...spots, FlSpot(predX, predY)],
            isCurved: false,
            color: s.recommendation == 'Buy'
                ? Colors.green
                : s.recommendation == 'Sell'
                    ? Colors.red
                    : Colors.orange,
            dotData: FlDotData(show: true)),
      ],
    );
  }
}
