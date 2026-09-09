import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../models/user_model.dart';

/// Response wrapper for Auth API operations
class AuthResult {
  final UserModel user;
  final String token;

  AuthResult({required this.user, required this.token});
}

/// Service handling raw authentication API requests
class AuthService {
  final ApiClient _apiClient;

  AuthService({required ApiClient apiClient}) : _apiClient = apiClient;

  // POST /api/auth/register
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      getRegisterUrl(),
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    final data = response['data'] as Map<String, dynamic>;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    final token = data['token'] as String;

    return AuthResult(user: user, token: token);
  }

  // POST /api/auth/login
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      getLoginUrl(),
      body: {
        'email': email,
        'password': password,
      },
    );

    final data = response['data'] as Map<String, dynamic>;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    final token = data['token'] as String;

    return AuthResult(user: user, token: token);
  }

  // GET /api/auth/me
  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get(getMeUrl());
    final data = response['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }
}
