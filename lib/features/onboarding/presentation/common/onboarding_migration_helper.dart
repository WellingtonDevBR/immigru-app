import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_status.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/current_status/current_status_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/current_status/current_status_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/migration_journey/migration_journey_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/migration_journey/migration_journey_event.dart';
import 'package:immigru/features/onboarding/presentation/common/onboarding_step_manager.dart';
import 'package:immigru/core/country/domain/entities/country.dart';
import 'package:immigru/core/logging/logger_interface.dart';

/// Helper class to facilitate migration from the old onboarding implementation to the new one
///
/// This class provides adapter methods that bridge between the old callback-based approach
/// and the new event-based approach, making it easier to gradually migrate components.
class OnboardingMigrationHelper {
  /// Convert a country selection callback to use the new architecture
  static void Function(Country) createCountrySelectionHandler({
    required BuildContext context,
    required LoggerInterface logger,
    bool autoNavigate = true,
    Duration navigationDelay = const Duration(milliseconds: 1000),
  }) {
    return (Country country) {
      logger.i('Country selected: ${country.name} (${country.isoCode})',
          tag: 'OnboardingMigration');

      // Get the onboarding bloc
      final onboardingBloc = context.read<OnboardingBloc>();

      // Update the bloc with the selected country
      onboardingBloc.add(BirthCountryUpdated(country));

      // Auto-navigate to the next step if enabled
      if (autoNavigate) {
        Future.delayed(navigationDelay, () {
          if (context.mounted) {
            onboardingBloc.add(const NextStepRequested());
          }
        });
      }
    };
  }

  /// Convert a status selection callback to use the new architecture
  static void Function(String) createStatusSelectionHandler({
    required BuildContext context,
    required LoggerInterface logger,
    bool autoNavigate = true,
    Duration navigationDelay = const Duration(milliseconds: 2000),
  }) {
    return (String statusId) {
      logger.i('Status selected: $statusId', tag: 'CurrentStatusStep');

      // Get the onboarding bloc
      final onboardingBloc = context.read<OnboardingBloc>();

      // Find the MigrationStatus that corresponds to the statusId
      final availableStatuses = MigrationStatus.getAvailableStatuses();
      final migrationStatus = availableStatuses.firstWhere(
        (status) => status.id == statusId,
        orElse: () => availableStatuses.first, // Default fallback
      );

      // Update the bloc with the selected status
      if (context.mounted) {
        try {
          // Try to use the CurrentStatusBloc if available
          final currentStatusBloc = context.read<CurrentStatusBloc>();
          currentStatusBloc.add(CurrentStatusSelected(migrationStatus));
        } catch (_) {
          // Fallback to the onboarding bloc
          onboardingBloc.add(CurrentStatusUpdated(statusId));
        }
      }

      // Auto-navigate to the next step if enabled
      if (autoNavigate) {
        Future.delayed(navigationDelay, () {
          if (context.mounted) {
            onboardingBloc.add(const NextStepRequested());
          }
        });
      }
    };
  }

  /// Convert a migration journey completion callback to use the new architecture
  static void Function(List<MigrationStep>) createMigrationJourneyHandler({
    required BuildContext context,
    required LoggerInterface logger,
    bool autoNavigate = true,
    Duration navigationDelay = const Duration(milliseconds: 2000),
  }) {
    return (List<MigrationStep> steps) {
      logger.i('Migration journey completed with ${steps.length} steps',
          tag: 'MigrationJourneyStep');

      // Get the onboarding bloc
      final onboardingBloc = context.read<OnboardingBloc>();

      if (context.mounted) {
        try {
          // Try to use the MigrationJourneyBloc if available
          final migrationJourneyBloc = context.read<MigrationJourneyBloc>();
          migrationJourneyBloc.add(MigrationStepsSaved());
        } catch (_) {
          // Fallback to the onboarding bloc
          onboardingBloc.add(MigrationJourneyUpdated(steps));
        }
      }

      // Save progress
      onboardingBloc.add(const OnboardingSaved());

      // Auto-navigate to the next step if enabled
      if (autoNavigate) {
        Future.delayed(navigationDelay, () {
          if (context.mounted) {
            onboardingBloc.add(const NextStepRequested());
          }
        });
      }
    };
  }

  /// Convert a migration journey completion callback to use the new architecture
  static void Function(List<MigrationStep>)
      createMigrationJourneyCompletionHandler({
    required BuildContext context,
    required LoggerInterface logger,
    bool autoNavigate = true,
    Duration navigationDelay = const Duration(milliseconds: 300),
  }) {
    // Delegate to the new implementation
    return createMigrationJourneyHandler(
      context: context,
      logger: logger,
      autoNavigate: autoNavigate,
      navigationDelay: navigationDelay,
    );
  }

  /// Create a step manager from a context
  static OnboardingStepManager createStepManager({
    required BuildContext context,
    required PageController pageController,
    required LoggerInterface logger,
  }) {
    return OnboardingStepManager(
      pageController: pageController,
      onboardingBloc: context.read<OnboardingBloc>(),
      logger: logger,
    );
  }
}
