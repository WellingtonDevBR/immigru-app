import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';
import 'package:immigru/features/onboarding/domain/repositories/migration_journey_repository.dart';
import 'package:immigru/core/logging/logger_interface.dart';

/// Use case for saving migration steps
class SaveMigrationStepsUseCase {
  final MigrationJourneyRepository _repository;
  final LoggerInterface _logger;

  /// Constructor
  SaveMigrationStepsUseCase(this._repository, this._logger);

  /// Execute the use case
  ///
  /// [steps] - The list of migration steps to save
  /// [deletedSteps] - Optional list of steps to be deleted
  Future<bool> call(List<MigrationStep> steps,
      {List<MigrationStep>? deletedSteps}) async {
    try {
      _logger.i('Saving ${steps.length} migration steps',
          tag: 'SaveMigrationStepsUseCase');

      // Ensure only one step is marked as current location
      final processedSteps = _ensureSingleCurrentLocation(steps);

      // Ensure steps have proper order
      final orderedSteps = _ensureProperOrder(processedSteps);

      final result = await _repository.saveMigrationSteps(orderedSteps,
          deletedSteps: deletedSteps);
      _logger.i('Migration steps saved successfully: $result',
          tag: 'SaveMigrationStepsUseCase');
      return result;
    } catch (e, stackTrace) {
      _logger.e(
        'Error saving migration steps',
        tag: 'SaveMigrationStepsUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Ensure only one step is marked as current location
  List<MigrationStep> _ensureSingleCurrentLocation(List<MigrationStep> steps) {
    if (steps.isEmpty) return steps;

    // Count how many steps are marked as current location
    final currentLocationCount =
        steps.where((step) => step.isCurrentLocation).length;

    // If none or exactly one, no changes needed
    if (currentLocationCount <= 1) return steps;

    // If multiple, keep only the most recent one as current location
    final sortedSteps = List<MigrationStep>.from(steps)
      ..sort((a, b) {
        // Sort by end date (null end date means current)
        if (a.endDate == null && b.endDate != null) return -1;
        if (a.endDate != null && b.endDate == null) return 1;
        if (a.endDate == null && b.endDate == null) {
          // Both are current, sort by start date (most recent first)
          return b.startDate?.compareTo(a.startDate ?? DateTime(1900)) ?? -1;
        }
        // Both have end dates, sort by end date (most recent first)
        return b.endDate!.compareTo(a.endDate!);
      });

    // Mark only the most recent step as current location and others as not current
    bool foundCurrent = false;
    return sortedSteps.map((step) {
      if (step.isCurrentLocation) {
        if (!foundCurrent) {
          foundCurrent = true;
          return step;
        } else {
          return step.copyWith(isCurrentLocation: false);
        }
      }
      return step;
    }).toList();
  }

  /// Ensure steps have proper order values
  List<MigrationStep> _ensureProperOrder(List<MigrationStep> steps) {
    if (steps.isEmpty) return steps;

    // Sort steps by start date
    final sortedSteps = List<MigrationStep>.from(steps)
      ..sort((a, b) {
        final aDate = a.startDate ?? DateTime(1900);
        final bDate = b.startDate ?? DateTime(1900);
        return aDate.compareTo(bDate);
      });

    // Assign proper order values and return the sorted steps with updated order
    return sortedSteps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;
      return step.copyWith(order: index + 1);
    }).toList();
  }
}
