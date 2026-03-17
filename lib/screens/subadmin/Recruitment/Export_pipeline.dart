import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class RecruitmentPipelineEntry {
  final String id;
  final String name;
  final String role;
  final String stage;
  final String priority;
  final String owner;
  final String source;
  final String location;
  final double fitScore;
  final DateTime appliedDate;
  final DateTime? interviewDate;

  const RecruitmentPipelineEntry({
    required this.id,
    required this.name,
    required this.role,
    required this.stage,
    required this.priority,
    required this.owner,
    required this.source,
    required this.location,
    required this.fitScore,
    required this.appliedDate,
    required this.interviewDate,
  });
}

class SubAdminExportPipelinePage extends StatefulWidget {
  final List<RecruitmentPipelineEntry> entries;

  const SubAdminExportPipelinePage({
    super.key,
    required this.entries,
  });

  @override
  State<SubAdminExportPipelinePage> createState() =>
      _SubAdminExportPipelinePageState();
}

class _SubAdminExportPipelinePageState
    extends State<SubAdminExportPipelinePage> {
  String _selectedFormat = 'PDF';
  bool _isDownloading = false;

  static const List<String> _formats = ['PDF', 'CSV'];

  static const List<String> _headers = [
    'Candidate ID',
    'Name',
    'Role',
    'Stage',
    'Priority',
    'Owner',
    'Source',
    'Location',
    'Fit Score',
    'Applied Date',
    'Interview Date',
  ];

  String get _fileName {
    final date = DateFormat('yyyyMMdd').format(DateTime.now());
    return 'recruitment_pipeline_$date';
  }

  List<List<String>> get _rows {
    return widget.entries.map((e) {
      return [
        e.id,
        e.name,
        e.role,
        e.stage,
        e.priority,
        e.owner,
        e.source,
        e.location,
        e.fitScore.toStringAsFixed(1),
        DateFormat('dd MMM yyyy').format(e.appliedDate),
        e.interviewDate == null
            ? '-'
            : DateFormat('dd MMM yyyy, hh:mm a').format(e.interviewDate!),
      ];
    }).toList();
  }

  Future<void> _download() async {
    setState(() => _isDownloading = true);
    try {
      if (_selectedFormat == 'CSV') {
        await _downloadCsv();
      } else {
        await _downloadPdf();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pipeline exported as $_selectedFormat successfully.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF0F9D58),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _downloadCsv() async {
    final buffer = StringBuffer();
    buffer.writeln('Recruitment Pipeline Export');
    buffer.writeln(
        'Generated,${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}');
    buffer.writeln();
    buffer.writeln(_headers.join(','));

    for (final row in _rows) {
      final escaped =
          row.map((value) => '"${value.replaceAll('"', '""')}"').join(',');
      buffer.writeln(escaped);
    }

    final bytes = Uint8List.fromList(buffer.toString().codeUnits);
    await FileSaver.instance.saveFile(
      name: _fileName,
      bytes: bytes,
      ext: 'csv',
      mimeType: MimeType.csv,
    );
  }

  Future<void> _downloadPdf() async {
    final pdf = pw.Document();

    final byStage = <String, int>{};
    for (final row in widget.entries) {
      byStage[row.stage] = (byStage[row.stage] ?? 0) + 1;
    }

    final stageSummary = byStage.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Recruitment Pipeline Export',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#0F355B'),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Generated: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColor.fromHex('#64748B'),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Divider(color: PdfColor.fromHex('#36B39C'), thickness: 1.2),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style:
                pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('#94A3B8')),
          ),
        ),
        build: (_) => [
          pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: stageSummary
                .map(
                  (item) => pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#F1F5F9'),
                      border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(5)),
                    ),
                    child: pw.Text(
                      '${item.key}: ${item.value}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                )
                .toList(),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColor.fromHex('#E2E8F0'),
              width: 0.5,
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.3),
              1: const pw.FlexColumnWidth(1.7),
              2: const pw.FlexColumnWidth(1.6),
              3: const pw.FlexColumnWidth(1.1),
              4: const pw.FlexColumnWidth(1.1),
              5: const pw.FlexColumnWidth(1.4),
              6: const pw.FlexColumnWidth(1.2),
              7: const pw.FlexColumnWidth(1.2),
              8: const pw.FlexColumnWidth(0.9),
              9: const pw.FlexColumnWidth(1.3),
              10: const pw.FlexColumnWidth(1.7),
            },
            children: [
              pw.TableRow(
                decoration:
                    pw.BoxDecoration(color: PdfColor.fromHex('#0F355B')),
                children: _headers
                    .map(
                      (header) => pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          header,
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 7,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              ..._rows.asMap().entries.map((entry) {
                final shade = entry.key.isEven
                    ? PdfColors.white
                    : PdfColor.fromHex('#F8FAFC');
                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: shade),
                  children: entry.value
                      .map(
                        (value) => pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(value,
                              style: const pw.TextStyle(fontSize: 7)),
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
        ),
        title: const Text(
          'Export Recruitment Pipeline',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F355B), Color(0xFF1A73E8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A73E8).withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    const Icon(Icons.file_download_outlined,
                        color: Colors.white, size: 28),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pipeline Export Ready',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.entries.length} candidates in current export.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _formats.map((format) {
                    final selected = format == _selectedFormat;
                    return ChoiceChip(
                      label: Text(format),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedFormat = format),
                      selectedColor: const Color(0xFFE8F0FE),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? const Color(0xFF1A73E8)
                            : const Color(0xFF334155),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(12),
                  child: DataTable(
                    headingRowColor:
                        WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                    columns: _headers
                        .map((header) => DataColumn(label: Text(header)))
                        .toList(),
                    rows: _rows
                        .map(
                          (row) => DataRow(
                            cells: row
                                .map((value) => DataCell(Text(value)))
                                .toList(),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 18),
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
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.download_rounded, size: 20),
                  label: Text(
                    _isDownloading
                        ? 'Preparing export...'
                        : 'Download $_selectedFormat',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
