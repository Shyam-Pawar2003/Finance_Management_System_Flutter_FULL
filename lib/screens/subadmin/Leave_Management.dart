import 'package:flutter/material.dart';

class SubAdminLeaveManagementPage extends StatefulWidget {
	const SubAdminLeaveManagementPage({super.key});

	@override
	State<SubAdminLeaveManagementPage> createState() =>
			_SubAdminLeaveManagementPageState();
}

class _SubAdminLeaveManagementPageState extends State<SubAdminLeaveManagementPage> {
	String _searchQuery = '';
	String _selectedDepartment = 'All';
	String _selectedStatus = 'All';
	String _selectedType = 'All';
	bool _onlyPending = false;

	late final TextEditingController _searchController;

	static const List<String> _statusOptions = [
		'All',
		'Pending',
		'Approved',
		'Rejected',
		'Escalated',
	];

	static const List<String> _typeOptions = [
		'All',
		'Sick Leave',
		'Casual Leave',
		'Annual Leave',
		'Work From Home',
		'Comp Off',
	];

	final List<_LeaveRequest> _requests = [
		_LeaveRequest(
			id: 'LV-2201',
			employeeId: 'EMP-002',
			employeeName: 'Neha Verma',
			department: 'HR',
			leaveType: 'Sick Leave',
			startDate: DateTime(2026, 3, 18),
			endDate: DateTime(2026, 3, 20),
			days: 3,
			status: 'Pending',
			priority: 'High',
			manager: 'R. Menon',
			reason: 'Medical recovery and doctor-advised rest.',
		),
		_LeaveRequest(
			id: 'LV-2202',
			employeeId: 'EMP-003',
			employeeName: 'Arjun Mehta',
			department: 'Operations',
			leaveType: 'Annual Leave',
			startDate: DateTime(2026, 3, 25),
			endDate: DateTime(2026, 3, 29),
			days: 5,
			status: 'Approved',
			priority: 'Normal',
			manager: 'P. Sinha',
			reason: 'Planned family travel with early project handover completed.',
		),
		_LeaveRequest(
			id: 'LV-2203',
			employeeId: 'EMP-005',
			employeeName: 'Karan Patel',
			department: 'Finance',
			leaveType: 'Comp Off',
			startDate: DateTime(2026, 3, 19),
			endDate: DateTime(2026, 3, 19),
			days: 1,
			status: 'Approved',
			priority: 'Normal',
			manager: 'A. Kapoor',
			reason: 'Compensatory leave against month-end extended support.',
		),
		_LeaveRequest(
			id: 'LV-2204',
			employeeId: 'EMP-007',
			employeeName: 'Ishita Rao',
			department: 'Legal',
			leaveType: 'Casual Leave',
			startDate: DateTime(2026, 3, 21),
			endDate: DateTime(2026, 3, 22),
			days: 2,
			status: 'Escalated',
			priority: 'High',
			manager: 'S. Bhatt',
			reason: 'Urgent personal commitment requiring immediate travel.',
		),
		_LeaveRequest(
			id: 'LV-2205',
			employeeId: 'EMP-008',
			employeeName: 'Rohan Das',
			department: 'Operations',
			leaveType: 'Work From Home',
			startDate: DateTime(2026, 3, 17),
			endDate: DateTime(2026, 3, 18),
			days: 2,
			status: 'Pending',
			priority: 'Normal',
			manager: 'P. Sinha',
			reason: 'Temporary mobility issue with unchanged shift coverage.',
		),
		_LeaveRequest(
			id: 'LV-2206',
			employeeId: 'EMP-004',
			employeeName: 'Sneha Iyer',
			department: 'HR',
			leaveType: 'Sick Leave',
			startDate: DateTime(2026, 3, 14),
			endDate: DateTime(2026, 3, 15),
			days: 2,
			status: 'Rejected',
			priority: 'Normal',
			manager: 'R. Menon',
			reason: 'Backdated request without prior manager intimation.',
		),
	];

	@override
	void initState() {
		super.initState();
		_searchController = TextEditingController();
	}

	@override
	void dispose() {
		_searchController.dispose();
		super.dispose();
	}

	List<String> get _departments {
		final values = _requests.map((request) => request.department).toSet().toList()
			..sort();
		return ['All', ...values];
	}

	List<_LeaveRequest> get _filteredRequests {
		final query = _searchQuery.trim().toLowerCase();

		final list = _requests.where((request) {
			final matchesSearch = query.isEmpty ||
					request.id.toLowerCase().contains(query) ||
					request.employeeName.toLowerCase().contains(query) ||
					request.leaveType.toLowerCase().contains(query) ||
					request.reason.toLowerCase().contains(query);

			final matchesDepartment =
					_selectedDepartment == 'All' || request.department == _selectedDepartment;
			final matchesStatus =
					_selectedStatus == 'All' || request.status == _selectedStatus;
			final matchesType = _selectedType == 'All' || request.leaveType == _selectedType;
			final matchesPending = !_onlyPending || request.status == 'Pending';

			return matchesSearch &&
					matchesDepartment &&
					matchesStatus &&
					matchesType &&
					matchesPending;
		}).toList();

		list.sort((a, b) => a.startDate.compareTo(b.startDate));
		return list;
	}

