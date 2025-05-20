import 'package:flutter/material.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// A reusable header component for onboarding steps
class OnboardingStepHeader extends StatelessWidget {
  /// The main title of the step
  final String title;
  
  /// Optional subtitle or description
  final String? subtitle;
  
  /// Optional icon to display
  final IconData? icon;
  
  /// Whether to show a divider below the header
  final bool showDivider;

  const OnboardingStepHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon if provided
        if (icon != null) ...[
          Icon(
            icon,
            size: 32,
            color: AppColors.primaryColor,
          ),
          const SizedBox(height: 16),
        ],
        
        // Title
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        // Subtitle if provided
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
        
        // Optional divider
        if (showDivider) ...[
          const SizedBox(height: 16),
          Divider(
            color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
            thickness: 1,
          ),
          const SizedBox(height: 16),
        ] else
          const SizedBox(height: 24),
      ],
    );
  }
}
