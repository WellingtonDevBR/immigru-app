import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme provider that manages theme state and persistence
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  
  /// Theme modes as strings for storage
  static const String light = 'light';
  static const String dark = 'dark';
  static const String system = 'system';
  
  // Initialize with a default value
  ThemeMode _themeMode = ThemeMode.system;
  
  /// Constructor that loads the theme
  ThemeProvider() {
    _loadTheme();
  }
  
  /// Get the current theme mode
  ThemeMode get themeMode => _themeMode;
  
  /// Check if dark mode is active
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  /// Load theme from persistent storage
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString(_themeKey) ?? system;
      _themeMode = _getThemeModeEnum(themeString);
      
      notifyListeners();
    } catch (e) {
      // Already initialized with ThemeMode.system as default
      debugPrint('Error loading theme: $e');
    }
  }
  
  /// Set the theme mode and persist it
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    try {
      final themeString = _getThemeModeString(mode);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeString);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
  
  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
  
  /// Convert string theme mode to ThemeMode enum
  ThemeMode _getThemeModeEnum(String mode) {
    switch (mode) {
      case light:
        return ThemeMode.light;
      case dark:
        return ThemeMode.dark;
      default: // This covers system and any unexpected values
        return ThemeMode.system;
    }
  }
  
  /// Convert ThemeMode enum to string
  String _getThemeModeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return light;
      case ThemeMode.dark:
        return dark;
      case ThemeMode.system:
        return system;
    }
  }
}
