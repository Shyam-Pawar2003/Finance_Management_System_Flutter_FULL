import 'package:flutter/material.dart';

class TaskAssignmentScreen extends StatefulWidget {
  const TaskAssignmentScreen({super.key});

  @override
  State<TaskAssignmentScreen> createState() => _TaskAssignmentScreenState();
}

class _TaskAssignmentScreenState extends State<TaskAssignmentScreen> {
  final _taskNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedEmployee = 'John Doe';
  String _selectedPriority = 'Medium';
  String _selectedProject = 'Mobile App Development';
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 7));

  List<Map<String, dynamic>> assignedTasks = [
    {
      'taskName': 'Fix Login Bug',
      'employee': 'John Doe',
      'project': 'Mobile App Development',
      'priority': 'High',
      'dueDate': '2026-01-30',
      'status': 'In Progress',
    },
    {
      'taskName': 'API Integration',
      'employee': 'Sarah Smith',
      'project': 'Web Dashboard',
      'priority': 'High',
      'dueDate': '2026-01-28',
      'status': 'Pending',
    },
    {
      'taskName': 'Database Migration',
      'employee': 'Mike Johnson',
      'project': 'Cloud Migration',
      'priority': 'Medium',
      'dueDate': '2026-02-05',
      'status': 'Pending',
    },
  ];

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _assignTask() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        assignedTasks.add({
          'taskName': _taskNameController.text,
          'employee': _selectedEmployee,
          'project': _selectedProject,
          'priority': _selectedPriority,
          'dueDate': _selectedDueDate.toString().split(' ')[0],
          'status': 'Pending',
        });
      });

      _taskNameController.clear();
      _descriptionController.clear();
      _selectedPriority = 'Medium';
      _selectedDueDate = DateTime.now().add(const Duration(days: 7));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task assigned successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    }
  }

  void _showAssignTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Assign New Task'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Task Name',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _taskNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter task name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter task name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Enter task description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Assign to Employee',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedEmployee,
                          isExpanded: true,
                          underline: const SizedBox(),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          items: const [
                            DropdownMenuItem(
                              value: 'John Doe',
                              child: Text('John Doe - Senior Developer'),
                            ),
                            DropdownMenuItem(
                              value: 'Sarah Smith',
                              child: Text('Sarah Smith - Frontend Developer'),
                            ),
                            DropdownMenuItem(
                              value: 'Mike Johnson',
                              child: Text('Mike Johnson - Backend Developer'),
                            ),
                            DropdownMenuItem(
                              value: 'Emily Davis',
                              child: Text('Emily Davis - QA Engineer'),
                            ),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              _selectedEmployee = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Project',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedProject,
                          isExpanded: true,
                          underline: const SizedBox(),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          items: const [
                            DropdownMenuItem(
                              value: 'Mobile App Development',
                              child: Text('Mobile App Development'),
                            ),
                            DropdownMenuItem(
                              value: 'Web Dashboard',
                              child: Text('Web Dashboard'),
                            ),
                            DropdownMenuItem(
                              value: 'Cloud Migration',
                              child: Text('Cloud Migration'),
                            ),
                            DropdownMenuItem(
                              value: 'AI Implementation',
                              child: Text('AI Implementation'),
                            ),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              _selectedProject = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Priority',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedPriority,
                          isExpanded: true,
                          underline: const SizedBox(),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          items: const [
                            DropdownMenuItem(
                              value: 'Low',
                              child: Text('Low'),
                            ),
                            DropdownMenuItem(
                              value: 'Medium',
                              child: Text('Medium'),
                            ),
                            DropdownMenuItem(
                              value: 'High',
                              child: Text('High'),
                            ),
                            DropdownMenuItem(
                              value: 'Urgent',
                              child: Text('Urgent'),
                            ),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              _selectedPriority = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Due Date',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDueDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (pickedDate != null) {
                            setDialogState(() {
                              _selectedDueDate = pickedDate;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDueDate.toString().split(' ')[0],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _assignTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Assign Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        title: const Text(
          'Task Management',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _showAssignTaskDialog,
        child: const Icon(Icons.add),
      ),
      body: assignedTasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks assigned yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to assign a new task',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Total Tasks',
                            assignedTasks.length.toString(),
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'In Progress',
                            assignedTasks
                                .where((t) => t['status'] == 'In Progress')
                                .length
                                .toString(),
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'Pending',
                            assignedTasks
                                .where((t) => t['status'] == 'Pending')
                                .length
                                .toString(),
                            Colors.red,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'All Assigned Tasks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Task List
                    ...assignedTasks.map((task) {
                      Color priorityColor = task['priority'] == 'High'
                          ? Colors.red
                          : task['priority'] == 'Medium'
                              ? Colors.orange
                              : task['priority'] == 'Urgent'
                                  ? Colors.deepOrange
                                  : Colors.green;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      task['taskName'],
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: priorityColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      task['priority'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: priorityColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Assigned to: ${task['employee']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Project: ${task['project']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: task['status'] == 'In Progress'
                                          ? Colors.orange.withOpacity(0.2)
                                          : Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      task['status'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: task['status'] == 'In Progress'
                                            ? Colors.orange
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Due: ${task['dueDate']}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard(String label, String count, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
