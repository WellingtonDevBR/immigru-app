import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';
import 'package:immigru/features/onboarding/domain/repositories/migration_journey_repository.dart';
import 'package:immigru/new_core/logging/logger_interface.dart';

/// Use case for updating a migration step
class UpdateMigrationStepUseCase {
  final MigrationJourneyRepository _repository;
  final LoggerInterface _logger;

  /// Constructor
  UpdateMigrationStepUseCase(this._repository, this._logger);

  /// Execute the use case
  Future<List<MigrationStep>> call(String id, MigrationStep step) async {
    try {
      _logger.i(
        'Updating migration step ID: $id, Country: ${step.countryName}',
        tag: 'UpdateMigrationStepUseCase',
      );
      
      final updatedSteps = await _repository.updateMigrationStep(id, step);
      _logger.i(
        'Migration step updated successfully. Total steps: ${updatedSteps.length}',
        tag: 'UpdateMigrationStepUseCase',
      );
      return updatedSteps;
    } catch (e, stackTrace) {
      _logger.e(
        'Error updating migration step',
        tag: 'UpdateMigrationStepUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
