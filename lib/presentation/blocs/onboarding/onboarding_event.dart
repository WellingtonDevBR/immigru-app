import 'package:equatable/equatable.dart';
import 'package:immigru/domain/entities/onboarding_data.dart';

/// Base class for all onboarding events
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize onboarding flow
class OnboardingInitialized extends OnboardingEvent {
  const OnboardingInitialized();
}

/// Event to update birth country
class BirthCountryUpdated extends OnboardingEvent {
  final String country;

  const BirthCountryUpdated(this.country);

  @override
  List<Object> get props => [country];
}

/// Event to update current immigration status
class CurrentStatusUpdated extends OnboardingEvent {
  final String status;

  const CurrentStatusUpdated(this.status);

  @override
  List<Object> get props => [status];
}

/// Event to add a migration step
class MigrationStepAdded extends OnboardingEvent {
  final MigrationStep step;

  const MigrationStepAdded(this.step);

  @override
  List<Object> get props => [step];
}

/// Event to update a migration step
class MigrationStepUpdated extends OnboardingEvent {
  final int index;
  final MigrationStep step;

  const MigrationStepUpdated(this.index, this.step);

  @override
  List<Object> get props => [index, step];
}

/// Event to remove a migration step
class MigrationStepRemoved extends OnboardingEvent {
  final int index;

  const MigrationStepRemoved(this.index);

  @override
  List<Object> get props => [index];
}

/// Event to update profession
class ProfessionUpdated extends OnboardingEvent {
  final String profession;

  const ProfessionUpdated(this.profession);

  @override
  List<Object> get props => [profession];
}

/// Event to navigate to the next step
class NextStepRequested extends OnboardingEvent {
  const NextStepRequested();
}

/// Event to navigate to the previous step
class PreviousStepRequested extends OnboardingEvent {
  const PreviousStepRequested();
}

/// Event to skip the current step
class StepSkipped extends OnboardingEvent {
  const StepSkipped();
}

/// Event to complete the onboarding process
class OnboardingCompleted extends OnboardingEvent {
  const OnboardingCompleted();
}

/// Event to save current onboarding progress
class OnboardingSaved extends OnboardingEvent {
  const OnboardingSaved();
}
