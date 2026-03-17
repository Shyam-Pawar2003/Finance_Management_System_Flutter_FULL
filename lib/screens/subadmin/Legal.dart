import 'package:flutter/material.dart';

class SubAdminLegalPage extends StatefulWidget {
	const SubAdminLegalPage({super.key});

	@override
	State<SubAdminLegalPage> createState() => _SubAdminLegalPageState();
}

class _SubAdminLegalPageState extends State<SubAdminLegalPage> {
	String _searchQuery = '';
	String _selectedArea = 'All';
	String _selectedPeriod = 'Mar 2026';

	late final TextEditingController _searchController;

	static const List<String> _areaOptions = [
		'All',
		'Contract Review',
		'Compliance',
		'Data Privacy',
		'Policy',
		'Litigation',
	];

	static const List<String> _periodOptions = [
		'Mar 2026',
		'Feb 2026',
		'Q1 2026',
	];

	final List<_LegalInitiative> _initiatives = [
		_LegalInitiative(
			id: 'LEG-501',
			title: 'Vendor contract SLA review sprint',
			area: 'Contract Review',
			owner: 'Ishita Rao',
			status: 'On Track',
			priority: 'High',
			progress: 0.81,
			matters: 18,
			riskFlags: 3,
			nextDeadline: DateTime(2026, 3, 21),
		),
		_LegalInitiative(
			id: 'LEG-502',
			title: 'Expense policy exception audit',
			area: 'Compliance',
			owner: 'S. Bhatt',
			status: 'Needs Review',
			priority: 'High',
			progress: 0.57,
			matters: 12,
			riskFlags: 7,
			nextDeadline: DateTime(2026, 3, 18),
		),
		_LegalInitiative(
			id: 'LEG-503',
			title: 'Employee data retention cleanup',
			area: 'Data Privacy',
			owner: 'Ishita Rao',
			status: 'On Track',
			priority: 'Medium',
			progress: 0.74,
			matters: 9,
			riskFlags: 2,
			nextDeadline: DateTime(2026, 3, 24),
		),
		_LegalInitiative(
			id: 'LEG-504',
			title: 'Policy handbook amendment cycle',
			area: 'Policy',
			owner: 'S. Bhatt',
			status: 'At Risk',
			priority: 'Medium',
			progress: 0.46,
			matters: 11,
			riskFlags: 5,
			nextDeadline: DateTime(2026, 3, 20),
		),
		_LegalInitiative(
			id: 'LEG-505',
			title: 'Regional dispute documentation pack',
			area: 'Litigation',
			owner: 'A. Kapoor',
			status: 'On Track',
			priority: 'High',
			progress: 0.69,
			matters: 6,
			riskFlags: 4,
			nextDeadline: DateTime(2026, 3, 27),
		),
		_LegalInitiative(
			id: 'LEG-506',
			title: 'NDA clause standardization rollout',
			area: 'Contract Review',
			owner: 'Ishita Rao',
			status: 'Needs Review',
			priority: 'Low',
			progress: 0.62,
			matters: 15,
			riskFlags: 1,
			nextDeadline: DateTime(2026, 3, 25),
		),
	];

