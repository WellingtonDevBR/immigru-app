import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/domain/entities/onboarding_data.dart';
import 'package:immigru/domain/usecases/migration_steps_usecases.dart';
import 'package:immigru/presentation/blocs/migration_steps/migration_steps_event.dart';
import 'package:immigru/presentation/blocs/migration_steps/migration_steps_state.dart';

/// BLoC for managing migration steps
class MigrationStepsBloc extends Bloc<MigrationStepsEvent, MigrationStepsState> {
  final GetMigrationStepsUseCase _getMigrationStepsUseCase;
  final SaveMigrationStepsUseCase _saveMigrationStepsUseCase;
  final LoggerService _logger;

  MigrationStepsBloc({
    required GetMigrationStepsUseCase getMigrationStepsUseCase,
    required SaveMigrationStepsUseCase saveMigrationStepsUseCase,
    required LoggerService logger,
  })  : _getMigrationStepsUseCase = getMigrationStepsUseCase,
        _saveMigrationStepsUseCase = saveMigrationStepsUseCase,
        _logger = logger,
        super(MigrationStepsState.initial()) {
    on<MigrationStepsLoaded>(_onMigrationStepsLoaded);
    on<MigrationStepAdded>(_onMigrationStepAdded);
    on<MigrationStepUpdated>(_onMigrationStepUpdated);
    on<MigrationStepRemoved>(_onMigrationStepRemoved);
    on<MigrationStepsSaved>(_onMigrationStepsSaved);
    on<MigrationStepsForceChanged>(_onMigrationStepsForceChanged);
  }

