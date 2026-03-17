import 'package:flutter/material.dart';

class SubAdminProfilePage extends StatefulWidget {
  const SubAdminProfilePage({super.key});

  @override
  State<SubAdminProfilePage> createState() => _SubAdminProfilePageState();
}

class _SubAdminProfilePageState extends State<SubAdminProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _departmentController;
  late final TextEditingController _locationController;
  late final TextEditingController _bioController;

  bool _isEditing = false;
  bool _emailAlerts = true;
  bool _weeklyDigest = true;
  bool _approvalReminders = true;
  bool _twoFactorAuth = true;

  static const List<_ProfileStat> _profileStats = [
    _ProfileStat(
      title: 'Teams Managed',
      value: '6',
      subtitle: 'Across HR, Finance, Ops',
      icon: Icons.groups_2_outlined,
      color: Color(0xFF1A73E8),
    ),
    _ProfileStat(
      title: 'Approvals Closed',
      value: '142',
      subtitle: 'Current quarter',
      icon: Icons.verified_outlined,
      color: Color(0xFF0F9D58),
    ),
    _ProfileStat(
      title: 'Avg Cycle Time',
      value: '2.4 days',
      subtitle: 'Workflow decisions',
      icon: Icons.timer_outlined,
      color: Color(0xFFF29900),
    ),
    _ProfileStat(
      title: 'Escalations',
      value: '3',
      subtitle: 'This month',
      icon: Icons.priority_high_rounded,
      color: Color(0xFFDB4437),
    ),
  ];

  static const List<_ImpactMetric> _impactMetrics = [
    _ImpactMetric('Leadership Score', 0.91, Color(0xFF1A73E8)),
    _ImpactMetric('Execution Reliability', 0.88, Color(0xFF36B39C)),
    _ImpactMetric('Team Engagement', 0.86, Color(0xFF0F9D58)),
    _ImpactMetric('Company Health Index', 0.87, Color(0xFF7C3AED)),
  ];

  static const List<_TimelineEntry> _timeline = [
    _TimelineEntry(
      title: 'Approved payroll cycle exceptions',
      subtitle: 'Finance Operations | 10:20 AM',
      icon: Icons.account_balance_wallet_outlined,
      color: Color(0xFF1A73E8),
    ),
    _TimelineEntry(
      title: 'Signed off interview panel outcomes',
      subtitle: 'Recruitment | 09:05 AM',
      icon: Icons.how_to_reg_outlined,
      color: Color(0xFF36B39C),
    ),
    _TimelineEntry(
      title: 'Updated attendance policy note',
      subtitle: 'Compliance | Yesterday',
      icon: Icons.policy_outlined,
      color: Color(0xFFF29900),
    ),
    _TimelineEntry(
      title: 'Escalated capacity gap in support team',
      subtitle: 'Operations | Yesterday',
      icon: Icons.flag_outlined,
      color: Color(0xFFDB4437),
    ),
  ];

  static const List<String> _specialties = [
    'People Operations',
    'Policy Governance',
    'Recruitment Operations',
    'Payroll Oversight',
    'Escalation Management',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Shyam Patel');
    _emailController = TextEditingController(text: 'shyam.patel@company.com');
    _phoneController = TextEditingController(text: '+91 98765 44321');
    _departmentController = TextEditingController(text: 'People Operations');
    _locationController = TextEditingController(text: 'Bengaluru, India');
    _bioController = TextEditingController(
      text:
          'Sub Admin responsible for cross-functional HR operations, performance governance, and workflow execution health across departments.',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });

    if (!_isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile details updated successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Sub Admin Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton.icon(
              onPressed: _toggleEdit,
              icon: Icon(
                _isEditing ? Icons.save_outlined : Icons.edit_outlined,
                size: 18,
              ),
              label: Text(_isEditing ? 'Save' : 'Edit'),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isCompact = width < 760;
          final isNarrow = width < 1160;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              isCompact ? 14 : 22,
              isCompact ? 14 : 18,
              isCompact ? 14 : 22,
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroCard(),
                const SizedBox(height: 16),
                _buildStatGrid(width),
                const SizedBox(height: 16),
                if (isNarrow) ...[
                  _buildIdentityPanel(isCompact),
                  const SizedBox(height: 14),
                  _buildDetailsPanel(),
                  const SizedBox(height: 14),
                  _buildPreferencesPanel(),
                  const SizedBox(height: 14),
                  _buildImpactPanel(),
                  const SizedBox(height: 14),
                  _buildTimelinePanel(),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            _buildIdentityPanel(false),
                            const SizedBox(height: 14),
                            _buildDetailsPanel(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _buildPreferencesPanel(),
                            const SizedBox(height: 14),
                            _buildImpactPanel(),
                            const SizedBox(height: 14),
                            _buildTimelinePanel(),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F355B), Color(0xFF36B39C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF36B39C).withOpacity(0.24),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Overview',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Sub Admin Operations Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Access control, approvals, and organization-wide execution monitoring',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _HeroTag(label: 'Role', value: 'Sub Admin'),
              _HeroTag(label: 'Access', value: 'Level 2'),
              _HeroTag(label: 'Status', value: 'Active'),
              _HeroTag(label: 'Region', value: 'India'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(double width) {
    final crossAxisCount = width >= 1300
        ? 4
        : width >= 840
            ? 2
            : 1;

    return GridView.builder(
      itemCount: _profileStats.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 124,
      ),
      itemBuilder: (context, index) {
        final stat = _profileStats[index];
        return _panel(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: stat.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(stat.icon, color: stat.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stat.title,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat.value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      stat.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIdentityPanel(bool isCompact) {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCompact)
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileHeader(),
                SizedBox(height: 12),
              ],
            )
          else
            const _ProfileHeader(),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _specialties
                .map(
                  (skill) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A73E8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      skill,
                      style: const TextStyle(
                        color: Color(0xFF1A73E8),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPanel() {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _field(
            label: 'Full Name',
            icon: Icons.person_outline_rounded,
            controller: _nameController,
          ),
          const SizedBox(height: 10),
          _field(
            label: 'Email Address',
            icon: Icons.alternate_email_rounded,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          _field(
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _field(
                  label: 'Department',
                  icon: Icons.apartment_outlined,
                  controller: _departmentController,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _field(
                  label: 'Location',
                  icon: Icons.location_on_outlined,
                  controller: _locationController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _field(
            label: 'About',
            icon: Icons.notes_rounded,
            controller: _bioController,
            minLines: 3,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor:
            _isEditing ? const Color(0xFFFFFFFF) : const Color(0xFFF8FAFC),
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
          borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 1.4),
        ),
      ),
    );
  }

  Widget _buildPreferencesPanel() {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferences & Security',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _preferenceTile(
            title: 'Email alerts',
            subtitle: 'Receive workflow updates by email.',
            value: _emailAlerts,
            onChanged: (value) => setState(() => _emailAlerts = value),
          ),
          _preferenceTile(
            title: 'Weekly digest',
            subtitle: 'Get weekly performance summary every Friday.',
            value: _weeklyDigest,
            onChanged: (value) => setState(() => _weeklyDigest = value),
          ),
          _preferenceTile(
            title: 'Approval reminders',
            subtitle: 'Notify when approvals are pending > 24 hours.',
            value: _approvalReminders,
            onChanged: (value) => setState(() => _approvalReminders = value),
          ),
          _preferenceTile(
            title: 'Two-factor authentication',
            subtitle: 'Require OTP login for admin actions.',
            value: _twoFactorAuth,
            onChanged: (value) => setState(() => _twoFactorAuth = value),
          ),
        ],
      ),
    );
  }

  Widget _preferenceTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF36B39C),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactPanel() {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manager & Company Impact',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ..._impactMetrics.map(
            (metric) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          metric.label,
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${(metric.value * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: metric.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: metric.value,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(metric.color),
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

  Widget _buildTimelinePanel() {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Profile Activity',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ..._timeline.map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: entry.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(entry.icon, color: entry.color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          entry.subtitle,
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
    );
  }

  Widget _panel({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EBF3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: Color(0xFF1A73E8),
          child: Icon(Icons.person_rounded, color: Colors.white, size: 36),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shyam Patel',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 3),
              Text(
                'Sub Admin | Operations Control',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat {
  const _ProfileStat({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class _ImpactMetric {
  const _ImpactMetric(this.label, this.value, this.color);

  final String label;
  final double value;
  final Color color;
}

class _TimelineEntry {
  const _TimelineEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}
