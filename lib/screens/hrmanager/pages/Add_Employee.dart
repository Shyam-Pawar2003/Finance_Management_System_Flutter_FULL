import 'package:flutter/material.dart';

class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({
    super.key,
    this.onEmployeeCreated,
  });

  final ValueChanged<EmployeeDraft>? onEmployeeCreated;

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  static const List<String> _departments = [
    'Human Resources',
    'Talent Acquisition',
    'Finance',
    'Operations',
    'IT',
    'Sales',
    'Marketing',
  ];

  static const List<String> _workModes = [
    'Onsite',
    'Hybrid',
    'Remote',
  ];

  static const List<String> _statuses = [
    'Active',
    'Probation',
    'On Leave',
    'Inactive',
  ];

  String _department = _departments.first;
  String _workMode = _workModes.first;
  String _status = _statuses.first;
  DateTime _joinDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _employeeIdController.dispose();
    _salaryController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickJoinDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joinDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    setState(() => _joinDate = picked);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  InputDecoration _fieldDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Future<void> _saveEmployee() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final draft = EmployeeDraft(
      fullName: _nameController.text.trim(),
      role: _roleController.text.trim(),
      department: _department,
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      employeeId: _employeeIdController.text.trim(),
      salary: double.tryParse(_salaryController.text.trim()) ?? 0,
      address: _addressController.text.trim(),
      notes: _notesController.text.trim(),
      workMode: _workMode,
      status: _status,
      joinDate: _joinDate,
    );

    setState(() => _isSaving = true);

    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) {
      return;
    }

    widget.onEmployeeCreated?.call(draft);

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Employee created: ${draft.fullName}'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop(draft);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Employee'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Employee Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Fill the details below to add a new employee to HR records.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: _fieldDecoration('Full Name', Icons.person),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _roleController,
                  decoration: _fieldDecoration('Role', Icons.badge_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter role';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _department,
                        decoration: _fieldDecoration(
                          'Department',
                          Icons.apartment_outlined,
                        ),
                        items: _departments
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _department = value ?? _department);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _employeeIdController,
                        decoration: _fieldDecoration(
                          'Employee ID',
                          Icons.tag,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter employee ID';
                          }
                          return null;
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
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _fieldDecoration('Email', Icons.email),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter email';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _fieldDecoration('Phone', Icons.call),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _workMode,
                        decoration: _fieldDecoration(
                          'Work Mode',
                          Icons.work_outline,
                        ),
                        items: _workModes
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _workMode = value ?? _workMode);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _status,
                        decoration: _fieldDecoration(
                          'Status',
                          Icons.verified_user_outlined,
                        ),
                        items: _statuses
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _status = value ?? _status);
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
                        controller: _salaryController,
                        keyboardType: TextInputType.number,
                        decoration: _fieldDecoration(
                          'Salary',
                          Icons.currency_rupee,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter salary';
                          }
                          if (double.tryParse(value.trim()) == null) {
                            return 'Enter valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickJoinDate,
                        icon: const Icon(Icons.event),
                        label: Text('Join ${_formatDate(_joinDate)}'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: _fieldDecoration(
                    'Address',
                    Icons.location_on_outlined,
                  ),
                  minLines: 2,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: _fieldDecoration(
                    'Notes (Optional)',
                    Icons.note_alt_outlined,
                  ),
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveEmployee,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label:
                            Text(_isSaving ? 'Saving...' : 'Create Employee'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmployeeDraft {
  const EmployeeDraft({
    required this.fullName,
    required this.role,
    required this.department,
    required this.email,
    required this.phone,
    required this.employeeId,
    required this.salary,
    required this.address,
    required this.notes,
    required this.workMode,
    required this.status,
    required this.joinDate,
  });

  final String fullName;
  final String role;
  final String department;
  final String email;
  final String phone;
  final String employeeId;
  final double salary;
  final String address;
  final String notes;
  final String workMode;
  final String status;
  final DateTime joinDate;
}
