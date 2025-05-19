import 'package:flutter/foundation.dart';
import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/core/services/onboarding_service.dart';
import 'package:immigru/core/services/supabase_service.dart';
import 'package:immigru/data/datasources/remote/user_profile_edge_function_data_source.dart';
import 'package:immigru/data/models/onboarding_data_model.dart';
import 'package:immigru/domain/entities/onboarding_data.dart';
import 'package:immigru/domain/entities/visa.dart';
import 'package:immigru/domain/repositories/onboarding_repository.dart';

/// Implementation of the OnboardingRepository
class OnboardingRepositoryImpl implements OnboardingRepository {
  final SupabaseService _supabaseService;
  final LoggerService _logger;
  final OnboardingService _onboardingService;
  final UserProfileEdgeFunctionDataSource _edgeFunctionDataSource;

  OnboardingRepositoryImpl(
    this._supabaseService,
    this._logger,
    this._onboardingService,
  ) : _edgeFunctionDataSource =
            UserProfileEdgeFunctionDataSource(_supabaseService, _logger);

  // Track the last saved data to prevent redundant API calls
  static final Map<String, dynamic> _lastSavedData = {};

  // Track the last save time for each step to prevent rapid consecutive saves
  static final Map<String, DateTime> _lastSaveTimes = {};

  // Minimum time between saves for the same step (milliseconds)
  static const int _saveThrottleMs = 1000;

  /// Helper method to check if a save operation should be throttled
  /// Returns true if the save should proceed, false if it should be skipped
  bool _shouldSave(String step, dynamic newData, [dynamic oldData]) {
    final now = DateTime.now();
    final lastSaveTime = _lastSaveTimes[step] ?? DateTime(2000);
    final timeSinceLastSave = now.difference(lastSaveTime).inMilliseconds;

    // Check if enough time has passed since the last save
    if (timeSinceLastSave < _saveThrottleMs) {
      return false;
    }

    // If we have old data to compare, check if the data has actually changed
    if (oldData != null && oldData == newData) {
      return false;
    }

    // Update the last save time
    _lastSaveTimes[step] = now;
    return true;
  }

