import 'package:flutter/material.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_state.dart';
import 'package:immigru/features/onboarding/presentation/common/onboarding_step_manager.dart';
import 'package:immigru/features/onboarding/presentation/steps/interest/interest_step.dart';
import 'package:immigru/features/onboarding/presentation/steps/language/language_step.dart';
import 'package:immigru/features/onboarding/presentation/steps/profession/profession_step.dart';
import 'package:immigru/features/onboarding/presentation/widgets/birth_country/birth_country_step_widget.dart';
import 'package:immigru/features/onboarding/presentation/widgets/current_status/current_status_step_widget.dart';
import 'package:immigru/features/onboarding/presentation/widgets/migration_journey/migration_journey_step_widget.dart';
import 'package:immigru/new_core/country/domain/entities/country.dart';

/// Factory class for creating onboarding step widgets
///
/// This class centralizes the creation of step widgets based on the current step index,
/// making it easier to add, remove, or reorder steps in the future.
class OnboardingStepFactory {
  /// Create a step widget based on the current step index
  static Widget createStepWidget({
    required int stepIndex,
    required OnboardingState state,
    required OnboardingStepManager stepManager,
  }) {
    switch (stepIndex) {
      case 0:
        // Birth country step
        return BirthCountryStepWidget(
          selectedCountryId: state.birthCountryId,
          onCountrySelected: (Country country) {
            // This will be updated to use the step manager in Phase 2
            stepManager.onboardingBloc.add(BirthCountryUpdated(country));

            // Add a small delay to ensure the save completes before moving to next step
            Future.delayed(const Duration(milliseconds: 1000), () {
              stepManager.goToNextStep();
            });
          },
        );

      case 1:
        // Current status step
        return CurrentStatusStepWidget(
          selectedStatusId: state.currentStatus,
          onStatusSelected: (String statusId) {
            // This will be updated to use the step manager in Phase 2
            stepManager.onboardingBloc.add(CurrentStatusUpdated(statusId));
            stepManager.saveProgress();

            // Add a small delay to ensure the save completes before moving to next step
            Future.delayed(const Duration(milliseconds: 2000), () {
              stepManager.goToNextStep();
            });
          },
        );

      case 2:
        // Migration journey step
        return MigrationJourneyStepWidget(
          birthCountryId: state.birthCountryId ?? '',
          birthCountryName: state.birthCountryName ?? '',
          onMigrationJourneyCompleted: (List<MigrationStep> steps) {
            // This will be updated to use the step manager in Phase 2
            stepManager.onboardingBloc.add(MigrationJourneyUpdated(steps));

            // Add a small delay to ensure the save completes before moving to next step
            Future.delayed(const Duration(milliseconds: 300), () {
              stepManager.goToNextStep();
            });
          },
        );

      case 3:
        // Profession step
        return ProfessionStep(
          onStepCompleted: () {
            // Add a small delay to ensure the save completes before moving to next step
            Future.delayed(const Duration(milliseconds: 300), () {
              stepManager.goToNextStep();
            });
          },
        );
        
      case 4:
        // Language step
        return LanguageStep(
          selectedLanguages: state.languages,
          onLanguagesSelected: (List<String> languages) {
            // Update languages in the onboarding bloc
            stepManager.onboardingBloc.add(LanguagesUpdated(languages));
            
            // Save languages directly
            stepManager.onboardingBloc.add(LanguagesSaveRequested(languages));
            
            // Add a small delay to ensure the save completes before moving to next step
            Future.delayed(const Duration(milliseconds: 300), () {
              stepManager.goToNextStep();
            });
          },
        );
        
      case 5:
        // Interest step
        return InterestStep(
          selectedInterests: state.interests,
          onInterestsSelected: (List<int> interests) {
            // Update interests in the onboarding bloc
            stepManager.onboardingBloc.add(InterestsUpdated(interests));
            
            // Add a small delay to ensure the save completes before moving to next step
            Future.delayed(const Duration(milliseconds: 300), () {
              stepManager.goToNextStep();
            });
          },
        );

      // Additional cases for other steps will be added here

      default:
        return const Center(
          child: Text('Step not implemented yet'),
        );
    }
  }
}
