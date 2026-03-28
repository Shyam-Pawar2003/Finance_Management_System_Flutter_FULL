import 'package:flutter/material.dart';
import '../Top_rated.dart';

class IciciTopRatedPage extends StatefulWidget {
  const IciciTopRatedPage({super.key});

  @override
  State<IciciTopRatedPage> createState() => _IciciTopRatedPageState();
}

class _IciciTopRatedPageState extends State<IciciTopRatedPage> {
  static const Color _bgTop = Color(0xFF0A1A08);
  static const Color _bgBottom = Color(0xFF050C04);
  static const Color _cardDark = Color(0xFF0D1F09);
  static const Color _lime = Color(0xFFC8F24A);
  static const Color _textPrimary = Color(0xFFEAF7C6);
  static const Color _textMuted = Color(0xFF9AB37F);

  bool _isTracking = false;
  DateTime? _trackingStartedAt;
  double _targetPrice = 1280;

  void _toggleTracking() {
    setState(() {
      _isTracking = !_isTracking;
      _trackingStartedAt = _isTracking ? DateTime.now() : null;
    });

    final text = _isTracking
        ? 'ICICI Multi Asset Fund is now in your tracked funds.'
        : 'Tracking removed for ICICI Multi Asset Fund.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _handleBack(BuildContext context) async {
    final popped = await Navigator.maybePop(context);
    if (!popped && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const TopRatedPage()),
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
        title: const Text('ICICI Top Rated',
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
            _card('ICICI Multi Asset Fund', 'Rating: 5★ • Consistency: 90%',
                '1Y: 14.7% • 3Y: 13.8% • Expense: 0.87%'),
            const SizedBox(height: 12),
            _buildTrackingCard(),
            const SizedBox(height: 12),
            _card(
                'Allocation Style',
                'Diversifies across equity, debt, and gold',
                'Built for smoother long-term compounding'),
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

  Widget _buildTrackingCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _lime.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Track Fund',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              Switch(
                value: _isTracking,
                activeColor: _lime,
                onChanged: (_) => _toggleTracking(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _isTracking
                ? 'Tracking is active. You will be notified when target conditions match.'
                : 'Enable tracking to monitor this fund with your custom target.',
            style: const TextStyle(
              color: _textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Target NAV Alert: INR ${_targetPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          Slider(
            value: _targetPrice,
            min: 900,
            max: 1800,
            divisions: 36,
            activeColor: _lime,
            inactiveColor: _textMuted.withOpacity(0.30),
            label: _targetPrice.toStringAsFixed(0),
            onChanged: _isTracking
                ? (value) {
                    setState(() => _targetPrice = value);
                  }
                : null,
          ),
          if (_isTracking && _trackingStartedAt != null)
            Text(
              'Tracking started: ${_trackingStartedAt!.day.toString().padLeft(2, '0')}/${_trackingStartedAt!.month.toString().padLeft(2, '0')}/${_trackingStartedAt!.year}',
              style: const TextStyle(
                color: _lime,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _toggleTracking,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isTracking ? Colors.redAccent : _lime,
                foregroundColor: _isTracking ? Colors.white : _cardDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(
                _isTracking
                    ? Icons.notifications_off_rounded
                    : Icons.notifications_active_rounded,
              ),
              label: Text(
                _isTracking ? 'Stop Tracking' : 'Start Tracking',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
