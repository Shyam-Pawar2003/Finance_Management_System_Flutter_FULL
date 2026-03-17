import 'package:flutter/material.dart';

class ExportStatementPage extends StatefulWidget {
  const ExportStatementPage({super.key});

  @override
  State<ExportStatementPage> createState() => _ExportStatementPageState();
}

class _ExportStatementPageState extends State<ExportStatementPage> {
  DateTimeRange? _range;
  String _format = _formats.first;
  bool _includePaid = true;
  bool _includePending = true;
  bool _includeOverdue = true;

  static const List<String> _formats = ['PDF', 'Excel', 'CSV'];

  final List<_RecentExportItem> _recentExports = [
    const _RecentExportItem(
      title: 'Monthly Statement',
      date: '01/10/2024',
      format: 'PDF',
      size: '1.2 MB',
    ),
    const _RecentExportItem(
      title: 'Quarterly Collection',
      date: '02/10/2024',
      format: 'Excel',
      size: '860 KB',
    ),
    const _RecentExportItem(
      title: 'Outstanding Summary',
      date: '05/10/2024',
      format: 'CSV',
      size: '310 KB',
    ),
    const _RecentExportItem(
      title: 'Client Balance Snapshot',
      date: '09/10/2024',
      format: 'PDF',
      size: '1.5 MB',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _range = _monthRange(DateTime.now());
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _range,
    );

    if (selected == null) return;
    setState(() {
      _range = selected;
    });
  }

  DateTimeRange _monthRange(DateTime value) {
    final start = DateTime(value.year, value.month, 1);
    final end = DateTime(value.year, value.month + 1, 0);
    return DateTimeRange(start: start, end: end);
  }

  DateTimeRange _quarterRange(DateTime value) {
    final quarterStartMonth = ((value.month - 1) ~/ 3) * 3 + 1;
    final start = DateTime(value.year, quarterStartMonth, 1);
    final end = DateTime(value.year, quarterStartMonth + 3, 0);
    return DateTimeRange(start: start, end: end);
  }

  DateTimeRange _yearToDateRange(DateTime value) {
    final start = DateTime(value.year, 1, 1);
    final end = DateTime(value.year, value.month, value.day);
    return DateTimeRange(start: start, end: end);
  }

