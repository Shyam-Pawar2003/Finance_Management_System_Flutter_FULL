import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../data/dashboard_seed_data.dart';

class InvestmentQrPage extends StatelessWidget {
  const InvestmentQrPage({super.key});

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
        title: const Text(
          'Investment QR',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(top: -120, right: -80, child: _glow(260)),
          Positioned(bottom: -100, left: -70, child: _glow(210)),
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
              child: InvestmentQrContent(),
            ),
          ),
        ],
      ),
    );
  }
}

class InvestmentQrContent extends StatefulWidget {
  const InvestmentQrContent({super.key});

  @override
  State<InvestmentQrContent> createState() => _InvestmentQrContentState();
}

class _InvestmentQrContentState extends State<InvestmentQrContent> {
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _cardDeep = Color(0xFF081606);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  final TextEditingController _recipientController =
      TextEditingController(text: 'Investment Desk');
  final TextEditingController _amountController =
      TextEditingController(text: '2500');
  final TextEditingController _noteController =
      TextEditingController(text: 'Monthly SIP contribution');

  int _selectedMode = 0;
  String _qrData = '';

  @override
  void initState() {
    super.initState();
    _qrData = _buildPayload();
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String get _currencySymbol {
    switch (seededUserProfile.currencyPreference) {
      case 'EUR':
        return 'EUR';
      case 'GBP':
        return 'GBP';
      case 'INR':
        return 'INR';
      case 'AED':
        return 'AED';
      case 'USD':
      default:
        return 'USD';
    }
  }

  double get _portfolioCurrent => seedInvestmentHoldings.fold<double>(
        0,
        (sum, item) => sum + item.currentValue,
      );

  double get _portfolioInvested => seedInvestmentHoldings.fold<double>(
        0,
        (sum, item) => sum + item.investedAmount,
      );

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  String _buildPayload() {
    final timestamp = DateTime.now().toIso8601String();

    if (_selectedMode == 0) {
      final payload = {
        'type': 'portfolio',
        'name': seededUserProfile.name,
        'currency': _currencySymbol,
        'current': _portfolioCurrent.toStringAsFixed(2),
        'invested': _portfolioInvested.toStringAsFixed(2),
        'holdings': seedInvestmentHoldings.length,
        'timestamp': timestamp,
      };
      return jsonEncode(payload);
    }

    if (_selectedMode == 1) {
      final amount = double.tryParse(_amountController.text.trim()) ?? 0;
      final payload = {
        'type': 'payment',
        'recipient': _recipientController.text.trim(),
        'amount': amount.toStringAsFixed(2),
        'currency': _currencySymbol,
        'note': _noteController.text.trim(),
        'timestamp': timestamp,
      };
      return jsonEncode(payload);
    }

    final payload = {
      'type': 'invite',
      'name': seededUserProfile.name,
      'email': seededUserProfile.email,
      'ref': 'INV-${DateTime.now().millisecondsSinceEpoch}',
      'timestamp': timestamp,
    };
    return jsonEncode(payload);
  }

  void _generateQr() {
    if (_selectedMode == 1) {
      final amount = double.tryParse(_amountController.text.trim()) ?? 0;
      if (_recipientController.text.trim().isEmpty) {
        _showMessage('Enter recipient name before generating payment QR.');
        return;
      }
      if (amount <= 0) {
        _showMessage('Enter a valid amount before generating payment QR.');
        return;
      }
    }

    setState(() => _qrData = _buildPayload());
    _showMessage('QR generated successfully.');
  }

  Future<void> _copyData() async {
    await Clipboard.setData(ClipboardData(text: _qrData));
    _showMessage('QR payload copied to clipboard.');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Generate Investment QR',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose mode, set details, and generate your QR instantly.',
                style: TextStyle(
                  color: _textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _modeChip(0, 'Portfolio'),
                  _modeChip(1, 'Payment'),
                  _modeChip(2, 'Invite'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_selectedMode == 1)
          _formCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _textField(
                  controller: _recipientController,
                  label: 'Recipient',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 10),
                _textField(
                  controller: _amountController,
                  label: 'Amount',
                  icon: Icons.payments_outlined,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 10),
                _textField(
                  controller: _noteController,
                  label: 'Note',
                  icon: Icons.notes_rounded,
                ),
              ],
            ),
          )
        else
          _formCard(
            child: Text(
              _selectedMode == 0
                  ? 'Portfolio QR includes summary value, invested amount, and holdings count.'
                  : 'Invite QR includes referral details for your investment profile.',
              style: const TextStyle(
                color: _textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _generateQr,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _lime,
                  foregroundColor: const Color(0xFF102A00),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Generate QR',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: _copyData,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _lime.withOpacity(0.32)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Copy Data',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardDark,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _lime.withOpacity(0.14)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: QrImageView(
                  data: _qrData.isEmpty ? 'init' : _qrData,
                  version: QrVersions.auto,
                  size: 220,
                  gapless: true,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF102A00),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF102A00),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Scan this QR to load the selected investment payload.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _modeChip(int value, String label) {
    final selected = _selectedMode == value;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() => _selectedMode = value);
        _generateQr();
      },
      selectedColor: _lime,
      backgroundColor: _cardDeep,
      labelStyle: TextStyle(
        color: selected ? _cardDark : _textMuted,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _formCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _lime.withOpacity(0.12)),
      ),
      child: child,
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: _textPrimary,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textMuted),
        prefixIcon: Icon(icon, color: _lime, size: 20),
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
          borderSide: BorderSide(color: _lime.withOpacity(0.40)),
        ),
      ),
    );
  }
}
