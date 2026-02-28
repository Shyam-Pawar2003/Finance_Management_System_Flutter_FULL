import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:http/http.dart' as http;

class GmailService {
  static final GmailService _instance = GmailService._internal();

  factory GmailService() {
    return _instance;
  }

  GmailService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/gmail.readonly',
    ],
  );

  GoogleSignInAccount? _currentUser;
  gmail.GmailApi? _gmailApi;

  GoogleSignInAccount? get currentUser => _currentUser;

  /// Authenticate user and initialize Gmail API
  Future<bool> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser == null) return false;

      // Create authenticated HTTP client
      final headers = await _currentUser!.authHeaders;
      final client = _GmailHttpClient(headers);

      _gmailApi = gmail.GmailApi(client);
      return true;
    } catch (e) {
      print('Error signing in: $e');
      return false;
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _gmailApi = null;
  }

  /// Get unread emails from Gmail inbox
  Future<List<GmailEmailModel>> getUnreadEmails({int maxResults = 10}) async {
    if (_gmailApi == null) {
      throw Exception('Gmail API not initialized. Please sign in first.');
    }

    try {
      final messageList = await _gmailApi!.users.messages.list(
        'me',
        q: 'is:unread',
        maxResults: maxResults,
      );

      List<GmailEmailModel> emails = [];

      if (messageList.messages != null) {
        for (final message in messageList.messages!) {
          try {
            final msg = await _gmailApi!.users.messages.get(
              'me',
              message.id!,
              format: 'full',
            );
            final email = GmailEmailModel.fromGmailMessage(msg);
            emails.add(email);
          } catch (e) {
            print('Error fetching message ${message.id}: $e');
            continue;
          }
        }
      }

      return emails;
    } catch (e) {
      print('Error fetching unread emails: $e');
      return [];
    }
  }

  /// Get all emails from Gmail inbox
  Future<List<GmailEmailModel>> getAllEmails({int maxResults = 20}) async {
    if (_gmailApi == null) {
      throw Exception('Gmail API not initialized. Please sign in first.');
    }

    try {
      final messageList = await _gmailApi!.users.messages.list(
        'me',
        maxResults: maxResults,
      );

      List<GmailEmailModel> emails = [];

      if (messageList.messages != null) {
        for (final message in messageList.messages!) {
          try {
            final msg = await _gmailApi!.users.messages.get(
              'me',
              message.id!,
              format: 'full',
            );
            final email = GmailEmailModel.fromGmailMessage(msg);
            emails.add(email);
          } catch (e) {
            print('Error fetching message ${message.id}: $e');
            continue;
          }
        }
      }

      return emails;
    } catch (e) {
      print('Error fetching all emails: $e');
      return [];
    }
  }

  /// Get emails by label
  Future<List<GmailEmailModel>> getEmailsByLabel(
    String labelId, {
    int maxResults = 20,
  }) async {
    if (_gmailApi == null) {
      throw Exception('Gmail API not initialized. Please sign in first.');
    }

    try {
      final messageList = await _gmailApi!.users.messages.list(
        'me',
        labelIds: [labelId],
        maxResults: maxResults,
      );

      List<GmailEmailModel> emails = [];

      if (messageList.messages != null) {
        for (final message in messageList.messages!) {
          try {
            final msg = await _gmailApi!.users.messages.get(
              'me',
              message.id!,
              format: 'full',
            );
            final email = GmailEmailModel.fromGmailMessage(msg);
            emails.add(email);
          } catch (e) {
            print('Error fetching message ${message.id}: $e');
            continue;
          }
        }
      }

      return emails;
    } catch (e) {
      print('Error fetching emails by label: $e');
      return [];
    }
  }

  /// Get email labels
  Future<List<String>> getLabels() async {
    if (_gmailApi == null) {
      throw Exception('Gmail API not initialized. Please sign in first.');
    }

    try {
      final labels = await _gmailApi!.users.labels.list('me');
      return labels.labels?.map((label) => label.name ?? '').toList() ?? [];
    } catch (e) {
      print('Error fetching labels: $e');
      return [];
    }
  }
}

/// Model for Gmail email
class GmailEmailModel {
  final String id;
  final String from;
  final String subject;
  final String snippet;
  final DateTime date;
  final bool isUnread;
  final String? body;

  GmailEmailModel({
    required this.id,
    required this.from,
    required this.subject,
    required this.snippet,
    required this.date,
    required this.isUnread,
    this.body,
  });

  /// Parse email from Gmail API message
  factory GmailEmailModel.fromGmailMessage(gmail.Message message) {
    final headers = message.payload?.headers ?? [];

    String getHeader(String name) {
      return headers
              .firstWhere(
                (h) => h.name?.toLowerCase() == name.toLowerCase(),
                orElse: () => gmail.MessagePartHeader(name: name, value: ''),
              )
              .value ??
          '';
    }

    // Try to extract body from message
    String? extractBody() {
      try {
        // First try to get body from parts
        if (message.payload?.parts != null &&
            message.payload!.parts!.isNotEmpty) {
          final firstPart = message.payload!.parts!.first;
          if (firstPart.body?.data != null) {
            return firstPart.body!.data;
          }
        }
        // Fallback to payload body
        if (message.payload?.body?.data != null) {
          return message.payload!.body!.data;
        }
        return null;
      } catch (e) {
        return null;
      }
    }

    // Parse date safely
    DateTime parseDate() {
      try {
        final dateStr = getHeader('Date');
        if (dateStr.isEmpty) {
          return DateTime.now();
        }
        return DateTime.parse(dateStr);
      } catch (e) {
        return DateTime.now();
      }
    }

    return GmailEmailModel(
      id: message.id ?? '',
      from: getHeader('From'),
      subject: getHeader('Subject'),
      snippet: message.snippet ?? '',
      date: parseDate(),
      isUnread: message.labelIds?.contains('UNREAD') ?? false,
      body: extractBody(),
    );
  }
}

/// Custom HTTP client for Gmail API authentication
class _GmailHttpClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  _GmailHttpClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Add authentication headers to the request
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}
