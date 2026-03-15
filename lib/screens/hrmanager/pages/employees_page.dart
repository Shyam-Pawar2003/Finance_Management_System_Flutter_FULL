import 'package:flutter/material.dart';

class Employee {
  Employee({
    required this.name,
    required this.role,
    required this.department,
    required this.email,
    required this.phone,
    required this.workMode,
    required this.status,
    required this.joinDate,
  });

  String name;
  String role;
  String department;
  String email;
  String phone;
  String workMode;
  String status;
  DateTime joinDate;
}

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({Key? key}) : super(key: key);

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  final List<Employee> _employees = [
    Employee(
      name: 'Alice Smith',
      role: 'HR Manager',
      department: 'Human Resources',
      email: 'alice@example.com',
      phone: '+91 98765 43210',
      workMode: 'Onsite',
      status: 'Active',
      joinDate: DateTime(2024, 4, 10),
    ),
    Employee(
      name: 'Bob Johnson',
      role: 'Recruiter',
      department: 'Talent Acquisition',
      email: 'bob@example.com',
      phone: '+91 91234 56789',
      workMode: 'Hybrid',
      status: 'Active',
      joinDate: DateTime(2025, 1, 15),
    ),
    Employee(
      name: 'Carol Davis',
      role: 'Payroll Specialist',
      department: 'Finance',
      email: 'carol@example.com',
      phone: '+91 99887 76655',
      workMode: 'Remote',
      status: 'Probation',
      joinDate: DateTime(2025, 12, 1),
    ),
    Employee(
      name: 'Daniel Lee',
      role: 'HR Executive',
      department: 'Human Resources',
      email: 'daniel@example.com',
      phone: '+91 90909 12345',
      workMode: 'Onsite',
      status: 'On Leave',
      joinDate: DateTime(2023, 8, 20),
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  static const List<String> _statusFilters = [
    'All',
    'Active',
    'Probation',
    'On Leave',
    'Inactive',
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

  List<Employee> get _visibleEmployees {
    final query = _searchController.text.trim().toLowerCase();

    return _employees.where((employee) {
      final matchesStatus =
          _selectedFilter == 'All' || employee.status == _selectedFilter;
      final matchesQuery = query.isEmpty ||
          employee.name.toLowerCase().contains(query) ||
          employee.role.toLowerCase().contains(query) ||
          employee.department.toLowerCase().contains(query) ||
          employee.email.toLowerCase().contains(query);

      return matchesStatus && matchesQuery;
    }).toList();
  }

  int _countByStatus(String status) {
    return _employees.where((employee) => employee.status == status).length;
  }

  int get _departmentCount {
    return _employees.map((employee) => employee.department).toSet().length;
  }

  int get _flexibleModeCount {
    return _employees
        .where((employee) =>
            employee.workMode == 'Remote' || employee.workMode == 'Hybrid')
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

  void _showAddEmployeeDialog() {
    final formKey = GlobalKey<FormState>();
    var name = '';
    var role = '';
    var department = 'Human Resources';
    var email = '';
    var phone = '';
    var workMode = 'Onsite';
    var status = 'Active';
    var joinDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Employee Profile'),
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
                            const InputDecoration(labelText: 'Full Name'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter employee name';
                          }
                          return null;
                        },
                        onSaved: (value) => name = value!.trim(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Role'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter employee role';
                          }
                          return null;
                        },
                        onSaved: (value) => role = value!.trim(),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: department,
                        decoration:
                            const InputDecoration(labelText: 'Department'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Human Resources',
                            child: Text('Human Resources'),
                          ),
                          DropdownMenuItem(
                            value: 'Talent Acquisition',
                            child: Text('Talent Acquisition'),
                          ),
                          DropdownMenuItem(
                            value: 'Finance',
                            child: Text('Finance'),
                          ),
                          DropdownMenuItem(
                            value: 'Operations',
                            child: Text('Operations'),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            department = value ?? 'Human Resources';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter email';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                        onSaved: (value) => email = value!.trim(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Phone'),
                        onSaved: (value) => phone = value?.trim() ?? '',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: workMode,
                              decoration:
                                  const InputDecoration(labelText: 'Work Mode'),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Onsite',
                                  child: Text('Onsite'),
                                ),
                                DropdownMenuItem(
                                  value: 'Hybrid',
                                  child: Text('Hybrid'),
                                ),
                                DropdownMenuItem(
                                  value: 'Remote',
                                  child: Text('Remote'),
                                ),
                              ],
                              onChanged: (value) {
                                setDialogState(() {
                                  workMode = value ?? 'Onsite';
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
                                  value: 'Active',
                                  child: Text('Active'),
                                ),
                                DropdownMenuItem(
                                  value: 'Probation',
                                  child: Text('Probation'),
                                ),
                                DropdownMenuItem(
                                  value: 'On Leave',
                                  child: Text('On Leave'),
                                ),
                                DropdownMenuItem(
                                  value: 'Inactive',
                                  child: Text('Inactive'),
                                ),
                              ],
                              onChanged: (value) {
                                setDialogState(() {
                                  status = value ?? 'Active';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await _pickDate(context, joinDate);
                          if (picked == null) return;
                          setDialogState(() {
                            joinDate = picked;
                          });
                        },
                        icon: const Icon(Icons.event),
                        label: Text('Join Date ${_formatDate(joinDate)}'),
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
                    _employees.insert(
                      0,
                      Employee(
                        name: name,
                        role: role,
                        department: department,
                        email: email,
                        phone: phone,
                        workMode: workMode,
                        status: status,
                        joinDate: joinDate,
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

  void _removeEmployee(Employee employee) {
    setState(() {
      _employees.remove(employee);
    });
  }

  void _updateStatus(Employee employee, String status) {
    setState(() {
      employee.status = status;
    });
  }

  void _showEmployeeDetails(Employee employee) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(employee.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Role: ${employee.role}'),
              const SizedBox(height: 8),
              Text('Department: ${employee.department}'),
              const SizedBox(height: 8),
              Text('Email: ${employee.email}'),
              const SizedBox(height: 8),
              Text('Phone: ${employee.phone.isEmpty ? '-' : employee.phone}'),
              const SizedBox(height: 8),
              Text('Work Mode: ${employee.workMode}'),
              const SizedBox(height: 8),
              Text('Status: ${employee.status}'),
              const SizedBox(height: 8),
              Text('Joined: ${_formatDate(employee.joinDate)}'),
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
      case 'Active':
        return Colors.green;
      case 'Probation':
        return Colors.orange;
      case 'On Leave':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }

  Color _workModeColor(String workMode) {
    switch (workMode) {
      case 'Remote':
        return Colors.blue;
      case 'Hybrid':
        return Colors.teal;
      default:
        return Colors.indigo;
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
    final visibleEmployees = _visibleEmployees;

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
                    'Employee Directory',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Manage employee profiles, roles, and current workforce status.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _showAddEmployeeDialog,
              icon: const Icon(Icons.add),
              label: const Text('New Employee'),
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
                  title: 'Total Employees',
                  value: '${_employees.length}',
                  icon: Icons.groups,
                  color: Colors.indigo,
                ),
                _MetricCard(
                  width: cardWidth,
                  title: 'Active',
                  value: '${_countByStatus('Active')}',
                  icon: Icons.verified_user,
                  color: Colors.green,
                ),
                _MetricCard(
                  width: cardWidth,
                  title: 'Departments',
                  value: '$_departmentCount',
                  icon: Icons.apartment,
                  color: Colors.orange,
                ),
                _MetricCard(
                  width: cardWidth,
                  title: 'Flexible Mode',
                  value: '$_flexibleModeCount',
                  icon: Icons.laptop_mac,
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
                  hintText: 'Search by name, role, department, or email',
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
          child: visibleEmployees.isEmpty
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
                      Icon(Icons.people_outline,
                          size: 42, color: Colors.black38),
                      SizedBox(height: 10),
                      Text(
                        'No employees found',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: visibleEmployees.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final employee = visibleEmployees[index];

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
                                _statusColor(employee.status).withOpacity(0.14),
                            child: Text(
                              _initials(employee.name),
                              style: TextStyle(
                                color: _statusColor(employee.status),
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
                                            employee.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            employee.role,
                                            style: const TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _Badge(
                                      label: employee.status,
                                      color: _statusColor(employee.status),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _InfoChip(
                                      icon: Icons.apartment,
                                      text: employee.department,
                                    ),
                                    _Badge(
                                      label: employee.workMode,
                                      color: _workModeColor(employee.workMode),
                                    ),
                                    _InfoChip(
                                      icon: Icons.event,
                                      text:
                                          'Joined ${_formatDate(employee.joinDate)}',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _InfoChip(
                                      icon: Icons.mail_outline,
                                      text: employee.email,
                                    ),
                                    if (employee.phone.isNotEmpty)
                                      _InfoChip(
                                        icon: Icons.phone_outlined,
                                        text: employee.phone,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton.icon(
                                onPressed: () => _showEmployeeDetails(employee),
                                icon: const Icon(Icons.visibility_outlined),
                                label: const Text('View'),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'Delete') {
                                    _removeEmployee(employee);
                                    return;
                                  }
                                  _updateStatus(employee, value);
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'Active',
                                    child: Text('Mark Active'),
                                  ),
                                  PopupMenuItem(
                                    value: 'Probation',
                                    child: Text('Mark Probation'),
                                  ),
                                  PopupMenuItem(
                                    value: 'On Leave',
                                    child: Text('Mark On Leave'),
                                  ),
                                  PopupMenuItem(
                                    value: 'Inactive',
                                    child: Text('Mark Inactive'),
                                  ),
                                  PopupMenuDivider(),
                                  PopupMenuItem(
                                    value: 'Delete',
                                    child: Text('Delete Employee'),
                                  ),
                                ],
                                child: const Icon(Icons.more_vert),
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
