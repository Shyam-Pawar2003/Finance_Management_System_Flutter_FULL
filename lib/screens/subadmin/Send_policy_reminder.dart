import 'package:flutter/material.dart';

class SubAdminSendPolicyReminderPage extends StatefulWidget {
	const SubAdminSendPolicyReminderPage({super.key});

	@override
	State<SubAdminSendPolicyReminderPage> createState() =>
			_SubAdminSendPolicyReminderPageState();
}

class _SubAdminSendPolicyReminderPageState
		extends State<SubAdminSendPolicyReminderPage> {
	String _selectedPolicy = 'Attendance Policy Acknowledgement';
	String _selectedDepartment = 'All';
	String _selectedStatus = 'All';
	String _selectedPriority = 'Normal';

	bool _sendEmail = true;
	bool _sendInApp = true;
	bool _sendSms = false;
	bool _onlyPending = true;

	late final TextEditingController _searchController;
	late final TextEditingController _subjectController;
	late final TextEditingController _messageController;

	String _searchQuery = '';

	static const List<String> _policyOptions = [
		'Attendance Policy Acknowledgement',
		'Code of Conduct Reminder',
		'Data Privacy Compliance Notice',
		'Expense Policy Reminder',
	];

	static const List<String> _statusOptions = [
		'All',
		'Active',
		'On Leave',
		'Probation',
	];

	static const List<String> _priorityOptions = [
		'Low',
		'Normal',
		'High',
	];

	final List<_ReminderEmployee> _employees = const [
		_ReminderEmployee(
			id: 'EMP-001',
			name: 'Rahul Sharma',
			role: 'Senior Accountant',
			department: 'Finance',
			status: 'Active',
			manager: 'A. Kapoor',
			email: 'rahul.sharma@company.com',
			lastReminderDays: 14,
			policyPending: true,
		),
		_ReminderEmployee(
			id: 'EMP-002',
			name: 'Neha Verma',
			role: 'HR Executive',
			department: 'HR',
			status: 'On Leave',
			manager: 'R. Menon',
			email: 'neha.verma@company.com',
			lastReminderDays: 7,
			policyPending: true,
		),
		_ReminderEmployee(
			id: 'EMP-003',
			name: 'Arjun Mehta',
			role: 'Operations Analyst',
			department: 'Operations',
			status: 'Active',
			manager: 'P. Sinha',
			email: 'arjun.mehta@company.com',
			lastReminderDays: 21,
			policyPending: false,
		),
		_ReminderEmployee(
			id: 'EMP-004',
			name: 'Sneha Iyer',
			role: 'Recruitment Coordinator',
			department: 'HR',
			status: 'Probation',
			manager: 'R. Menon',
			email: 'sneha.iyer@company.com',
			lastReminderDays: 0,
			policyPending: true,
		),
		_ReminderEmployee(
			id: 'EMP-005',
			name: 'Karan Patel',
			role: 'Payroll Specialist',
			department: 'Finance',
			status: 'Active',
			manager: 'A. Kapoor',
			email: 'karan.patel@company.com',
			lastReminderDays: 10,
			policyPending: true,
		),
		_ReminderEmployee(
			id: 'EMP-006',
			name: 'Maya Nair',
			role: 'Data Associate',
			department: 'Operations',
			status: 'Active',
			manager: 'P. Sinha',
			email: 'maya.nair@company.com',
			lastReminderDays: 4,
			policyPending: false,
		),
		_ReminderEmployee(
			id: 'EMP-007',
			name: 'Ishita Rao',
			role: 'Compliance Analyst',
			department: 'Legal',
			status: 'Active',
			manager: 'S. Bhatt',
			email: 'ishita.rao@company.com',
			lastReminderDays: 18,
			policyPending: true,
		),
		_ReminderEmployee(
			id: 'EMP-008',
			name: 'Rohan Das',
			role: 'Support Executive',
			department: 'Operations',
			status: 'Probation',
			manager: 'P. Sinha',
			email: 'rohan.das@company.com',
			lastReminderDays: 2,
			policyPending: true,
		),
	];

	final List<_ReminderRun> _recentRuns = [
		_ReminderRun(
			title: 'Code of Conduct Reminder',
			audience: 'HR and Legal',
			channel: 'Email + In-app',
			sentBy: 'Shyam Patel',
			timestamp: DateTime(2026, 3, 16, 9, 20),
			recipientCount: 18,
			status: 'Delivered',
		),
		_ReminderRun(
			title: 'Attendance Policy Acknowledgement',
			audience: 'All pending employees',
			channel: 'Email',
			sentBy: 'Shyam Patel',
			timestamp: DateTime(2026, 3, 15, 16, 40),
			recipientCount: 26,
			status: 'Completed',
		),
		_ReminderRun(
			title: 'Expense Policy Reminder',
			audience: 'Finance team',
			channel: 'In-app',
			sentBy: 'Shyam Patel',
			timestamp: DateTime(2026, 3, 14, 11, 10),
			recipientCount: 9,
			status: 'Completed',
		),
	];

	@override
	void initState() {
		super.initState();
		_searchController = TextEditingController();
		_subjectController = TextEditingController(
			text: 'Reminder: Please review and acknowledge the updated policy',
		);
		_messageController = TextEditingController(
			text:
					'Please review the latest policy update and submit your acknowledgement today. Reach out to your manager or People Operations if you need clarification.',
		);
	}

	@override
	void dispose() {
		_searchController.dispose();
		_subjectController.dispose();
		_messageController.dispose();
		super.dispose();
	}

	List<String> get _departments {
		final values = _employees.map((employee) => employee.department).toSet().toList()
			..sort();
		return ['All', ...values];
	}

	List<_ReminderEmployee> get _filteredEmployees {
		final query = _searchQuery.trim().toLowerCase();

		return _employees.where((employee) {
			final matchesSearch = query.isEmpty ||
					employee.id.toLowerCase().contains(query) ||
					employee.name.toLowerCase().contains(query) ||
					employee.role.toLowerCase().contains(query) ||
					employee.email.toLowerCase().contains(query);

			final matchesDepartment =
					_selectedDepartment == 'All' || employee.department == _selectedDepartment;
			final matchesStatus =
					_selectedStatus == 'All' || employee.status == _selectedStatus;
			final matchesPending = !_onlyPending || employee.policyPending;

			return matchesSearch && matchesDepartment && matchesStatus && matchesPending;
		}).toList();
	}

	int _pendingCount(List<_ReminderEmployee> employees) {
		return employees.where((employee) => employee.policyPending).length;
	}

	double _recentReminderAverage(List<_ReminderEmployee> employees) {
		if (employees.isEmpty) {
			return 0;
		}
		final total = employees.fold<int>(0, (sum, item) => sum + item.lastReminderDays);
		return total / employees.length;
	}

	void _sendReminder() {
		final recipients = _filteredEmployees;
		if (recipients.isEmpty) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text('No employees match the selected reminder filters.'),
					backgroundColor: Color(0xFFDB4437),
				),
			);
			return;
		}

		final channels = <String>[];
		if (_sendEmail) {
			channels.add('Email');
		}
		if (_sendInApp) {
			channels.add('In-app');
		}
		if (_sendSms) {
			channels.add('SMS');
		}

		if (channels.isEmpty) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text('Select at least one delivery channel.'),
					backgroundColor: Color(0xFFDB4437),
				),
			);
			return;
		}

		final audience = _selectedDepartment == 'All'
				? (_onlyPending ? 'All pending employees' : 'All employees')
				: _selectedDepartment;

		setState(() {
			_recentRuns.insert(
				0,
				_ReminderRun(
					title: _selectedPolicy,
					audience: audience,
					channel: channels.join(' + '),
					sentBy: 'Shyam Patel',
					timestamp: DateTime.now(),
					recipientCount: recipients.length,
					status: 'Delivered',
				),
			);
		});

		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text('Reminder sent to ${recipients.length} employees.'),
				backgroundColor: const Color(0xFF1A73E8),
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
						final employees = _filteredEmployees;

						return SingleChildScrollView(
							padding: EdgeInsets.all(isCompact ? 14 : 20),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									_buildHeader(isCompact),
									const SizedBox(height: 16),
									_buildHeroCard(employees),
									const SizedBox(height: 16),
									_buildMetricGrid(width, employees),
									const SizedBox(height: 16),
									if (isNarrow) ...[
										_buildComposerPanel(isCompact),
										const SizedBox(height: 14),
										_buildRecipientsPanel(employees),
										const SizedBox(height: 14),
										_buildHistoryPanel(),
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
															_buildHistoryPanel(),
														],
													),
												),
												const SizedBox(width: 16),
												Expanded(
													flex: 3,
													child: _buildRecipientsPanel(employees),
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
					'Send Policy Reminder',
					style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
				),
				SizedBox(height: 6),
				Text(
					'Target employees by department and status, customize the message, and track recent reminder runs.',
					style: TextStyle(color: Color(0xFF5F6368)),
				),
			],
		);

		final actions = Wrap(
			spacing: 8,
			runSpacing: 8,
			children: [
				OutlinedButton.icon(
					onPressed: () {
						setState(() {
							_selectedPolicy = _policyOptions.first;
							_selectedDepartment = 'All';
							_selectedStatus = 'All';
							_selectedPriority = 'Normal';
							_sendEmail = true;
							_sendInApp = true;
							_sendSms = false;
							_onlyPending = true;
							_searchQuery = '';
							_searchController.clear();
							_subjectController.text =
									'Reminder: Please review and acknowledge the updated policy';
							_messageController.text =
									'Please review the latest policy update and submit your acknowledgement today. Reach out to your manager or People Operations if you need clarification.';
						});
					},
					icon: const Icon(Icons.restart_alt_rounded, size: 18),
					label: const Text('Reset'),
					style: OutlinedButton.styleFrom(
						foregroundColor: const Color(0xFF0F172A),
						side: const BorderSide(color: Color(0xFFD6DEE8)),
					),
				),
				FilledButton.icon(
					onPressed: _sendReminder,
					icon: const Icon(Icons.send_rounded, size: 18),
					label: const Text('Send Reminder'),
					style: FilledButton.styleFrom(
						backgroundColor: const Color(0xFF1A73E8),
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

	Widget _buildHeroCard(List<_ReminderEmployee> employees) {
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
				children: [
					const SizedBox(
						width: 380,
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									'Policy Communication Hub',
									style: TextStyle(
										color: Colors.white,
										fontSize: 22,
										fontWeight: FontWeight.w800,
									),
								),
								SizedBox(height: 8),
								Text(
									'Keep policy acknowledgements on track with targeted reminder campaigns and clear follow-up visibility.',
									style: TextStyle(color: Colors.white70, height: 1.4),
								),
							],
						),
					),
					_heroBadge(Icons.people_outline_rounded,
							'${employees.length} Employees In Scope'),
					_heroBadge(Icons.pending_actions_outlined,
							'${_pendingCount(employees)} Pending Acknowledgements'),
					_heroBadge(Icons.history_toggle_off_rounded,
							'${_recentReminderAverage(employees).toStringAsFixed(0)} Avg Days Since Last Reminder'),
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

	Widget _buildMetricGrid(double width, List<_ReminderEmployee> employees) {
		int columns = 4;
		if (width < 1180) {
			columns = 2;
		}
		if (width < 700) {
			columns = 1;
		}

		final metrics = [
			_ReminderMetricCard(
				title: 'Pending',
				value: '${_pendingCount(employees)}',
				hint: 'Still need acknowledgement',
				color: const Color(0xFFDB4437),
				icon: Icons.error_outline_rounded,
			),
			_ReminderMetricCard(
				title: 'Active Scope',
				value: '${employees.where((item) => item.status == 'Active').length}',
				hint: 'Eligible active employees',
				color: const Color(0xFF0F9D58),
				icon: Icons.verified_user_outlined,
			),
			_ReminderMetricCard(
				title: 'Priority',
				value: _selectedPriority,
				hint: 'Current send urgency',
				color: const Color(0xFF1A73E8),
				icon: Icons.flag_outlined,
			),
			_ReminderMetricCard(
				title: 'Recent Runs',
				value: '${_recentRuns.length}',
				hint: 'Visible delivery history',
				color: const Color(0xFFF29900),
				icon: Icons.outbox_outlined,
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
									Flexible(
										child: Text(
											metric.title,
											maxLines: 1,
											overflow: TextOverflow.ellipsis,
											textAlign: TextAlign.right,
											style: const TextStyle(
												fontSize: 12,
												color: Color(0xFF5F6368),
												fontWeight: FontWeight.w600,
											),
										),
									),
								],
							),
							const SizedBox(height: 10),
							Text(
								metric.value,
								style: const TextStyle(
									fontSize: 24,
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
						'Reminder Composer',
						style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
					),
					const SizedBox(height: 6),
					const Text(
						'Choose the policy, audience, message tone, and delivery channels.',
						style: TextStyle(color: Color(0xFF64748B)),
					),
					const SizedBox(height: 14),
					_fieldLabel('Policy Template'),
					DropdownButtonFormField<String>(
						value: _selectedPolicy,
						items: _policyOptions
								.map((item) => DropdownMenuItem(value: item, child: Text(item)))
								.toList(),
						onChanged: (value) {
							if (value == null) {
								return;
							}
							setState(() {
								_selectedPolicy = value;
							});
						},
						decoration: _inputDecoration('Select policy'),
					),
					const SizedBox(height: 12),
					if (isCompact) ...[
						_departmentField(),
						const SizedBox(height: 12),
						_statusField(),
						const SizedBox(height: 12),
						_priorityField(),
					] else
						Row(
							children: [
								Expanded(child: _departmentField()),
								const SizedBox(width: 10),
								Expanded(child: _statusField()),
								const SizedBox(width: 10),
								Expanded(child: _priorityField()),
							],
						),
					const SizedBox(height: 12),
					_fieldLabel('Subject'),
					TextField(
						controller: _subjectController,
						decoration: _inputDecoration('Reminder subject'),
					),
					const SizedBox(height: 12),
					_fieldLabel('Message'),
					TextField(
						controller: _messageController,
						minLines: 4,
						maxLines: 5,
						decoration: _inputDecoration('Reminder message body'),
					),
					const SizedBox(height: 8),
					SwitchListTile(
						contentPadding: EdgeInsets.zero,
						value: _onlyPending,
						onChanged: (value) {
							setState(() {
								_onlyPending = value;
							});
						},
						title: const Text('Only send to employees with pending acknowledgement'),
						dense: true,
					),
					CheckboxListTile(
						contentPadding: EdgeInsets.zero,
						controlAffinity: ListTileControlAffinity.leading,
						value: _sendEmail,
						onChanged: (value) {
							setState(() {
								_sendEmail = value ?? false;
							});
						},
						title: const Text('Email'),
						dense: true,
					),
					CheckboxListTile(
						contentPadding: EdgeInsets.zero,
						controlAffinity: ListTileControlAffinity.leading,
						value: _sendInApp,
						onChanged: (value) {
							setState(() {
								_sendInApp = value ?? false;
							});
						},
						title: const Text('In-app notification'),
						dense: true,
					),
					CheckboxListTile(
						contentPadding: EdgeInsets.zero,
						controlAffinity: ListTileControlAffinity.leading,
						value: _sendSms,
						onChanged: (value) {
							setState(() {
								_sendSms = value ?? false;
							});
						},
						title: const Text('SMS escalation'),
						dense: true,
					),
					const SizedBox(height: 6),
					SizedBox(
						width: double.infinity,
						child: FilledButton.icon(
							onPressed: _sendReminder,
							icon: const Icon(Icons.send_rounded, size: 18),
							label: const Text('Send Policy Reminder'),
							style: FilledButton.styleFrom(
								backgroundColor: const Color(0xFF1A73E8),
								padding: const EdgeInsets.symmetric(vertical: 13),
							),
						),
					),
				],
			),
		);
	}

	Widget _departmentField() {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				_fieldLabel('Department'),
				DropdownButtonFormField<String>(
					value: _selectedDepartment,
					items: _departments
							.map((item) => DropdownMenuItem(value: item, child: Text(item)))
							.toList(),
					onChanged: (value) {
						if (value == null) {
							return;
						}
						setState(() {
							_selectedDepartment = value;
						});
					},
					decoration: _inputDecoration('Select department'),
				),
			],
		);
	}

	Widget _statusField() {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				_fieldLabel('Status'),
				DropdownButtonFormField<String>(
					value: _selectedStatus,
					items: _statusOptions
							.map((item) => DropdownMenuItem(value: item, child: Text(item)))
							.toList(),
					onChanged: (value) {
						if (value == null) {
							return;
						}
						setState(() {
							_selectedStatus = value;
						});
					},
					decoration: _inputDecoration('Select status'),
				),
			],
		);
	}

	Widget _priorityField() {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				_fieldLabel('Priority'),
				DropdownButtonFormField<String>(
					value: _selectedPriority,
					items: _priorityOptions
							.map((item) => DropdownMenuItem(value: item, child: Text(item)))
							.toList(),
					onChanged: (value) {
						if (value == null) {
							return;
						}
						setState(() {
							_selectedPriority = value;
						});
					},
					decoration: _inputDecoration('Select priority'),
				),
			],
		);
	}

	Widget _buildRecipientsPanel(List<_ReminderEmployee> employees) {
		return _panel(
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					const Text(
						'Recipients Preview',
						style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
					),
					const SizedBox(height: 6),
					const Text(
						'Search and review employees who will receive the reminder.',
						style: TextStyle(color: Color(0xFF64748B)),
					),
					const SizedBox(height: 12),
					TextField(
						controller: _searchController,
						onChanged: (value) {
							setState(() {
								_searchQuery = value;
							});
						},
						decoration: _inputDecoration('Search by employee, role, or email')
								.copyWith(prefixIcon: const Icon(Icons.search_rounded)),
					),
					const SizedBox(height: 12),
					if (employees.isEmpty)
						Container(
							width: double.infinity,
							padding: const EdgeInsets.all(16),
							decoration: BoxDecoration(
								color: const Color(0xFFF8FAFF),
								borderRadius: BorderRadius.circular(12),
								border: Border.all(color: const Color(0xFFDCE6F3)),
							),
							child: const Text(
								'No employees match the selected reminder filters.',
								style: TextStyle(color: Color(0xFF64748B)),
							),
						)
					else
						...employees.map(_buildRecipientCard),
				],
			),
		);
	}

	Widget _buildRecipientCard(_ReminderEmployee employee) {
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
									_initials(employee.name),
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
											employee.name,
											style: const TextStyle(
												fontSize: 15,
												fontWeight: FontWeight.w700,
												color: Color(0xFF0F172A),
											),
										),
										const SizedBox(height: 2),
										Text(
											'${employee.role}  •  ${employee.department}',
											style: const TextStyle(
												color: Color(0xFF64748B),
												fontWeight: FontWeight.w500,
											),
										),
									],
								),
							),
							const SizedBox(width: 8),
							_chip(
								employee.policyPending ? 'Pending' : 'Complete',
								employee.policyPending
										? const Color(0xFFDB4437)
										: const Color(0xFF0F9D58),
							),
						],
					),
					const SizedBox(height: 10),
					Wrap(
						spacing: 8,
						runSpacing: 8,
						children: [
							_detailChip(Icons.badge_outlined, employee.id),
							_detailChip(Icons.person_outline_rounded, employee.manager),
							_detailChip(
								Icons.history_rounded,
								employee.lastReminderDays == 0
										? 'No prior reminder'
										: '${employee.lastReminderDays} days ago',
							),
							_detailChip(Icons.email_outlined, employee.status),
						],
					),
					const SizedBox(height: 8),
					Text(
						employee.email,
						style: const TextStyle(
							color: Color(0xFF64748B),
							fontSize: 12,
						),
					),
				],
			),
		);
	}

	Widget _buildHistoryPanel() {
		return _panel(
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					const Text(
						'Recent Reminder Runs',
						style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
					),
					const SizedBox(height: 6),
					const Text(
						'Recent policy reminder campaigns and delivery status for audit visibility.',
						style: TextStyle(color: Color(0xFF64748B)),
					),
					const SizedBox(height: 12),
					..._recentRuns.take(5).map(
								(run) => Container(
									width: double.infinity,
									margin: const EdgeInsets.only(bottom: 10),
									padding: const EdgeInsets.all(12),
									decoration: BoxDecoration(
										color: const Color(0xFFFAFCFF),
										borderRadius: BorderRadius.circular(12),
										border: Border.all(color: const Color(0xFFDCE6F3)),
									),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Row(
												children: [
													Expanded(
														child: Text(
															run.title,
															style: const TextStyle(
																fontWeight: FontWeight.w700,
																color: Color(0xFF0F172A),
															),
														),
													),
													_chip(run.status, const Color(0xFF0F9D58)),
												],
											),
											const SizedBox(height: 6),
											Text(
												'${run.channel}  •  ${run.audience}',
												style: const TextStyle(color: Color(0xFF64748B)),
											),
											const SizedBox(height: 4),
											Text(
												'${run.recipientCount} recipients  •  ${_formatDateTime(run.timestamp)}',
												style: const TextStyle(
													color: Color(0xFF64748B),
													fontSize: 12,
												),
											),
										],
									),
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

	Widget _chip(String label, Color color) {
		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
			decoration: BoxDecoration(
				color: color.withOpacity(0.12),
				borderRadius: BorderRadius.circular(999),
			),
			child: Text(
				label,
				style: TextStyle(
					color: color,
					fontWeight: FontWeight.w700,
					fontSize: 12,
				),
			),
		);
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

	String _formatDateTime(DateTime value) {
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
		final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
		final minute = value.minute.toString().padLeft(2, '0');
		final period = value.hour >= 12 ? 'PM' : 'AM';
		return '${months[value.month - 1]} ${value.day}, ${value.year} • $hour:$minute $period';
	}
}

class _ReminderEmployee {
	const _ReminderEmployee({
		required this.id,
		required this.name,
		required this.role,
		required this.department,
		required this.status,
		required this.manager,
		required this.email,
		required this.lastReminderDays,
		required this.policyPending,
	});

	final String id;
	final String name;
	final String role;
	final String department;
	final String status;
	final String manager;
	final String email;
	final int lastReminderDays;
	final bool policyPending;
}

class _ReminderRun {
	const _ReminderRun({
		required this.title,
		required this.audience,
		required this.channel,
		required this.sentBy,
		required this.timestamp,
		required this.recipientCount,
		required this.status,
	});

	final String title;
	final String audience;
	final String channel;
	final String sentBy;
	final DateTime timestamp;
	final int recipientCount;
	final String status;
}

class _ReminderMetricCard {
	const _ReminderMetricCard({
		required this.title,
		required this.value,
		required this.hint,
		required this.color,
		required this.icon,
	});

	final String title;
	final String value;
	final String hint;
	final Color color;
	final IconData icon;
}
