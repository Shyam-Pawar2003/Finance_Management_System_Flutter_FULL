import 'package:flutter/material.dart';
import '../../user_dashboard.dart';

class SubmitReportPage extends StatefulWidget {
  const SubmitReportPage({super.key});

  @override
  State<SubmitReportPage> createState() => _SubmitReportPageState();
}

class _SubmitReportPageState extends State<SubmitReportPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _insightsController = TextEditingController();

  String _selectedCategory = _categories.first;
  String _selectedFormat = _formats.first;
  String _selectedPriority = _priorities.first;

  DateTime? _periodStart;
  DateTime? _periodEnd;

  bool _includeCharts = true;
  bool _confidential = false;
  bool _notifyStakeholders = true;

  static const List<String> _categories = [
    'Finance',
    'Operations',
    'Sales',
    'Compliance',
    'HR',
  ];

  static const List<String> _formats = [
    'PDF',
    'Spreadsheet',
    'Slide Deck',
    'Memo',
  ];

  static const List<String> _priorities = [
    'Standard',
    'High',
    'Urgent',
  ];

  static const List<_ChecklistItem> _checklist = [
    _ChecklistItem(label: 'Executive summary added', done: true),
    _ChecklistItem(label: 'Data source verified', done: true),
    _ChecklistItem(label: 'Variance explained', done: false),
    _ChecklistItem(label: 'Reviewer assigned', done: false),
  ];

  static const List<_RecentSubmission> _recentSubmissions = [
    _RecentSubmission(
      title: 'Q1 Payroll Overview',
      submittedOn: '2026-03-09',
      status: 'Approved',
      reviewer: 'Finance Lead',
    ),
    _RecentSubmission(
      title: 'Weekly Expense Digest',
      submittedOn: '2026-03-07',
      status: 'In Review',
      reviewer: 'Ops Manager',
    ),
    _RecentSubmission(
      title: 'Vendor Settlement Note',
      submittedOn: '2026-03-03',
      status: 'Needs Update',
      reviewer: 'Compliance Desk',
    ),
  ];

  Future<void> _handleBackNavigation() async {
    final didPop = await Navigator.maybePop(context);
    if (!didPop && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserDashboard()),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _insightsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial =
        isStart ? (_periodStart ?? now) : (_periodEnd ?? _periodStart ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      if (isStart) {
        _periodStart = picked;
        if (_periodEnd != null && _periodEnd!.isBefore(picked)) {
          _periodEnd = picked;
        }
      } else {
        _periodEnd = picked;
      }
    });
  }

  String _dateLabel(DateTime? value) {
    if (value == null) {
      return 'Select date';
    }
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _periodLabel() {
    if (_periodStart == null || _periodEnd == null) {
      return 'Not selected';
    }
    return '${_dateLabel(_periodStart)} to ${_dateLabel(_periodEnd)}';
  }

  int _completionScore() {
    var score = 0;
    if (_titleController.text.trim().isNotEmpty) score += 20;
    if (_summaryController.text.trim().length >= 20) score += 20;
    if (_insightsController.text.trim().isNotEmpty) score += 15;
    if (_periodStart != null && _periodEnd != null) score += 20;
    if (_includeCharts) score += 10;
    if (_notifyStakeholders) score += 10;
    if (_selectedPriority == 'Urgent') score += 5;
    return score.clamp(0, 100);
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report draft saved.')),
    );
  }

  void _submitReport() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    if (_periodStart == null || _periodEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select report period dates.')),
      );
      return;
    }

    if (_periodEnd!.isBefore(_periodStart!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Period end cannot be before start date.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Report "${_titleController.text.trim()}" submitted successfully.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1040;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7FB),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isDesktop ? 24 : 16,
                16,
                isDesktop ? 24 : 16,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildHeroCard(),
                  const SizedBox(height: 16),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildFormPanel()),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: _buildSidePanel()),
                      ],
                    )
                  else ...[
                    _buildFormPanel(),
                    const SizedBox(height: 16),
                    _buildSidePanel(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: _handleBackNavigation,
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
        const SizedBox(width: 4),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submit Report',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4),
              Text(
                'Prepare and submit structured reports with review-ready details.',
                style: TextStyle(color: Color(0xFF5F6368)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    final score = _completionScore();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F355B), Color(0xFF1A73E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withOpacity(0.24),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report Composer',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Ship clean reports with confidence.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _heroBadge('Category', _selectedCategory),
              _heroBadge('Priority', _selectedPriority),
              _heroBadge('Completion', '$score%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroBadge(String label, String value) {
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
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormPanel() {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration('Report Title'),
              validator: (value) {
                if (value == null || value.trim().length < 5) {
                  return 'Please enter a report title.';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: _inputDecoration('Category'),
                    items: _categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFormat,
                    decoration: _inputDecoration('Format'),
                    items: _formats
                        .map(
                          (format) => DropdownMenuItem(
                            value: format,
                            child: Text(format),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedFormat = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _dateInputCard(
                    label: 'Period Start',
                    value: _dateLabel(_periodStart),
                    onTap: () => _pickDate(isStart: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _dateInputCard(
                    label: 'Period End',
                    value: _dateLabel(_periodEnd),
                    onTap: () => _pickDate(isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Priority',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _priorities
                  .map(
                    (priority) => ChoiceChip(
                      label: Text(priority),
                      selected: _selectedPriority == priority,
                      onSelected: (_) {
                        setState(() {
                          _selectedPriority = priority;
                        });
                      },
                      selectedColor: const Color(0xFF1A73E8),
                      labelStyle: TextStyle(
                        color: _selectedPriority == priority
                            ? Colors.white
                            : const Color(0xFF334155),
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: _selectedPriority == priority
                            ? const Color(0xFF1A73E8)
                            : const Color(0xFFD5DEE9),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Include charts and visuals',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle:
                  const Text('Auto-generate chart placeholders in output'),
              value: _includeCharts,
              onChanged: (value) {
                setState(() {
                  _includeCharts = value;
                });
              },
              activeColor: const Color(0xFF1A73E8),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Mark report as confidential',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                  'Restrict report visibility to selected reviewers'),
              value: _confidential,
              onChanged: (value) {
                setState(() {
                  _confidential = value;
                });
              },
              activeColor: const Color(0xFF1A73E8),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Notify stakeholders on submit',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle:
                  const Text('Send immediate update to managers and reviewers'),
              value: _notifyStakeholders,
              onChanged: (value) {
                setState(() {
                  _notifyStakeholders = value;
                });
              },
              activeColor: const Color(0xFF1A73E8),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _summaryController,
              maxLines: 4,
              decoration: _inputDecoration('Executive Summary'),
              validator: (value) {
                if (value == null || value.trim().length < 20) {
                  return 'Please enter at least 20 characters.';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _insightsController,
              maxLines: 4,
              decoration: _inputDecoration('Key Insights / Risks'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please mention at least one key insight.';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saveDraft,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save Draft'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(color: Color(0xFFD5DEE9)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _submitReport,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Submit Report'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      backgroundColor: const Color(0xFF1A73E8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateInputCard({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD5DEE9)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidePanel() {
    final completedChecks = _checklist.where((item) => item.done).length;

    return Column(
      children: [
        _panel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Submission Snapshot',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              _statTile('Checklist completion',
                  '$completedChecks/${_checklist.length}'),
              const SizedBox(height: 8),
              _statTile('Report period', _periodLabel()),
              const SizedBox(height: 8),
              _statTile('Format', _selectedFormat),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _panel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pre-Submission Checklist',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ..._checklist.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.done
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 18,
                        color: item.done
                            ? const Color(0xFF0F9D58)
                            : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.label,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _panel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Submissions',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ..._recentSubmissions.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
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
                              item.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          _statusChip(item.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Submitted ${item.submittedOn} | Reviewer: ${item.reviewer}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statTile(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return const Color(0xFF0F9D58);
      case 'In Review':
        return const Color(0xFF1A73E8);
      case 'Needs Update':
        return const Color(0xFFF29900);
      default:
        return const Color(0xFF64748B);
    }
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 1.4),
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

class _ChecklistItem {
  const _ChecklistItem({required this.label, required this.done});

  final String label;
  final bool done;
}

class _RecentSubmission {
  const _RecentSubmission({
    required this.title,
    required this.submittedOn,
    required this.status,
    required this.reviewer,
  });

  final String title;
  final String submittedOn;
  final String status;
  final String reviewer;
}
