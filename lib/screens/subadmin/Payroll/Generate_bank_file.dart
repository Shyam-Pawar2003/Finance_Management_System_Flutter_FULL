import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';

class SubAdminGenerateBankFilePage extends StatefulWidget {
	const SubAdminGenerateBankFilePage({super.key});

	@override
	State<SubAdminGenerateBankFilePage> createState() =>
			_SubAdminGenerateBankFilePageState();
}

class _SubAdminGenerateBankFilePageState
		extends State<SubAdminGenerateBankFilePage> {
	String _selectedCycle = 'Mar 2026';
	String _selectedBank = 'Primary Salary Bank';
	String _selectedFormat = 'NEFT';
	bool _includeNarration = true;
	bool _onlyVerified = true;
	bool _isGenerating = false;

	static const List<String> _cycleOptions = ['Mar 2026', 'Feb 2026', 'Jan 2026'];
	static const List<String> _bankOptions = [
		'Primary Salary Bank',
		'Secondary Disbursement Bank',
	];
	static const List<String> _formatOptions = ['NEFT', 'RTGS', 'CSV'];

	final List<_BankFileRecord> _records = [
		_BankFileRecord(
			id: 'BNK-3101',
			employee: 'Rahul Sharma',
			accountMasked: 'XXXX7821',
			ifsc: 'HDFC0001290',
			amount: 8890,
			status: 'Verified',
			department: 'Finance',
			selected: true,
		),
		_BankFileRecord(
			id: 'BNK-3102',
			employee: 'Sneha Iyer',
			accountMasked: 'XXXX1142',
			ifsc: 'ICIC0002112',
			amount: 6180,
			status: 'Verified',
			department: 'HR',
			selected: true,
		),
		_BankFileRecord(
			id: 'BNK-3103',
			employee: 'Arjun Mehta',
			accountMasked: 'XXXX6510',
			ifsc: 'SBIN0007730',
			amount: 7130,
			status: 'Verified',
			department: 'Operations',
			selected: true,
		),
		_BankFileRecord(
			id: 'BNK-3104',
			employee: 'Neha Verma',
			accountMasked: 'XXXX7701',
			ifsc: 'KKBK0002101',
			amount: 7450,
			status: 'Pending Verification',
			department: 'HR',
			selected: false,
		),
		_BankFileRecord(
			id: 'BNK-3105',
			employee: 'Karan Patel',
			accountMasked: 'XXXX9020',
			ifsc: 'HDFC0001290',
			amount: 8220,
			status: 'Verified',
			department: 'Finance',
			selected: true,
		),
	];

	List<_BankFileRecord> get _visibleRecords {
		return _records.where((record) {
			if (!_onlyVerified) return true;
			return record.status == 'Verified';
		}).toList();
	}

	int get _selectedCount {
		return _visibleRecords.where((record) => record.selected).length;
	}

	List<_BankFileRecord> get _selectedRecords {
		return _visibleRecords.where((record) => record.selected).toList();
	}

	double get _selectedAmount {
		return _visibleRecords
				.where((record) => record.selected)
				.fold<double>(0, (sum, record) => sum + record.amount);
	}

	void _toggleRecord(_BankFileRecord record, bool selected) {
		final index = _records.indexWhere((item) => item.id == record.id);
		if (index == -1) return;

		setState(() {
			_records[index] = _records[index].copyWith(selected: selected);
		});
	}

	void _toggleAll(bool selected) {
		setState(() {
			for (var i = 0; i < _records.length; i++) {
				if (_onlyVerified && _records[i].status != 'Verified') {
					continue;
				}
				_records[i] = _records[i].copyWith(selected: selected);
			}
		});
	}

	Future<void> _generateFile() async {
		if (_isGenerating) {
			return;
		}

		final selectedRecords = _selectedRecords;
		if (selectedRecords.isEmpty) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text('Select at least one verified record to generate file.'),
					backgroundColor: Color(0xFFDB4437),
				),
			);
			return;
		}

		setState(() {
			_isGenerating = true;
		});

		try {
			final timestamp = DateTime.now().millisecondsSinceEpoch;
			final fileBaseName =
					'BANK_FILE_${_selectedCycle.replaceAll(' ', '_')}_${_selectedFormat.toUpperCase()}_$timestamp';
			final bytes = _buildFileBytes(selectedRecords);
			final saveLocation = await FileSaver.instance.saveFile(
				name: fileBaseName,
				bytes: bytes,
				ext: _fileExtension,
				mimeType: _mimeType,
			);

			if (!mounted) {
				return;
			}

			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Text(
						saveLocation.isNotEmpty
								? 'File generated and downloaded: $saveLocation'
								: 'File generated and downloaded successfully.',
					),
					backgroundColor: const Color(0xFF1A73E8),
				),
			);
		} catch (error) {
			if (!mounted) {
				return;
			}

			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Text('Unable to generate file: $error'),
					backgroundColor: const Color(0xFFDB4437),
				),
			);
		} finally {
			if (mounted) {
				setState(() {
					_isGenerating = false;
				});
			}
		}
	}

	String get _fileExtension {
		return _selectedFormat == 'CSV' ? 'csv' : 'txt';
	}

	MimeType get _mimeType {
		return _selectedFormat == 'CSV' ? MimeType.csv : MimeType.text;
	}

	Uint8List _buildFileBytes(List<_BankFileRecord> records) {
		final content = _buildFileContent(records);
		return Uint8List.fromList(utf8.encode(content));
	}

	String _buildFileContent(List<_BankFileRecord> records) {
		final headers = <String>[
			'ReferenceId',
			'Employee',
			'Department',
			'Account',
			'IFSC',
			'Amount',
			'Bank',
			'Cycle',
			'TransferMode',
			if (_includeNarration) 'Narration',
		];

		final lines = <String>[
			headers.map(_csvValue).join(','),
			...records.map((record) {
				final values = <String>[
					record.id,
					record.employee,
					record.department,
					record.accountMasked,
					record.ifsc,
					record.amount.toStringAsFixed(2),
					_selectedBank,
					_selectedCycle,
					_selectedFormat,
					if (_includeNarration)
						'Payroll payout ${record.id} for ${record.employee} ($_selectedCycle)',
				];
				return values.map(_csvValue).join(',');
			}),
		];

		return lines.join('\n');
	}

	String _csvValue(String value) {
		final escaped = value.replaceAll('"', '""');
		return '"$escaped"';
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
									_buildHeroCard(),
									const SizedBox(height: 16),
									if (isCompact) ...[
										_buildConfigurationPanel(),
										const SizedBox(height: 12),
										_buildRecordPanel(),
									] else
										Row(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Expanded(flex: 2, child: _buildConfigurationPanel()),
												const SizedBox(width: 12),
												Expanded(flex: 3, child: _buildRecordPanel()),
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
					'Generate Bank File',
					style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
				),
				SizedBox(height: 6),
				Text(
					'Prepare bank disbursement file from verified payroll records.',
					style: TextStyle(color: Color(0xFF5F6368)),
				),
			],
		);

		final actions = FilledButton.icon(
			onPressed: _isGenerating ? null : _generateFile,
			icon: _isGenerating
					? const SizedBox(
							width: 16,
							height: 16,
							child: CircularProgressIndicator(strokeWidth: 2),
						)
					: const Icon(Icons.file_present_outlined, size: 18),
			label: Text(_isGenerating ? 'Generating...' : 'Generate File'),
			style: FilledButton.styleFrom(
				backgroundColor: const Color(0xFF1A73E8),
			),
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
			children: [
				Expanded(child: title),
				actions,
			],
		);
	}

	Widget _buildHeroCard() {
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
					_heroChip('Selected', '$_selectedCount records'),
					_heroChip('Payout', _currency(_selectedAmount)),
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
					fontSize: 12,
					fontWeight: FontWeight.w700,
				),
			),
		);
	}

	Widget _buildConfigurationPanel() {
		return _panel(
			title: 'File Configuration',
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
							if (value != null) {
								setState(() => _selectedCycle = value);
							}
						},
					),
					const SizedBox(height: 10),
					DropdownButtonFormField<String>(
						value: _selectedBank,
						isExpanded: true,
						decoration: _inputDecoration('Destination Bank'),
						items: _bankOptions
								.map((value) => DropdownMenuItem(value: value, child: Text(value)))
								.toList(),
						onChanged: (value) {
							if (value != null) {
								setState(() => _selectedBank = value);
							}
						},
					),
					const SizedBox(height: 10),
					DropdownButtonFormField<String>(
						value: _selectedFormat,
						isExpanded: true,
						decoration: _inputDecoration('Transfer Format'),
						items: _formatOptions
								.map((value) => DropdownMenuItem(value: value, child: Text(value)))
								.toList(),
						onChanged: (value) {
							if (value != null) {
								setState(() => _selectedFormat = value);
							}
						},
					),
					const SizedBox(height: 10),
					SwitchListTile(
						value: _includeNarration,
						onChanged: (value) => setState(() => _includeNarration = value),
						contentPadding: EdgeInsets.zero,
						title: const Text('Include transaction narration'),
					),
					SwitchListTile(
						value: _onlyVerified,
						onChanged: (value) => setState(() => _onlyVerified = value),
						contentPadding: EdgeInsets.zero,
						title: const Text('Only include verified records'),
					),
					const SizedBox(height: 10),
					Row(
						children: [
							Expanded(
								child: OutlinedButton(
									onPressed: () => _toggleAll(true),
									child: const Text('Select All'),
								),
							),
							const SizedBox(width: 8),
							Expanded(
								child: OutlinedButton(
									onPressed: () => _toggleAll(false),
									child: const Text('Clear All'),
								),
							),
						],
					),
				],
			),
		);
	}

	Widget _buildRecordPanel() {
		final visible = _visibleRecords;

		return _panel(
			title: 'Eligible Payroll Records',
			child: visible.isEmpty
					? const Padding(
							padding: EdgeInsets.all(14),
							child: Text(
								'No records available for current filter settings.',
								style: TextStyle(color: Color(0xFF64748B)),
							),
						)
					: Column(
							children: visible
									.map(
										(record) => Container(
											margin: const EdgeInsets.only(bottom: 8),
											padding: const EdgeInsets.all(10),
											decoration: BoxDecoration(
												color: const Color(0xFFF8FAFC),
												borderRadius: BorderRadius.circular(10),
												border: Border.all(color: const Color(0xFFE2E8F0)),
											),
											child: Row(
												children: [
													Checkbox(
														value: record.selected,
														onChanged: (value) =>
																_toggleRecord(record, value ?? false),
													),
													const SizedBox(width: 6),
													Expanded(
														child: Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																Text(
																	record.employee,
																	style: const TextStyle(
																		fontWeight: FontWeight.w700,
																	),
																),
																Text(
																	'${record.id}  |  ${record.department}  |  ${record.accountMasked}',
																	style: const TextStyle(
																		color: Color(0xFF64748B),
																		fontSize: 12,
																	),
																),
																Text(
																	'IFSC: ${record.ifsc}',
																	style: const TextStyle(
																		color: Color(0xFF64748B),
																		fontSize: 12,
																	),
																),
															],
														),
													),
													Text(
														_currency(record.amount),
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

class _BankFileRecord {
	const _BankFileRecord({
		required this.id,
		required this.employee,
		required this.accountMasked,
		required this.ifsc,
		required this.amount,
		required this.status,
		required this.department,
		required this.selected,
	});

	final String id;
	final String employee;
	final String accountMasked;
	final String ifsc;
	final double amount;
	final String status;
	final String department;
	final bool selected;

	_BankFileRecord copyWith({bool? selected}) {
		return _BankFileRecord(
			id: id,
			employee: employee,
			accountMasked: accountMasked,
			ifsc: ifsc,
			amount: amount,
			status: status,
			department: department,
			selected: selected ?? this.selected,
		);
	}
}
