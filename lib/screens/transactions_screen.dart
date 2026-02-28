import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _type = 'expense';
  String _category = 'General';
  DateTime _date = DateTime.now();
  final _categories = ['General', 'Salary', 'Food', 'Transport', 'Other'];

  @override
  Widget build(BuildContext context) {
    final txProv = Provider.of<TransactionProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title')),
            TextField(
                controller: _amountCtrl,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number),
            Row(children: [
              DropdownButton<String>(
                  value: _type,
                  items: const [
                    DropdownMenuItem(value: 'income', child: Text('Income')),
                    DropdownMenuItem(value: 'expense', child: Text('Expense'))
                  ],
                  onChanged: (v) => setState(() => _type = v!)),
              const SizedBox(width: 12),
              DropdownButton<String>(
                  value: _category,
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!)),
              const Spacer(),
              TextButton(
                  onPressed: () async {
                    final d = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100));
                    if (d != null) setState(() => _date = d);
                  },
                  child: Text('${_date.toLocal()}'.split(' ')[0]))
            ]),
            ElevatedButton(
                onPressed: () {
                  final title = _titleCtrl.text.trim();
                  final amount = double.tryParse(_amountCtrl.text) ?? 0.0;
                  if (title.isEmpty || amount <= 0) return;
                  final t = TransactionModel(
                      id: const Uuid().v4(),
                      title: title,
                      amount: amount,
                      type: _type,
                      category: _category,
                      date: _date);
                  txProv.addTransaction(t);
                  _titleCtrl.clear();
                  _amountCtrl.clear();
                  setState(() {});
                },
                child: const Text('Save')),
            const SizedBox(height: 12),
            Expanded(
                child: ListView.builder(
                    itemCount: txProv.transactions.length,
                    itemBuilder: (ctx, i) {
                      final t = txProv.transactions[i];
                      return ListTile(
                        leading: CircleAvatar(
                            backgroundColor:
                                t.type == 'income' ? Colors.green : Colors.red,
                            child: Text(t.type == 'income' ? '+' : '-')),
                        title: Text(t.title),
                        subtitle: Text('${t.category} • ${t.date.toLocal()}'
                            .split(' ')[0]),
                        trailing: Text(t.amount.toStringAsFixed(2)),
                      );
                    }))
          ],
        ),
      ),
    );
  }
}
