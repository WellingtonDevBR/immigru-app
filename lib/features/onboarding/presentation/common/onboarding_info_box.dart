import 'package:flutter/material.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// A reusable info box component for the onboarding process
///
/// This component provides a consistent styled container for displaying
/// informational content during onboarding steps.
class OnboardingInfoBox extends StatelessWidget {
  /// The icon to display in the info box
  final IconData? icon;
  
  /// The title text for the info box
  final String? title;
  
  /// The message text for the info box
  final String message;
  
  /// Optional widget to display instead of the message text
  final Widget? child;
  
  /// Optional border radius for the info box
  final BorderRadius? borderRadius;
  
  /// Optional padding for the info box
  final EdgeInsetsGeometry padding;
  
  /// Optional background color for the info box
  final Color? backgroundColor;
  
  /// Optional border color for the info box
  final Color? borderColor;
  
  /// Creates an instance of [OnboardingInfoBox]
  const OnboardingInfoBox({
    super.key,
    this.icon,
    this.title,
    this.message = '',
    this.child,
    this.borderRadius,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.borderColor,
  });
  
  /// Validates that either message or child is provided
  bool get debugAssertIsValid {
    assert(message.isNotEmpty || child != null, 'Either message or child must be provided');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Get the onboarding theme extension
    // We'll use this in future implementations
    
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryColor.withValues(alpha: 0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? AppColors.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null || title != null)
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(theme.brightness),
                      ),
                    ),
                  ),
              ],
            ),
          if (icon != null || title != null)
            const SizedBox(height: 8),
          child ?? Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary(theme.brightness),
            ),
          ),
        ],
      ),
    );
  }
}
