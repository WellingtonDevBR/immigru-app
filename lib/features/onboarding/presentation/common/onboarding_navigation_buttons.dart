import 'package:flutter/material.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// A reusable navigation buttons component for onboarding steps
class OnboardingNavigationButtons extends StatelessWidget {
  /// Callback for the next button
  final VoidCallback? onNext;
  
  /// Callback for the back button
  final VoidCallback? onBack;
  
  /// Callback for the skip button
  final VoidCallback? onSkip;
  
  /// Whether the next button is enabled
  final bool canMoveNext;
  
  /// Whether to show the back button
  final bool showBackButton;
  
  /// Whether to show the skip button
  final bool showSkipButton;
  
  /// Text for the next button
  final String nextButtonText;
  
  /// Text for the back button
  final String backButtonText;
  
  /// Text for the skip button
  final String skipButtonText;

  const OnboardingNavigationButtons({
    super.key,
    this.onNext,
    this.onBack,
    this.onSkip,
    this.canMoveNext = true,
    this.showBackButton = true,
    this.showSkipButton = false,
    this.nextButtonText = 'Next',
    this.backButtonText = 'Back',
    this.skipButtonText = 'Skip',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Skip button (if enabled)
          if (showSkipButton)
            TextButton(
              onPressed: onSkip,
              child: Text(skipButtonText),
            ),
            
          // Spacer to push buttons to edges
          if (showSkipButton) const Spacer(),
          
          // Back button (if enabled)
          if (showBackButton)
            Expanded(
              flex: 2, // Smaller flex for back button
              child: ElevatedButton(
                onPressed: onBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(backButtonText),
              ),
            ),
            
          // Spacing between buttons
          if (showBackButton) const SizedBox(width: 16),
          
          // Next button
          Expanded(
            flex: 3, // Larger flex for next button
            child: ElevatedButton(
              onPressed: canMoveNext ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(nextButtonText),
            ),
          ),
        ],
      ),
    );
  }
}
