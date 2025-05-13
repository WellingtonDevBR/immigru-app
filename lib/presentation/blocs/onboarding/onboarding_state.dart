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
  profileLocation,
  profilePrivacy,
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

  /// Check if the current step is valid and can proceed to the next step
  bool get isCurrentStepValid {
    switch (currentStep) {
      case OnboardingStep.birthCountry:
        return data.birthCountry != null && data.birthCountry!.isNotEmpty;
      case OnboardingStep.currentStatus:
        return data.currentStatus != null && data.currentStatus!.isNotEmpty;
      case OnboardingStep.migrationJourney:
        // Migration journey can be skipped, so it's always valid
        return true;
      case OnboardingStep.profession:
        // Profession can be skipped, so it's always valid
        return true;
      case OnboardingStep.languages:
        // Languages can be skipped, but at least one is recommended
        return true;
      case OnboardingStep.interests:
        // Interests can be skipped, but at least one is recommended
        return true;
      case OnboardingStep.profileBasicInfo:
        // Profile basic info is optional but recommended
        return true;
      case OnboardingStep.profileDisplayName:
        // Display name is optional but recommended
        return true;
      case OnboardingStep.profileBio:
        // Bio is optional
        return true;
      case OnboardingStep.profileLocation:
        // Location is optional
        return true;
      // Photo step has been integrated into BasicInfoStep
      case OnboardingStep.profilePrivacy:
        // Privacy settings are pre-filled
        return true;
      case OnboardingStep.completed:
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
