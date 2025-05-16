import 'package:equatable/equatable.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_status.dart';

/// Base class for all events related to the current status step
abstract class CurrentStatusEvent extends Equatable {
  const CurrentStatusEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the current status step is initialized
class CurrentStatusInitialized extends CurrentStatusEvent {
  const CurrentStatusInitialized();
}

/// Event triggered when a migration status is selected
class CurrentStatusSelected extends CurrentStatusEvent {
  final MigrationStatus status;

  const CurrentStatusSelected(this.status);

  @override
  List<Object?> get props => [status];
}

/// Event triggered when the current status data needs to be saved
class CurrentStatusSaved extends CurrentStatusEvent {
  const CurrentStatusSaved();
}
