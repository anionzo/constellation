import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
/// Cross-platform persistent token storage service for Quire.
/// Automatically maps to:
/// - Web: `window.localStorage`
/// - Android: `EncryptedSharedPreferences / SharedPreferences`
/// - iOS/macOS: `NSUserDefaults`
/// - Windows/Linux: AppData secure storage configuration
class TokenStorageService {
  static const String _keyAccessToken = 'quire_access_token';
  static const String _keyRefreshToken = 'quire_refresh_token';
  static const String _keyUserEmail = 'quire_user_email';
  static const String _keyUserId = 'quire_user_id';
  static const String _keyUserName = 'quire_user_name';

  static TokenStorageService? _instance;
  static SharedPreferences? _prefs;

  TokenStorageService._();

  static Future<TokenStorageService> getInstance() async {
    _instance ??= TokenStorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  /// Save authenticated session tokens and user information
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userEmail,
    String? userId,
    String? userName,
  }) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_keyAccessToken, accessToken),
      // On Web, Refresh Token is stored strictly in HttpOnly Secure Cookie (NEVER in localStorage to prevent XSS)
      if (!kIsWeb && refreshToken.isNotEmpty) prefs.setString(_keyRefreshToken, refreshToken),
      prefs.setString(_keyUserEmail, userEmail),
      if (userId != null) prefs.setString(_keyUserId, userId),
      if (userName != null) prefs.setString(_keyUserName, userName),
    ]);
  }

  /// Retrieve current stored access token
  String? getAccessToken() {
    return _prefs?.getString(_keyAccessToken);
  }

  /// Retrieve current stored refresh token
  String? getRefreshToken() {
    return _prefs?.getString(_keyRefreshToken);
  }

  /// Retrieve stored user email
  String? getUserEmail() {
    return _prefs?.getString(_keyUserEmail);
  }

  /// Retrieve stored user ID
  String? getUserId() {
    return _prefs?.getString(_keyUserId);
  }

  /// Retrieve stored display name
  String? getUserName() {
    return _prefs?.getString(_keyUserName);
  }

  /// Check whether an authenticated session exists
  bool hasSession() {
    final token = getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all stored authentication tokens and session data (Logout)
  Future<void> clearSession() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_keyAccessToken),
      prefs.remove(_keyRefreshToken),
      prefs.remove(_keyUserEmail),
      prefs.remove(_keyUserId),
      prefs.remove(_keyUserName),
    ]);
  }
}
