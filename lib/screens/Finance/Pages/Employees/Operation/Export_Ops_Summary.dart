import 'package:flutter/material.dart';

class ExportOpsSummaryPage extends StatefulWidget {
  const ExportOpsSummaryPage({super.key});

  @override
  State<ExportOpsSummaryPage> createState() => _ExportOpsSummaryPageState();
}

class _ExportOpsSummaryPageState extends State<ExportOpsSummaryPage> {
  static const List<String> _departments = [
    'All',
    'Operations',
    'Logistics',
    'Warehouse',
    'Procurement',
  ];

  static const List<String> _periods = [
    'This Week',
    'This Month',
    'This Quarter',
    'This Year',
  ];

  final TextEditingController _searchController = TextEditingController();

  String _selectedDepartment = 'All';
  String _selectedPeriod = 'This Month';
  bool _onlyCritical = false;

  final List<_OpsRecord> _records = const [
    _OpsRecord(
      team: 'Ops Core',
      department: 'Operations',
      completedTasks: 182,
      pendingTasks: 18,
      delayRate: 4.2,
      utilization: 92,
      criticalFlag: false,
    ),
    _OpsRecord(
      team: 'Route Desk',
      department: 'Logistics',
      completedTasks: 144,
      pendingTasks: 24,
      delayRate: 8.8,
      utilization: 86,
      criticalFlag: true,
    ),
    _OpsRecord(
      team: 'Stock Control',
      department: 'Warehouse',
      completedTasks: 126,
      pendingTasks: 15,
      delayRate: 5.1,
      utilization: 89,
      criticalFlag: false,
    ),
    _OpsRecord(
      team: 'Vendor Ops',
      department: 'Procurement',
      completedTasks: 97,
      pendingTasks: 21,
      delayRate: 10.3,
      utilization: 81,
      criticalFlag: true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_OpsRecord> get _visibleRecords {
    final q = _searchController.text.trim().toLowerCase();
    return _records.where((row) {
      final byDepartment =
          _selectedDepartment == 'All' || row.department == _selectedDepartment;
      final byCritical = !_onlyCritical || row.criticalFlag;
      final bySearch = q.isEmpty ||
          row.team.toLowerCase().contains(q) ||
          row.department.toLowerCase().contains(q);
      return byDepartment && byCritical && bySearch;
    }).toList();
  }

  int get _totalCompleted =>
      _visibleRecords.fold(0, (sum, item) => sum + item.completedTasks);

  int get _totalPending =>
      _visibleRecords.fold(0, (sum, item) => sum + item.pendingTasks);

  double get _avgDelay {
    if (_visibleRecords.isEmpty) return 0;
    final total =
        _visibleRecords.fold(0.0, (sum, item) => sum + item.delayRate);
    return total / _visibleRecords.length;
  }

  double get _avgUtilization {
    if (_visibleRecords.isEmpty) return 0;
    final total =
        _visibleRecords.fold(0, (sum, item) => sum + item.utilization);
    return total / _visibleRecords.length;
  }

  void _showExportDone(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Operations summary exported as $format for $_selectedPeriod.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = _visibleRecords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Ops Summary'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildFiltersCard(),
            const SizedBox(height: 16),
            _buildKpiGrid(),
            const SizedBox(height: 16),
            _buildPreviewTable(rows),
            const SizedBox(height: 16),
            _buildActionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F355B), Color(0xFF1A73E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operations Reporting Center',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Review current performance metrics and export summary reports for leadership syncs.',
            style: TextStyle(
              color: Color(0xFFE3EEFF),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 820;
              if (compact) {
                return Column(
                  children: [
                    _buildSearchField(),
                    const SizedBox(height: 10),
                    _buildDepartmentDropdown(),
                    const SizedBox(height: 10),
                    _buildPeriodDropdown(),
                    const SizedBox(height: 8),
                    _buildCriticalToggle(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 3, child: _buildSearchField()),
                  const SizedBox(width: 10),
                  Expanded(flex: 2, child: _buildDepartmentDropdown()),
                  const SizedBox(width: 10),
                  Expanded(flex: 2, child: _buildPeriodDropdown()),
                  const SizedBox(width: 10),
                  _buildCriticalToggle(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search by team or department',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDepartment,
      decoration: InputDecoration(
        labelText: 'Department',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      items: _departments
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() => _selectedDepartment = value);
      },
    );
  }

  Widget _buildPeriodDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedPeriod,
      decoration: InputDecoration(
        labelText: 'Period',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      items: _periods
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() => _selectedPeriod = value);
      },
    );
  }

  Widget _buildCriticalToggle() {
    return FilterChip(
      label: const Text('Critical only'),
      selected: _onlyCritical,
      onSelected: (value) => setState(() => _onlyCritical = value),
      avatar: const Icon(Icons.priority_high_rounded, size: 18),
    );
  }

  Widget _buildKpiGrid() {
    final cards = [
      _KpiData('Teams in view', '${_visibleRecords.length}',
          Icons.groups_2_rounded, const Color(0xFF1A73E8)),
      _KpiData('Tasks completed', '$_totalCompleted',
          Icons.check_circle_outline_rounded, const Color(0xFF16A34A)),
      _KpiData('Tasks pending', '$_totalPending',
          Icons.hourglass_bottom_rounded, const Color(0xFFF59E0B)),
      _KpiData('Avg delay rate', '${_avgDelay.toStringAsFixed(1)}%',
          Icons.schedule_rounded, const Color(0xFFDC2626)),
      _KpiData('Avg utilization', '${_avgUtilization.toStringAsFixed(0)}%',
          Icons.speed_rounded, const Color(0xFF7C3AED)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width > 1100
            ? 5
            : width > 860
                ? 3
                : width > 560
                    ? 2
                    : 1;
        final itemWidth = (width - (columns - 1) * 10) / columns;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: cards
              .map((card) => SizedBox(
                    width: itemWidth,
                    child: _KpiCard(data: card),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildPreviewTable(List<_OpsRecord> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export Preview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (rows.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              alignment: Alignment.center,
              child: const Text(
                'No records found for current filters.',
                style: TextStyle(color: Color(0xFF5F6368)),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Team')),
                  DataColumn(label: Text('Department')),
                  DataColumn(label: Text('Completed')),
                  DataColumn(label: Text('Pending')),
                  DataColumn(label: Text('Delay %')),
                  DataColumn(label: Text('Utilization %')),
                  DataColumn(label: Text('Priority')),
                ],
                rows: rows
                    .map(
                      (row) => DataRow(cells: [
                        DataCell(Text(row.team)),
                        DataCell(Text(row.department)),
                        DataCell(Text('${row.completedTasks}')),
                        DataCell(Text('${row.pendingTasks}')),
                        DataCell(Text(row.delayRate.toStringAsFixed(1))),
                        DataCell(Text('${row.utilization}')),
                        DataCell(
                          Chip(
                            label:
                                Text(row.criticalFlag ? 'Critical' : 'Normal'),
                            backgroundColor: row.criticalFlag
                                ? Colors.red.shade50
                                : Colors.green.shade50,
                          ),
                        ),
                      ]),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          ElevatedButton.icon(
            onPressed: () => _showExportDone('PDF'),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Export PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showExportDone('CSV'),
            icon: const Icon(Icons.table_chart_outlined),
            label: const Text('Export CSV'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _showExportDone('print preview'),
            icon: const Icon(Icons.print_outlined),
            label: const Text('Print Preview'),
          ),
        ],
      ),
    );
  }
}

class _OpsRecord {
  final String team;
  final String department;
  final int completedTasks;
  final int pendingTasks;
  final double delayRate;
  final int utilization;
  final bool criticalFlag;

  const _OpsRecord({
    required this.team,
    required this.department,
    required this.completedTasks,
    required this.pendingTasks,
    required this.delayRate,
    required this.utilization,
    required this.criticalFlag,
  });
}

class _KpiData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiData(this.title, this.value, this.icon, this.color);
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;

  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: data.color.withOpacity(0.12),
            child: Icon(data.icon, color: data.color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            data.value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            data.title,
            style: const TextStyle(color: Color(0xFF5F6368)),
          ),
        ],
      ),
    );
  }
}