  @override
  Future<void> saveOnboardingData(OnboardingData data) async {
    try {
      

      // IMPORTANT: First check for display name and save it explicitly
      // This ensures the display name is always saved when present
      if (data.displayName != null && data.displayName!.isNotEmpty) {
        // Use our throttled save method which handles caching internally
        await _saveDisplayName(data.displayName!);
      }

      // IMPORTANT: First save the birth country if it's available
      // This ensures the birth country is always saved regardless of other data
      if (data.birthCountry != null && data.birthCountry!.isNotEmpty) {
        final stepName = 'birthCountry';
        final birthCountryData = {'birthCountry': data.birthCountry};
        
        // Check if we should save (throttle and check for changes)
        if (_shouldSave(stepName, data.birthCountry, _lastSavedData['birthCountry'])) {
          try {
            await _edgeFunctionDataSource.saveStepData(
              step: stepName,
              data: birthCountryData,
              isCompleted: false,
            );
            
            // Update last saved data after successful save
            _lastSavedData['birthCountry'] = data.birthCountry;
          } catch (e) {
            // Continue with other data even if birth country save fails
            
          }
        }
      }

      // Also save the current status (MigrationStage) if available
      if (data.currentStatus != null && data.currentStatus!.isNotEmpty) {
        final stepName = 'currentStatus';
        
        // Validate the status value
        final validStatuses = [
          'planning',
          'gathering',
          'moved',
          'exploring',
          'permanent'
        ];
        
        if (validStatuses.contains(data.currentStatus)) {
          final currentStatusData = {'currentStatus': data.currentStatus};
          
          // Check if we should save (throttle and check for changes)
          if (_shouldSave(stepName, data.currentStatus, _lastSavedData['currentStatus'])) {
            try {
              await _edgeFunctionDataSource.saveStepData(
                step: stepName,
                data: currentStatusData,
                isCompleted: false,
              );
              
              // Update last saved data after successful save
              _lastSavedData['currentStatus'] = data.currentStatus;
            } catch (e) {
              // Continue with other data even if current status save fails
              
            }
          }
        } else {
          
        }
      }

      // Also save the profession if available
      if (data.profession != null && data.profession!.isNotEmpty) {
        final stepName = 'profession';
        final professionData = {'profession': data.profession};
        
        // Check if we should save (throttle and check for changes)
        if (_shouldSave(stepName, data.profession, _lastSavedData['profession'])) {
          try {
            await _edgeFunctionDataSource.saveStepData(
              step: stepName,
              data: professionData,
              isCompleted: false,
            );
            
            // Update last saved data after successful save
            _lastSavedData['profession'] = data.profession;
          } catch (e) {
            // Continue with other data even if profession save fails
            
          }
        }
      }
      
      // Save the bio if available
      if (data.bio != null && data.bio!.isNotEmpty) {
        await _saveBio(data.bio!);
      }

      // Now determine which other step to save
      String step = '';
      Map<String, dynamic> stepData = {};

      // Handle other data types
      if (data.isCompleted) {
        step = 'completed';

        stepData = OnboardingDataModel.fromEntity(data).toJson();
      } else if (data.fullName != null && data.fullName!.isNotEmpty) {
        final stepName = 'profileBasicInfo';

        // Split the full name into first and last name to match the edge function expectations
        final nameParts = data.fullName!.split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : '';
        final lastName =
            nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        // Create the data to send
        final profileData = {
          'fullName': data.fullName,
          'firstName': firstName,
          'lastName': lastName,
          'profilePhotoUrl': data.profilePhotoUrl ?? '',
        };

        // Get last saved profile data for comparison
        final lastSavedProfileData =
            _lastSavedData['profileBasicInfo'] as Map<String, dynamic>?;

        if (_shouldSave(stepName, profileData, lastSavedProfileData)) {
          try {
            await _edgeFunctionDataSource.saveStepData(
              step: stepName,
              data: profileData,
              isCompleted: false,
            );

            // Update last saved data after successful save
            _lastSavedData['profileBasicInfo'] =
                Map<String, dynamic>.from(profileData);
          } catch (e) {
            // Log error but continue with other data
          }
        }

        // Skip the general save mechanism for this case
        return;
      } else if (data.migrationSteps.isNotEmpty) {
        step = 'migrationJourney';

        // Log detailed information about each migration step
        _logger.debug('Migration Steps', 'Saving ${data.migrationSteps.length} migration steps');

        for (int i = 0; i < data.migrationSteps.length; i++) {
          final step = data.migrationSteps[i];

          // Validate critical fields
          if (step.countryId <= 0) {
            _logger.error('Validation', 'Migration step $i has invalid countryId: ${step.countryId}');
          }
          if (step.visaId == null) {
            _logger.debug('Validation', 'Migration step $i has null visaId');
          } else if (step.visaId! <= 0) {
            _logger.error('Validation', 'Migration step $i has invalid visaId: ${step.visaId}');
          }
          if (step.arrivedDate == null) {
            _logger.error('Validation', 'Migration step $i has null arrivedDate');
          }
        }

        // Important: Send migration steps to the dedicated migration-steps edge function
        try {
          await _saveMigrationSteps(data.migrationSteps);
          _logger.debug('Migration Steps', 'Successfully sent migration steps to edge function');
        } catch (e) {
          _logger.error('Migration Steps', 'Failed to save migration steps: $e');
        }

        // Also prepare the data for the user-profile edge function
        final migrationStepsData = data.migrationSteps.map((step) {
          final stepJson = step.toJson();

          // Verify the JSON has all required fields
          if (!stepJson.containsKey('countryId') ||
              stepJson['countryId'] == null) {
            _logger.error('Validation', 'Migration step JSON missing countryId');
          }
          if (!stepJson.containsKey('visaId') || stepJson['visaId'] == null) {
            _logger.debug('Validation', 'Migration step JSON missing visaId');
          }

          return stepJson;
        }).toList();

        stepData = {'migrationSteps': migrationStepsData};

        // Current status is now handled separately at the beginning
        // Display name is now handled separately at the beginning of this method
        // to ensure it's always saved when present
      } else if (data.profession != null && data.profession!.isNotEmpty) {
        step = 'profession';

        stepData = {'profession': data.profession};
      } else if (data.languages.isNotEmpty) {
        step = 'languages';

        // We need to convert language ISO codes to language IDs
        // For now, we'll just log this and let the dedicated language repository handle it

        // Skip this step as it's better handled by the dedicated language repository
        step = '';
        stepData = {};
      } else if (data.interests.isNotEmpty) {
        step = 'interests';

        stepData = {'interests': data.interests};
      } else if (data.selectedImmiGroves.isNotEmpty) {
        step = 'immiGroves';

        stepData = {'selectedImmiGroves': data.selectedImmiGroves};

        // Check if we should save (throttle and check for changes)
        final lastSavedImmiGroves = _lastSavedData['selectedImmiGroves'] as List<dynamic>?;
        if (!_shouldSave(step, data.selectedImmiGroves, lastSavedImmiGroves)) {
          // Skip saving if no changes or throttled
          step = '';
          stepData = {};
        } else {
          // Update last saved data after successful save
          _lastSavedData['selectedImmiGroves'] = List<String>.from(data.selectedImmiGroves);
        }
      } else {
        // Default to saving the entire data object
        step = 'all';

        stepData = OnboardingDataModel.fromEntity(data).toJson();
      }

      // Save the additional data using the edge function (if we have a step to save)
      if (step.isNotEmpty && stepData.isNotEmpty) {
        try {
          await _edgeFunctionDataSource.saveStepData(
            step: step,
            data: stepData,
            isCompleted: data.isCompleted,
          );
        } catch (e) {
          // Don't rethrow here, we want to continue with other operations
          // even if one step fails
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Helper method to explicitly save the display name
  Future<void> _saveDisplayName(String displayName) async {
    try {
      final stepName = 'profileDisplayName';
      final stepData = {'displayName': displayName};
      
      // Check if we should save (throttle and check for changes)
      if (!_shouldSave(stepName, displayName, _lastSavedData['displayName'])) {
        return;
      }

      // Update our tracked value before making the API call
      _lastSavedData['displayName'] = displayName;

      

      await _edgeFunctionDataSource.saveStepData(
        step: stepName,
        data: stepData,
        isCompleted: false,
      );

      
    } catch (e) {
      // Don't rethrow, we want to continue with other operations
    }
  }

  /// Helper method to explicitly save the bio
  Future<void> _saveBio(String bio) async {
    try {
      final stepName = 'profileBio';
      final stepData = {'bio': bio};
      
      // Check if we should save (throttle and check for changes)
      if (!_shouldSave(stepName, bio, _lastSavedData['bio'])) {
        return;
      }
      
      // Update our tracked value before making the API call
      _lastSavedData['bio'] = bio;
      
      await _edgeFunctionDataSource.saveStepData(
        step: stepName,
        data: stepData,
        isCompleted: false,
      );
      
    } catch (e) {
      // Don't rethrow, we want to continue with other operations
    }
  }
  
  /// Helper method to save migration steps to the dedicated migration-steps edge function
  Future<void> _saveMigrationSteps(List<MigrationStep> steps) async {
    try {
      _logger.debug('Migration Steps', 'Preparing to save ${steps.length} migration steps to migration-steps edge function');
      
      // Convert steps to JSON format expected by the migration-steps edge function
      final stepsJson = steps.map((step) => step.toJson()).toList();
      
      // Directly invoke the migration-steps edge function
      final response = await _supabaseService.client.functions.invoke(
        'migration-steps',
        body: {
          'action': 'save',
          'data': stepsJson,
        },
      );
      
      // Log response for debugging
      if (response.data == null) {
        _logger.error('Migration Steps', 'Migration steps edge function returned null data');
      } else {
        _logger.debug('Migration Steps', 'Migration steps saved successfully: ${response.data}');
      }
      
      // Check for errors
      if (response.status != 200) {
        final errorMessage = 'Error status: ${response.status}';
        _logger.error('Migration Steps', 'Error saving migration steps: $errorMessage');
        throw Exception('Failed to save migration steps: $errorMessage');
      }
    } catch (e, stackTrace) {
      _logger.error('Migration Steps', 'Exception saving migration steps: $e');
      debugPrintStack(stackTrace: stackTrace, label: 'Migration Steps Save Error');
      rethrow;
    }
  }

  @override
  Future<OnboardingData> getOnboardingData() async {
    try {
      // Get user profile data from edge function
      final userData = await _edgeFunctionDataSource.getUserProfile();

      // Extract profile data
      final profileData = userData.containsKey('profile')
          ? userData['profile'] as Map<String, dynamic>
          : <String, dynamic>{};

      // Log profile data for debugging

      // Extract migration steps if available
      List<MigrationStep> migrationSteps = [];
      if (userData.containsKey('migrationSteps') &&
          userData['migrationSteps'] is List) {
        migrationSteps =
            _parseMigrationSteps(userData['migrationSteps'] as List);
      }

      // Create onboarding data model
      final onboardingData = OnboardingDataModel(
        birthCountry: profileData['OriginCountry'] ?? '',
        currentStatus: profileData['MigrationStage'] ?? '',
        migrationSteps: migrationSteps,
        profession: profileData['Profession'] ?? '',
        languages: _parseLanguages(userData['languages'] ?? []),
        interests: _parseInterests(userData['interests'] ?? []),
        fullName: profileData['FullName'] ?? '',
        displayName: profileData['DisplayName'] ?? '',
        bio: profileData['Bio'] ?? '',
        profilePhotoUrl: profileData['AvatarUrl'] ?? '',
        currentLocation: profileData['CurrentCity'] ?? '',
        destinationCity: profileData['DestinationCity'] ?? '',
        isPrivate: profileData['IsPrivate'] ?? false,
        isCompleted: profileData['IsOnboardingCompleted'] ?? false,
      );

      return onboardingData;
    } catch (e) {
      // Return empty data on error instead of crashing
      _logger.error('OnboardingRepository', 'Failed to get onboarding data: $e');
      return OnboardingData.empty();
    }
  }

  /// Parse migration steps from the edge function response
  List<MigrationStep> _parseMigrationSteps(List<dynamic> steps) {
    return steps
        .map((step) => MigrationStep(
              id: step['Id'] ?? 0,
              order: step['Order'] ?? 0,
              countryId: step['CountryId'] ?? 0,
              countryName:
                  step['countryName'] ?? step['Country']?['Name'] ?? '',
              visaId: step['VisaId'],
              visaName: step['visaName'] ?? step['Visa']?['VisaName'] ?? '',
              arrivedDate: step['ArrivedAt'] != null
                  ? DateTime.tryParse(step['ArrivedAt'])
                  : null,
              leftDate: step['LeftAt'] != null
                  ? DateTime.tryParse(step['LeftAt'])
                  : null,
              isCurrentLocation: step['IsCurrent'] ?? false,
              isTargetDestination: step['IsTarget'] ?? false,
              wasSuccessful: step['WasSuccessful'] ?? true,
              notes: step['Notes'],
              migrationReason: _parseMigrationReason(step['MigrationReason']),
            ))
        .toList();
  }

  /// Parse migration reason from string
  MigrationReason? _parseMigrationReason(String? reasonStr) {
    if (reasonStr == null) return null;

    switch (reasonStr.toLowerCase()) {
      case 'work':
        return MigrationReason.work;
      case 'study':
        return MigrationReason.study;
      case 'family':
        return MigrationReason.family;
      case 'refugee':
        return MigrationReason.refugee;
      case 'retirement':
        return MigrationReason.retirement;
      case 'lifestyle':
        return MigrationReason.lifestyle;
      case 'other':
        return MigrationReason.other;
      default:
        return null;
    }
  }

  /// Parse languages from the edge function response
  List<String> _parseLanguages(List<dynamic> languages) {
    return languages
        .map<String>((lang) {
          if (lang is Map && lang.containsKey('Language')) {
            final language = lang['Language'];
            return language['Name'] ?? '';
          } else if (lang is String) {
            return lang;
          }
          return '';
        })
        .where((lang) => lang.isNotEmpty)
        .toList();
  }

  List<String> _parseInterests(List<dynamic> interests) {
    return interests
        .map<String>((interest) {
          if (interest is Map && interest.containsKey('Interest')) {
            final interestData = interest['Interest'];
            return interestData['Name'] ?? '';
          } else if (interest is String) {
            return interest;
          }
          return '';
        })
        .where((interest) => interest.isNotEmpty)
        .toList();
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    try {
      // First check local storage for faster response
      final hasCompletedLocally =
          await _onboardingService.hasCompletedOnboarding();

      // Check the server status using the edge function
      bool hasCompletedOnServer = false;
      try {
        hasCompletedOnServer =
            await _edgeFunctionDataSource.checkOnboardingStatus();

        // Sync local storage with server status
        if (hasCompletedOnServer && !hasCompletedLocally) {
          await _onboardingService.markOnboardingCompleted();
        }
      } catch (serverError) {
        // If server check fails, rely on local storage
        return hasCompletedLocally;
      }

      // Return the server status as the source of truth
      return hasCompletedOnServer;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> completeOnboarding() async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Get current onboarding data
      final onboardingData = await getOnboardingData();

      // Mark as completed
      final updatedData = onboardingData.copyWith(isCompleted: true);

      // Save to database
      await saveOnboardingData(updatedData);

      // Also save to local storage for faster access
      await _onboardingService.markOnboardingCompleted();
    } catch (e) {
      rethrow;
    }
  }
}
