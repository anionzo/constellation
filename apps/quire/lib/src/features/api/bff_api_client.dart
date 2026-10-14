import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:local_sync/local_sync.dart';
import 'package:media_storage/media_storage.dart';
import '../photo_upload/services/quire_moment_uploader.dart';

/// HTTP Client connecting Quire Flutter app directly to the Golang BFF Service.
class BffApiClient {
  final String baseUrl;
  final http.Client _client;
  String? _authToken;

  BffApiClient({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? 'http://127.0.0.1:8000',
        _client = client ?? http.Client();

  /// Set the Supabase JWT token for authenticated requests.
  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
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
  // Profile APIs
  // ==========================================

  Future<Map<String, dynamic>?> getMyProfile() async {
    final res = await _client.get(Uri.parse('$baseUrl/api/v1/profile/me'), headers: _headers);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
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