	int _countByStatus(List<_LeaveRequest> list, String status) {
		return list.where((request) => request.status == status).length;
	}

	double _averageLeaveDays(List<_LeaveRequest> list) {
		if (list.isEmpty) {
			return 0;
		}
		final total = list.fold<int>(0, (sum, item) => sum + item.days);
		return total / list.length;
	}

	int _onLeaveToday(List<_LeaveRequest> list) {
		final now = DateTime.now();
		final today = DateTime(now.year, now.month, now.day);
		return list.where((request) {
			if (request.status != 'Approved') {
				return false;
			}
			final start = DateTime(request.startDate.year, request.startDate.month, request.startDate.day);
			final end = DateTime(request.endDate.year, request.endDate.month, request.endDate.day);
			return !today.isBefore(start) && !today.isAfter(end);
		}).length;
	}

	void _updateStatus(_LeaveRequest request, String newStatus) {
		final index = _requests.indexWhere((item) => item.id == request.id);
		if (index == -1) {
			return;
		}
		setState(() {
			_requests[index] = _requests[index].copyWith(status: newStatus);
		});
		_showSnack('Request ${request.id} updated to $newStatus.');
	}

	void _sendBulkReminder() {
		final pending = _filteredRequests.where((request) => request.status == 'Pending').toList();
		if (pending.isEmpty) {
			_showSnack('No pending leave requests in current filters.', isError: true);
			return;
		}
		_showSnack('Reminder sent for ${pending.length} pending requests.');
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
						final requests = _filteredRequests;

						return SingleChildScrollView(
							padding: EdgeInsets.all(isCompact ? 14 : 20),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									_buildHeader(isCompact),
									const SizedBox(height: 16),
									_buildHeroCard(requests),
									const SizedBox(height: 16),
									_buildMetricGrid(width, requests),
									const SizedBox(height: 16),
									if (isNarrow) ...[
										_buildRequestsPanel(requests, isCompact),
										const SizedBox(height: 14),
										_buildInsightsPanel(requests),
									] else
										Row(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Expanded(
													flex: 3,
													child: _buildRequestsPanel(requests, false),
												),
												const SizedBox(width: 16),
												Expanded(
													flex: 2,
													child: _buildInsightsPanel(requests),
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
					'Leave Management',
					style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
				),
				SizedBox(height: 6),
				Text(
					'Review leave requests, resolve pending approvals, and monitor coverage impact across teams.',
					style: TextStyle(color: Color(0xFF5F6368)),
				),
			],
		);

		final actions = Wrap(
			spacing: 8,
			runSpacing: 8,
			children: [
				OutlinedButton.icon(
					onPressed: _sendBulkReminder,
					icon: const Icon(Icons.notifications_active_outlined, size: 18),
					label: const Text('Send Reminder'),
					style: OutlinedButton.styleFrom(
						foregroundColor: const Color(0xFF0F172A),
						side: const BorderSide(color: Color(0xFFD6DEE8)),
					),
				),
				FilledButton.icon(
					onPressed: () {
						setState(() {
							_searchQuery = '';
							_searchController.clear();
							_selectedDepartment = 'All';
							_selectedStatus = 'All';
							_selectedType = 'All';
							_onlyPending = false;
						});
					},
					icon: const Icon(Icons.restart_alt_rounded, size: 18),
					label: const Text('Reset Filters'),
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

	Widget _buildHeroCard(List<_LeaveRequest> requests) {
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
									'Leave Approval Control',
									style: TextStyle(
										color: Colors.white,
										fontSize: 22,
										fontWeight: FontWeight.w800,
									),
								),
								SizedBox(height: 8),
								Text(
									'Balance employee wellness with operational continuity using fast, transparent leave decisions.',
									style: TextStyle(color: Colors.white70, height: 1.4),
								),
							],
						),
					),
					_heroBadge(Icons.pending_actions_rounded,
							'${_countByStatus(requests, 'Pending')} Pending'),
					_heroBadge(Icons.check_circle_outline_rounded,
							'${_countByStatus(requests, 'Approved')} Approved'),
					_heroBadge(Icons.event_busy_outlined,
							'${_onLeaveToday(requests)} On Leave Today'),
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

	Widget _buildMetricGrid(double width, List<_LeaveRequest> requests) {
		int columns = 4;
		if (width < 1180) {
			columns = 2;
		}
		if (width < 700) {
			columns = 1;
		}

		final metrics = [
			_LeaveMetricCard(
				title: 'Pending',
				value: '${_countByStatus(requests, 'Pending')}',
				hint: 'Need immediate decision',
				color: const Color(0xFFDB4437),
				icon: Icons.error_outline_rounded,
			),
			_LeaveMetricCard(
				title: 'Approved',
				value: '${_countByStatus(requests, 'Approved')}',
				hint: 'Accepted in selected scope',
				color: const Color(0xFF0F9D58),
				icon: Icons.verified_rounded,
			),
			_LeaveMetricCard(
				title: 'Avg Duration',
				value: '${_averageLeaveDays(requests).toStringAsFixed(1)} days',
				hint: 'Per leave request',
				color: const Color(0xFF1A73E8),
				icon: Icons.timelapse_rounded,
			),
			_LeaveMetricCard(
				title: 'Escalated',
				value: '${_countByStatus(requests, 'Escalated')}',
				hint: 'Manager escalation queue',
				color: const Color(0xFFF29900),
				icon: Icons.flag_outlined,
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

	Widget _buildRequestsPanel(List<_LeaveRequest> requests, bool isCompact) {
		return _panel(
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					const Text(
						'Leave Requests',
						style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
					),
					const SizedBox(height: 6),
					const Text(
						'Filter requests and take approval actions without leaving this panel.',
						style: TextStyle(color: Color(0xFF64748B)),
					),
					const SizedBox(height: 12),
					_buildFilterPanel(isCompact),
					const SizedBox(height: 12),
					if (requests.isEmpty)
						Container(
							width: double.infinity,
							padding: const EdgeInsets.all(16),
							decoration: BoxDecoration(
								color: const Color(0xFFF8FAFF),
								borderRadius: BorderRadius.circular(12),
								border: Border.all(color: const Color(0xFFDCE6F3)),
							),
							child: const Text(
								'No leave requests match the selected filters.',
								style: TextStyle(color: Color(0xFF64748B)),
							),
						)
					else
						...requests.map(_buildRequestCard),
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
			decoration: _inputDecoration('Search by employee, request ID, type').copyWith(
				prefixIcon: const Icon(Icons.search_rounded),
			),
		);

		final departmentField = DropdownButtonFormField<String>(
			value: _selectedDepartment,
			items: _departments
					.map((department) => DropdownMenuItem(value: department, child: Text(department)))
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

		final typeField = DropdownButtonFormField<String>(
			value: _selectedType,
			items: _typeOptions
					.map((type) => DropdownMenuItem(value: type, child: Text(type)))
					.toList(),
			onChanged: (value) {
				if (value == null) {
					return;
				}
				setState(() {
					_selectedType = value;
				});
			},
			decoration: _inputDecoration('Leave Type'),
		);

		if (isCompact) {
			return Column(
				children: [
					searchField,
					const SizedBox(height: 10),
					departmentField,
					const SizedBox(height: 10),
					statusField,
					const SizedBox(height: 10),
					typeField,
					const SizedBox(height: 6),
					SwitchListTile(
						contentPadding: EdgeInsets.zero,
						value: _onlyPending,
						onChanged: (value) {
							setState(() {
								_onlyPending = value;
							});
						},
						title: const Text('Only pending requests'),
						dense: true,
					),
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
						const SizedBox(width: 10),
						Expanded(child: typeField),
					],
				),
				const SizedBox(height: 6),
				SwitchListTile(
					contentPadding: EdgeInsets.zero,
					value: _onlyPending,
					onChanged: (value) {
						setState(() {
							_onlyPending = value;
						});
					},
					title: const Text('Only pending requests'),
					dense: true,
				),
			],
		);
	}

	Widget _buildRequestCard(_LeaveRequest request) {
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
									_initials(request.employeeName),
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
											request.employeeName,
											style: const TextStyle(
												fontSize: 15,
												fontWeight: FontWeight.w700,
												color: Color(0xFF0F172A),
											),
										),
										const SizedBox(height: 2),
										Text(
											'${request.id}  •  ${request.department}  •  ${request.leaveType}',
											style: const TextStyle(
												color: Color(0xFF64748B),
												fontWeight: FontWeight.w500,
											),
										),
									],
								),
							),
							const SizedBox(width: 8),
							_chip(request.status, _statusColor(request.status)),
						],
					),
					const SizedBox(height: 10),
					Wrap(
						spacing: 8,
						runSpacing: 8,
						children: [
							_detailChip(Icons.calendar_today_outlined,
									'${_formatDate(request.startDate)} - ${_formatDate(request.endDate)}'),
							_detailChip(Icons.timelapse_rounded, '${request.days} day(s)'),
							_detailChip(Icons.person_outline_rounded, request.manager),
							_detailChip(Icons.flag_outlined, request.priority),
						],
					),
					const SizedBox(height: 8),
					Text(
						request.reason,
						style: const TextStyle(
							color: Color(0xFF64748B),
							fontSize: 12,
						),
					),
					if (request.status == 'Pending' || request.status == 'Escalated') ...[
						const SizedBox(height: 10),
						Wrap(
							spacing: 8,
							runSpacing: 8,
							children: [
								OutlinedButton.icon(
									onPressed: () => _updateStatus(request, 'Approved'),
									icon: const Icon(Icons.check_rounded, size: 16),
									label: const Text('Approve'),
								),
								OutlinedButton.icon(
									onPressed: () => _updateStatus(request, 'Rejected'),
									icon: const Icon(Icons.close_rounded, size: 16),
									label: const Text('Reject'),
								),
								OutlinedButton.icon(
									onPressed: () => _updateStatus(request, 'Escalated'),
									icon: const Icon(Icons.priority_high_rounded, size: 16),
									label: const Text('Escalate'),
								),
							],
						),
					],
				],
			),
		);
	}

	Widget _buildInsightsPanel(List<_LeaveRequest> requests) {
		final upcoming = [...requests]..sort((a, b) => a.startDate.compareTo(b.startDate));
		final typeSplit = _typeSplit(requests);

		return Column(
			children: [
				_panel(
					padding: const EdgeInsets.all(16),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							const Text(
								'Leave Type Split',
								style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
							),
							const SizedBox(height: 10),
							if (typeSplit.isEmpty)
								const Text(
									'No leave distribution available.',
									style: TextStyle(color: Color(0xFF64748B)),
								)
							else
								...typeSplit.map(
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
													child: Text(
														item.type,
														style: const TextStyle(fontWeight: FontWeight.w600),
													),
												),
												Text(
													'${item.count}',
													style: const TextStyle(
														color: Color(0xFF36B39C),
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
								'Upcoming Leaves',
								style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
							),
							const SizedBox(height: 10),
							if (upcoming.isEmpty)
								const Text(
									'No upcoming leaves.',
									style: TextStyle(color: Color(0xFF64748B)),
								)
							else
								...upcoming.take(4).map(
									(request) => Container(
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
																request.employeeName,
																maxLines: 1,
																overflow: TextOverflow.ellipsis,
																style: const TextStyle(fontWeight: FontWeight.w700),
															),
															const SizedBox(height: 2),
															Text(
																request.leaveType,
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
													_formatDate(request.startDate),
													style: const TextStyle(
														fontWeight: FontWeight.w700,
														color: Color(0xFF0F172A),
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

	List<_LeaveTypeCount> _typeSplit(List<_LeaveRequest> requests) {
		final counts = <String, int>{};
		for (final request in requests) {
			counts.update(request.leaveType, (value) => value + 1, ifAbsent: () => 1);
		}
		final rows = counts.entries
				.map((entry) => _LeaveTypeCount(entry.key, entry.value))
				.toList();
		rows.sort((a, b) => b.count.compareTo(a.count));
		return rows;
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

	Color _statusColor(String status) {
		switch (status) {
			case 'Approved':
				return const Color(0xFF0F9D58);
			case 'Pending':
				return const Color(0xFFF29900);
			case 'Escalated':
				return const Color(0xFFDB4437);
			case 'Rejected':
				return const Color(0xFF7C3AED);
			default:
				return const Color(0xFF64748B);
		}
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

	String _formatDate(DateTime value) {
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
		return '${months[value.month - 1]} ${value.day}';
	}
}

class _LeaveRequest {
	const _LeaveRequest({
		required this.id,
		required this.employeeId,
		required this.employeeName,
		required this.department,
		required this.leaveType,
		required this.startDate,
		required this.endDate,
		required this.days,
		required this.status,
		required this.priority,
		required this.manager,
		required this.reason,
	});

	final String id;
	final String employeeId;
	final String employeeName;
	final String department;
	final String leaveType;
	final DateTime startDate;
	final DateTime endDate;
	final int days;
	final String status;
	final String priority;
	final String manager;
	final String reason;

	_LeaveRequest copyWith({
		String? status,
	}) {
		return _LeaveRequest(
			id: id,
			employeeId: employeeId,
			employeeName: employeeName,
			department: department,
			leaveType: leaveType,
			startDate: startDate,
			endDate: endDate,
			days: days,
			status: status ?? this.status,
			priority: priority,
			manager: manager,
			reason: reason,
		);
	}
}

class _LeaveMetricCard {
	const _LeaveMetricCard({
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

class _LeaveTypeCount {
	const _LeaveTypeCount(this.type, this.count);

	final String type;
	final int count;
}
