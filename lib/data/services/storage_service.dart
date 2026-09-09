import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Local persistent storage service using SharedPreferences
class StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';
  static const String _keyThemeMode = 'app_theme_mode';
  static const String _keyBaseUrl = 'custom_base_url';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Auth Token Management ---
  Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  Future<void> removeToken() async {
    await _prefs.remove(_keyToken);
  }

  // --- User Profile Management ---
  Future<void> saveUser(UserModel user) async {
    final jsonStr = jsonEncode(user.toJson());
    await _prefs.setString(_keyUser, jsonStr);
  }

  UserModel? getUser() {
    final jsonStr = _prefs.getString(_keyUser);
    if (jsonStr == null) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> removeUser() async {
    await _prefs.remove(_keyUser);
  }

  // Clear all auth data on logout
  Future<void> clearAuthData() async {
    await removeToken();
    await removeUser();
  }

  // --- Theme Preference ---
  Future<void> saveThemeMode(bool isDarkMode) async {
    await _prefs.setBool(_keyThemeMode, isDarkMode);
  }

  bool? getThemeMode() {
    return _prefs.getBool(_keyThemeMode);
  }

  // --- Custom Base URL ---
  Future<void> saveBaseUrl(String url) async {
    await _prefs.setString(_keyBaseUrl, url);
  }

  String? getBaseUrl() {
    return _prefs.getString(_keyBaseUrl);
  }
}
