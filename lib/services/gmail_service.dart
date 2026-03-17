import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const String _gmailWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
const String _gmailServerClientId =
    String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
const String _webClientIdPlaceholder =
    'REPLACE_WITH_WEB_CLIENT_ID.apps.googleusercontent.com';

class GmailService {
  static final GmailService _instance = GmailService._internal();

  factory GmailService() {
    return _instance;
  }

  GmailService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/gmail.readonly',
      'https://www.googleapis.com/auth/gmail.send',
    ],
    clientId: _gmailWebClientId.isEmpty ? null : _gmailWebClientId,
    serverClientId: _gmailServerClientId.isEmpty ? null : _gmailServerClientId,
  );

  GoogleSignInAccount? _currentUser;
  gmail.GmailApi? _gmailApi;
  http.Client? _authClient;

  GoogleSignInAccount? get currentUser =>
      _currentUser ?? _googleSignIn.currentUser;

  String _signInHelpMessage(String details) {
    final lowerDetails = details.toLowerCase();

    if (kIsWeb &&
        (lowerDetails.contains('clientid not set') ||
            lowerDetails.contains('appclientid != null'))) {
      return 'Google sign-in is not configured for web. Open web/index.html and replace the google-signin-client_id meta value with your real OAuth Web Client ID, or run with --dart-define=GOOGLE_WEB_CLIENT_ID=your_client_id.apps.googleusercontent.com.';
    }

    if (kIsWeb &&
        _gmailWebClientId.trim().toLowerCase() ==
            _webClientIdPlaceholder.toLowerCase()) {
      return 'Web client ID is still a placeholder. Set a valid GOOGLE_WEB_CLIENT_ID or replace the value in web/index.html.';
    }

    if (kIsWeb &&
        (lowerDetails.contains('invalid_client') ||
            lowerDetails.contains('unauthorized_client'))) {
      return 'Google sign-in client ID is invalid for this app. Verify the OAuth Web Client ID and allowed JavaScript origins in Google Cloud Console.';
    }

    if (lowerDetails.contains('apiexception: 10') ||
        lowerDetails.contains('developer error') ||
        lowerDetails.contains('oauth') ||
        lowerDetails.contains('client id')) {
      return 'Google sign-in configuration is incomplete. Check OAuth client IDs, SHA fingerprints, package name, and enabled Gmail API.';
    }

    return 'Google sign-in failed. Please verify Google OAuth setup and try again.';
  }

  Future<bool> restoreSession() async {
    try {
      final signedUser = _googleSignIn.currentUser;
      if (signedUser != null) {
        await _initializeApi(signedUser);
        return true;
      }

      final restoredUser = await _googleSignIn.signInSilently();
      if (restoredUser == null) {
        return false;
      }

      await _initializeApi(restoredUser);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _initializeApi(GoogleSignInAccount account) async {
    final headers = await account.authHeaders;
    _authClient?.close();
    _authClient = _GmailHttpClient(headers);
    _currentUser = account;
    _gmailApi = gmail.GmailApi(_authClient!);
  }

  Future<void> _ensureApiReady() async {
    if (_gmailApi != null && _currentUser != null) {
      return;
    }

    final user = currentUser;
    if (user == null) {
      throw Exception('Please sign in with Google first.');
    }

    await _initializeApi(user);
  }

  /// Authenticate user and initialize Gmail API
  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return false;
      }

      await _initializeApi(account);
      return true;
    } on PlatformException catch (error) {
      final code = error.code.toLowerCase();
      if (code.contains('cancel') || code.contains('canceled')) {
        return false;
      }

      final message = (error.message ?? '').trim();
      final details = message.isEmpty ? error.code : '$message (${error.code})';
      throw Exception(_signInHelpMessage(details));
    } catch (error) {
      throw Exception(_signInHelpMessage(error.toString()));
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _gmailApi = null;
    _authClient?.close();
    _authClient = null;
  }

  /// Get unread emails from Gmail inbox
  Future<List<GmailEmailModel>> getUnreadEmails({int maxResults = 10}) async {
    await _ensureApiReady();

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
      throw Exception('Unable to load unread emails. $e');
    }
  }

  /// Get all emails from Gmail inbox
  Future<List<GmailEmailModel>> getAllEmails({int maxResults = 20}) async {
    await _ensureApiReady();

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
      throw Exception('Unable to load inbox emails. $e');
    }
  }

  /// Get emails by label
  Future<List<GmailEmailModel>> getEmailsByLabel(
    String labelId, {
    int maxResults = 20,
  }) async {
    await _ensureApiReady();

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
      throw Exception('Unable to load emails for this label. $e');
    }
  }

  /// Get email labels
  Future<List<String>> getLabels() async {
    await _ensureApiReady();

    try {
      final labels = await _gmailApi!.users.labels.list('me');
      return labels.labels?.map((label) => label.name ?? '').toList() ?? [];
    } catch (e) {
      throw Exception('Unable to fetch Gmail labels. $e');
    }
  }

  /// Send an email using Gmail API.
  Future<void> sendEmail({
    required String to,
    required String subject,
    required String body,
    String? cc,
    String? bcc,
  }) async {
    await _ensureApiReady();

    if (to.trim().isEmpty) {
      throw Exception('Recipient email is required.');
    }

    final user = currentUser;
    final senderEmail = user?.email ?? 'me';
    final senderName = (user?.displayName ?? '').trim();
    final fromHeader =
        senderName.isEmpty ? senderEmail : '"$senderName" <$senderEmail>';

    final messageLines = <String>[
      'From: $fromHeader',
      'To: ${to.trim()}',
      if (cc != null && cc.trim().isNotEmpty) 'Cc: ${cc.trim()}',
      if (bcc != null && bcc.trim().isNotEmpty) 'Bcc: ${bcc.trim()}',
      'Subject: ${subject.trim()}',
      'MIME-Version: 1.0',
      'Content-Type: text/plain; charset="utf-8"',
      'Content-Transfer-Encoding: 8bit',
      '',
      body,
    ];

    final rawMessage = messageLines.join('\r\n');
    final encodedMessage =
        base64Url.encode(utf8.encode(rawMessage)).replaceAll('=', '');

    final gmailMessage = gmail.Message()..raw = encodedMessage;

    try {
      await _gmailApi!.users.messages.send(gmailMessage, 'me');
    } catch (error) {
      final lower = error.toString().toLowerCase();
      if (lower.contains('insufficient') || lower.contains('permission')) {
        throw Exception(
          'Gmail send permission is missing. Sign out, then sign in again to grant send access.',
        );
      }
      throw Exception('Unable to send Gmail message. $error');
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

    String decodeBase64Url(String value) {
      final normalized = value.replaceAll('-', '+').replaceAll('_', '/');
      final padding = (4 - normalized.length % 4) % 4;
      final withPadding = '$normalized${'=' * padding}';
      return utf8.decode(base64.decode(withPadding), allowMalformed: true);
    }

    String cleanBodyText(String rawText) {
      var text = rawText;
      text = text.replaceAll(RegExp(r'<[^>]*>'), ' ');
      text = text
          .replaceAll('&nbsp;', ' ')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&quot;', '"')
          .replaceAll('&#39;', "'");
      text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
      return text;
    }

    String? extractBodyFromPart(gmail.MessagePart? part) {
      if (part == null) {
        return null;
      }

      final mimeType = part.mimeType?.toLowerCase() ?? '';
      final data = part.body?.data;
      if (data != null && data.isNotEmpty) {
        try {
          final decoded = decodeBase64Url(data);
          final cleaned = cleanBodyText(decoded);
          if (cleaned.isNotEmpty &&
              (mimeType.contains('text/plain') ||
                  mimeType.contains('text/html') ||
                  mimeType.isEmpty)) {
            return cleaned;
          }
        } catch (_) {
          // Skip invalid body chunk and continue searching nested parts.
        }
      }

      final nestedParts = part.parts ?? <gmail.MessagePart>[];
      for (final nested in nestedParts) {
        final nestedBody = extractBodyFromPart(nested);
        if (nestedBody != null && nestedBody.isNotEmpty) {
          return nestedBody;
        }
      }

      return null;
    }

    DateTime parseDate() {
      final rawDate = getHeader('Date').trim();
      if (rawDate.isEmpty) {
        return DateTime.now();
      }

      final cleanedDate = rawDate.replaceAll(RegExp(r'\s*\(.*\)$'), '').trim();
      final patterns = [
        'EEE, d MMM yyyy HH:mm:ss Z',
        'EEE, dd MMM yyyy HH:mm:ss Z',
        'd MMM yyyy HH:mm:ss Z',
        'EEE, d MMM yyyy HH:mm Z',
      ];

      for (final pattern in patterns) {
        try {
          return DateFormat(pattern, 'en_US')
              .parse(cleanedDate, true)
              .toLocal();
        } catch (_) {
          continue;
        }
      }

      final fallback = DateTime.tryParse(cleanedDate);
      return (fallback ?? DateTime.now()).toLocal();
    }

    return GmailEmailModel(
      id: message.id ?? '',
      from: getHeader('From'),
      subject: getHeader('Subject'),
      snippet: message.snippet ?? '',
      date: parseDate(),
      isUnread: message.labelIds?.contains('UNREAD') ?? false,
      body: extractBodyFromPart(message.payload),
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
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
