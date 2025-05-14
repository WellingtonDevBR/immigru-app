import 'package:immigru/domain/entities/onboarding_data.dart';
import 'package:immigru/domain/repositories/migration_steps_repository.dart';

/// Use case for getting migration steps
class GetMigrationStepsUseCase {
  final MigrationStepsRepository _repository;

  GetMigrationStepsUseCase(this._repository);

  /// Execute the use case to get migration steps
  Future<List<MigrationStep>> call() async {
    return await _repository.getMigrationSteps();
  }
}

/// Use case for saving migration steps
class SaveMigrationStepsUseCase {
  final MigrationStepsRepository _repository;

  SaveMigrationStepsUseCase(this._repository);

  /// Execute the use case to save migration steps
  Future<bool> call(List<MigrationStep> steps) async {
    return await _repository.saveMigrationSteps(steps);
  }
}
