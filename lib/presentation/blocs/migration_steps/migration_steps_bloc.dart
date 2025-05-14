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
  // Track deleted steps that need to be sent to the backend
  final List<MigrationStep> _deletedSteps = [];
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
      
      // Ensure only one step is marked as current location
      final processedSteps = _ensureSingleCurrentLocation(steps);
      
      emit(state.copyWith(
        steps: processedSteps,
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
      final timestamp = DateTime.now().toIso8601String();
      
      // Create a copy of the current steps
      List<MigrationStep> updatedSteps = List.from(state.steps);
      
      // Ensure the country name is set in the new step
      MigrationStep stepToAdd = event.step;
      if (stepToAdd.countryName.isEmpty && stepToAdd.countryId > 0) {
        // Log warning about missing country name
        debugPrint('[$timestamp] ⚠️ WARNING: Adding step with missing country name. CountryId: ${stepToAdd.countryId}');
        stepToAdd = stepToAdd.copyWith(countryName: 'Unknown Country');
      }
      
      // Add the new step
      updatedSteps.add(stepToAdd);
      
      // Process steps to ensure proper ordering and single current location
      final processedSteps = _processSteps(updatedSteps);
      
      // Use the processed steps in the emit call
      emit(state.copyWith(
        steps: processedSteps,
        hasChanges: true,
      ));
      
      // Log the updated steps
      debugPrint('[$timestamp] Updated steps after addition:');
      for (int i = 0; i < processedSteps.length; i++) {
        final step = processedSteps[i];
        debugPrint('[$timestamp] Step ${i + 1}: ${step.countryName} (isCurrentLocation: ${step.isCurrentLocation})');
      }
      
      _logger.debug('MigrationStepsBloc', 'Added migration step for ${stepToAdd.countryName}');
    } catch (e) {
      _logger.error('MigrationStepsBloc', 'Failed to add migration step: $e');
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// Handle updating a migration step
  void _onMigrationStepUpdated(
    MigrationStepUpdated event,
    Emitter<MigrationStepsState> emit,
  ) {
    try {
      final timestamp = DateTime.now().toIso8601String();
      
      // Create a copy of the current steps
      List<MigrationStep> updatedSteps = List.from(state.steps);
      
      // Find the index of the step to update
      final index = updatedSteps.indexWhere((step) => step.id == event.step.id);
      
      if (index != -1) {
        // Ensure the country name is preserved in the updated step
        MigrationStep stepToUpdate = event.step;
        if (stepToUpdate.countryName.isEmpty && stepToUpdate.countryId > 0) {
          // Try to use the original country name if available
          final originalCountryName = updatedSteps[index].countryName;
          if (originalCountryName.isNotEmpty) {
            stepToUpdate = stepToUpdate.copyWith(countryName: originalCountryName);
            debugPrint('[$timestamp] Preserved original country name: $originalCountryName');
          } else {
            // Log warning about missing country name
            debugPrint('[$timestamp] ⚠️ WARNING: Updating step with missing country name. CountryId: ${stepToUpdate.countryId}');
            stepToUpdate = stepToUpdate.copyWith(countryName: 'Unknown Country');
          }
        }
        
        // Update the step
        updatedSteps[index] = stepToUpdate;
        
        // Process steps to ensure proper ordering and single current location
        final processedSteps = _processSteps(updatedSteps);
        
        // Use the processed steps in the emit call
        emit(state.copyWith(
          steps: processedSteps,
          hasChanges: true,
        ));
        
        // Log the updated steps
        debugPrint('[$timestamp] Updated steps after update:');
        for (int i = 0; i < processedSteps.length; i++) {
          final step = processedSteps[i];
          debugPrint('[$timestamp] Step ${i + 1}: ${step.countryName} (isCurrentLocation: ${step.isCurrentLocation})');
        }
        
        _logger.debug('MigrationStepsBloc', 'Updated migration step for ${stepToUpdate.countryName}');
      } else {
        _logger.error('MigrationStepsBloc', 'Failed to update migration step: Step not found');
        emit(state.copyWith(errorMessage: 'Failed to update migration step: Step not found'));
      }
    } catch (e) {
      _logger.error('MigrationStepsBloc', 'Failed to update migration step: $e');
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// Handle removing a migration step
  void _onMigrationStepRemoved(
    MigrationStepRemoved event,
    Emitter<MigrationStepsState> emit,
  ) {
    try {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('[$timestamp] 🗑️ MigrationStepsBloc._onMigrationStepRemoved called for index ${event.index}');
      
      // Check if we have a valid index
      if (event.index < 0 || event.index >= state.steps.length) {
        _logger.error('MigrationStepsBloc', 'Invalid index for removing migration step: ${event.index}');
        emit(state.copyWith(errorMessage: 'Invalid index for removing migration step'));
        return;
      }
      
      // Remove by index
      final removedStep = state.steps[event.index];
      debugPrint('[$timestamp] 🗑️ Removing step by index ${event.index}: ${removedStep.countryName}');
      
      // Add to deleted steps list if it has an ID (exists in the database)
      if (removedStep.id != null) {
        _deletedSteps.add(removedStep);
        debugPrint('[$timestamp] 🗑️ Added step with ID ${removedStep.id} to deleted steps list');
      }
      
      // Create a copy of the current steps without the removed step
      final updatedSteps = List<MigrationStep>.from(state.steps);
      updatedSteps.removeAt(event.index);
      
      // Process steps to ensure proper ordering and single current location
      final processedSteps = _processSteps(updatedSteps);
      
      // Use the processed steps in the emit call
      emit(state.copyWith(
        steps: processedSteps,
        hasChanges: true,
      ));
      
      // Log the updated steps
      debugPrint('[$timestamp] Updated steps after removal:');
      for (int i = 0; i < processedSteps.length; i++) {
        final step = processedSteps[i];
        debugPrint('[$timestamp] Step ${i + 1}: ${step.countryName} (isCurrentLocation: ${step.isCurrentLocation})');
      }
      
      _logger.debug('MigrationStepsBloc', 'Removed migration step for ${removedStep.countryName}');
    } catch (e) {
      _logger.error('MigrationStepsBloc', 'Failed to remove migration step: $e');
      emit(state.copyWith(errorMessage: e.toString()));
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
      
      // Mark as saving
      emit(state.copyWith(isSaving: true));
      
      // Process steps to ensure proper ordering and single current location
      final processedSteps = _processSteps(state.steps);
      
      // Save the steps
      final result = await _saveMigrationStepsUseCase(
        processedSteps,
        deletedSteps: _deletedSteps,
      );
      
      // Clear the deleted steps list after successful save
      if (result) {
        debugPrint('[$timestamp] 🗑️ Clearing deleted steps list after successful save');
        _deletedSteps.clear();
      }
      
      // Update the state
      emit(state.copyWith(
        steps: processedSteps,
        isSaving: false,
        hasChanges: false,
        lastSavedAt: DateTime.now(),
      ));
      
      debugPrint('[$timestamp] 🚀 SAVE FLOW: Save result: $result');
      _logger.debug('MigrationStepsBloc', 'Saved ${processedSteps.length} migration steps');
    } catch (e) {
      _logger.error('MigrationStepsBloc', 'Failed to save migration steps: $e');
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save migration steps: $e',
      ));
    }
  }

  /// Handle forcing the hasChanges flag to true
  void _onMigrationStepsForceChanged(
    MigrationStepsForceChanged event,
    Emitter<MigrationStepsState> emit,
  ) {
    try {
      emit(state.copyWith(hasChanges: true));
      _logger.debug('MigrationStepsBloc', 'Forced hasChanges flag to true');
    } catch (e) {
      _logger.error('MigrationStepsBloc', 'Failed to force hasChanges flag: $e');
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
  
  /// Process steps to ensure proper ordering and single current location
  List<MigrationStep> _processSteps(List<MigrationStep> steps) {
    final timestamp = DateTime.now().toIso8601String();
    
    // Log incoming steps for debugging
    debugPrint('[$timestamp] Processing ${steps.length} migration steps');
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      debugPrint('[$timestamp] Input step $i: countryId=${step.countryId}, countryName="${step.countryName}", isCurrentLocation=${step.isCurrentLocation}');
    }
    
    // Sort steps by arrival date
    steps.sort((a, b) {
      if (a.arrivedDate == null && b.arrivedDate == null) return 0;
      if (a.arrivedDate == null) return -1;
      if (b.arrivedDate == null) return 1;
      return a.arrivedDate!.compareTo(b.arrivedDate!);
    });
    
    // First pass: update orders and remove current location flag from all steps
    final List<MigrationStep> processedSteps = [];
    for (int i = 0; i < steps.length; i++) {
      // CRITICAL: Ensure country name is preserved exactly as it was
      // Do not modify the country name unless it's actually empty
      final String countryName = steps[i].countryName.isNotEmpty 
          ? steps[i].countryName 
          : 'Unknown Country';
      
      // Create a copy with updated order but preserve the original country name
      final step = steps[i].copyWith(
        order: i + 1, // 1-based ordering
        isCurrentLocation: false, // Reset current location flag
        // Only set countryName if it was empty, otherwise keep the original
        countryName: countryName,
      );
      
      // Log the step details for debugging
      debugPrint('[$timestamp] Processed step $i: countryId=${step.countryId}, countryName="${step.countryName}"');
      
      processedSteps.add(step);
    }
    
    // Second pass: determine the most recent step (by arrival date) and mark it as current location
    if (processedSteps.isNotEmpty) {
      // Find the most recent step (with the latest arrival date)
      MigrationStep? mostRecentStep;
      DateTime? latestDate;
      
      for (final step in processedSteps) {
        if (step.arrivedDate != null && (latestDate == null || step.arrivedDate!.isAfter(latestDate))) {
          latestDate = step.arrivedDate;
          mostRecentStep = step;
        }
      }
      
      // Mark the most recent step as current location
      if (mostRecentStep != null) {
        final index = processedSteps.indexOf(mostRecentStep);
        processedSteps[index] = mostRecentStep.copyWith(isCurrentLocation: true);
        debugPrint('[$timestamp] Marked step ${index + 1} (${mostRecentStep.countryName}) as current location');
      }
    }
    
    return processedSteps;
  }
  
  /// Ensure only one step is marked as current location
  List<MigrationStep> _ensureSingleCurrentLocation(List<MigrationStep> steps) {
    // If no steps, return empty list
    if (steps.isEmpty) return [];
    
    // Check if multiple steps are marked as current location
    final currentLocationSteps = steps.where((step) => step.isCurrentLocation).toList();
    
    // If only one or zero steps are marked as current location, return the original list
    if (currentLocationSteps.length <= 1) return steps;
    
    // Otherwise, process the steps to ensure only one is marked as current location
    return _processSteps(steps);
  }
}
