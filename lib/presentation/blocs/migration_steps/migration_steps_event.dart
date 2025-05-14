import 'package:equatable/equatable.dart';
import 'package:immigru/domain/entities/onboarding_data.dart';

/// Base class for all migration steps events
abstract class MigrationStepsEvent extends Equatable {
  const MigrationStepsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load migration steps
class MigrationStepsLoaded extends MigrationStepsEvent {
  const MigrationStepsLoaded();
}

/// Event to add a migration step
class MigrationStepAdded extends MigrationStepsEvent {
  final MigrationStep step;

  const MigrationStepAdded(this.step);

  @override
  List<Object> get props => [step];
}

/// Event to update a migration step
class MigrationStepUpdated extends MigrationStepsEvent {
  final int index;
  final MigrationStep step;

  const MigrationStepUpdated(this.index, this.step);

  @override
  List<Object> get props => [index, step];
}

/// Event to remove a migration step
class MigrationStepRemoved extends MigrationStepsEvent {
  final int index;

  const MigrationStepRemoved(this.index);

  @override
  List<Object> get props => [index];
}

/// Event to save migration steps
class MigrationStepsSaved extends MigrationStepsEvent {
  const MigrationStepsSaved();
}

/// Event to force the hasChanges flag to true
class MigrationStepsForceChanged extends MigrationStepsEvent {
  const MigrationStepsForceChanged();
}
