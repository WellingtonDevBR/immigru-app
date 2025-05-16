import 'package:flutter/material.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:immigru/shared/theme/app_text_styles.dart';

/// App theme definitions
class AppTheme {
  /// Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryLight,
      onPrimary: Colors.white,
      secondary: AppColors.primaryLight.withAlpha(204), // 0.8 opacity (204/255)
      onSecondary: Colors.white,
      surface: AppColors.surfaceLight,
      // Using surface instead of background (deprecated)
      surfaceContainer: AppColors.backgroundLight,
      error: AppColors.errorLight,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
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
      displayLarge: AppTextStyles.heading1(brightness: Brightness.light),
      displayMedium: AppTextStyles.heading2(brightness: Brightness.light),
      displaySmall: AppTextStyles.heading3(brightness: Brightness.light),
      headlineMedium: AppTextStyles.heading4(brightness: Brightness.light),
      bodyLarge: AppTextStyles.bodyLarge(brightness: Brightness.light),
      bodyMedium: AppTextStyles.bodyMedium(brightness: Brightness.light),
      bodySmall: AppTextStyles.bodySmall(brightness: Brightness.light),
      labelLarge: AppTextStyles.buttonLarge(brightness: Brightness.light),
      labelMedium: AppTextStyles.buttonMedium(brightness: Brightness.light),
      labelSmall: AppTextStyles.buttonSmall(brightness: Brightness.light),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        side: BorderSide(color: AppColors.primaryLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.errorLight, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );

  /// Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryDark,
      onPrimary: Colors.white,
      secondary: AppColors.primaryDark.withAlpha(204), // 0.8 opacity (204/255)
      onSecondary: Colors.white,
      surface: AppColors.surfaceDark,
      // Using surface instead of background (deprecated)
      surfaceContainer: AppColors.backgroundDark,
      error: AppColors.errorDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
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
      displayLarge: AppTextStyles.heading1(brightness: Brightness.dark),
      displayMedium: AppTextStyles.heading2(brightness: Brightness.dark),
      displaySmall: AppTextStyles.heading3(brightness: Brightness.dark),
      headlineMedium: AppTextStyles.heading4(brightness: Brightness.dark),
      bodyLarge: AppTextStyles.bodyLarge(brightness: Brightness.dark),
      bodyMedium: AppTextStyles.bodyMedium(brightness: Brightness.dark),
      bodySmall: AppTextStyles.bodySmall(brightness: Brightness.dark),
      labelLarge: AppTextStyles.buttonLarge(brightness: Brightness.dark),
      labelMedium: AppTextStyles.buttonMedium(brightness: Brightness.dark),
      labelSmall: AppTextStyles.buttonSmall(brightness: Brightness.dark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
        side: BorderSide(color: AppColors.primaryDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primaryDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.errorDark, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}
