import 'package:flutter/material.dart';

class ExportPayrollSheetPage extends StatefulWidget {
  const ExportPayrollSheetPage({super.key});

  @override
  State<ExportPayrollSheetPage> createState() => _ExportPayrollSheetPageState();
}

class _ExportPayrollSheetPageState extends State<ExportPayrollSheetPage> {
  final List<_PayrollExportRecord> _records = const [
    _PayrollExportRecord(
      id: 'EMP-001',
      name: 'John Doe',
      department: 'Finance',
      salary: 5000,
      reimbursement: 320,
      payDate: '18 Mar 2026',
    ),
    _PayrollExportRecord(
      id: 'EMP-002',
      name: 'Jane Smith',
      department: 'Accounting',
      salary: 4500,
      reimbursement: 0,
      payDate: '18 Mar 2026',
    ),
    _PayrollExportRecord(
      id: 'EMP-003',
      name: 'Mike Johnson',
      department: 'Finance',
      salary: 6000,
      reimbursement: 180,
      payDate: '18 Mar 2026',
    ),
    _PayrollExportRecord(
      id: 'EMP-004',
      name: 'Sarah Williams',
      department: 'HR',
      salary: 5500,
      reimbursement: 70,
      payDate: '18 Mar 2026',
    ),
    _PayrollExportRecord(
      id: 'EMP-005',
      name: 'Tom Brown',
      department: 'Operations',
      salary: 4800,
      reimbursement: 420,
      payDate: '19 Mar 2026',
    ),
    _PayrollExportRecord(
      id: 'EMP-006',
      name: 'Aisha Khan',
      department: 'Accounting',
      salary: 4700,
      reimbursement: 0,
      payDate: '19 Mar 2026',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  final List<_ExportHistoryItem> _history = [];

  String _searchQuery = '';
  String _selectedDepartment = 'All';
  String _selectedFormat = 'PDF';

  static const List<String> _formats = ['PDF', 'CSV', 'Excel'];

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(_records.map((e) => e.id));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _departments {
    final values = _records.map((e) => e.department).toSet().toList()..sort();
    return ['All', ...values];
  }

  List<_PayrollExportRecord> get _filteredRecords {
    final q = _searchQuery.trim().toLowerCase();
    return _records.where((record) {
      final matchesQuery = q.isEmpty ||
          record.name.toLowerCase().contains(q) ||
          record.id.toLowerCase().contains(q) ||
          record.department.toLowerCase().contains(q);

      final matchesDepartment = _selectedDepartment == 'All' ||
          record.department == _selectedDepartment;

      return matchesQuery && matchesDepartment;
    }).toList();
  }

  String _currency(double amount) {
    final raw = amount.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final reverseIndex = raw.length - i;
      buffer.write(raw[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return '\$${buffer.toString()}';
  }

  double get _selectedTotal => _records
      .where((record) => _selectedIds.contains(record.id))
      .fold(0, (sum, record) => sum + record.netPay);

  void _toggleSelect(String id, bool checked) {
    setState(() {
      if (checked) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _toggleSelectAll(bool checked) {
    final visibleIds = _filteredRecords.map((e) => e.id);
    setState(() {
      if (checked) {
        _selectedIds.addAll(visibleIds);
      } else {
        _selectedIds.removeWhere(visibleIds.contains);
      }
    });
  }

  void _exportSelected() {
    if (_selectedIds.isEmpty) {
      _showMessage('Select at least one employee to export.');
      return;
    }

    final selected =
        _records.where((record) => _selectedIds.contains(record.id)).toList();

    setState(() {
      _history.insertAll(
        0,
        selected.map(
          (record) => _ExportHistoryItem(
            employeeId: record.id,
            name: record.name,
            format: _selectedFormat,
            amount: record.netPay,
            time: 'Just now',
          ),
        ),
      );
    });

    _showMessage(
      '${selected.length} payroll row(s) exported as $_selectedFormat.',
    );
  }

  void _exportSingle(_PayrollExportRecord record) {
    setState(() {
      _history.insert(
        0,
        _ExportHistoryItem(
          employeeId: record.id,
          name: record.name,
          format: _selectedFormat,
          amount: record.netPay,
          time: 'Just now',
        ),
      );
    });
    _showMessage('${record.name} exported as $_selectedFormat.');
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Color _formatColor(String format) {
    switch (format) {
      case 'CSV':
        return const Color(0xFF16A34A);
      case 'Excel':
        return const Color(0xFF0F766E);
      default:
        return const Color(0xFFDC2626);
    }
  }

  IconData _formatIcon(String format) {
    switch (format) {
      case 'CSV':
        return Icons.table_chart_rounded;
      case 'Excel':
        return Icons.grid_on_rounded;
      default:
        return Icons.picture_as_pdf_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _filteredRecords;
    final allVisibleSelected =
        visible.isNotEmpty && visible.every((e) => _selectedIds.contains(e.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: const Text('Export Payroll Sheet'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFF), Color(0xFFEEF3FB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 980;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(),
                    const SizedBox(height: 14),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 3,
                              child: _buildExportPanel(
                                  visible, allVisibleSelected)),
                          const SizedBox(width: 14),
                          Expanded(flex: 2, child: _buildHistoryPanel()),
                        ],
                      )
                    else ...[
                      _buildExportPanel(visible, allVisibleSelected),
                      const SizedBox(height: 14),
                      _buildHistoryPanel(),
                    ],
                    const SizedBox(height: 14),
                    _buildFooter(isWide),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2C67), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payroll Export Hub',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 23,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose payroll rows, select output format, and generate report-ready sheets.',
            style:
                TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _heroChip('Records', '${_records.length}'),
              _heroChip('Selected', '${_selectedIds.length}'),
              _heroChip('Selected Total', _currency(_selectedTotal)),
              _heroChip('Format', _selectedFormat),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildExportPanel(
      List<_PayrollExportRecord> visible, bool allVisibleSelected) {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Export Queue',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search by employee or id...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _departments.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final dept = _departments[index];
                      final selected = dept == _selectedDepartment;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDepartment = dept),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            dept,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF475569),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: allVisibleSelected,
                      onChanged: (value) => _toggleSelectAll(value ?? false),
                      activeColor: const Color(0xFF2563EB),
                    ),
                    const Text('Select all visible'),
                    const Spacer(),
                    Text(
                      '${visible.length} record(s)',
                      style: const TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          if (visible.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Text(
                  'No rows match the selected filters.',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visible.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) => _buildRowItem(visible[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildRowItem(_PayrollExportRecord record) {
    final selected = _selectedIds.contains(record.id);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Checkbox(
            value: selected,
            onChanged: (value) => _toggleSelect(record.id, value ?? false),
            activeColor: const Color(0xFF2563EB),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${record.id}  |  ${record.department}  |  ${record.payDate}',
                  style:
                      const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            _currency(record.netPay),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(width: 10),
          TextButton.icon(
            onPressed: () => _exportSingle(record),
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Export'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2563EB),
              backgroundColor: const Color(0xFF2563EB).withOpacity(0.10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPanel() {
    return _panel(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Export History',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (_history.isEmpty)
              const Text(
                'No exports yet.',
                style: TextStyle(color: Color(0xFF94A3B8)),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = _history[index];
                  final color = _formatColor(item.format);
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(_formatIcon(item.format),
                              color: color, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              Text(
                                '${item.employeeId}  |  ${item.format}  |  ${_currency(item.amount)}',
                                style: TextStyle(
                                    color: color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          item.time,
                          style: const TextStyle(
                              color: Color(0xFF94A3B8), fontSize: 11),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isWide) {
    final selector = Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _formats.map((format) {
        final selected = format == _selectedFormat;
        final color = _formatColor(format);
        return GestureDetector(
          onTap: () => setState(() => _selectedFormat = format),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: selected ? color : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: selected ? color : const Color(0xFFE2E8F0)),
            ),
            child: Text(
              format,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF475569),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );

    return _panel(
      padding: const EdgeInsets.all(16),
      child: isWide
          ? Row(
              children: [
                Expanded(
                  child: Text(
                    '${_selectedIds.length} selected  |  ${_currency(_selectedTotal)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                selector,
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _exportSelected,
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: Text('Export $_selectedFormat'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedIds.length} selected  |  ${_currency(_selectedTotal)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                selector,
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _exportSelected,
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text('Export $_selectedFormat'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _panel({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding,
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

class _PayrollExportRecord {
  const _PayrollExportRecord({
    required this.id,
    required this.name,
    required this.department,
    required this.salary,
    required this.reimbursement,
    required this.payDate,
  });

  final String id;
  final String name;
  final String department;
  final double salary;
  final double reimbursement;
  final String payDate;

  double get netPay => salary + reimbursement;
}

class _ExportHistoryItem {
  const _ExportHistoryItem({
    required this.employeeId,
    required this.name,
    required this.format,
    required this.amount,
    required this.time,
  });

  final String employeeId;
  final String name;
  final String format;
  final double amount;
  final String time;
}
