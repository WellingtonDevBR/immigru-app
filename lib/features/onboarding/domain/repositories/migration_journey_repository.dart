import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';

/// Repository interface for managing migration journey data
abstract class MigrationJourneyRepository {
  /// Get all migration steps for the current user
  Future<List<MigrationStep>> getMigrationSteps();

  /// Save all migration steps for the current user
  /// Returns true if the operation was successful
  /// 
  /// [steps] - The list of migration steps to save
  /// [deletedSteps] - Optional list of steps to be deleted
  Future<bool> saveMigrationSteps(List<MigrationStep> steps, {List<MigrationStep>? deletedSteps});

  /// Add a new migration step
  /// Returns the updated list of steps
  Future<List<MigrationStep>> addMigrationStep(MigrationStep step);

  /// Update an existing migration step
  /// Returns the updated list of steps
  Future<List<MigrationStep>> updateMigrationStep(String id, MigrationStep step);

  /// Remove a migration step
  /// Returns the updated list of steps
  Future<List<MigrationStep>> removeMigrationStep(String id);
}
