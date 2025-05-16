import 'package:equatable/equatable.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';

/// Base class for migration journey events
abstract class MigrationJourneyEvent extends Equatable {
  const MigrationJourneyEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the migration journey bloc
class MigrationJourneyInitialized extends MigrationJourneyEvent {
  const MigrationJourneyInitialized();
}

/// Event to add a migration step
class MigrationStepAdded extends MigrationJourneyEvent {
  final MigrationStep step;

  const MigrationStepAdded(this.step);

  @override
  List<Object?> get props => [step];
}

/// Event to update a migration step
class MigrationStepUpdated extends MigrationJourneyEvent {
  final String id;
  final MigrationStep step;

  const MigrationStepUpdated(this.id, this.step);

  @override
  List<Object?> get props => [id, step];
}

/// Event to remove a migration step
class MigrationStepRemoved extends MigrationJourneyEvent {
  final String id;

  const MigrationStepRemoved(this.id);

  @override
  List<Object?> get props => [id];
}

/// Event to save all migration steps
class MigrationStepsSaved extends MigrationJourneyEvent {
  const MigrationStepsSaved();
}

/// Event to force update the migration steps list
class MigrationStepsForceUpdated extends MigrationJourneyEvent {
  final List<MigrationStep> steps;

  const MigrationStepsForceUpdated(this.steps);

  @override
  List<Object?> get props => [steps];
}