  void _applyPreset(DateTimeRange range) {
    setState(() {
      _range = range;
    });
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  String get _rangeText {
    if (_range == null) {
      return 'No date range selected';
    }
    return '${_formatDate(_range!.start)} - ${_formatDate(_range!.end)}';
  }

  List<String> get _includedStatuses {
    return [
      if (_includePaid) 'Paid',
      if (_includePending) 'Pending',
      if (_includeOverdue) 'Overdue',
    ];
  }

  String get _statusScopeLabel {
    final statuses = _includedStatuses;
    if (statuses.isEmpty) {
      return 'No statuses selected';
    }
    return statuses.join(', ');
  }

  IconData _formatIcon(String format) {
    switch (format) {
      case 'PDF':
        return Icons.picture_as_pdf_rounded;
      case 'Excel':
        return Icons.grid_on_rounded;
      case 'CSV':
        return Icons.table_chart_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _formatColor(String format) {
    switch (format) {
      case 'PDF':
        return const Color(0xFFB91C1C);
      case 'Excel':
        return const Color(0xFF166534);
      case 'CSV':
        return const Color(0xFF0F766E);
      default:
        return const Color(0xFF2563EB);
    }
  }

  void _export() {
    if (_range == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date range first.')),
      );
      return;
    }

    final statuses = _includedStatuses;
    if (statuses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one invoice status to export.'),
        ),
      );
      return;
    }

    final generatedItem = _RecentExportItem(
      title:
          'Statement ${_formatDate(_range!.start)}-${_formatDate(_range!.end)}',
      date: _formatDate(DateTime.now()),
      format: _format,
      size: _format == 'CSV'
          ? '280 KB'
          : _format == 'Excel'
              ? '740 KB'
              : '1.1 MB',
    );

    setState(() {
      _recentExports.insert(0, generatedItem);
      if (_recentExports.length > 6) {
        _recentExports.removeLast();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Statement exported as $_format (${statuses.join(', ')}) for ${_formatDate(_range!.start)} - ${_formatDate(_range!.end)}.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: const Text('Export Statement'),
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
                    _buildHeroCard(),
                    const SizedBox(height: 14),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildFilterStudio()),
                          const SizedBox(width: 14),
                          Expanded(flex: 2, child: _buildRecentExportsPanel()),
                        ],
                      )
                    else ...[
                      _buildFilterStudio(),
                      const SizedBox(height: 14),
                      _buildRecentExportsPanel(),
                    ],
                    const SizedBox(height: 14),
                    _buildActionFooter(isWide),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
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
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statement Export Studio',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 23,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Generate polished invoice reports with period, scope, and format controls.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(
                  Icons.insert_chart_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _heroChip('Period', _rangeText),
              _heroChip('Format', _format),
              _heroChip('Scope', _statusScopeLabel),
              _heroChip('Recent exports', '${_recentExports.length} items'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String label, String value) {
    return Container(
      constraints: const BoxConstraints(minWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterStudio() {
    final now = DateTime.now();

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Studio',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pick a date span, choose format, and include statuses for the report.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _presetButton(
                label: 'This Month',
                onPressed: () => _applyPreset(_monthRange(now)),
              ),
              _presetButton(
                label: 'This Quarter',
                onPressed: () => _applyPreset(_quarterRange(now)),
              ),
              _presetButton(
                label: 'Year to Date',
                onPressed: () => _applyPreset(_yearToDateRange(now)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _pickDateRange,
            icon: const Icon(Icons.date_range_rounded),
            label: Text(_rangeText),
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
              side: const BorderSide(color: Color(0xFFD5DEE9)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Export Format',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _formats
                .map(
                  (format) => ChoiceChip(
                    label: Text(format),
                    selected: _format == format,
                    onSelected: (_) {
                      setState(() {
                        _format = format;
                      });
                    },
                    selectedColor: const Color(0xFF1D4ED8),
                    labelStyle: TextStyle(
                      color: _format == format
                          ? Colors.white
                          : const Color(0xFF334155),
                      fontWeight: FontWeight.w700,
                    ),
                    side: BorderSide(
                      color: _format == format
                          ? const Color(0xFF1D4ED8)
                          : const Color(0xFFD5DEE9),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          const Text(
            'Status Scope',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _statusTile(
            title: 'Include paid invoices',
            value: _includePaid,
            onChanged: (value) {
              setState(() {
                _includePaid = value;
              });
            },
          ),
          _statusTile(
            title: 'Include pending invoices',
            value: _includePending,
            onChanged: (value) {
              setState(() {
                _includePending = value;
              });
            },
          ),
          _statusTile(
            title: 'Include overdue invoices',
            value: _includeOverdue,
            onChanged: (value) {
              setState(() {
                _includeOverdue = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _presetButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFD5DEE9)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF334155),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _statusTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: SwitchListTile(
        value: value,
        contentPadding: EdgeInsets.zero,
        activeColor: const Color(0xFF1D4ED8),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildRecentExportsPanel() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Exports',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Latest generated statements and download snapshots.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          ..._recentExports.map(_buildRecentExportCard),
        ],
      ),
    );
  }

  Widget _buildRecentExportCard(_RecentExportItem item) {
    final accent = _formatColor(item.format);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_formatIcon(item.format), color: accent, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.date} | ${item.size}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.format,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionFooter(bool isWide) {
    final summary = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Export Preview',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          '$_format file | $_rangeText | $_statusScopeLabel',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final exportButton = ElevatedButton.icon(
      onPressed: _export,
      icon: const Icon(Icons.download_rounded),
      label: const Text('Export Statement'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0F355B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    return _panel(
      child: isWide
          ? Row(
              children: [
                Expanded(child: summary),
                const SizedBox(width: 12),
                exportButton,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summary,
                const SizedBox(height: 10),
                SizedBox(width: double.infinity, child: exportButton),
              ],
            ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RecentExportItem {
  const _RecentExportItem({
    required this.title,
    required this.date,
    required this.format,
    required this.size,
  });

  final String title;
  final String date;
  final String format;
  final String size;
}
