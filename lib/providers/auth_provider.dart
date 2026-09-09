import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

enum AuthStatus { initial, authenticating, authenticated, unauthenticated, error }

/// AuthProvider acts as the Authentication ViewModel / Controller.
/// Manages user authentication lifecycle, loading states, and error messages.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthProvider({required AuthRepository authRepository})
      : _authRepository = authRepository {
    _initAuth();
  }

  // Getters
  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _currentUser != null;
  bool get isLoading => _status == AuthStatus.authenticating;

  // Initialize and check persistent session
  Future<void> _initAuth() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      final user = await _authRepository.autoLogin();
      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
      } else {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  // Register action
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.register(
        name: name,
        email: email,
        password: password,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Login action
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.login(
        email: email,
        password: password,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Logout action
  Future<void> logout() async {
    await _authRepository.logout();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  // Clear current error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
