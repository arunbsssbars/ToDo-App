import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

/// Repository for managing user authentication state, local tokens, and profile data
class AuthRepository {
  final AuthService _authService;
  final StorageService _storageService;

  AuthRepository({
    required AuthService authService,
    required StorageService storageService,
  })  : _authService = authService,
        _storageService = storageService;

  // Check if token exists in storage
  bool get isAuthenticated => _storageService.getToken() != null;

  // Get cached user from storage
  UserModel? get cachedUser => _storageService.getUser();

  // Get stored token
  String? get token => _storageService.getToken();

  // Register user and persist token + profile
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
    );

    // Save token and user locally
    await _storageService.saveToken(result.token);
    await _storageService.saveUser(result.user);

    return result.user;
  }

  // Login user and persist token + profile
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final result = await _authService.login(
      email: email,
      password: password,
    );

    // Save token and user locally
    await _storageService.saveToken(result.token);
    await _storageService.saveUser(result.user);

    return result.user;
  }

  // Auto-login: verifies token by fetching current profile from server
  Future<UserModel?> autoLogin() async {
    final storedToken = _storageService.getToken();
    if (storedToken == null) return null;

    try {
      final user = await _authService.getCurrentUser();
      await _storageService.saveUser(user);
      return user;
    } catch (_) {
      // If token is expired or server returned error, clear stored data
      await _storageService.clearAuthData();
      return null;
    }
  }

  // Logout: clear all tokens and stored credentials
  Future<void> logout() async {
    await _storageService.clearAuthData();
  }
}
