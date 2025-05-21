import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';
import 'package:immigru/features/onboarding/presentation/bloc/migration_journey/migration_journey_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/migration_journey/migration_journey_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/migration_journey/migration_journey_state.dart';
import 'package:immigru/features/onboarding/presentation/common/base_onboarding_step.dart';
import 'package:immigru/features/onboarding/presentation/common/onboarding_migration_helper.dart';
import 'package:immigru/features/onboarding/presentation/common/onboarding_navigation_buttons.dart';
import 'package:immigru/features/onboarding/presentation/common/onboarding_step_header.dart';
import 'package:immigru/features/onboarding/presentation/widgets/migration_journey/migration_step_modal.dart';
import 'package:immigru/features/onboarding/presentation/widgets/migration_journey/migration_timeline_widget.dart';
import 'package:immigru/core/di/service_locator.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Widget for the migration journey step in onboarding
///
/// This step allows users to add and edit their migration journey steps.
/// It follows the new architecture pattern using the BaseOnboardingStep.
class MigrationJourneyStep extends BaseOnboardingStep {
  /// The birth country ID of the user
  final String birthCountryId;

  /// The birth country name of the user
  final String birthCountryName;

  const MigrationJourneyStep({
    super.key,
    required this.birthCountryId,
    required this.birthCountryName,
  });

  @override
  State<MigrationJourneyStep> createState() => _MigrationJourneyStepState();
}

class _MigrationJourneyStepState
    extends BaseOnboardingStepState<MigrationJourneyStep> {
  // Flag to track if the journey is complete
  bool _isJourneyComplete = false;

  // Flag to track if saving is in progress
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = ServiceLocator.instance<MigrationJourneyBloc>();
        bloc.add(const MigrationJourneyInitialized());
        return bloc;
      },
      child: Builder(
        builder: (context) {
          return _buildContent(context);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const OnboardingStepHeader(
            title: 'Your Migration Journey',
            subtitle: 'Tell us about your migration journey so far.',
            icon: Icons.flight_takeoff,
          ),

          // Migration journey content
          Expanded(
            child: BlocConsumer<MigrationJourneyBloc, MigrationJourneyState>(
              listener: (context, state) {
                // Update the journey complete flag based on the state
                if (state.steps.isNotEmpty && !_isJourneyComplete) {
                  setState(() {
                    _isJourneyComplete = true;
                  });
                } else if (state.steps.isEmpty && _isJourneyComplete) {
                  setState(() {
                    _isJourneyComplete = false;
                  });
                }
              },
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state.errorMessage != null) {
                  return _buildErrorState(context, state.errorMessage!);
                }

                return _buildMigrationJourneyContent(context, state);
              },
            ),
          ),

          // Navigation buttons
          BlocBuilder<MigrationJourneyBloc, MigrationJourneyState>(
            builder: (context, state) {
              return OnboardingNavigationButtons(
                onNext: _isJourneyComplete && !_isSaving
                    ? () => _handleJourneyCompleted(context, state.steps)
                    : null,
                onBack: () => goToPreviousStep(),
                canMoveNext: _isJourneyComplete && !_isSaving,
                showBackButton: true,
                nextButtonText: 'Continue',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load migration journey',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<MigrationJourneyBloc>().add(
                    const MigrationJourneyInitialized(),
                  );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMigrationJourneyContent(
      BuildContext context, MigrationJourneyState state) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Birth country info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.home,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Birth Country',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    Text(
                      widget.birthCountryName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Migration timeline
        Expanded(
          child: state.steps.isEmpty
              ? _buildEmptyState(context)
              : MigrationTimelineWidget(
                  steps: state.steps,
                  onEditStep: (step) => _showEditStepModal(context, step),
                  onRemoveStep: (step) => _handleDeleteStep(context, step),
                ),
        ),

        // Add step button
        if (state.steps.isNotEmpty)
          Center(
            child: TextButton.icon(
              onPressed: () => _showAddStepModal(context),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add Another Step'),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flight,
            size: 64,
            color: isDarkMode ? Colors.white38 : Colors.black26,
          ),
          const SizedBox(height: 24),
          Text(
            'No migration steps added yet',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first migration step to continue',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddStepModal(context),
            icon: const Icon(Icons.add),
            label: const Text('Add First Step'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStepModal(BuildContext context) {
    MigrationStepModal.show(
      context: context,
      onSave: (MigrationStep step) {
        context.read<MigrationJourneyBloc>().add(MigrationStepAdded(step));
      },
    );
  }

  void _showEditStepModal(BuildContext context, MigrationStep step) {
    MigrationStepModal.show(
      context: context,
      step: step,
      isEditing: true,
      onSave: (MigrationStep updatedStep) {
        context
            .read<MigrationJourneyBloc>()
            .add(MigrationStepUpdated(step.id, updatedStep));
      },
    );
  }

  void _handleDeleteStep(BuildContext context, MigrationStep step) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Step'),
        content:
            const Text('Are you sure you want to delete this migration step?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<MigrationJourneyBloc>()
                  .add(MigrationStepRemoved(step.id));
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleJourneyCompleted(
      BuildContext context, List<MigrationStep> steps) async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Store the bloc reference before the async operation
      final migrationJourneyBloc = context.read<MigrationJourneyBloc>();

      // Save the migration steps
      migrationJourneyBloc.add(const MigrationStepsSaved());

      // Update the onboarding bloc with the migration steps
      // Use the onboarding migration helper to handle the event
      final migrationHandler =
          OnboardingMigrationHelper.createMigrationJourneyCompletionHandler(
        context: context,
        logger: logger,
        autoNavigate: false,
      );
      migrationHandler(steps);

      // Add a small delay to ensure the save completes before moving to next step
      await Future.delayed(const Duration(milliseconds: 300));

      // Navigate to the next step if still mounted
      if (mounted) {
        goToNextStep();
      }
    } catch (e) {
      logger.e('Error saving migration journey',
          tag: 'MigrationJourney', error: e);

      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Failed to save migration journey. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
