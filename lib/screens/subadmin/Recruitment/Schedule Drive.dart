import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduledDriveItem {
  final String id;
  final String title;
  final String role;
  final String type;
  final String owner;
  final String location;
  final int capacity;
  final DateTime dateTime;
  final String status;

  const ScheduledDriveItem({
    required this.id,
    required this.title,
    required this.role,
    required this.type,
    required this.owner,
    required this.location,
    required this.capacity,
    required this.dateTime,
    required this.status,
  });
}

class SubAdminScheduleDrivePage extends StatefulWidget {
  final List<String> roles;
  final List<String> owners;

  const SubAdminScheduleDrivePage({
    super.key,
    this.roles = const [],
    this.owners = const [],
  });

  @override
  State<SubAdminScheduleDrivePage> createState() =>
      _SubAdminScheduleDrivePageState();
}

class _SubAdminScheduleDrivePageState extends State<SubAdminScheduleDrivePage> {
  final TextEditingController _driveNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _capacityController =
      TextEditingController(text: '25');

  late String _selectedRole;
  late String _selectedOwner;
  String _selectedType = 'Campus';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 3));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  List<ScheduledDriveItem> _drives = [];

  List<String> get _roleOptions {
    if (widget.roles.isNotEmpty) return widget.roles;
    return const [
      'Payroll Analyst',
      'HR Generalist',
      'Operations Executive',
      'Business Analyst',
    ];
  }

  List<String> get _ownerOptions {
    if (widget.owners.isNotEmpty) return widget.owners;
    return const ['A. Kapoor', 'R. Menon', 'P. Sinha', 'S. Bhatt'];
  }

  @override
  void initState() {
    super.initState();
    _selectedRole = _roleOptions.first;
    _selectedOwner = _ownerOptions.first;
    _drives = [
      ScheduledDriveItem(
        id: 'DRV-110',
        title: 'Finance Analysts Campus Drive',
        role: 'Payroll Analyst',
        type: 'Campus',
        owner: 'A. Kapoor',
        location: 'Ahmedabad',
        capacity: 40,
        dateTime: DateTime.now().add(const Duration(days: 2)),
        status: 'Scheduled',
      ),
      ScheduledDriveItem(
        id: 'DRV-111',
        title: 'Virtual Screening Day',
        role: 'HR Generalist',
        type: 'Virtual',
        owner: 'R. Menon',
        location: 'Online',
        capacity: 30,
        dateTime: DateTime.now().add(const Duration(days: 4)),
        status: 'Scheduled',
      ),
      ScheduledDriveItem(
        id: 'DRV-112',
        title: 'Walk-in Ops Hiring',
        role: 'Operations Executive',
        type: 'Walk-in',
        owner: 'P. Sinha',
        location: 'Mumbai',
        capacity: 45,
        dateTime: DateTime.now().add(const Duration(days: 6)),
        status: 'Planning',
      ),
    ];
  }

  @override
  void dispose() {
    _driveNameController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _scheduleDrive() {
    final title = _driveNameController.text.trim();
    final location = _locationController.text.trim();
    final capacity = int.tryParse(_capacityController.text.trim());

    if (title.isEmpty) {
      _showSnack('Please enter drive title.');
      return;
    }
    if (location.isEmpty) {
      _showSnack('Please enter drive location.');
      return;
    }
    if (capacity == null || capacity <= 0) {
      _showSnack('Please enter valid capacity.');
      return;
    }

    final combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final item = ScheduledDriveItem(
      id: 'DRV-${110 + _drives.length + 1}',
      title: title,
      role: _selectedRole,
      type: _selectedType,
      owner: _selectedOwner,
      location: location,
      capacity: capacity,
      dateTime: combinedDateTime,
      status: 'Scheduled',
    );

    setState(() {
      _drives.insert(0, item);
      _drives.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      _driveNameController.clear();
      _locationController.clear();
      _capacityController.text = '25';
    });

    _showSnack('${item.id} scheduled successfully.');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1A73E8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final thisWeek = _drives
        .where((d) =>
            d.dateTime.isBefore(DateTime.now().add(const Duration(days: 7))))
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Schedule Recruitment Drive',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A73E8), Color(0xFF36B39C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _heroChip('Total Drives', '${_drives.length}'),
                    _heroChip('This Week', '$thisWeek'),
                    _heroChip('Role Focus', _selectedRole),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Drive Details',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _driveNameController,
                      decoration: const InputDecoration(
                        labelText: 'Drive Title',
                        filled: true,
                        fillColor: Color(0xFFF8FAFC),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        SizedBox(
                          width: 220,
                          child: DropdownButtonFormField<String>(
                            value: _selectedRole,
                            isExpanded: true,
                            items: _roleOptions
                                .map((item) => DropdownMenuItem(
                                    value: item, child: Text(item)))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedRole = value);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Role',
                              filled: true,
                              fillColor: Color(0xFFF8FAFC),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 180,
                          child: DropdownButtonFormField<String>(
                            value: _selectedType,
                            items: const ['Campus', 'Walk-in', 'Virtual']
                                .map((item) => DropdownMenuItem(
                                    value: item, child: Text(item)))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedType = value);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Drive Type',
                              filled: true,
                              fillColor: Color(0xFFF8FAFC),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: DropdownButtonFormField<String>(
                            value: _selectedOwner,
                            isExpanded: true,
                            items: _ownerOptions
                                .map((item) => DropdownMenuItem(
                                    value: item, child: Text(item)))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedOwner = value);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Owner',
                              filled: true,
                              fillColor: Color(0xFFF8FAFC),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        SizedBox(
                          width: 220,
                          child: TextField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              labelText: 'Location',
                              filled: true,
                              fillColor: Color(0xFFF8FAFC),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 160,
                          child: TextField(
                            controller: _capacityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Capacity',
                              filled: true,
                              fillColor: Color(0xFFF8FAFC),
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today_rounded,
                              size: 16),
                          label: Text(
                              DateFormat('dd MMM yyyy').format(_selectedDate)),
                        ),
                        OutlinedButton.icon(
                          onPressed: _pickTime,
                          icon: const Icon(Icons.schedule_rounded, size: 16),
                          label: Text(_selectedTime.format(context)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _scheduleDrive,
                        icon: const Icon(Icons.event_available_outlined,
                            size: 18),
                        label: const Text('Schedule Drive'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1A73E8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upcoming Drives',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    if (_drives.isEmpty)
                      const Text(
                        'No drives scheduled yet.',
                        style: TextStyle(color: Color(0xFF64748B)),
                      )
                    else
                      ..._drives.map(
                        (drive) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        drive.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    _statusChip(drive.status),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${drive.id}  -  ${drive.role}  -  ${drive.type}',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _infoChip('Owner: ${drive.owner}'),
                                    _infoChip('Location: ${drive.location}'),
                                    _infoChip('Capacity: ${drive.capacity}'),
                                    _infoChip(
                                      DateFormat('dd MMM yyyy, hh:mm a')
                                          .format(drive.dateTime),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case 'Scheduled':
        color = const Color(0xFF0F9D58);
        break;
      case 'Planning':
        color = const Color(0xFFF29900);
        break;
      default:
        color = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
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

  Widget _infoChip(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Color(0xFF1A73E8),
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
