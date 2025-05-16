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
  const NextStepRequested();
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
