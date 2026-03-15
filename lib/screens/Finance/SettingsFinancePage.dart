import 'package:flutter/material.dart';

class SettingsFinancePage extends StatefulWidget {
  const SettingsFinancePage({super.key});

  @override
  State<SettingsFinancePage> createState() => _SettingsFinancePageState();
}

class _SettingsFinancePageState extends State<SettingsFinancePage> {
  bool _notificationsEnabled = true;
  bool _emailAlerts = false;
  bool _smsAlerts = true;
  bool _weeklyDigest = true;
  bool _taxReminders = true;
  bool _autoBackup = true;
  bool _requireApprovalForExpense = true;
  bool _twoFactorAuth = false;

  String _currency = 'USD';
  String _dateFormat = 'MM/DD/YYYY';
  String _timezone = 'UTC+05:30';
  String _fiscalYearStart = 'April';
  String _reportDelivery = 'Weekly';
  String _language = 'English';

  bool _hasUnsavedChanges = false;

  void _updateSetting(VoidCallback update) {
    setState(() {
      update();
      _hasUnsavedChanges = true;
    });
  }

  void _resetToDefaults() {
    setState(() {
      _notificationsEnabled = true;
      _emailAlerts = false;
      _smsAlerts = true;
      _weeklyDigest = true;
      _taxReminders = true;
      _autoBackup = true;
      _requireApprovalForExpense = true;
      _twoFactorAuth = false;
      _currency = 'USD';
      _dateFormat = 'MM/DD/YYYY';
      _timezone = 'UTC+05:30';
      _fiscalYearStart = 'April';
      _reportDelivery = 'Weekly';
      _language = 'English';
      _hasUnsavedChanges = false;
    });

    _showMessage('Settings reset to defaults.');
  }

