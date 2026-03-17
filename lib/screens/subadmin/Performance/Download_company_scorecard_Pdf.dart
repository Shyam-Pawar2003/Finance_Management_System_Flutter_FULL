import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CompanyScorecardEntry {
  final String manager;
  final String department;
  final int teamSize;
  final double targetAchievement;
  final double qualityScore;
  final double engagementScore;
  final double reviewCompletion;
  final double attritionRisk;
  final double trend;
  final double compositeScore;

  const CompanyScorecardEntry({
    required this.manager,
    required this.department,
    required this.teamSize,
    required this.targetAchievement,
    required this.qualityScore,
    required this.engagementScore,
    required this.reviewCompletion,
    required this.attritionRisk,
    required this.trend,
    required this.compositeScore,
  });
}

class SubAdminDownloadCompanyScorecardPdfPage extends StatefulWidget {
  final List<CompanyScorecardEntry> entries;
  final String period;

  const SubAdminDownloadCompanyScorecardPdfPage({
    super.key,
    required this.entries,
    required this.period,
  });

  @override
  State<SubAdminDownloadCompanyScorecardPdfPage> createState() =>
      _SubAdminDownloadCompanyScorecardPdfPageState();
}

class _SubAdminDownloadCompanyScorecardPdfPageState
    extends State<SubAdminDownloadCompanyScorecardPdfPage> {
  bool _isDownloading = false;

  String get _fileName {
    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    return 'company_scorecard_${widget.period.toLowerCase()}_$today';
  }

  Future<void> _downloadPdf() async {
    setState(() => _isDownloading = true);
    try {
      final pdf = pw.Document();

      final averageScore = widget.entries.isEmpty
          ? 0.0
          : widget.entries
                  .map((e) => e.compositeScore)
                  .reduce((a, b) => a + b) /
              widget.entries.length;

      final averageEngagement = widget.entries.isEmpty
          ? 0.0
          : widget.entries
                  .map((e) => e.engagementScore)
                  .reduce((a, b) => a + b) /
              widget.entries.length;

      final highRiskTeams =
          widget.entries.where((e) => e.attritionRisk >= 0.14).length;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(24),
          header: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Company Performance Scorecard',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#0F355B'),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Period: ${widget.period} | Generated: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColor.fromHex('#64748B'),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1.2, color: PdfColor.fromHex('#36B39C')),
              pw.SizedBox(height: 8),
            ],
          ),
          footer: (context) => pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(
                fontSize: 9,
                color: PdfColor.fromHex('#94A3B8'),
              ),
            ),
          ),
          build: (_) => [
            pw.Row(
              children: [
                _pdfMetric('Managers', '${widget.entries.length}'),
                pw.SizedBox(width: 8),
                _pdfMetric('Average Score', averageScore.toStringAsFixed(1)),
                pw.SizedBox(width: 8),
                _pdfMetric(
                  'Average Engagement',
                  '${averageEngagement.toStringAsFixed(0)}%',
                ),
                pw.SizedBox(width: 8),
                _pdfMetric('High Risk Teams', '$highRiskTeams'),
              ],
            ),
            pw.SizedBox(height: 14),
            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColor.fromHex('#E2E8F0'),
                width: 0.6,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.0),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(0.9),
                3: const pw.FlexColumnWidth(1.1),
                4: const pw.FlexColumnWidth(1.0),
                5: const pw.FlexColumnWidth(1.1),
                6: const pw.FlexColumnWidth(1.1),
                7: const pw.FlexColumnWidth(1.1),
                8: const pw.FlexColumnWidth(0.9),
                9: const pw.FlexColumnWidth(1.2),
              },
              children: [
                pw.TableRow(
                  decoration:
                      pw.BoxDecoration(color: PdfColor.fromHex('#0F355B')),
                  children: _pdfHeaders
                      .map(
                        (header) => pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
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
                ...widget.entries.asMap().entries.map((entry) {
                  final row = entry.value;
                  final stripe = entry.key.isEven
                      ? PdfColors.white
                      : PdfColor.fromHex('#F8FAFC');
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: stripe),
                    children: [
                      _pdfCell(row.manager),
                      _pdfCell(row.department),
                      _pdfCell('${row.teamSize}'),
                      _pdfCell(
                          '${(row.targetAchievement * 100).toStringAsFixed(0)}%'),
                      _pdfCell(row.qualityScore.toStringAsFixed(0)),
                      _pdfCell('${row.engagementScore.toStringAsFixed(0)}%'),
                      _pdfCell(
                          '${(row.reviewCompletion * 100).toStringAsFixed(0)}%'),
                      _pdfCell(
                          '${(row.attritionRisk * 100).toStringAsFixed(0)}%'),
                      _pdfCell(
                        row.trend >= 0
                            ? '+${(row.trend * 100).toStringAsFixed(0)}%'
                            : '${(row.trend * 100).toStringAsFixed(0)}%',
                      ),
                      _pdfCell(row.compositeScore.toStringAsFixed(1)),
                    ],
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

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Company scorecard PDF downloaded successfully.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF0F9D58),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to download scorecard: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  pw.Widget _pdfMetric(String label, String value) {
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
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 8,
                color: PdfColor.fromHex('#64748B'),
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#0F355B'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _pdfCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 7),
      ),
    );
  }

  List<String> get _pdfHeaders => const [
        'Manager',
        'Department',
        'Team',
        'Target',
        'Quality',
        'Engagement',
        'Review Done',
        'Attrition',
        'Trend',
        'Score',
      ];

  @override
  Widget build(BuildContext context) {
    final averageScore = widget.entries.isEmpty
        ? 0.0
        : widget.entries.map((e) => e.compositeScore).reduce((a, b) => a + b) /
            widget.entries.length;

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
          'Download Company Scorecard PDF',
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F355B), Color(0xFF36B39C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF36B39C).withOpacity(0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Wrap(
                  spacing: 14,
                  runSpacing: 10,
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Company Scorecard Ready',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Period: ${widget.period} | ${widget.entries.length} managers | Avg score ${averageScore.toStringAsFixed(1)}',
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
                      child: Text(
                        'Scorecard Preview',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(12),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFFF1F5F9),
                        ),
                        columns: const [
                          DataColumn(label: Text('Manager')),
                          DataColumn(label: Text('Dept')),
                          DataColumn(label: Text('Target')),
                          DataColumn(label: Text('Quality')),
                          DataColumn(label: Text('Engagement')),
                          DataColumn(label: Text('Attrition')),
                          DataColumn(label: Text('Score')),
                        ],
                        rows: widget.entries
                            .map(
                              (e) => DataRow(
                                cells: [
                                  DataCell(Text(e.manager)),
                                  DataCell(Text(e.department)),
                                  DataCell(Text(
                                      '${(e.targetAchievement * 100).toStringAsFixed(0)}%')),
                                  DataCell(
                                      Text(e.qualityScore.toStringAsFixed(0))),
                                  DataCell(Text(
                                      '${e.engagementScore.toStringAsFixed(0)}%')),
                                  DataCell(Text(
                                      '${(e.attritionRisk * 100).toStringAsFixed(0)}%')),
                                  DataCell(Text(
                                      e.compositeScore.toStringAsFixed(1))),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _isDownloading ? null : _downloadPdf,
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
                        ? 'Preparing PDF...'
                        : 'Download Scorecard PDF',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF36B39C),
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
