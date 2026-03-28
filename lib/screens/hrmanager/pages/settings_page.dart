import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finance_flutter_full/providers/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _weeklyDigest = true;
  bool _autoApproveLeave = false;
  bool _biometricSignIn = false;
  String _selectedLanguage = 'English';
  String _selectedWorkWeek = 'Monday - Friday';

  void _showSavedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings updated successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HR Settings',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Manage HR preferences, communication controls, and workspace settings.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showSavedMessage(context),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth >= 1000
                  ? (constraints.maxWidth - 24) / 3
                  : constraints.maxWidth >= 700
                      ? (constraints.maxWidth - 12) / 2
                      : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _SummaryCard(
                    width: cardWidth,
                    title: 'Theme',
                    value: themeProvider.isDark ? 'Dark' : 'Light',
                    icon: Icons.palette_outlined,
                    color: Colors.indigo,
                  ),
                  _SummaryCard(
                    width: cardWidth,
                    title: 'Notifications',
                    value: _notificationsEnabled ? 'Enabled' : 'Muted',
                    icon: Icons.notifications_active_outlined,
                    color: Colors.orange,
                  ),
                  _SummaryCard(
                    width: cardWidth,
                    title: 'Leave Workflow',
                    value:
                        _autoApproveLeave ? 'Auto-Approve' : 'Manual Approval',
                    icon: Icons.approval_outlined,
                    color: Colors.green,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Appearance',
            subtitle: 'Set visual preferences used across HR workspace.',
            child: Column(
              children: [
                _SettingTile(
                  title: 'Dark Mode',
                  subtitle:
                      'Switch the application theme between light and dark.',
                  trailing: Switch(
                    value: themeProvider.isDark,
                    onChanged: (_) => themeProvider.toggleDark(),
                  ),
                ),
                const Divider(height: 24),
                _DropdownSettingTile(
                  title: 'Language',
                  subtitle: 'Choose the display language for HR pages.',
                  value: _selectedLanguage,
                  items: const ['English', 'Hindi', 'Marathi'],
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Notifications',
            subtitle: 'Control who gets informed and how often.',
            child: Column(
              children: [
                _SettingTile(
                  title: 'Push Notifications',
                  subtitle:
                      'Send HR alerts for approvals, reviews, and attendance.',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ),
                const Divider(height: 24),
                _SettingTile(
                  title: 'Weekly Digest',
                  subtitle: 'Send a weekly HR summary every Friday evening.',
                  trailing: Switch(
                    value: _weeklyDigest,
                    onChanged: (value) {
                      setState(() {
                        _weeklyDigest = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Workflow & Security',
            subtitle: 'Tune leave approval and sign-in behavior.',
            child: Column(
              children: [
                _SettingTile(
                  title: 'Auto-Approve Leave Requests',
                  subtitle:
                      'Automatically approve eligible low-risk leave requests.',
                  trailing: Switch(
                    value: _autoApproveLeave,
                    onChanged: (value) {
                      setState(() {
                        _autoApproveLeave = value;
                      });
                    },
                  ),
                ),
                const Divider(height: 24),
                _SettingTile(
                  title: 'Biometric Sign-In',
                  subtitle: 'Require device biometrics for HR admin access.',
                  trailing: Switch(
                    value: _biometricSignIn,
                    onChanged: (value) {
                      setState(() {
                        _biometricSignIn = value;
                      });
                    },
                  ),
                ),
                const Divider(height: 24),
                _DropdownSettingTile(
                  title: 'Default Work Week',
                  subtitle: 'Used for attendance and leave calculations.',
                  value: _selectedWorkWeek,
                  items: const [
                    'Monday - Friday',
                    'Monday - Saturday',
                    'Sunday - Thursday',
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedWorkWeek = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.width,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final double width;
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        trailing,
      ],
    );
  }
}

class _DropdownSettingTile extends StatelessWidget {
  const _DropdownSettingTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<String>(
            value: value,
            items: items
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ),
                )
                .toList(),
            onChanged: (selected) {
              if (selected != null) {
                onChanged(selected);
              }
            },
            decoration: const InputDecoration(isDense: true),
          ),
        ),
      ],
    );
  }
}
