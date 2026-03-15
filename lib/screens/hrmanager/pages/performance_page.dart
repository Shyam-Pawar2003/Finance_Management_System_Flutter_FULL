import 'package:flutter/material.dart';

class PerformanceRecord {
  PerformanceRecord({
    required this.employee,
    required this.role,
    required this.date,
    required this.rating,
    required this.comments,
    required this.goals,
    required this.status,
  });

  String employee;
  String role;
  DateTime date;
  int rating;
  String comments;
  String goals;
  String status;
}

class PerformancePage extends StatefulWidget {
  const PerformancePage({Key? key}) : super(key: key);

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  final List<PerformanceRecord> _records = [
    PerformanceRecord(
      employee: 'Alice Smith',
      role: 'HR Manager',
      date: DateTime(2026, 3, 9),
      rating: 5,
      comments: 'Excellent leadership and policy execution.',
      goals: 'Mentor two junior HR associates.',
      status: 'Completed',
    ),
    PerformanceRecord(
      employee: 'Bob Johnson',
      role: 'Recruiter',
      date: DateTime(2026, 3, 7),
      rating: 4,
      comments: 'Strong candidate pipeline this month.',
      goals: 'Reduce time-to-hire by 10%.',
      status: 'In Progress',
    ),
    PerformanceRecord(
      employee: 'Carol Davis',
      role: 'Payroll Specialist',
      date: DateTime(2026, 3, 5),
      rating: 3,
      comments: 'Needs improvement in monthly close timelines.',
      goals: 'Improve report submission consistency.',
      status: 'Needs Follow-up',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  static const List<String> _statusFilters = [
    'All',
    'Completed',
    'In Progress',
    'Needs Follow-up',
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

  List<PerformanceRecord> get _visibleRecords {
    final query = _searchController.text.trim().toLowerCase();

    return _records.where((record) {
      final matchesStatus =
          _selectedFilter == 'All' || record.status == _selectedFilter;

      final matchesQuery = query.isEmpty ||
          record.employee.toLowerCase().contains(query) ||
          record.role.toLowerCase().contains(query) ||
          record.comments.toLowerCase().contains(query);

      return matchesStatus && matchesQuery;
    }).toList();
  }

  int _countByStatus(String status) {
    return _records.where((record) => record.status == status).length;
  }

  double get _averageRating {
    if (_records.isEmpty) return 0;
    final total = _records.fold<int>(0, (sum, record) => sum + record.rating);
    return total / _records.length;
  }

  int get _topPerformerCount {
    return _records.where((record) => record.rating >= 4).length;
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

  void _showAddReviewDialog() {
    final formKey = GlobalKey<FormState>();
    var employeeName = '';
    var role = '';
    var selectedDate = DateTime.now();
    var rating = 4;
    var comments = '';
    var goals = '';
    var status = 'In Progress';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Performance Review'),
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
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Role'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter role';
                          }
                          return null;
                        },
                        onSaved: (value) => role = value!.trim(),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await _pickDate(context, selectedDate);
                          if (picked == null) return;
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        },
                        icon: const Icon(Icons.event),
                        label: Text('Review Date ${_formatDate(selectedDate)}'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: rating,
                        decoration: const InputDecoration(labelText: 'Rating'),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1 - Poor')),
                          DropdownMenuItem(value: 2, child: Text('2 - Fair')),
                          DropdownMenuItem(value: 3, child: Text('3 - Good')),
                          DropdownMenuItem(
                              value: 4, child: Text('4 - Very Good')),
                          DropdownMenuItem(
                              value: 5, child: Text('5 - Excellent')),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            rating = value ?? 4;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: status,
                        decoration:
                            const InputDecoration(labelText: 'Review Status'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Completed',
                            child: Text('Completed'),
                          ),
                          DropdownMenuItem(
                            value: 'In Progress',
                            child: Text('In Progress'),
                          ),
                          DropdownMenuItem(
                            value: 'Needs Follow-up',
                            child: Text('Needs Follow-up'),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            status = value ?? 'In Progress';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        minLines: 2,
                        maxLines: 3,
                        decoration:
                            const InputDecoration(labelText: 'Review Notes'),
                        onSaved: (value) => comments = value?.trim() ?? '',
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        minLines: 2,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Goals / Action Plan',
                        ),
                        onSaved: (value) => goals = value?.trim() ?? '',
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
                      PerformanceRecord(
                        employee: employeeName,
                        role: role,
                        date: selectedDate,
                        rating: rating,
                        comments: comments,
                        goals: goals,
                        status: status,
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

  void _removeReview(PerformanceRecord record) {
    setState(() {
      _records.remove(record);
    });
  }

  void _updateStatus(PerformanceRecord record, String status) {
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
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  Widget _ratingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < rating;
        return Icon(
          filled ? Icons.star : Icons.star_border,
          size: 16,
          color: filled ? Colors.amber.shade700 : Colors.grey,
        );
      }),
    );
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
                    'Performance Reviews',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Capture performance feedback and follow-up actions.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _showAddReviewDialog,
              icon: const Icon(Icons.add),
              label: const Text('New Review'),
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
                  title: 'Total Reviews',
                  value: '${_records.length}',
                  icon: Icons.assignment,
                  color: Colors.indigo,
                ),
                _MetricCard(
                  width: cardWidth,
                  title: 'Average Rating',
                  value: _averageRating.toStringAsFixed(1),
                  icon: Icons.star,
                  color: Colors.amber,
                ),
                _MetricCard(
                  width: cardWidth,
                  title: 'Top Performers',
                  value: '$_topPerformerCount',
                  icon: Icons.workspace_premium,
                  color: Colors.green,
                ),
                _MetricCard(
                  width: cardWidth,
                  title: 'Follow-up Needed',
                  value: '${_countByStatus('Needs Follow-up')}',
                  icon: Icons.assignment_late,
                  color: Colors.orange,
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
                  hintText: 'Search by employee, role, or notes',
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
                      Icon(Icons.assignment_late,
                          size: 42, color: Colors.black38),
                      SizedBox(height: 10),
                      Text(
                        'No performance records found',
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
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            record.employee,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            record.role,
                                            style: const TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _StatusBadge(
                                      label: record.status,
                                      color: _statusColor(record.status),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _ratingStars(record.rating),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${record.rating}/5',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _InfoChip(
                                      icon: Icons.event,
                                      text: _formatDate(record.date),
                                    ),
                                    const _InfoChip(
                                      icon: Icons.flag,
                                      text: 'Goals tracked',
                                    ),
                                  ],
                                ),
                                if (record.comments.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    record.comments,
                                    style:
                                        const TextStyle(color: Colors.black87),
                                  ),
                                ],
                                if (record.goals.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'Action: ${record.goals}',
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
                                _removeReview(record);
                                return;
                              }
                              _updateStatus(record, value);
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'Completed',
                                child: Text('Mark Completed'),
                              ),
                              PopupMenuItem(
                                value: 'In Progress',
                                child: Text('Mark In Progress'),
                              ),
                              PopupMenuItem(
                                value: 'Needs Follow-up',
                                child: Text('Mark Needs Follow-up'),
                              ),
                              PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'Delete',
                                child: Text('Delete Review'),
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