	final List<_LegalAlert> _alerts = const [
		_LegalAlert(
			title: '4 contracts exceed approval threshold',
			subtitle: 'Commercial terms need legal sign-off before vendor release.',
			color: Color(0xFFDB4437),
			icon: Icons.gavel_outlined,
		),
		_LegalAlert(
			title: 'Policy acknowledgement risk reduced',
			subtitle: 'Open compliance acknowledgements dropped by 16 this week.',
			color: Color(0xFF0F9D58),
			icon: Icons.verified_user_outlined,
		),
		_LegalAlert(
			title: 'Data privacy evidence requested',
			subtitle: 'Retention log attachments must be uploaded before Friday.',
			color: Color(0xFFF29900),
			icon: Icons.security_outlined,
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

	List<_LegalInitiative> get _filteredInitiatives {
		final query = _searchQuery.trim().toLowerCase();

		final list = _initiatives.where((initiative) {
			final matchesSearch = query.isEmpty ||
					initiative.id.toLowerCase().contains(query) ||
					initiative.title.toLowerCase().contains(query) ||
					initiative.owner.toLowerCase().contains(query) ||
					initiative.area.toLowerCase().contains(query);

			final matchesArea =
					_selectedArea == 'All' || initiative.area == _selectedArea;

			return matchesSearch && matchesArea;
		}).toList();

		list.sort((a, b) => b.progress.compareTo(a.progress));
		return list;
	}

	int _countByStatus(List<_LegalInitiative> list, String status) {
		return list.where((initiative) => initiative.status == status).length;
	}

	double _averageProgress(List<_LegalInitiative> list) {
		if (list.isEmpty) {
			return 0;
		}
		final total = list.fold<double>(0, (sum, item) => sum + item.progress);
		return total / list.length;
	}

	int _totalMatters(List<_LegalInitiative> list) {
		return list.fold<int>(0, (sum, item) => sum + item.matters);
	}

	int _totalRiskFlags(List<_LegalInitiative> list) {
		return list.fold<int>(0, (sum, item) => sum + item.riskFlags);
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
						final initiatives = _filteredInitiatives;

						return SingleChildScrollView(
							padding: EdgeInsets.all(isCompact ? 14 : 20),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									_buildHeader(isCompact),
									const SizedBox(height: 16),
									_buildHeroCard(initiatives),
									const SizedBox(height: 16),
									_buildMetricGrid(width, initiatives),
									const SizedBox(height: 16),
									if (isNarrow) ...[
										_buildOperationsPanel(initiatives, isCompact),
										const SizedBox(height: 14),
										_buildInsightsPanel(initiatives),
									] else
										Row(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Expanded(
													flex: 3,
													child: _buildOperationsPanel(initiatives, false),
												),
												const SizedBox(width: 16),
												Expanded(
													flex: 2,
													child: _buildInsightsPanel(initiatives),
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
					'Legal Governance Desk',
					style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
				),
				SizedBox(height: 6),
				Text(
					'Track contracts, compliance reviews, policy changes, privacy work, and legal risk exposure.',
					style: TextStyle(color: Color(0xFF5F6368)),
				),
			],
		);

		final actions = Wrap(
			spacing: 8,
			runSpacing: 8,
			children: [
				OutlinedButton.icon(
					onPressed: () {},
					icon: const Icon(Icons.file_download_outlined, size: 18),
					label: const Text('Export Legal Summary'),
					style: OutlinedButton.styleFrom(
						foregroundColor: const Color(0xFF0F172A),
						side: const BorderSide(color: Color(0xFFD6DEE8)),
					),
				),
				FilledButton.icon(
					onPressed: () {},
					icon: const Icon(Icons.verified_outlined, size: 18),
					label: const Text('Review Risks'),
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

	Widget _buildHeroCard(List<_LegalInitiative> initiatives) {
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
						width: 380,
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									'Legal Risk Pulse',
									style: TextStyle(
										color: Colors.white,
										fontSize: 22,
										fontWeight: FontWeight.w800,
									),
								),
								SizedBox(height: 8),
								Text(
									'Keep contracts, disputes, compliance obligations, and privacy controls aligned around deadlines and exposure.',
									style: TextStyle(color: Colors.white70, height: 1.4),
								),
							],
						),
					),
					_heroBadge(Icons.description_outlined,
							'${_totalMatters(initiatives)} Legal Matters'),
					_heroBadge(Icons.warning_amber_rounded,
							'${_totalRiskFlags(initiatives)} Risk Flags'),
					_heroBadge(Icons.fact_check_outlined,
							'${_countByStatus(initiatives, 'Needs Review')} Needs Review'),
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

	Widget _buildMetricGrid(double width, List<_LegalInitiative> initiatives) {
		int columns = 4;
		if (width < 1180) {
			columns = 2;
		}
		if (width < 700) {
			columns = 1;
		}

		final metrics = [
			_LegalMetricCard(
				title: 'On Track',
				value: '${_countByStatus(initiatives, 'On Track')}',
				hint: 'Healthy legal workflows',
				color: const Color(0xFF0F9D58),
				icon: Icons.check_circle_outline_rounded,
			),
			_LegalMetricCard(
				title: 'Needs Review',
				value: '${_countByStatus(initiatives, 'Needs Review')}',
				hint: 'Awaiting legal validation',
				color: const Color(0xFFF29900),
				icon: Icons.rule_folder_outlined,
			),
			_LegalMetricCard(
				title: 'Avg Progress',
				value: '${(_averageProgress(initiatives) * 100).toStringAsFixed(0)}%',
				hint: 'Across filtered items',
				color: const Color(0xFF1A73E8),
				icon: Icons.timeline_rounded,
			),
			_LegalMetricCard(
				title: 'High Priority',
				value: '${initiatives.where((item) => item.priority == 'High').length}',
				hint: 'Require active oversight',
				color: const Color(0xFFDB4437),
				icon: Icons.priority_high_rounded,
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

	Widget _buildOperationsPanel(
		List<_LegalInitiative> initiatives,
		bool isCompact,
	) {
		return _panel(
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					const Text(
						'Legal Workstreams',
						style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
					),
					const SizedBox(height: 6),
					const Text(
						'Search current legal initiatives and review exposure across contracts, policy, and compliance work.',
						style: TextStyle(color: Color(0xFF64748B)),
					),
					const SizedBox(height: 14),
					_buildFilters(isCompact),
					const SizedBox(height: 14),
					if (initiatives.isEmpty)
						Container(
							width: double.infinity,
							padding: const EdgeInsets.all(16),
							decoration: BoxDecoration(
								color: const Color(0xFFF8FAFF),
								borderRadius: BorderRadius.circular(12),
								border: Border.all(color: const Color(0xFFDCE6F3)),
							),
							child: const Text(
								'No legal initiatives match the selected filters.',
								style: TextStyle(color: Color(0xFF64748B)),
							),
						)
					else
						...initiatives.map(_buildInitiativeCard),
				],
			),
		);
	}

	Widget _buildFilters(bool isCompact) {
		final searchField = TextField(
			controller: _searchController,
			onChanged: (value) {
				setState(() {
					_searchQuery = value;
				});
			},
			decoration: _inputDecoration('Search by initiative, owner, area').copyWith(
				prefixIcon: const Icon(Icons.search_rounded),
			),
		);

		final areaField = DropdownButtonFormField<String>(
			value: _selectedArea,
			items: _areaOptions
					.map((area) => DropdownMenuItem(value: area, child: Text(area)))
					.toList(),
			onChanged: (value) {
				if (value == null) {
					return;
				}
				setState(() {
					_selectedArea = value;
				});
			},
			decoration: _inputDecoration('Area'),
		);

		final periodField = DropdownButtonFormField<String>(
			value: _selectedPeriod,
			items: _periodOptions
					.map((period) => DropdownMenuItem(value: period, child: Text(period)))
					.toList(),
			onChanged: (value) {
				if (value == null) {
					return;
				}
				setState(() {
					_selectedPeriod = value;
				});
			},
			decoration: _inputDecoration('Period'),
		);

		if (isCompact) {
			return Column(
				children: [
					searchField,
					const SizedBox(height: 10),
					areaField,
					const SizedBox(height: 10),
					periodField,
				],
			);
		}

		return Column(
			children: [
				searchField,
				const SizedBox(height: 10),
				Row(
					children: [
						Expanded(child: areaField),
						const SizedBox(width: 10),
						Expanded(child: periodField),
					],
				),
			],
		);
	}

	Widget _buildInitiativeCard(_LegalInitiative initiative) {
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
							Container(
								padding: const EdgeInsets.all(10),
								decoration: BoxDecoration(
									color: _areaColor(initiative.area).withOpacity(0.12),
									borderRadius: BorderRadius.circular(12),
								),
								child: Icon(
									Icons.balance_outlined,
									size: 20,
									color: _areaColor(initiative.area),
								),
							),
							const SizedBox(width: 10),
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											initiative.title,
											style: const TextStyle(
												fontSize: 15,
												fontWeight: FontWeight.w700,
												color: Color(0xFF0F172A),
											),
										),
										const SizedBox(height: 3),
										Text(
											'${initiative.id}  •  ${initiative.owner}  •  ${initiative.area}',
											style: const TextStyle(
												color: Color(0xFF64748B),
												fontWeight: FontWeight.w500,
											),
										),
									],
								),
							),
							const SizedBox(width: 8),
							_chip(initiative.status, _statusColor(initiative.status)),
						],
					),
					const SizedBox(height: 10),
					Wrap(
						spacing: 8,
						runSpacing: 8,
						children: [
							_detailChip(Icons.flag_outlined, initiative.priority),
							_detailChip(Icons.folder_open_outlined,
									'${initiative.matters} matters'),
							_detailChip(Icons.warning_amber_rounded,
									'${initiative.riskFlags} risk flags'),
							_detailChip(
								Icons.event_outlined,
								'Due ${_formatDate(initiative.nextDeadline)}',
							),
						],
					),
					const SizedBox(height: 10),
					ClipRRect(
						borderRadius: BorderRadius.circular(8),
						child: LinearProgressIndicator(
							minHeight: 8,
							value: initiative.progress,
							color: _statusColor(initiative.status),
							backgroundColor: const Color(0xFFDCE6F3),
						),
					),
					const SizedBox(height: 8),
					Text(
						'Progress ${(initiative.progress * 100).toStringAsFixed(0)}%',
						style: const TextStyle(
							color: Color(0xFF64748B),
							fontWeight: FontWeight.w600,
						),
					),
				],
			),
		);
	}

	Widget _buildInsightsPanel(List<_LegalInitiative> initiatives) {
		final sortedByDeadline = [...initiatives]
			..sort((a, b) => a.nextDeadline.compareTo(b.nextDeadline));

		return Column(
			children: [
				_panel(
					padding: const EdgeInsets.all(16),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							const Text(
								'Legal Priorities',
								style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
							),
							const SizedBox(height: 10),
							_signalRow('Contract approvals pending', '4 pending', const Color(0xFFDB4437)),
							const SizedBox(height: 8),
							_signalRow('Privacy evidence requests', '3 open', const Color(0xFFF29900)),
							const SizedBox(height: 8),
							_signalRow('Policy updates published', '9 this month', const Color(0xFF1A73E8)),
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
							if (sortedByDeadline.isEmpty)
								const Text(
									'No initiatives available.',
									style: TextStyle(color: Color(0xFF64748B)),
								)
							else
								...sortedByDeadline.take(4).map(
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
																item.title,
																maxLines: 1,
																overflow: TextOverflow.ellipsis,
																style: const TextStyle(fontWeight: FontWeight.w700),
															),
															const SizedBox(height: 2),
															Text(
																item.area,
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
													_formatDate(item.nextDeadline),
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
				const SizedBox(height: 14),
				_panel(
					padding: const EdgeInsets.all(16),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							const Text(
								'Legal Signals',
								style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
							),
							const SizedBox(height: 10),
							..._alerts.map(
								(alert) => Container(
									width: double.infinity,
									margin: const EdgeInsets.only(bottom: 8),
									padding: const EdgeInsets.all(10),
									decoration: BoxDecoration(
										borderRadius: BorderRadius.circular(10),
										color: alert.color.withOpacity(0.08),
										border: Border.all(color: alert.color.withOpacity(0.18)),
									),
									child: Row(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Icon(alert.icon, size: 18, color: alert.color),
											const SizedBox(width: 8),
											Expanded(
												child: Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														Text(
															alert.title,
															style: TextStyle(
																color: alert.color,
																fontWeight: FontWeight.w700,
															),
														),
														const SizedBox(height: 2),
														Text(
															alert.subtitle,
															style: const TextStyle(
																color: Color(0xFF64748B),
																fontSize: 12,
															),
														),
													],
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

	Widget _signalRow(String title, String value, Color color) {
		return Container(
			padding: const EdgeInsets.all(10),
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(10),
				border: Border.all(color: const Color(0xFFE2E8F0)),
			),
			child: Row(
				children: [
					Expanded(
						child: Text(
							title,
							style: const TextStyle(fontWeight: FontWeight.w600),
						),
					),
					Text(
						value,
						style: TextStyle(
							color: color,
							fontWeight: FontWeight.w800,
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
			case 'On Track':
				return const Color(0xFF0F9D58);
			case 'At Risk':
				return const Color(0xFFDB4437);
			case 'Needs Review':
				return const Color(0xFFF29900);
			default:
				return const Color(0xFF64748B);
		}
	}

	Color _areaColor(String area) {
		switch (area) {
			case 'Contract Review':
				return const Color(0xFF1A73E8);
			case 'Compliance':
				return const Color(0xFF36B39C);
			case 'Data Privacy':
				return const Color(0xFF7C3AED);
			case 'Policy':
				return const Color(0xFFF29900);
			case 'Litigation':
				return const Color(0xFFDB4437);
			default:
				return const Color(0xFF64748B);
		}
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

class _LegalInitiative {
	const _LegalInitiative({
		required this.id,
		required this.title,
		required this.area,
		required this.owner,
		required this.status,
		required this.priority,
		required this.progress,
		required this.matters,
		required this.riskFlags,
		required this.nextDeadline,
	});

	final String id;
	final String title;
	final String area;
	final String owner;
	final String status;
	final String priority;
	final double progress;
	final int matters;
	final int riskFlags;
	final DateTime nextDeadline;
}

class _LegalAlert {
	const _LegalAlert({
		required this.title,
		required this.subtitle,
		required this.color,
		required this.icon,
	});

	final String title;
	final String subtitle;
	final Color color;
	final IconData icon;
}

class _LegalMetricCard {
	const _LegalMetricCard({
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
