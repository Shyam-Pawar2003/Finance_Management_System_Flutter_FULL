import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateInvoiceDashboardPage extends StatefulWidget {
  const CreateInvoiceDashboardPage({super.key});

  @override
  State<CreateInvoiceDashboardPage> createState() =>
      _CreateInvoiceDashboardPageState();
}

class _CreateInvoiceDashboardPageState
    extends State<CreateInvoiceDashboardPage> {
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _dueDate = DateTime.now().add(const Duration(days: 14));
  double _taxPercent = 18;
  bool _sendByEmail = true;
  bool _markAsPaid = false;

  final List<_InvoiceLineItem> _items = [
    const _InvoiceLineItem(
      description: 'Consulting Services',
      quantity: 1,
      unitPrice: 1200,
    ),
  ];

  final List<_GeneratedInvoice> _history = [];

  @override
  void dispose() {
    _clientController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _subTotal {
    return _items.fold<double>(0, (sum, item) {
      return sum + (item.quantity * item.unitPrice);
    });
  }

  double get _taxAmount => _subTotal * (_taxPercent / 100);

  double get _grandTotal => _subTotal + _taxAmount;

  String _money(double value) {
    final rounded = value.toStringAsFixed(2);
    final parts = rounded.split('.');
    final whole = parts[0];
    final decimal = parts[1];
    final buffer = StringBuffer();

    for (var i = 0; i < whole.length; i++) {
      final reverseIndex = whole.length - i;
      buffer.write(whole[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    return '\$${buffer.toString()}.$decimal';
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _showLineItemDialog({int? index}) async {
    final editing = index != null;
    final existing = editing ? _items[index] : null;

    final descController = TextEditingController(text: existing?.description);
    final qtyController = TextEditingController(
      text: existing == null ? '1' : '${existing.quantity}',
    );
    final priceController = TextEditingController(
      text: existing == null ? '' : '${existing.unitPrice}',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(editing ? 'Edit Line Item' : 'Add Line Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Unit Price'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final description = descController.text.trim();
                final quantity = int.tryParse(qtyController.text.trim());
                final unitPrice = double.tryParse(priceController.text.trim());

                if (description.isEmpty ||
                    quantity == null ||
                    quantity <= 0 ||
                    unitPrice == null ||
                    unitPrice <= 0) {
                  _showMessage('Please enter valid line item details.');
                  return;
                }

                setState(() {
                  final item = _InvoiceLineItem(
                    description: description,
                    quantity: quantity,
                    unitPrice: unitPrice,
                  );
                  if (editing) {
                    _items[index] = item;
                  } else {
                    _items.add(item);
                  }
                });

                Navigator.of(dialogContext).pop();
              },
              child: Text(editing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  bool _validateInvoiceForm() {
    final client = _clientController.text.trim();
    final email = _emailController.text.trim();

    if (client.isEmpty) {
      _showMessage('Please enter client name.');
      return false;
    }
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      _showMessage('Please enter a valid client email address.');
      return false;
    }
    if (_items.isEmpty) {
      _showMessage('Please add at least one invoice item.');
      return false;
    }
    return true;
  }

  void _generateInvoice() {
    if (!_validateInvoiceForm()) return;

    final invoiceId =
        'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    final invoice = _GeneratedInvoice(
      id: invoiceId,
      client: _clientController.text.trim(),
      email: _emailController.text.trim(),
      dueDate: _dueDate,
      subTotal: _subTotal,
      taxAmount: _taxAmount,
      totalAmount: _grandTotal,
      status: _markAsPaid ? 'Paid' : (_sendByEmail ? 'Sent' : 'Draft'),
      createdAt: DateTime.now(),
      itemCount: _items.length,
      notes: _notesController.text.trim(),
    );

    setState(() {
      _history.insert(0, invoice);
    });

    _showGeneratedInvoiceDialog(invoice);
  }

  Future<void> _sendInvoiceEmail(_GeneratedInvoice invoice) async {
    setState(() {
      final index = _history.indexWhere((i) => i.id == invoice.id);
      if (index != -1) {
        _history[index] = _history[index].copyWith(status: 'Sent');
      }
    });
    _showMessage('Invoice ${invoice.id} email sent to ${invoice.email}.');
  }

  Future<void> _copyInvoiceSummary(_GeneratedInvoice invoice) async {
    final summary = StringBuffer()
      ..writeln('Invoice Summary')
      ..writeln('ID: ${invoice.id}')
      ..writeln('Client: ${invoice.client}')
      ..writeln('Email: ${invoice.email}')
      ..writeln('Due Date: ${_formatDate(invoice.dueDate)}')
      ..writeln('Subtotal: ${_money(invoice.subTotal)}')
      ..writeln('Tax: ${_money(invoice.taxAmount)}')
      ..writeln('Total: ${_money(invoice.totalAmount)}')
      ..writeln('Status: ${invoice.status}');

    await Clipboard.setData(ClipboardData(text: summary.toString()));
    _showMessage('Invoice summary copied to clipboard.');
  }

  void _showGeneratedInvoiceDialog(_GeneratedInvoice invoice) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Invoice ${invoice.id} Created'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Client: ${invoice.client}'),
              const SizedBox(height: 4),
              Text('Due: ${_formatDate(invoice.dueDate)}'),
              const SizedBox(height: 4),
              Text('Total: ${_money(invoice.totalAmount)}'),
              const SizedBox(height: 4),
              Text('Status: ${invoice.status}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Close'),
            ),
            OutlinedButton(
              onPressed: () async {
                await _copyInvoiceSummary(invoice);
              },
              child: const Text('Copy Summary'),
            ),
            FilledButton(
              onPressed: () async {
                await _sendInvoiceEmail(invoice);
                if (!mounted) return;
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Send Email'),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    setState(() {
      _clientController.clear();
      _emailController.clear();
      _notesController.clear();
      _dueDate = DateTime.now().add(const Duration(days: 14));
      _taxPercent = 18;
      _sendByEmail = true;
      _markAsPaid = false;
      _items
        ..clear()
        ..add(
          const _InvoiceLineItem(
            description: 'Consulting Services',
            quantity: 1,
            unitPrice: 1200,
          ),
        );
    });
    _showMessage('Invoice form reset.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Create Invoice',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(),
              const SizedBox(height: 14),
              _buildClientDetailsPanel(),
              const SizedBox(height: 14),
              _buildLineItemsPanel(),
              const SizedBox(height: 14),
              _buildSummaryPanel(),
              const SizedBox(height: 14),
              _buildHistoryPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F355B), Color(0xFF1A73E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          _heroChip('Items', '${_items.length}'),
          _heroChip('Subtotal', _money(_subTotal)),
          _heroChip('Tax', '${_taxPercent.toStringAsFixed(0)}%'),
          _heroChip('Grand Total', _money(_grandTotal)),
        ],
      ),
    );
  }

  Widget _heroChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientDetailsPanel() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Client & Invoice Details',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _clientController,
            decoration: const InputDecoration(
              labelText: 'Client Name',
              filled: true,
              fillColor: Color(0xFFF8FAFC),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Client Email',
              filled: true,
              fillColor: Color(0xFFF8FAFC),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _pickDueDate,
                icon: const Icon(Icons.calendar_today_rounded, size: 16),
                label: Text('Due ${_formatDate(_dueDate)}'),
              ),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<double>(
                  value: _taxPercent,
                  decoration: const InputDecoration(
                    labelText: 'Tax %',
                    filled: true,
                    fillColor: Color(0xFFF8FAFC),
                  ),
                  items: const [0, 5, 12, 18, 28]
                      .map(
                        (tax) => DropdownMenuItem(
                          value: tax.toDouble(),
                          child: Text('${tax.toInt()}%'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _taxPercent = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notes',
              filled: true,
              fillColor: Color(0xFFF8FAFC),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Send by email on create'),
            value: _sendByEmail,
            onChanged: (value) {
              setState(() {
                _sendByEmail = value;
              });
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Mark as paid'),
            value: _markAsPaid,
            onChanged: (value) {
              setState(() {
                _markAsPaid = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLineItemsPanel() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Line Items',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _showLineItemDialog(),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Item'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_items.isEmpty)
            const Text(
              'No line items added yet.',
              style: TextStyle(color: Color(0xFF64748B)),
            )
          else
            ..._items.asMap().entries.map(
                  (entry) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.value.description,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Qty ${entry.value.quantity} x ${_money(entry.value.unitPrice)}',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _money(entry.value.quantity * entry.value.unitPrice),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () =>
                              _showLineItemDialog(index: entry.key),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _items.removeAt(entry.key);
                            });
                          },
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSummaryPanel() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Invoice Summary',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _summaryRow('Subtotal', _money(_subTotal)),
          _summaryRow(
              'Tax (${_taxPercent.toStringAsFixed(0)}%)', _money(_taxAmount)),
          const Divider(height: 20),
          _summaryRow('Grand Total', _money(_grandTotal), emphasize: true),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _generateInvoice,
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Generate Invoice'),
              ),
              OutlinedButton.icon(
                onPressed: _clearForm,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Clear Form'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: emphasize
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF64748B),
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
              fontSize: emphasize ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPanel() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generated Invoices',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (_history.isEmpty)
            const Text(
              'No invoices generated yet.',
              style: TextStyle(color: Color(0xFF64748B)),
            )
          else
            ..._history.map(
              (invoice) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${invoice.id} - ${invoice.client}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        _statusChip(invoice.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total ${_money(invoice.totalAmount)} | Due ${_formatDate(invoice.dueDate)} | ${invoice.itemCount} items',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showGeneratedInvoiceDialog(invoice),
                          icon: const Icon(Icons.visibility_outlined, size: 16),
                          label: const Text('Preview'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _copyInvoiceSummary(invoice),
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text('Copy'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => _sendInvoiceEmail(invoice),
                          icon: const Icon(Icons.send_rounded, size: 16),
                          label: const Text('Send'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = status == 'Paid'
        ? const Color(0xFF0F9D58)
        : status == 'Sent'
            ? const Color(0xFF1A73E8)
            : const Color(0xFFF29900);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EBF3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InvoiceLineItem {
  const _InvoiceLineItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  final String description;
  final int quantity;
  final double unitPrice;
}

class _GeneratedInvoice {
  const _GeneratedInvoice({
    required this.id,
    required this.client,
    required this.email,
    required this.dueDate,
    required this.subTotal,
    required this.taxAmount,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.itemCount,
    required this.notes,
  });

  final String id;
  final String client;
  final String email;
  final DateTime dueDate;
  final double subTotal;
  final double taxAmount;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final int itemCount;
  final String notes;

  _GeneratedInvoice copyWith({
    String? status,
  }) {
    return _GeneratedInvoice(
      id: id,
      client: client,
      email: email,
      dueDate: dueDate,
      subTotal: subTotal,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      status: status ?? this.status,
      createdAt: createdAt,
      itemCount: itemCount,
      notes: notes,
    );
  }
}
