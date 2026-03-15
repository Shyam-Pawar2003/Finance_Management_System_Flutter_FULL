import 'package:flutter/material.dart';

class LeaveRequest {
  LeaveRequest({
    required this.employee,
    required this.from,
    required this.to,
    required this.type,
    required this.reason,
    this.status = 'Pending',
  });

  String employee;
  DateTime from;
  DateTime to;
  String type;
  String reason;
  String status;

  int get days => to.difference(from).inDays + 1;
}

class LeavePage extends StatefulWidget {
  const LeavePage({Key? key}) : super(key: key);

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  final List<LeaveRequest> _requests = [
    LeaveRequest(
      employee: 'Alice Smith',
      from: DateTime(2026, 3, 10),
      to: DateTime(2026, 3, 12),
      type: 'Paid',
      reason: 'Family event',
      status: 'Approved',
    ),
    LeaveRequest(
      employee: 'Bob Johnson',
      from: DateTime(2026, 3, 13),
      to: DateTime(2026, 3, 14),
      type: 'Sick',
      reason: 'Medical recovery',
      status: 'Pending',
    ),
    LeaveRequest(
      employee: 'Carol Davis',
      from: DateTime(2026, 3, 8),
      to: DateTime(2026, 3, 9),
      type: 'Unpaid',
      reason: 'Personal work',
      status: 'Rejected',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';

  static const List<String> _statusFilters = [
    'All',
    'Pending',
    'Approved',
    'Rejected',
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

  List<LeaveRequest> get _visibleRequests {
    final query = _searchController.text.trim().toLowerCase();

    return _requests.where((request) {
      final matchesStatus =
          _selectedStatus == 'All' || request.status == _selectedStatus;

      final matchesQuery = query.isEmpty ||
          request.employee.toLowerCase().contains(query) ||
          request.type.toLowerCase().contains(query) ||
          request.reason.toLowerCase().contains(query);

      return matchesStatus && matchesQuery;
    }).toList();
  }

  int _countByStatus(String status) {
    return _requests.where((request) => request.status == status).length;
  }

  int get _activeTodayCount {
    final today = DateTime.now();
    final current = DateTime(today.year, today.month, today.day);

    return _requests.where((request) {
      final from =
          DateTime(request.from.year, request.from.month, request.from.day);
      final to = DateTime(request.to.year, request.to.month, request.to.day);

      return request.status == 'Approved' &&
          (current.isAtSameMomentAs(from) ||
              current.isAtSameMomentAs(to) ||
              (current.isAfter(from) && current.isBefore(to)));
    }).length;
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

  void _showAddRequestDialog() {
    final formKey = GlobalKey<FormState>();
    var employeeName = '';
    var leaveType = 'Paid';
    var leaveStatus = 'Pending';
    var fromDate = DateTime.now();
    var toDate = DateTime.now();
    var reason = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Leave Request'),
          content: Form(
            key: formKey,
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Employee Name',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter employee name';
                          }
                          return null;
                        },
                        onSaved: (value) => employeeName = value!.trim(),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final picked =
                                    await _pickDate(context, fromDate);
                                if (picked == null) return;
                                setDialogState(() {
                                  fromDate = picked;
                                  if (toDate.isBefore(fromDate)) {
                                    toDate = fromDate;
                                  }
                                });
                              },
                              icon: const Icon(Icons.event),
                              label: Text('From ${_formatDate(fromDate)}'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final picked = await _pickDate(context, toDate);
                                if (picked == null) return;
                                setDialogState(() {
                                  toDate = picked;
                                  if (toDate.isBefore(fromDate)) {
                                    fromDate = toDate;
                                  }
                                });
                              },
                              icon: const Icon(Icons.event_available),
                              label: Text('To ${_formatDate(toDate)}'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: leaveType,
                        decoration:
                            const InputDecoration(labelText: 'Leave Type'),
                        items: const [
                          DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                          DropdownMenuItem(
                              value: 'Unpaid', child: Text('Unpaid')),
                          DropdownMenuItem(value: 'Sick', child: Text('Sick')),
                          DropdownMenuItem(
                              value: 'Casual', child: Text('Casual')),
                        ],
                        onChanged: (value) => leaveType = value ?? 'Paid',
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: leaveStatus,
                        decoration:
                            const InputDecoration(labelText: 'Initial Status'),
                        items: const [
                          DropdownMenuItem(
                              value: 'Pending', child: Text('Pending')),
                          DropdownMenuItem(
                              value: 'Approved', child: Text('Approved')),
                          DropdownMenuItem(
                              value: 'Rejected', child: Text('Rejected')),
                        ],
                        onChanged: (value) => leaveStatus = value ?? 'Pending',
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Reason'),
                        minLines: 2,
                        maxLines: 3,
                        onSaved: (value) => reason = value?.trim() ?? '',
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
                    _requests.add(LeaveRequest(
                      employee: employeeName,
                      from: fromDate,
                      to: toDate,
                      type: leaveType,
                      reason: reason,
                      status: leaveStatus,
                    ));
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

  void _removeRequest(LeaveRequest request) {
    setState(() {
      _requests.remove(request);
    });
  }

  void _updateStatus(LeaveRequest request, String status) {
    setState(() {
      request.status = status;
    });
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Sick':
        return Colors.red;
      case 'Unpaid':
        return Colors.deepPurple;
      case 'Casual':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  String _shortName(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final visibleRequests = _visibleRequests;

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
                    'Leave Management',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Track leave requests, approvals, and active absences.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _showAddRequestDialog,
              icon: const Icon(Icons.add),
              label: const Text('New Request'),
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
                _SummaryCard(
                  width: cardWidth,
                  title: 'Total Requests',
                  value: '${_requests.length}',
                  color: Colors.indigo,
                  icon: Icons.list_alt,
                ),
                _SummaryCard(
                  width: cardWidth,
                  title: 'Pending Approval',
                  value: '${_countByStatus('Pending')}',
                  color: Colors.orange,
                  icon: Icons.pending_actions,
                ),
                _SummaryCard(
                  width: cardWidth,
                  title: 'Approved',
                  value: '${_countByStatus('Approved')}',
                  color: Colors.green,
                  icon: Icons.verified,
                ),
                _SummaryCard(
                  width: cardWidth,
                  title: 'On Leave Today',
                  value: '$_activeTodayCount',
                  color: Colors.deepPurple,
                  icon: Icons.beach_access,
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
                  hintText: 'Search by employee, type, or reason',
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
                    selected: _selectedStatus == status,
                    onSelected: (_) {
                      setState(() {
                        _selectedStatus = status;
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
          child: visibleRequests.isEmpty
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
                        'No leave requests found',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: visibleRequests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final request = visibleRequests[index];

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
                                _statusColor(request.status).withOpacity(0.14),
                            child: Text(
                              _shortName(request.employee),
                              style: TextStyle(
                                color: _statusColor(request.status),
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
                                        request.employee,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    _StatusBadge(
                                      label: request.status,
                                      color: _statusColor(request.status),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    _InfoPill(
                                      icon: Icons.calendar_today,
                                      text:
                                          '${_formatDate(request.from)} - ${_formatDate(request.to)}',
                                    ),
                                    _InfoPill(
                                      icon: Icons.timelapse,
                                      text: '${request.days} day(s)',
                                    ),
                                    _TypeBadge(
                                      label: request.type,
                                      color: _typeColor(request.type),
                                    ),
                                  ],
                                ),
                                if (request.reason.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    request.reason,
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
                                _removeRequest(request);
                                return;
                              }
                              _updateStatus(request, value);
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'Pending',
                                child: Text('Mark Pending'),
                              ),
                              PopupMenuItem(
                                value: 'Approved',
                                child: Text('Mark Approved'),
                              ),
                              PopupMenuItem(
                                value: 'Rejected',
                                child: Text('Mark Rejected'),
                              ),
                              PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'Delete',
                                child: Text('Delete Request'),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.width,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final double width;
  final String title;
  final String value;
  final Color color;
  final IconData icon;

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

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label, required this.color});

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

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});

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
