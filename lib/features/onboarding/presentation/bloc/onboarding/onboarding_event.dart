import 'package:equatable/equatable.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';
import 'package:immigru/new_core/country/domain/entities/country.dart';

/// Base class for onboarding events
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the onboarding flow is initialized
class OnboardingInitialized extends OnboardingEvent {
  const OnboardingInitialized();
}

/// Event triggered when the birth country is updated
class BirthCountryUpdated extends OnboardingEvent {
  final Country country;

  const BirthCountryUpdated(this.country);

  @override
  List<Object?> get props => [country];
}

/// Event triggered when the next step is requested
class NextStepRequested extends OnboardingEvent {
  /// Whether to force navigation even if canMoveToNextStep is false
  final bool forceNavigation;
  
  const NextStepRequested({this.forceNavigation = false});
  
  @override
  List<Object?> get props => [forceNavigation];
}

/// Event triggered when the previous step is requested
class PreviousStepRequested extends OnboardingEvent {
  const PreviousStepRequested();
}

/// Event triggered when a step is skipped
class StepSkipped extends OnboardingEvent {
  const StepSkipped();
}

/// Event triggered when the onboarding flow is completed
class OnboardingCompleted extends OnboardingEvent {
  const OnboardingCompleted();
}

/// Event triggered when the onboarding data needs to be saved
class OnboardingSaved extends OnboardingEvent {
  const OnboardingSaved();
}

/// Event triggered when the current status is updated
class CurrentStatusUpdated extends OnboardingEvent {
  final String statusId;

  const CurrentStatusUpdated(this.statusId);

  @override
  List<Object?> get props => [statusId];
}

/// Event triggered when the migration journey is updated
class MigrationJourneyUpdated extends OnboardingEvent {
  final List<MigrationStep> steps;

  const MigrationJourneyUpdated(this.steps);

  @override
  List<Object?> get props => [steps];
}

/// Event triggered when the profession is updated
class ProfessionUpdated extends OnboardingEvent {
  final String profession;
  final String? industry;

  const ProfessionUpdated(this.profession, {this.industry});

  @override
  List<Object?> get props => [profession, industry];
}

/// Event triggered when languages are updated
class LanguagesUpdated extends OnboardingEvent {
  final List<String> languages;

  const LanguagesUpdated(this.languages);

  @override
  List<Object?> get props => [languages];
}

/// Event triggered when interests are updated
class InterestsUpdated extends OnboardingEvent {
  final List<String> interests;

  const InterestsUpdated(this.interests);

  @override
  List<Object?> get props => [interests];
}

/// Event triggered when languages need to be saved
class LanguagesSaveRequested extends OnboardingEvent {
  final List<String> languageCodes;

  const LanguagesSaveRequested(this.languageCodes);

  @override
  List<Object?> get props => [languageCodes];
}
