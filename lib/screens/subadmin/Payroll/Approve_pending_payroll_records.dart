import 'package:flutter/material.dart';

class SubAdminApprovePendingPayrollRecordsPage extends StatefulWidget {
	const SubAdminApprovePendingPayrollRecordsPage({super.key});

	@override
	State<SubAdminApprovePendingPayrollRecordsPage> createState() =>
			_SubAdminApprovePendingPayrollRecordsPageState();
}

class _SubAdminApprovePendingPayrollRecordsPageState
		extends State<SubAdminApprovePendingPayrollRecordsPage> {
	String _searchQuery = '';
	String _selectedDepartment = 'All';
	String _selectedPriority = 'All';
	String _selectedIssueType = 'All';
	bool _onlyEscalated = false;

	late final TextEditingController _searchController;

	static const List<String> _priorityOptions = [
		'All',
		'Critical',
		'High',
		'Normal',
	];

	final List<_PendingPayrollRecord> _records = [
		_PendingPayrollRecord(
			id: 'APR-4101',
			employeeId: 'EMP-002',
			employeeName: 'Neha Verma',
			department: 'HR',
			baseSalary: 7400,
			overtime: 210,
			bonus: 300,
			deduction: 460,
			status: 'Pending',
			priority: 'High',
			issueType: 'Bank KYC',
			issueDetail: 'KYC re-verification pending from employee documents.',
			variancePct: 7.8,
			reviewer: 'R. Menon',
			submittedAt: DateTime(2026, 3, 14, 10, 20),
		),
		_PendingPayrollRecord(
			id: 'APR-4102',
			employeeId: 'EMP-008',
			employeeName: 'Rohan Das',
			department: 'Operations',
			baseSalary: 5600,
			overtime: 240,
			bonus: 110,
			deduction: 320,
			status: 'Escalated',
			priority: 'Critical',
			issueType: 'Missing Documents',
			issueDetail:
					'Attendance proof mismatch for 2 shifts; manager attachment missing.',
			variancePct: 12.3,
			reviewer: 'P. Sinha',
			submittedAt: DateTime(2026, 3, 13, 16, 45),
		),
		_PendingPayrollRecord(
			id: 'APR-4103',
			employeeId: 'EMP-011',
			employeeName: 'Harsh Solanki',
			department: 'Finance',
			baseSalary: 8100,
			overtime: 360,
			bonus: 500,
			deduction: 390,
			status: 'Pending',
			priority: 'Normal',
			issueType: 'Tax Recheck',
			issueDetail: 'Tax slab override needs finance controller confirmation.',
			variancePct: 4.6,
			reviewer: 'A. Kapoor',
			submittedAt: DateTime(2026, 3, 15, 9, 10),
		),
		_PendingPayrollRecord(
			id: 'APR-4104',
			employeeId: 'EMP-017',
			employeeName: 'Ishita Rao',
			department: 'Legal',
			baseSalary: 7100,
			overtime: 190,
			bonus: 340,
			deduction: 270,
			status: 'On Hold',
			priority: 'High',
			issueType: 'Approval Chain',
			issueDetail: 'Secondary approver unavailable; delegated approver pending.',
			variancePct: 6.9,
			reviewer: 'S. Bhatt',
			submittedAt: DateTime(2026, 3, 12, 13, 40),
		),
		_PendingPayrollRecord(
			id: 'APR-4105',
			employeeId: 'EMP-019',
			employeeName: 'Vimal Patel',
			department: 'Operations',
			baseSalary: 6200,
			overtime: 410,
			bonus: 120,
			deduction: 430,
			status: 'Pending',
			priority: 'Critical',
			issueType: 'Overtime Audit',
			issueDetail: 'Overtime exceeds threshold; shift logs require cross-check.',
			variancePct: 11.2,
			reviewer: 'P. Sinha',
			submittedAt: DateTime(2026, 3, 16, 8, 25),
		),
		_PendingPayrollRecord(
			id: 'APR-4106',
			employeeId: 'EMP-021',
			employeeName: 'Kriti Dave',
			department: 'HR',
			baseSalary: 6800,
			overtime: 150,
			bonus: 200,
			deduction: 300,
			status: 'Pending',
			priority: 'Normal',
			issueType: 'Benefit Adjustment',
			issueDetail:
					'Medical allowance revision reflected late in payroll adjustment sheet.',
			variancePct: 3.4,
			reviewer: 'R. Menon',
			submittedAt: DateTime(2026, 3, 15, 11, 5),
		),
		_PendingPayrollRecord(
			id: 'APR-4107',
			employeeId: 'EMP-025',
			employeeName: 'Aman Vohra',
			department: 'Finance',
			baseSalary: 7800,
			overtime: 260,
			bonus: 500,
			deduction: 340,
			status: 'Approved',
			priority: 'Normal',
			issueType: 'Resolved',
			issueDetail: 'Record approved after tax verification.',
			variancePct: 2.1,
			reviewer: 'A. Kapoor',
			submittedAt: DateTime(2026, 3, 11, 10, 35),
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
		final values = _records.map((record) => record.department).toSet().toList()
			..sort();
		return ['All', ...values];
	}

	List<String> get _issueTypes {
		final values = _records.map((record) => record.issueType).toSet().toList()
			..sort();
		return ['All', ...values];
	}

	List<_PendingPayrollRecord> get _filteredRecords {
		final query = _searchQuery.trim().toLowerCase();

		final list = _records.where((record) {
			final matchesSearch = query.isEmpty ||
					record.id.toLowerCase().contains(query) ||
					record.employeeName.toLowerCase().contains(query) ||
					record.employeeId.toLowerCase().contains(query) ||
					record.department.toLowerCase().contains(query) ||
					record.issueType.toLowerCase().contains(query) ||
					record.issueDetail.toLowerCase().contains(query);

			final matchesDepartment = _selectedDepartment == 'All' ||
					record.department == _selectedDepartment;
			final matchesPriority =
					_selectedPriority == 'All' || record.priority == _selectedPriority;
			final matchesIssue =
					_selectedIssueType == 'All' || record.issueType == _selectedIssueType;
			final matchesEscalated = !_onlyEscalated || record.status == 'Escalated';

			return matchesSearch &&
					matchesDepartment &&
					matchesPriority &&
					matchesIssue &&
					matchesEscalated;
		}).toList();

		list.sort((a, b) {
			final statusWeight = _statusWeight(a.status).compareTo(_statusWeight(b.status));
			if (statusWeight != 0) {
				return statusWeight;
			}
			return b.variancePct.compareTo(a.variancePct);
		});
		return list;
	}

	int _statusWeight(String status) {
		switch (status) {
			case 'Escalated':
				return 0;
			case 'Pending':
				return 1;
			case 'On Hold':
				return 2;
			case 'Approved':
				return 3;
			case 'Rejected':
				return 4;
			default:
				return 9;
		}
	}

	double _netPay(_PendingPayrollRecord record) {
		return record.baseSalary + record.overtime + record.bonus - record.deduction;
	}

	int _countByStatus(List<_PendingPayrollRecord> list, String status) {
		return list.where((record) => record.status == status).length;
	}

	double _pendingAmount(List<_PendingPayrollRecord> list) {
		final pending = list.where(_requiresApproval);
		return pending.fold<double>(0, (sum, record) => sum + _netPay(record));
	}

	bool _requiresApproval(_PendingPayrollRecord record) {
		return record.status == 'Pending' ||
				record.status == 'Escalated' ||
				record.status == 'On Hold';
	}

	double _averageVariance(List<_PendingPayrollRecord> list) {
		if (list.isEmpty) {
			return 0;
		}
		final total = list.fold<double>(0, (sum, record) => sum + record.variancePct);
		return total / list.length;
	}

	int _highRiskCount(List<_PendingPayrollRecord> list) {
		return list
				.where((record) =>
						record.priority == 'Critical' ||
						record.variancePct >= 10 ||
						record.status == 'Escalated')
				.length;
	}

	void _approveAllVisible() {
		final visiblePending =
				_filteredRecords.where((record) => _requiresApproval(record)).toList();
		if (visiblePending.isEmpty) {
			_showSnack('No visible pending records to approve.', isError: true);
			return;
		}

		setState(() {
			for (final record in visiblePending) {
				final index = _records.indexWhere((item) => item.id == record.id);
				if (index != -1) {
					_records[index] = _records[index].copyWith(status: 'Approved');
				}
			}
		});

		_showSnack('${visiblePending.length} payroll records approved.');
	}

	void _updateStatus(_PendingPayrollRecord record, String status) {
		final index = _records.indexWhere((item) => item.id == record.id);
		if (index == -1) {
			return;
		}

		setState(() {
			_records[index] = _records[index].copyWith(status: status);
		});

		_showSnack('Record ${record.id} updated to $status.');
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
						final records = _filteredRecords;

						return SingleChildScrollView(
							padding: EdgeInsets.all(isCompact ? 14 : 20),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									_buildHeader(isCompact),
									const SizedBox(height: 16),
									_buildHeroCard(records),
									const SizedBox(height: 16),
									_buildMetricGrid(width, records),
									const SizedBox(height: 16),
									if (isNarrow) ...[
										_buildApprovalPanel(records, isCompact),
										const SizedBox(height: 14),
										_buildInsightsPanel(records),
									] else
										Row(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Expanded(
													flex: 3,
													child: _buildApprovalPanel(records, false),
												),
												const SizedBox(width: 16),
												Expanded(
													flex: 2,
													child: _buildInsightsPanel(records),
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
					'Approve Pending Payroll Records',
					style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
				),
				SizedBox(height: 6),
				Text(
					'Resolve payroll exceptions, validate risk, and approve pending payouts before release.',
					style: TextStyle(color: Color(0xFF5F6368)),
				),
			],
		);

		final actions = Wrap(
			spacing: 8,
			runSpacing: 8,
			children: [
				OutlinedButton.icon(
					onPressed: () => setState(() => _onlyEscalated = !_onlyEscalated),
					icon: Icon(
						_onlyEscalated
								? Icons.filter_alt_off_outlined
								: Icons.filter_alt_outlined,
						size: 18,
					),
					label: Text(_onlyEscalated ? 'Show All' : 'Only Escalated'),
					style: OutlinedButton.styleFrom(
						foregroundColor: const Color(0xFF0F172A),
						side: const BorderSide(color: Color(0xFFD6DEE8)),
					),
				),
				FilledButton.icon(
					onPressed: _approveAllVisible,
					icon: const Icon(Icons.approval_rounded, size: 18),
					label: const Text('Approve Visible'),
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

	Widget _buildHeroCard(List<_PendingPayrollRecord> records) {
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
						color: const Color(0xFF1A73E8).withOpacity(0.26),
						blurRadius: 22,
						offset: const Offset(0, 12),
					),
				],
			),
			child: Wrap(
				spacing: 14,
				runSpacing: 12,
				crossAxisAlignment: WrapCrossAlignment.center,
				children: [
					const SizedBox(
						width: 420,
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									'Payroll risk window is active. Prioritize escalated records before payout cutoff.',
									style: TextStyle(
										color: Colors.white,
										fontSize: 17,
										fontWeight: FontWeight.w700,
									),
								),
								SizedBox(height: 6),
								Text(
									'Use the filters to isolate high-variance records and fast-track approvals with audit traceability.',
									style: TextStyle(color: Color(0xFFE3F2FD), fontSize: 12),
								),
							],
						),
					),
					Wrap(
						spacing: 8,
						runSpacing: 8,
						children: [
							_heroBadge(
								icon: Icons.receipt_long_outlined,
								label: 'Records: ${records.length}',
							),
							_heroBadge(
								icon: Icons.warning_amber_rounded,
								label: 'High risk: ${_highRiskCount(records)}',
							),
							_heroBadge(
								icon: Icons.account_balance_wallet_outlined,
								label: 'At risk: ${_currency(_pendingAmount(records))}',
							),
						],
					),
				],
			),
		);
	}

	Widget _heroBadge({required IconData icon, required String label}) {
		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
			decoration: BoxDecoration(
				color: Colors.white.withOpacity(0.16),
				borderRadius: BorderRadius.circular(999),
				border: Border.all(color: Colors.white.withOpacity(0.2)),
			),
			child: Row(
				mainAxisSize: MainAxisSize.min,
				children: [
					Icon(icon, size: 16, color: Colors.white),
					const SizedBox(width: 6),
					Text(
						label,
						style: const TextStyle(
							color: Colors.white,
							fontSize: 12,
							fontWeight: FontWeight.w600,
						),
					),
				],
			),
		);
	}

	Widget _buildMetricGrid(double width, List<_PendingPayrollRecord> records) {
		final metrics = [
			_ApprovalMetric(
				label: 'Pending',
				value: '${_countByStatus(records, 'Pending')}',
				subtitle: 'Needs decision',
				icon: Icons.hourglass_top_rounded,
				color: const Color(0xFF1A73E8),
			),
			_ApprovalMetric(
				label: 'Escalated',
				value: '${_countByStatus(records, 'Escalated')}',
				subtitle: 'Critical attention',
				icon: Icons.priority_high_rounded,
				color: const Color(0xFFDB4437),
			),
			_ApprovalMetric(
				label: 'Amount at Risk',
				value: _currency(_pendingAmount(records)),
				subtitle: 'Pending approval value',
				icon: Icons.account_balance_wallet_outlined,
				color: const Color(0xFFF29900),
			),
			_ApprovalMetric(
				label: 'Avg Variance',
				value: '${_averageVariance(records).toStringAsFixed(1)}%',
				subtitle: 'Difference from expected',
				icon: Icons.show_chart_rounded,
				color: const Color(0xFF7C3AED),
			),
		];

		final columns = width >= 1180
				? 4
				: width >= 720
						? 2
						: 1;

		return GridView.builder(
			shrinkWrap: true,
			physics: const NeverScrollableScrollPhysics(),
			gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
				crossAxisCount: columns,
				crossAxisSpacing: 12,
				mainAxisSpacing: 12,
				mainAxisExtent: 130,
			),
			itemCount: metrics.length,
			itemBuilder: (context, index) {
				final metric = metrics[index];
				return Container(
					padding: const EdgeInsets.all(14),
					decoration: BoxDecoration(
						color: Colors.white,
						borderRadius: BorderRadius.circular(16),
						border: Border.all(color: const Color(0xFFE5EAF2)),
					),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Row(
								children: [
									Container(
										padding: const EdgeInsets.all(8),
										decoration: BoxDecoration(
											color: metric.color.withOpacity(0.14),
											borderRadius: BorderRadius.circular(10),
										),
										child: Icon(metric.icon, color: metric.color, size: 18),
									),
									const SizedBox(width: 10),
									Expanded(
										child: Text(
											metric.label,
											maxLines: 1,
											overflow: TextOverflow.ellipsis,
											style: const TextStyle(
												fontSize: 13,
												color: Color(0xFF475569),
												fontWeight: FontWeight.w600,
											),
										),
									),
								],
							),
							const Spacer(),
							Text(
								metric.value,
								style: const TextStyle(
									fontSize: 24,
									fontWeight: FontWeight.w800,
									color: Color(0xFF0F172A),
								),
							),
							const SizedBox(height: 2),
							Text(
								metric.subtitle,
								maxLines: 1,
								overflow: TextOverflow.ellipsis,
								style: TextStyle(
									fontSize: 11,
									color: metric.color,
									fontWeight: FontWeight.w600,
								),
							),
						],
					),
				);
			},
		);
	}

	Widget _buildApprovalPanel(List<_PendingPayrollRecord> records, bool isCompact) {
		return Container(
			padding: EdgeInsets.all(isCompact ? 14 : 16),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(18),
				border: Border.all(color: const Color(0xFFE6EBF2)),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					const Text(
						'Approval Queue',
						style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
					),
					const SizedBox(height: 4),
					const Text(
						'Review pending payroll entries and push them to final approval workflow.',
						style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
					),
					const SizedBox(height: 12),
					_buildFilterBar(isCompact),
					const SizedBox(height: 12),
					if (records.isEmpty)
						Container(
							width: double.infinity,
							padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
							decoration: BoxDecoration(
								color: const Color(0xFFF8FAFC),
								borderRadius: BorderRadius.circular(14),
								border: Border.all(color: const Color(0xFFE2E8F0)),
							),
							child: const Text(
								'No records match current filters.',
								textAlign: TextAlign.center,
								style: TextStyle(
									color: Color(0xFF64748B),
									fontWeight: FontWeight.w600,
								),
							),
						)
					else
						...records.map(
							(record) => Padding(
								padding: const EdgeInsets.only(bottom: 10),
								child: _buildRecordTile(record),
							),
						),
				],
			),
		);
	}

	Widget _buildFilterBar(bool isCompact) {
		final searchField = TextField(
			controller: _searchController,
			onChanged: (value) => setState(() => _searchQuery = value),
			decoration: InputDecoration(
				hintText: 'Search by employee, id, issue type, or details...',
				prefixIcon: const Icon(Icons.search_rounded),
				filled: true,
				fillColor: const Color(0xFFF8FAFC),
				contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
				border: OutlineInputBorder(
					borderRadius: BorderRadius.circular(12),
					borderSide: const BorderSide(color: Color(0xFFDCE3EC)),
				),
				enabledBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(12),
					borderSide: const BorderSide(color: Color(0xFFDCE3EC)),
				),
			),
		);

		if (isCompact) {
			return Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					searchField,
					const SizedBox(height: 10),
					Wrap(
						spacing: 8,
						runSpacing: 8,
						children: [
							SizedBox(
								width: 170,
								child: _buildDropdown(
									label: 'Department',
									value: _selectedDepartment,
									items: _departments,
									onChanged: (value) => setState(() => _selectedDepartment = value),
								),
							),
							SizedBox(
								width: 170,
								child: _buildDropdown(
									label: 'Priority',
									value: _selectedPriority,
									items: _priorityOptions,
									onChanged: (value) => setState(() => _selectedPriority = value),
								),
							),
							SizedBox(
								width: 170,
								child: _buildDropdown(
									label: 'Issue Type',
									value: _selectedIssueType,
									items: _issueTypes,
									onChanged: (value) => setState(() => _selectedIssueType = value),
								),
							),
						],
					),
				],
			);
		}

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				searchField,
				const SizedBox(height: 10),
				Row(
					children: [
						Expanded(
							child: _buildDropdown(
								label: 'Department',
								value: _selectedDepartment,
								items: _departments,
								onChanged: (value) => setState(() => _selectedDepartment = value),
							),
						),
						const SizedBox(width: 8),
						Expanded(
							child: _buildDropdown(
								label: 'Priority',
								value: _selectedPriority,
								items: _priorityOptions,
								onChanged: (value) => setState(() => _selectedPriority = value),
							),
						),
						const SizedBox(width: 8),
						Expanded(
							child: _buildDropdown(
								label: 'Issue Type',
								value: _selectedIssueType,
								items: _issueTypes,
								onChanged: (value) => setState(() => _selectedIssueType = value),
							),
						),
					],
				),
			],
		);
	}

	Widget _buildDropdown({
		required String label,
		required String value,
		required List<String> items,
		required ValueChanged<String> onChanged,
	}) {
		return DropdownButtonFormField<String>(
			isExpanded: true,
			value: value,
			items: items
					.map(
						(item) => DropdownMenuItem<String>(
							value: item,
							child: Text(
								item,
								maxLines: 1,
								overflow: TextOverflow.ellipsis,
							),
						),
					)
					.toList(),
			selectedItemBuilder: (context) {
				return items
						.map(
							(item) => Align(
								alignment: Alignment.centerLeft,
								child: Text(
									item,
									maxLines: 1,
									overflow: TextOverflow.ellipsis,
								),
							),
						)
						.toList();
			},
			onChanged: (changed) {
				if (changed != null) {
					onChanged(changed);
				}
			},
			decoration: InputDecoration(
				labelText: label,
				filled: true,
				fillColor: const Color(0xFFF8FAFC),
				isDense: true,
				border: OutlineInputBorder(
					borderRadius: BorderRadius.circular(12),
					borderSide: const BorderSide(color: Color(0xFFDCE3EC)),
				),
				enabledBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(12),
					borderSide: const BorderSide(color: Color(0xFFDCE3EC)),
				),
			),
		);
	}

	Widget _buildRecordTile(_PendingPayrollRecord record) {
		final statusColor = _statusColor(record.status);
		final priorityColor = _priorityColor(record.priority);

		return Container(
			padding: const EdgeInsets.all(14),
			decoration: BoxDecoration(
				color: const Color(0xFFF8FAFC),
				borderRadius: BorderRadius.circular(14),
				border: Border.all(color: const Color(0xFFE2E8F0)),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											record.employeeName,
											style: const TextStyle(
												fontSize: 16,
												fontWeight: FontWeight.w700,
											),
										),
										const SizedBox(height: 2),
										Text(
											'${record.id}  •  ${record.employeeId}  •  ${record.department}',
											style: const TextStyle(
												fontSize: 12,
												color: Color(0xFF64748B),
											),
										),
									],
								),
							),
							Container(
								padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
								decoration: BoxDecoration(
									color: statusColor.withOpacity(0.14),
									borderRadius: BorderRadius.circular(999),
								),
								child: Text(
									record.status,
									style: TextStyle(
										fontSize: 11,
										fontWeight: FontWeight.w700,
										color: statusColor,
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
							_chip('Priority: ${record.priority}', priorityColor),
							_chip('Issue: ${record.issueType}', const Color(0xFF1A73E8)),
							_chip('Net: ${_currency(_netPay(record))}', const Color(0xFF0F9D58)),
							_chip('Variance: ${record.variancePct.toStringAsFixed(1)}%',
									const Color(0xFFF29900)),
							_chip('Reviewer: ${record.reviewer}', const Color(0xFF475569)),
							_chip('Submitted: ${_formatDate(record.submittedAt)}',
									const Color(0xFF475569)),
						],
					),
					const SizedBox(height: 10),
					Text(
						record.issueDetail,
						style: const TextStyle(
							color: Color(0xFF334155),
							fontSize: 12,
							fontWeight: FontWeight.w500,
						),
					),
					const SizedBox(height: 10),
					Wrap(
						spacing: 8,
						runSpacing: 8,
						children: [
							OutlinedButton.icon(
								onPressed: () =>
										_showSnack('Payroll slip opened for ${record.employeeName}.'),
								icon: const Icon(Icons.receipt_long_outlined, size: 17),
								label: const Text('View Slip'),
								style: OutlinedButton.styleFrom(
									foregroundColor: const Color(0xFF0F172A),
									side: const BorderSide(color: Color(0xFFD3DCE7)),
								),
							),
							FilledButton.tonalIcon(
								onPressed: record.status == 'Approved'
										? null
										: () => _updateStatus(record, 'Approved'),
								icon: const Icon(Icons.check_circle_outline_rounded, size: 17),
								label: const Text('Approve'),
								style: FilledButton.styleFrom(
									backgroundColor: const Color(0xFFE8F5EE),
									foregroundColor: const Color(0xFF0B8043),
								),
							),
							PopupMenuButton<String>(
								onSelected: (value) => _updateStatus(record, value),
								itemBuilder: (context) => const [
									PopupMenuItem(value: 'On Hold', child: Text('Mark On Hold')),
									PopupMenuItem(value: 'Escalated', child: Text('Escalate')),
									PopupMenuItem(value: 'Rejected', child: Text('Reject')),
								],
								child: OutlinedButton.icon(
									onPressed: null,
									icon: const Icon(Icons.more_horiz_rounded, size: 17),
									label: const Text('More Actions'),
									style: OutlinedButton.styleFrom(
										foregroundColor: const Color(0xFF0F172A),
										side: const BorderSide(color: Color(0xFFD3DCE7)),
									),
								),
							),
						],
					),
				],
			),
		);
	}

	Widget _buildInsightsPanel(List<_PendingPayrollRecord> records) {
		return Column(
			children: [
				_buildIssueBreakdownCard(records),
				const SizedBox(height: 12),
				_buildHighRiskCard(records),
				const SizedBox(height: 12),
				_buildQueueHealthCard(records),
			],
		);
	}

	Widget _buildIssueBreakdownCard(List<_PendingPayrollRecord> records) {
		final counts = <String, int>{};
		for (final record in records) {
			counts[record.issueType] = (counts[record.issueType] ?? 0) + 1;
		}
		final rows = counts.entries.toList()
			..sort((a, b) => b.value.compareTo(a.value));
		final maxCount = rows.isEmpty ? 1 : rows.first.value;

		return _insightPanel(
			title: 'Issue Breakdown',
			child: rows.isEmpty
					? const Text(
							'No issue data available.',
							style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
						)
					: Column(
							children: rows
									.map(
										(entry) => Padding(
											padding: const EdgeInsets.only(bottom: 10),
											child: Column(
												children: [
													Row(
														children: [
															Expanded(
																child: Text(
																	entry.key,
																	style: const TextStyle(
																		fontSize: 12,
																		fontWeight: FontWeight.w600,
																	),
																),
															),
															Text(
																'${entry.value}',
																style: const TextStyle(
																	fontSize: 12,
																	fontWeight: FontWeight.w700,
																	color: Color(0xFF1A73E8),
																),
															),
														],
													),
													const SizedBox(height: 6),
													ClipRRect(
														borderRadius: BorderRadius.circular(999),
														child: LinearProgressIndicator(
															minHeight: 8,
															value: entry.value / maxCount,
															backgroundColor: const Color(0xFFE8EDF5),
															valueColor: const AlwaysStoppedAnimation<Color>(
																	Color(0xFF1A73E8)),
														),
													),
												],
											),
										),
									)
									.toList(),
						),
		);
	}

	Widget _buildHighRiskCard(List<_PendingPayrollRecord> records) {
		final highRisk = records
				.where((record) =>
						record.priority == 'Critical' ||
						record.status == 'Escalated' ||
						record.variancePct >= 10)
				.toList();

		return _insightPanel(
			title: 'High Risk Records',
			child: highRisk.isEmpty
					? const Text(
							'No high-risk records in current filters.',
							style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
						)
					: Column(
							children: highRisk
									.take(4)
									.map(
										(record) => Container(
											margin: const EdgeInsets.only(bottom: 8),
											padding: const EdgeInsets.all(10),
											decoration: BoxDecoration(
												color: const Color(0xFFFFF7ED),
												borderRadius: BorderRadius.circular(10),
												border: Border.all(color: const Color(0xFFFED7AA)),
											),
											child: Row(
												children: [
													const Icon(
														Icons.warning_amber_rounded,
														size: 16,
														color: Color(0xFFF29900),
													),
													const SizedBox(width: 8),
													Expanded(
														child: Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																Text(
																	record.employeeName,
																	style: const TextStyle(
																		fontSize: 12,
																		fontWeight: FontWeight.w700,
																	),
																),
																Text(
																	'${record.id}  •  ${record.issueType}',
																	style: const TextStyle(
																		fontSize: 11,
																		color: Color(0xFF64748B),
																	),
																),
															],
														),
													),
													Text(
														'${record.variancePct.toStringAsFixed(1)}%',
														style: const TextStyle(
															color: Color(0xFFDB4437),
															fontWeight: FontWeight.w800,
															fontSize: 12,
														),
													),
												],
											),
										),
									)
									.toList(),
						),
		);
	}

	Widget _buildQueueHealthCard(List<_PendingPayrollRecord> records) {
		return _insightPanel(
			title: 'Queue Health',
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					_healthRow('Pending', _countByStatus(records, 'Pending'),
							const Color(0xFF1A73E8)),
					const SizedBox(height: 8),
					_healthRow('Escalated', _countByStatus(records, 'Escalated'),
							const Color(0xFFDB4437)),
					const SizedBox(height: 8),
					_healthRow(
							'On Hold', _countByStatus(records, 'On Hold'), const Color(0xFFF29900)),
					const SizedBox(height: 8),
					_healthRow('Approved', _countByStatus(records, 'Approved'),
							const Color(0xFF0F9D58)),
					const SizedBox(height: 12),
					Text(
						'Approval coverage: ${_approvalCoverage(records).toStringAsFixed(1)}%',
						style: const TextStyle(
							fontSize: 12,
							color: Color(0xFF334155),
							fontWeight: FontWeight.w700,
						),
					),
				],
			),
		);
	}

	Widget _healthRow(String label, int value, Color color) {
		return Row(
			children: [
				Expanded(
					child: Text(
						label,
						style: const TextStyle(
							fontSize: 12,
							fontWeight: FontWeight.w600,
						),
					),
				),
				Container(
					padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
					decoration: BoxDecoration(
						color: color.withOpacity(0.14),
						borderRadius: BorderRadius.circular(999),
					),
					child: Text(
						'$value',
						style: TextStyle(
							color: color,
							fontWeight: FontWeight.w700,
							fontSize: 11,
						),
					),
				),
			],
		);
	}

	double _approvalCoverage(List<_PendingPayrollRecord> records) {
		if (records.isEmpty) {
			return 0;
		}
		final approved = _countByStatus(records, 'Approved');
		return (approved / records.length) * 100;
	}

	Widget _insightPanel({required String title, required Widget child}) {
		return Container(
			width: double.infinity,
			padding: const EdgeInsets.all(14),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(16),
				border: Border.all(color: const Color(0xFFE2E8F0)),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(
						title,
						style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
					),
					const SizedBox(height: 10),
					child,
				],
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
					fontSize: 11,
				),
			),
		);
	}

	Color _statusColor(String status) {
		switch (status) {
			case 'Pending':
				return const Color(0xFF1A73E8);
			case 'Escalated':
				return const Color(0xFFDB4437);
			case 'On Hold':
				return const Color(0xFFF29900);
			case 'Approved':
				return const Color(0xFF0F9D58);
			case 'Rejected':
				return const Color(0xFF7C3AED);
			default:
				return const Color(0xFF64748B);
		}
	}

	Color _priorityColor(String priority) {
		switch (priority) {
			case 'Critical':
				return const Color(0xFFDB4437);
			case 'High':
				return const Color(0xFFF29900);
			default:
				return const Color(0xFF1A73E8);
		}
	}

	String _formatDate(DateTime date) {
		final month = _monthName(date.month);
		final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
		final minute = date.minute.toString().padLeft(2, '0');
		final suffix = date.hour >= 12 ? 'PM' : 'AM';
		return '$month ${date.day}, ${date.year}  $hour:$minute $suffix';
	}

	String _monthName(int month) {
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
		return months[month - 1];
	}

	String _currency(double value) {
		return '\$${value.toStringAsFixed(0)}';
	}
}

