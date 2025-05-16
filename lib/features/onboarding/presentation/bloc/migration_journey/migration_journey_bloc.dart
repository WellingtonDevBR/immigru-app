import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';
import 'package:immigru/features/onboarding/domain/usecases/add_migration_step_usecase.dart';
import 'package:immigru/features/onboarding/domain/usecases/get_migration_steps_usecase.dart';
import 'package:immigru/features/onboarding/domain/usecases/remove_migration_step_usecase.dart';
import 'package:immigru/features/onboarding/domain/usecases/save_migration_steps_usecase.dart';
import 'package:immigru/features/onboarding/domain/usecases/update_migration_step_usecase.dart';
import 'package:immigru/features/onboarding/presentation/bloc/migration_journey/migration_journey_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/migration_journey/migration_journey_state.dart';
import 'package:immigru/shared/interfaces/logger_interface.dart';

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
        (step) => step.id.startsWith('birth_'),
      );
      // Remove the birth country step from the list
      sortedSteps.removeWhere((step) => step.id.startsWith('birth_'));
    } catch (_) {
      // No birth country step found
      birthCountryStep = null;
    }
    
    // Sort the remaining steps by date (most recent on top)
    sortedSteps.sort((a, b) {
      // If either step is marked as current location, it should be at the top
      if (a.isCurrentLocation && !b.isCurrentLocation) return -1;
      if (!a.isCurrentLocation && b.isCurrentLocation) return 1;
      
      // If either step is marked as target country, it should be at the top after current location
      if (a.isTargetCountry && !b.isTargetCountry) return -1;
      if (!a.isTargetCountry && b.isTargetCountry) return 1;
      
      // Otherwise, sort by start date (most recent on top)
      final aDate = a.startDate ?? DateTime(1900);
      final bDate = b.startDate ?? DateTime(1900);
      return bDate.compareTo(aDate); // Reverse order for most recent first
    });
    
    // If birth country step exists, add it at the bottom
    if (birthCountryStep != null) {
      sortedSteps.add(birthCountryStep);
    }
    
    // Log the sorted steps
    _logger.d(
      'Sorted steps: ${sortedSteps.map((s) => "${s.countryName} (${s.startDate})").join(', ')}',
      tag: 'MigrationJourneyBloc',
    );
    
    return sortedSteps;
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
      
      // Sort steps by date (most recent on top)
      final sortedSteps = _sortStepsByDate(updatedSteps);
      
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
      
      // Ensure birth country step is preserved
      MigrationStep? birthCountryStep;
      try {
        birthCountryStep = state.steps.firstWhere(
          (step) => step.id.startsWith('birth_'),
        );
      } catch (_) {
        // No birth country step found
        birthCountryStep = null;
      }
      
      if (birthCountryStep != null && !updatedSteps.any((step) => step.id.startsWith('birth_'))) {
        _logger.w(
          'Birth country step was lost during update, adding it back',
          tag: 'MigrationJourneyBloc',
        );
        
        // Add birth country step back to the list
        updatedSteps.add(birthCountryStep);
      }
      
      // Sort steps by date (most recent on top)
      final sortedSteps = _sortStepsByDate(updatedSteps);
      
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
      emit(state.copyWith(isLoading: true, clearError: true));
      
      // Find the step to be removed and add it to the deleted steps list
      final stepToRemove = state.steps.firstWhere(
        (step) => step.id == event.id,
        orElse: () => throw Exception('Step not found'),
      );
      
      // Add to deleted steps list for backend synchronization
      _deletedSteps.add(stepToRemove);
      
      final updatedSteps = await _removeMigrationStepUseCase(event.id);
      
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
        
        emit(state.copyWith(
          isSaving: false,
          hasChanges: false,
        ));
      } else {
        emit(state.copyWith(
          errorMessage: 'Failed to save migration steps. Please try again.',
          isSaving: false,
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
        errorMessage: 'Failed to save migration steps. Please try again.',
        isSaving: false,
      ));
    }
  }

  /// Handle steps force updated event
  void _onStepsForceUpdated(
    MigrationStepsForceUpdated event,
    Emitter<MigrationJourneyState> emit,
  ) {
    emit(state.copyWith(
      steps: event.steps,
      hasChanges: true,
      clearError: true,
    ));
    
    _logger.i(
      'Force updated migration steps: ${event.steps.length}',
      tag: 'MigrationJourneyBloc',
    );
  }
}
