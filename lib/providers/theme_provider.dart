import 'package:flutter/material.dart';
import '../data/services/storage_service.dart';

/// ThemeProvider for toggling between Light and Dark mode with persistence
class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider({required StorageService storageService})
      : _storageService = storageService {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void _loadTheme() {
    final isDark = _storageService.getThemeMode();
    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _storageService.saveThemeMode(isDarkMode);
    notifyListeners();
  }
}
