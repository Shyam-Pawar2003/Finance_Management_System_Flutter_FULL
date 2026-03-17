import 'package:flutter/material.dart';

class SubAdminStartCalibrationPage extends StatefulWidget {
  const SubAdminStartCalibrationPage({super.key});

  @override
  State<SubAdminStartCalibrationPage> createState() =>
      _SubAdminStartCalibrationPageState();
}

class _SubAdminStartCalibrationPageState
    extends State<SubAdminStartCalibrationPage> {
  // ── Calibration session state ────────────────────────────────────────────
  _CalibrationStep _currentStep = _CalibrationStep.configure;
  bool _isLaunching = false;

  // ── Configuration form state ─────────────────────────────────────────────
  String _selectedCycle = 'Q1 2026';
  String _selectedScope = 'All Departments';
  String _selectedMethod = 'Forced Distribution';
  bool _notifyManagers = true;
  bool _lockScoresAfter = false;
  bool _requireComments = true;
  DateTime _deadline = DateTime(2026, 4, 15);

  static const List<String> _cycles = [
    'Q1 2026',
    'Q2 2026',
    'Q3 2026',
    'Q4 2026',
    'Annual 2025',
  ];
  static const List<String> _scopes = [
    'All Departments',
    'Finance',
    'HR',
    'Operations',
    'Legal',
    'Sales',
    'Support',
  ];
  static const List<String> _methods = [
    'Forced Distribution',
    'Ranking',
    'Rating Scale',
    'MBO (Management by Objectives)',
  ];

  // ── Manager calibration data ─────────────────────────────────────────────
  final List<_CalibrationEntry> _entries = [
    _CalibrationEntry(
      manager: 'A. Kapoor',
      department: 'Finance',
      teamSize: 14,
      currentRating: 'Exceeds',
      proposedRating: 'Exceeds',
      score: 93.0,
      notes: '',
    ),
    _CalibrationEntry(
      manager: 'R. Menon',
      department: 'HR',
      teamSize: 10,
      currentRating: 'Meets',
      proposedRating: 'Meets',
      score: 88.0,
      notes: '',
    ),
    _CalibrationEntry(
      manager: 'P. Sinha',
      department: 'Operations',
      teamSize: 18,
      currentRating: 'Meets',
      proposedRating: 'Meets',
      score: 85.0,
      notes: '',
    ),
    _CalibrationEntry(
      manager: 'S. Bhatt',
      department: 'Legal',
      teamSize: 7,
      currentRating: 'Exceeds',
      proposedRating: 'Outstanding',
      score: 95.0,
      notes: '',
    ),
    _CalibrationEntry(
      manager: 'M. Arora',
      department: 'Sales',
      teamSize: 12,
      currentRating: 'Meets',
      proposedRating: 'Meets',
      score: 89.0,
      notes: '',
    ),
    _CalibrationEntry(
      manager: 'N. Verma',
      department: 'Support',
      teamSize: 16,
      currentRating: 'Meets',
      proposedRating: 'Needs Improvement',
      score: 81.0,
      notes: '',
    ),
  ];

  static const List<String> _ratingOptions = [
    'Outstanding',
    'Exceeds',
    'Meets',
    'Needs Improvement',
    'Unsatisfactory',
  ];

  int get _totalTeamMembers => _entries.fold(0, (sum, e) => sum + e.teamSize);

  int get _updatedCount =>
      _entries.where((e) => e.proposedRating != e.currentRating).length;

  // ── Helpers ───────────────────────────────────────────────────────────────
  Color _ratingColor(String rating) {
    switch (rating) {
      case 'Outstanding':
        return const Color(0xFF7C3AED);
      case 'Exceeds':
        return const Color(0xFF0F9D58);
      case 'Meets':
        return const Color(0xFF1A73E8);
      case 'Needs Improvement':
        return const Color(0xFFF29900);
      default:
        return const Color(0xFFDC2626);
    }
  }

  InputDecoration _inputDecoration({
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF36B39C), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _panel({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // ── Date picker ───────────────────────────────────────────────────────────
  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF36B39C),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  // ── Step actions ──────────────────────────────────────────────────────────
  void _launchCalibration() async {
    setState(() => _isLaunching = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() {
      _isLaunching = false;
      _currentStep = _CalibrationStep.launched;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────
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
          'Start Calibration',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          if (_currentStep == _CalibrationStep.review)
            FilledButton.icon(
              onPressed: _isLaunching ? null : _launchCalibration,
              icon: _isLaunching
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.rocket_launch_rounded, size: 18),
              label: Text(_isLaunching ? 'Launching…' : 'Launch Calibration'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF36B39C),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _currentStep == _CalibrationStep.launched
                  ? _buildSuccessView()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStepIndicator(),
                        const SizedBox(height: 20),
                        _buildHeroBanner(),
                        const SizedBox(height: 20),
                        if (_currentStep == _CalibrationStep.configure)
                          _buildConfigureStep()
                        else
                          _buildReviewStep(constraints.maxWidth),
                        const SizedBox(height: 24),
                        _buildStepNavigation(),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  // ── Step indicator ─────────────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    final steps = ['Configure', 'Review & Launch'];
    return Row(
      children: steps.asMap().entries.map((entry) {
        final idx = entry.key;
        final label = entry.value;
        final isActive = idx == _currentStep.index;
        final isDone = idx < _currentStep.index;
        final color = isActive || isDone
            ? const Color(0xFF36B39C)
            : const Color(0xFFCBD5E1);
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isActive || isDone
                      ? const Color(0xFF36B39C)
                      : const Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded,
                          size: 14, color: Colors.white)
                      : Text(
                          '${idx + 1}',
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF94A3B8),
                  fontSize: 13,
                ),
              ),
              if (idx < steps.length - 1) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Container(height: 2, color: color),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        );
      }).toList(),
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
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(Icons.track_changes_rounded,
              color: Colors.white, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Performance Calibration Session',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Cycle: $_selectedCycle  ·  Scope: $_selectedScope  ·  Method: $_selectedMethod',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: [
              _chip('${_entries.length} Managers'),
              _chip('$_totalTeamMembers Members'),
              _chip(_selectedPeriodLabel),
            ],
          ),
        ],
      ),
    );
  }

  String get _selectedPeriodLabel {
    final days = _deadline.difference(DateTime.now()).inDays;
    if (days < 0) return 'Overdue';
    if (days == 0) return 'Due Today';
    return 'Due in $days days';
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  // ── Configure step ─────────────────────────────────────────────────────────
  Widget _buildConfigureStep() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calibration Configuration',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Set up the parameters for this calibration session.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          const SizedBox(height: 20),
          // Row 1 — Cycle + Scope
          _formRow(
            children: [
              _labeledField(
                label: 'Review Cycle',
                child: DropdownButtonFormField<String>(
                  value: _selectedCycle,
                  decoration: _inputDecoration(),
                  items: _cycles
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedCycle = v);
                  },
                ),
              ),
              _labeledField(
                label: 'Scope',
                child: DropdownButtonFormField<String>(
                  value: _selectedScope,
                  decoration: _inputDecoration(),
                  items: _scopes
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedScope = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Row 2 — Method + Deadline
          _formRow(
            children: [
              _labeledField(
                label: 'Calibration Method',
                child: DropdownButtonFormField<String>(
                  value: _selectedMethod,
                  decoration: _inputDecoration(),
                  items: _methods
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedMethod = v);
                  },
                ),
              ),
              _labeledField(
                label: 'Submission Deadline',
                child: InkWell(
                  onTap: _pickDeadline,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Text(
                          '${_deadline.day} ${_monthName(_deadline.month)} ${_deadline.year}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            'Session Options',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _switchTile(
            title: 'Notify managers via email',
            subtitle:
                'Send an automated notification to all managers when the session launches.',
            value: _notifyManagers,
            onChanged: (v) => setState(() => _notifyManagers = v),
          ),
          _switchTile(
            title: 'Lock scores after deadline',
            subtitle:
                'Prevent managers from editing ratings once the deadline has passed.',
            value: _lockScoresAfter,
            onChanged: (v) => setState(() => _lockScoresAfter = v),
          ),
          _switchTile(
            title: 'Require written comments',
            subtitle:
                'Managers must provide justification for each rating change.',
            value: _requireComments,
            onChanged: (v) => setState(() => _requireComments = v),
          ),
        ],
      ),
    );
  }

  Widget _formRow({required List<Widget> children}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 500) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                children.expand((w) => [w, const SizedBox(height: 14)]).toList()
                  ..removeLast(),
          );
        }
        return Row(
          children: children
              .expand((w) => [Expanded(child: w), const SizedBox(width: 14)])
              .toList()
            ..removeLast(),
        );
      },
    );
  }

  Widget _labeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      subtitle: Text(subtitle,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF36B39C),
    );
  }

  // ── Review step ────────────────────────────────────────────────────────────
  Widget _buildReviewStep(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary cards
        _buildReviewSummary(width),
        const SizedBox(height: 16),
        // Manager calibration table
        _panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Manager Calibration Ratings',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (_updatedCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF29900).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_updatedCount updated',
                        style: const TextStyle(
                          color: Color(0xFFF29900),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Review and adjust proposed ratings before launching.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
              const SizedBox(height: 16),
              ..._entries
                  .asMap()
                  .entries
                  .map((entry) => _calibrationRow(entry.key, entry.value)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSummary(double width) {
    final outstanding =
        _entries.where((e) => e.proposedRating == 'Outstanding').length;
    final exceeds = _entries.where((e) => e.proposedRating == 'Exceeds').length;
    final meets = _entries.where((e) => e.proposedRating == 'Meets').length;
    final needsImprovement =
        _entries.where((e) => e.proposedRating == 'Needs Improvement').length;

    final cols = width >= 800
        ? 4
        : width >= 500
            ? 2
            : 1;

    final summaryItems = [
      _SummaryItem('Outstanding', outstanding, const Color(0xFF7C3AED),
          Icons.star_rounded),
      _SummaryItem(
          'Exceeds', exceeds, const Color(0xFF0F9D58), Icons.thumb_up_rounded),
      _SummaryItem('Meets', meets, const Color(0xFF1A73E8),
          Icons.check_circle_outline_rounded),
      _SummaryItem('Needs Improvement', needsImprovement,
          const Color(0xFFF29900), Icons.flag_rounded),
    ];

    return GridView.builder(
      itemCount: summaryItems.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 82,
      ),
      itemBuilder: (context, index) {
        final item = summaryItems[index];
        return _panel(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${item.count}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: item.color,
                    ),
                  ),
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _calibrationRow(int index, _CalibrationEntry entry) {
    final changed = entry.proposedRating != entry.currentRating;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: changed ? const Color(0xFFFFF8E1) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: changed
              ? const Color(0xFFF29900).withOpacity(0.4)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF36B39C).withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _initials(entry.manager),
                    style: const TextStyle(
                      color: Color(0xFF36B39C),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.manager,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    Text(
                      '${entry.department} · ${entry.teamSize} members · Score: ${entry.score.toStringAsFixed(1)}',
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (changed)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF29900).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Modified',
                    style: TextStyle(
                      color: Color(0xFFF29900),
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 460;
              final ratingRow = Row(
                children: [
                  // Current rating badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current',
                        style:
                            TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _ratingColor(entry.currentRating)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: _ratingColor(entry.currentRating)
                                  .withOpacity(0.3)),
                        ),
                        child: Text(
                          entry.currentRating,
                          style: TextStyle(
                            color: _ratingColor(entry.currentRating),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 10),
                  // Proposed rating dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Proposed',
                        style:
                            TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 3),
                      DropdownButtonHideUnderline(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: _ratingColor(entry.proposedRating)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: _ratingColor(entry.proposedRating)
                                    .withOpacity(0.4)),
                          ),
                          child: DropdownButton<String>(
                            value: entry.proposedRating,
                            isDense: true,
                            style: TextStyle(
                              color: _ratingColor(entry.proposedRating),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                            icon: Icon(
                              Icons.arrow_drop_down_rounded,
                              color: _ratingColor(entry.proposedRating),
                              size: 18,
                            ),
                            items: _ratingOptions
                                .map((r) => DropdownMenuItem(
                                      value: r,
                                      child: Text(r),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _entries[index] = _CalibrationEntry(
                                  manager: entry.manager,
                                  department: entry.department,
                                  teamSize: entry.teamSize,
                                  currentRating: entry.currentRating,
                                  proposedRating: value,
                                  score: entry.score,
                                  notes: entry.notes,
                                );
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );

              final notesField = isNarrow
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: _notesField(index, entry),
                    )
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: _notesField(index, entry),
                      ),
                    );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [ratingRow, notesField],
                );
              }
              return Row(
                children: [ratingRow, notesField],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _notesField(int index, _CalibrationEntry entry) {
    return TextFormField(
      initialValue: entry.notes,
      decoration: _inputDecoration(hintText: 'Add justification comments…'),
      maxLines: 1,
      style: const TextStyle(fontSize: 12),
      onChanged: (value) {
        _entries[index] = _CalibrationEntry(
          manager: entry.manager,
          department: entry.department,
          teamSize: entry.teamSize,
          currentRating: entry.currentRating,
          proposedRating: entry.proposedRating,
          score: entry.score,
          notes: value,
        );
      },
    );
  }

  // ── Navigation row ─────────────────────────────────────────────────────────
  Widget _buildStepNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep == _CalibrationStep.review)
          OutlinedButton.icon(
            onPressed: () =>
                setState(() => _currentStep = _CalibrationStep.configure),
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text('Back to Configure'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1E293B),
              side: const BorderSide(color: Color(0xFFD5DEE9)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          )
        else
          const SizedBox.shrink(),
        if (_currentStep == _CalibrationStep.configure)
          FilledButton.icon(
            onPressed: () =>
                setState(() => _currentStep = _CalibrationStep.review),
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: const Text('Continue to Review'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF36B39C),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          )
        else
          FilledButton.icon(
            onPressed: _isLaunching ? null : _launchCalibration,
            icon: _isLaunching
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.rocket_launch_rounded, size: 16),
            label: Text(_isLaunching ? 'Launching…' : 'Launch Calibration'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF36B39C),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
      ],
    );
  }

  // ── Success view ───────────────────────────────────────────────────────────
  Widget _buildSuccessView() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: _panel(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF36B39C).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF36B39C),
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Calibration Launched!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'The "$_selectedCycle" calibration session for "$_selectedScope" has been started using the $_selectedMethod method.',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildSuccessDetail(
                  Icons.group_rounded, '${_entries.length} managers enrolled'),
              const SizedBox(height: 8),
              _buildSuccessDetail(Icons.calendar_today_rounded,
                  'Deadline: ${_deadline.day} ${_monthName(_deadline.month)} ${_deadline.year}'),
              const SizedBox(height: 8),
              if (_notifyManagers)
                _buildSuccessDetail(Icons.email_rounded,
                    'Email notifications sent to managers'),
              if (_lockScoresAfter) ...[
                const SizedBox(height: 8),
                _buildSuccessDetail(
                    Icons.lock_rounded, 'Scores locked after deadline'),
              ],
              if (_requireComments) ...[
                const SizedBox(height: 8),
                _buildSuccessDetail(Icons.comment_rounded,
                    'Written comments required from managers'),
              ],
              const SizedBox(height: 24),
              if (_updatedCount > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF29900).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFFF29900).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: Color(0xFFF29900), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$_updatedCount proposed rating change${_updatedCount == 1 ? '' : 's'} will be sent for manager review.',
                          style: const TextStyle(
                            color: Color(0xFFF29900),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Return to Performance'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF36B39C),
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessDetail(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF36B39C)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  // ── Utilities ─────────────────────────────────────────────────────────────
  String _initials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _monthName(int month) {
    const months = [
      '',
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
    return months[month];
  }
}

// ── Step enum ────────────────────────────────────────────────────────────────
enum _CalibrationStep { configure, review, launched }

// ── Data models ───────────────────────────────────────────────────────────────
class _CalibrationEntry {
  final String manager;
  final String department;
  final int teamSize;
  final String currentRating;
  final String proposedRating;
  final double score;
  final String notes;

  const _CalibrationEntry({
    required this.manager,
    required this.department,
    required this.teamSize,
    required this.currentRating,
    required this.proposedRating,
    required this.score,
    required this.notes,
  });
}

class _SummaryItem {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _SummaryItem(this.label, this.count, this.color, this.icon);
}
