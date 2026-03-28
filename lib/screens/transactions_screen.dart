import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _type = 'expense';
  String _category = 'General';
  DateTime _date = DateTime.now();
  final _categories = ['General', 'Salary', 'Food', 'Transport', 'Other'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txProv = Provider.of<TransactionProvider>(context);

    if (txProv.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(txProv.errorMessage!)),
        );
        txProv.clearError();
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Title is required'
                            : null,
                  ),
                  TextFormField(
                    controller: _amountCtrl,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      final amount = double.tryParse((value ?? '').trim()) ?? 0;
                      if (amount <= 0) return 'Amount should be greater than 0';
                      return null;
                    },
                  ),
                  Row(children: [
                    DropdownButton<String>(
                      value: _type,
                      items: const [
                        DropdownMenuItem(
                            value: 'income', child: Text('Income')),
                        DropdownMenuItem(
                            value: 'expense', child: Text('Expense')),
                      ],
                      onChanged: (v) => setState(() => _type = v!),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _category,
                      items: _categories
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) setState(() => _date = d);
                      },
                      child: Text(DateFormat('yyyy-MM-dd').format(_date)),
                    ),
                  ]),
                  ElevatedButton(
                    onPressed: txProv.isLoading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;

                            final t = TransactionModel(
                              id: const Uuid().v4(),
                              title: _titleCtrl.text.trim(),
                              amount: double.parse(_amountCtrl.text.trim()),
                              type: _type,
                              category: _category,
                              date: _date,
                            );

                            final ok = await txProv.addTransaction(t);
                            if (!mounted) return;
                            if (ok) {
                              _titleCtrl.clear();
                              _amountCtrl.clear();
                            }
                          },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: txProv.activeUserId == null
                  ? const Center(
                      child: Text('Login required to view transactions.'),
                    )
                  : StreamBuilder<List<TransactionModel>>(
                      stream: txProv.streamForCurrentUser(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('Failed to load transactions.'),
                          );
                        }

                        final items = snapshot.data ?? <TransactionModel>[];
                        if (items.isEmpty) {
                          return const Center(
                            child: Text('No transactions yet.'),
                          );
                        }

                        return ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (ctx, i) {
                            final t = items[i];
                            return Dismissible(
                              key: ValueKey(t.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                color: Colors.red,
                                padding: const EdgeInsets.only(right: 16),
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              onDismissed: (_) {
                                txProv.deleteTransaction(t.id);
                              },
                              child: ListTile(
                                onTap: () =>
                                    _showEditDialog(context, txProv, t),
                                leading: CircleAvatar(
                                  backgroundColor: t.type == 'income'
                                      ? Colors.green
                                      : Colors.red,
                                  child: Text(t.type == 'income' ? '+' : '-'),
                                ),
                                title: Text(t.title),
                                subtitle: Text(
                                  '${t.category} • ${DateFormat('yyyy-MM-dd').format(t.date)}',
                                ),
                                trailing: Text(t.amount.toStringAsFixed(2)),
                              ),
                            );
                          },
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    TransactionProvider txProv,
    TransactionModel existing,
  ) async {
    final titleCtrl = TextEditingController(text: existing.title);
    final amountCtrl = TextEditingController(text: existing.amount.toString());
    var type = existing.type;
    var category = existing.category;
    var date = existing.date;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Transaction'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: amountCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Amount'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: type,
                      items: const [
                        DropdownMenuItem(
                            value: 'income', child: Text('Income')),
                        DropdownMenuItem(
                            value: 'expense', child: Text('Expense')),
                      ],
                      onChanged: (v) => setDialogState(() => type = v!),
                    ),
                    DropdownButton<String>(
                      value: category,
                      items: _categories
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setDialogState(() => category = v!),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() => date = picked);
                        }
                      },
                      child: Text(DateFormat('yyyy-MM-dd').format(date)),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved != true) return;

    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
    if (titleCtrl.text.trim().isEmpty || amount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid transaction details.')),
      );
      return;
    }

    await txProv.updateTransaction(
      TransactionModel(
        id: existing.id,
        title: titleCtrl.text.trim(),
        amount: amount,
        type: type,
        category: category,
        date: date,
      ),
    );
  }
}
