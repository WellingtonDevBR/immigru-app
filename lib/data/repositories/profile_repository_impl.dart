import 'dart:io';
import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/core/services/onboarding_service.dart';
import 'package:immigru/core/services/supabase_service.dart';
import 'package:immigru/data/datasources/remote/user_profile_edge_function_data_source.dart';
import 'package:immigru/data/models/profile_model.dart';
import 'package:immigru/domain/entities/onboarding_data.dart';
import 'package:immigru/domain/entities/profile.dart';
import 'package:immigru/domain/repositories/profile_repository.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Implementation of the ProfileRepository interface
class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseService _supabaseService;
  final LoggerService _logger;
  final UserProfileEdgeFunctionDataSource _edgeFunctionDataSource;
  final OnboardingService _onboardingService;

  ProfileRepositoryImpl(
    this._supabaseService, 
    this._logger, 
    this._edgeFunctionDataSource,
    this._onboardingService,
  );

  @override
  Future<Profile?> getProfile() async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) {
        
        return null;
      }

      final response = await _supabaseService.client
          .from('profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return ProfileModel.fromJson(response);
    } catch (e) {
      _logger.error('ProfileRepository', 'Error fetching profile: $e');
      return null;
    }
  }

  @override
  Future<void> saveProfile(Profile profile) async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final profileData = (profile as ProfileModel).toJson();
      profileData['user_id'] = user.id;
      profileData['updated_at'] = DateTime.now().toIso8601String();

      await _supabaseService.client.from('profiles').upsert(
            profileData,
            onConflict: 'user_id',
          );

      
    } catch (e) {
      _logger.error('ProfileRepository', 'Error saving profile: $e');
      throw Exception('Failed to save profile: $e');
    }
  }

  @override
  Future<String?> uploadProfilePhoto(String localPath) async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final file = File(localPath);
      final fileExt = path.extension(localPath);
      final fileName = '${const Uuid().v4()}$fileExt';
      final filePath = 'profiles/${user.id}/$fileName';

      await _supabaseService.client.storage.from('profile_photos').upload(
            filePath,
            file,
          );

      final photoUrl = _supabaseService.client.storage
          .from('profile_photos')
          .getPublicUrl(filePath);

      
      return photoUrl;
    } catch (e) {
      _logger.error('ProfileRepository', 'Error uploading profile photo: $e');
      return null;
    }
  }

  @override
  Future<void> updatePrivacySettings({required VisibilityType visibility}) async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      await _edgeFunctionDataSource.saveStepData(
        step: 'profilePrivacy',
        data: {
          'showEmail': visibility.toString().split('.').last,
          'showLocation': visibility.toString().split('.').last,
          'showBirthdate': visibility.toString().split('.').last,
          'showProfession': visibility.toString().split('.').last,
          'showJourneyInfo': visibility.toString().split('.').last,
          'showRelationshipStatus': visibility.toString().split('.').last,
        },
      );

      
    } catch (e) {
      _logger.error('ProfileRepository', 'Error updating privacy settings: $e');
      throw Exception('Failed to update privacy settings: $e');
    }
  }
  
  @override
  Future<void> saveBirthCountry(String birthCountry) async {
    try {
      await _edgeFunctionDataSource.saveStepData(
        step: 'birthCountry',
        data: {'birthCountry': birthCountry},
      );
      
    } catch (e) {
      _logger.error('ProfileRepository', 'Error saving birth country: $e');
      throw Exception('Failed to save birth country: $e');
    }
  }
  
  @override
  Future<void> saveCurrentStatus(String currentStatus) async {
    try {
      await _edgeFunctionDataSource.saveStepData(
        step: 'currentStatus',
        data: {'currentStatus': currentStatus},
      );
      
    } catch (e) {
      _logger.error('ProfileRepository', 'Error saving current status: $e');
      throw Exception('Failed to save current status: $e');
    }
  }
  
  @override
  Future<void> saveMigrationJourney(List<MigrationStep> migrationSteps) async {
    try {
      // Convert migration steps to JSON format
      final stepsJson = migrationSteps.map((step) => {
        'countryId': step.countryId,
        'countryName': step.countryName,
        'visaId': step.visaId,
        'visaName': step.visaName,
        'arrivedAt': step.arrivedDate?.toIso8601String(),
        'leftAt': step.leftDate?.toIso8601String(),
        'isCurrent': step.isCurrentLocation,
        'isTarget': step.isTargetDestination,
        'notes': step.notes,
        'migrationReason': step.migrationReason?.toString().split('.').last,
        'wasSuccessful': step.wasSuccessful,
      }).toList();
      
      await _edgeFunctionDataSource.saveStepData(
        step: 'migrationJourney',
        data: {'migrationSteps': stepsJson},
      );
      
    } catch (e) {
      _logger.error('ProfileRepository', 'Error saving migration journey: $e');
      throw Exception('Failed to save migration journey: $e');
    }
  }
  
  @override
  Future<void> saveProfession(String profession, {String? industry}) async {
    try {
      await _edgeFunctionDataSource.saveStepData(
        step: 'profession',
        data: {
          'profession': profession,
          'industry': industry,
        },
      );
      
    } catch (e) {
      _logger.error('ProfileRepository', 'Error saving profession: $e');
      throw Exception('Failed to save profession: $e');
    }
  }
  
  @override
  Future<void> saveLanguages(List<String> languages) async {
    try {
      await _edgeFunctionDataSource.saveStepData(
        step: 'languages',
        data: {'languages': languages},
      );
      
    } catch (e) {
      _logger.error('ProfileRepository', 'Error saving languages: $e');
      throw Exception('Failed to save languages: $e');
    }
  }
  
  @override
  Future<void> saveInterests(List<String> interests) async {
    try {
      await _edgeFunctionDataSource.saveStepData(
        step: 'interests',
        data: {'interests': interests},
      );
      
    } catch (e) {
      _logger.error('ProfileRepository', 'Error saving interests: $e');
      throw Exception('Failed to save interests: $e');
    }
  }
  
  @override
  Future<void> saveBasicInfo({
    required String firstName,
    required String lastName,
    String? profilePhotoUrl,
  }) async {
    try {
      await _edgeFunctionDataSource.saveStepData(
        step: 'profileBasicInfo',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'profilePhotoUrl': profilePhotoUrl,
        },
      );
      
    } catch (e) {
      _logger.error('ProfileRepository', 'Error saving basic info: $e');
      throw Exception('Failed to save basic info: $e');
    }
  }
  
  @override
  Future<void> saveDisplayName(String displayName) async {
    try {
      await _edgeFunctionDataSource.saveStepData(
        step: 'profileDisplayName',
        data: {'displayName': displayName},
      );
      
    } catch (e) {
      _logger.error('ProfileRepository', 'Error saving display name: $e');
      throw Exception('Failed to save display name: $e');
    }
  }
  
  @override
  Future<void> saveBio(String bio) async {
    try {
      await _edgeFunctionDataSource.saveStepData(
        step: 'profileBio',
        data: {'bio': bio},
      );
      
    } catch (e) {
      _logger.error('ProfileRepository', 'Error saving bio: $e');
      throw Exception('Failed to save bio: $e');
    }
  }
  
  @override
  Future<void> saveLocation({
    required String currentLocation,
    required String destinationCity,
  }) async {
    try {
      await _edgeFunctionDataSource.saveStepData(
        step: 'profileLocation',
        data: {
          'currentLocation': currentLocation,
          'destinationCity': destinationCity,
        },
      );
      
    } catch (e) {
      _logger.error('ProfileRepository', 'Error saving location: $e');
      throw Exception('Failed to save location: $e');
    }
  }
  
  @override
  Future<void> completeOnboarding() async {
    try {
      await _edgeFunctionDataSource.saveStepData(
        step: 'completed',
        data: {},
        isCompleted: true,
      );
      
      // Also save to local storage for faster access
      await _onboardingService.markOnboardingCompleted();
      
      
    } catch (e) {
      _logger.error('ProfileRepository', 'Error completing onboarding: $e');
      throw Exception('Failed to complete onboarding: $e');
    }
  }
  
  @override
  Future<bool> hasCompletedOnboarding() async {
    try {
      // First check local storage for faster response
      final hasCompleted = await _onboardingService.hasCompletedOnboarding();
      if (hasCompleted) {
        return true;
      }
      
      // If not found in local storage, check the database via profile
      final profile = await getProfile();
      return profile != null; // If we have a profile, consider onboarding completed
    } catch (e) {
      _logger.error('ProfileRepository', 'Error checking onboarding completion: $e');
      return false;
    }
  }
}