  /// Handle loading migration steps
  Future<void> _onMigrationStepsLoaded(
    MigrationStepsLoaded event,
    Emitter<MigrationStepsState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      
      final steps = await _getMigrationStepsUseCase();
      
      emit(state.copyWith(
        steps: steps,
        isLoading: false,
      ));
      
      _logger.debug('MigrationStepsBloc', 'Loaded ${steps.length} migration steps');
    } catch (e) {
      _logger.error('MigrationStepsBloc', 'Failed to load migration steps: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load migration steps: $e',
      ));
    }
  }

  /// Handle adding a migration step
  void _onMigrationStepAdded(
    MigrationStepAdded event,
    Emitter<MigrationStepsState> emit,
  ) {
    try {
      final updatedSteps = List<MigrationStep>.from(state.steps)..add(event.step);
      
      emit(state.copyWith(
        steps: updatedSteps,
        hasChanges: true,
      ));
      
      _logger.debug('MigrationStepsBloc', 'Added migration step for ${event.step.countryName}');
    } catch (e) {
      _logger.error('MigrationStepsBloc', 'Failed to add migration step: $e');
      emit(state.copyWith(
        errorMessage: 'Failed to add migration step: $e',
      ));
    }
  }

  /// Handle updating a migration step
  void _onMigrationStepUpdated(
    MigrationStepUpdated event,
    Emitter<MigrationStepsState> emit,
  ) {
    try {
      if (event.index < 0 || event.index >= state.steps.length) {
        _logger.error('MigrationStepsBloc', 'Invalid index for updating migration step: ${event.index}');
        emit(state.copyWith(
          errorMessage: 'Invalid index for updating migration step',
        ));
        return;
      }
      
      final updatedSteps = List<MigrationStep>.from(state.steps);
      updatedSteps[event.index] = event.step;
      
      emit(state.copyWith(
        steps: updatedSteps,
        hasChanges: true,
      ));
      
      _logger.debug('MigrationStepsBloc', 'Updated migration step at index ${event.index} for ${event.step.countryName}');
    } catch (e) {
      _logger.error('MigrationStepsBloc', 'Failed to update migration step: $e');
      emit(state.copyWith(
        errorMessage: 'Failed to update migration step: $e',
      ));
    }
  }

  /// Handle removing a migration step
  void _onMigrationStepRemoved(
    MigrationStepRemoved event,
    Emitter<MigrationStepsState> emit,
  ) {
    try {
      if (event.index < 0 || event.index >= state.steps.length) {
        _logger.error('MigrationStepsBloc', 'Invalid index for removing migration step: ${event.index}');
        emit(state.copyWith(
          errorMessage: 'Invalid index for removing migration step',
        ));
        return;
      }
      
      final updatedSteps = List<MigrationStep>.from(state.steps);
      final removedStep = updatedSteps.removeAt(event.index);
      
      emit(state.copyWith(
        steps: updatedSteps,
        hasChanges: true,
      ));
      
      _logger.debug('MigrationStepsBloc', 'Removed migration step at index ${event.index} for ${removedStep.countryName}');
    } catch (e) {
      _logger.error('MigrationStepsBloc', 'Failed to remove migration step: $e');
      emit(state.copyWith(
        errorMessage: 'Failed to remove migration step: $e',
      ));
    }
  }

  /// Handle saving migration steps
  Future<void> _onMigrationStepsSaved(
    MigrationStepsSaved event,
    Emitter<MigrationStepsState> emit,
  ) async {
    final timestamp = DateTime.now().toIso8601String();
    try {
      debugPrint('[$timestamp] 🚀 SAVE FLOW: MigrationStepsBloc._onMigrationStepsSaved called');
      debugPrint('[$timestamp] 📊 Current steps: ${state.steps.length}');
      debugPrint('[$timestamp] 📊 Has changes flag: ${state.hasChanges}');
      
      // CRITICAL: Always force save regardless of hasChanges flag
      // This ensures edits are always saved with action="save"
      debugPrint('[$timestamp] 🚀 SAVE FLOW: Setting isSaving to true and forcing save');
      emit(state.copyWith(isSaving: true, hasChanges: true));
      
      // Log details of each step being saved
      for (int i = 0; i < state.steps.length; i++) {
        final step = state.steps[i];
        debugPrint('[$timestamp] 💾 Step $i: countryId=${step.countryId}, countryName=${step.countryName}');
        debugPrint('[$timestamp] 💾   visaId=${step.visaId}, visaName=${step.visaName}');
        debugPrint('[$timestamp] 💾   isCurrent=${step.isCurrentLocation}, isTarget=${step.isTargetDestination}');
        debugPrint('[$timestamp] 💾   dates: ${step.arrivedDate} to ${step.leftDate}');
        debugPrint('[$timestamp] 💾   id: ${step.id}, order: ${step.order}');
      }
      
      debugPrint('[$timestamp] 🚀 SAVE FLOW: Calling _saveMigrationStepsUseCase with EXPLICIT action="save"');
      final success = await _saveMigrationStepsUseCase(state.steps);
      debugPrint('[$timestamp] 🚀 SAVE FLOW: Save result: $success');
      
      if (success) {
        emit(state.copyWith(
          isSaving: false,
          hasChanges: false,
          lastSavedAt: DateTime.now(),
        ));
        
        _logger.debug('MigrationStepsBloc', 'Successfully saved ${state.steps.length} migration steps');
      } else {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to save migration steps',
        ));
        
        _logger.error('MigrationStepsBloc', 'Failed to save migration steps');
      }
    } catch (e) {
      _logger.error('MigrationStepsBloc', 'Error saving migration steps: $e');
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Error saving migration steps: $e',
      ));
    }
  }

  /// Handle forcing the hasChanges flag to true
  void _onMigrationStepsForceChanged(
    MigrationStepsForceChanged event,
    Emitter<MigrationStepsState> emit,
  ) {
    _logger.debug('MigrationStepsBloc', '🔄 Force setting hasChanges flag to true');
    
    // Make sure we emit a new state with hasChanges set to true
    final newState = state.copyWith(hasChanges: true);
    
    // Log the change for debugging
    _logger.debug('MigrationStepsBloc', '🔄 Previous hasChanges: ${state.hasChanges}, New hasChanges: ${newState.hasChanges}');
    
    // Emit the new state
    emit(newState);
  }
}
