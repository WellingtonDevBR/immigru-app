import 'package:flutter/material.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Theme extension for onboarding-specific styling
///
/// This class provides styling utilities for the onboarding process.
/// It can be used directly via static methods or as a ThemeExtension.
class OnboardingTheme extends ThemeExtension<OnboardingTheme> {
  /// Get a gradient container decoration for headers
  static BoxDecoration headerGradientDecoration({
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.primaryColor,
          AppColors.primaryColor.withValues(alpha: 0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: borderRadius ?? BorderRadius.circular(16),
    );
  }

  /// Get a container decoration for info boxes
  static BoxDecoration infoBoxDecoration(Brightness brightness, {
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: AppColors.primaryColor.withValues(alpha: 0.1),
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.primaryColor.withValues(alpha: 0.3),
      ),
    );
  }

  /// Get a card decoration based on selection state and theme brightness
  static BoxDecoration cardDecoration({
    required bool isSelected,
    required Brightness brightness,
    BorderRadius? borderRadius,
    Color? selectedColor,
  }) {
    final isDarkMode = brightness == Brightness.dark;
    
    return BoxDecoration(
      color: isSelected
          ? (selectedColor ?? AppColors.primaryColor).withValues(alpha: 0.15)
          : isDarkMode
              ? AppColors.cardDark
              : Colors.white,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: (selectedColor ?? AppColors.primaryColor)
                    .withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
      border: isSelected
          ? Border.all(
              color: selectedColor ?? AppColors.primaryColor, width: 2)
          : Border.all(
              color: isDarkMode
                  ? AppColors.borderDark
                  : AppColors.borderLight,
              width: 1,
            ),
    );
  }

  // Instance properties for ThemeExtension
  final Color primaryColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color borderColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final BorderRadius defaultBorderRadius;
  
  /// Creates an instance of OnboardingTheme
  const OnboardingTheme({
    required this.primaryColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    this.defaultBorderRadius = const BorderRadius.all(Radius.circular(16)),
  });
  
  /// Creates a light theme version
  factory OnboardingTheme.light() {
    return OnboardingTheme(
      primaryColor: AppColors.primaryLight,
      backgroundColor: AppColors.backgroundLight,
      cardColor: AppColors.cardLight,
      borderColor: AppColors.borderLight,
      textPrimaryColor: AppColors.textPrimaryLight,
      textSecondaryColor: AppColors.textSecondaryLight,
    );
  }
  
  /// Creates a dark theme version
  factory OnboardingTheme.dark() {
    return OnboardingTheme(
      primaryColor: AppColors.primaryDark,
      backgroundColor: AppColors.backgroundDark,
      cardColor: AppColors.cardDark,
      borderColor: AppColors.borderDark,
      textPrimaryColor: AppColors.textPrimaryDark,
      textSecondaryColor: AppColors.textSecondaryDark,
    );
  }
  
  /// Get the theme extension from the current theme
  static OnboardingTheme of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<OnboardingTheme>() ?? 
      (theme.brightness == Brightness.dark ? OnboardingTheme.dark() : OnboardingTheme.light());
  }
  
  @override
  ThemeExtension<OnboardingTheme> copyWith({
    Color? primaryColor,
    Color? backgroundColor,
    Color? cardColor,
    Color? borderColor,
    Color? textPrimaryColor,
    Color? textSecondaryColor,
    BorderRadius? defaultBorderRadius,
  }) {
    return OnboardingTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cardColor: cardColor ?? this.cardColor,
      borderColor: borderColor ?? this.borderColor,
      textPrimaryColor: textPrimaryColor ?? this.textPrimaryColor,
      textSecondaryColor: textSecondaryColor ?? this.textSecondaryColor,
      defaultBorderRadius: defaultBorderRadius ?? this.defaultBorderRadius,
    );
  }
  
  @override
  ThemeExtension<OnboardingTheme> lerp(ThemeExtension<OnboardingTheme>? other, double t) {
    if (other is! OnboardingTheme) {
      return this;
    }
    
    return OnboardingTheme(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      textPrimaryColor: Color.lerp(textPrimaryColor, other.textPrimaryColor, t)!,
      textSecondaryColor: Color.lerp(textSecondaryColor, other.textSecondaryColor, t)!,
      defaultBorderRadius: BorderRadius.lerp(defaultBorderRadius, other.defaultBorderRadius, t)!,
    );
  }
  
  /// Get a container decoration for icon containers
  static BoxDecoration iconContainerDecoration({
    required bool isSelected,
    required Brightness brightness,
    BorderRadius? borderRadius,
  }) {
    final isDarkMode = brightness == Brightness.dark;
    
    return BoxDecoration(
      color: isSelected
          ? AppColors.primaryColor.withValues(alpha: 0.2)
          : isDarkMode
              ? AppColors.surfaceDark
              : AppColors.surfaceLight,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        )
      ],
    );
  }

  /// Get a color for icons based on selection state and theme brightness
  static Color iconColor({
    required bool isSelected,
    required Brightness brightness,
  }) {
    final isDarkMode = brightness == Brightness.dark;
    
    return isSelected
        ? AppColors.primaryColor
        : isDarkMode
            ? Colors.white70
            : Colors.black54;
  }

  /// Get a search bar decoration based on theme brightness
  static BoxDecoration searchBarDecoration({
    required Brightness brightness,
    required bool isActive,
    BorderRadius? borderRadius,
  }) {
    final isDarkMode = brightness == Brightness.dark;
    
    return BoxDecoration(
      color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      border: Border.all(
        color: isActive
            ? AppColors.primaryColor
            : Colors.transparent,
        width: isActive ? 2 : 1,
      ),
    );
  }
}
