import 'package:flutter/material.dart';

class SubAdminExportEmployeeReportPage extends StatefulWidget {
	const SubAdminExportEmployeeReportPage({super.key});

	@override
	State<SubAdminExportEmployeeReportPage> createState() =>
			_SubAdminExportEmployeeReportPageState();
}

class _SubAdminExportEmployeeReportPageState
		extends State<SubAdminExportEmployeeReportPage> {
	String _selectedReportType = 'Workforce Summary';
	String _selectedDepartment = 'All';
	String _selectedStatus = 'All';
	String _selectedFormat = 'PDF';

	bool _includeAttendance = true;
	bool _includeProjects = true;
	bool _includeCompensation = false;
	bool _includeContactInfo = true;
	bool _onlyFilteredEmployees = true;

	late final TextEditingController _distributionController;

	static const List<String> _reportTypes = [
		'Workforce Summary',
		'Attendance Snapshot',
		'Project Allocation',
		'Leadership View',
	];

	static const List<String> _statusOptions = [
		'All',
		'Active',
		'On Leave',
		'Probation',
	];

	static const List<String> _formatOptions = ['PDF', 'Excel', 'CSV'];

	final List<_ExportEmployeeRecord> _employees = const [
		_ExportEmployeeRecord(
			id: 'EMP-001',
			name: 'Rahul Sharma',
			role: 'Senior Accountant',
			department: 'Finance',
			status: 'Active',
			attendance: 0.96,
			projects: 3,
			manager: 'A. Kapoor',
			email: 'rahul.sharma@company.com',
			monthlyCompensation: 8200,
		),
		_ExportEmployeeRecord(
			id: 'EMP-002',
			name: 'Neha Verma',
			role: 'HR Executive',
			department: 'HR',
			status: 'On Leave',
			attendance: 0.91,
			projects: 2,
			manager: 'R. Menon',
			email: 'neha.verma@company.com',
			monthlyCompensation: 7400,
		),
		_ExportEmployeeRecord(
			id: 'EMP-003',
			name: 'Arjun Mehta',
			role: 'Operations Analyst',
			department: 'Operations',
			status: 'Active',
			attendance: 0.94,
			projects: 5,
			manager: 'P. Sinha',
			email: 'arjun.mehta@company.com',
			monthlyCompensation: 6900,
		),
		_ExportEmployeeRecord(
			id: 'EMP-004',
			name: 'Sneha Iyer',
			role: 'Recruitment Coordinator',
			department: 'HR',
			status: 'Probation',
			attendance: 0.88,
			projects: 1,
			manager: 'R. Menon',
			email: 'sneha.iyer@company.com',
			monthlyCompensation: 6100,
		),
		_ExportEmployeeRecord(
			id: 'EMP-005',
			name: 'Karan Patel',
			role: 'Payroll Specialist',
			department: 'Finance',
			status: 'Active',
			attendance: 0.97,
			projects: 4,
			manager: 'A. Kapoor',
			email: 'karan.patel@company.com',
			monthlyCompensation: 7800,
		),
		_ExportEmployeeRecord(
			id: 'EMP-006',
			name: 'Maya Nair',
			role: 'Data Associate',
			department: 'Operations',
			status: 'Active',
			attendance: 0.93,
			projects: 2,
			manager: 'P. Sinha',
			email: 'maya.nair@company.com',
			monthlyCompensation: 6400,
		),
		_ExportEmployeeRecord(
			id: 'EMP-007',
			name: 'Ishita Rao',
			role: 'Compliance Analyst',
			department: 'Legal',
			status: 'Active',
			attendance: 0.92,
			projects: 3,
			manager: 'S. Bhatt',
			email: 'ishita.rao@company.com',
			monthlyCompensation: 7100,
		),
		_ExportEmployeeRecord(
			id: 'EMP-008',
			name: 'Rohan Das',
			role: 'Support Executive',
			department: 'Support',
			status: 'Active',
			attendance: 0.89,
			projects: 2,
			manager: 'T. Deshmukh',
			email: 'rohan.das@company.com',
			monthlyCompensation: 5600,
		),
	];

	final List<_ExportRun> _recentExports = [
		_ExportRun(
			title: 'Leadership View',
			format: 'PDF',
			scope: 'All departments',
			createdBy: 'Shyam Patel',
			timestamp: DateTime(2026, 3, 16, 10, 35),
			status: 'Completed',
		),
		_ExportRun(
			title: 'Attendance Snapshot',
			format: 'Excel',
			scope: 'HR department',
			createdBy: 'Shyam Patel',
			timestamp: DateTime(2026, 3, 15, 16, 10),
			status: 'Delivered',
		),
		_ExportRun(
			title: 'Project Allocation',
			format: 'CSV',
			scope: 'Active employees',
			createdBy: 'Shyam Patel',
			timestamp: DateTime(2026, 3, 14, 11, 45),
			status: 'Completed',
		),
	];

	@override
	void initState() {
		super.initState();
		_distributionController =
				TextEditingController(text: 'leadership@company.com');
	}

	@override
	void dispose() {
		_distributionController.dispose();
		super.dispose();
	}

	List<String> get _departments {
		final values = _employees.map((employee) => employee.department).toSet().toList()
			..sort();
		return ['All', ...values];
	}

	List<_ExportEmployeeRecord> get _filteredEmployees {
		return _employees.where((employee) {
			final matchesDepartment =
					_selectedDepartment == 'All' || employee.department == _selectedDepartment;
			final matchesStatus =
					_selectedStatus == 'All' || employee.status == _selectedStatus;

			if (!_onlyFilteredEmployees) {
				return true;
			}

			return matchesDepartment && matchesStatus;
		}).toList();
	}

	double _averageAttendance(List<_ExportEmployeeRecord> list) {
		if (list.isEmpty) {
			return 0;
		}
		final total = list.fold<double>(0, (sum, item) => sum + item.attendance);
		return total / list.length;
	}

	int _activeEmployees(List<_ExportEmployeeRecord> list) {
		return list.where((employee) => employee.status == 'Active').length;
	}

	int _totalProjects(List<_ExportEmployeeRecord> list) {
		return list.fold<int>(0, (sum, item) => sum + item.projects);
	}

	List<String> get _selectedSections {
		final sections = <String>['Identity & role'];
		if (_includeAttendance) {
			sections.add('Attendance');
		}
		if (_includeProjects) {
			sections.add('Project load');
		}
		if (_includeCompensation) {
			sections.add('Compensation');
		}
		if (_includeContactInfo) {
			sections.add('Contact info');
		}
		return sections;
	}

	void _runExport() {
		final scope = _selectedDepartment == 'All'
				? (_selectedStatus == 'All'
						? 'All employees'
						: '${_selectedStatus.toLowerCase()} employees')
				: '$_selectedDepartment department';

		setState(() {
			_recentExports.insert(
				0,
				_ExportRun(
					title: _selectedReportType,
					format: _selectedFormat,
					scope: scope,
					createdBy: 'Shyam Patel',
					timestamp: DateTime.now(),
					status: 'Completed',
				),
			);
		});

		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text('$_selectedReportType export generated as $_selectedFormat.'),
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
										_buildExportPanel(isCompact),
										const SizedBox(height: 14),
										_buildPreviewPanel(employees),
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
															_buildExportPanel(false),
															const SizedBox(height: 16),
															_buildHistoryPanel(),
														],
													),
												),
												const SizedBox(width: 16),
												Expanded(
													flex: 3,
													child: _buildPreviewPanel(employees),
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
					'Export Employee Report',
					style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
				),
				SizedBox(height: 6),
				Text(
					'Prepare leadership-ready workforce reports with attendance, allocation, and employee detail filters.',
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
							_selectedReportType = _reportTypes.first;
							_selectedDepartment = 'All';
							_selectedStatus = 'All';
							_selectedFormat = _formatOptions.first;
							_includeAttendance = true;
							_includeProjects = true;
							_includeCompensation = false;
							_includeContactInfo = true;
							_onlyFilteredEmployees = true;
							_distributionController.text = 'leadership@company.com';
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
					onPressed: _runExport,
					icon: const Icon(Icons.file_download_outlined, size: 18),
					label: const Text('Export Now'),
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

	Widget _buildHeroCard(List<_ExportEmployeeRecord> employees) {
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
									'Reporting Control Center',
									style: TextStyle(
										color: Colors.white,
										fontSize: 22,
										fontWeight: FontWeight.w800,
									),
								),
								SizedBox(height: 8),
								Text(
									'Package workforce data by role, department, attendance, and project load for fast executive review.',
									style: TextStyle(color: Colors.white70, height: 1.4),
								),
							],
						),
					),
					_heroBadge(Icons.groups_2_outlined, '${employees.length} Employees In Scope'),
					_heroBadge(Icons.rule_folder_outlined, '${_selectedSections.length} Sections Included'),
					_heroBadge(Icons.outbox_outlined, '${_recentExports.length} Recent Export Runs'),
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

	Widget _buildMetricGrid(double width, List<_ExportEmployeeRecord> employees) {
		int columns = 4;
		if (width < 1180) {
			columns = 2;
		}
		if (width < 700) {
			columns = 1;
		}

		final metrics = [
			_ExportMetricCard(
				title: 'Employees',
				value: '${employees.length}',
				hint: 'Current export scope',
				color: const Color(0xFF1A73E8),
				icon: Icons.badge_outlined,
			),
			_ExportMetricCard(
				title: 'Avg Attendance',
				value: '${(_averageAttendance(employees) * 100).toStringAsFixed(1)}%',
				hint: 'Across selected records',
				color: const Color(0xFF36B39C),
				icon: Icons.calendar_month_outlined,
			),
			_ExportMetricCard(
				title: 'Active Employees',
				value: '${_activeEmployees(employees)}',
				hint: 'Ready for live projects',
				color: const Color(0xFF0F9D58),
				icon: Icons.workspace_premium_outlined,
			),
			_ExportMetricCard(
				title: 'Project Load',
				value: '${_totalProjects(employees)}',
				hint: 'Total linked assignments',
				color: const Color(0xFFF29900),
				icon: Icons.account_tree_outlined,
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

	Widget _buildExportPanel(bool isCompact) {
		return _panel(
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					const Text(
						'Export Configuration',
						style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
					),
					const SizedBox(height: 6),
					const Text(
						'Choose the report layout, employee scope, and which data sections should be included.',
						style: TextStyle(color: Color(0xFF64748B)),
					),
					const SizedBox(height: 14),
					_fieldLabel('Report Type'),
					DropdownButtonFormField<String>(
						value: _selectedReportType,
						items: _reportTypes
								.map((type) => DropdownMenuItem(value: type, child: Text(type)))
								.toList(),
						onChanged: (value) {
							if (value == null) {
								return;
							}
							setState(() {
								_selectedReportType = value;
							});
						},
						decoration: _inputDecoration('Select report type'),
					),
					const SizedBox(height: 12),
					if (isCompact) ...[
						_departmentField(),
						const SizedBox(height: 12),
						_statusField(),
						const SizedBox(height: 12),
						_formatField(),
					] else
						Row(
							children: [
								Expanded(child: _departmentField()),
								const SizedBox(width: 10),
								Expanded(child: _statusField()),
								const SizedBox(width: 10),
								Expanded(child: _formatField()),
							],
						),
					const SizedBox(height: 12),
					_fieldLabel('Distribution List'),
					TextField(
						controller: _distributionController,
						decoration: _inputDecoration('Comma-separated email recipients'),
					),
					const SizedBox(height: 12),
					SwitchListTile(
						contentPadding: EdgeInsets.zero,
						value: _onlyFilteredEmployees,
						onChanged: (value) {
							setState(() {
								_onlyFilteredEmployees = value;
							});
						},
						title: const Text('Limit export to current department and status filters'),
						dense: true,
					),
					const SizedBox(height: 8),
					const Text(
						'Included Sections',
						style: TextStyle(fontWeight: FontWeight.w700),
					),
					const SizedBox(height: 8),
					CheckboxListTile(
						contentPadding: EdgeInsets.zero,
						value: _includeAttendance,
						onChanged: (value) {
							setState(() {
								_includeAttendance = value ?? false;
							});
						},
						title: const Text('Attendance overview'),
						dense: true,
						controlAffinity: ListTileControlAffinity.leading,
					),
					CheckboxListTile(
						contentPadding: EdgeInsets.zero,
						value: _includeProjects,
						onChanged: (value) {
							setState(() {
								_includeProjects = value ?? false;
							});
						},
						title: const Text('Project allocation summary'),
						dense: true,
						controlAffinity: ListTileControlAffinity.leading,
					),
					CheckboxListTile(
						contentPadding: EdgeInsets.zero,
						value: _includeCompensation,
						onChanged: (value) {
							setState(() {
								_includeCompensation = value ?? false;
							});
						},
						title: const Text('Compensation snapshot'),
						dense: true,
						controlAffinity: ListTileControlAffinity.leading,
					),
					CheckboxListTile(
						contentPadding: EdgeInsets.zero,
						value: _includeContactInfo,
						onChanged: (value) {
							setState(() {
								_includeContactInfo = value ?? false;
							});
						},
						title: const Text('Contact and reporting info'),
						dense: true,
						controlAffinity: ListTileControlAffinity.leading,
					),
					const SizedBox(height: 6),
					SizedBox(
						width: double.infinity,
						child: FilledButton.icon(
							onPressed: _runExport,
							icon: const Icon(Icons.ios_share_outlined, size: 18),
							label: const Text('Generate Export'),
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
					decoration: _inputDecoration('Select status'),
				),
			],
		);
	}

	Widget _formatField() {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				_fieldLabel('Format'),
				DropdownButtonFormField<String>(
					value: _selectedFormat,
					items: _formatOptions
							.map((format) => DropdownMenuItem(value: format, child: Text(format)))
							.toList(),
					onChanged: (value) {
						if (value == null) {
							return;
						}
						setState(() {
							_selectedFormat = value;
						});
					},
					decoration: _inputDecoration('Select format'),
				),
			],
		);
	}

	Widget _buildPreviewPanel(List<_ExportEmployeeRecord> employees) {
		return _panel(
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							const Expanded(
								child: Text(
									'Report Preview',
									style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
								),
							),
							_chip(_selectedFormat, const Color(0xFF1A73E8)),
						],
					),
					const SizedBox(height: 6),
					Text(
						'Template: $_selectedReportType  •  ${employees.length} employee records',
						style: const TextStyle(color: Color(0xFF64748B)),
					),
					const SizedBox(height: 12),
					Wrap(
						spacing: 8,
						runSpacing: 8,
						children: _selectedSections
								.map((section) => _chip(section, const Color(0xFF36B39C)))
								.toList(),
					),
					const SizedBox(height: 14),
					...employees.take(5).map(_buildPreviewRow),
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
								'No employees match the selected filters.',
								style: TextStyle(color: Color(0xFF64748B)),
							),
						),
				],
			),
		);
	}

	Widget _buildPreviewRow(_ExportEmployeeRecord employee) {
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
							_chip(employee.status, _statusColor(employee.status)),
						],
					),
					const SizedBox(height: 10),
					Wrap(
						spacing: 8,
						runSpacing: 8,
						children: [
							_detailChip(Icons.badge_outlined, employee.id),
							if (_includeAttendance)
								_detailChip(Icons.fact_check_outlined,
										'Attendance ${(employee.attendance * 100).toStringAsFixed(0)}%'),
							if (_includeProjects)
								_detailChip(Icons.account_tree_outlined,
										'${employee.projects} projects'),
							if (_includeContactInfo)
								_detailChip(Icons.person_outline_rounded, employee.manager),
							if (_includeCompensation)
								_detailChip(Icons.payments_outlined,
										'\$${employee.monthlyCompensation.toStringAsFixed(0)} / month'),
						],
					),
					if (_includeContactInfo) ...[
						const SizedBox(height: 8),
						Text(
							employee.email,
							style: const TextStyle(
								color: Color(0xFF64748B),
								fontSize: 12,
							),
						),
					],
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
						'Recent Exports',
						style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
					),
					const SizedBox(height: 6),
					const Text(
						'Last report runs and delivery status for audit visibility.',
						style: TextStyle(color: Color(0xFF64748B)),
					),
					const SizedBox(height: 12),
					..._recentExports.take(5).map(
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
												'${run.format}  •  ${run.scope}',
												style: const TextStyle(color: Color(0xFF64748B)),
											),
											const SizedBox(height: 4),
											Text(
												'Created by ${run.createdBy} on ${_formatDateTime(run.timestamp)}',
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

	Color _statusColor(String status) {
		switch (status) {
			case 'Active':
				return const Color(0xFF0F9D58);
			case 'On Leave':
				return const Color(0xFFF29900);
			case 'Probation':
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

class _ExportEmployeeRecord {
	final String id;
	final String name;
	final String role;
	final String department;
	final String status;
	final double attendance;
	final int projects;
	final String manager;
	final String email;
	final double monthlyCompensation;

	const _ExportEmployeeRecord({
		required this.id,
		required this.name,
		required this.role,
		required this.department,
		required this.status,
		required this.attendance,
		required this.projects,
		required this.manager,
		required this.email,
		required this.monthlyCompensation,
	});
}

class _ExportRun {
	final String title;
	final String format;
	final String scope;
	final String createdBy;
	final DateTime timestamp;
	final String status;

	const _ExportRun({
		required this.title,
		required this.format,
		required this.scope,
		required this.createdBy,
		required this.timestamp,
		required this.status,
	});
}

class _ExportMetricCard {
	final String title;
	final String value;
	final String hint;
	final Color color;
	final IconData icon;

	const _ExportMetricCard({
		required this.title,
		required this.value,
		required this.hint,
		required this.color,
		required this.icon,
	});
}
