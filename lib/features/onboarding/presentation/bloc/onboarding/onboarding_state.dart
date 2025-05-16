import 'package:equatable/equatable.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';

/// State for the onboarding flow
class OnboardingState extends Equatable {
  final int currentStepIndex;
  final int totalSteps;
  final bool isLoading;
  final String? errorMessage;
  final bool canMoveToNextStep;
  final bool isLastStep;
  
  // Birth country step data
  final String? birthCountryId;
  final String? birthCountryName;
  
  // Current status step data
  final String? currentStatus;
  
  // Migration journey step data
  final List<MigrationStep> migrationSteps;

  const OnboardingState({
    this.currentStepIndex = 0,
    this.totalSteps = 3, // Birth country, current status, and migration journey steps
    this.isLoading = false,
    this.errorMessage,
    this.canMoveToNextStep = false,
    this.isLastStep = false,
    this.birthCountryId,
    this.birthCountryName,
    this.currentStatus,
    this.migrationSteps = const [],
  });

  /// Initial state for the onboarding flow
  factory OnboardingState.initial() {
    return const OnboardingState(
      currentStepIndex: 0,
      totalSteps: 3, // Birth country, current status, and migration journey steps
      isLoading: true,
      canMoveToNextStep: false,
      isLastStep: false,
      migrationSteps: [],
    );
  }

  /// Create a copy of this state with updated properties
  OnboardingState copyWith({
    int? currentStepIndex,
    int? totalSteps,
    bool? isLoading,
    String? errorMessage,
    bool? canMoveToNextStep,
    bool? isLastStep,
    String? birthCountryId,
    String? birthCountryName,
    String? currentStatus,
    List<MigrationStep>? migrationSteps,
  }) {
    return OnboardingState(
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      totalSteps: totalSteps ?? this.totalSteps,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      canMoveToNextStep: canMoveToNextStep ?? this.canMoveToNextStep,
      isLastStep: isLastStep ?? this.isLastStep,
      birthCountryId: birthCountryId ?? this.birthCountryId,
      birthCountryName: birthCountryName ?? this.birthCountryName,
      currentStatus: currentStatus ?? this.currentStatus,
      migrationSteps: migrationSteps ?? this.migrationSteps,
    );
  }

  @override
  List<Object?> get props => [
        currentStepIndex,
        totalSteps,
        isLoading,
        errorMessage,
        canMoveToNextStep,
        isLastStep,
        birthCountryId,
        birthCountryName,
        currentStatus,
        migrationSteps,
      ];
}
