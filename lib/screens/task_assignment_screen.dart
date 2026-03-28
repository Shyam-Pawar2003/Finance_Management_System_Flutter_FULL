import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/task_model.dart';
import '../providers/task_provider.dart';

class TaskAssignmentScreen extends StatefulWidget {
  const TaskAssignmentScreen({super.key});

  @override
  State<TaskAssignmentScreen> createState() => _TaskAssignmentScreenState();
}

class _TaskAssignmentScreenState extends State<TaskAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  String _assignedTo = 'General Team';
  String _priority = 'Medium';
  String _project = 'General';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));

  static const _priorityOptions = ['Low', 'Medium', 'High', 'Urgent'];
  static const _statusOptions = ['Pending', 'In Progress', 'Completed'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<TaskProvider>();
    final task = AppTaskModel(
      id: const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      assignedTo: _assignedTo,
      project: _project,
      priority: _priority,
      status: 'Pending',
      dueDate: _dueDate,
      createdAt: DateTime.now(),
    );

    await provider.addTask(task);
    if (!mounted) return;

    _titleCtrl.clear();
    _descriptionCtrl.clear();
    setState(() {
      _priority = 'Medium';
      _project = 'General';
      _assignedTo = 'General Team';
      _dueDate = DateTime.now().add(const Duration(days: 7));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task created and saved to Firebase.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.tasks;

    final pending = tasks.where((t) => t.status == 'Pending').length;
    final inProgress = tasks.where((t) => t.status == 'In Progress').length;
    final completed = tasks.where((t) => t.status == 'Completed').length;

    return Scaffold(
      appBar: AppBar(title: const Text('Task Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Task title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Task title is required'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionCtrl,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _assignedTo,
                          decoration: const InputDecoration(
                            labelText: 'Assigned to',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) => _assignedTo =
                              v.trim().isEmpty ? 'General Team' : v.trim(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: _project,
                          decoration: const InputDecoration(
                            labelText: 'Project',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) => _project =
                              v.trim().isEmpty ? 'General' : v.trim(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _priority,
                          items: _priorityOptions
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) {
                            if (v != null) setState(() => _priority = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.event),
                          label: Text(
                            '${_dueDate.day.toString().padLeft(2, '0')}/${_dueDate.month.toString().padLeft(2, '0')}/${_dueDate.year}',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _createTask,
                      icon: const Icon(Icons.add_task_rounded),
                      label: const Text('Create Task'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _summaryChip('All', tasks.length, Colors.blue),
                const SizedBox(width: 8),
                _summaryChip('Pending', pending, Colors.orange),
                const SizedBox(width: 8),
                _summaryChip('In Progress', inProgress, Colors.purple),
                const SizedBox(width: 8),
                _summaryChip('Done', completed, Colors.green),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : tasks.isEmpty
                    ? const Center(
                        child: Text('No tasks yet. Create your first task.'),
                      )
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
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
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              priorityColor.withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                  Text(
                                    'Assigned: ${task.assignedTo} | Project: ${task.project}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  if (task.description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        task.description,
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: task.status,
                                          items: _statusOptions
                                              .map((e) => DropdownMenuItem(
                                                    value: e,
                                                    child: Text(e),
                                                  ))
                                              .toList(),
                                          decoration: const InputDecoration(
                                            labelText: 'Status',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          onChanged: (value) {
                                            if (value == null) return;
                                            context
                                                .read<TaskProvider>()
                                                .updateTaskStatus(
                                                  task.id,
                                                  value,
                                                );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Due ${task.dueDate.day.toString().padLeft(2, '0')}/${task.dueDate.month.toString().padLeft(2, '0')}/${task.dueDate.year}',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => context
                                            .read<TaskProvider>()
                                            .deleteTask(task.id),
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
      ),
    );
  }

  Widget _summaryChip(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
