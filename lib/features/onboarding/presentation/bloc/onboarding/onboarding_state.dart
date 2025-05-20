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
  final bool preventAutoNavigation;
  
  // Birth country step data
  final String? birthCountryId;
  final String? birthCountryName;
  
  // Current status step data
  final String? currentStatus;
  
  // Migration journey step data
  final List<MigrationStep> migrationSteps;
  
  // Profession step data
  final String? profession;
  final String? industry;
  
  // Language step data
  final List<String> languages;
  
  // Interest step data
  final List<int> interests;
  
  // ImmiGrove step data
  final List<String> immiGroveIds;

  const OnboardingState({
    this.currentStepIndex = 0,
    this.totalSteps = 7, // Birth country, current status, migration journey, profession, language, interest, and ImmiGrove steps
    this.isLoading = false,
    this.errorMessage,
    this.canMoveToNextStep = false,
    this.isLastStep = false,
    this.preventAutoNavigation = false,
    this.birthCountryId,
    this.birthCountryName,
    this.currentStatus,
    this.migrationSteps = const [],
    this.profession,
    this.industry,
    this.languages = const [],
    this.interests = const [],
    this.immiGroveIds = const [],
  });

  /// Initial state for the onboarding flow
  factory OnboardingState.initial() {
    return const OnboardingState(
      currentStepIndex: 0,
      totalSteps: 7, // Birth country, current status, migration journey, profession, language, interest, and ImmiGrove steps
      isLoading: true,
      canMoveToNextStep: false,
      isLastStep: false,
      preventAutoNavigation: false,
      migrationSteps: [],
      languages: [],
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
    bool? preventAutoNavigation,
    String? birthCountryId,
    String? birthCountryName,
    String? currentStatus,
    List<MigrationStep>? migrationSteps,
    String? profession,
    String? industry,
    List<String>? languages,
    List<int>? interests,
    List<String>? immiGroveIds,
  }) {
    return OnboardingState(
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      totalSteps: totalSteps ?? this.totalSteps,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      canMoveToNextStep: canMoveToNextStep ?? this.canMoveToNextStep,
      isLastStep: isLastStep ?? this.isLastStep,
      preventAutoNavigation: preventAutoNavigation ?? this.preventAutoNavigation,
      birthCountryId: birthCountryId ?? this.birthCountryId,
      birthCountryName: birthCountryName ?? this.birthCountryName,
      currentStatus: currentStatus ?? this.currentStatus,
      migrationSteps: migrationSteps ?? this.migrationSteps,
      profession: profession ?? this.profession,
      industry: industry ?? this.industry,
      languages: languages ?? this.languages,
      interests: interests ?? this.interests,
      immiGroveIds: immiGroveIds ?? this.immiGroveIds,
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
    preventAutoNavigation,
    birthCountryId,
    birthCountryName,
    currentStatus,
    migrationSteps,
    profession,
    industry,
    languages,
    interests,
  ];
}
