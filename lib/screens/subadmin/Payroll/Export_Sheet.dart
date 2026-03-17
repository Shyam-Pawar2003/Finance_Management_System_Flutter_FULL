import 'package:flutter/material.dart';

class SubAdminExportSheetPage extends StatefulWidget {
	const SubAdminExportSheetPage({super.key});

	@override
	State<SubAdminExportSheetPage> createState() => _SubAdminExportSheetPageState();
}

class _SubAdminExportSheetPageState extends State<SubAdminExportSheetPage> {
	String _selectedCycle = 'Mar 2026';
	String _selectedDepartment = 'All';
	String _selectedStatus = 'All';
	String _selectedFormat = 'XLSX';

	bool _includeBankInfo = true;
	bool _includeDeductions = true;
	bool _includeAuditTrail = true;

	static const List<String> _cycleOptions = ['Mar 2026', 'Feb 2026', 'Jan 2026'];
	static const List<String> _formatOptions = ['XLSX', 'CSV'];
	static const List<String> _departmentOptions = [
		'All',
		'Finance',
		'Operations',
		'HR',
		'Legal',
	];
	static const List<String> _statusOptions = [
		'All',
		'Ready',
		'Pending Review',
		'Processed',
		'On Hold',
	];

	final List<_ExportRow> _rows = const [
		_ExportRow('PAY-2401', 'Rahul Sharma', 'Finance', 'Ready', 8890),
		_ExportRow('PAY-2402', 'Neha Verma', 'HR', 'Pending Review', 7450),
		_ExportRow('PAY-2403', 'Arjun Mehta', 'Operations', 'Processed', 7130),
		_ExportRow('PAY-2404', 'Sneha Iyer', 'HR', 'Ready', 6180),
		_ExportRow('PAY-2405', 'Karan Patel', 'Finance', 'Processed', 8220),
	];

	List<_ExportRow> get _previewRows {
		return _rows.where((row) {
			final departmentMatch =
					_selectedDepartment == 'All' || row.department == _selectedDepartment;
			final statusMatch = _selectedStatus == 'All' || row.status == _selectedStatus;
			return departmentMatch && statusMatch;
		}).toList();
	}

	int get _columnCount {
		var count = 5;
		if (_includeBankInfo) count += 2;
		if (_includeDeductions) count += 2;
		if (_includeAuditTrail) count += 2;
		return count;
	}

	void _exportSheet() {
		final rows = _previewRows.length;
		final fileName = 'Payroll_Export_${_selectedCycle.replaceAll(' ', '_')}';
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text('$fileName.$_selectedFormat exported with $rows rows.'),
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
						final isCompact = constraints.maxWidth < 980;

						return SingleChildScrollView(
							padding: EdgeInsets.all(isCompact ? 14 : 20),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									_buildHeader(isCompact),
									const SizedBox(height: 16),
									_buildHero(),
									const SizedBox(height: 16),
									if (isCompact) ...[
										_buildConfiguration(),
										const SizedBox(height: 12),
										_buildPreview(),
									] else
										Row(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Expanded(flex: 2, child: _buildConfiguration()),
												const SizedBox(width: 12),
												Expanded(flex: 3, child: _buildPreview()),
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
					'Export Payroll Sheet',
					style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
				),
				SizedBox(height: 6),
				Text(
					'Customize payroll columns and export a clean workbook for operations and audit teams.',
					style: TextStyle(color: Color(0xFF5F6368)),
				),
			],
		);

