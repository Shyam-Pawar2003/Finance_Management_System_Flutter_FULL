import 'package:flutter/material.dart';

class Report {
  Report({
    required this.title,
    required this.category,
    required this.owner,
    required this.date,
    required this.status,
    required this.summary,
  });

  String title;
  String category;
  String owner;
  DateTime date;
  String status;
  String summary;
}

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final List<Report> _reports = [
    Report(
      title: 'Monthly Attendance Summary',
      category: 'Attendance',
      owner: 'Alice Smith',
      date: DateTime(2026, 3, 10),
      status: 'Published',
      summary: 'Attendance closed at 94% with strong on-time check-in trends.',
    ),
    Report(
      title: 'Hiring Funnel Update',
      category: 'Recruitment',
      owner: 'Bob Johnson',
      date: DateTime(2026, 3, 8),
      status: 'In Review',
      summary: 'Engineering roles gained 12 new applicants this week.',
    ),
    Report(
      title: 'Quarterly Performance Snapshot',
      category: 'Performance',
      owner: 'Carol Davis',
      date: DateTime(2026, 3, 4),
      status: 'Draft',
      summary: 'Two team leads are marked for follow-up coaching plans.',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  static const List<String> _statusFilters = [
    'All',
    'Draft',
    'In Review',
    'Published',
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

  List<Report> get _visibleReports {
    final query = _searchController.text.trim().toLowerCase();

    return _reports.where((report) {
      final matchesStatus =
          _selectedFilter == 'All' || report.status == _selectedFilter;
      final matchesQuery = query.isEmpty ||
          report.title.toLowerCase().contains(query) ||
          report.category.toLowerCase().contains(query) ||
          report.owner.toLowerCase().contains(query) ||
          report.summary.toLowerCase().contains(query);

      return matchesStatus && matchesQuery;
    }).toList();
  }

  int _countByStatus(String status) {
    return _reports.where((report) => report.status == status).length;
  }

  int get _reportsThisMonth {
    final now = DateTime.now();
    return _reports
        .where((report) =>
            report.date.year == now.year && report.date.month == now.month)
        .length;
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

  void _showAddReportDialog() {
    final formKey = GlobalKey<FormState>();
    var title = '';
    var category = 'Attendance';
    var owner = '';
    var status = 'Draft';
    var date = DateTime.now();
    var summary = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Report'),
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
                            const InputDecoration(labelText: 'Report Title'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter report title';
                          }
                          return null;
                        },
                        onSaved: (value) => title = value!.trim(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: category,
                              decoration:
                                  const InputDecoration(labelText: 'Category'),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Attendance',
                                  child: Text('Attendance'),
                                ),
                                DropdownMenuItem(
                                  value: 'Recruitment',
                                  child: Text('Recruitment'),
                                ),
                                DropdownMenuItem(
                                  value: 'Performance',
                                  child: Text('Performance'),
                                ),
                                DropdownMenuItem(
                                  value: 'Compliance',
                                  child: Text('Compliance'),
                                ),
                              ],
                              onChanged: (value) {
                                setDialogState(() {
                                  category = value ?? 'Attendance';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: status,
                              decoration:
                                  const InputDecoration(labelText: 'Status'),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Draft',
                                  child: Text('Draft'),
                                ),
                                DropdownMenuItem(
                                  value: 'In Review',
                                  child: Text('In Review'),
                                ),
                                DropdownMenuItem(
                                  value: 'Published',
                                  child: Text('Published'),
                                ),
                              ],
                              onChanged: (value) {
                                setDialogState(() {
                                  status = value ?? 'Draft';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Owner'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter owner name';
                          }
                          return null;
                        },
                        onSaved: (value) => owner = value!.trim(),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await _pickDate(context, date);
                          if (picked == null) return;
                          setDialogState(() {
                            date = picked;
                          });
                        },
                        icon: const Icon(Icons.event),
                        label: Text('Report Date ${_formatDate(date)}'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(labelText: 'Summary'),
                        onSaved: (value) => summary = value?.trim() ?? '',
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
                    _reports.insert(
                      0,
                      Report(
                        title: title,
                        category: category,
                        owner: owner,
                        date: date,
                        status: status,
                        summary: summary,
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

  void _removeReport(Report report) {
    setState(() {
      _reports.remove(report);
    });
  }

  void _updateStatus(Report report, String status) {
    setState(() {
      report.status = status;
    });
  }

  void _showReportDetails(Report report) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(report.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category: ${report.category}'),
              const SizedBox(height: 8),
              Text('Owner: ${report.owner}'),
              const SizedBox(height: 8),
              Text('Date: ${_formatDate(report.date)}'),
              const SizedBox(height: 8),
              Text('Status: ${report.status}'),
              const SizedBox(height: 12),
              Text(report.summary.isEmpty ? 'No summary.' : report.summary),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Published':
        return Colors.green;
      case 'In Review':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Attendance':
        return Colors.indigo;
      case 'Recruitment':
        return Colors.teal;
      case 'Performance':
        return Colors.deepPurple;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleReports = _visibleReports;

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
                    'HR Reports',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Manage reporting drafts, reviews, and published updates.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _showAddReportDialog,
              icon: const Icon(Icons.add),
              label: const Text('New Report'),
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
                  title: 'Total Reports',
                  value: '${_reports.length}',
                  icon: Icons.description,
                  color: Colors.indigo,
                ),
                _MetricCard(
                  width: cardWidth,
                  title: 'Drafts',
                  value: '${_countByStatus('Draft')}',
                  icon: Icons.edit_document,
                  color: Colors.blueGrey,
                ),
                _MetricCard(
                  width: cardWidth,
                  title: 'In Review',
                  value: '${_countByStatus('In Review')}',
                  icon: Icons.rate_review,
                  color: Colors.orange,
                ),
                _MetricCard(
                  width: cardWidth,
                  title: 'This Month',
                  value: '$_reportsThisMonth',
                  icon: Icons.calendar_month,
                  color: Colors.green,
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
                  hintText: 'Search by report, owner, category, or summary',
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
          child: visibleReports.isEmpty
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
                      Icon(Icons.folder_open, size: 42, color: Colors.black38),
                      SizedBox(height: 10),
                      Text(
                        'No reports found',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: visibleReports.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final report = visibleReports[index];

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  report.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _Badge(
                                label: report.category,
                                color: _categoryColor(report.category),
                              ),
                              const SizedBox(width: 8),
                              _Badge(
                                label: report.status,
                                color: _statusColor(report.status),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            report.summary.isEmpty
                                ? 'No summary.'
                                : report.summary,
                            style: const TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _InfoChip(
                                icon: Icons.person_outline,
                                text: report.owner,
                              ),
                              _InfoChip(
                                icon: Icons.event,
                                text: _formatDate(report.date),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _showReportDetails(report),
                                icon: const Icon(Icons.visibility_outlined),
                                label: const Text('View'),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'Delete') {
                                    _removeReport(report);
                                    return;
                                  }
                                  _updateStatus(report, value);
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'Draft',
                                    child: Text('Mark Draft'),
                                  ),
                                  PopupMenuItem(
                                    value: 'In Review',
                                    child: Text('Mark In Review'),
                                  ),
                                  PopupMenuItem(
                                    value: 'Published',
                                    child: Text('Mark Published'),
                                  ),
                                  PopupMenuDivider(),
                                  PopupMenuItem(
                                    value: 'Delete',
                                    child: Text('Delete Report'),
                                  ),
                                ],
                                child: const Icon(Icons.more_horiz),
                              ),
                            ],
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

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
