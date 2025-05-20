import 'package:flutter/material.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_state.dart';
import 'package:immigru/new_core/logging/logger_interface.dart';

/// A manager class for handling onboarding step transitions
///
/// This class encapsulates the logic for navigating between steps,
/// handling step completion, and managing the PageController.
class OnboardingStepManager {
  /// Page controller for the onboarding steps
  final PageController pageController;
  
  /// Onboarding bloc for state management
  final OnboardingBloc onboardingBloc;
  
  /// Logger for debugging
  final LoggerInterface logger;

  /// Constructor
  const OnboardingStepManager({
    required this.pageController,
    required this.onboardingBloc,
    required this.logger,
  });

  /// Navigate to the next step
  void goToNextStep() {
    logger.i('Navigating to next step', tag: 'OnboardingStepManager');
    onboardingBloc.add(const NextStepRequested());
  }

  /// Navigate to the previous step
  void goToPreviousStep() {
    logger.i('Navigating to previous step', tag: 'OnboardingStepManager');
    onboardingBloc.add(const PreviousStepRequested());
  }

  /// Skip the current step
  void skipStep() {
    logger.i('Skipping current step', tag: 'OnboardingStepManager');
    onboardingBloc.add(const StepSkipped());
  }

  /// Mark the onboarding as completed
  void completeOnboarding() {
    logger.i('Completing onboarding', tag: 'OnboardingStepManager');
    onboardingBloc.add(const OnboardingCompleted());
  }

  /// Save the current onboarding progress
  void saveProgress() {
    logger.i('Saving onboarding progress', tag: 'OnboardingStepManager');
    onboardingBloc.add(const OnboardingSaved());
  }
  
  /// Animate to a specific step
  void animateToStep(int stepIndex) {
    if (pageController.hasClients) {
      logger.i('Animating to step $stepIndex', tag: 'OnboardingStepManager');
      pageController.animateToPage(
        stepIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  /// Check if we can navigate to the next step based on current state
  bool canNavigateToNextStep(OnboardingState state) {
    return state.canMoveToNextStep && !state.isLastStep;
  }
  
  /// Check if we can navigate to the previous step based on current state
  bool canNavigateToPreviousStep(OnboardingState state) {
    return state.currentStepIndex > 0;
  }
}
