import 'package:flutter/material.dart';
import '../Tax_saver.dart';

class ParagTaxSaverPage extends StatelessWidget {
  const ParagTaxSaverPage({super.key});

  static const Color _bgTop = Color(0xFF0A1A08);
  static const Color _bgBottom = Color(0xFF050C04);
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  Future<void> _handleBack(BuildContext context) async {
    final popped = await Navigator.maybePop(context);
    if (!popped && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const TaxSaverPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBottom,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => _handleBack(context),
          icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
        ),
        title: const Text('Parag ELSS',
            style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w800)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [_bgTop, _bgBottom],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _card(
                'Parag Parikh ELSS Tax Saver',
                '1Y: 16.6% • 3Y: 14.9% • 5Y: 13.8%',
                'Expense: 0.88% • Risk: Moderate'),
            const SizedBox(height: 12),
            _card('Portfolio Style', 'Flexi Cap approach with quality bias',
                'Useful for long-term tax-efficient equity allocation'),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, String subtitle, String caption) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _lime.withOpacity(0.16))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16)),
        const SizedBox(height: 6),
        Text(subtitle,
            style: const TextStyle(
                color: _lime, fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 4),
        Text(caption,
            style: const TextStyle(
                color: _textMuted, fontWeight: FontWeight.w600, fontSize: 12)),
      ]),
    );
  }
}
