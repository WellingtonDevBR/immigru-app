import 'package:flutter/material.dart';
import 'package:immigru/features/onboarding/presentation/common/onboarding_theme.dart';

/// A reusable gradient header component for onboarding steps
class OnboardingGradientHeader extends StatelessWidget {
  /// The title text to display
  final String title;
  
  /// The subtitle text to display
  final String subtitle;
  
  /// The icon to display
  final IconData icon;
  
  /// Optional padding for the container
  final EdgeInsetsGeometry padding;
  
  /// Optional margin for the container
  final EdgeInsetsGeometry margin;

  /// Creates a new OnboardingGradientHeader
  const OnboardingGradientHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.padding = const EdgeInsets.all(20),
    this.margin = const EdgeInsets.symmetric(horizontal: 16.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: margin,
      decoration: OnboardingTheme.headerGradientDecoration(),
      padding: padding,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
