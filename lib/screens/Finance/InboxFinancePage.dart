import 'package:flutter/material.dart';

class InboxFinancePage extends StatefulWidget {
  const InboxFinancePage({super.key});

  @override
  State<InboxFinancePage> createState() => _InboxFinancePageState();
}

class _InboxFinancePageState extends State<InboxFinancePage> {
  String _selectedFilter = 'All';
  String _selectedChannel = 'All';
  String _searchQuery = '';

  late final TextEditingController _searchController;

  static const List<String> _filters = ['All', 'Unread', 'Flagged', 'High'];
  static const List<String> _channels = ['All', 'Email', 'Internal', 'System'];

  final List<_InboxMessage> _messages = const [
    _InboxMessage(
      id: 'MSG-001',
      sender: 'Apex Labs',
      subject: 'Invoice Clarification Required',
      snippet: 'Please confirm tax code on invoice INV-302 before release.',
      time: '09:40',
      isUnread: true,
      isFlagged: true,
      priority: 'High',
      channel: 'Email',
    ),
    _InboxMessage(
      id: 'MSG-002',
      sender: 'Payroll Bot',
      subject: 'Payroll Batch Validation Complete',
      snippet: 'All records passed except 2 pending bank account checks.',
      time: '08:10',
      isUnread: false,
      isFlagged: false,
      priority: 'Medium',
      channel: 'System',
    ),
    _InboxMessage(
      id: 'MSG-003',
      sender: 'Northwind Co.',
      subject: 'Payment Proof Uploaded',
      snippet: 'Receipt attached for TRX-8901. Please confirm settlement.',
      time: 'Yesterday',
      isUnread: true,
      isFlagged: false,
      priority: 'Medium',
      channel: 'Email',
    ),
    _InboxMessage(
      id: 'MSG-004',
      sender: 'Finance Admin Team',
      subject: 'Quarterly Budget Meeting',
      snippet: 'Reminder: budget review call scheduled for Friday 11:30 AM.',
      time: 'Yesterday',
      isUnread: false,
      isFlagged: true,
      priority: 'Low',
      channel: 'Internal',
    ),
    _InboxMessage(
      id: 'MSG-005',
      sender: 'Security Notice',
      subject: 'API Key Rotation Due',
      snippet: 'Finance integration key expires in 3 days.',
      time: '2 days ago',
      isUnread: true,
      isFlagged: true,
      priority: 'High',
      channel: 'System',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_InboxMessage> get _filteredMessages {
    final query = _searchQuery.trim().toLowerCase();
    return _messages.where((message) {
      final matchesQuery = query.isEmpty ||
          message.sender.toLowerCase().contains(query) ||
          message.subject.toLowerCase().contains(query) ||
          message.snippet.toLowerCase().contains(query) ||
          message.id.toLowerCase().contains(query);

      final matchesChannel =
          _selectedChannel == 'All' || message.channel == _selectedChannel;

      final matchesFilter = _selectedFilter == 'All' ||
          (_selectedFilter == 'Unread' && message.isUnread) ||
          (_selectedFilter == 'Flagged' && message.isFlagged) ||
          (_selectedFilter == 'High' && message.priority == 'High');

      return matchesQuery && matchesChannel && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 760;
        final isNarrow = width < 1100;
        final messages = _filteredMessages;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isCompact),
              const SizedBox(height: 18),
              _buildHeroCard(messages),
              const SizedBox(height: 16),
              _buildMetrics(width, messages),
              const SizedBox(height: 16),
              _buildFilters(isCompact),
              const SizedBox(height: 16),
              if (isNarrow) ...[
                _buildMessagesPanel(messages, isCompact),
                const SizedBox(height: 14),
                _buildRightPanel(messages),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildMessagesPanel(messages, false),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildRightPanel(messages),
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
          'Inbox',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 6),
        Text(
          'Review conversations, alerts, and action-required finance updates.',
          style: TextStyle(color: Color(0xFF5F6368)),
        ),
      ],
    );

    final actions = ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.add_comment_rounded, size: 18),
      label: const Text('New Message'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
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
        const SizedBox(width: 12),
        actions,
      ],
    );
  }

  Widget _buildHeroCard(List<_InboxMessage> messages) {
    final unread = messages.where((m) => m.isUnread).length;
    final flagged = messages.where((m) => m.isFlagged).length;

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Message Center',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${messages.length} conversations',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 33,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _heroChip('Unread', '$unread'),
              _heroChip('Flagged', '$flagged'),
              _heroChip('SLA', '1h 20m avg'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String label, String value) {
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
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics(double width, List<_InboxMessage> messages) {
    final crossAxisCount = width >= 1280
        ? 4
        : width >= 860
            ? 2
            : 1;

    final cards = [
      _InboxMetric(
        title: 'Unread',
        value: '${messages.where((m) => m.isUnread).length}',
        subtitle: 'Messages waiting for response',
        color: const Color(0xFF1A73E8),
        icon: Icons.mark_email_unread_rounded,
      ),
      _InboxMetric(
        title: 'Flagged',
        value: '${messages.where((m) => m.isFlagged).length}',
        subtitle: 'High-visibility threads',
        color: const Color(0xFFF29900),
        icon: Icons.flag_rounded,
      ),
      _InboxMetric(
        title: 'High Priority',
        value: '${messages.where((m) => m.priority == 'High').length}',
        subtitle: 'Urgent items in queue',
        color: const Color(0xFFDB4437),
        icon: Icons.priority_high_rounded,
      ),
      _InboxMetric(
        title: 'Resolution Rate',
        value: '92%',
        subtitle: 'Handled within SLA',
        color: const Color(0xFF0F9D58),
        icon: Icons.task_alt_rounded,
      ),
    ];

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
                width: 42,
                height: 42,
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
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
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

  Widget _buildFilters(bool isCompact) {
    final search = TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        hintText: 'Search sender, subject, or message id',
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
        ),
      ),
    );

    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCompact)
            search
          else
            Row(
              children: [
                Expanded(child: search),
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _selectedFilter = 'All';
                      _selectedChannel = 'All';
                    });
                  },
                  icon: const Icon(Icons.restart_alt_rounded, size: 18),
                  label: const Text('Reset'),
                ),
              ],
            ),
          if (isCompact)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _selectedFilter = 'All';
                    _selectedChannel = 'All';
                  });
                },
                icon: const Icon(Icons.restart_alt_rounded, size: 18),
                label: const Text('Reset'),
              ),
            ),
          const SizedBox(height: 10),
          const Text(
            'Status Filter',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _filters
                .map(
                  (filter) => ChoiceChip(
                    label: Text(filter),
                    selected: _selectedFilter == filter,
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: const Color(0xFF1A73E8),
                    labelStyle: TextStyle(
                      color: _selectedFilter == filter
                          ? Colors.white
                          : const Color(0xFF334155),
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: _selectedFilter == filter
                          ? const Color(0xFF1A73E8)
                          : const Color(0xFFD5DEE9),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          const Text(
            'Channel',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _channels
                .map(
                  (channel) => ChoiceChip(
                    label: Text(channel),
                    selected: _selectedChannel == channel,
                    onSelected: (_) {
                      setState(() {
                        _selectedChannel = channel;
                      });
                    },
                    selectedColor: const Color(0xFF0F355B),
                    labelStyle: TextStyle(
                      color: _selectedChannel == channel
                          ? Colors.white
                          : const Color(0xFF334155),
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: _selectedChannel == channel
                          ? const Color(0xFF0F355B)
                          : const Color(0xFFD5DEE9),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesPanel(List<_InboxMessage> messages, bool isCompact) {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Messages',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${messages.length} threads',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (messages.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'No messages found for selected filters.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ...messages
                .map((message) => _buildMessageRow(message, isCompact))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildMessageRow(_InboxMessage message, bool isCompact) {
    final priorityColor = _priorityColor(message.priority);

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message.subject,
          style: TextStyle(
            fontWeight: message.isUnread ? FontWeight.w800 : FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${message.id} | ${message.sender}',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          message.snippet,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      ],
    );

    final statusChips = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _chip(message.channel, const Color(0xFF123A68)),
        _chip(message.priority, priorityColor),
        if (message.isUnread) _chip('Unread', const Color(0xFF1A73E8)),
        if (message.isFlagged) _chip('Flagged', const Color(0xFFF29900)),
      ],
    );

    if (isCompact) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A73E8).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.mail_outline_rounded,
                    color: Color(0xFF1A73E8),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: header),
              ],
            ),
            const SizedBox(height: 8),
            statusChips,
            const SizedBox(height: 6),
            Text(
              message.time,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.mail_outline_rounded,
              color: Color(0xFF1A73E8),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: header),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              statusChips,
              const SizedBox(height: 6),
              Text(
                message.time,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(List<_InboxMessage> messages) {
    final pendingReply = messages.where((m) => m.isUnread).length;

    return Column(
      children: [
        _panel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Action Queue',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              _queueTile('Pending Replies', '$pendingReply'),
              const SizedBox(height: 8),
              _queueTile('Needs Escalation', '2'),
              const SizedBox(height: 8),
              _queueTile('Awaiting Attachment', '1'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _panel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              _actionButton(Icons.done_all_rounded, 'Mark all as read'),
              const SizedBox(height: 8),
              _actionButton(Icons.label_important_rounded, 'Review flagged'),
              const SizedBox(height: 8),
              _actionButton(Icons.file_download_done_rounded, 'Export log'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _queueTile(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A73E8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 18, color: const Color(0xFF1A73E8)),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          side: const BorderSide(color: Color(0xFFD5DEE9)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFDB4437);
      case 'Medium':
        return const Color(0xFFF29900);
      default:
        return const Color(0xFF0F9D58);
    }
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
}

class _InboxMessage {
  const _InboxMessage({
    required this.id,
    required this.sender,
    required this.subject,
    required this.snippet,
    required this.time,
    required this.isUnread,
    required this.isFlagged,
    required this.priority,
    required this.channel,
  });

  final String id;
  final String sender;
  final String subject;
  final String snippet;
  final String time;
  final bool isUnread;
  final bool isFlagged;
  final String priority;
  final String channel;
}

class _InboxMetric {
  const _InboxMetric({
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
