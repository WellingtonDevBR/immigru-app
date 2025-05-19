import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';
import 'package:immigru/features/onboarding/domain/usecases/add_migration_step_usecase.dart';
import 'package:immigru/features/onboarding/domain/usecases/get_migration_steps_usecase.dart';
import 'package:immigru/features/onboarding/domain/usecases/remove_migration_step_usecase.dart';
import 'package:immigru/features/onboarding/domain/usecases/save_migration_steps_usecase.dart';
import 'package:immigru/features/onboarding/domain/usecases/update_migration_step_usecase.dart';
import 'package:immigru/features/onboarding/presentation/bloc/migration_journey/migration_journey_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/migration_journey/migration_journey_state.dart';
import 'package:immigru/new_core/logging/logger_interface.dart';

/// BLoC for managing migration journey
class MigrationJourneyBloc extends Bloc<MigrationJourneyEvent, MigrationJourneyState> {
  final GetMigrationStepsUseCase _getMigrationStepsUseCase;
  final SaveMigrationStepsUseCase _saveMigrationStepsUseCase;
  final AddMigrationStepUseCase _addMigrationStepUseCase;
  final UpdateMigrationStepUseCase _updateMigrationStepUseCase;
  final RemoveMigrationStepUseCase _removeMigrationStepUseCase;
  final LoggerInterface _logger;
  
  // Track deleted steps that need to be sent to the backend
  final List<MigrationStep> _deletedSteps = [];

  /// Constructor
  MigrationJourneyBloc({
    required GetMigrationStepsUseCase getMigrationStepsUseCase,
    required SaveMigrationStepsUseCase saveMigrationStepsUseCase,
    required AddMigrationStepUseCase addMigrationStepUseCase,
    required UpdateMigrationStepUseCase updateMigrationStepUseCase,
    required RemoveMigrationStepUseCase removeMigrationStepUseCase,
    required LoggerInterface logger,
  })  : _getMigrationStepsUseCase = getMigrationStepsUseCase,
        _saveMigrationStepsUseCase = saveMigrationStepsUseCase,
        _addMigrationStepUseCase = addMigrationStepUseCase,
        _updateMigrationStepUseCase = updateMigrationStepUseCase,
        _removeMigrationStepUseCase = removeMigrationStepUseCase,
        _logger = logger,
        super(MigrationJourneyState.initial()) {
    on<MigrationJourneyInitialized>(_onInitialized);
    on<MigrationStepAdded>(_onStepAdded);
    on<MigrationStepUpdated>(_onStepUpdated);
    on<MigrationStepRemoved>(_onStepRemoved);
    on<MigrationStepsSaved>(_onStepsSaved);
    on<MigrationStepsForceUpdated>(_onStepsForceUpdated);
  }

