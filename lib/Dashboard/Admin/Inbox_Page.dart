import 'package:flutter/material.dart';
import '../../services/gmail_service.dart';

// Removed standalone `main` and `MyApp` widget because this
// screen is shown inside the main application.  Keeping them here
// caused duplicate `MaterialApp` declarations and could lead to
// unexpected runtime errors (e.g. the `Colors` lookup failing in
// the web build).  Use the `InboxPage` class directly through
// navigation or from another widget.

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  late GmailService _gmailService;
  bool _isSignedIn = false;
  bool _isLoading = false;
  List<GmailEmailModel> _emails = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _gmailService = GmailService();
    _checkSignInStatus();
  }

  /// Check if user is already signed in
  void _checkSignInStatus() async {
    if (_gmailService.currentUser != null) {
      setState(() {
        _isSignedIn = true;
      });
      _loadEmails();
    }
  }

  /// Sign in with Google
  void _handleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _gmailService.signIn();
      if (success) {
        setState(() {
          _isSignedIn = true;
        });
        _loadEmails();
      } else {
        setState(() {
          _errorMessage = 'Sign in cancelled';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error signing in: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Sign out
  void _handleSignOut() async {
    await _gmailService.signOut();
    setState(() {
      _isSignedIn = false;
      _emails = [];
      _errorMessage = null;
    });
  }

  /// Load emails from Gmail
  void _loadEmails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final emails = await _gmailService.getAllEmails(maxResults: 20);
      setState(() {
        _emails = emails;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading emails: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Load unread emails
  void _loadUnreadEmails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final emails = await _gmailService.getUnreadEmails(maxResults: 20);
      setState(() {
        _emails = emails;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading unread emails: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSignedIn) {
      return _buildSignInScreen();
    }

    return _buildInboxScreen();
  }

  /// Build sign-in screen
  Widget _buildSignInScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gmail Inbox"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mail,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              "Welcome to Gmail Inbox",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Sign in to view your emails",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _handleSignIn,
                    icon: const Icon(Icons.account_circle),
                    label: const Text("Sign in with Google"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      backgroundColor: Colors.blue,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  /// Build inbox screen
  Widget _buildInboxScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gmail Inbox"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmails,
            tooltip: "Refresh",
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'unread') {
                _loadUnreadEmails();
              } else if (value == 'all') {
                _loadEmails();
              } else if (value == 'signout') {
                _handleSignOut();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.all_inbox, color: Colors.blue),
                    SizedBox(width: 10),
                    Text('All Emails'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'unread',
                child: Row(
                  children: [
                    Icon(Icons.mail_outline, color: Colors.orange),
                    SizedBox(width: 10),
                    Text('Unread'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadEmails,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : _emails.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.mail_outline,
                            size: 60,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "No emails found",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _loadEmails,
                            child: const Text("Refresh"),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _emails.length,
                      itemBuilder: (context, index) {
                        final email = _emails[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Icon(
                                email.isUnread
                                    ? Icons.mail
                                    : Icons.mail_outline,
                                color: Colors.blue,
                              ),
                            ),
                            title: Text(
                              email.from,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: email.isUnread
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  email.subject,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                Text(
                                  email.snippet,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _formatDate(email.date),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                if (email.isUnread)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(top: 4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue.shade600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}
