import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';

class EmployeeTaskScreen extends StatefulWidget {
  const EmployeeTaskScreen({super.key});

  @override
  State<EmployeeTaskScreen> createState() => _EmployeeTaskScreenState();
}

class _EmployeeTaskScreenState extends State<EmployeeTaskScreen> {
  int _selectedIndex = 0;
  String _filterStatus = 'All';

  static const _statusFilters = [
    'All',
    'Pending',
    'In Progress',
    'Completed',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal,
        title: const Text(
          'My Tasks',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Payment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildTasksTab();
      case 1:
        return _buildScheduleTab();
      case 2:
        return _buildPaymentTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildTasksTab();
    }
  }

  Widget _buildTasksTab() {
    final provider = context.watch<TaskProvider>();
    final allTasks = provider.tasks;
    final visibleTasks = _filterStatus == 'All'
        ? allTasks
        : allTasks.where((t) => t.status == _filterStatus).toList();

    final pending = allTasks.where((t) => t.status == 'Pending').length;
    final inProgress = allTasks.where((t) => t.status == 'In Progress').length;
    final completed = allTasks.where((t) => t.status == 'Completed').length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                  child: _summaryCard('Total', allTasks.length, Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _summaryCard('Pending', pending, Colors.orange)),
              const SizedBox(width: 8),
              Expanded(
                  child: _summaryCard('Progress', inProgress, Colors.purple)),
              const SizedBox(width: 8),
              Expanded(child: _summaryCard('Done', completed, Colors.green)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Text('Filter: '),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterStatus,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: _statusFilters
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        _filterStatus = v;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : visibleTasks.isEmpty
                  ? const Center(child: Text('No tasks available.'))
                  : ListView.builder(
                      itemCount: visibleTasks.length,
                      itemBuilder: (context, index) {
                        final task = visibleTasks[index];
                        final priorityColor = task.priority == 'Urgent'
                            ? Colors.red
                            : task.priority == 'High'
                                ? Colors.deepOrange
                                : task.priority == 'Medium'
                                    ? Colors.orange
                                    : Colors.green;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        task.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: priorityColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        task.priority,
                                        style: TextStyle(
                                          color: priorityColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('Project: ${task.project}'),
                                Text('Assigned To: ${task.assignedTo}'),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: task.status,
                                        decoration: const InputDecoration(
                                          labelText: 'Status',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'Pending',
                                            child: Text('Pending'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'In Progress',
                                            child: Text('In Progress'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Completed',
                                            child: Text('Completed'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          if (value == null) return;
                                          context
                                              .read<TaskProvider>()
                                              .updateTaskStatus(task.id, value);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${task.dueDate.day.toString().padLeft(2, '0')}/${task.dueDate.month.toString().padLeft(2, '0')}/${task.dueDate.year}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildScheduleTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: Icon(Icons.today, color: Colors.teal),
          title: Text('Today'),
          subtitle: Text('09:00 AM - 06:00 PM'),
        ),
        ListTile(
          leading: Icon(Icons.event, color: Colors.blue),
          title: Text('Weekly Standup'),
          subtitle: Text('Monday, 10:00 AM'),
        ),
        ListTile(
          leading: Icon(Icons.group, color: Colors.orange),
          title: Text('Sprint Review'),
          subtitle: Text('Friday, 04:00 PM'),
        ),
      ],
    );
  }

  Widget _buildPaymentTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Current Month',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'INR 45,000',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 8),
                Text('Next payout date: 1st of next month'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CircleAvatar(
          radius: 42,
          backgroundColor: Colors.teal.shade100,
          child: const Icon(Icons.person, size: 40, color: Colors.teal),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Employee Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        const ListTile(
          leading: Icon(Icons.email),
          title: Text('Email'),
          subtitle: Text('employee@company.com'),
        ),
        const ListTile(
          leading: Icon(Icons.badge),
          title: Text('Role'),
          subtitle: Text('Team Member'),
        ),
      ],
    );
  }

  Widget _summaryCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
