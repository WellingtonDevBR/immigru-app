import 'package:immigru/features/onboarding/data/models/migration_step_model.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';
import 'package:immigru/features/onboarding/domain/repositories/migration_journey_repository.dart';
import 'package:immigru/new_core/network/edge_function_client.dart';
import 'package:immigru/shared/interfaces/logger_interface.dart';
import 'package:flutter/foundation.dart';

/// Implementation of the MigrationJourneyRepository
class MigrationJourneyRepositoryImpl implements MigrationJourneyRepository {
  final EdgeFunctionClient _edgeFunctionClient;
  final LoggerInterface _logger;
  
  
  // Track the last saved steps to prevent redundant API calls
  static List<MigrationStep>? _lastSavedSteps;
  static DateTime _lastSaveTime = DateTime(2000); // Initialize with old date

  /// Constructor
  MigrationJourneyRepositoryImpl(this._edgeFunctionClient, this._logger);

  @override
  Future<List<MigrationStep>> getMigrationSteps() async {
    try {
      _logger.i('Getting migration steps', tag: 'MigrationJourneyRepository');
      
      // Use the dedicated migration-steps edge function
      final response = await _edgeFunctionClient.invoke<Map<String, dynamic>>(
        'migration-steps',
        body: {
          'action': 'get',
          // No need for 'step' parameter as this edge function is dedicated to migration steps
        },
      );
      
      // Log the request for debugging
      _logger.d(
        'Sent request to migration-steps edge function to get steps',
        tag: 'MigrationJourneyRepository',
      );
      
      if (!response.isSuccess || response.data == null) {
        _logger.w('No migration steps found', tag: 'MigrationJourneyRepository');
        return [];
      }
      
      final responseData = response.data!;
      
      // Check if the response has the data field
      if (!responseData.containsKey('data')) {
        _logger.w('Data field not found in response', tag: 'MigrationJourneyRepository');
        return [];
      }
      
      final data = responseData['data'];
      
      // For migration-steps edge function, data should be a direct array of steps
      if (data is List<dynamic>) {
        _logger.i('Found ${data.length} migration steps (direct list)', tag: 'MigrationJourneyRepository');
        
        // Convert to models
        final steps = data.map((json) => MigrationStepModel.fromJson(json)).toList();
        
        // Cache the steps
        _lastSavedSteps = List<MigrationStep>.from(steps);
        
        return steps;
      } 
      // For backward compatibility with user-profile endpoint
      else if (data is Map<String, dynamic> && data.containsKey('migrationSteps')) {
        final List<dynamic> stepsJson = data['migrationSteps'] as List<dynamic>;
        
        _logger.i('Found ${stepsJson.length} migration steps (nested in migrationSteps)', tag: 'MigrationJourneyRepository');
        
        // Convert to models
        final steps = stepsJson.map((json) => MigrationStepModel.fromJson(json)).toList();
        
        // Cache the steps
        _lastSavedSteps = List<MigrationStep>.from(steps);
        
        return steps;
      }
      
      _logger.w('Migration steps not found in response format', tag: 'MigrationJourneyRepository');
      return [];
    } catch (e, stackTrace) {
      _logger.e(
        'Error getting migration steps',
        tag: 'MigrationJourneyRepository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<bool> saveMigrationSteps(List<MigrationStep> steps, {List<MigrationStep>? deletedSteps}) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      _logger.i('Saving ${steps.length} migration steps', tag: 'MigrationJourneyRepository');
      
      // Check if the steps have changed since the last save
      if (_areStepsUnchanged(steps)) {
        _logger.i('Steps unchanged, skipping save', tag: 'MigrationJourneyRepository');
        return true;
      }
      
      // CRITICAL: Check if there's a birth country step in the current steps
      MigrationStep? birthCountryStep;
      try {
        birthCountryStep = steps.firstWhere(
          (step) => step.id.startsWith('birth_'),
        );
        _logger.i('Found birth country step in current steps: ${birthCountryStep.countryName}', 
          tag: 'MigrationJourneyRepository');
      } catch (_) {
        // No birth country step found in current steps
        birthCountryStep = null;
      }
      
      // If no birth country step is found in the current steps, check the last saved steps
      if (birthCountryStep == null && _lastSavedSteps != null) {
        try {
          final savedBirthCountryStep = _lastSavedSteps!.firstWhere(
            (step) => step.id.startsWith('birth_'),
          );
          
          // If found in last saved steps, add it to the current steps
          steps = [...steps, savedBirthCountryStep];
          birthCountryStep = savedBirthCountryStep;
          _logger.w('Added birth country step back from cache: ${savedBirthCountryStep.countryName}', 
            tag: 'MigrationJourneyRepository');
        } catch (_) {
          // No birth country step found in last saved steps either
          _logger.w('No birth country step found in current or cached steps', 
            tag: 'MigrationJourneyRepository');
        }
      }
      
      // Map steps to the format expected by the edge function
      final processedSteps = steps.map((step) {
        // Check if this is a birth country step
        final isBirthCountry = step.id.startsWith('birth_');
        
        // Create the base step data
        final stepData = <String, dynamic>{
          // For birth country steps, preserve the string ID to maintain the 'birth_' prefix
          'id': isBirthCountry ? step.id : (int.tryParse(step.id) != null ? int.parse(step.id) : step.id),
          'countryId': step.countryId,
          'countryName': step.countryName,
          'visaId': step.visaTypeId,
          'visaName': step.visaTypeName,
          'order': step.order,
          
          // CRITICAL: Send all possible variations of the flags to ensure compatibility
          // Current location flags
          'IsCurrent': step.isCurrentLocation,
          'isCurrent': step.isCurrentLocation,
          'isCurrentLocation': step.isCurrentLocation,
          
          // Target country flags - CRITICAL for fixing the issue
          'IsTarget': step.isTargetCountry,
          'isTarget': step.isTargetCountry,
          'isTargetCountry': step.isTargetCountry,
          'isTargetDestination': step.isTargetCountry,
          
          // Map date fields to the expected format
          'arrivedDate': step.startDate?.toIso8601String(),
          'leftDate': step.endDate?.toIso8601String(),
          // Add additional fields required by the server
          'wasSuccessful': true, // Default to true
        };
        
        // Debug: Log the processed step data
        _logger.i(
          'Processed step data for ${step.countryName}: IsTarget=${stepData['IsTarget']}, isTargetCountry=${stepData['isTargetCountry']}',
          tag: 'MigrationJourneyRepository'
        );
        
        // Add a special flag for birth country steps
        if (isBirthCountry) {
          stepData['isBirthCountry'] = true;
          stepData['IsBirthCountry'] = true; // Add both formats for compatibility
          _logger.i('Flagged birth country step for ${step.countryName}', tag: 'MigrationJourneyRepository');
        }
        
        return stepData;
      }).toList();
      
      // Add deleted steps if provided
      final deletedStepsList = <Map<String, dynamic>>[];
      if (deletedSteps != null && deletedSteps.isNotEmpty) {
        // Log deletion with more visibility
        _logger.w('[$timestamp] 🗑️ Processing ${deletedSteps.length} deleted steps', tag: 'MigrationJourneyRepository');
        
        for (var deletedStep in deletedSteps) {
          // CRITICAL: Skip if this is a birth country step - never delete birth country steps
          if (deletedStep.id.startsWith('birth_')) {
            _logger.w(
              '[$timestamp] ⚠️ Attempted to delete birth country step ${deletedStep.id} (${deletedStep.countryName}), skipping',
              tag: 'MigrationJourneyRepository',
            );
            continue; // Skip this step
          }
          
          if (deletedStep.id.isNotEmpty) {
            // Simplify the deletion format to focus on the essential fields
            // The edge function primarily needs the ID and isDeleted flag
            final processedDeletedStep = {
              // ID is the most critical field - try both formats
              'id': int.tryParse(deletedStep.id) ?? deletedStep.id,
              'Id': int.tryParse(deletedStep.id) ?? deletedStep.id,
              
              // Include country information for logging/debugging
              'CountryId': deletedStep.countryId,
              'CountryName': deletedStep.countryName,
              
              // CRITICAL: Mark as deleted in both formats
              'isDeleted': true,
              'IsDeleted': true,
            };
            
            deletedStepsList.add(processedDeletedStep);
            
            // Log with high visibility
            _logger.w(
              '🗑️ Explicitly marking step ${processedDeletedStep['id']} (${deletedStep.countryName}) for deletion',
              tag: 'MigrationJourneyRepository'
            );
            
            // Debug print for immediate console visibility
            debugPrint('[$timestamp] 🗑️ DELETION: Step ${processedDeletedStep['id']} (${deletedStep.countryName})');
          }
        }
      }
      
      // Combine active and deleted steps
      final allSteps = [...processedSteps, ...deletedStepsList];
      
      // Use the dedicated migration-steps edge function instead of user-profile
      // IMPORTANT: Send the steps directly as an array, not wrapped in a migrationSteps property
      final response = await _edgeFunctionClient.invoke(
        'migration-steps',
        body: {
          'action': 'save',
          // Send the steps array directly as the data
          'data': allSteps,
        },
      );
      
      // Log the request for debugging
      _logger.d(
        'Sent request to migration-steps edge function with ${allSteps.length} steps (including ${deletedStepsList.length} for deletion)',
        tag: 'MigrationJourneyRepository',
      );
      
      if (!response.isSuccess) {
        _logger.e(
          'Failed to save migration steps: ${response.message}',
          tag: 'MigrationJourneyRepository',
        );
        return false;
      }
      
      _logger.i('Migration steps saved successfully', tag: 'MigrationJourneyRepository');
      
      // Process the response to update client-side IDs with server-side IDs
      if (response.data != null) {
        try {
          // The response data could be a list of saved steps or a map with data field
          List<dynamic> savedSteps;
          
          if (response.data is List) {
            savedSteps = response.data as List<dynamic>;
          } else if (response.data is Map && response.data['data'] != null) {
            if (response.data['data'] is List) {
              savedSteps = response.data['data'] as List<dynamic>;
            } else {
              _logger.w('Unexpected response format: ${response.data}', tag: 'MigrationJourneyRepository');
              savedSteps = [];
            }
          } else {
            _logger.w('Unexpected response format: ${response.data}', tag: 'MigrationJourneyRepository');
            savedSteps = [];
          }
          
          // Update client-side steps with server IDs
          if (savedSteps.isNotEmpty) {
            _logger.i('Received ${savedSteps.length} saved steps from server', tag: 'MigrationJourneyRepository');
            
            // Map client-side steps to server-side IDs by country and visa
            for (var i = 0; i < steps.length; i++) {
              final clientStep = steps[i];
              
              // Find matching server step by country ID
              try {
                final matchingServerStep = savedSteps.firstWhere(
                  (serverStep) => 
                    (serverStep['CountryId'] == clientStep.countryId || 
                     serverStep['countryId'] == clientStep.countryId),
                );
                
                // Update the client step ID with server ID
                final serverId = matchingServerStep['Id'] ?? matchingServerStep['id'];
                if (serverId != null) {
                  _logger.d('Updating client step ID from ${clientStep.id} to $serverId', 
                    tag: 'MigrationJourneyRepository');
                  
                  // We can't modify the original step directly, so we'll update our cached version
                  if (_lastSavedSteps != null) {
                    try {
                      final savedStep = _lastSavedSteps!.firstWhere(
                        (step) => step.id == clientStep.id,
                      );
                      final updatedStep = savedStep.copyWith(id: serverId.toString());
                      
                      // Replace the step in the list
                      final index = _lastSavedSteps!.indexOf(savedStep);
                      if (index >= 0) {
                        _lastSavedSteps![index] = updatedStep;
                      }
                    } catch (e) {
                      // Step not found in cached list, ignore
                    }
                  }
                }
              } catch (e) {
                // No matching server step found, ignore
              }
            }
          }
        } catch (e, stackTrace) {
          _logger.e(
            'Error processing saved steps response',
            tag: 'MigrationJourneyRepository',
            error: e,
            stackTrace: stackTrace,
          );
        }
      }
      
      // Update the last saved steps
      _lastSavedSteps = List<MigrationStep>.from(steps);
      _lastSaveTime = DateTime.now();
      
      return true;
    } catch (e, stackTrace) {
      _logger.e(
        'Error saving migration steps',
        tag: 'MigrationJourneyRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
  
  /// Check if steps have changed since the last save
  bool _areStepsUnchanged(List<MigrationStep> steps) {
    // If no previous save or more than 5 minutes have passed, consider changed
    if (_lastSavedSteps == null || 
        DateTime.now().difference(_lastSaveTime).inMinutes > 5) {
      return false;
    }
    
    // If different number of steps, consider changed
    if (_lastSavedSteps!.length != steps.length) {
      return false;
    }
    
    // Check each step for changes
    for (var i = 0; i < steps.length; i++) {
      final newStep = steps[i];
      final oldStep = _lastSavedSteps![i];
      
      // Compare essential properties
      if (newStep.id != oldStep.id ||
          newStep.countryId != oldStep.countryId ||
          newStep.visaTypeId != oldStep.visaTypeId ||
          newStep.isCurrentLocation != oldStep.isCurrentLocation ||
          newStep.order != oldStep.order) {
        return false;
      }
      
      // Compare dates
      if ((newStep.startDate?.toIso8601String() != oldStep.startDate?.toIso8601String()) ||
          (newStep.endDate?.toIso8601String() != oldStep.endDate?.toIso8601String())) {
        return false;
      }
    }
    
    // No changes detected
    return true;
  }

  @override
  Future<List<MigrationStep>> addMigrationStep(MigrationStep step) async {
    try {
      _logger.i(
        'Adding migration step for country: ${step.countryName}',
        tag: 'MigrationJourneyRepository',
      );
      
      // Get current steps
      final currentSteps = await getMigrationSteps();
      
      // Add new step
      final updatedSteps = List<MigrationStep>.from(currentSteps)..add(step);
      
      // Save updated steps
      await saveMigrationSteps(updatedSteps);
      
      // Return updated steps
      return updatedSteps;
    } catch (e, stackTrace) {
      _logger.e(
        'Error adding migration step',
        tag: 'MigrationJourneyRepository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<MigrationStep>> updateMigrationStep(String id, MigrationStep step) async {
    try {
      _logger.i(
        'Updating migration step ID: $id, Country: ${step.countryName}',
        tag: 'MigrationJourneyRepository',
      );
      
      // Get current steps
      final currentSteps = await getMigrationSteps();
      
      // Try to find the step by different ID formats
      int? numericId = int.tryParse(id);
      
      // Find index of step to update - try multiple ways to match the ID
      int index = currentSteps.indexWhere((s) => s.id == id);
      
      // If not found by exact match, try numeric ID if available
      if (index == -1 && numericId != null) {
        index = currentSteps.indexWhere((s) => int.tryParse(s.id) == numericId);
      }
      
      // If still not found, try matching by country ID and visa ID
      if (index == -1) {
        index = currentSteps.indexWhere((s) => 
          s.countryId == step.countryId && 
          s.visaTypeId == step.visaTypeId);
      }
      
      // If still not found, we need to add it as a new step
      if (index == -1) {
        _logger.w(
          'Step with ID $id not found, adding as new step',
          tag: 'MigrationJourneyRepository',
        );
        
        return addMigrationStep(step);
      }
      
      // Create updated list
      final updatedSteps = List<MigrationStep>.from(currentSteps);
      
      // Preserve the server ID if it exists
      final existingId = updatedSteps[index].id;
      final updatedStep = step.copyWith(
        id: existingId, // Keep the existing ID to ensure we update the right record
      );
      
      updatedSteps[index] = updatedStep;
      
      // Save updated steps
      await saveMigrationSteps(updatedSteps);
      
      // Return updated steps
      return updatedSteps;
    } catch (e, stackTrace) {
      _logger.e(
        'Error updating migration step',
        tag: 'MigrationJourneyRepository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<MigrationStep>> removeMigrationStep(String id) async {
    try {
      _logger.i(
        'Removing migration step ID: $id',
        tag: 'MigrationJourneyRepository',
      );
      
      // Get current steps
      final currentSteps = await getMigrationSteps();
      
      // CRITICAL: Check if the step to be deleted is a birth country step
      if (id.startsWith('birth_')) {
        _logger.w(
          'Attempted to delete birth country step $id - operation blocked',
          tag: 'MigrationJourneyRepository',
        );
        // Return current steps without deleting anything
        return currentSteps;
      }
      
      // Check if the step exists in the current steps
      final stepExists = currentSteps.any((step) => step.id == id);
      
      if (!stepExists) {
        // If the step doesn't exist in the backend, it might be a temporary step
        // that was only in the UI but never saved to the backend
        _logger.w(
          'Step with ID $id not found in current steps, might be a temporary step',
          tag: 'MigrationJourneyRepository',
        );
        
        // Return current steps without any changes
        return currentSteps;
      }
      
      // Find the step to be deleted
      final stepToDelete = currentSteps.firstWhere(
        (step) => step.id == id,
      );
      
      // CRITICAL: Ensure we preserve the birth country step
      MigrationStep? birthCountryStep;
      try {
        birthCountryStep = currentSteps.firstWhere(
          (step) => step.id.startsWith('birth_'),
        );
        _logger.i('Found birth country step: ${birthCountryStep.countryName}', 
          tag: 'MigrationJourneyRepository');
      } catch (_) {
        birthCountryStep = null;
        _logger.w('No birth country step found in current steps', 
          tag: 'MigrationJourneyRepository');
      }
      
      // Create a list of steps without the deleted one
      final updatedSteps = currentSteps.where((step) => step.id != id).toList();
      
      // Create a list with the step marked for deletion
      final deletedSteps = [stepToDelete];
      
      // Log the deletion
      _logger.d(
        'Marking step $id (${stepToDelete.countryName}) for deletion',
        tag: 'MigrationJourneyRepository',
      );
      
      // Save updated steps and explicitly pass the deleted step
      await saveMigrationSteps(updatedSteps, deletedSteps: deletedSteps);
      
      // Get the updated steps after saving to ensure birth country is preserved
      final finalSteps = await getMigrationSteps();
      
      // Double-check that birth country step is still present
      if (birthCountryStep != null && !finalSteps.any((step) => step.id.startsWith('birth_'))) {
        _logger.w(
          'Birth country step missing after deletion, adding it back',
          tag: 'MigrationJourneyRepository',
        );
        
        // Add birth country step back and save again
        final stepsWithBirthCountry = [...finalSteps, birthCountryStep];
        await saveMigrationSteps(stepsWithBirthCountry);
        return stepsWithBirthCountry;
      }
      
      // Return updated steps
      return finalSteps;
    } catch (e, stackTrace) {
      _logger.e(
        'Error removing migration step',
        tag: 'MigrationJourneyRepository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
