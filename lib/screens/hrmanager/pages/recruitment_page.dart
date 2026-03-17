import 'package:flutter/material.dart';

class JobPosting {
  JobPosting({
    required this.title,
    required this.department,
    required this.description,
    required this.status,
    required this.priority,
    required this.openings,
    required this.applicants,
    required this.postedOn,
  });

  String title;
  String department;
  String description;
  String status;
  String priority;
  int openings;
  int applicants;
  DateTime postedOn;
}

class RecruitmentPage extends StatefulWidget {
  final List<JobPosting> seededJobs;

  const RecruitmentPage({Key? key, this.seededJobs = const []})
      : super(key: key);

  @override
  State<RecruitmentPage> createState() => _RecruitmentPageState();
}

class _RecruitmentPageState extends State<RecruitmentPage> {
  final List<JobPosting> _jobs = [
    JobPosting(
      title: 'Senior Flutter Developer',
      department: 'Engineering',
      description:
          'Build and maintain cross-platform features for the finance suite.',
      status: 'Open',
      priority: 'High',
      openings: 2,
      applicants: 19,
      postedOn: DateTime(2026, 3, 2),
    ),
    JobPosting(
      title: 'HR Operations Specialist',
      department: 'Human Resources',
      description:
          'Coordinate onboarding, policy compliance, and employee records.',
      status: 'Interviewing',
      priority: 'Medium',
      openings: 1,
      applicants: 11,
      postedOn: DateTime(2026, 2, 26),
    ),
    JobPosting(
      title: 'Payroll Analyst',
      department: 'Finance',
      description:
          'Own payroll accuracy, reconciliation, and month-end reporting.',
      status: 'Closed',
      priority: 'Low',
      openings: 1,
      applicants: 8,
      postedOn: DateTime(2026, 2, 19),
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  static const List<String> _statusFilters = [
    'All',
    'Open',
    'Interviewing',
    'Closed',
  ];

  @override
  void initState() {
    super.initState();

    // Insert seeded jobs first so cross-page flows can surface newly created roles.
    if (widget.seededJobs.isNotEmpty) {
      for (final seeded in widget.seededJobs.reversed) {
        _jobs.insert(
          0,
          JobPosting(
            title: seeded.title,
            department: seeded.department,
            description: seeded.description,
            status: seeded.status,
            priority: seeded.priority,
            openings: seeded.openings,
            applicants: seeded.applicants,
            postedOn: seeded.postedOn,
          ),
        );
      }
    }

    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<JobPosting> get _visibleJobs {
    final query = _searchController.text.trim().toLowerCase();

    return _jobs.where((job) {
      final matchesStatus =
          _selectedFilter == 'All' || job.status == _selectedFilter;

      final matchesQuery = query.isEmpty ||
          job.title.toLowerCase().contains(query) ||
          job.department.toLowerCase().contains(query) ||
          job.priority.toLowerCase().contains(query);

      return matchesStatus && matchesQuery;
    }).toList();
  }

  int _countByStatus(String status) {
    return _jobs.where((job) => job.status == status).length;
  }

  int get _totalApplicants {
    return _jobs.fold(0, (sum, job) => sum + job.applicants);
  }

  int get _highPriorityOpen {
    return _jobs
        .where((job) => job.status != 'Closed' && job.priority == 'High')
        .length;
  }

  void _showAddJobDialog() {
    final formKey = GlobalKey<FormState>();
    var title = '';
    var department = '';
    var description = '';
    var status = 'Open';
    var priority = 'Medium';
    var openings = 1;
    var applicants = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Job Posting'),
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
                            const InputDecoration(labelText: 'Job Title'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter job title';
                          }
                          return null;
                        },
                        onSaved: (value) => title = value!.trim(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Department'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter department';
                          }
                          return null;
                        },
                        onSaved: (value) => department = value!.trim(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: status,
                              decoration:
                                  const InputDecoration(labelText: 'Status'),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Open',
                                  child: Text('Open'),
                                ),
                                DropdownMenuItem(
                                  value: 'Interviewing',
                                  child: Text('Interviewing'),
                                ),
                                DropdownMenuItem(
                                  value: 'Closed',
                                  child: Text('Closed'),
                                ),
                              ],
                              onChanged: (value) {
                                setDialogState(() {
                                  status = value ?? 'Open';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: priority,
                              decoration:
                                  const InputDecoration(labelText: 'Priority'),
                              items: const [
                                DropdownMenuItem(
                                  value: 'High',
                                  child: Text('High'),
                                ),
                                DropdownMenuItem(
                                  value: 'Medium',
                                  child: Text('Medium'),
                                ),
                                DropdownMenuItem(
                                  value: 'Low',
                                  child: Text('Low'),
                                ),
                              ],
                              onChanged: (value) {
                                setDialogState(() {
                                  priority = value ?? 'Medium';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: '$openings',
                              keyboardType: TextInputType.number,
                              decoration:
                                  const InputDecoration(labelText: 'Openings'),
                              onSaved: (value) {
                                openings = int.tryParse(value ?? '') ?? 1;
                                if (openings < 1) openings = 1;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: '$applicants',
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Applicants',
                              ),
                              onSaved: (value) {
                                applicants = int.tryParse(value ?? '') ?? 0;
                                if (applicants < 0) applicants = 0;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        minLines: 2,
                        maxLines: 3,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        onSaved: (value) => description = value?.trim() ?? '',
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
                    _jobs.insert(
                      0,
                      JobPosting(
                        title: title,
                        department: department,
                        description: description,
                        status: status,
                        priority: priority,
                        openings: openings,
                        applicants: applicants,
                        postedOn: DateTime.now(),
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

  void _removeJob(JobPosting job) {
    setState(() {
      _jobs.remove(job);
    });
  }

  void _updateStatus(JobPosting job, String status) {
    setState(() {
      job.status = status;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Open':
        return Colors.green;
      case 'Interviewing':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  void _showJobDetails(JobPosting job) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(job.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Department: ${job.department}'),
              const SizedBox(height: 8),
              Text('Status: ${job.status}'),
              const SizedBox(height: 8),
              Text('Priority: ${job.priority}'),
              const SizedBox(height: 8),
              Text('Openings: ${job.openings}'),
              const SizedBox(height: 8),
              Text('Applicants: ${job.applicants}'),
              const SizedBox(height: 8),
              Text('Posted On: ${_formatDate(job.postedOn)}'),
              const SizedBox(height: 12),
              Text(job.description.isEmpty
                  ? 'No description.'
                  : job.description),
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

  @override
  Widget build(BuildContext context) {
    final visibleJobs = _visibleJobs;

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
                    'Recruitment Pipeline',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Track open roles, hiring status, and applicant volume.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _showAddJobDialog,
              icon: const Icon(Icons.add),
              label: const Text('New Position'),
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
                  title: 'Total Positions',
                  value: '${_jobs.length}',
                  icon: Icons.badge,
                  color: Colors.indigo,
                ),
                _MetricCard(
                  width: cardWidth,
                  title: 'Open Roles',
                  value: '${_countByStatus('Open')}',
                  icon: Icons.work,
                  color: Colors.green,
                ),
                _MetricCard(
                  width: cardWidth,
                  title: 'Applicants',
                  value: '$_totalApplicants',
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                _MetricCard(
                  width: cardWidth,
                  title: 'High Priority',
                  value: '$_highPriorityOpen',
                  icon: Icons.priority_high,
                  color: Colors.red,
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
                  hintText: 'Search by title, department, or priority',
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
          child: visibleJobs.isEmpty
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
                      Icon(Icons.work_off, size: 42, color: Colors.black38),
                      SizedBox(height: 10),
                      Text(
                        'No positions found',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: visibleJobs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final job = visibleJobs[index];

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
                                  job.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _TagBadge(
                                label: job.priority,
                                color: _priorityColor(job.priority),
                              ),
                              const SizedBox(width: 8),
                              _TagBadge(
                                label: job.status,
                                color: _statusColor(job.status),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            job.department,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            job.description.isEmpty
                                ? 'No description'
                                : job.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _InfoChip(
                                icon: Icons.group,
                                text: 'Applicants ${job.applicants}',
                              ),
                              _InfoChip(
                                icon: Icons.badge_outlined,
                                text: 'Openings ${job.openings}',
                              ),
                              _InfoChip(
                                icon: Icons.event,
                                text: 'Posted ${_formatDate(job.postedOn)}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _showJobDetails(job),
                                icon: const Icon(Icons.visibility_outlined),
                                label: const Text('View'),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'Delete') {
                                    _removeJob(job);
                                    return;
                                  }
                                  _updateStatus(job, value);
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'Open',
                                    child: Text('Mark Open'),
                                  ),
                                  PopupMenuItem(
                                    value: 'Interviewing',
                                    child: Text('Mark Interviewing'),
                                  ),
                                  PopupMenuItem(
                                    value: 'Closed',
                                    child: Text('Mark Closed'),
                                  ),
                                  PopupMenuDivider(),
                                  PopupMenuItem(
                                    value: 'Delete',
                                    child: Text('Delete Position'),
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

class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.label, required this.color});

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
