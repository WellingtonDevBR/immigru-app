import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';
import 'package:immigru/features/onboarding/domain/repositories/migration_journey_repository.dart';
import 'package:immigru/new_core/logging/logger_interface.dart';

/// Use case for adding a migration step
class AddMigrationStepUseCase {
  final MigrationJourneyRepository _repository;
  final LoggerInterface _logger;

  /// Constructor
  AddMigrationStepUseCase(this._repository, this._logger);

  /// Execute the use case
  Future<List<MigrationStep>> call(MigrationStep step) async {
    try {
      _logger.i(
        'Adding migration step for country: ${step.countryName}',
        tag: 'AddMigrationStepUseCase',
      );
      
      // Generate a unique ID if not provided
      final stepToAdd = step.id.isEmpty
          ? step.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString())
          : step;
      
      final updatedSteps = await _repository.addMigrationStep(stepToAdd);
      _logger.i(
        'Migration step added successfully. Total steps: ${updatedSteps.length}',
        tag: 'AddMigrationStepUseCase',
      );
      return updatedSteps;
    } catch (e, stackTrace) {
      _logger.e(
        'Error adding migration step',
        tag: 'AddMigrationStepUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
