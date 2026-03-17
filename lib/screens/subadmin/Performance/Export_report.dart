import 'dart:typed_data';

import 'package:excel/excel.dart' hide Border;
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// ── Data passed in from the Performance page ──────────────────────────────────
class PerformanceReportEntry {
  final String manager;
  final String department;
  final int teamSize;
  final int projectsDelivered;
  final double targetAchievement;
  final double qualityScore;
  final double engagementScore;
  final double attritionRisk;
  final double reviewCompletion;
  final double trend;
  final double compositeScore;

  const PerformanceReportEntry({
    required this.manager,
    required this.department,
    required this.teamSize,
    required this.projectsDelivered,
    required this.targetAchievement,
    required this.qualityScore,
    required this.engagementScore,
    required this.attritionRisk,
    required this.reviewCompletion,
    required this.trend,
    required this.compositeScore,
  });
}

class SubAdminExportReportPage extends StatefulWidget {
  final List<PerformanceReportEntry> entries;
  final String period;

  const SubAdminExportReportPage({
    super.key,
    required this.entries,
    required this.period,
  });

  @override
  State<SubAdminExportReportPage> createState() =>
      _SubAdminExportReportPageState();
}

class _SubAdminExportReportPageState extends State<SubAdminExportReportPage> {
  String _selectedFormat = 'PDF';
  bool _isDownloading = false;

  static const List<String> _formats = ['PDF', 'Excel', 'CSV'];

  static const List<String> _headers = [
    'Manager',
    'Department',
    'Team Size',
    'Projects Delivered',
    'Target %',
    'Quality Score',
    'Engagement',
    'Attrition Risk',
    'Review Done %',
    'Trend',
    'Composite Score',
  ];

  List<List<String>> get _rows => widget.entries.map((e) {
        return [
          e.manager,
          e.department,
          '${e.teamSize}',
          '${e.projectsDelivered}',
          '${(e.targetAchievement * 100).toStringAsFixed(0)}%',
          e.qualityScore.toStringAsFixed(0),
          '${e.engagementScore.toStringAsFixed(0)}%',
          '${(e.attritionRisk * 100).toStringAsFixed(0)}%',
          '${(e.reviewCompletion * 100).toStringAsFixed(0)}%',
          e.trend >= 0
              ? '+${(e.trend * 100).toStringAsFixed(0)}%'
              : '${(e.trend * 100).toStringAsFixed(0)}%',
          e.compositeScore.toStringAsFixed(1),
        ];
      }).toList();

  String get _fileName {
    final date = DateFormat('yyyyMMdd').format(DateTime.now());
    return 'performance_report_${widget.period.replaceAll(' ', '_')}_$date';
  }

  // ── Export: CSV ────────────────────────────────────────────────────────────
  Future<void> _exportCsv() async {
    final buffer = StringBuffer();
    buffer.writeln('Performance Report — ${widget.period}');
    buffer.writeln(
        'Generated: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}');
    buffer.writeln();

    buffer.writeln(_headers.join(','));
    for (final row in _rows) {
      buffer.writeln(row.map((cell) => '"$cell"').join(','));
    }

    final bytes = Uint8List.fromList(buffer.toString().codeUnits);
    await FileSaver.instance.saveFile(
      name: _fileName,
      bytes: bytes,
      ext: 'csv',
      mimeType: MimeType.csv,
    );
  }

  // ── Export: Excel ──────────────────────────────────────────────────────────
  Future<void> _exportExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Performance Report'];