  /// Handle initialization event
  Future<void> _onInitialized(
    MigrationJourneyInitialized event,
    Emitter<MigrationJourneyState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      
      final steps = await _getMigrationStepsUseCase();
      
      // Sort steps by date (most recent on top)
      final sortedSteps = _sortStepsByDate(steps);
      
      emit(state.copyWith(
        steps: sortedSteps,
        isLoading: false,
        hasChanges: false,
      ));
      
      _logger.i(
        'Initialized with ${sortedSteps.length} migration steps',
        tag: 'MigrationJourneyBloc',
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Error initializing migration journey',
        tag: 'MigrationJourneyBloc',
        error: e,
        stackTrace: stackTrace,
      );
      
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load migration steps. Please try again.',
      ));
    }
  }

  /// Sort steps by date (most recent on top) with birth country always at the bottom
  List<MigrationStep> _sortStepsByDate(List<MigrationStep> steps) {
    // Create a copy of the steps list to avoid modifying the original
    final sortedSteps = List<MigrationStep>.from(steps);
    
    // First, extract the birth country step if it exists
    MigrationStep? birthCountryStep;
    try {
      birthCountryStep = sortedSteps.firstWhere(
        (step) => step.id.startsWith('birth_') || step.isBirthCountry,
      );
      // Remove the birth country step from the list
      sortedSteps.removeWhere((step) => step.id.startsWith('birth_') || step.isBirthCountry);
      _logger.i(
        'Extracted birth country step: ${birthCountryStep.countryName}',
        tag: 'MigrationJourneyBloc',
      );
    } catch (_) {
      // No birth country step found
      birthCountryStep = null;
      _logger.w(
        'No birth country step found during sorting',
        tag: 'MigrationJourneyBloc',
      );
    }
    
    // CRITICAL: Sort the remaining steps with specific priorities
    sortedSteps.sort((a, b) {
      // Get the dates, defaulting to a very old date if null
      final aDate = a.startDate ?? DateTime(1900);
      final bDate = b.startDate ?? DateTime(1900);
      
      // Priority 1: Target countries should be at the top
      if (a.isTargetCountry != b.isTargetCountry) {
        return a.isTargetCountry ? -1 : 1;
      }
      
      // Priority 2: Current location should be next
      if (a.isCurrentLocation != b.isCurrentLocation) {
        return a.isCurrentLocation ? -1 : 1;
      }
      
      // Priority 3: Sort by date (most recent first)
      return bDate.compareTo(aDate);
    });
    
    // Log the sorted steps (without birth country)
    _logger.i(
      'Sorted steps (before adding birth country): ${sortedSteps.map((s) => "${s.countryName} (${s.startDate})").join(', ')}',
      tag: 'MigrationJourneyBloc',
    );
    
    // If birth country step exists, add it at the bottom
    if (birthCountryStep != null) {
      sortedSteps.add(birthCountryStep);
      _logger.i(
        'Added birth country step to the bottom: ${birthCountryStep.countryName}',
        tag: 'MigrationJourneyBloc',
      );
    }
    
    // Log the final sorted steps
    _logger.i(
      'Final sorted steps: ${sortedSteps.map((s) => "${s.countryName} (${s.startDate})").join(', ')}',
      tag: 'MigrationJourneyBloc',
    );
    
    return sortedSteps;
  }
  
  /// Ensure only the most recent country is marked as current and set end dates for previous countries
  List<MigrationStep> _ensureOnlyMostRecentIsCurrent(List<MigrationStep> steps) {
    // Create a copy of the steps list to avoid modifying the original
    final updatedSteps = List<MigrationStep>.from(steps);
    
    // First, extract the birth country step if it exists
    MigrationStep? birthCountryStep;
    try {
      birthCountryStep = updatedSteps.firstWhere(
        (step) => step.id.startsWith('birth_') || step.isBirthCountry,
      );
      // Remove the birth country step from the list for processing
      updatedSteps.removeWhere((step) => step.id.startsWith('birth_') || step.isBirthCountry);
    } catch (_) {
      birthCountryStep = null;
    }
    
    // Extract target countries
    final targetCountries = updatedSteps.where((step) => step.isTargetCountry).toList();
    // Remove target countries from the list for processing
    updatedSteps.removeWhere((step) => step.isTargetCountry);
    
    // Sort remaining steps by date (most recent first)
    updatedSteps.sort((a, b) {
      final aDate = a.startDate ?? DateTime(1900);
      final bDate = b.startDate ?? DateTime(1900);
      return bDate.compareTo(aDate);
    });
    
    // Process regular countries (not target or birth countries)
    // First pass: mark the most recent as current
    if (updatedSteps.isNotEmpty) {
      // Mark the most recent country as current
      final mostRecentStep = updatedSteps.first;
      updatedSteps[0] = mostRecentStep.copyWith(
        isCurrentLocation: true,
        endDate: null, // Current location has no end date
      );
      
      // Second pass: ensure all other countries are not current and set end dates
      for (int i = 1; i < updatedSteps.length; i++) {
        final step = updatedSteps[i];
        final nextStep = updatedSteps[i - 1]; // The next chronological step (remember list is in reverse chronological order)
        
        // Ensure this step is not marked as current
        var updatedStep = step.copyWith(isCurrentLocation: false);
        
        // If this step has no end date, set it to the start date of the next step
        // This assumes the person left this country when they arrived at the next one
        if (updatedStep.endDate == null && nextStep.startDate != null) {
          updatedStep = updatedStep.copyWith(endDate: nextStep.startDate);
          _logger.i(
            'Automatically set end date for ${updatedStep.countryName} to ${nextStep.startDate}',
            tag: 'MigrationJourneyBloc',
          );
        }
        
        updatedSteps[i] = updatedStep;
      }
    }
    
    // Process target countries
    for (int i = 0; i < targetCountries.length; i++) {
      final targetStep = targetCountries[i];
      
      // Ensure target countries are never marked as current
      targetCountries[i] = targetStep.copyWith(
        isCurrentLocation: false,
        endDate: null, // Target countries don't have end dates
      );
    }
    
    // Add back target countries
    updatedSteps.addAll(targetCountries);
    
    // Add back birth country step if it exists
    if (birthCountryStep != null) {
      updatedSteps.add(birthCountryStep);
    }
    
    return updatedSteps;
  }

  /// Handle step added event
  Future<void> _onStepAdded(
    MigrationStepAdded event,
    Emitter<MigrationJourneyState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      
      // Check if this is a birth country step (has 'birth_' prefix in ID)
      final isBirthCountryStep = event.step.id.startsWith('birth_');
      
      // If this is a birth country step, check if we already have one
      if (isBirthCountryStep) {
        // Check if we already have a birth country step
        final hasBirthCountryStep = state.steps.any((step) => step.id.startsWith('birth_'));
        
        if (hasBirthCountryStep) {
          // We already have a birth country step, so update it instead of adding a new one
          final updatedSteps = await _updateBirthCountryStep(event.step);
          
          emit(state.copyWith(
            steps: updatedSteps,
            isLoading: false,
            hasChanges: true,
          ));
          
          _logger.i(
            'Updated birth country step for ${event.step.countryName}',
            tag: 'MigrationJourneyBloc',
          );
          return;
        }
      }
      
      // Add the step normally
      final updatedSteps = await _addMigrationStepUseCase(event.step);
      
      // CRITICAL: Ensure birth country step is preserved
      MigrationStep? birthCountryStep;
      try {
        // First check if there's a birth country step in the current state
        birthCountryStep = state.steps.firstWhere(
          (step) => step.id.startsWith('birth_'),
        );
        
        _logger.i(
          'Found birth country step in current state before adding new step: ${birthCountryStep.countryName}',
          tag: 'MigrationJourneyBloc',
        );
        
        // Check if birth country step is missing from updated steps
        if (!updatedSteps.any((step) => step.id.startsWith('birth_'))) {
          _logger.w(
            'Birth country step was lost during step addition, adding it back: ${birthCountryStep.countryName}',
            tag: 'MigrationJourneyBloc',
          );
          
          // Add birth country step back to the list
          updatedSteps.add(birthCountryStep);
        }
      } catch (_) {
        // No birth country step found in current state
        _logger.i(
          'No birth country step found in current state when adding new step',
          tag: 'MigrationJourneyBloc',
        );
      }
      
      // Ensure only the most recent country is marked as current
      final processedSteps = _ensureOnlyMostRecentIsCurrent(updatedSteps);
      
      // Sort steps by date (most recent on top)
      final sortedSteps = _sortStepsByDate(processedSteps);
      
      emit(state.copyWith(
        steps: sortedSteps,
        isLoading: false,
        hasChanges: true,
      ));
      
      _logger.i(
        'Added migration step for ${event.step.countryName}',
        tag: 'MigrationJourneyBloc',
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Error adding migration step',
        tag: 'MigrationJourneyBloc',
        error: e,
        stackTrace: stackTrace,
      );
      
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to add migration step. Please try again.',
      ));
    }
  }
  
  /// Update the birth country step
  Future<List<MigrationStep>> _updateBirthCountryStep(MigrationStep newBirthCountryStep) async {
    // Get the current steps
    final currentSteps = List<MigrationStep>.from(state.steps);
    
    // Find the index of the birth country step
    final index = currentSteps.indexWhere((step) => step.id.startsWith('birth_'));
    
    if (index != -1) {
      // Replace the birth country step
      currentSteps[index] = newBirthCountryStep;
    } else {
      // Add the birth country step if not found
      currentSteps.add(newBirthCountryStep);
    }
    
    return currentSteps;
  }
  
  // Removed _sortStepsWithBirthCountryFirst method as it's replaced by _sortStepsByDate

  /// Handle step updated event
  Future<void> _onStepUpdated(
    MigrationStepUpdated event,
    Emitter<MigrationJourneyState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      
      // Check if the step ID exists in our current steps
      final stepExists = state.steps.any((step) => step.id == event.id);
      
      if (!stepExists) {
        _logger.w(
          'Step with ID ${event.id} not found in current steps, adding as new step',
          tag: 'MigrationJourneyBloc',
        );
        
        // If step doesn't exist, add it instead of updating
        final addedSteps = await _addMigrationStepUseCase(event.step);
        
        emit(state.copyWith(
          steps: addedSteps,
          isLoading: false,
          hasChanges: true,
        ));
        
        _logger.i(
          'Added new migration step for ${event.step.countryName}',
          tag: 'MigrationJourneyBloc',
        );
        return;
      }
      
      // Proceed with update if step exists
      final updatedSteps = await _updateMigrationStepUseCase(event.id, event.step);
      
      // CRITICAL: Ensure birth country step is preserved
      MigrationStep? birthCountryStep;
      try {
        // First check if there's a birth country step in the current state
        birthCountryStep = state.steps.firstWhere(
          (step) => step.id.startsWith('birth_'),
        );
        
        _logger.i(
          'Found birth country step in current state: ${birthCountryStep.countryName}',
          tag: 'MigrationJourneyBloc',
        );
      } catch (_) {
        // No birth country step found in current state
        _logger.w(
          'No birth country step found in current state',
          tag: 'MigrationJourneyBloc',
        );
        birthCountryStep = null;
      }
      
      // Check if birth country step is missing from updated steps
      if (birthCountryStep != null && !updatedSteps.any((step) => step.id.startsWith('birth_'))) {
        _logger.w(
          'Birth country step was lost during update, adding it back: ${birthCountryStep.countryName}',
          tag: 'MigrationJourneyBloc',
        );
        
        // Add birth country step back to the list
        updatedSteps.add(birthCountryStep);
      }
      
      // Ensure only the most recent country is marked as current
      final processedSteps = _ensureOnlyMostRecentIsCurrent(updatedSteps);
      
      // Sort steps by date (most recent on top)
      final sortedSteps = _sortStepsByDate(processedSteps);
      
      emit(state.copyWith(
        steps: sortedSteps,
        isLoading: false,
        hasChanges: true,
      ));
      
      _logger.i(
        'Updated migration step ${event.id} for ${event.step.countryName}',
        tag: 'MigrationJourneyBloc',
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Error updating migration step',
        tag: 'MigrationJourneyBloc',
        error: e,
        stackTrace: stackTrace,
      );
      
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update migration step. Please try again.',
      ));
    }
  }

  /// Handle step removal event
  Future<void> _onStepRemoved(
    MigrationStepRemoved event,
    Emitter<MigrationJourneyState> emit,
  ) async {
    try {
      // CRITICAL: Prevent removal of birth country steps
      if (event.id.startsWith('birth_')) {
        _logger.w(
          'Attempted to remove birth country step (${event.id}), which is not allowed',
          tag: 'MigrationJourneyBloc',
        );
        
        emit(state.copyWith(
          errorMessage: 'Birth country cannot be removed from your migration journey.',
          isLoading: false,
        ));
        return;
      }
      
      emit(state.copyWith(isLoading: true, clearError: true));
      
      // CRITICAL: Save the birth country step before removal
      MigrationStep? birthCountryStep;
      try {
        // First check if there's a birth country step in the current state
        birthCountryStep = state.steps.firstWhere(
          (step) => step.id.startsWith('birth_'),
        );
        
        _logger.i(
          'Found birth country step before removal: ${birthCountryStep.countryName}',
          tag: 'MigrationJourneyBloc',
        );
      } catch (_) {
        // No birth country step found in current state
        _logger.w(
          'No birth country step found in current state before removal',
          tag: 'MigrationJourneyBloc',
        );
      }
      
      // Check if the step exists in the current state
      final stepExists = state.steps.any((step) => step.id == event.id);
      
      if (!stepExists) {
        // Step doesn't exist in current state, might be a UI-only temporary step
        _logger.w(
          'Step with ID ${event.id} not found in current state, might be a temporary step',
          tag: 'MigrationJourneyBloc',
        );
        
        // Just return the current state without changes
        emit(state.copyWith(isLoading: false));
        return;
      }
      
      // Find the step to be removed and add it to the deleted steps list
      final stepToRemove = state.steps.firstWhere(
        (step) => step.id == event.id,
      );
      
      // Add to deleted steps list for backend synchronization
      _deletedSteps.add(stepToRemove);
      
      // CRITICAL: Filter out any birth country steps from the deleted steps list
      _deletedSteps.removeWhere((step) => step.id.startsWith('birth_'));
      
      // Call the repository to remove the step
      try {
        final updatedSteps = await _removeMigrationStepUseCase(event.id);
        
        // CRITICAL: Ensure birth country step is preserved after removal
        if (birthCountryStep != null && !updatedSteps.any((step) => step.id.startsWith('birth_'))) {
          _logger.w(
            'Birth country step was lost during step removal, adding it back: ${birthCountryStep.countryName}',
            tag: 'MigrationJourneyBloc',
          );
          
          // Create a new list with the birth country step included
          final stepsWithBirthCountry = List<MigrationStep>.from(updatedSteps);
          stepsWithBirthCountry.add(birthCountryStep);
          
          // Save the updated steps with birth country included
          await _saveMigrationStepsUseCase(stepsWithBirthCountry);
          
          // Get the updated steps after saving
          final finalSteps = await _getMigrationStepsUseCase();
          
          // Double-check that birth country step is now present
          if (!finalSteps.any((step) => step.id.startsWith('birth_'))) {
            _logger.e(
              'CRITICAL: Birth country step still missing after recovery attempt!',
              tag: 'MigrationJourneyBloc',
            );
            
            // Force add the birth country step to the local state
            final forcedSteps = List<MigrationStep>.from(finalSteps);
            forcedSteps.add(birthCountryStep);
            
            emit(state.copyWith(
              steps: _sortStepsByDate(forcedSteps), // Sort to ensure proper order
              isLoading: false,
              hasChanges: true,
              successMessage: 'Step removed, birth country preserved',
            ));
            
            return;
          }
          
          emit(state.copyWith(
            steps: finalSteps,
            isLoading: false,
            hasChanges: true,
            successMessage: 'Step removed successfully',
          ));
          
          return;
        }
        
        // Sort steps by date (most recent on top)
        final sortedSteps = _sortStepsByDate(updatedSteps);
        
        emit(state.copyWith(
          steps: sortedSteps,
          isLoading: false,
          hasChanges: true,
        ));
      } catch (e, stackTrace) {
        _logger.e(
          'Error removing migration step',
          tag: 'MigrationJourneyBloc',
          error: e,
          stackTrace: stackTrace,
        );
        
        emit(state.copyWith(
          errorMessage: 'Failed to remove step: ${e.toString()}',
          isLoading: false,
        ));
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error removing migration step',
        tag: 'MigrationJourneyBloc',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(
        errorMessage: 'Failed to remove migration step. Please try again.',
        isLoading: false,
      ));
    }
  }

  /// Handle steps save event
  Future<void> _onStepsSaved(
    MigrationStepsSaved event,
    Emitter<MigrationJourneyState> emit,
  ) async {
    try {
      emit(state.copyWith(isSaving: true, clearError: true));
      
      // Save steps with deleted steps
      final result = await _saveMigrationStepsUseCase(
        state.steps,
        deletedSteps: _deletedSteps.isNotEmpty ? _deletedSteps : null,
      );
      
      if (result) {
        // Clear deleted steps after successful save
        _deletedSteps.clear();
        
        // Update state with success message
        emit(state.copyWith(
          isSaving: false,
          hasChanges: false,
          successMessage: 'Migration steps saved successfully',
        ));
      } else {
        // Update state with error message
        emit(state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to save migration steps',
        ));
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error saving migration steps',
        tag: 'MigrationJourneyBloc',
        error: e,
        stackTrace: stackTrace,
      );
      
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save migration steps: ${e.toString()}',
      ));
    }
  }
  
  /// Handle force update event
  Future<void> _onStepsForceUpdated(
    MigrationStepsForceUpdated event,
    Emitter<MigrationJourneyState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      
      // Get the latest steps from the server
      final updatedSteps = await _getMigrationStepsUseCase();
      
      // Sort steps by date (most recent on top)
      final sortedSteps = _sortStepsByDate(updatedSteps);
      
      emit(state.copyWith(
        steps: sortedSteps,
        isLoading: false,
        hasChanges: false,
      ));
    } catch (e, stackTrace) {
      _logger.e(
        'Error force updating migration steps',
        tag: 'MigrationJourneyBloc',
        error: e,
        stackTrace: stackTrace,
      );
      
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update migration steps: ${e.toString()}',
      ));
    }
  }
}
