import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:local_sync/local_sync.dart';
import 'package:media_storage/media_storage.dart';
import '../photo_upload/services/quire_moment_uploader.dart';
import 'token_storage_service.dart';

/// HTTP Client connecting Quire Flutter app directly to the Golang BFF Service.
/// Supports cross-platform persistent tokens, automatic refresh, and session security.
class BffApiClient {
  final String baseUrl;
  final http.Client _client;
  final TokenStorageService? _storage;

  String? _accessToken;
  String? _refreshToken;
  String? _userEmail;

  BffApiClient({
    String? baseUrl,
    http.Client? client,
    TokenStorageService? storage,
  })  : baseUrl = baseUrl ?? 'http://127.0.0.1:8088',
        _client = client ?? http.Client(),
        _storage = storage;

  /// Initialize and restore stored session from cross-platform storage (Web/Mobile/Desktop)
  Future<bool> initSession() async {
    final storage = _storage ?? await TokenStorageService.getInstance();
    _accessToken = storage.getAccessToken();
    _refreshToken = storage.getRefreshToken();
    _userEmail = storage.getUserEmail();
    return hasSession;
  }

  bool get hasSession => _accessToken != null && _accessToken!.isNotEmpty;
  String? get currentEmail => _userEmail;
  String? get accessToken => _accessToken;