		final action = FilledButton.icon(
			onPressed: _exportSheet,
			icon: const Icon(Icons.file_download_outlined, size: 18),
			label: const Text('Export Sheet'),
			style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1A73E8)),
		);

		if (isCompact) {
			return Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					title,
					const SizedBox(height: 12),
					action,
				],
			);
		}

		return Row(
			children: [
				Expanded(child: title),
				action,
			],
		);
	}

	Widget _buildHero() {
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
			),
			child: Wrap(
				spacing: 10,
				runSpacing: 10,
				children: [
					_heroChip('Cycle', _selectedCycle),
					_heroChip('Format', _selectedFormat),
					_heroChip('Columns', '$_columnCount'),
					_heroChip('Rows', '${_previewRows.length}'),
				],
			),
		);
	}

	Widget _heroChip(String label, String value) {
		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
			decoration: BoxDecoration(
				color: Colors.white.withOpacity(0.16),
				borderRadius: BorderRadius.circular(999),
			),
			child: Text(
				'$label: $value',
				style: const TextStyle(
					color: Colors.white,
					fontWeight: FontWeight.w700,
					fontSize: 12,
				),
			),
		);
	}

	Widget _buildConfiguration() {
		return _panel(
			title: 'Export Configuration',
			child: Column(
				children: [
					DropdownButtonFormField<String>(
						value: _selectedCycle,
						isExpanded: true,
						decoration: _inputDecoration('Payroll Cycle'),
						items: _cycleOptions
								.map((value) => DropdownMenuItem(value: value, child: Text(value)))
								.toList(),
						onChanged: (value) {
							if (value != null) setState(() => _selectedCycle = value);
						},
					),
					const SizedBox(height: 10),
					DropdownButtonFormField<String>(
						value: _selectedDepartment,
						isExpanded: true,
						decoration: _inputDecoration('Department'),
						items: _departmentOptions
								.map((value) => DropdownMenuItem(value: value, child: Text(value)))
								.toList(),
						onChanged: (value) {
							if (value != null) setState(() => _selectedDepartment = value);
						},
					),
					const SizedBox(height: 10),
					DropdownButtonFormField<String>(
						value: _selectedStatus,
						isExpanded: true,
						decoration: _inputDecoration('Status'),
						items: _statusOptions
								.map((value) => DropdownMenuItem(value: value, child: Text(value)))
								.toList(),
						onChanged: (value) {
							if (value != null) setState(() => _selectedStatus = value);
						},
					),
					const SizedBox(height: 10),
					DropdownButtonFormField<String>(
						value: _selectedFormat,
						isExpanded: true,
						decoration: _inputDecoration('File Format'),
						items: _formatOptions
								.map((value) => DropdownMenuItem(value: value, child: Text(value)))
								.toList(),
						onChanged: (value) {
							if (value != null) setState(() => _selectedFormat = value);
						},
					),
					const SizedBox(height: 10),
					SwitchListTile(
						value: _includeBankInfo,
						onChanged: (value) => setState(() => _includeBankInfo = value),
						contentPadding: EdgeInsets.zero,
						title: const Text('Include bank information columns'),
					),
					SwitchListTile(
						value: _includeDeductions,
						onChanged: (value) => setState(() => _includeDeductions = value),
						contentPadding: EdgeInsets.zero,
						title: const Text('Include deduction breakdown columns'),
					),
					SwitchListTile(
						value: _includeAuditTrail,
						onChanged: (value) => setState(() => _includeAuditTrail = value),
						contentPadding: EdgeInsets.zero,
						title: const Text('Include audit trail columns'),
					),
				],
			),
		);
	}

	Widget _buildPreview() {
		final rows = _previewRows;

		return _panel(
			title: 'Preview Rows',
			child: rows.isEmpty
					? const Padding(
							padding: EdgeInsets.all(14),
							child: Text(
								'No rows available for selected filters.',
								style: TextStyle(color: Color(0xFF64748B)),
							),
						)
					: Column(
							children: rows
									.map(
										(row) => Container(
											margin: const EdgeInsets.only(bottom: 8),
											padding: const EdgeInsets.all(10),
											decoration: BoxDecoration(
												color: const Color(0xFFF8FAFC),
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
																	row.employee,
																	style: const TextStyle(fontWeight: FontWeight.w700),
																),
																Text(
																	'${row.id}  |  ${row.department}  |  ${row.status}',
																	style: const TextStyle(
																		color: Color(0xFF64748B),
																		fontSize: 12,
																	),
																),
															],
														),
													),
													Text(
														_currency(row.netAmount),
														style: const TextStyle(
															color: Color(0xFF0F172A),
															fontWeight: FontWeight.w800,
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

	Widget _panel({required String title, required Widget child}) {
		return Container(
			width: double.infinity,
			padding: const EdgeInsets.all(16),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(14),
				border: Border.all(color: const Color(0xFFE5EBF3)),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(
						title,
						style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
					),
					const SizedBox(height: 10),
					child,
				],
			),
		);
	}

	InputDecoration _inputDecoration(String label) {
		return InputDecoration(
			labelText: label,
			filled: true,
			fillColor: const Color(0xFFF8FAFC),
			border: OutlineInputBorder(
				borderRadius: BorderRadius.circular(10),
				borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
			),
			enabledBorder: OutlineInputBorder(
				borderRadius: BorderRadius.circular(10),
				borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
			),
			contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
		);
	}

	String _currency(double value) {
		return '\$${value.toStringAsFixed(0)}';
	}
}

class _ExportRow {
	const _ExportRow(
		this.id,
		this.employee,
		this.department,
		this.status,
		this.netAmount,
	);

	final String id;
	final String employee;
	final String department;
	final String status;
	final double netAmount;
}
