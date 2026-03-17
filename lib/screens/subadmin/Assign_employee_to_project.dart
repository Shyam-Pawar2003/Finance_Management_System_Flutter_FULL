import 'package:flutter/material.dart';

class SubAdminAssignEmployeeToProjectPage extends StatefulWidget {
	const SubAdminAssignEmployeeToProjectPage({super.key});

	@override
	State<SubAdminAssignEmployeeToProjectPage> createState() =>
			_SubAdminAssignEmployeeToProjectPageState();
}

class _SubAdminAssignEmployeeToProjectPageState
		extends State<SubAdminAssignEmployeeToProjectPage> {
	String _searchQuery = '';
	String _selectedDepartment = 'All';
	String _selectedStatus = 'All';

	String? _selectedEmployeeId;
	String? _selectedProjectId;
	String _selectedRole = 'Contributor';
	double _allocation = 60;
	bool _notifyEmployee = true;
	bool _billable = true;

	late DateTime _startDate;
	late DateTime _dueDate;
	late final TextEditingController _searchController;
	late final TextEditingController _notesController;

	static const List<String> _statusOptions = [
		'All',
		'Assigned',
		'In Progress',
		'Completed',
		'At Risk',
	];

	static const List<String> _roleOptions = [
		'Contributor',
		'Reviewer',
		'Coordinator',
		'Owner',
	];

	final List<_EmployeeOption> _employees = const [
		_EmployeeOption(
			id: 'EMP-101',
			name: 'Rahul Sharma',
			department: 'Finance',
			title: 'Senior Analyst',
			utilization: 0.72,
		),
		_EmployeeOption(
			id: 'EMP-112',
			name: 'Neha Verma',
			department: 'HR',
			title: 'Talent Partner',
			utilization: 0.61,
		),
		_EmployeeOption(
			id: 'EMP-128',
			name: 'Arjun Mehta',
			department: 'Operations',
			title: 'Process Specialist',
			utilization: 0.81,
		),
		_EmployeeOption(
			id: 'EMP-139',
			name: 'Maya Nair',
			department: 'Operations',
			title: 'Project Coordinator',
			utilization: 0.58,
		),
		_EmployeeOption(
			id: 'EMP-141',
			name: 'Karan Patel',
			department: 'Finance',
			title: 'Payroll Executive',
			utilization: 0.66,
		),
		_EmployeeOption(
			id: 'EMP-152',
			name: 'Ishita Rao',
			department: 'Legal',
			title: 'Compliance Associate',
			utilization: 0.49,
		),
		_EmployeeOption(
			id: 'EMP-168',
			name: 'Rohan Das',
			department: 'Support',
			title: 'Service Specialist',
			utilization: 0.57,
		),
	];

	final List<_ProjectOption> _projects = [
		_ProjectOption(
			id: 'PRJ-1042',
			name: 'Payroll Automation Phase 2',
			department: 'Finance',
			manager: 'A. Kapoor',
			status: 'On Track',
			priority: 'High',
			deadline: DateTime(2026, 3, 22),
		),
		_ProjectOption(
			id: 'PRJ-1049',
			name: 'Hiring Pipeline Revamp',
			department: 'HR',
			manager: 'R. Menon',
			status: 'At Risk',
			priority: 'High',
			deadline: DateTime(2026, 3, 19),
		),
		_ProjectOption(
			id: 'PRJ-1061',
			name: 'Policy Compliance Assistant',
			department: 'Legal',
			manager: 'S. Bhatt',
			status: 'On Track',
			priority: 'Medium',
			deadline: DateTime(2026, 3, 28),
		),
		_ProjectOption(
			id: 'PRJ-1074',
			name: 'Offer Approval Workflow',
			department: 'HR',
			manager: 'N. Verma',
			status: 'On Track',
			priority: 'High',
			deadline: DateTime(2026, 3, 24),
		),
		_ProjectOption(
			id: 'PRJ-1082',
			name: 'Regional Support Capacity Planner',
			department: 'Support',
			manager: 'T. Deshmukh',
			status: 'At Risk',
			priority: 'High',
			deadline: DateTime(2026, 3, 20),
		),
	];

	final List<_AssignmentRecord> _assignments = [
		_AssignmentRecord(
			id: 'ASN-3001',
			employeeId: 'EMP-101',
			employeeName: 'Rahul Sharma',
			employeeDepartment: 'Finance',
			projectId: 'PRJ-1042',
			projectName: 'Payroll Automation Phase 2',
			role: 'Owner',
			status: 'In Progress',
			allocation: 70,
			startDate: DateTime(2026, 3, 1),
			dueDate: DateTime(2026, 3, 22),
			billable: true,
		),
		_AssignmentRecord(
			id: 'ASN-3002',
			employeeId: 'EMP-112',
			employeeName: 'Neha Verma',
			employeeDepartment: 'HR',
			projectId: 'PRJ-1049',
			projectName: 'Hiring Pipeline Revamp',
			role: 'Contributor',
			status: 'At Risk',
			allocation: 65,
			startDate: DateTime(2026, 2, 28),
			dueDate: DateTime(2026, 3, 19),
			billable: true,
		),
		_AssignmentRecord(
			id: 'ASN-3003',
			employeeId: 'EMP-152',
			employeeName: 'Ishita Rao',
			employeeDepartment: 'Legal',
			projectId: 'PRJ-1061',
			projectName: 'Policy Compliance Assistant',
			role: 'Reviewer',
			status: 'Assigned',
			allocation: 45,
			startDate: DateTime(2026, 3, 12),
			dueDate: DateTime(2026, 3, 28),
			billable: false,
		),
	];

	@override
	void initState() {
		super.initState();
		_searchController = TextEditingController();
		_notesController = TextEditingController();
		_startDate = DateTime.now();
		_dueDate = DateTime.now().add(const Duration(days: 14));
	}

	@override
	void dispose() {
		_searchController.dispose();
		_notesController.dispose();
		super.dispose();
	}

	List<String> get _departments {
		final values = _employees.map((employee) => employee.department).toSet().toList()
			..sort();
		return ['All', ...values];
	}

	List<_AssignmentRecord> get _filteredAssignments {
		final query = _searchQuery.trim().toLowerCase();

		final list = _assignments.where((assignment) {
			final matchesSearch = query.isEmpty ||
					assignment.id.toLowerCase().contains(query) ||
					assignment.employeeName.toLowerCase().contains(query) ||
					assignment.projectName.toLowerCase().contains(query) ||
					assignment.role.toLowerCase().contains(query);

			final matchesDepartment = _selectedDepartment == 'All' ||
					assignment.employeeDepartment == _selectedDepartment;

			final matchesStatus =
					_selectedStatus == 'All' || assignment.status == _selectedStatus;

			return matchesSearch && matchesDepartment && matchesStatus;
		}).toList();

		list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
		return list;
	}

	int _countByStatus(List<_AssignmentRecord> list, String status) {
		return list.where((assignment) => assignment.status == status).length;
	}

	double _averageAllocation(List<_AssignmentRecord> list) {
		if (list.isEmpty) {
			return 0;
		}
		final total = list.fold<double>(0, (sum, item) => sum + item.allocation);
		return total / list.length;
	}

	int _dueInSevenDays(List<_AssignmentRecord> list) {
		final now = DateTime.now();
		final limit = now.add(const Duration(days: 7));
		return list
				.where((assignment) =>
						assignment.dueDate.isAfter(now) && assignment.dueDate.isBefore(limit))
				.length;
	}

	int _unassignedEmployees() {
		final assignedIds = _assignments
				.where((assignment) => assignment.status != 'Completed')
				.map((assignment) => assignment.employeeId)
				.toSet();
		return _employees.where((employee) => !assignedIds.contains(employee.id)).length;
	}

	Future<void> _pickDate({required bool isStart}) async {
		final initialDate = isStart ? _startDate : _dueDate;

		final picked = await showDatePicker(
			context: context,
			initialDate: initialDate,
			firstDate: DateTime(2024),
			lastDate: DateTime(2032),
		);

		if (picked == null) {
			return;
		}

		if (!mounted) {
			return;
		}

		setState(() {
			if (isStart) {
				_startDate = picked;
				if (_dueDate.isBefore(_startDate)) {
					_dueDate = _startDate.add(const Duration(days: 7));
				}
			} else {
				_dueDate = picked;
			}
		});
	}

	void _clearDraft() {
		setState(() {
			_selectedEmployeeId = null;
			_selectedProjectId = null;
			_selectedRole = _roleOptions.first;
			_allocation = 60;
			_notifyEmployee = true;
			_billable = true;
			_startDate = DateTime.now();
			_dueDate = DateTime.now().add(const Duration(days: 14));
			_notesController.clear();
		});
	}

	void _createAssignment() {
		if (_selectedEmployeeId == null || _selectedProjectId == null) {
			_showSnack(
				'Select both an employee and a project before creating an assignment.',
				isError: true,
			);
			return;
		}

		if (_dueDate.isBefore(_startDate)) {
			_showSnack('Due date cannot be earlier than start date.', isError: true);
			return;
		}

		final duplicate = _assignments.any((assignment) =>
				assignment.employeeId == _selectedEmployeeId &&
				assignment.projectId == _selectedProjectId &&
				assignment.status != 'Completed');

		if (duplicate) {
			_showSnack(
				'This employee already has an active assignment on the selected project.',
				isError: true,
			);
			return;
		}

		final employee = _employees.firstWhere((item) => item.id == _selectedEmployeeId);
		final project = _projects.firstWhere((item) => item.id == _selectedProjectId);

		final assignment = _AssignmentRecord(
			id: 'ASN-${3000 + _assignments.length + 1}',
			employeeId: employee.id,
			employeeName: employee.name,
			employeeDepartment: employee.department,
			projectId: project.id,
			projectName: project.name,
			role: _selectedRole,
			status: 'Assigned',
			allocation: _allocation,
			startDate: _startDate,
			dueDate: _dueDate,
			billable: _billable,
		);

		setState(() {
			_assignments.insert(0, assignment);
			_notesController.clear();
			_selectedEmployeeId = null;
			_selectedProjectId = null;
			_selectedRole = _roleOptions.first;
			_allocation = 60;
			_startDate = DateTime.now();
			_dueDate = DateTime.now().add(const Duration(days: 14));
		});

		_showSnack(
			_notifyEmployee
					? 'Assignment created and employee notification queued.'
					: 'Assignment created successfully.',
		);
	}

	void _updateStatus(_AssignmentRecord record, String status) {
		final index = _assignments.indexWhere((item) => item.id == record.id);
		if (index == -1) {
			return;
		}
		setState(() {
			_assignments[index] = _assignments[index].copyWith(status: status);
		});
	}

	void _removeAssignment(_AssignmentRecord record) {
		setState(() {
			_assignments.removeWhere((item) => item.id == record.id);
		});
		_showSnack('Assignment ${record.id} removed.');
	}

	void _showSnack(String message, {bool isError = false}) {
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text(message),
				backgroundColor: isError ? const Color(0xFFDB4437) : const Color(0xFF1A73E8),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFFF4F7FC),
			body: SafeArea(
				child: LayoutBuilder(
					builder: (context, constraints) {
						final width = constraints.maxWidth;
						final isCompact = width < 760;
						final isNarrow = width < 1140;
						final assignments = _filteredAssignments;

						return SingleChildScrollView(
							padding: EdgeInsets.all(isCompact ? 14 : 20),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									_buildHeader(isCompact),
									const SizedBox(height: 16),
									_buildHeroCard(assignments),
									const SizedBox(height: 16),
									_buildMetricGrid(width, assignments),
									const SizedBox(height: 16),
									if (isNarrow) ...[
										_buildComposerPanel(isCompact),
										const SizedBox(height: 14),
										_buildAssignmentsPanel(assignments, isCompact),
										const SizedBox(height: 14),
										_buildInsightsPanel(assignments),
									] else
										Row(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Expanded(
													flex: 2,
													child: Column(
														children: [
															_buildComposerPanel(false),
															const SizedBox(height: 16),
															_buildInsightsPanel(assignments),
														],
													),
												),
												const SizedBox(width: 16),
												Expanded(
													flex: 3,
													child: _buildAssignmentsPanel(assignments, false),
												),
											],
										),
								],
							),
						);
					},
				),
			),
		);
	}

	Widget _buildHeader(bool isCompact) {
		final title = Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: const [
				Text(
					'Assign Employee To Project',
					style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
				),
				SizedBox(height: 6),
				Text(
					'Plan ownership, allocation, and due dates with full execution visibility.',
					style: TextStyle(color: Color(0xFF5F6368)),
				),
			],
		);

		final actions = Wrap(
			spacing: 8,
			runSpacing: 8,
			children: [
				OutlinedButton.icon(
					onPressed: _clearDraft,
					icon: const Icon(Icons.restart_alt_rounded, size: 18),
					label: const Text('Reset Draft'),
					style: OutlinedButton.styleFrom(
						foregroundColor: const Color(0xFF0F172A),
						side: const BorderSide(color: Color(0xFFD6DEE8)),
						padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
					),
				),
				FilledButton.icon(
					onPressed: _createAssignment,
					icon: const Icon(Icons.assignment_turned_in_outlined, size: 18),
					label: const Text('Create Assignment'),
					style: FilledButton.styleFrom(
						backgroundColor: const Color(0xFF1A73E8),
						padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
					),
				),
			],
		);

		if (isCompact) {
			return Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					title,
					const SizedBox(height: 12),
					actions,
				],
			);
		}

		return Row(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Expanded(child: title),
				actions,
			],
		);
	}

	Widget _buildHeroCard(List<_AssignmentRecord> list) {
		final active = list.where((item) => item.status != 'Completed').length;
		final completionRate = list.isEmpty
				? 0
				: (_countByStatus(list, 'Completed') / list.length * 100).round();

		return Container(
			width: double.infinity,
			padding: const EdgeInsets.all(18),
			decoration: BoxDecoration(
				gradient: const LinearGradient(
					colors: [Color(0xFF0F5ED7), Color(0xFF1A73E8), Color(0xFF36B39C)],
					begin: Alignment.topLeft,
					end: Alignment.bottomRight,
				),
				borderRadius: BorderRadius.circular(18),
				boxShadow: [
					BoxShadow(
						color: const Color(0xFF1A73E8).withOpacity(0.28),
						blurRadius: 22,
						offset: const Offset(0, 12),
					),
				],
			),
			child: Wrap(
				spacing: 16,
				runSpacing: 16,
				crossAxisAlignment: WrapCrossAlignment.center,
				children: [
					const SizedBox(
						width: 360,
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									'Execution Assignment Hub',
									style: TextStyle(
										color: Colors.white,
										fontSize: 22,
										fontWeight: FontWeight.w800,
									),
								),
								SizedBox(height: 8),
								Text(
									'Balance team capacity with priority projects and resolve bottlenecks before deadlines slip.',
									style: TextStyle(color: Colors.white70, height: 1.4),
								),
							],
						),
					),
					_heroBadge(Icons.assignment_rounded, '$active Active Assignments'),
					_heroBadge(Icons.timeline_rounded, '$completionRate% Completion Rate'),
					_heroBadge(Icons.groups_2_outlined,
							'${_unassignedEmployees()} Unassigned Employees'),
				],
			),
		);
	}

	Widget _heroBadge(IconData icon, String label) {
		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
			decoration: BoxDecoration(
				color: Colors.white.withOpacity(0.17),
				borderRadius: BorderRadius.circular(12),
				border: Border.all(color: Colors.white.withOpacity(0.3)),
			),
			child: Row(
				mainAxisSize: MainAxisSize.min,
				children: [
					Icon(icon, color: Colors.white, size: 18),
					const SizedBox(width: 8),
					Text(
						label,
						style: const TextStyle(
							color: Colors.white,
							fontWeight: FontWeight.w700,
						),
					),
				],
			),
		);
	}

	Widget _buildMetricGrid(double width, List<_AssignmentRecord> list) {
		int columns = 4;
		if (width < 1180) {
			columns = 2;
		}
		if (width < 700) {
			columns = 1;
		}

		final metrics = [
			_MetricCardData(
				title: 'Assigned',
				value: '${_countByStatus(list, 'Assigned')}',
				hint: 'Recently created',
				color: const Color(0xFF1A73E8),
				icon: Icons.assignment_outlined,
			),
			_MetricCardData(
				title: 'In Progress',
				value: '${_countByStatus(list, 'In Progress')}',
				hint: 'Currently executing',
				color: const Color(0xFF36B39C),
				icon: Icons.play_circle_outline_rounded,
			),
			_MetricCardData(
				title: 'Avg Allocation',
				value: '${_averageAllocation(list).toStringAsFixed(0)}%',
				hint: 'Across filtered items',
				color: const Color(0xFFF29900),
				icon: Icons.pie_chart_outline_rounded,
			),
			_MetricCardData(
				title: 'Due In 7 Days',
				value: '${_dueInSevenDays(list)}',
				hint: 'Need close tracking',
				color: const Color(0xFFDB4437),
				icon: Icons.event_busy_outlined,
			),
		];

		return GridView.builder(
			shrinkWrap: true,
			physics: const NeverScrollableScrollPhysics(),
			itemCount: metrics.length,
			gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
				crossAxisCount: columns,
				crossAxisSpacing: 12,
				mainAxisSpacing: 12,
				mainAxisExtent: 140,
			),
			itemBuilder: (context, index) {
				final metric = metrics[index];
				return _panel(
					padding: const EdgeInsets.all(14),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Row(
								children: [
									Container(
										padding: const EdgeInsets.all(8),
										decoration: BoxDecoration(
											color: metric.color.withOpacity(0.12),
											borderRadius: BorderRadius.circular(10),
										),
										child: Icon(metric.icon, size: 19, color: metric.color),
									),
									const Spacer(),
									Text(
										metric.title,
										maxLines: 1,
										overflow: TextOverflow.ellipsis,
										style: const TextStyle(
											fontSize: 12,
											color: Color(0xFF5F6368),
											fontWeight: FontWeight.w600,
										),
									),
								],
							),
							const SizedBox(height: 10),
							Text(
								metric.value,
								style: const TextStyle(
									fontSize: 25,
									fontWeight: FontWeight.w800,
									color: Color(0xFF0F172A),
								),
							),
							const SizedBox(height: 5),
							Text(
								metric.hint,
								maxLines: 2,
								overflow: TextOverflow.ellipsis,
								style: const TextStyle(color: Color(0xFF64748B)),
							),
						],
					),
				);
			},
		);
	}

	Widget _buildComposerPanel(bool isCompact) {
		return _panel(
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					const Text(
						'Create Assignment',
						style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
					),
					const SizedBox(height: 6),
					const Text(
						'Select an employee, project, and ownership details.',
						style: TextStyle(color: Color(0xFF64748B)),
					),
					const SizedBox(height: 14),
					_fieldLabel('Employee'),
					DropdownButtonFormField<String>(
						value: _selectedEmployeeId,
						items: _employees
								.map(
									(employee) => DropdownMenuItem(
										value: employee.id,
										child: Text('${employee.name} (${employee.department})'),
									),
								)
								.toList(),
						onChanged: (value) {
							setState(() {
								_selectedEmployeeId = value;
							});
						},
						decoration: _inputDecoration('Select employee'),
						isExpanded: true,
					),
					const SizedBox(height: 12),
					_fieldLabel('Project'),
					DropdownButtonFormField<String>(
						value: _selectedProjectId,
						items: _projects
								.map(
									(project) => DropdownMenuItem(
										value: project.id,
										child: Text('${project.name} (${project.priority})'),
									),
								)
								.toList(),
						onChanged: (value) {
							setState(() {
								_selectedProjectId = value;
							});
						},
						decoration: _inputDecoration('Select project'),
						isExpanded: true,
					),
					const SizedBox(height: 12),
					if (isCompact) ...[
						_roleField(),
						const SizedBox(height: 12),
						_allocationField(),
					] else
						Row(
							children: [
								Expanded(child: _roleField()),
								const SizedBox(width: 10),
								Expanded(child: _allocationField()),
							],
						),
					const SizedBox(height: 12),
					if (isCompact) ...[
						_dateField(isStart: true),
						const SizedBox(height: 10),
						_dateField(isStart: false),
					] else
						Row(
							children: [
								Expanded(child: _dateField(isStart: true)),
								const SizedBox(width: 10),
								Expanded(child: _dateField(isStart: false)),
							],
						),
					const SizedBox(height: 12),
					_fieldLabel('Notes'),
					TextField(
						controller: _notesController,
						minLines: 2,
						maxLines: 3,
						decoration: _inputDecoration('Optional context for this assignment'),
					),
					const SizedBox(height: 10),
					SwitchListTile(
						contentPadding: EdgeInsets.zero,
						value: _notifyEmployee,
						onChanged: (value) {
							setState(() {
								_notifyEmployee = value;
							});
						},
						title: const Text('Notify employee immediately'),
						dense: true,
					),
					SwitchListTile(
						contentPadding: EdgeInsets.zero,
						value: _billable,
						onChanged: (value) {
							setState(() {
								_billable = value;
							});
						},
						title: const Text('Mark as billable assignment'),
						dense: true,
					),
					const SizedBox(height: 6),
					Row(
						children: [
							Expanded(
								child: OutlinedButton.icon(
									onPressed: _clearDraft,
									icon: const Icon(Icons.close_rounded, size: 17),
									label: const Text('Clear'),
								),
							),
							const SizedBox(width: 10),
							Expanded(
								child: FilledButton.icon(
									onPressed: _createAssignment,
									icon: const Icon(Icons.add_task_rounded, size: 18),
									label: const Text('Assign'),
									style: FilledButton.styleFrom(
										backgroundColor: const Color(0xFF1A73E8),
									),
								),
							),
						],
					),
				],
			),
		);
	}

	Widget _roleField() {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				_fieldLabel('Role'),
				DropdownButtonFormField<String>(
					value: _selectedRole,
					items: _roleOptions
							.map((role) => DropdownMenuItem(value: role, child: Text(role)))
							.toList(),
					onChanged: (value) {
						if (value == null) {
							return;
						}
						setState(() {
							_selectedRole = value;
						});
					},
					decoration: _inputDecoration('Role in project'),
				),
			],
		);
	}

	Widget _allocationField() {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				_fieldLabel('Allocation ${_allocation.round()}%'),
				SliderTheme(
					data: SliderTheme.of(context).copyWith(
						activeTrackColor: const Color(0xFF1A73E8),
						inactiveTrackColor: const Color(0xFFDCE6F3),
						thumbColor: const Color(0xFF1A73E8),
					),
					child: Slider(
						value: _allocation,
						min: 20,
						max: 100,
						divisions: 16,
						onChanged: (value) {
							setState(() {
								_allocation = value;
							});
						},
					),
				),
			],
		);
	}

	Widget _dateField({required bool isStart}) {
		final value = isStart ? _startDate : _dueDate;
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				_fieldLabel(isStart ? 'Start Date' : 'Due Date'),
				InkWell(
					onTap: () => _pickDate(isStart: isStart),
					borderRadius: BorderRadius.circular(10),
					child: Ink(
						padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
						decoration: BoxDecoration(
							color: Colors.white,
							borderRadius: BorderRadius.circular(10),
							border: Border.all(color: const Color(0xFFD5DEE9)),
						),
						child: Row(
							children: [
								const Icon(Icons.date_range_outlined,
										size: 18, color: Color(0xFF1A73E8)),
								const SizedBox(width: 8),
								Text(
									_formatDate(value),
									style: const TextStyle(fontWeight: FontWeight.w600),
								),
							],
						),
					),
				),
			],
		);
	}

	Widget _buildAssignmentsPanel(List<_AssignmentRecord> list, bool isCompact) {
		return _panel(
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					const Text(
						'Assignment Board',
						style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
					),
					const SizedBox(height: 6),
					const Text(
						'Filter by department or status and update progress in one place.',
						style: TextStyle(color: Color(0xFF64748B)),
					),
					const SizedBox(height: 12),
					_buildFilterPanel(isCompact),
					const SizedBox(height: 12),
					if (list.isEmpty)
						Container(
							width: double.infinity,
							padding: const EdgeInsets.all(16),
							decoration: BoxDecoration(
								color: const Color(0xFFF8FAFF),
								borderRadius: BorderRadius.circular(12),
								border: Border.all(color: const Color(0xFFDCE6F3)),
							),
							child: const Text(
								'No assignments match your current filters.',
								style: TextStyle(color: Color(0xFF64748B)),
							),
						)
					else
						...list.map(_buildAssignmentCard),
				],
			),
		);
	}

	Widget _buildFilterPanel(bool isCompact) {
		final searchField = TextField(
			controller: _searchController,
			onChanged: (value) {
				setState(() {
					_searchQuery = value;
				});
			},
			decoration: _inputDecoration('Search by assignment, employee, project')
					.copyWith(prefixIcon: const Icon(Icons.search_rounded)),
		);

		final departmentField = DropdownButtonFormField<String>(
			value: _selectedDepartment,
			items: _departments
					.map((department) =>
							DropdownMenuItem(value: department, child: Text(department)))
					.toList(),
			onChanged: (value) {
				if (value == null) {
					return;
				}
				setState(() {
					_selectedDepartment = value;
				});
			},
			decoration: _inputDecoration('Department'),
		);

		final statusField = DropdownButtonFormField<String>(
			value: _selectedStatus,
			items: _statusOptions
					.map((status) => DropdownMenuItem(value: status, child: Text(status)))
					.toList(),
			onChanged: (value) {
				if (value == null) {
					return;
				}
				setState(() {
					_selectedStatus = value;
				});
			},
			decoration: _inputDecoration('Status'),
		);

		if (isCompact) {
			return Column(
				children: [
					searchField,
					const SizedBox(height: 10),
					departmentField,
					const SizedBox(height: 10),
					statusField,
				],
			);
		}

		return Column(
			children: [
				searchField,
				const SizedBox(height: 10),
				Row(
					children: [
						Expanded(child: departmentField),
						const SizedBox(width: 10),
						Expanded(child: statusField),
					],
				),
			],
		);
	}

	Widget _buildAssignmentCard(_AssignmentRecord record) {
		return Container(
			width: double.infinity,
			margin: const EdgeInsets.only(bottom: 10),
			padding: const EdgeInsets.all(13),
			decoration: BoxDecoration(
				color: const Color(0xFFFAFCFF),
				borderRadius: BorderRadius.circular(12),
				border: Border.all(color: const Color(0xFFDCE6F3)),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							CircleAvatar(
								radius: 17,
								backgroundColor: const Color(0xFF1A73E8).withOpacity(0.12),
								child: Text(
									_initials(record.employeeName),
									style: const TextStyle(
										color: Color(0xFF1A73E8),
										fontWeight: FontWeight.w700,
									),
								),
							),
							const SizedBox(width: 10),
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											record.employeeName,
											style: const TextStyle(
												fontSize: 15,
												fontWeight: FontWeight.w700,
												color: Color(0xFF0F172A),
											),
										),
										const SizedBox(height: 2),
										Text(
											'${record.projectName}  •  ${record.role}',
											style: const TextStyle(
												color: Color(0xFF64748B),
												fontWeight: FontWeight.w500,
											),
										),
									],
								),
							),
							const SizedBox(width: 8),
							_statusChip(record.status),
						],
					),
					const SizedBox(height: 10),
					Wrap(
						spacing: 8,
						runSpacing: 8,
						children: [
							_detailChip(Icons.badge_outlined, record.id),
							_detailChip(Icons.calendar_today_outlined,
									'${_formatDate(record.startDate)} - ${_formatDate(record.dueDate)}'),
							_detailChip(Icons.pie_chart_outline_rounded,
									'Allocation ${record.allocation.toStringAsFixed(0)}%'),
							_detailChip(Icons.receipt_long_outlined,
									record.billable ? 'Billable' : 'Non-billable'),
						],
					),
					const SizedBox(height: 10),
					ClipRRect(
						borderRadius: BorderRadius.circular(8),
						child: LinearProgressIndicator(
							minHeight: 8,
							value: (record.allocation / 100).clamp(0, 1),
							color: _statusColor(record.status),
							backgroundColor: const Color(0xFFDCE6F3),
						),
					),
					const SizedBox(height: 10),
					Wrap(
						spacing: 8,
						runSpacing: 8,
						children: [
							OutlinedButton.icon(
								onPressed: () => _updateStatus(record, 'In Progress'),
								icon: const Icon(Icons.play_arrow_rounded, size: 16),
								label: const Text('In Progress'),
							),
							OutlinedButton.icon(
								onPressed: () => _updateStatus(record, 'Completed'),
								icon: const Icon(Icons.done_all_rounded, size: 16),
								label: const Text('Complete'),
							),
							OutlinedButton.icon(
								onPressed: () => _updateStatus(record, 'At Risk'),
								icon: const Icon(Icons.priority_high_rounded, size: 16),
								label: const Text('Mark Risk'),
							),
							TextButton.icon(
								onPressed: () => _removeAssignment(record),
								icon: const Icon(Icons.delete_outline_rounded,
										size: 16, color: Color(0xFFDB4437)),
								label: const Text(
									'Remove',
									style: TextStyle(color: Color(0xFFDB4437)),
								),
							),
						],
					),
				],
			),
		);
	}

	Widget _buildInsightsPanel(List<_AssignmentRecord> list) {
		final workloads = _workloads(list);
		final upcoming = [..._projects]..sort((a, b) => a.deadline.compareTo(b.deadline));

		return Column(
			children: [
				_panel(
					padding: const EdgeInsets.all(16),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							const Text(
								'Workload By Employee',
								style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
							),
							const SizedBox(height: 10),
							if (workloads.isEmpty)
								const Text(
									'No active workload data available.',
									style: TextStyle(color: Color(0xFF64748B)),
								)
							else
								...workloads.map(
									(item) => Container(
										margin: const EdgeInsets.only(bottom: 8),
										padding: const EdgeInsets.all(10),
										decoration: BoxDecoration(
											borderRadius: BorderRadius.circular(10),
											border: Border.all(color: const Color(0xFFE2E8F0)),
										),
										child: Row(
											children: [
												Expanded(
													child: Column(
														crossAxisAlignment: CrossAxisAlignment.start,
														children: [
															Text(
																item.employee,
																style: const TextStyle(fontWeight: FontWeight.w700),
															),
															const SizedBox(height: 2),
															Text(
																'${item.assignments} active assignments',
																style: const TextStyle(
																	color: Color(0xFF64748B),
																	fontSize: 12,
																),
															),
														],
													),
												),
												Text(
													'${item.utilization.toStringAsFixed(0)}%',
													style: TextStyle(
														color: item.utilization >= 80
																? const Color(0xFFDB4437)
																: const Color(0xFF1A73E8),
														fontWeight: FontWeight.w800,
													),
												),
											],
										),
									),
								),
						],
					),
				),
				const SizedBox(height: 14),
				_panel(
					padding: const EdgeInsets.all(16),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							const Text(
								'Upcoming Deadlines',
								style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
							),
							const SizedBox(height: 10),
							...upcoming.take(4).map(
								(project) => Container(
									margin: const EdgeInsets.only(bottom: 8),
									padding: const EdgeInsets.all(10),
									decoration: BoxDecoration(
										borderRadius: BorderRadius.circular(10),
										border: Border.all(color: const Color(0xFFE2E8F0)),
									),
									child: Row(
										children: [
											Expanded(
												child: Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														Text(
															project.name,
															maxLines: 1,
															overflow: TextOverflow.ellipsis,
															style: const TextStyle(fontWeight: FontWeight.w700),
														),
														const SizedBox(height: 2),
														Text(
															'${project.department}  •  ${project.priority}',
															style: const TextStyle(
																color: Color(0xFF64748B),
																fontSize: 12,
															),
														),
													],
												),
											),
											const SizedBox(width: 8),
											Text(
												_formatDate(project.deadline),
												style: const TextStyle(
													color: Color(0xFF0F172A),
													fontWeight: FontWeight.w700,
													fontSize: 12,
												),
											),
										],
									),
								),
							),
						],
					),
				),
			],
		);
	}

	List<_WorkloadItem> _workloads(List<_AssignmentRecord> list) {
		final active = list.where((item) => item.status != 'Completed');
		final map = <String, _WorkloadItem>{};

		for (final assignment in active) {
			final existing = map[assignment.employeeName];
			if (existing == null) {
				map[assignment.employeeName] = _WorkloadItem(
					employee: assignment.employeeName,
					assignments: 1,
					utilization: assignment.allocation,
				);
			} else {
				map[assignment.employeeName] = _WorkloadItem(
					employee: existing.employee,
					assignments: existing.assignments + 1,
					utilization: existing.utilization + assignment.allocation,
				);
			}
		}

		final values = map.values.toList();
		values.sort((a, b) => b.utilization.compareTo(a.utilization));
		return values.take(5).toList();
	}

	Widget _statusChip(String status) {
		final color = _statusColor(status);
		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
			decoration: BoxDecoration(
				color: color.withOpacity(0.12),
				borderRadius: BorderRadius.circular(999),
			),
			child: Text(
				status,
				style: TextStyle(
					fontSize: 12,
					color: color,
					fontWeight: FontWeight.w700,
				),
			),
		);
	}

	Color _statusColor(String status) {
		switch (status) {
			case 'Assigned':
				return const Color(0xFF1A73E8);
			case 'In Progress':
				return const Color(0xFF36B39C);
			case 'Completed':
				return const Color(0xFF0F9D58);
			case 'At Risk':
				return const Color(0xFFDB4437);
			default:
				return const Color(0xFF64748B);
		}
	}

	Widget _detailChip(IconData icon, String label) {
		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
			decoration: BoxDecoration(
				color: const Color(0xFFEFF3FB),
				borderRadius: BorderRadius.circular(999),
			),
			child: Row(
				mainAxisSize: MainAxisSize.min,
				children: [
					Icon(icon, size: 14, color: const Color(0xFF1A73E8)),
					const SizedBox(width: 5),
					Text(
						label,
						style: const TextStyle(
							fontSize: 12,
							fontWeight: FontWeight.w600,
							color: Color(0xFF374151),
						),
					),
				],
			),
		);
	}

	Widget _panel({required Widget child, EdgeInsets? padding}) {
		return Container(
			width: double.infinity,
			padding: padding ?? const EdgeInsets.all(12),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(16),
				border: Border.all(color: const Color(0xFFE3EBF5)),
				boxShadow: [
					BoxShadow(
						color: const Color(0xFF0B1E3A).withOpacity(0.04),
						blurRadius: 12,
						offset: const Offset(0, 6),
					),
				],
			),
			child: child,
		);
	}

	InputDecoration _inputDecoration(String hint) {
		return InputDecoration(
			hintText: hint,
			filled: true,
			fillColor: Colors.white,
			contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
			border: OutlineInputBorder(
				borderRadius: BorderRadius.circular(10),
				borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
			),
			enabledBorder: OutlineInputBorder(
				borderRadius: BorderRadius.circular(10),
				borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
			),
			focusedBorder: OutlineInputBorder(
				borderRadius: BorderRadius.circular(10),
				borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 1.2),
			),
		);
	}

	Widget _fieldLabel(String label) {
		return Padding(
			padding: const EdgeInsets.only(bottom: 6),
			child: Text(
				label,
				style: const TextStyle(
					color: Color(0xFF334155),
					fontWeight: FontWeight.w600,
				),
			),
		);
	}

	String _initials(String name) {
		final parts = name.trim().split(RegExp(r'\s+'));
		if (parts.length == 1 && parts.first.isNotEmpty) {
			return parts.first.substring(0, 1).toUpperCase();
		}
		if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
			return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
		}
		return 'NA';
	}

	String _formatDate(DateTime date) {
		const months = [
			'Jan',
			'Feb',
			'Mar',
			'Apr',
			'May',
			'Jun',
			'Jul',
			'Aug',
			'Sep',
			'Oct',
			'Nov',
			'Dec',
		];
		return '${months[date.month - 1]} ${date.day}, ${date.year}';
	}
}