    // Title row
    sheet.merge(
      CellIndex.indexByString('A1'),
      CellIndex.indexByString('K1'),
    );
    final titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue('Performance Report — ${widget.period}');
    titleCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 14,
      fontColorHex: ExcelColor.fromHexString('#0F355B'),
    );

    // Generated date
    sheet.merge(
      CellIndex.indexByString('A2'),
      CellIndex.indexByString('K2'),
    );
    sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue(
      'Generated: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}',
    );

    // Header row (row index 3)
    for (var i = 0; i < _headers.length; i++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 3));
      cell.value = TextCellValue(_headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#0F355B'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );
    }

    // Data rows
    for (var r = 0; r < _rows.length; r++) {
      for (var c = 0; c < _rows[r].length; c++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 4))
            .value = TextCellValue(_rows[r][c]);
      }
    }

    // Remove default Sheet1
    excel.delete('Sheet1');

    final fileBytes = excel.encode();
    if (fileBytes == null) return;

    await FileSaver.instance.saveFile(
      name: _fileName,
      bytes: Uint8List.fromList(fileBytes),
      ext: 'xlsx',
      mimeType: MimeType.microsoftExcel,
    );
  }

  // ── Export: PDF ────────────────────────────────────────────────────────────
  Future<void> _exportPdf() async {
    final pdf = pw.Document();

    final headerStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 7,
      color: PdfColors.white,
    );
    final cellStyle = const pw.TextStyle(fontSize: 7);
    final titleStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 14,
      color: PdfColor.fromHex('#0F355B'),
    );
    final subtitleStyle = pw.TextStyle(
      fontSize: 10,
      color: PdfColor.fromHex('#64748B'),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Performance Report', style: titleStyle),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Period: ${widget.period}  ·  Generated: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}',
                      style: subtitleStyle,
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(color: PdfColor.fromHex('#36B39C'), thickness: 1.5),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style:
                pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('#94A3B8')),
          ),
        ),
        build: (pw.Context context) => [
          // Summary stats row
          pw.Row(
            children: [
              _pdfStatBox('Managers', '${widget.entries.length}'),
              pw.SizedBox(width: 8),
              _pdfStatBox(
                'Avg Score',
                widget.entries.isEmpty
                    ? '—'
                    : (widget.entries
                                .map((e) => e.compositeScore)
                                .reduce((a, b) => a + b) /
                            widget.entries.length)
                        .toStringAsFixed(1),
              ),
              pw.SizedBox(width: 8),
              _pdfStatBox(
                'Avg Engagement',
                widget.entries.isEmpty
                    ? '—'
                    : '${(widget.entries.map((e) => e.engagementScore).reduce((a, b) => a + b) / widget.entries.length).toStringAsFixed(0)}%',
              ),
              pw.SizedBox(width: 8),
              _pdfStatBox(
                'Above Target',
                '${widget.entries.where((e) => e.targetAchievement >= 0.9).length}',
              ),
            ],
          ),
          pw.SizedBox(height: 14),
          // Data table
          pw.Table(
            border: pw.TableBorder.all(
                color: PdfColor.fromHex('#E2E8F0'), width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.2),
              1: const pw.FlexColumnWidth(1.6),
              2: const pw.FlexColumnWidth(1.1),
              3: const pw.FlexColumnWidth(1.3),
              4: const pw.FlexColumnWidth(1.2),
              5: const pw.FlexColumnWidth(1.2),
              6: const pw.FlexColumnWidth(1.2),
              7: const pw.FlexColumnWidth(1.3),
              8: const pw.FlexColumnWidth(1.3),
              9: const pw.FlexColumnWidth(1.1),
              10: const pw.FlexColumnWidth(1.4),
            },
            children: [
              // Header
              pw.TableRow(
                decoration:
                    pw.BoxDecoration(color: PdfColor.fromHex('#0F355B')),
                children: _headers
                    .map(
                      (h) => pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 5, vertical: 5),
                        child: pw.Text(h, style: headerStyle),
                      ),
                    )
                    .toList(),
              ),
              // Data rows
              ..._rows.asMap().entries.map((entry) {
                final isEven = entry.key % 2 == 0;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color:
                        isEven ? PdfColors.white : PdfColor.fromHex('#F8FAFC'),
                  ),
                  children: entry.value
                      .map(
                        (cell) => pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 5, vertical: 4),
                          child: pw.Text(cell, style: cellStyle),
                        ),
                      )
                      .toList(),
                );
              }),
            ],
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    await FileSaver.instance.saveFile(
      name: _fileName,
      bytes: Uint8List.fromList(bytes),
      ext: 'pdf',
      mimeType: MimeType.pdf,
    );
  }

  pw.Widget _pdfStatBox(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#F1F5F9'),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: pw.TextStyle(
                    fontSize: 8, color: PdfColor.fromHex('#64748B'))),
            pw.SizedBox(height: 3),
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#0F355B'))),
          ],
        ),
      ),
    );
  }

  // ── Download dispatcher ────────────────────────────────────────────────────
  Future<void> _download() async {
    setState(() => _isDownloading = true);
    try {
      switch (_selectedFormat) {
        case 'CSV':
          await _exportCsv();
          break;
        case 'Excel':
          await _exportExcel();
          break;
        case 'PDF':
        default:
          await _exportPdf();
          break;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report downloaded as $_selectedFormat successfully!'),
          backgroundColor: const Color(0xFF0F9D58),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: ${e.toString()}'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
        title: const Text(
          'Export Performance Report',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _isDownloading ? null : _download,
              icon: _isDownloading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.download_rounded, size: 18),
              label: Text(_isDownloading
                  ? 'Downloading…'
                  : 'Download $_selectedFormat'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF36B39C),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 760;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroBanner(),
                  const SizedBox(height: 16),
                  _buildFormatSelector(),
                  const SizedBox(height: 16),
                  _buildPreviewTable(isCompact),
                  const SizedBox(height: 24),
                  // Bottom download button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _isDownloading ? null : _download,
                      icon: _isDownloading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.download_rounded, size: 20),
                      label: Text(
                        _isDownloading
                            ? 'Preparing download…'
                            : 'Download $_selectedFormat Report',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF36B39C),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Hero banner ────────────────────────────────────────────────────────────
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F355B), Color(0xFF36B39C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF36B39C).withOpacity(0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(Icons.file_download_outlined,
              color: Colors.white, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Performance Report Export',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Period: ${widget.period}  ·  '
                '${widget.entries.length} managers  ·  '
                'Generated ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _heroChip('Managers', '${widget.entries.length}'),
              _heroChip(
                  'Avg Score',
                  widget.entries.isEmpty
                      ? '—'
                      : (widget.entries
                                  .map((e) => e.compositeScore)
                                  .reduce((a, b) => a + b) /
                              widget.entries.length)
                          .toStringAsFixed(1)),
              _heroChip('Above Target',
                  '${widget.entries.where((e) => e.targetAchievement >= 0.9).length}'),
              _heroChip('Format', _selectedFormat),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13)),
        ],
      ),
    );
  }

  // ── Format selector ────────────────────────────────────────────────────────
  Widget _buildFormatSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Export Format',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Select the file format for your report download.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _formats.map((fmt) {
              final selected = fmt == _selectedFormat;
              final icon = fmt == 'PDF'
                  ? Icons.picture_as_pdf_rounded
                  : fmt == 'Excel'
                      ? Icons.table_chart_rounded
                      : Icons.grid_on_rounded;
              final color = fmt == 'PDF'
                  ? const Color(0xFFDC2626)
                  : fmt == 'Excel'
                      ? const Color(0xFF0F9D58)
                      : const Color(0xFF1A73E8);
              return InkWell(
                onTap: () => setState(() => _selectedFormat = fmt),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withOpacity(0.1)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: selected ? color : const Color(0xFFE2E8F0),
                        width: selected ? 1.5 : 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon,
                          color: selected ? color : const Color(0xFF94A3B8),
                          size: 22),
                      const SizedBox(width: 10),
                      Text(
                        fmt,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: selected ? color : const Color(0xFF64748B),
                        ),
                      ),
                      if (selected) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.check_circle_rounded,
                            size: 16, color: color),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Preview table ──────────────────────────────────────────────────────────
  Widget _buildPreviewTable(bool isCompact) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Report Preview',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
                Text(
                  '${widget.entries.length} rows',
                  style: const TextStyle(
                      color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: Color(0xFF0F355B),
              ),
              dataTextStyle: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1E293B),
              ),
              columnSpacing: 20,
              horizontalMargin: 12,
              columns: _headers.map((h) => DataColumn(label: Text(h))).toList(),
              rows: _rows
                  .asMap()
                  .entries
                  .map(
                    (entry) => DataRow(
                      color: WidgetStateProperty.resolveWith(
                        (states) => entry.key % 2 == 0
                            ? Colors.white
                            : const Color(0xFFF8FAFC),
                      ),
                      cells: entry.value
                          .map((cell) => DataCell(Text(cell)))
                          .toList(),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
