import 'package:flutter/material.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Text styles for the application
class AppTextStyles {
  /// Heading styles
  static TextStyle heading1({required Brightness brightness}) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary(brightness),
    letterSpacing: -0.5,
  );

  static TextStyle heading2({required Brightness brightness}) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary(brightness),
    letterSpacing: -0.5,
  );

  static TextStyle heading3({required Brightness brightness}) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary(brightness),
    letterSpacing: -0.5,
  );

  static TextStyle heading4({required Brightness brightness}) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary(brightness),
  );

  /// Body text styles
  static TextStyle bodyLarge({required Brightness brightness}) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary(brightness),
  );

  static TextStyle bodyMedium({required Brightness brightness}) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary(brightness),
  );

  static TextStyle bodySmall({required Brightness brightness}) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary(brightness),
  );

  /// Button text styles
  static TextStyle buttonLarge({required Brightness brightness}) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle buttonMedium({required Brightness brightness}) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle buttonSmall({required Brightness brightness}) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  /// Caption and label styles
  static TextStyle caption({required Brightness brightness}) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary(brightness),
    letterSpacing: 0.4,
  );

  static TextStyle label({required Brightness brightness}) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary(brightness),
    letterSpacing: 0.1,
  );
}
