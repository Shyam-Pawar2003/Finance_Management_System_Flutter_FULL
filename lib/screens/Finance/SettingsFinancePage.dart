import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:math';

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

  String _currentPassword = 'Finance@123';
  DateTime? _lastPasswordChanged;

  final Random _random = Random.secure();
  final List<_ApiKeyRecord> _apiKeys = [
    _ApiKeyRecord(
      id: 'KEY-201',
      label: 'Payroll Sync',
      value: 'fin_live_8Dk3PzTjQ4nY2vLmK9xR6aBcH1uW7sEf',
      createdAt: DateTime(2026, 1, 18, 10, 20),
      lastUsedAt: DateTime(2026, 3, 15, 16, 10),
      isActive: true,
    ),
    _ApiKeyRecord(
      id: 'KEY-202',
      label: 'Invoice Webhook',
      value: 'fin_live_4aZ2mQ9kL7pT5vBhN3xW6yR1cS8dEfUg',
      createdAt: DateTime(2026, 2, 2, 14, 45),
      lastUsedAt: DateTime(2026, 3, 11, 9, 5),
      isActive: true,
    ),
  ];

  final List<_AuditTrailEntry> _auditTrail = [];

  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _recordAudit(
      'Settings opened',
      'Finance settings dashboard accessed.',
      icon: Icons.settings_rounded,
      color: const Color(0xFF1A73E8),
    );
  }

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
      _recordAudit(
        'Defaults restored',
        'All finance settings were reset to default values.',
        icon: Icons.restart_alt_rounded,
        color: const Color(0xFF1A73E8),
      );
    });

    _showMessage('Settings reset to defaults.');
  }

  void _saveChanges() {
    setState(() {
      _hasUnsavedChanges = false;
      _recordAudit(
        'Settings saved',
        'Finance settings changes were saved.',
        icon: Icons.save_outlined,
        color: const Color(0xFF0F9D58),
      );
    });
    _showMessage('Finance settings saved successfully.');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _recordAudit(
    String title,
    String detail, {
    IconData icon = Icons.history_rounded,
    Color color = const Color(0xFF1A73E8),
  }) {
    _auditTrail.insert(
      0,
      _AuditTrailEntry(
        title: title,
        detail: detail,
        timestamp: DateTime.now(),
        icon: icon,
        color: color,
      ),
    );
    if (_auditTrail.length > 120) {
      _auditTrail.removeLast();
    }
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return 'Never';
    }
    final date = value;
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} $hour:$minute $suffix';
  }

  bool _isStrongPassword(String value) {
    final hasUpper = RegExp(r'[A-Z]').hasMatch(value);
    final hasLower = RegExp(r'[a-z]').hasMatch(value);
    final hasDigit = RegExp(r'\d').hasMatch(value);
    final hasSpecial =
        RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:\\|,.<>\/?]').hasMatch(value);
    return value.length >= 8 && hasUpper && hasLower && hasDigit && hasSpecial;
  }

  String _generateApiKeyValue() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final bytes =
        List.generate(32, (_) => chars[_random.nextInt(chars.length)]).join();
    return 'fin_live_$bytes';
  }

  String _maskApiKey(String raw) {
    if (raw.length <= 10) {
      return '**********';
    }
    return '${raw.substring(0, 8)}...${raw.substring(raw.length - 6)}';
  }

  Future<void> _runBackupData() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Expanded(child: Text('Preparing finance backup...')),
            ],
          ),
        );
      },
    );

    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.of(context).pop();

    setState(() {
      _recordAudit(
        'Backup exported',
        'Finance backup package export was initiated.',
        icon: Icons.download_rounded,
        color: const Color(0xFF0F9D58),
      );
    });

    _showMessage('Finance backup export started successfully.');
  }

  Future<void> _showImportConfigurationDialog() async {
    String selectedPreset = 'Compliance Focus';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Import Configuration'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Choose a predefined settings profile to apply.',
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedPreset,
                    items: const [
                      DropdownMenuItem(
                        value: 'Compliance Focus',
                        child: Text('Compliance Focus'),
                      ),
                      DropdownMenuItem(
                        value: 'Automation Focus',
                        child: Text('Automation Focus'),
                      ),
                      DropdownMenuItem(
                        value: 'Minimal Alerts',
                        child: Text('Minimal Alerts'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedPreset = value;
                        });
                      }
                    },
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
                    _updateSetting(() {
                      if (selectedPreset == 'Compliance Focus') {
                        _notificationsEnabled = true;
                        _emailAlerts = true;
                        _smsAlerts = true;
                        _weeklyDigest = true;
                        _taxReminders = true;
                        _autoBackup = true;
                        _requireApprovalForExpense = true;
                        _twoFactorAuth = true;
                        _reportDelivery = 'Weekly';
                      } else if (selectedPreset == 'Automation Focus') {
                        _notificationsEnabled = true;
                        _emailAlerts = true;
                        _smsAlerts = false;
                        _weeklyDigest = true;
                        _taxReminders = true;
                        _autoBackup = true;
                        _requireApprovalForExpense = false;
                        _twoFactorAuth = false;
                        _reportDelivery = 'Daily';
                      } else {
                        _notificationsEnabled = true;
                        _emailAlerts = true;
                        _smsAlerts = false;
                        _weeklyDigest = false;
                        _taxReminders = true;
                        _autoBackup = true;
                        _requireApprovalForExpense = true;
                        _twoFactorAuth = false;
                        _reportDelivery = 'Monthly';
                      }

                      _recordAudit(
                        'Configuration imported',
                        'Applied "$selectedPreset" settings profile.',
                        icon: Icons.upload_file_rounded,
                        color: const Color(0xFF1A73E8),
                      );
                    });

                    Navigator.of(dialogContext).pop();
                    _showMessage(
                        'Configuration profile "$selectedPreset" imported.');
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final currentController = TextEditingController();
    final nextController = TextEditingController();
    final confirmController = TextEditingController();
    String? error;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentController,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'Current Password'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nextController,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'New Password'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: confirmController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Confirm New Password'),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        error!,
                        style: const TextStyle(
                          color: Color(0xFFB91C1C),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final current = currentController.text.trim();
                    final next = nextController.text.trim();
                    final confirm = confirmController.text.trim();

                    if (current != _currentPassword) {
                      setDialogState(() {
                        error = 'Current password is incorrect.';
                      });
                      return;
                    }

                    if (next == _currentPassword) {
                      setDialogState(() {
                        error =
                            'New password must be different from current password.';
                      });
                      return;
                    }

                    if (!_isStrongPassword(next)) {
                      setDialogState(() {
                        error =
                            'Use at least 8 chars with upper, lower, number, and symbol.';
                      });
                      return;
                    }

                    if (next != confirm) {
                      setDialogState(() {
                        error = 'Confirmation password does not match.';
                      });
                      return;
                    }

                    setState(() {
                      _currentPassword = next;
                      _lastPasswordChanged = DateTime.now();
                      _recordAudit(
                        'Password changed',
                        'Finance account password was updated.',
                        icon: Icons.lock_outline_rounded,
                        color: const Color(0xFF0F9D58),
                      );
                    });

                    Navigator.of(dialogContext).pop();
                    _showMessage('Password changed successfully.');
                  },
                  child: const Text('Update Password'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showCreateApiKeyDialog({VoidCallback? onCreated}) async {
    final labelController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Create API Key'),
          content: TextField(
            controller: labelController,
            decoration: const InputDecoration(
              labelText: 'Key Label',
              hintText: 'Example: ERP Sync',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final label = labelController.text.trim();
                if (label.isEmpty) {
                  _showMessage('Please enter a label for the API key.');
                  return;
                }

                setState(() {
                  final key = _ApiKeyRecord(
                    id: 'KEY-${200 + _apiKeys.length + 1}',
                    label: label,
                    value: _generateApiKeyValue(),
                    createdAt: DateTime.now(),
                    lastUsedAt: null,
                    isActive: true,
                  );
                  _apiKeys.insert(0, key);
                  _recordAudit(
                    'API key created',
                    'Created API key "$label".',
                    icon: Icons.key_rounded,
                    color: const Color(0xFF1A73E8),
                  );
                });

                Navigator.of(dialogContext).pop();
                onCreated?.call();
                _showMessage('API key created successfully.');
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _rotateApiKey(_ApiKeyRecord key) {
    setState(() {
      final index = _apiKeys.indexWhere((item) => item.id == key.id);
      if (index == -1) {
        return;
      }
      _apiKeys[index] = _apiKeys[index].copyWith(
        value: _generateApiKeyValue(),
        lastUsedAt: DateTime.now(),
      );
      _recordAudit(
        'API key rotated',
        'Rotated key "${key.label}" (${key.id}).',
        icon: Icons.refresh_rounded,
        color: const Color(0xFFF29900),
      );
    });
    _showMessage('API key rotated for ${key.label}.');
  }

  void _toggleApiKeyState(_ApiKeyRecord key) {
    setState(() {
      final index = _apiKeys.indexWhere((item) => item.id == key.id);
      if (index == -1) {
        return;
      }
      final next = !_apiKeys[index].isActive;
      _apiKeys[index] = _apiKeys[index].copyWith(isActive: next);
      _recordAudit(
        next ? 'API key activated' : 'API key revoked',
        '${next ? 'Activated' : 'Revoked'} key "${key.label}" (${key.id}).',
        icon: next ? Icons.verified_rounded : Icons.block_rounded,
        color: next ? const Color(0xFF0F9D58) : const Color(0xFFDB4437),
      );
    });
    _showMessage(key.isActive
        ? 'API key revoked: ${key.label}'
        : 'API key activated: ${key.label}');
  }

  Future<void> _copyApiKey(_ApiKeyRecord key) async {
    await Clipboard.setData(ClipboardData(text: key.value));
    _showMessage('Copied API key for ${key.label}.');
    setState(() {
      _recordAudit(
        'API key copied',
        'Copied key value for "${key.label}".',
        icon: Icons.copy_rounded,
        color: const Color(0xFF1A73E8),
      );
    });
  }

  Future<void> _showManageApiKeysSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'API Key Manager',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () async {
                            await _showCreateApiKeyDialog(onCreated: () {
                              setSheetState(() {});
                            });
                          },
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('New Key'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_apiKeys.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text('No API keys available.'),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _apiKeys.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final key = _apiKeys[index];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${key.label} (${key.id})',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: key.isActive
                                              ? const Color(0xFFE8F5E9)
                                              : const Color(0xFFFFEBEE),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          key.isActive ? 'Active' : 'Revoked',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: key.isActive
                                                ? const Color(0xFF0F9D58)
                                                : const Color(0xFFDB4437),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _maskApiKey(key.value),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Created: ${_formatDateTime(key.createdAt)} | Last used: ${_formatDateTime(key.lastUsedAt)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () async {
                                          await _copyApiKey(key);
                                          setSheetState(() {});
                                        },
                                        icon: const Icon(Icons.copy_rounded,
                                            size: 16),
                                        label: const Text('Copy'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: key.isActive
                                            ? () {
                                                _rotateApiKey(key);
                                                setSheetState(() {});
                                              }
                                            : null,
                                        icon: const Icon(Icons.refresh_rounded,
                                            size: 16),
                                        label: const Text('Rotate'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          _toggleApiKeyState(key);
                                          setSheetState(() {});
                                        },
                                        icon: Icon(
                                          key.isActive
                                              ? Icons.block_rounded
                                              : Icons.verified_rounded,
                                          size: 16,
                                        ),
                                        label: Text(
                                          key.isActive ? 'Revoke' : 'Activate',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAuditTrailSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Audit Trail',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Recent security and settings events.',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 10),
                if (_auditTrail.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('No audit entries yet.')),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _auditTrail.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final entry = _auditTrail[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: entry.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                alignment: Alignment.center,
                                child: Icon(entry.icon,
                                    color: entry.color, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      entry.detail,
                                      style: const TextStyle(
                                        color: Color(0xFF475569),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDateTime(entry.timestamp),
                                      style: const TextStyle(
                                        color: Color(0xFF94A3B8),
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
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
            auditTitle: 'Currency',
          ),
          const SizedBox(height: 10),
          _buildDropdownSetting(
            title: 'Date Format',
            subtitle: 'Display format across finance modules',
            value: _dateFormat,
            options: const ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'],
            onSelected: (value) => _dateFormat = value,
            auditTitle: 'Date Format',
          ),
          const SizedBox(height: 10),
          _buildDropdownSetting(
            title: 'Timezone',
            subtitle: 'Transaction timestamps and reports',
            value: _timezone,
            options: const ['UTC+05:30', 'UTC+00:00', 'UTC-05:00', 'UTC+01:00'],
            onSelected: (value) => _timezone = value,
            auditTitle: 'Timezone',
          ),
          const SizedBox(height: 10),
          _buildDropdownSetting(
            title: 'Fiscal Year Start',
            subtitle: 'Starting month for fiscal calculations',
            value: _fiscalYearStart,
            options: const ['January', 'April', 'July', 'October'],
            onSelected: (value) => _fiscalYearStart = value,
            auditTitle: 'Fiscal Year Start',
          ),
          const SizedBox(height: 10),
          _buildDropdownSetting(
            title: 'Report Delivery',
            subtitle: 'Automated report delivery cadence',
            value: _reportDelivery,
            options: const ['Daily', 'Weekly', 'Monthly'],
            onSelected: (value) => _reportDelivery = value,
            auditTitle: 'Report Delivery',
          ),
          const SizedBox(height: 10),
          _buildDropdownSetting(
            title: 'Language',
            subtitle: 'Language for finance labels and exports',
            value: _language,
            options: const ['English', 'Hindi', 'Spanish', 'French'],
            onSelected: (value) => _language = value,
            auditTitle: 'Language',
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
            onChanged: (value) {
              _notificationsEnabled = value;
              if (!value) {
                _emailAlerts = false;
                _smsAlerts = false;
                _weeklyDigest = false;
                _taxReminders = false;
              }
            },
            auditTitle: 'Notifications',
          ),
          const SizedBox(height: 10),
          _buildSwitchSetting(
            title: 'Email Alerts',
            subtitle: 'Critical updates and monthly report dispatch',
            value: _emailAlerts,
            onChanged: (value) => _emailAlerts = value,
            enabled: _notificationsEnabled,
            auditTitle: 'Email Alerts',
          ),
          const SizedBox(height: 10),
          _buildSwitchSetting(
            title: 'SMS Alerts',
            subtitle: 'High-priority settlement and failure notices',
            value: _smsAlerts,
            onChanged: (value) => _smsAlerts = value,
            enabled: _notificationsEnabled,
            auditTitle: 'SMS Alerts',
          ),
          const SizedBox(height: 10),
          _buildSwitchSetting(
            title: 'Weekly Digest',
            subtitle: 'Summary of key transaction and payroll events',
            value: _weeklyDigest,
            onChanged: (value) => _weeklyDigest = value,
            enabled: _notificationsEnabled,
            auditTitle: 'Weekly Digest',
          ),
          const SizedBox(height: 10),
          _buildSwitchSetting(
            title: 'Tax Reminders',
            subtitle: 'Advance reminders for tax and filing deadlines',
            value: _taxReminders,
            onChanged: (value) => _taxReminders = value,
            enabled: _notificationsEnabled,
            auditTitle: 'Tax Reminders',
          ),
          if (!_notificationsEnabled) ...[
            const SizedBox(height: 8),
            const Text(
              'Enable Notifications to configure email, SMS, weekly digest, and tax reminder channels.',
              style: TextStyle(
                color: Color(0xFFB45309),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
            auditTitle: 'Automatic Backup',
          ),
          const SizedBox(height: 10),
          _buildSwitchSetting(
            title: 'Require Expense Approval',
            subtitle: 'Mandate manager approval for outgoing expenses',
            value: _requireApprovalForExpense,
            onChanged: (value) => _requireApprovalForExpense = value,
            auditTitle: 'Expense Approval',
          ),
          const SizedBox(height: 14),
          _buildActionTile(
            icon: Icons.download_rounded,
            title: 'Backup Data',
            subtitle: 'Download a complete finance data backup',
            onTap: _runBackupData,
          ),
          const SizedBox(height: 8),
          _buildActionTile(
            icon: Icons.upload_file_rounded,
            title: 'Import Configuration',
            subtitle: 'Apply a saved settings profile',
            onTap: _showImportConfigurationDialog,
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
            auditTitle: 'Two-Factor Authentication',
          ),
          const SizedBox(height: 10),
          Text(
            'Last password change: ${_formatDateTime(_lastPasswordChanged)}',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Active API keys: ${_apiKeys.where((item) => item.isActive).length}',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _buildActionTile(
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            subtitle: 'Update account password and session keys',
            onTap: _showChangePasswordDialog,
          ),
          const SizedBox(height: 8),
          _buildActionTile(
            icon: Icons.key_rounded,
            title: 'Manage API Keys',
            subtitle: 'Rotate and revoke integration keys securely',
            onTap: _showManageApiKeysSheet,
          ),
          const SizedBox(height: 8),
          _buildActionTile(
            icon: Icons.history_rounded,
            title: 'View Audit Trail',
            subtitle: 'Inspect recent security-sensitive changes',
            onTap: _showAuditTrailSheet,
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
    String? auditTitle,
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
                    if (auditTitle != null) {
                      _recordAudit(
                        '$auditTitle changed',
                        '$auditTitle set to "$selected".',
                        icon: Icons.tune_rounded,
                        color: const Color(0xFF1A73E8),
                      );
                    }
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
    bool enabled = true,
    String? auditTitle,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.6,
      child: Container(
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
              onChanged: enabled
                  ? (newValue) {
                      _updateSetting(() {
                        onChanged(newValue);
                        if (auditTitle != null) {
                          _recordAudit(
                            '$auditTitle ${newValue ? 'enabled' : 'disabled'}',
                            '${newValue ? 'Enabled' : 'Disabled'} $auditTitle in finance settings.',
                            icon: Icons.notifications_active_rounded,
                            color: newValue
                                ? const Color(0xFF0F9D58)
                                : const Color(0xFFB45309),
                          );
                        }
                      });
                    }
                  : null,
            ),
          ],
        ),
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
              setState(() {
                _recordAudit(
                  'Logout initiated',
                  'User initiated logout from finance settings.',
                  icon: Icons.logout_rounded,
                  color: const Color(0xFFDB4437),
                );
              });
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

class _ApiKeyRecord {
  const _ApiKeyRecord({
    required this.id,
    required this.label,
    required this.value,
    required this.createdAt,
    required this.lastUsedAt,
    required this.isActive,
  });

  final String id;
  final String label;
  final String value;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final bool isActive;

  _ApiKeyRecord copyWith({
    String? value,
    DateTime? lastUsedAt,
    bool? isActive,
  }) {
    return _ApiKeyRecord(
      id: id,
      label: label,
      value: value ?? this.value,
      createdAt: createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class _AuditTrailEntry {
  const _AuditTrailEntry({
    required this.title,
    required this.detail,
    required this.timestamp,
    required this.icon,
    required this.color,
  });

  final String title;
  final String detail;
  final DateTime timestamp;
  final IconData icon;
  final Color color;
}
