import 'package:equatable/equatable.dart';
import 'package:immigru/domain/entities/onboarding_data.dart';

/// Enum representing different steps in the onboarding process
enum OnboardingStep {
  birthCountry,
  currentStatus,
  migrationJourney,
  profession,
  languages,
  interests,
  profileBasicInfo,
  profileDisplayName,
  profileBio,
  // profileLocation has been removed
  profilePrivacy,
  immiGroves,
  completed,
}

/// Base class for all onboarding states
class OnboardingState extends Equatable {
  final OnboardingData data;
  final OnboardingStep currentStep;
  final bool isLoading;
  final String? errorMessage;

  const OnboardingState({
    required this.data,
    required this.currentStep,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Initial state for onboarding
  factory OnboardingState.initial() => OnboardingState(
        data: OnboardingData.empty(),
        currentStep: OnboardingStep.birthCountry,
      );

  /// Create a copy of this state with the given fields replaced with new values
  OnboardingState copyWith({
    OnboardingData? data,
    OnboardingStep? currentStep,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OnboardingState(
      data: data ?? this.data,
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// Check if the current step is valid (has required data)
  bool get isCurrentStepValid {
    switch (currentStep) {
      case OnboardingStep.birthCountry:
        return data.birthCountry != null && data.birthCountry!.isNotEmpty;
      case OnboardingStep.currentStatus:
        return data.currentStatus != null && data.currentStatus!.isNotEmpty;
      case OnboardingStep.migrationJourney:
        // Migration journey is optional, so always valid
        return true;
      case OnboardingStep.profession:
        // Profession is optional, so always valid
        return true;
      case OnboardingStep.languages:
        // At least one language is required
        return data.languages.isNotEmpty;
      case OnboardingStep.interests:
        // At least one interest is required
        return data.interests.isNotEmpty;
      case OnboardingStep.profileBasicInfo:
        // Full name is required, photo is optional
        return data.fullName != null && data.fullName!.isNotEmpty;
      case OnboardingStep.profileDisplayName:
        // Display name is required
        return data.displayName != null && data.displayName!.isNotEmpty;
      case OnboardingStep.profileBio:
        // Bio is optional, so always valid
        return true;
      // profileLocation step has been removed
      case OnboardingStep.profilePrivacy:
        // Privacy setting is always valid (default is private)
        return true;
      case OnboardingStep.immiGroves:
        // ImmiGroves selection is optional, so always valid
        return true;
      case OnboardingStep.completed:
        // Completed step is always valid
        return true;
    }
  }

  /// Get the progress percentage (0.0 to 1.0) based on the current step
  double get progressPercentage {
    final totalSteps = OnboardingStep.values.length - 1; // Exclude 'completed'
    final currentStepIndex = OnboardingStep.values.indexOf(currentStep);
    return currentStepIndex / totalSteps;
  }

  @override
  List<Object?> get props => [
        data,
        currentStep,
        isLoading,
        errorMessage,
      ];
}
