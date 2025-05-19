import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:immigru/core/services/logger_service.dart';

/// Service for theme persistence
///
/// This service is responsible for saving and loading theme preferences.
/// It only handles the persistence layer and doesn't contain any UI logic.
class ThemeService {
  static const String _themeKey = 'app_theme';
  
  /// Theme modes as strings for storage
  static const String light = 'light';
  static const String dark = 'dark';
  static const String system = 'system';
  
  final LoggerService _logger = LoggerService();
  
  /// Get the current theme mode from storage
  Future<String> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final theme = prefs.getString(_themeKey) ?? system;
      
      return theme;
    } catch (e) {

      return system;
    }
  }
  
  /// Save the theme mode to storage
  Future<bool> setThemeMode(String mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode);
      
      return true;
    } catch (e) {

      return false;
    }
  }
  
  /// Convert string theme mode to ThemeMode enum
  static ThemeMode getThemeModeEnum(String mode) {
    switch (mode) {
      case light:
        return ThemeMode.light;
      case dark:
        return ThemeMode.dark;
      case system:
      default:
        return ThemeMode.system;
    }
  }
  
  /// Convert ThemeMode enum to string
  static String getThemeModeString(ThemeMode mode) {
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
