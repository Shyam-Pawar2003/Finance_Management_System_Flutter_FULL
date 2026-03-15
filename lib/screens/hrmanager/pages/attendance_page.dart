import 'package:flutter/material.dart';

class AttendanceRecord {
  AttendanceRecord({
    required this.employee,
    required this.date,
    required this.status,
    required this.shift,
    required this.checkIn,
    required this.checkOut,
    this.note = '',
  });

  String employee;
  DateTime date;
  String status;
  String shift;
  String checkIn;
  String checkOut;
  String note;
}

class AttendancePage extends StatefulWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final List<AttendanceRecord> _records = [
    AttendanceRecord(
      employee: 'Alice Smith',
      date: DateTime(2026, 3, 11),
      status: 'Present',
      shift: 'General',
      checkIn: '09:08 AM',
      checkOut: '06:02 PM',
      note: 'On time',
    ),
    AttendanceRecord(
      employee: 'Bob Johnson',
      date: DateTime(2026, 3, 11),
      status: 'Remote',
      shift: 'General',
      checkIn: '09:20 AM',
      checkOut: '05:48 PM',
      note: 'WFH approved',
    ),
    AttendanceRecord(
      employee: 'Carol Davis',
      date: DateTime(2026, 3, 11),
      status: 'Absent',
      shift: 'Morning',
      checkIn: '--',
      checkOut: '--',
      note: 'No update submitted',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  static const List<String> _statusFilters = [
    'All',
    'Present',
    'Remote',
    'Leave',
    'Absent',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AttendanceRecord> get _visibleRecords {
    final query = _searchController.text.trim().toLowerCase();

    return _records.where((record) {
      final matchesStatus =
          _selectedFilter == 'All' || record.status == _selectedFilter;
      final matchesSearch = query.isEmpty ||
          record.employee.toLowerCase().contains(query) ||
          record.shift.toLowerCase().contains(query) ||
          record.status.toLowerCase().contains(query);

      return matchesStatus && matchesSearch;
    }).toList();
  }

  int _countByStatus(String status) {
    return _records.where((record) => record.status == status).length;
  }

  double get _attendanceRate {
    if (_records.isEmpty) return 0;

    final onDuty = _records
        .where(
            (record) => record.status == 'Present' || record.status == 'Remote')
        .length;

    return (onDuty / _records.length) * 100;
  }

  Future<DateTime?> _pickDate(
      BuildContext context, DateTime initialDate) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  void _showAddRecordDialog() {
    final formKey = GlobalKey<FormState>();
    var employeeName = '';
    var selectedDate = DateTime.now();
    var status = 'Present';
    var shift = 'General';
    var checkIn = '09:30 AM';
    var checkOut = '06:00 PM';
    var note = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Attendance Record'),
          content: Form(
            key: formKey,
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Employee Name'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter employee name';
                          }
                          return null;
                        },
                        onSaved: (value) => employeeName = value!.trim(),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await _pickDate(context, selectedDate);
                          if (picked == null) return;
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        },
                        icon: const Icon(Icons.event),
                        label: Text('Date ${_formatDate(selectedDate)}'),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(
                              value: 'Present', child: Text('Present')),
                          DropdownMenuItem(
                              value: 'Remote', child: Text('Remote')),
                          DropdownMenuItem(
                              value: 'Leave', child: Text('Leave')),
                          DropdownMenuItem(
                              value: 'Absent', child: Text('Absent')),
                        ],
                        onChanged: (value) => status = value ?? 'Present',
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: shift,
                        decoration: const InputDecoration(labelText: 'Shift'),
                        items: const [
                          DropdownMenuItem(
                              value: 'General', child: Text('General')),
                          DropdownMenuItem(
                              value: 'Morning', child: Text('Morning')),
                          DropdownMenuItem(
                              value: 'Evening', child: Text('Evening')),
                          DropdownMenuItem(
                              value: 'Night', child: Text('Night')),
                        ],
                        onChanged: (value) => shift = value ?? 'General',
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: checkIn,
                              decoration:
                                  const InputDecoration(labelText: 'Check In'),
                              onSaved: (value) =>
                                  checkIn = value?.trim() ?? '--',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: checkOut,
                              decoration:
                                  const InputDecoration(labelText: 'Check Out'),
                              onSaved: (value) =>
                                  checkOut = value?.trim() ?? '--',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Notes'),
                        minLines: 2,
                        maxLines: 3,
                        onSaved: (value) => note = value?.trim() ?? '',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  formKey.currentState?.save();
                  setState(() {
                    _records.insert(
                      0,
                      AttendanceRecord(
                        employee: employeeName,
                        date: selectedDate,
                        status: status,
                        shift: shift,
                        checkIn: checkIn,
                        checkOut: checkOut,
                        note: note,
                      ),
                    );
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _removeRecord(AttendanceRecord record) {
    setState(() {
      _records.remove(record);
    });
  }

  void _updateStatus(AttendanceRecord record, String status) {
    setState(() {
      record.status = status;
    });
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Remote':
        return Colors.blue;
      case 'Leave':
        return Colors.deepPurple;
      default:
        return Colors.red;
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final visibleRecords = _visibleRecords;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance Tracker',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Monitor daily attendance and status updates across teams.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _showAddRecordDialog,
              icon: const Icon(Icons.add),
              label: const Text('New Record'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth >= 1000
                ? (constraints.maxWidth - 36) / 4
                : constraints.maxWidth >= 700
                    ? (constraints.maxWidth - 12) / 2
                    : constraints.maxWidth;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(
                  width: cardWidth,
                  title: 'Total Logs',
                  value: '${_records.length}',
                  icon: Icons.fact_check,
                  color: Colors.indigo,
                ),
                _MetricCard(
                  width: cardWidth,
                  title: 'Present',
                  value: '${_countByStatus('Present')}',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                _MetricCard(
                  width: cardWidth,
                  title: 'Absent',
                  value: '${_countByStatus('Absent')}',
                  icon: Icons.cancel,
                  color: Colors.red,
                ),
                _MetricCard(
                  width: cardWidth,
                  title: 'Attendance Rate',
                  value: '${_attendanceRate.toStringAsFixed(1)}%',
                  icon: Icons.insights,
                  color: Colors.blue,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by employee, shift, or status',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFF4F6FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _statusFilters.map((status) {
                  return ChoiceChip(
                    label: Text(status),
                    selected: _selectedFilter == status,
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = status;
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: visibleRecords.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_busy, size: 42, color: Colors.black38),
                      SizedBox(height: 10),
                      Text(
                        'No attendance records found',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: visibleRecords.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final record = visibleRecords[index];

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor:
                                _statusColor(record.status).withOpacity(0.14),
                            child: Text(
                              _initials(record.employee),
                              style: TextStyle(
                                color: _statusColor(record.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        record.employee,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    _StatusBadge(
                                      label: record.status,
                                      color: _statusColor(record.status),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _InfoChip(
                                      icon: Icons.calendar_today,
                                      text: _formatDate(record.date),
                                    ),
                                    _InfoChip(
                                      icon: Icons.access_time,
                                      text:
                                          '${record.checkIn} - ${record.checkOut}',
                                    ),
                                    _InfoChip(
                                      icon: Icons.work_outline,
                                      text: record.shift,
                                    ),
                                  ],
                                ),
                                if (record.note.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    record.note,
                                    style:
                                        const TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'Delete') {
                                _removeRecord(record);
                                return;
                              }
                              _updateStatus(record, value);
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'Present',
                                child: Text('Mark Present'),
                              ),
                              PopupMenuItem(
                                value: 'Remote',
                                child: Text('Mark Remote'),
                              ),
                              PopupMenuItem(
                                value: 'Leave',
                                child: Text('Mark Leave'),
                              ),
                              PopupMenuItem(
                                value: 'Absent',
                                child: Text('Mark Absent'),
                              ),
                              PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'Delete',
                                child: Text('Delete Record'),
                              ),
                            ],
                            child: const Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final double width;
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
