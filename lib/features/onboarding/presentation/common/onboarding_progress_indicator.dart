import 'package:flutter/material.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// A reusable progress indicator for the onboarding flow
class OnboardingProgressIndicator extends StatelessWidget {
  /// Current step index (0-based)
  final int currentStep;
  
  /// Total number of steps
  final int totalSteps;
  
  /// Whether to show step numbers
  final bool showStepNumbers;
  
  /// Height of the progress indicator
  final double height;

  const OnboardingProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.showStepNumbers = false,
    this.height = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Column(
      children: [
        // Linear progress indicator
        LinearProgressIndicator(
          value: (currentStep + 1) / totalSteps,
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.primaryColor,
          ),
          minHeight: height,
        ),
        
        // Step numbers if enabled
        if (showStepNumbers)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Step ${currentStep + 1} of $totalSteps',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
      ],
    );
  }
}
