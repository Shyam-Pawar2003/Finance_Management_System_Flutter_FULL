import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/budget_model.dart';
import '../providers/budget_provider.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _categoryCtrl = TextEditingController();
  final _limitCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bp = Provider.of<BudgetProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(labelText: 'Category')),
          TextField(
              controller: _limitCtrl,
              decoration: const InputDecoration(labelText: 'Monthly Limit'),
              keyboardType: TextInputType.number),
          ElevatedButton(
              onPressed: () {
                final cat = _categoryCtrl.text.trim();
                final limit = double.tryParse(_limitCtrl.text) ?? 0.0;
                if (cat.isEmpty || limit <= 0) return;
                bp.addOrUpdateBudget(
                    BudgetModel(category: cat, monthlyLimit: limit));
                _categoryCtrl.clear();
                _limitCtrl.clear();
              },
              child: const Text('Save')),
          const SizedBox(height: 12),
          Expanded(
              child: ListView.builder(
                  itemCount: bp.budgets.length,
                  itemBuilder: (ctx, i) {
                    final b = bp.budgets[i];
                    final exceeded = b.spentAmount > b.monthlyLimit;
                    return Card(
                      child: ListTile(
                        title: Text(b.category),
                        subtitle: Text(
                            'Limit: ${b.monthlyLimit.toStringAsFixed(2)} • Spent: ${b.spentAmount.toStringAsFixed(2)}'),
                        trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  'Remaining: ${b.remainingAmount.toStringAsFixed(2)}'),
                              if (exceeded)
                                Text('Exceeded',
                                    style: TextStyle(color: Colors.red))
                            ]),
                      ),
                    );
                  }))
        ]),
      ),
    );
  }
}
