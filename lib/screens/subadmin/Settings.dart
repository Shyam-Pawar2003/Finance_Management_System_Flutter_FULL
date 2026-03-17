import 'package:flutter/material.dart';

class SubAdminSettingsPage extends StatefulWidget {
  const SubAdminSettingsPage({super.key});

  @override
  State<SubAdminSettingsPage> createState() => _SubAdminSettingsPageState();
}

class _SubAdminSettingsPageState extends State<SubAdminSettingsPage> {
  bool _emailAlerts = true;
  bool _inAppAlerts = true;
  bool _autoSync = true;
  bool _twoFactorRequired = true;
  bool _darkSidebarTheme = true;

  String _sessionTimeout = '30 minutes';
  String _dateFormat = 'DD/MM/YYYY';

  final List<String> _timeoutOptions = const [
    '15 minutes',
    '30 minutes',
    '1 hour',
    '4 hours',
  ];

  final List<String> _dateFormatOptions = const [
    'DD/MM/YYYY',
    'MM/DD/YYYY',
    'YYYY-MM-DD',
  ];

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 980;

        final preferencesCard = _card(
          title: 'Workspace Preferences',
          subtitle:
              'Control notification channels and visual behavior for Subadmin workflows.',
          child: Column(
            children: [
              _switchTile(
                title: 'Email alerts',
                subtitle: 'Send approval and task updates to registered email.',
                value: _emailAlerts,
                onChanged: (value) => setState(() => _emailAlerts = value),
              ),
              _switchTile(
                title: 'In-app alerts',
                subtitle: 'Show real-time notifications in Subadmin panel.',
                value: _inAppAlerts,
                onChanged: (value) => setState(() => _inAppAlerts = value),
              ),
              _switchTile(
                title: 'Automatic data sync',
                subtitle:
                    'Keep attendance, payroll, and recruitment cards synced every 15 minutes.',
                value: _autoSync,
                onChanged: (value) => setState(() => _autoSync = value),
              ),
              _switchTile(
                title: 'Use dark sidebar theme',
                subtitle: 'Preserve current dashboard navigation appearance.',
                value: _darkSidebarTheme,
                onChanged: (value) => setState(() => _darkSidebarTheme = value),
              ),
            ],
          ),
        );

        final securityCard = _card(
          title: 'Security Settings',
          subtitle:
              'Configure account safety controls for this operations console.',
          child: Column(
            children: [
              _switchTile(
                title: 'Require two-factor authentication',
                subtitle: 'Prompt OTP verification for privileged actions.',
                value: _twoFactorRequired,
                onChanged: (value) =>
                    setState(() => _twoFactorRequired = value),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _sessionTimeout,
                isExpanded: true,
                decoration: _inputDecoration(
                  'Session timeout',
                  Icons.timer_outlined,
                ),
                items: _timeoutOptions
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _sessionTimeout = value);
                  }
                },
              ),
            ],
          ),
        );

        final formatAndActionsCard = _card(
          title: 'Regional & Maintenance',
          subtitle:
              'Customize display format and run maintenance actions when needed.',
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _dateFormat,
                isExpanded: true,
                decoration: _inputDecoration(
                    'Date format', Icons.calendar_month_outlined),
                items: _dateFormatOptions
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _dateFormat = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () =>
                        _showMessage('System sync started successfully.'),
                    icon: const Icon(Icons.sync_rounded),
                    label: const Text('Run Sync'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _showMessage('Company settings exported as PDF.'),
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Export Settings'),
                  ),
                  FilledButton.icon(
                    onPressed: () =>
                        _showMessage('Settings saved successfully.'),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save Changes'),
                  ),
                ],
              ),
            ],
          ),
        );

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 14),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: preferencesCard),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          securityCard,
                          const SizedBox(height: 12),
                          formatAndActionsCard,
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                preferencesCard,
                const SizedBox(height: 12),
                securityCard,
                const SizedBox(height: 12),
                formatAndActionsCard,
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF0EA5A4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subadmin Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Manage notifications, security, and workspace behavior in one place.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
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
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1D4ED8), width: 1.3),
      ),
    );
  }
}
