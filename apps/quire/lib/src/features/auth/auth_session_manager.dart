import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/bff_api_client.dart';

/// User profile model encapsulating authenticated identity.
class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String username;

  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.username,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? json['email']?.toString() ?? 'Bạn',
      username: json['username']?.toString() ?? '@ban.quire',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'display_name': displayName,
        'username': username,
      };
}

/// Single Source of Truth for Authentication and Token Management.
/// Handles cross-platform persistent storage, token rotation, and reactive state.
class AuthSessionManager extends ChangeNotifier {
  static const String _keyAccessToken = 'quire_access_token';
  static const String _keyRefreshToken = 'quire_refresh_token';
  static const String _keyUserProfile = 'quire_user_profile';

  final BffApiClient apiClient;

  String? _accessToken;
  String? _refreshToken;
  UserProfile? _currentUser;
  bool _isInitialized = false;

  AuthSessionManager({required this.apiClient});

  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  UserProfile? get currentUser => _currentUser;
  String get userDisplayName => _currentUser?.displayName ?? 'Khách trải nghiệm';
  String get userEmail => _currentUser?.email ?? 'khach@quire.app';
  String get userUsername => _currentUser?.username ?? '@ban.quire';

  /// 1. Initialize Session on Cold Boot or Web F5 Refresh
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_keyAccessToken);
      final savedRefreshToken = prefs.getString(_keyRefreshToken);
      final userJsonStr = prefs.getString(_keyUserProfile);

      if (savedToken != null && savedToken.isNotEmpty) {
        _accessToken = savedToken;
        _refreshToken = savedRefreshToken;

        if (userJsonStr != null && userJsonStr.isNotEmpty) {
          try {
            final map = jsonDecode(userJsonStr) as Map<String, dynamic>;
            _currentUser = UserProfile.fromJson(map);
          } catch (_) {}
        }

        // Configure API client with restored token if not guest
        if (_accessToken != null && _accessToken != 'guest_token') {
          apiClient.setAuthTokens(
            accessToken: _accessToken!,
            refreshToken: _refreshToken ?? '',
            userEmail: _currentUser?.email,
          );

          // Verify if user account still exists in database (handles database resets)
          final profile = await apiClient.getMyProfile();
          if (profile == null && !apiClient.hasSession) {
            // Stale account deleted from database: clear dead token
            await _clearStorage();
          }
        }
      }
    } catch (e) {
      debugPrint('[AuthSessionManager] Error restoring session: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// 2. User Login with Email & Password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await apiClient.login(email: email, password: password);
    if (res['success'] == true) {
      final data = res['data'] as Map<String, dynamic>;
      await _persistSession(data, fallbackEmail: email);
      return {'success': true};
    }
    return {'success': false, 'error': res['error'] ?? 'Đăng nhập không thành công'};
  }

  /// 3. User Sign Up
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final res = await apiClient.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
    if (res['success'] == true) {
      final data = res['data'] as Map<String, dynamic>;
      await _persistSession(data, fallbackEmail: email, fallbackDisplayName: displayName);
      return {'success': true};
    }
    return {'success': false, 'error': res['error'] ?? 'Đăng ký không thành công'};
  }

  /// 4. Guest Mode (Instant Access with persistent guest session across F5)
  Future<void> enterAsGuest() async {
    _accessToken = 'guest_token';
    _refreshToken = '';
    _currentUser = const UserProfile(
      id: 'guest',
      email: 'khach@quire.app',
      displayName: 'Khách trải nghiệm',
      username: '@khach.quire',
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setString(_keyAccessToken, 'guest_token'),
        prefs.setString(_keyRefreshToken, ''),
        prefs.setString(_keyUserProfile, jsonEncode(_currentUser!.toJson())),
      ]);
    } catch (_) {}

    notifyListeners();
  }

  /// 5. Token Rotation & Refresh
  Future<bool> refresh() async {
    final res = await apiClient.refreshSession();
    if (res != null) {
      _accessToken = apiClient.accessToken;
      final prefs = await SharedPreferences.getInstance();
      if (_accessToken != null) {
        await prefs.setString(_keyAccessToken, _accessToken!);
      }
      notifyListeners();
      return true;
    } else {
      await logout();
      return false;
    }
  }

  /// 6. Logout Single Device (Invalidates token on server & wipes storage)
  Future<void> logout() async {
    try {
      await apiClient.logout();
    } catch (_) {}
    await _clearStorage();
    notifyListeners();
  }

  /// 7. Logout All Devices (Revokes all active sessions in PostgreSQL)
  Future<void> logoutAll() async {
    try {
      await apiClient.logoutAll();
    } catch (_) {}
    await _clearStorage();
    notifyListeners();
  }

  /// 8. Deactivate Account
  Future<Map<String, dynamic>> deactivateAccount({required String password}) async {
    final res = await apiClient.deactivateAccount(password: password);
    if (res['success'] == true) {
      await _clearStorage();
      notifyListeners();
      return {'success': true};
    }
    return {'success': false, 'error': res['error'] ?? 'Lỗi khi vô hiệu hóa tài khoản'};
  }

  // --- Internal Persistence Helpers ---

  Future<void> _persistSession(
    Map<String, dynamic> data, {
    String? fallbackEmail,
    String? fallbackDisplayName,
  }) async {
    final aToken = (data['access_token'] ?? data['token'])?.toString() ?? '';
    final rToken = (data['refresh_token'])?.toString() ?? '';

    _accessToken = aToken;
    _refreshToken = rToken;

    if (data['user'] is Map<String, dynamic>) {
      _currentUser = UserProfile.fromJson(data['user'] as Map<String, dynamic>);
    } else {
      _currentUser = UserProfile(
        id: 'usr_local',
        email: fallbackEmail ?? '',
        displayName: fallbackDisplayName ?? (fallbackEmail != null ? fallbackEmail.split('@')[0] : 'Bạn'),
        username: '@${fallbackDisplayName?.toLowerCase().replaceAll(' ', '.') ?? 'ban.quire'}',
      );
    }

    // Persist to SharedPreferences (LocalStorage on Web, Secure on Mobile/Desktop)
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setString(_keyAccessToken, aToken),
        prefs.setString(_keyRefreshToken, rToken),
        prefs.setString(_keyUserProfile, jsonEncode(_currentUser!.toJson())),
      ]);
    } catch (_) {}

    apiClient.setAuthTokens(
      accessToken: aToken,
      refreshToken: rToken,
      userEmail: _currentUser?.email,
    );

    notifyListeners();
  }

  Future<void> _clearStorage() async {
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;
    apiClient.clearSession();

    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_keyAccessToken),
        prefs.remove(_keyRefreshToken),
        prefs.remove(_keyUserProfile),
      ]);
    } catch (_) {}
  }
}
