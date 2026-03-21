import 'package:flutter/material.dart';

import '../../../data/dashboard_seed_data.dart';

class InvestmentSettingsPage extends StatelessWidget {
  const InvestmentSettingsPage({super.key});

  static const Color _bgTop = Color(0xFF0A1A08);
  static const Color _bgBottom = Color(0xFF050C04);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);

  Widget _glow(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _lime.withOpacity(0.08),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBottom,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Investment Settings',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(top: -120, right: -70, child: _glow(280)),
          Positioned(bottom: -110, left: -70, child: _glow(230)),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_bgTop, _bgBottom],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          const SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: InvestmentSettingsContent(),
            ),
          ),
        ],
      ),
    );
  }
}

class InvestmentSettingsContent extends StatefulWidget {
  const InvestmentSettingsContent({super.key, this.onSaved});

  final VoidCallback? onSaved;

  @override
  State<InvestmentSettingsContent> createState() =>
      _InvestmentSettingsContentState();
}

class _InvestmentSettingsContentState extends State<InvestmentSettingsContent> {
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  late bool _twoFactorEnabled;
  late bool _biometricEnabled;
  late bool _bankImportEnabled;

  bool _priceAlertsEnabled = true;
  bool _riskAlertsEnabled = true;
  bool _weeklySummaryEnabled = true;
  bool _allowFractionalOrders = true;

  late String _currency;
  int _riskPreferenceIndex = 1;

