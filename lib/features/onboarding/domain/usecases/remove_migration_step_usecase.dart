import 'package:immigru/features/onboarding/domain/repositories/migration_journey_repository.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';
import 'package:immigru/new_core/logging/logger_interface.dart';

/// Use case for removing a migration step
class RemoveMigrationStepUseCase {
  final MigrationJourneyRepository _repository;
  final LoggerInterface _logger;

  /// Constructor
  RemoveMigrationStepUseCase(this._repository, this._logger);

  /// Execute the use case
  Future<List<MigrationStep>> call(String id) async {
    try {
      _logger.i(
        'Removing migration step ID: $id',
        tag: 'RemoveMigrationStepUseCase',
      );
      
      final updatedSteps = await _repository.removeMigrationStep(id);
      _logger.i(
        'Migration step removed successfully. Total steps: ${updatedSteps.length}',
        tag: 'RemoveMigrationStepUseCase',
      );
      return updatedSteps;
    } catch (e, stackTrace) {
      _logger.e(
        'Error removing migration step',
        tag: 'RemoveMigrationStepUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
