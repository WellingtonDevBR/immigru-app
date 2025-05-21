import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';
import 'package:immigru/features/onboarding/domain/repositories/migration_journey_repository.dart';
import 'package:immigru/core/logging/logger_interface.dart';

/// Use case for retrieving migration steps
class GetMigrationStepsUseCase {
  final MigrationJourneyRepository _repository;
  final LoggerInterface _logger;

  /// Constructor
  GetMigrationStepsUseCase(this._repository, this._logger);

  /// Execute the use case
  Future<List<MigrationStep>> call() async {
    try {
      _logger.i('Getting migration steps', tag: 'GetMigrationStepsUseCase');
      final steps = await _repository.getMigrationSteps();
      _logger.i('Retrieved ${steps.length} migration steps',
          tag: 'GetMigrationStepsUseCase');
      return steps;
    } catch (e, stackTrace) {
      _logger.e(
        'Error getting migration steps',
        tag: 'GetMigrationStepsUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
