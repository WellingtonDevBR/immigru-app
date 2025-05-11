import 'package:flutter/material.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// A custom progress indicator for the onboarding flow
class OnboardingProgressIndicator extends StatelessWidget {
  final double progress;

  const OnboardingProgressIndicator({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress text
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Your Progress',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
        
        // Progress bar
        Stack(
          children: [
            // Background track
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            
            // Progress fill
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 8,
              width: MediaQuery.of(context).size.width * progress,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
