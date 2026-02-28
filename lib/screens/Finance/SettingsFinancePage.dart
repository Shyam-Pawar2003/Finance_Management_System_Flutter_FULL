import 'package:flutter/material.dart';

class SettingsFinancePage extends StatefulWidget {
  const SettingsFinancePage({super.key});

  @override
  State<SettingsFinancePage> createState() => _SettingsFinancePageState();
}

class _SettingsFinancePageState extends State<SettingsFinancePage> {
  bool _notificationsEnabled = true;
  bool _emailAlerts = false;
  String _currency = 'USD';
  String _dateFormat = 'MM/DD/YYYY';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildSection('Notifications', [
            _buildSwitchTile(
              'Enable Notifications',
              'Get alerts for financial activities',
              _notificationsEnabled,
              (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            _buildSwitchTile(
              'Email Alerts',
              'Send email for important updates',
              _emailAlerts,
              (value) {
                setState(() {
                  _emailAlerts = value;
                });
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Display', [
            _buildDropdownTile(
              'Currency',
              _currency,
              ['USD', 'EUR', 'GBP', 'INR'],
              (value) {
                setState(() {
                  _currency = value;
                });
              },
            ),
            _buildDropdownTile(
              'Date Format',
              _dateFormat,
              ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'],
              (value) {
                setState(() {
                  _dateFormat = value;
                });
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Account', [
            ListTile(
              title: const Text('Change Password'),
              subtitle: const Text('Update your password'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Two-Factor Authentication'),
              subtitle: const Text('Add extra security to your account'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Backup Data'),
              subtitle: const Text('Download your financial data'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Danger Zone', [
            ListTile(
              title: const Text('Logout'),
              textColor: Colors.red,
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ...children.asMap().entries.map((entry) {
            final isLast = entry.key == children.length - 1;
            return Column(
              children: [
                entry.value,
                if (!isLast) const Divider(height: 1),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildDropdownTile(String title, String value, List<String> options,
      Function(String) onChanged) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        items: options
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (val) {
          if (val != null) onChanged(val);
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
