import 'package:immigru/domain/entities/onboarding_data.dart';

/// Repository interface for handling migration steps
abstract class MigrationStepsRepository {
  /// Get all migration steps for the current user
  Future<List<MigrationStep>> getMigrationSteps();
  
  /// Save a list of migration steps
  /// Returns true if the save was successful
  Future<bool> saveMigrationSteps(List<MigrationStep> steps);
}
