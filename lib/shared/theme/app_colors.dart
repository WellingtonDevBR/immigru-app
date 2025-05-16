import 'package:flutter/material.dart';

/// App color palette
class AppColors {
  // Base primary color (used across themes)
  static const Color primaryColor = Color(0xFF2EAA76); // Unified green
  static const Color darkBackground = Color(0xFF121212); // darkBackground
  static const Color darkSurface = Color(0xFF1E1E1E); // darkSurface

  // Light Theme
  static const Color backgroundLight = Colors.white;
  static const Color surfaceLight = Color(0xFFF5F5F5);
  static const Color cardLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color iconLight = Color(0xFF616161);
  static const Color errorLight = Color(0xFFD32F2F);
  static const Color primaryLight = Color(0xFF2EAA76);

  // Dark Theme
  static const Color backgroundDark = Color(0xFF121212); // Same as darkBackground
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF242424);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);
  static const Color borderDark = Color(0xFF424242);
  static const Color iconDark = Color(0xFFBDBDBD);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color primaryDark = Color(0xFF2EAA76);

  // Helpers for dynamic access
  static Color background(Brightness brightness) =>
      brightness == Brightness.dark ? backgroundDark : backgroundLight;

  static Color surface(Brightness brightness) =>
      brightness == Brightness.dark ? surfaceDark : surfaceLight;

  static Color card(Brightness brightness) =>
      brightness == Brightness.dark ? cardDark : cardLight;

  static Color textPrimary(Brightness brightness) =>
      brightness == Brightness.dark ? textPrimaryDark : textPrimaryLight;

  static Color textSecondary(Brightness brightness) =>
      brightness == Brightness.dark ? textSecondaryDark : textSecondaryLight;

  static Color border(Brightness brightness) =>
      brightness == Brightness.dark ? borderDark : borderLight;

  static Color icon(Brightness brightness) =>
      brightness == Brightness.dark ? iconDark : iconLight;

  static Color error(Brightness brightness) =>
      brightness == Brightness.dark ? errorDark : errorLight;
}
