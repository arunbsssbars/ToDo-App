import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../data/services/storage_service.dart';

/// Exception thrown when API calls encounter client/server errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Centralized HTTP Network Client
/// Handles JSON headers, Bearer authorization token injection, and response parsing
class ApiClient {
  final http.Client _client;
  final StorageService _storageService;

  ApiClient({http.Client? client, required StorageService storageService})
      : _client = client ?? http.Client(),
        _storageService = storageService;

  // Build standard headers with optional Bearer JWT token
  Map<String, String> _buildHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Handle and parse HTTP response
  dynamic _processResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    String errorMessage = 'Request failed with status: ${response.statusCode}';
    if (body is Map<String, dynamic> && body['message'] != null) {
      errorMessage = body['message'].toString();
    }

    throw ApiException(errorMessage, response.statusCode);
  }

  // GET Request
  Future<dynamic> get(String url, {Map<String, String>? queryParams}) async {
    try {
      Uri uri = Uri.parse(url);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await _client.get(uri, headers: _buildHeaders());
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Cannot reach the server. Please check your backend connection.');
    } on http.ClientException {
      throw ApiException('Network client connection error.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  // POST Request
  Future<dynamic> post(String url, {Map<String, dynamic>? body}) async {
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _buildHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Cannot reach the server. Please check your backend connection.');
    } on http.ClientException {
      throw ApiException('Network client connection error.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  // PUT Request
  Future<dynamic> put(String url, {Map<String, dynamic>? body}) async {
    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: _buildHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Cannot reach the server. Please check your backend connection.');
    } on http.ClientException {
      throw ApiException('Network client connection error.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  // PATCH Request
  Future<dynamic> patch(String url, {Map<String, dynamic>? body}) async {
    try {
      final response = await _client.patch(
        Uri.parse(url),
        headers: _buildHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Cannot reach the server. Please check your backend connection.');
    } on http.ClientException {
      throw ApiException('Network client connection error.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  // DELETE Request
  Future<dynamic> delete(String url) async {
    try {
      final response = await _client.delete(
        Uri.parse(url),
        headers: _buildHeaders(),
      );
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Cannot reach the server. Please check your backend connection.');
    } on http.ClientException {
      throw ApiException('Network client connection error.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }
}