class _ApprovalMetric {
	const _ApprovalMetric({
		required this.label,
		required this.value,
		required this.subtitle,
		required this.icon,
		required this.color,
	});

	final String label;
	final String value;
	final String subtitle;
	final IconData icon;
	final Color color;
}

class _PendingPayrollRecord {
	const _PendingPayrollRecord({
		required this.id,
		required this.employeeId,
		required this.employeeName,
		required this.department,
		required this.baseSalary,
		required this.overtime,
		required this.bonus,
		required this.deduction,
		required this.status,
		required this.priority,
		required this.issueType,
		required this.issueDetail,
		required this.variancePct,
		required this.reviewer,
		required this.submittedAt,
	});

	final String id;
	final String employeeId;
	final String employeeName;
	final String department;
	final double baseSalary;
	final double overtime;
	final double bonus;
	final double deduction;
	final String status;
	final String priority;
	final String issueType;
	final String issueDetail;
	final double variancePct;
	final String reviewer;
	final DateTime submittedAt;

	_PendingPayrollRecord copyWith({
		String? status,
	}) {
		return _PendingPayrollRecord(
			id: id,
			employeeId: employeeId,
			employeeName: employeeName,
			department: department,
			baseSalary: baseSalary,
			overtime: overtime,
			bonus: bonus,
			deduction: deduction,
			status: status ?? this.status,
			priority: priority,
			issueType: issueType,
			issueDetail: issueDetail,
			variancePct: variancePct,
			reviewer: reviewer,
			submittedAt: submittedAt,
		);
	}
}