  void _saveChanges() {
    setState(() {
      _hasUnsavedChanges = false;
    });
    _showMessage('Finance settings saved successfully.');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  int _enabledAlertCount() {
    final toggles = [
      _notificationsEnabled,
      _emailAlerts,
      _smsAlerts,
      _weeklyDigest,
      _taxReminders,
    ];
    return toggles.where((v) => v).length;
  }

  int _automationScore() {
    int score = 0;
    if (_autoBackup) score += 45;
    if (_requireApprovalForExpense) score += 35;
    if (_reportDelivery == 'Daily') score += 20;
    if (_reportDelivery == 'Weekly') score += 12;
    return score.clamp(0, 100);
  }

  int _securityScore() {
    int score = 55;
    if (_twoFactorAuth) score += 25;
    if (_requireApprovalForExpense) score += 10;
    if (_autoBackup) score += 10;
    return score.clamp(0, 100);
  }

  String _complianceState() {
    final compliant =
        _taxReminders && _requireApprovalForExpense && _autoBackup;
    return compliant ? 'Ready' : 'Needs Review';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 760;
        final isNarrow = width < 1160;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isCompact),
              const SizedBox(height: 18),
              _buildHeroCard(),
              const SizedBox(height: 18),
              _buildMetricsGrid(width),
              const SizedBox(height: 16),
              if (isNarrow) ...[
                _buildGeneralSettingsPanel(),
                const SizedBox(height: 14),
                _buildNotificationPanel(),
                const SizedBox(height: 14),
                _buildAutomationPanel(),
                const SizedBox(height: 14),
                _buildSecurityAndActionsPanel(),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildGeneralSettingsPanel(),
                          const SizedBox(height: 14),
                          _buildAutomationPanel(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          _buildNotificationPanel(),
                          const SizedBox(height: 14),
                          _buildSecurityAndActionsPanel(),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isCompact) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Settings',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 6),
        Text(
          'Control finance preferences, notifications, automation, and security.',
          style: TextStyle(color: Color(0xFF5F6368)),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        OutlinedButton.icon(
          onPressed: _resetToDefaults,
          icon: const Icon(Icons.restart_alt_rounded, size: 18),
          label: const Text('Reset'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFD5DEE9)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _hasUnsavedChanges ? _saveChanges : null,
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('Save Changes'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A73E8),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFAFC5E8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, const SizedBox(height: 12), actions],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        const SizedBox(width: 14),
        actions,
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF123A68), Color(0xFF1A73E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 14,
        alignment: WrapAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Finance Configuration Center',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Operational Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _heroBadge('Currency', _currency),
              _heroBadge('Fiscal Start', _fiscalYearStart),
              _heroBadge('Security', _twoFactorAuth ? '2FA On' : '2FA Off'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
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
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(double width) {
    final cards = [
      _MetricCardData(
        title: 'Alert Channels',
        value: '${_enabledAlertCount()}/5',
        subtitle: 'Configured notification signals',
        color: const Color(0xFF1A73E8),
        icon: Icons.notifications_active_rounded,
      ),
      _MetricCardData(
        title: 'Automation Score',
        value: '${_automationScore()}%',
        subtitle: 'Backup and approval maturity',
        color: const Color(0xFF0F9D58),
        icon: Icons.auto_awesome_rounded,
      ),
      _MetricCardData(
        title: 'Security Score',
        value: '${_securityScore()}%',
        subtitle: 'Protection and access posture',
        color: const Color(0xFFF29900),
        icon: Icons.security_rounded,
      ),
      _MetricCardData(
        title: 'Compliance State',
        value: _complianceState(),
        subtitle: 'Readiness for finance audits',
        color: _complianceState() == 'Ready'
            ? const Color(0xFF0F9D58)
            : const Color(0xFFDB4437),
        icon: Icons.rule_folder_rounded,
      ),
    ];

    final crossAxisCount = width >= 1280
        ? 4
        : width >= 860
            ? 2
            : 1;

    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 130,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];
        return _panel(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: card.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(card.icon, color: card.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      card.title,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      card.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
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

  Widget _buildGeneralSettingsPanel() {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'General Preferences',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Set regional formats and reporting preferences.',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 14),
          _buildDropdownSetting(
            title: 'Currency',
            subtitle: 'Default money display format',
            value: _currency,
            options: const ['USD', 'EUR', 'GBP', 'INR'],
            onSelected: (value) => _currency = value,
          ),
          const SizedBox(height: 10),
          _buildDropdownSetting(
            title: 'Date Format',
            subtitle: 'Display format across finance modules',
            value: _dateFormat,
            options: const ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'],
            onSelected: (value) => _dateFormat = value,
          ),
          const SizedBox(height: 10),
          _buildDropdownSetting(
            title: 'Timezone',
            subtitle: 'Transaction timestamps and reports',
            value: _timezone,
            options: const ['UTC+05:30', 'UTC+00:00', 'UTC-05:00', 'UTC+01:00'],
            onSelected: (value) => _timezone = value,
          ),
          const SizedBox(height: 10),
          _buildDropdownSetting(
            title: 'Fiscal Year Start',
            subtitle: 'Starting month for fiscal calculations',
            value: _fiscalYearStart,
            options: const ['January', 'April', 'July', 'October'],
            onSelected: (value) => _fiscalYearStart = value,
          ),
          const SizedBox(height: 10),
          _buildDropdownSetting(
            title: 'Report Delivery',
            subtitle: 'Automated report delivery cadence',
            value: _reportDelivery,
            options: const ['Daily', 'Weekly', 'Monthly'],
            onSelected: (value) => _reportDelivery = value,
          ),
          const SizedBox(height: 10),
          _buildDropdownSetting(
            title: 'Language',
            subtitle: 'Language for finance labels and exports',
            value: _language,
            options: const ['English', 'Hindi', 'Spanish', 'French'],
            onSelected: (value) => _language = value,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationPanel() {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notifications',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose when and how finance alerts are delivered.',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 14),
          _buildSwitchSetting(
            title: 'Enable Notifications',
            subtitle: 'Master switch for all finance alert events',
            value: _notificationsEnabled,
            onChanged: (value) => _notificationsEnabled = value,
          ),
          const SizedBox(height: 10),
          _buildSwitchSetting(
            title: 'Email Alerts',
            subtitle: 'Critical updates and monthly report dispatch',
            value: _emailAlerts,
            onChanged: (value) => _emailAlerts = value,
          ),
          const SizedBox(height: 10),
          _buildSwitchSetting(
            title: 'SMS Alerts',
            subtitle: 'High-priority settlement and failure notices',
            value: _smsAlerts,
            onChanged: (value) => _smsAlerts = value,
          ),
          const SizedBox(height: 10),
          _buildSwitchSetting(
            title: 'Weekly Digest',
            subtitle: 'Summary of key transaction and payroll events',
            value: _weeklyDigest,
            onChanged: (value) => _weeklyDigest = value,
          ),
          const SizedBox(height: 10),
          _buildSwitchSetting(
            title: 'Tax Reminders',
            subtitle: 'Advance reminders for tax and filing deadlines',
            value: _taxReminders,
            onChanged: (value) => _taxReminders = value,
          ),
        ],
      ),
    );
  }

  Widget _buildAutomationPanel() {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Automation And Controls',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Define guardrails for backups and expense governance.',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 14),
          _buildSwitchSetting(
            title: 'Automatic Backup',
            subtitle: 'Create nightly snapshots of finance records',
            value: _autoBackup,
            onChanged: (value) => _autoBackup = value,
          ),
          const SizedBox(height: 10),
          _buildSwitchSetting(
            title: 'Require Expense Approval',
            subtitle: 'Mandate manager approval for outgoing expenses',
            value: _requireApprovalForExpense,
            onChanged: (value) => _requireApprovalForExpense = value,
          ),
          const SizedBox(height: 14),
          _buildActionTile(
            icon: Icons.download_rounded,
            title: 'Backup Data',
            subtitle: 'Download a complete finance data backup',
            onTap: () => _showMessage('Backup export started.'),
          ),
          const SizedBox(height: 8),
          _buildActionTile(
            icon: Icons.upload_file_rounded,
            title: 'Import Configuration',
            subtitle: 'Apply a saved settings profile',
            onTap: () => _showMessage('Import flow opened.'),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityAndActionsPanel() {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security And Access',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Protect finance operations and manage account-level actions.',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 14),
          _buildSwitchSetting(
            title: 'Two-Factor Authentication',
            subtitle: 'Add an additional step for sign-in verification',
            value: _twoFactorAuth,
            onChanged: (value) => _twoFactorAuth = value,
          ),
          const SizedBox(height: 14),
          _buildActionTile(
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            subtitle: 'Update account password and session keys',
            onTap: () => _showMessage('Password workflow opened.'),
          ),
          const SizedBox(height: 8),
          _buildActionTile(
            icon: Icons.key_rounded,
            title: 'Manage API Keys',
            subtitle: 'Rotate and revoke integration keys securely',
            onTap: () => _showMessage('API key manager opened.'),
          ),
          const SizedBox(height: 8),
          _buildActionTile(
            icon: Icons.history_rounded,
            title: 'View Audit Trail',
            subtitle: 'Inspect recent security-sensitive changes',
            onTap: () => _showMessage('Audit trail opened.'),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Danger Zone',
                  style: TextStyle(
                    color: Color(0xFFB91C1C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign out from the current finance administration session.',
                  style: TextStyle(
                    color: Color(0xFF991B1B),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFB91C1C),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSetting({
    required String title,
    required String subtitle,
    required String value,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
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
          const SizedBox(width: 10),
          SizedBox(
            width: 170,
            child: DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
                ),
              ),
              items: options
                  .map((option) =>
                      DropdownMenuItem(value: option, child: Text(option)))
                  .toList(),
              onChanged: (selected) {
                if (selected != null) {
                  _updateSetting(() {
                    onSelected(selected);
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
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
          const SizedBox(width: 10),
          Switch(
            value: value,
            onChanged: (newValue) {
              _updateSetting(() {
                onChanged(newValue);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
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
                color: const Color(0xFF1A73E8).withOpacity(0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: const Color(0xFF1A73E8), size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
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
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content:
            const Text('Are you sure you want to logout from this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showMessage('Logout action triggered.');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _MetricCardData {
  const _MetricCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;
}