  void setAuthTokens({
    required String accessToken,
    required String refreshToken,
    String? userEmail,
  }) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    if (userEmail != null) _userEmail = userEmail;
    _storage?.saveSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userEmail: userEmail ?? _userEmail ?? '',
    );
  }

  void clearSession() {
    _accessToken = null;
    _refreshToken = null;
    _userEmail = null;
    _storage?.clearSession();
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  // ==========================================
  // Health & System
  // ==========================================

  Future<bool> checkHealth() async {
    try {
      final res = await _client.get(Uri.parse('$baseUrl/health'));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ==========================================
  // Authentication & Session Security
  // ==========================================

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/api/v1/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'display_name': displayName,
        }),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 201) {
        final aToken = (data['access_token'] ?? data['token']) as String?;
        final rToken = (data['refresh_token'] ?? '') as String;
        if (aToken != null) {
          setAuthTokens(
            accessToken: aToken,
            refreshToken: rToken,
            userEmail: email,
          );
        }
        return {'success': true, 'data': data};
      }
      return {'success': false, 'error': data['error'] ?? 'Lỗi đăng ký tài khoản'};
    } catch (e) {
      return {'success': false, 'error': 'Không thể kết nối máy chủ ($e)'};
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) {
        final aToken = (data['access_token'] ?? data['token']) as String?;
        final rToken = (data['refresh_token'] ?? '') as String;
        if (aToken != null) {
          setAuthTokens(
            accessToken: aToken,
            refreshToken: rToken,
            userEmail: email,
          );
        }
        return {'success': true, 'data': data};
      }
      return {'success': false, 'error': data['error'] ?? 'Lỗi đăng nhập'};
    } catch (e) {
      return {'success': false, 'error': 'Không thể kết nối máy chủ ($e)'};
    }
  }

  Future<bool> refreshSession() async {
    final rToken = _refreshToken ?? _storage?.getRefreshToken();
    if (rToken == null || rToken.isEmpty) return false;

    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/api/v1/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': rToken}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final aToken = data['access_token'] as String?;
        final newRToken = data['refresh_token'] as String?;
        if (aToken != null && newRToken != null) {
          setAuthTokens(
            accessToken: aToken,
            refreshToken: newRToken,
            userEmail: _userEmail,
          );
          return true;
        }
      }
      clearSession();
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    final rToken = _refreshToken ?? _storage?.getRefreshToken();
    try {
      await _client.post(
        Uri.parse('$baseUrl/api/v1/auth/logout'),
        headers: _headers,
        body: jsonEncode({'refresh_token': rToken ?? ''}),
      );
    } catch (_) {}
    clearSession();
  }

  Future<void> logoutAll() async {
    try {
      await _client.post(
        Uri.parse('$baseUrl/api/v1/auth/logout-all'),
        headers: _headers,
      );
    } catch (_) {}
    clearSession();
  }

  Future<Map<String, dynamic>> deactivateAccount({required String password}) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/api/v1/auth/deactivate'),
        headers: _headers,
        body: jsonEncode({'password': password}),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) {
        clearSession();
        return {'success': true, 'message': data['message']};
      }
      return {'success': false, 'error': data['error'] ?? 'Lỗi khi vô hiệu hóa tài khoản'};
    } catch (e) {
      return {'success': false, 'error': 'Không thể kết nối máy chủ: $e'};
    }
  }

  // ==========================================
  // Profile APIs
  // ==========================================

  Future<Map<String, dynamic>?> getMyProfile() async {
    final res = await _client.get(Uri.parse('$baseUrl/api/v1/profile/me'), headers: _headers);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else if (res.statusCode == 401) {
      if (await refreshSession()) {
        final retry = await _client.get(Uri.parse('$baseUrl/api/v1/profile/me'), headers: _headers);
        if (retry.statusCode == 200) {
          return jsonDecode(retry.body) as Map<String, dynamic>;
        }
      }
    }
    return null;
  }

  Future<bool> updateMyProfile({
    required String displayName,
    required String username,
    required String bio,
    required String city,
  }) async {
    final res = await _client.put(
      Uri.parse('$baseUrl/api/v1/profile/me'),
      headers: _headers,
      body: jsonEncode({
        'display_name': displayName,
        'username': username,
        'bio': bio,
        'city': city,
      }),
    );
    return res.statusCode == 200;
  }

  // ==========================================
  // Articles APIs (with Cursor Pagination)
  // ==========================================

  Future<Map<String, dynamic>?> getArticles({
    String? scope,
    String? topic,
    String? cursor,
    int limit = 20,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/articles').replace(queryParameters: {
      if (scope != null) 'scope': scope,
      if (topic != null) 'topic': topic,
      if (cursor != null) 'cursor': cursor,
      'limit': limit.toString(),
    });

    final res = await _client.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String, dynamic>?> publishArticle({
    required String title,
    required String category,
    required String excerpt,
    required String fullContent,
    required bool isPublic,
    String? coverImagePath,
  }) async {
    final res = await _client.post(
      Uri.parse('$baseUrl/api/v1/articles'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'category': category,
        'excerpt': excerpt,
        'full_content': fullContent,
        'is_public': isPublic,
        'cover_image_path': coverImagePath ?? '',
      }),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  // ==========================================
  // Moments APIs (with Soft-Purge)
  // ==========================================

  Future<Map<String, dynamic>?> getMomentsFeed({String? cursor, int limit = 20}) async {
    final uri = Uri.parse('$baseUrl/api/v1/moments/feed').replace(queryParameters: {
      if (cursor != null) 'cursor': cursor,
      'limit': limit.toString(),
    });

    final res = await _client.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String, dynamic>?> postMoment({
    required String imagePath,
    required String caption,
    String? circleId,
    int? autoPurgeDurationSeconds,
  }) async {
    final res = await _client.post(
      Uri.parse('$baseUrl/api/v1/moments'),
      headers: _headers,
      body: jsonEncode({
        'image_path': imagePath,
        'caption': caption,
        'circle_id': circleId ?? 'circle_1',
        'auto_purge_duration_seconds': autoPurgeDurationSeconds,
      }),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  // ==========================================
  // Contextual Chat APIs
  // ==========================================

  Future<List<dynamic>?> getInbox() async {
    final res = await _client.get(Uri.parse('$baseUrl/api/v1/chat/inbox'), headers: _headers);
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return json['data'] as List<dynamic>?;
    }
    return null;
  }

  Future<Map<String, dynamic>?> sendChatMessage({
    required String friendId,
    required String messageText,
    String? quotedMomentId,
    String? imagePath,
  }) async {
    final res = await _client.post(
      Uri.parse('$baseUrl/api/v1/chat/$friendId/messages'),
      headers: _headers,
      body: jsonEncode({
        'message_text': messageText,
        'quoted_moment_id': quotedMomentId,
        'image_path': imagePath,
      }),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }
}

/// Production implementation of QuireMomentUploader communicating via BffApiClient.
class BffMomentUploader extends QuireMomentUploader {
  final BffApiClient bffClient;

  BffMomentUploader({
    required this.bffClient,
    required MediaStorageAdapter storageAdapter,
    required LocalStoreAdapter localStore,
    required NetworkConnectivityChecker isOnline,
  }) : super(
          storageAdapter: storageAdapter,
          dbInserter: ({required momentRow, required recipientRows}) async {
            // Forward to Golang BFF
            final imagePath = momentRow['image_path'] as String;
            final caption = momentRow['caption'] as String? ?? '';
            final circleId = momentRow['circle_id'] as String? ?? 'circle_1';

            await bffClient.postMoment(
              imagePath: imagePath,
              caption: caption,
              circleId: circleId,
            );
          },
          localStore: localStore,
          isOnline: isOnline,
        );
}
