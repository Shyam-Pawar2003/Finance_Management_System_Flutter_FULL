import 'package:flutter/material.dart';

import '../../services/gmail_service.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  late final GmailService _gmailService;
  final TextEditingController _searchController = TextEditingController();

  bool _isSignedIn = false;
  bool _isBootstrapping = true;
  bool _isLoading = false;
  List<GmailEmailModel> _emails = [];
  String? _errorMessage;
  String _activeFeed = 'All';

  @override
  void initState() {
    super.initState();
    _gmailService = GmailService();
    _searchController.addListener(() => setState(() {}));
    _restoreSignInIfAvailable();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GmailEmailModel> get _visibleEmails {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _emails;
    }

    return _emails.where((email) {
      return email.from.toLowerCase().contains(query) ||
          email.subject.toLowerCase().contains(query) ||
          email.snippet.toLowerCase().contains(query);
    }).toList();
  }

  int get _unreadCount {
    return _emails.where((email) => email.isUnread).length;
  }

  Future<void> _restoreSignInIfAvailable() async {
    setState(() {
      _isBootstrapping = true;
      _errorMessage = null;
    });

    try {
      final restored = await _gmailService.restoreSession();
      if (!mounted) return;

      if (restored) {
        setState(() {
          _isSignedIn = true;
        });
        await _loadEmails(feed: _activeFeed, showLoader: false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSignedIn = false;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isBootstrapping = false;
      });
    }
  }

  String _friendlyErrorMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    final normalized = message.toLowerCase();

    if (normalized.contains('network') || normalized.contains('socket')) {
      return 'Network error while contacting Google. Check your internet and try again.';
    }

    if (normalized.contains('oauth') ||
        normalized.contains('apiexception: 10') ||
        normalized.contains('client id') ||
        normalized.contains('developer error')) {
      return 'Google sign-in is not configured correctly. Add OAuth client IDs (Web/Android), app SHA fingerprints, package name, and Gmail API access in Google Cloud Console. For web, set google-signin-client_id in web/index.html or run with --dart-define=GOOGLE_WEB_CLIENT_ID=your_client_id.apps.googleusercontent.com.';
    }

    if (normalized.contains('cancel')) {
      return 'Sign-in was canceled before completion.';
    }

    return message.isEmpty
        ? 'Something went wrong during sign-in. Please try again.'
        : message;
  }

  Future<void> _handleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _gmailService.signIn();
      if (!mounted) return;

      if (success) {
        setState(() {
          _isSignedIn = true;
        });
        await _loadEmails(feed: _activeFeed);
      } else {
        setState(() {
          _errorMessage = 'Sign-in was canceled.';
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _friendlyErrorMessage(error);
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSignOut() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _gmailService.signOut();
      if (!mounted) return;
      _searchController.clear();
      setState(() {
        _isSignedIn = false;
        _emails = [];
        _activeFeed = 'All';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _friendlyErrorMessage(error);
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEmails({
    String feed = 'All',
    bool showLoader = true,
  }) async {
    if (showLoader) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _activeFeed = feed;
      });
    } else {
      setState(() {
        _errorMessage = null;
        _activeFeed = feed;
      });
    }

    try {
      final emails = feed == 'Unread'
          ? await _gmailService.getUnreadEmails(maxResults: 20)
          : await _gmailService.getAllEmails(maxResults: 20);
      if (!mounted) return;
      setState(() {
        _emails = emails;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _friendlyErrorMessage(error);
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showEmailDetails(GmailEmailModel email) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(email.subject.isEmpty ? '(No subject)' : email.subject),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('From: ${email.from}'),
                const SizedBox(height: 8),
                Text('Date: ${_formatFullDate(email.date)}'),
                const SizedBox(height: 8),
                Text('Status: ${email.isUnread ? 'Unread' : 'Read'}'),
                const SizedBox(height: 16),
                Text(
                  email.body?.isNotEmpty == true ? email.body! : email.snippet,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _formatShortDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final emailDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(emailDate).inDays;

    if (difference == 0) {
      final hour =
          date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final suffix = date.hour >= 12 ? 'PM' : 'AM';
      return '$hour:${date.minute.toString().padLeft(2, '0')} $suffix';
    }
    if (difference == 1) {
      return 'Yesterday';
    }
    if (difference < 7) {
      return '${difference}d ago';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatFullDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _senderInitials(String from) {
    final cleaned = from.trim();
    if (cleaned.isEmpty) return '?';
    final parts = cleaned.split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final visibleEmails = _visibleEmails;
    final currentUser = _gmailService.currentUser;
    final isCompact = MediaQuery.sizeOf(context).width < 760;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCompact)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Inbox Workspace',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isSignedIn
                        ? 'Review inbox activity, unread mail, and message previews for the connected Google account.'
                        : 'Connect your Google account to review inbox activity directly from the HR workspace.',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isSignedIn)
                ElevatedButton.icon(
                  onPressed:
                      _isLoading ? null : () => _loadEmails(feed: _activeFeed),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed:
                      (_isLoading || _isBootstrapping) ? null : _handleSignIn,
                  icon: const Icon(Icons.login),
                  label: const Text('Connect Gmail'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Inbox Workspace',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isSignedIn
                          ? 'Review inbox activity, unread mail, and message previews for the connected Google account.'
                          : 'Connect your Google account to review inbox activity directly from the HR workspace.',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (_isSignedIn)
                ElevatedButton.icon(
                  onPressed:
                      _isLoading ? null : () => _loadEmails(feed: _activeFeed),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed:
                      (_isLoading || _isBootstrapping) ? null : _handleSignIn,
                  icon: const Icon(Icons.login),
                  label: const Text('Connect Gmail'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
            ],
          ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth >= 1000
                ? (constraints.maxWidth - 36) / 4
                : constraints.maxWidth >= 700
                    ? (constraints.maxWidth - 12) / 2
                    : constraints.maxWidth;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SummaryCard(
                  width: cardWidth,
                  title: 'Connection',
                  value: _isSignedIn ? 'Connected' : 'Not connected',
                  icon: Icons.cloud_done_outlined,
                  color: _isSignedIn ? Colors.green : Colors.grey,
                ),
                _SummaryCard(
                  width: cardWidth,
                  title: 'Messages Loaded',
                  value: '${_emails.length}',
                  icon: Icons.mail_outline,
                  color: Colors.indigo,
                ),
                _SummaryCard(
                  width: cardWidth,
                  title: 'Unread In View',
                  value: '$_unreadCount',
                  icon: Icons.mark_email_unread_outlined,
                  color: Colors.orange,
                ),
                _SummaryCard(
                  width: cardWidth,
                  title: 'Active Feed',
                  value: _activeFeed,
                  icon: Icons.inbox_outlined,
                  color: Colors.blue,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        if (_isSignedIn && _gmailService.isDemoMode)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Text(
              'Demo inbox mode is active for local development. Configure Google OAuth to load real Gmail messages.',
              style: TextStyle(color: Colors.amber.shade900),
            ),
          ),
        if (_isBootstrapping)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (!_isSignedIn)
          Expanded(
            child: LayoutBuilder(
              builder: (context, boxConstraints) {
                final messageMaxWidth = boxConstraints.maxWidth < 540
                    ? boxConstraints.maxWidth
                    : 540.0;
                final hintMaxWidth = boxConstraints.maxWidth < 620
                    ? boxConstraints.maxWidth
                    : 620.0;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: boxConstraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.mail_lock_outlined,
                              size: 46,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Connect Gmail to continue',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          ConstrainedBox(
                            constraints:
                                BoxConstraints(maxWidth: messageMaxWidth),
                            child: const Text(
                              'Sign in with your Google account to view your inbox, filter unread messages, and open message previews directly from this workspace.',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.black54, height: 1.4),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: hintMaxWidth),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Text(
                                'If sign-in fails: update web/index.html and replace REPLACE_WITH_WEB_CLIENT_ID.apps.googleusercontent.com with your real OAuth Web Client ID, then restart flutter run.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black54,
                                  height: 1.35,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 18),
                            ConstrainedBox(
                              constraints:
                                  BoxConstraints(maxWidth: hintMaxWidth),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.red.shade200),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          _isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton.icon(
                                  onPressed: _handleSignIn,
                                  icon:
                                      const Icon(Icons.account_circle_outlined),
                                  label: const Text('Sign in with Google'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 22,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        else ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, accountConstraints) {
                    final accountCompact = accountConstraints.maxWidth < 640;

                    if (accountCompact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.indigo.shade50,
                                child: Text(
                                  _senderInitials(currentUser?.displayName ??
                                      currentUser?.email ??
                                      'G'),
                                  style: TextStyle(
                                    color: Colors.indigo.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentUser?.displayName ??
                                          'Google Account',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      currentUser?.email ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _isLoading ? null : _handleSignOut,
                            icon: const Icon(Icons.logout),
                            label: const Text('Sign Out'),
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.indigo.shade50,
                          child: Text(
                            _senderInitials(currentUser?.displayName ??
                                currentUser?.email ??
                                'G'),
                            style: TextStyle(
                              color: Colors.indigo.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentUser?.displayName ?? 'Google Account',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                currentUser?.email ?? '',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _isLoading ? null : _handleSignOut,
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign Out'),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search sender, subject, or snippet',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.trim().isEmpty
                        ? null
                        : IconButton(
                            onPressed: () => _searchController.clear(),
                            icon: const Icon(Icons.close),
                          ),
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF4F6FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _activeFeed == 'All',
                      onSelected:
                          _isLoading ? null : (_) => _loadEmails(feed: 'All'),
                    ),
                    ChoiceChip(
                      label: const Text('Unread'),
                      selected: _activeFeed == 'Unread',
                      onSelected: _isLoading
                          ? null
                          : (_) => _loadEmails(feed: 'Unread'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _InboxEmptyState(
                        icon: Icons.error_outline,
                        title: 'Unable to load emails',
                        message: _errorMessage!,
                        actionLabel: 'Retry',
                        onPressed: () => _loadEmails(feed: _activeFeed),
                      )
                    : visibleEmails.isEmpty
                        ? _InboxEmptyState(
                            icon: Icons.mail_outline,
                            title: 'No emails found',
                            message:
                                'Try switching the feed or refreshing the inbox.',
                            actionLabel: 'Refresh',
                            onPressed: () => _loadEmails(feed: _activeFeed),
                          )
                        : RefreshIndicator(
                            onRefresh: () => _loadEmails(feed: _activeFeed),
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: visibleEmails.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final email = visibleEmails[index];
                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () => _showEmailDetails(email),
                                    borderRadius: BorderRadius.circular(14),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 22,
                                          backgroundColor: email.isUnread
                                              ? Colors.blue.shade50
                                              : Colors.grey.shade200,
                                          child: Text(
                                            _senderInitials(email.from),
                                            style: TextStyle(
                                              color: email.isUnread
                                                  ? Colors.blue.shade700
                                                  : Colors.black54,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      email.from,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: email
                                                                .isUnread
                                                            ? FontWeight.bold
                                                            : FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  _FeedBadge(
                                                    label: email.isUnread
                                                        ? 'Unread'
                                                        : 'Read',
                                                    color: email.isUnread
                                                        ? Colors.blue
                                                        : Colors.grey,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                email.subject.isEmpty
                                                    ? '(No subject)'
                                                    : email.subject,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                email.snippet,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  height: 1.35,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  _MetaChip(
                                                    icon: Icons.schedule,
                                                    text: _formatShortDate(
                                                        email.date),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ],
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
                    fontSize: 20,
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

class _InboxEmptyState extends StatelessWidget {
  const _InboxEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: Colors.black38),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onPressed,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _FeedBadge extends StatelessWidget {
  const _FeedBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
