import 'dart:io';
import 'package:flutter/foundation.dart';

/// Top-level function to determine default backend URL based on platform
String getDefaultBaseUrl() {
  if (kIsWeb) {
    final host = Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost';
    return 'http://$host:3000';
  } else if (Platform.isAndroid) {
    // Android Emulator host loopback address
    return 'http://10.0.2.2:3000';
  } else {
    // iOS Simulator, macOS, Windows, Linux
    return 'http://localhost:3000';
  }
}

// Current active base URL
String activeBaseUrl = getDefaultBaseUrl();

// Top-level endpoint builder functions
String getRegisterUrl() => '$activeBaseUrl/api/auth/register';
String getLoginUrl() => '$activeBaseUrl/api/auth/login';
String getMeUrl() => '$activeBaseUrl/api/auth/me';

String getTodosUrl() => '$activeBaseUrl/api/todos';
String getTodoByIdUrl(String id) => '$activeBaseUrl/api/todos/$id';
String getToggleTodoUrl(String id) => '$activeBaseUrl/api/todos/$id/toggle';
String getHealthUrl() => '$activeBaseUrl/api/health';

/// ApiEndpoints backward compatible wrapper
class ApiEndpoints {
  static String get defaultBaseUrl => getDefaultBaseUrl();
  static String get baseUrl => activeBaseUrl;
  static set baseUrl(String url) => activeBaseUrl = url;

  static String get register => getRegisterUrl();
  static String get login => getLoginUrl();
  static String get me => getMeUrl();
  static String get todos => getTodosUrl();
  static String todoById(String id) => getTodoByIdUrl(id);
  static String toggleTodo(String id) => getToggleTodoUrl(id);
  static String get health => getHealthUrl();
}
