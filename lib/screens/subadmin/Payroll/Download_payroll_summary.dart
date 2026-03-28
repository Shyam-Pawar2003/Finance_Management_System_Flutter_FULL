import 'dart:convert';
import 'dart:math' show max;
import 'dart:typed_data';

import 'package:excel/excel.dart' hide Border;
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SubAdminDownloadPayrollSummaryPage extends StatefulWidget {
  const SubAdminDownloadPayrollSummaryPage({super.key});

  @override
  State<SubAdminDownloadPayrollSummaryPage> createState() =>
      _SubAdminDownloadPayrollSummaryPageState();
}

class _SubAdminDownloadPayrollSummaryPageState
    extends State<SubAdminDownloadPayrollSummaryPage> {
  String _selectedCycle = 'Mar 2026';
  String _selectedFormat = 'PDF';
  bool _includeCharts = true;
  bool _includeDepartmentSplit = true;
  bool _includeExceptionQueue = true;
  bool _compressDownload = false;
  bool _isDownloading = false;

  static const List<String> _cycleOptions = [
    'Mar 2026',
    'Feb 2026',
    'Jan 2026',
  ];

  static const List<String> _formatOptions = [
    'PDF',
    'CSV',
    'XLSX',
  ];

  final List<_DepartmentSummary> _departmentSummary = const [
    _DepartmentSummary('Finance', 27120),
    _DepartmentSummary('Operations', 22880),
    _DepartmentSummary('HR', 13210),
    _DepartmentSummary('Legal', 7280),
  ];

  final List<_DownloadHistory> _history = [
    _DownloadHistory(
      title: 'Payroll Summary - Mar 2026',
      cycle: 'Mar 2026',
      format: 'PDF',
      includeCharts: true,
      includeDepartmentSplit: true,
      includeExceptionQueue: true,
      compressed: false,
      createdBy: 'Shyam Patel',
      createdAt: 'Today, 10:25 AM',
      size: '2.4 MB',
    ),
    _DownloadHistory(
      title: 'Payroll Summary - Feb 2026',
      cycle: 'Feb 2026',
      format: 'XLSX',
      includeCharts: true,
      includeDepartmentSplit: true,
      includeExceptionQueue: true,
      compressed: false,
      createdBy: 'Shyam Patel',
      createdAt: 'Mar 01, 04:16 PM',
      size: '1.8 MB',
    ),
    _DownloadHistory(
      title: 'Payroll Exception Snapshot',
      cycle: 'Feb 2026',
      format: 'CSV',
      includeCharts: false,
      includeDepartmentSplit: false,
      includeExceptionQueue: true,
      compressed: false,
      createdBy: 'Shyam Patel',
      createdAt: 'Feb 28, 06:42 PM',
      size: '640 KB',
    ),
  ];

  static const List<_TrendPoint> _trendData = [
    _TrendPoint('Jan 2026', 68400),
    _TrendPoint('Feb 2026', 71200),
    _TrendPoint('Mar 2026', 70490),
  ];

  static const List<_ExceptionRecord> _exceptionRecords = [
    _ExceptionRecord('Aisha Patel', 'HR', 'Missing TDS declaration', 'High'),
    _ExceptionRecord(
        'Ravi Kumar', 'Finance', 'Overdraft limit breach', 'Critical'),
    _ExceptionRecord(
        'Deepak Nair', 'Legal', 'Pending bank verification', 'Medium'),
    _ExceptionRecord('Meena Sharma', 'Operations', 'LOP mismatch', 'High'),
  ];

  double get _totalPayout {
    return _departmentSummary.fold<double>(0, (sum, item) => sum + item.amount);
  }

  int get _sectionCount {
    var count = 1;
    if (_includeCharts) count++;
    if (_includeDepartmentSplit) count++;
    if (_includeExceptionQueue) count++;
    return count;
  }

  Future<void> _downloadSummary({String? historyTitle}) async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      final now = DateTime.now();
      final cycleSafe = _selectedCycle.replaceAll(' ', '_');
      final timestamp = now.millisecondsSinceEpoch;
      final fileName = 'Payroll_Summary_${cycleSafe}_$timestamp';

      Uint8List bytes;
      String ext;
      MimeType mime;

      switch (_selectedFormat) {
        case 'CSV':
          bytes = _buildCsvBytes();
          ext = 'csv';
          mime = MimeType.csv;
          break;
        case 'XLSX':
          bytes = _buildXlsxBytes();
          ext = 'xlsx';
          mime = MimeType.microsoftExcel;
          break;
        default: // PDF
          bytes = await _buildPdfBytes();
          ext = 'pdf';
          mime = MimeType.pdf;
      }

      final saveLocation = await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        ext: ext,
        mimeType: mime,
      );

      if (mounted) {
        setState(() {
          _history.insert(
            0,
            _DownloadHistory(
              title: historyTitle ?? 'Payroll Summary - $_selectedCycle',
              cycle: _selectedCycle,
              format: _selectedFormat,
              includeCharts: _includeCharts,
              includeDepartmentSplit: _includeDepartmentSplit,
              includeExceptionQueue: _includeExceptionQueue,
              compressed: _compressDownload,
              createdBy: 'Shyam Patel',
              createdAt: _formatCreatedAt(now),
              size: _formatFileSize(bytes.length),
            ),
          );
          if (_history.length > 20) {
            _history.removeRange(20, _history.length);
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              saveLocation.isNotEmpty
                  ? '$_selectedFormat saved to $saveLocation'
                  : 'Payroll_Summary_$cycleSafe.$ext downloaded successfully.',
            ),
            backgroundColor: const Color(0xFF1A73E8),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: const Color(0xFFD93025),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _downloadAgain(_DownloadHistory item) async {
    if (_isDownloading) return;

    setState(() {
      _selectedCycle = item.cycle;
      _selectedFormat = item.format;
      _includeCharts = item.includeCharts;
      _includeDepartmentSplit = item.includeDepartmentSplit;
      _includeExceptionQueue = item.includeExceptionQueue;
      _compressDownload = item.compressed;
    });

    await _downloadSummary(historyTitle: item.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 860;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isCompact ? 14 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isCompact),
                  const SizedBox(height: 16),
                  _buildHero(),
                  const SizedBox(height: 16),
                  if (isCompact) ...[
                    _buildConfigPanel(),
                    const SizedBox(height: 12),
                    _buildPreviewPanel(),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildConfigPanel()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildPreviewPanel()),
                      ],
                    ),
                  const SizedBox(height: 12),
                  _buildHistoryPanel(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isCompact) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Download Payroll Summary',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 6),
        Text(
          'Configure summary sections and download payroll insights in your preferred format.',
          style: TextStyle(color: Color(0xFF5F6368)),
        ),
      ],
    );

    final actions = _isDownloading
        ? FilledButton.icon(
            onPressed: null,
            icon: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            label: const Text('Generating...'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1A73E8),
            ),
          )
        : FilledButton.icon(
            onPressed: () => _downloadSummary(),
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Download Summary'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1A73E8),
            ),
          );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 12),
          actions,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: title),
        actions,
      ],
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F5ED7), Color(0xFF1A73E8), Color(0xFF36B39C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _heroChip('Cycle', _selectedCycle),
          _heroChip('Format', _selectedFormat),
          _heroChip('Sections', '$_sectionCount included'),
          _heroChip('Estimated Size', _compressDownload ? '1.4 MB' : '2.3 MB'),
        ],
      ),
    );
  }

  Widget _heroChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigPanel() {
    return _panel(
      title: 'Summary Configuration',
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedCycle,
            isExpanded: true,
            decoration: _inputDecoration('Payroll Cycle'),
            items: _cycleOptions
                .map((value) =>
                    DropdownMenuItem(value: value, child: Text(value)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCycle = value);
              }
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedFormat,
            isExpanded: true,
            decoration: _inputDecoration('File Format'),
            items: _formatOptions
                .map((value) =>
                    DropdownMenuItem(value: value, child: Text(value)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedFormat = value);
              }
            },
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            value: _includeCharts,
            onChanged: (value) => setState(() => _includeCharts = value),
            contentPadding: EdgeInsets.zero,
            title: const Text('Include trend charts'),
          ),
          SwitchListTile(
            value: _includeDepartmentSplit,
            onChanged: (value) =>
                setState(() => _includeDepartmentSplit = value),
            contentPadding: EdgeInsets.zero,
            title: const Text('Include department split'),
          ),
          SwitchListTile(
            value: _includeExceptionQueue,
            onChanged: (value) =>
                setState(() => _includeExceptionQueue = value),
            contentPadding: EdgeInsets.zero,
            title: const Text('Include exception queue'),
          ),
          SwitchListTile(
            value: _compressDownload,
            onChanged: (value) => setState(() => _compressDownload = value),
            contentPadding: EdgeInsets.zero,
            title: const Text('Compress downloaded file'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewPanel() {
    final maxValue =
        _departmentSummary.isEmpty ? 1.0 : _departmentSummary.first.amount;

    return _panel(
      title: 'Summary Preview',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimated payout: ${_currency(_totalPayout)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          ..._departmentSummary.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          row.department,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        _currency(row.amount),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A73E8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: row.amount / maxValue,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFF1A73E8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPanel() {
    return _panel(
      title: 'Recent Downloads',
      child: Column(
        children: _history
            .map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: Color(0xFF1A73E8),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${item.format}  |  ${item.createdAt}  |  ${item.size}',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _downloadAgain(item),
                      icon: const Icon(Icons.download_rounded),
                      color: const Color(0xFF1A73E8),
                      tooltip: 'Download again',
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _panel({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EBF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  String _currency(double value) {
    return '\$${value.toStringAsFixed(0)}';
  }

  String _formatCreatedAt(DateTime value) {
    final now = DateTime.now();
    final isToday = now.year == value.year &&
        now.month == value.month &&
        now.day == value.day;

    final hour12 = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    final time = '$hour12:$minute $period';

    if (isToday) {
      return 'Today, $time';
    }

    const monthNames = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = monthNames[value.month - 1];
    final day = value.day.toString().padLeft(2, '0');
    return '$month $day, $time';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    final kilobytes = bytes / 1024;
    if (kilobytes < 1024) {
      return '${kilobytes.toStringAsFixed(0)} KB';
    }

    final megabytes = kilobytes / 1024;
    if (megabytes < 1024) {
      return '${megabytes.toStringAsFixed(1)} MB';
    }

    final gigabytes = megabytes / 1024;
    return '${gigabytes.toStringAsFixed(2)} GB';
  }

  // ── CSV ──────────────────────────────────────────────────────────────────────
  Uint8List _buildCsvBytes() {
    final buf = StringBuffer();
    buf.writeln('"Payroll Summary Report"');
    buf.writeln('"Cycle","$_selectedCycle"');
    buf.writeln('"Format","$_selectedFormat"');
    buf.writeln('"Generated","${DateTime.now().toString().substring(0, 16)}"');
    buf.writeln('"Total Payout (USD)","${_totalPayout.toStringAsFixed(2)}"');
    buf.writeln();

    if (_includeCharts) {
      buf.writeln('"MONTHLY PAYOUT TREND"');
      buf.writeln('"Month","Payout (USD)"');
      for (final p in _trendData) {
        buf.writeln('"${p.month}","${p.amount.toStringAsFixed(2)}"');
      }
      buf.writeln();
    }

    if (_includeDepartmentSplit) {
      buf.writeln('"DEPARTMENT SPLIT"');
      buf.writeln('"Department","Amount (USD)","Share (%)"');
      for (final d in _departmentSummary) {
        final pct = _totalPayout > 0
            ? (d.amount / _totalPayout * 100).toStringAsFixed(1)
            : '0.0';
        buf.writeln(
            '"${d.department}","${d.amount.toStringAsFixed(2)}","$pct"');
      }
      buf.writeln();
    }

    if (_includeExceptionQueue) {
      buf.writeln('"EXCEPTION QUEUE"');
      buf.writeln('"Employee","Department","Issue","Priority"');
      for (final ex in _exceptionRecords) {
        buf.writeln(
            '"${ex.employee}","${ex.department}","${ex.issue}","${ex.priority}"');
      }
      buf.writeln();
    }

    return Uint8List.fromList(utf8.encode(buf.toString()));
  }

  // ── XLSX ─────────────────────────────────────────────────────────────────────
  Uint8List _buildXlsxBytes() {
    final wb = Excel.createExcel();

    final summary = wb['Summary'];
    summary.appendRow([TextCellValue('Payroll Summary Report')]);
    summary.appendRow([TextCellValue('Cycle'), TextCellValue(_selectedCycle)]);
    summary
        .appendRow([TextCellValue('Format'), TextCellValue(_selectedFormat)]);
    summary.appendRow([
      TextCellValue('Generated'),
      TextCellValue(DateTime.now().toString().substring(0, 16)),
    ]);
    summary.appendRow([]);
    summary.appendRow([
      TextCellValue('Total Payout (USD)'),
      DoubleCellValue(_totalPayout),
    ]);

    if (_includeCharts) {
      final trend = wb['Monthly Trend'];
      trend.appendRow([TextCellValue('Month'), TextCellValue('Payout (USD)')]);
      for (final p in _trendData) {
        trend.appendRow([TextCellValue(p.month), DoubleCellValue(p.amount)]);
      }
    }

    if (_includeDepartmentSplit) {
      final dept = wb['Dept Split'];
      dept.appendRow([
        TextCellValue('Department'),
        TextCellValue('Amount (USD)'),
        TextCellValue('Share (%)'),
      ]);
      for (final d in _departmentSummary) {
        final pct = _totalPayout > 0 ? d.amount / _totalPayout * 100 : 0.0;
        dept.appendRow([
          TextCellValue(d.department),
          DoubleCellValue(d.amount),
          DoubleCellValue(
            double.parse(pct.toStringAsFixed(1)),
          ),
        ]);
      }
    }

    if (_includeExceptionQueue) {
      final exSheet = wb['Exception Queue'];
      exSheet.appendRow([
        TextCellValue('Employee'),
        TextCellValue('Department'),
        TextCellValue('Issue'),
        TextCellValue('Priority'),
      ]);
      for (final e in _exceptionRecords) {
        exSheet.appendRow([
          TextCellValue(e.employee),
          TextCellValue(e.department),
          TextCellValue(e.issue),
          TextCellValue(e.priority),
        ]);
      }
    }

    wb.delete('Sheet1');
    return Uint8List.fromList(wb.encode()!);
  }

  // ── PDF ──────────────────────────────────────────────────────────────────────
  Future<Uint8List> _buildPdfBytes() async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          final sectionStyle = pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
          );
          final labelStyle = pw.TextStyle(fontSize: 9);
          final valueStyle = pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
          );
          final widgets = <pw.Widget>[];

          // ── Header banner ──────────────────────────────────────────
          widgets.add(
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue800,
                borderRadius: const pw.BorderRadius.all(
                  pw.Radius.circular(8),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Payroll Summary Report',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    children: [
                      _pdfChip('Cycle', _selectedCycle),
                      pw.SizedBox(width: 6),
                      _pdfChip('Format', _selectedFormat),
                      pw.SizedBox(width: 6),
                      _pdfChip(
                        'Generated',
                        DateTime.now().toString().substring(0, 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
          widgets.add(pw.SizedBox(height: 14));

          // ── Total payout ───────────────────────────────────────────
          widgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                border: pw.Border.all(color: PdfColors.blue200),
                borderRadius: const pw.BorderRadius.all(
                  pw.Radius.circular(6),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Payout', style: sectionStyle),
                  pw.Text(
                    '\$${_totalPayout.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green800,
                    ),
                  ),
                ],
              ),
            ),
          );
          widgets.add(pw.SizedBox(height: 18));

          // ── Monthly trend (horizontal bar chart) ───────────────────
          if (_includeCharts) {
            final maxTrend = _trendData.map((e) => e.amount).reduce(max);
            widgets.add(
              pw.Text('Monthly Payout Trend', style: sectionStyle),
            );
            widgets.add(pw.SizedBox(height: 8));
            for (final d in _trendData) {
              final ratio = d.amount / maxTrend;
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Row(
                    children: [
                      pw.SizedBox(
                        width: 72,
                        child: pw.Text(
                          d.month,
                          style: labelStyle,
                        ),
                      ),
                      pw.Container(
                        width: ratio * 260,
                        height: 14,
                        color: PdfColors.blue700,
                      ),
                      pw.SizedBox(width: 6),
                      pw.Text(
                        '\$${(d.amount / 1000).toStringAsFixed(1)}K',
                        style: valueStyle,
                      ),
                    ],
                  ),
                ),
              );
            }
            widgets.add(pw.SizedBox(height: 18));
          }

          // ── Department split (horizontal bar chart) ────────────────
          if (_includeDepartmentSplit) {
            widgets.add(
              pw.Text('Department Payout Split', style: sectionStyle),
            );
            widgets.add(pw.SizedBox(height: 8));
            for (final d in _departmentSummary) {
              final pct = _totalPayout > 0 ? d.amount / _totalPayout : 0.0;
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Row(
                    children: [
                      pw.SizedBox(
                        width: 80,
                        child: pw.Text(
                          d.department,
                          style: labelStyle,
                        ),
                      ),
                      pw.Container(
                        width: pct * 230,
                        height: 14,
                        color: PdfColors.teal700,
                      ),
                      pw.SizedBox(width: 6),
                      pw.Text(
                        '\$${d.amount.toStringAsFixed(0)} '
                        '(${(pct * 100).toStringAsFixed(1)}%)',
                        style: valueStyle,
                      ),
                    ],
                  ),
                ),
              );
            }
            widgets.add(pw.SizedBox(height: 18));
          }

          // ── Exception queue (table) ────────────────────────────────
          if (_includeExceptionQueue) {
            widgets.add(
              pw.Text('Exception Queue', style: sectionStyle),
            );
            widgets.add(pw.SizedBox(height: 8));
            widgets.add(
              pw.TableHelper.fromTextArray(
                headers: [
                  'Employee',
                  'Department',
                  'Issue',
                  'Priority',
                ],
                data: _exceptionRecords
                    .map(
                      (e) => [
                        e.employee,
                        e.department,
                        e.issue,
                        e.priority,
                      ],
                    )
                    .toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColors.blueGrey700,
                ),
                cellStyle: pw.TextStyle(fontSize: 9),
                cellPadding: const pw.EdgeInsets.all(4),
              ),
            );
          }

          return widgets;
        },
      ),
    );

    return doc.save();
  }

  pw.Widget _pdfChip(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(999)),
      ),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$label: ',
              style: pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey700,
              ),
            ),
            pw.TextSpan(
              text: value,
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentSummary {
  const _DepartmentSummary(this.department, this.amount);

  final String department;
  final double amount;
}

class _DownloadHistory {
  const _DownloadHistory({
    required this.title,
    required this.cycle,
    required this.format,
    required this.includeCharts,
    required this.includeDepartmentSplit,
    required this.includeExceptionQueue,
    required this.compressed,
    required this.createdBy,
    required this.createdAt,
    required this.size,
  });

  final String title;
  final String cycle;
  final String format;
  final bool includeCharts;
  final bool includeDepartmentSplit;
  final bool includeExceptionQueue;
  final bool compressed;
  final String createdBy;
  final String createdAt;
  final String size;
}

class _TrendPoint {
  const _TrendPoint(this.month, this.amount);

  final String month;
  final double amount;
}

class _ExceptionRecord {
  const _ExceptionRecord(
    this.employee,
    this.department,
    this.issue,
    this.priority,
  );

  final String employee;
  final String department;
  final String issue;
  final String priority;
}
