import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/core/services/onboarding_service.dart';
import 'package:immigru/core/services/supabase_service.dart';
import 'package:immigru/data/datasources/remote/user_profile_edge_function_data_source.dart';
import 'package:immigru/data/models/onboarding_data_model.dart';
import 'package:immigru/domain/entities/country.dart';
import 'package:immigru/domain/entities/onboarding_data.dart';
import 'package:immigru/domain/entities/visa.dart';
import 'package:immigru/domain/repositories/country_repository.dart';
import 'package:immigru/domain/repositories/onboarding_repository.dart';

/// Implementation of the OnboardingRepository
class OnboardingRepositoryImpl implements OnboardingRepository {
  final SupabaseService _supabaseService;
  final LoggerService _logger;
  final OnboardingService _onboardingService;
  final UserProfileEdgeFunctionDataSource _edgeFunctionDataSource;
  final CountryRepository? _countryRepository;

  OnboardingRepositoryImpl(
    this._supabaseService, 
    this._logger, 
    this._onboardingService, 
    [this._countryRepository]
  ) : _edgeFunctionDataSource = UserProfileEdgeFunctionDataSource(_supabaseService, _logger);

  @override
  Future<void> saveOnboardingData(OnboardingData data) async {
    try {
      _logger.debug('OnboardingRepository', 'Saving onboarding data');
      
      print('==== SAVE ONBOARDING DATA - REPOSITORY ====');
      print('Received data to save:');
      print('Birth country: ${data.birthCountry}');
      print('Current status: ${data.currentStatus}');
      print('Migration steps count: ${data.migrationSteps.length}');
      print('Profession: ${data.profession}');
      print('Languages count: ${data.languages.length}');
      print('Interests count: ${data.interests.length}');
      
      // IMPORTANT: First save the birth country if it's available
      // This ensures the birth country is always saved regardless of other data
      if (data.birthCountry != null && data.birthCountry!.isNotEmpty) {
        print('==== SAVING BIRTH COUNTRY FIRST ====');
        print('Birth country: ${data.birthCountry}');
        
        final birthCountryData = {'birthCountry': data.birthCountry};
        print('Sending birth country directly: ${data.birthCountry}');
        
        try {
          await _edgeFunctionDataSource.saveStepData(
            step: 'birthCountry',
            data: birthCountryData,
            isCompleted: false,
          );
          print('==== BIRTH COUNTRY SAVED SUCCESSFULLY ====');
        } catch (e) {
          print('ERROR saving birth country: $e');
          // Continue with other data even if birth country save fails
        }
      }
      
      // Also save the current status (MigrationStage) if available
      if (data.currentStatus != null && data.currentStatus!.isNotEmpty) {
        print('==== SAVING CURRENT STATUS FIRST ====');
        print('Current status: ${data.currentStatus}');
        
        // Validate the status value
        final validStatuses = ['planning', 'gathering', 'moved', 'exploring', 'permanent'];
        if (validStatuses.contains(data.currentStatus)) {
          print('Status "${data.currentStatus}" is valid');
        } else {
          print('WARNING: Status "${data.currentStatus}" is NOT in the valid list: $validStatuses');
        }
        
        final currentStatusData = {'currentStatus': data.currentStatus};
        print('Sending current status directly: ${data.currentStatus}');
        
        try {
          await _edgeFunctionDataSource.saveStepData(
            step: 'currentStatus',
            data: currentStatusData,
            isCompleted: false,
          );
          print('==== CURRENT STATUS SAVED SUCCESSFULLY ====');
        } catch (e) {
          print('ERROR saving current status: $e');
          // Continue with other data even if current status save fails
        }
      }
      
      // Now determine which other step to save
      String step = '';
      Map<String, dynamic> stepData = {};
      
      // Handle other data types
      if (data.isCompleted) {
        step = 'completed';
        print('Detected step: completed');
        stepData = OnboardingDataModel.fromEntity(data).toJson();
      } else if (data.migrationSteps.isNotEmpty) {
        step = 'migrationJourney';
        print('==== MIGRATION JOURNEY STEP DETECTED ====');
        print('Detected step: migrationJourney with ${data.migrationSteps.length} steps');
        
        // Log detailed information about each migration step
        print('==== MIGRATION STEPS DETAILS ====');
        for (int i = 0; i <data.migrationSteps.length; i++) {
          final step = data.migrationSteps[i];
          print('Migration Step ${i+1} details:');
          print('- Country: ${step.countryName} (ID: ${step.countryId})');
          print('- Visa: ${step.visaName} (ID: ${step.visaId})');
          print('- Arrived Date: ${step.arrivedDate}');
          print('- Is Current: ${step.isCurrentLocation}');
          print('- Is Target: ${step.isTargetDestination}');
          print('- Was Successful: ${step.wasSuccessful}');
          print('- Migration Reason: ${step.migrationReason?.name}');
          print('- Notes: ${step.notes ?? 'None'}');
          
          // Validate critical fields
          if (step.countryId <= 0) {
            print('WARNING: Invalid countryId: ${step.countryId}');
          }
          if (step.visaId == null) {
            print('WARNING: Missing visaId');
          } else if (step.visaId! <= 0) {
            print('WARNING: Invalid visaId: ${step.visaId}');
          }
          if (step.arrivedDate == null) {
            print('WARNING: Missing arrivedDate');
          }
        }
        
        // Ensure we're sending the correct country ID format for each step
        print('==== SERIALIZING MIGRATION STEPS ====');
        final migrationStepsData = data.migrationSteps.map((step) {
          print('Serializing step for country: ${step.countryName}');
          print('- Country ID: ${step.countryId}');
          print('- Visa ID: ${step.visaId}');
          print('- Arrived Date: ${step.arrivedDate}');
          print('- Is Current Location: ${step.isCurrentLocation}');
          print('- Is Target Destination: ${step.isTargetDestination}');
          print('- Was Successful: ${step.wasSuccessful}');
          print('- Migration Reason: ${step.migrationReason?.name}');
          
          final stepJson = step.toJson();
          print('Serialized JSON: $stepJson');
          
          // Verify the JSON has all required fields
          if (!stepJson.containsKey('countryId') || stepJson['countryId'] == null) {
            print('ERROR: Missing countryId in serialized JSON');
          }
          if (!stepJson.containsKey('visaId') || stepJson['visaId'] == null) {
            print('ERROR: Missing visaId in serialized JSON');
          }
          
          return stepJson;
        }).toList();
        
        stepData = {'migrationSteps': migrationStepsData};
        print('==== FINAL MIGRATION STEPS DATA ====');
        print('Migration steps data to send: $stepData');
      // Current status is now handled separately at the beginning
      } else if (data.profession != null && data.profession!.isNotEmpty) {
        step = 'profession';
        print('Detected step: profession');
        stepData = {'profession': data.profession};
      } else if (data.languages.isNotEmpty) {
        step = 'languages';
        print('Detected step: languages with ${data.languages.length} languages');
        stepData = {'languages': data.languages};
      } else if (data.interests.isNotEmpty) {
        step = 'interests';
        print('Detected step: interests with ${data.interests.length} interests');
        stepData = {'interests': data.interests};
      } else {
        // Default to saving the entire data object
        step = 'all';
        print('No specific step detected, saving all data');
        stepData = OnboardingDataModel.fromEntity(data).toJson();
      }
      
      // Save the additional data using the edge function (if we have a step to save)
      if (step.isNotEmpty && stepData.isNotEmpty) {
        print('==== SENDING DATA TO EDGE FUNCTION ====');
        print('Step name: $step');
        print('Is completed: ${data.isCompleted}');
        print('Data size: ${stepData.toString().length} characters');
        
        try {
          await _edgeFunctionDataSource.saveStepData(
            step: step,
            data: stepData,
            isCompleted: data.isCompleted,
          );
          print('==== EDGE FUNCTION CALL COMPLETED SUCCESSFULLY ====');
        } catch (e, stackTrace) {
          print('==== ERROR CALLING EDGE FUNCTION ====');
          print('Error: $e');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      }

      _logger.debug('OnboardingRepository', 'Saved onboarding data successfully');
    } catch (e, stackTrace) {
      _logger.error(
        'OnboardingRepository',
        'Error saving onboarding data',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<OnboardingData> getOnboardingData() async {
    try {
      _logger.debug('OnboardingRepository', 'Getting onboarding data from edge function');
      
      // Get user profile data from edge function
      final userData = await _edgeFunctionDataSource.getUserProfile();
      
      // Extract profile data
      final profileData = userData.containsKey('profile') ? userData['profile'] as Map<String, dynamic> : <String, dynamic>{};
      
      // Log profile data for debugging
      _logger.debug('OnboardingRepository', 'Profile data: $profileData');
      
      // Extract migration steps if available
      List<MigrationStep> migrationSteps = [];
      if (userData.containsKey('migrationSteps') && userData['migrationSteps'] is List) {
        migrationSteps = _parseMigrationSteps(userData['migrationSteps'] as List);
      }
      
      // Create onboarding data model
      final onboardingData = OnboardingDataModel(
        birthCountry: profileData['OriginCountry'] ?? '',
        currentStatus: profileData['MigrationStage'] ?? '',
        migrationSteps: migrationSteps,
        profession: profileData['Profession'] ?? '',
        languages: _parseLanguages(userData['languages'] ?? []),
        interests: _parseInterests(userData['interests'] ?? []),
        firstName: profileData['FirstName'] ?? '',
        lastName: profileData['LastName'] ?? '',
        displayName: profileData['DisplayName'] ?? '',
        bio: profileData['Bio'] ?? '',
        profilePhotoUrl: profileData['AvatarUrl'] ?? '',
        currentLocation: profileData['CurrentCity'] ?? '',
        destinationCity: profileData['DestinationCity'] ?? '',
        isPrivate: profileData['IsPrivate'] ?? false,
        isCompleted: profileData['IsOnboardingCompleted'] ?? false,
      );
      
      _logger.debug('OnboardingRepository', 'Successfully retrieved onboarding data');
      return onboardingData;
    } catch (e, stackTrace) {
      _logger.error(
        'OnboardingRepository',
        'Error retrieving onboarding data from edge function',
        error: e,
        stackTrace: stackTrace,
      );
      
      // Return empty data on error instead of crashing
      return OnboardingData.empty();
    }
  }
  
  /// Parse migration steps from the edge function response
  List<MigrationStep> _parseMigrationSteps(List<dynamic> steps) {
    return steps.map((step) => MigrationStep(
      id: step['Id'] ?? 0,
      order: step['Order'] ?? 0,
      countryId: step['CountryId'] ?? 0,
      countryName: step['countryName'] ?? step['Country']?['Name'] ?? '',
      visaId: step['VisaId'],
      visaName: step['visaName'] ?? step['Visa']?['VisaName'] ?? '',
      arrivedDate: step['ArrivedAt'] != null ? DateTime.tryParse(step['ArrivedAt']) : null,
      leftDate: step['LeftAt'] != null ? DateTime.tryParse(step['LeftAt']) : null,
      isCurrentLocation: step['IsCurrent'] ?? false,
      isTargetDestination: step['IsTarget'] ?? false,
      wasSuccessful: step['WasSuccessful'] ?? true,
      notes: step['Notes'],
      migrationReason: _parseMigrationReason(step['MigrationReason']),
    )).toList();
  }
  
  /// Parse migration reason from string
  MigrationReason? _parseMigrationReason(String? reasonStr) {
    if (reasonStr == null) return null;
    
    switch (reasonStr.toLowerCase()) {
      case 'work': return MigrationReason.work;
      case 'study': return MigrationReason.study;
      case 'family': return MigrationReason.family;
      case 'refugee': return MigrationReason.refugee;
      case 'retirement': return MigrationReason.retirement;
      case 'lifestyle': return MigrationReason.lifestyle;
      case 'other': return MigrationReason.other;
      default: return null;
    }
  }
  
  /// Parse languages from the edge function response
  List<String> _parseLanguages(List<dynamic> languages) {
  return languages.map<String>((lang) {
    if (lang is Map && lang.containsKey('Language')) {
      final language = lang['Language'];
      return language['Name'] ?? '';
    } else if (lang is String) {
      return lang;
    }
    return '';
  }).where((lang) => lang.isNotEmpty).toList();
}

List<String> _parseInterests(List<dynamic> interests) {
  return interests.map<String>((interest) {
    if (interest is Map && interest.containsKey('Interest')) {
      final interestData = interest['Interest'];
      return interestData['Name'] ?? '';
    } else if (interest is String) {
      return interest;
    }
    return '';
  }).where((interest) => interest.isNotEmpty).toList();
}


  /// Helper method to get a country by its ISO code
  Future<Country?> _getCountryByCode(String isoCode) async {
    if (_countryRepository == null) {
      _logger.debug('OnboardingRepository', 'Country repository not available');
      return null;
    }
    
    try {
      final countries = await _countryRepository!.getCountries();
      final matchingCountries = countries.where((country) => country.isoCode == isoCode).toList();
      
      if (matchingCountries.isNotEmpty) {
        return matchingCountries.first;
      }
      
      _logger.debug('OnboardingRepository', 'No country found with ISO code: $isoCode');
      return null;
    } catch (e) {
      _logger.error('OnboardingRepository', 'Error fetching country data', error: e);
      return null;
    }
  }
  
  @override
  Future<bool> hasCompletedOnboarding() async {
    try {
      // First check local storage for faster response
      final hasCompletedLocally = await _onboardingService.hasCompletedOnboarding();
      
      // Check the server status using the edge function
      bool hasCompletedOnServer = false;
      try {
        hasCompletedOnServer = await _edgeFunctionDataSource.checkOnboardingStatus();
        
        // Sync local storage with server status
        if (hasCompletedOnServer && !hasCompletedLocally) {
          await _onboardingService.markOnboardingCompleted();
          _logger.debug('OnboardingRepository', 'Updated local storage with server onboarding status');
        }
      } catch (serverError) {
        _logger.error(
          'OnboardingRepository',
          'Error checking server onboarding status, falling back to local',
          error: serverError,
        );
        // If server check fails, rely on local storage
        return hasCompletedLocally;
      }
      
      // Return the server status as the source of truth
      return hasCompletedOnServer;
    } catch (e, stackTrace) {
      _logger.error(
        'OnboardingRepository',
        'Error checking onboarding completion status',
        error: e,
        stackTrace: stackTrace,
      );
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
      
      _logger.debug('OnboardingRepository', 'Marked onboarding as completed for user: ${user.id}');
    } catch (e, stackTrace) {
      _logger.error(
        'OnboardingRepository',
        'Error completing onboarding',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
