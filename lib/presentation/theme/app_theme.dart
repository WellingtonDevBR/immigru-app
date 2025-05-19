import 'package:flutter/material.dart';
import 'package:immigru/core/services/theme_service.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Theme provider that manages theme state and persistence
class AppThemeProvider extends ChangeNotifier {
  final ThemeService _themeService = ThemeService();
  // Initialize with a default value to avoid LateInitializationError
  ThemeMode _themeMode = ThemeMode.system;

  AppThemeProvider() {
    _loadTheme();
  }

  /// Get the current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Check if dark mode is active
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Load theme from persistent storage
  Future<void> _loadTheme() async {
    try {
      final themeString = await _themeService.getThemeMode();
      _themeMode = ThemeService.getThemeModeEnum(themeString);

      notifyListeners();
    } catch (e) {
      // Already initialized with ThemeMode.system as default
    }
  }

  /// Set the theme mode and persist it
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final themeString = ThemeService.getThemeModeString(mode);
    final success = await _themeService.setThemeMode(themeString);

    if (!success) {}
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}

/// App theme definitions
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryLight,
      onPrimary: Colors.white,
      secondary: AppColors.primaryLight.withValues(alpha: 0.8),
      onSecondary: Colors.white,
      surface: AppColors.surfaceLight,
      surfaceContainerHighest: AppColors.surfaceLight,
      error: AppColors.errorLight,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.textPrimaryLight,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: AppColors.cardLight,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.borderLight, width: 0.5),
      ),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: AppColors.primaryLight,
      unselectedLabelColor: AppColors.textSecondaryLight,
      indicatorColor: AppColors.primaryLight,
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.borderLight,
      thickness: 0.5,
      space: 1.0,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: AppColors.textPrimaryLight),
      displayMedium: TextStyle(color: AppColors.textPrimaryLight),
      displaySmall: TextStyle(color: AppColors.textPrimaryLight),
      headlineLarge: TextStyle(color: AppColors.textPrimaryLight),
      headlineMedium: TextStyle(color: AppColors.textPrimaryLight),
      headlineSmall: TextStyle(color: AppColors.textPrimaryLight),
      titleLarge: TextStyle(color: AppColors.textPrimaryLight),
      titleMedium: TextStyle(color: AppColors.textPrimaryLight),
      titleSmall: TextStyle(color: AppColors.textPrimaryLight),
      bodyLarge: TextStyle(color: AppColors.textPrimaryLight),
      bodyMedium: TextStyle(color: AppColors.textPrimaryLight),
      bodySmall: TextStyle(color: AppColors.textSecondaryLight),
      labelLarge: TextStyle(color: AppColors.textPrimaryLight),
      labelMedium: TextStyle(color: AppColors.textPrimaryLight),
      labelSmall: TextStyle(color: AppColors.textSecondaryLight),
    ),
    iconTheme: IconThemeData(
      color: AppColors.iconLight,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryDark,
      onPrimary: Colors.white,
      secondary: AppColors.primaryDark.withValues(alpha: 0.8),
      onSecondary: Colors.white,
      surface: AppColors.surfaceDark,
      surfaceContainerHighest: AppColors.backgroundDark,
      error: AppColors.errorDark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.textPrimaryDark,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: AppColors.cardDark,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.borderDark, width: 0.5),
      ),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: AppColors.primaryDark,
      unselectedLabelColor: AppColors.textSecondaryDark,
      indicatorColor: AppColors.primaryDark,
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.borderDark,
      thickness: 0.5,
      space: 1.0,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: AppColors.textPrimaryDark),
      displayMedium: TextStyle(color: AppColors.textPrimaryDark),
      displaySmall: TextStyle(color: AppColors.textPrimaryDark),
      headlineLarge: TextStyle(color: AppColors.textPrimaryDark),
      headlineMedium: TextStyle(color: AppColors.textPrimaryDark),
      headlineSmall: TextStyle(color: AppColors.textPrimaryDark),
      titleLarge: TextStyle(color: AppColors.textPrimaryDark),
      titleMedium: TextStyle(color: AppColors.textPrimaryDark),
      titleSmall: TextStyle(color: AppColors.textPrimaryDark),
      bodyLarge: TextStyle(color: AppColors.textPrimaryDark),
      bodyMedium: TextStyle(color: AppColors.textPrimaryDark),
      bodySmall: TextStyle(color: AppColors.textSecondaryDark),
      labelLarge: TextStyle(color: AppColors.textPrimaryDark),
      labelMedium: TextStyle(color: AppColors.textPrimaryDark),
      labelSmall: TextStyle(color: AppColors.textSecondaryDark),
    ),
    iconTheme: IconThemeData(
      color: AppColors.iconDark,
    ),
  );
}
