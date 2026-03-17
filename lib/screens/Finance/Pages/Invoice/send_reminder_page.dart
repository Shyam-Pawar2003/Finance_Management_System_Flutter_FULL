import 'package:flutter/material.dart';

import '../../../../services/gmail_service.dart';

class SendReminderPage extends StatefulWidget {
  const SendReminderPage({super.key});

  @override
  State<SendReminderPage> createState() => _SendReminderPageState();
}

class _SendReminderPageState extends State<SendReminderPage> {
  final GmailService _gmailService = GmailService();

  final List<_ReminderInvoice> _invoices = const [
    _ReminderInvoice(
      id: 'INV-002',
      client: 'XYZ Industries',
      pendingAmount: 1300,
      contactEmail: 'accounts@xyzindustries.com',
      daysOverdue: 2,
    ),
    _ReminderInvoice(
      id: 'INV-003',
      client: 'Tech Solutions',
      pendingAmount: 4500,
      contactEmail: 'finance@techsolutions.com',
      daysOverdue: 18,
    ),
    _ReminderInvoice(
      id: 'INV-004',
      client: 'Global Enterprises',
      pendingAmount: 3200,
      contactEmail: 'billing@globalenterprises.com',
      daysOverdue: 6,
    ),
    _ReminderInvoice(
      id: 'INV-006',
      client: 'Northbridge LLP',
      pendingAmount: 7100,
      contactEmail: 'payables@northbridge.com',
      daysOverdue: 22,
    ),
    _ReminderInvoice(
      id: 'INV-007',
      client: 'Prime Logistics',
      pendingAmount: 3300,
      contactEmail: 'accounts@primelogistics.com',
      daysOverdue: 10,
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = <String>{};
  String _searchQuery = '';
  String _template = _templates.first.name;
  bool _isRestoringSession = true;
  bool _isSigningIn = false;
  bool _isSending = false;
  bool _isSignedIn = false;

  static const List<_ReminderTemplate> _templates = [
    _ReminderTemplate(
      name: 'Friendly follow-up',
      subtitle: 'Soft and polite nudge for recently due invoices.',
      subjectPrefix: 'Gentle payment reminder',
      icon: Icons.waving_hand_rounded,
      accent: Color(0xFF2563EB),
    ),
    _ReminderTemplate(
      name: 'Payment due reminder',
      subtitle: 'Balanced tone with clear due amount and date.',
      subjectPrefix: 'Payment due notice',
      icon: Icons.schedule_send_rounded,
      accent: Color(0xFF0F766E),
    ),
    _ReminderTemplate(
      name: 'Final overdue notice',
      subtitle: 'Firm follow-up for long-pending receivables.',
      subjectPrefix: 'Final overdue notification',
      icon: Icons.priority_high_rounded,
      accent: Color(0xFFB91C1C),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(_invoices.take(2).map((e) => e.id));
    _restoreSignInIfAvailable();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _currency(double amount) {
    final value = amount.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      final reverseIndex = value.length - i;
      buffer.write(value[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return '\$${buffer.toString()}';
  }

  double get _totalPending {
    return _invoices.fold(0, (sum, invoice) => sum + invoice.pendingAmount);
  }

  double get _selectedAmount {
    return _invoices
        .where((invoice) => _selectedIds.contains(invoice.id))
        .fold(0, (sum, invoice) => sum + invoice.pendingAmount);
  }

  int get _overdueCount {
    return _invoices.where((invoice) => invoice.daysOverdue > 0).length;
  }

  _ReminderTemplate get _selectedTemplate {
    return _templates.firstWhere((template) => template.name == _template);
  }

  List<_ReminderInvoice> get _filteredInvoices {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return _invoices;
    }

    return _invoices.where((invoice) {
      return invoice.id.toLowerCase().contains(query) ||
          invoice.client.toLowerCase().contains(query) ||
          invoice.contactEmail.toLowerCase().contains(query);
    }).toList();
  }

  void _toggleSelection(String invoiceId, bool checked) {
    setState(() {
      if (checked) {
        _selectedIds.add(invoiceId);
      } else {
        _selectedIds.remove(invoiceId);
      }
    });
  }

  void _toggleSelectAllVisible(bool checked) {
    final visibleIds = _filteredInvoices.map((invoice) => invoice.id);
    setState(() {
      if (checked) {
        _selectedIds.addAll(visibleIds);
      } else {
        _selectedIds.removeWhere((id) => visibleIds.contains(id));
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  Future<void> _restoreSignInIfAvailable() async {
    setState(() {
      _isRestoringSession = true;
    });

    try {
      final restored = await _gmailService.restoreSession();
      if (!mounted) return;
      setState(() {
        _isSignedIn = restored;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isRestoringSession = false;
      });
    }
  }

  String _friendlyErrorMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    final normalized = message.toLowerCase();

    if (normalized.contains('network') || normalized.contains('socket')) {
      return 'Network error while contacting Gmail. Please check your internet and try again.';
    }

    if (normalized.contains('oauth') ||
        normalized.contains('client id') ||
        normalized.contains('permission') ||
        normalized.contains('apiexception: 10') ||
        normalized.contains('developer error')) {
      return 'Google sign-in configuration is incomplete. Please verify OAuth client IDs and Gmail API access.';
    }

    if (normalized.contains('cancel')) {
      return 'Google sign-in was canceled before completion.';
    }

    return message.isEmpty
        ? 'Unable to complete this action. Please try again.'
        : message;
  }

  Future<bool> _ensureSignedIn() async {
    if (_isSignedIn) {
      return true;
    }

    setState(() {
      _isSigningIn = true;
    });

    try {
      final success = await _gmailService.signIn();
      if (!mounted) return false;

      if (success) {
        setState(() {
          _isSignedIn = true;
        });
        return true;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google sign-in canceled.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    } catch (error) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_friendlyErrorMessage(error)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFB91C1C),
        ),
      );
      return false;
    } finally {
      if (!mounted) return false;
      setState(() {
        _isSigningIn = false;
      });
    }
  }

  String _subjectFor(_ReminderInvoice invoice) {
    return '${_selectedTemplate.subjectPrefix} - ${invoice.id}';
  }

  String _messageBodyFor(_ReminderInvoice invoice) {
    final selectedTemplate = _selectedTemplate;
    final days = invoice.daysOverdue;
    final overdueLine =
        days > 0 ? '$days day(s) overdue' : 'due soon and pending';

    if (selectedTemplate.name == 'Friendly follow-up') {
      return 'Hello ${invoice.client},\n\n'
          'This is a friendly reminder that invoice ${invoice.id} for ${_currency(invoice.pendingAmount)} is currently $overdueLine.\n\n'
          'Please share an update on the expected payment date.\n\n'
          'Regards,\nFinance Team';
    }

    if (selectedTemplate.name == 'Final overdue notice') {
      return 'Dear ${invoice.client},\n\n'
          'This is a final notice for invoice ${invoice.id}. The outstanding amount ${_currency(invoice.pendingAmount)} is $overdueLine.\n\n'
          'Please clear the pending amount at the earliest to avoid further escalation.\n\n'
          'Regards,\nFinance Team';
    }

    return 'Dear ${invoice.client},\n\n'
        'Invoice ${invoice.id} is pending for ${_currency(invoice.pendingAmount)} and is currently $overdueLine.\n\n'
        'Kindly process the payment and confirm once done.\n\n'
        'Regards,\nFinance Team';
  }

  Future<void> _sendReminders() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one invoice.')),
      );
      return;
    }

    if (_isSending) return;

    final signedIn = await _ensureSignedIn();
    if (!signedIn) return;

    setState(() {
      _isSending = true;
    });

    final selectedInvoices = _invoices
        .where((invoice) => _selectedIds.contains(invoice.id))
        .toList(growable: false);

    int sentCount = 0;
    final failedIds = <String>[];

    try {
      for (final invoice in selectedInvoices) {
        try {
          await _gmailService.sendEmail(
            to: invoice.contactEmail,
            subject: _subjectFor(invoice),
            body: _messageBodyFor(invoice),
          );
          sentCount++;
        } catch (_) {
          failedIds.add(invoice.id);
        }
      }

      if (!mounted) return;

      if (failedIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reminder emails sent for $sentCount invoice(s). Total ${_currency(_selectedAmount)}.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF0F766E),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sent: $sentCount, Failed: ${failedIds.length}. Failed invoices: ${failedIds.join(', ')}',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFFB45309),
          ),
        );
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isSending = false;
      });
    }
  }

  Color _urgencyColor(int daysOverdue) {
    if (daysOverdue >= 16) {
      return const Color(0xFFB91C1C);
    }
    if (daysOverdue >= 8) {
      return const Color(0xFFB45309);
    }
    return const Color(0xFF1D4ED8);
  }

  String _urgencyLabel(int daysOverdue) {
    if (daysOverdue <= 0) {
      return 'Due soon';
    }
    return '${daysOverdue}d overdue';
  }

  @override
  Widget build(BuildContext context) {
    final visibleInvoices = _filteredInvoices;
    final allVisibleSelected = visibleInvoices.isNotEmpty &&
        visibleInvoices.every((invoice) => _selectedIds.contains(invoice.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: const Text('Send Reminders'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFF), Color(0xFFEEF3FB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 980;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroCard(),
                    const SizedBox(height: 14),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildInvoicesPanel(
                              visibleInvoices,
                              allVisibleSelected,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 2,
                            child: _buildTemplatePanel(),
                          ),
                        ],
                      )
                    else ...[
                      _buildInvoicesPanel(visibleInvoices, allVisibleSelected),
                      const SizedBox(height: 14),
                      _buildTemplatePanel(),
                    ],
                    const SizedBox(height: 14),
                    _buildSendBar(isWide),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2C67), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminder Campaign',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 23,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Choose recipients, tailor tone, and trigger follow-up emails in one flow.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _heroStatChip('Selected', '${_selectedIds.length} invoices'),
              _heroStatChip('Selected value', _currency(_selectedAmount)),
              _heroStatChip('Portfolio due', _currency(_totalPending)),
              _heroStatChip('Overdue', '$_overdueCount invoices'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
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
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesPanel(
    List<_ReminderInvoice> visibleInvoices,
    bool allVisibleSelected,
  ) {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Receivables Queue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F0FE),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${visibleInvoices.length} visible',
                  style: const TextStyle(
                    color: Color(0xFF1D4ED8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search by invoice, client, or email',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: allVisibleSelected,
                  onChanged: (value) {
                    _toggleSelectAllVisible(value ?? false);
                  },
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Select all visible',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _clearSearch,
                icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                label: const Text('Clear filter'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (visibleInvoices.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'No invoices match your search.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ...visibleInvoices.map(_buildInvoiceCard),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(_ReminderInvoice invoice) {
    final isSelected = _selectedIds.contains(invoice.id);
    final urgencyColor = _urgencyColor(invoice.daysOverdue);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEDF4FF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFFBFD8FF) : const Color(0xFFE2E8F0),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _toggleSelection(invoice.id, !isSelected),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  _toggleSelection(invoice.id, value ?? false);
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${invoice.id} - ${invoice.client}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      invoice.contactEmail,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _currency(invoice.pendingAmount),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: urgencyColor.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _urgencyLabel(invoice.daysOverdue),
                      style: TextStyle(
                        color: urgencyColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplatePanel() {
    final selectedTemplate = _selectedTemplate;

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Template Studio',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pick the communication tone for this reminder batch.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          ..._templates.map(
            (template) => _buildTemplateCard(
              template,
              selected: _template == template.name,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selectedTemplate.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedTemplate.accent.withOpacity(0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subject preview',
                  style: TextStyle(
                    color: selectedTemplate.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${selectedTemplate.subjectPrefix} - ${DateTime.now().year}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(
    _ReminderTemplate template, {
    required bool selected,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _template = template.name;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? template.accent.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? template.accent : const Color(0xFFD5DEE9),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: template.accent.withOpacity(0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(template.icon, color: template.accent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    template.subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? template.accent : const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendBar(bool isWide) {
    final signedInUser = _gmailService.currentUser;
    final accountText = _isRestoringSession
        ? 'Checking Gmail sign-in...'
        : _isSignedIn
            ? 'Connected as ${signedInUser?.email ?? 'Google account'}'
            : 'Not connected. Sign in with Google to send emails.';

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ready to launch?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          '${_selectedIds.length} recipients selected | ${_currency(_selectedAmount)} pending total',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          accountText,
          style: TextStyle(
            color:
                _isSignedIn ? const Color(0xFF0F766E) : const Color(0xFFB45309),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );

    final sendButton = ElevatedButton.icon(
      onPressed: (_isSigningIn || _isSending || _isRestoringSession)
          ? null
          : _sendReminders,
      icon: (_isSigningIn || _isSending)
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.send_rounded),
      label: Text(_isSending
          ? 'Sending...'
          : _isSigningIn
              ? 'Signing in...'
              : 'Send Reminder Emails'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0F355B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    final signInButton = OutlinedButton.icon(
      onPressed:
          (_isSignedIn || _isSigningIn || _isRestoringSession || _isSending)
              ? null
              : _ensureSignedIn,
      icon: const Icon(Icons.login_rounded),
      label: const Text('Sign in Gmail'),
    );

    return _panel(
      child: isWide
          ? Row(
              children: [
                Expanded(child: info),
                const SizedBox(width: 12),
                signInButton,
                const SizedBox(width: 10),
                sendButton,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                info,
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: signInButton),
                    const SizedBox(width: 10),
                    Expanded(child: sendButton),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ReminderInvoice {
  const _ReminderInvoice({
    required this.id,
    required this.client,
    required this.pendingAmount,
    required this.contactEmail,
    required this.daysOverdue,
  });

  final String id;
  final String client;
  final double pendingAmount;
  final String contactEmail;
  final int daysOverdue;
}

class _ReminderTemplate {
  const _ReminderTemplate({
    required this.name,
    required this.subtitle,
    required this.subjectPrefix,
    required this.icon,
    required this.accent,
  });

  final String name;
  final String subtitle;
  final String subjectPrefix;
  final IconData icon;
  final Color accent;
}