class _EmployeeOption {
	final String id;
	final String name;
	final String department;
	final String title;
	final double utilization;

	const _EmployeeOption({
		required this.id,
		required this.name,
		required this.department,
		required this.title,
		required this.utilization,
	});
}

class _ProjectOption {
	final String id;
	final String name;
	final String department;
	final String manager;
	final String status;
	final String priority;
	final DateTime deadline;

	const _ProjectOption({
		required this.id,
		required this.name,
		required this.department,
		required this.manager,
		required this.status,
		required this.priority,
		required this.deadline,
	});
}

class _AssignmentRecord {
	final String id;
	final String employeeId;
	final String employeeName;
	final String employeeDepartment;
	final String projectId;
	final String projectName;
	final String role;
	final String status;
	final double allocation;
	final DateTime startDate;
	final DateTime dueDate;
	final bool billable;

	const _AssignmentRecord({
		required this.id,
		required this.employeeId,
		required this.employeeName,
		required this.employeeDepartment,
		required this.projectId,
		required this.projectName,
		required this.role,
		required this.status,
		required this.allocation,
		required this.startDate,
		required this.dueDate,
		required this.billable,
	});

	_AssignmentRecord copyWith({
		String? status,
	}) {
		return _AssignmentRecord(
			id: id,
			employeeId: employeeId,
			employeeName: employeeName,
			employeeDepartment: employeeDepartment,
			projectId: projectId,
			projectName: projectName,
			role: role,
			status: status ?? this.status,
			allocation: allocation,
			startDate: startDate,
			dueDate: dueDate,
			billable: billable,
		);
	}
}

class _MetricCardData {
	final String title;
	final String value;
	final String hint;
	final Color color;
	final IconData icon;

	const _MetricCardData({
		required this.title,
		required this.value,
		required this.hint,
		required this.color,
		required this.icon,
	});
}

class _WorkloadItem {
	final String employee;
	final int assignments;
	final double utilization;

	const _WorkloadItem({
		required this.employee,
		required this.assignments,
		required this.utilization,
	});
}