  late final TextEditingController _defaultSipController;
  late final TextEditingController _slippageController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _twoFactorEnabled = seededUserProfile.twoFactorEnabled;
    _biometricEnabled = seededUserProfile.biometricEnabled;
    _bankImportEnabled = seededUserProfile.bankImportEnabled;
    _currency = seededUserProfile.currencyPreference;
    _defaultSipController = TextEditingController(text: '500');
    _slippageController = TextEditingController(text: '2.0');
  }

  @override
  void dispose() {
    _defaultSipController.dispose();
    _slippageController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _saveSettings() async {
    final sip = double.tryParse(_defaultSipController.text.trim()) ?? 0;
    final slippage = double.tryParse(_slippageController.text.trim()) ?? -1;

    if (sip <= 0) {
      _showMessage('Default SIP amount must be greater than zero.');
      return;
    }
    if (slippage < 0 || slippage > 20) {
      _showMessage('Slippage threshold must be between 0 and 20.');
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 750));
    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    _showMessage('Investment settings saved successfully.');
    widget.onSaved?.call();
  }

  void _resetDefaults() {
    setState(() {
      _twoFactorEnabled = seededUserProfile.twoFactorEnabled;
      _biometricEnabled = seededUserProfile.biometricEnabled;
      _bankImportEnabled = seededUserProfile.bankImportEnabled;
      _priceAlertsEnabled = true;
      _riskAlertsEnabled = true;
      _weeklySummaryEnabled = true;
      _allowFractionalOrders = true;
      _currency = seededUserProfile.currencyPreference;
      _riskPreferenceIndex = 1;
      _defaultSipController.text = '500';
      _slippageController.text = '2.0';
    });
    _showMessage('Settings reset to defaults.');
  }

  @override
  Widget build(BuildContext context) {
    const riskLabels = ['Conservative', 'Balanced', 'Aggressive'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _profileCard(),
        const SizedBox(height: 20),
        _sectionTitle('Portfolio Preferences'),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _lime.withOpacity(0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Risk Preference',
                style: TextStyle(
                  color: _textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  riskLabels.length,
                  (i) => ChoiceChip(
                    label: Text(riskLabels[i]),
                    selected: _riskPreferenceIndex == i,
                    onSelected: (_) => setState(() => _riskPreferenceIndex = i),
                    selectedColor: _lime,
                    backgroundColor: _cardDeep,
                    labelStyle: TextStyle(
                      color: _riskPreferenceIndex == i ? _cardDark : _textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _currency,
                dropdownColor: _cardDeep,
                style: const TextStyle(color: _textPrimary),
                iconEnabledColor: _lime,
                decoration: InputDecoration(
                  labelText: 'Preferred Currency',
                  labelStyle: const TextStyle(color: _textMuted),
                  filled: true,
                  fillColor: _cardDeep,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _lime.withOpacity(0.18)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _lime.withOpacity(0.18)),
                  ),
                ),
                items: supportedCurrencies
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _currency = value);
                  }
                },
              ),
              const SizedBox(height: 10),
              _numericField(
                controller: _defaultSipController,
                label: 'Default SIP Amount',
                prefix: _currency == 'USD' ? r'$' : '$_currency ',
              ),
              const SizedBox(height: 10),
              _numericField(
                controller: _slippageController,
                label: 'Max Slippage (%)',
                suffix: '%',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _sectionTitle('Security & Integrations'),
        const SizedBox(height: 10),
        _switchCard(
          title: 'Two-Factor Authentication',
          subtitle: 'Extra verification during sensitive actions',
          value: _twoFactorEnabled,
          onChanged: (v) => setState(() => _twoFactorEnabled = v),
        ),
        const SizedBox(height: 8),
        _switchCard(
          title: 'Biometric Authentication',
          subtitle: 'Use fingerprint/face unlock for confirmations',
          value: _biometricEnabled,
          onChanged: (v) => setState(() => _biometricEnabled = v),
        ),
        const SizedBox(height: 8),
        _switchCard(
          title: 'Bank Import',
          subtitle: 'Sync transactions from linked accounts',
          value: _bankImportEnabled,
          onChanged: (v) => setState(() => _bankImportEnabled = v),
        ),
        const SizedBox(height: 16),
        _sectionTitle('Notifications'),
        const SizedBox(height: 10),
        _switchCard(
          title: 'Price Alerts',
          subtitle: 'Get alerts on target price movements',
          value: _priceAlertsEnabled,
          onChanged: (v) => setState(() => _priceAlertsEnabled = v),
        ),
        const SizedBox(height: 8),
        _switchCard(
          title: 'Risk Alerts',
          subtitle: 'Warn when portfolio risk drifts above threshold',
          value: _riskAlertsEnabled,
          onChanged: (v) => setState(() => _riskAlertsEnabled = v),
        ),
        const SizedBox(height: 8),
        _switchCard(
          title: 'Weekly Summary',
          subtitle: 'Receive weekly investment performance digest',
          value: _weeklySummaryEnabled,
          onChanged: (v) => setState(() => _weeklySummaryEnabled = v),
        ),
        const SizedBox(height: 8),
        _switchCard(
          title: 'Allow Fractional Orders',
          subtitle: 'Permit orders with fractional units',
          value: _allowFractionalOrders,
          onChanged: (v) => setState(() => _allowFractionalOrders = v),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _resetDefaults,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _lime.withOpacity(0.32)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Reset',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _lime,
                  foregroundColor: const Color(0xFF102A00),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF102A00)),
                        ),
                      )
                    : const Text(
                        'Save Settings',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _profileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_cardDark, _cardDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _lime.withOpacity(0.16)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _cardDeep,
            child: Text(
              seededUserProfile.name.substring(0, 1),
              style: const TextStyle(
                color: _lime,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seededUserProfile.name,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  seededUserProfile.email,
                  style: const TextStyle(
                    color: _textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _lime.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'PRO',
              style: TextStyle(
                color: _lime,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: _textPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 20,
      ),
    );
  }

  Widget _numericField({
    required TextEditingController controller,
    required String label,
    String? prefix,
    String? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(
        color: _textPrimary,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textMuted),
        prefixText: prefix,
        suffixText: suffix,
        prefixStyle: const TextStyle(
          color: _lime,
          fontWeight: FontWeight.w700,
        ),
        suffixStyle: const TextStyle(
          color: _lime,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: _cardDeep,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _lime.withOpacity(0.18)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _lime.withOpacity(0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _lime.withOpacity(0.45)),
        ),
      ),
    );
  }

  Widget _switchCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _lime.withOpacity(0.10)),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: _textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: _lime,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
