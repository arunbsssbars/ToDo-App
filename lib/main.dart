import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/api_endpoints.dart';
import 'core/constants/app_colors.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/todo_repository.dart';
import 'data/services/auth_service.dart';
import 'data/services/storage_service.dart';
import 'data/services/todo_service.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/todo_provider.dart';
import 'ui/views/auth/login_screen.dart';
import 'ui/views/todos/todo_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize persistent storage
  final storageService = await StorageService.init();

  // 2. Restore custom backend URL if saved previously
  final savedUrl = storageService.getBaseUrl();
  if (savedUrl != null && savedUrl.isNotEmpty) {
    activeBaseUrl = savedUrl;
  }

  // 3. Initialize HTTP Network Client
  final apiClient = ApiClient(storageService: storageService);

  // 4. Initialize Data Services
  final authService = AuthService(apiClient: apiClient);
  final todoService = TodoService(apiClient: apiClient);

  // 5. Initialize Repositories (Single source of truth)
  final authRepository = AuthRepository(
    authService: authService,
    storageService: storageService,
  );
  final todoRepository = TodoRepository(todoService: todoService);

  runApp(
    MultiProvider(
      providers: [
        // Storage & Services
        Provider<StorageService>.value(value: storageService),
        // Providers / ViewModels
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(storageService: storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => TodoProvider(todoRepository: todoRepository),
        ),
      ],
      child: const TodoApp(),
    ),
  );
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'TaskFlow - Modern Full Stack Todo',
      debugShowCheckedModeBanner: false,
      theme: getLightTheme(),
      darkTheme: getDarkTheme(),
      themeMode: themeProvider.themeMode,
      home: const AuthGatekeeper(),
    );
  }
}

/// Dynamic Gatekeeper widget that routes to Login or Home based on Auth status
class AuthGatekeeper extends StatelessWidget {
  const AuthGatekeeper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    switch (authProvider.status) {
      case AuthStatus.authenticating:
      case AuthStatus.initial:
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'Loading TaskFlow...',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      case AuthStatus.authenticated:
        return const TodoHomeScreen();
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
      default:
        return const LoginScreen();
    }
  }
}
