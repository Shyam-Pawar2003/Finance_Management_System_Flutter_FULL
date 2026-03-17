import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color _bgTop = Color(0xFF0A1A08);
  static const Color _bgBottom = Color(0xFF050C04);
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  bool _notificationsEnabled = true;
  bool _twoFactorEnabled = false;
  String _selectedCurrency = 'INR';
  bool _isEditMode = false;

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final currentController = TextEditingController();
    final nextController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Current password'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nextController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (currentController.text.trim().isEmpty ||
                    nextController.text.trim().length < 8) {
                  _showMessage(
                      'Use your current password and a new password with at least 8 characters.');
                  return;
                }

                Navigator.of(dialogContext).pop();
                _showMessage('Password updated successfully.');
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    currentController.dispose();
    nextController.dispose();
  }

  Future<void> _confirmSignOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Do you want to sign out from this device?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (shouldSignOut == true) {
      _showMessage('Signed out successfully.');
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'This action is permanent. Do you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      _showMessage('Account deletion request submitted.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBottom,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });
              _showMessage(
                _isEditMode ? 'Edit mode enabled.' : 'Edit mode disabled.',
              );
            },
            tooltip: 'Toggle edit mode',
            icon: const Icon(Icons.edit_rounded, color: _textPrimary),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          Positioned(top: -130, right: -80, child: _glow(280)),
          Positioned(bottom: -120, left: -70, child: _glow(220)),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_bgTop, _bgBottom],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  _buildProfileHeader(),
                  const SizedBox(height: 28),

                  // Account Section
                  _buildSectionTitle('Account Information'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                      'Email', 'john.doe@example.com', Icons.email_rounded),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                      'Phone', '+91 98765 43210', Icons.phone_rounded),
                  const SizedBox(height: 10),
                  _buildInfoCard('Member Since', 'March 2024',
                      Icons.calendar_today_rounded),
                  const SizedBox(height: 28),

                  // Preferences Section
                  _buildSectionTitle('Preferences'),
                  const SizedBox(height: 12),
                  _buildDropdownCard('Currency', _selectedCurrency,
                      ['USD', 'EUR', 'INR', 'GBP', 'AED']),
                  const SizedBox(height: 28),

                  // Notifications Section
                  _buildSectionTitle('Notifications'),
                  const SizedBox(height: 12),
                  _buildToggleCard(
                    title: 'Email Notifications',
                    subtitle: 'Receive payment reminders',
                    value: _notificationsEnabled,
                    onChanged: (val) {
                      setState(() => _notificationsEnabled = val);
                      _showMessage(
                        val
                            ? 'Email notifications enabled.'
                            : 'Email notifications disabled.',
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // Security Section
                  _buildSectionTitle('Security'),
                  const SizedBox(height: 12),
                  _buildToggleCard(
                    title: 'Two-Factor Authentication',
                    subtitle: 'Enhanced account security',
                    value: _twoFactorEnabled,
                    onChanged: (val) {
                      setState(() => _twoFactorEnabled = val);
                      _showMessage(
                        val
                            ? 'Two-factor authentication enabled.'
                            : 'Two-factor authentication disabled.',
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildActionCard(
                    icon: Icons.lock_rounded,
                    title: 'Change Password',
                    subtitle: 'Update your password',
                    color: Color(0xFF5B6FFF),
                    onTap: _showChangePasswordDialog,
                  ),
                  const SizedBox(height: 28),

                  // Danger Zone
                  _buildSectionTitle('Account'),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    subtitle: 'Log out from this device',
                    color: Colors.orange,
                    onTap: _confirmSignOut,
                  ),
                  const SizedBox(height: 10),
                  _buildActionCard(
                    icon: Icons.delete_rounded,
                    title: 'Delete Account',
                    subtitle: 'Permanently delete your account',
                    color: Colors.red.shade400,
                    onTap: _confirmDeleteAccount,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _lime.withOpacity(0.09),
        ),
      );

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _lime.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_lime, _lime.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _lime.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'JD',
                style: TextStyle(
                  color: Color(0xFF050C04),
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          const Text(
            'John Doe',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),

          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _lime.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _lime,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Premium Member',
                  style: TextStyle(
                    color: _lime,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                  'Dashboard', '5', Icons.dashboard_customize_rounded),
              _buildStatItem('Transactions', '237', Icons.swap_horiz_rounded),
              _buildStatItem(
                  'Investments', '12', Icons.candlestick_chart_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: _lime, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: _textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: _textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _lime.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _lime.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _lime, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: _textMuted),
        ],
      ),
    );
  }

  Widget _buildDropdownCard(String label, String value, List<String> options) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _lime.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: _cardDark,
            underline: const SizedBox(),
            items: options
                .map((opt) => DropdownMenuItem(
                      value: opt,
                      child: Text(
                        opt,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedCurrency = val);
                _showMessage('Currency updated to $val.');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleCard({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _lime.withOpacity(0.08)),
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
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _lime,
            activeTrackColor: _lime.withOpacity(0.3),
            inactiveThumbColor: _textMuted,
            inactiveTrackColor: _textMuted.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
      ),
    );
  }
}
