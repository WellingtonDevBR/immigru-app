import 'package:immigru/domain/entities/profile.dart';
import 'package:immigru/domain/entities/onboarding_data.dart';

/// Repository interface for profile-related operations
abstract class ProfileRepository {
  /// Get the current user's profile
  Future<Profile?> getProfile();
  
  /// Save or update the user's profile
  Future<void> saveProfile(Profile profile);
  
  /// Upload a profile photo and return the URL
  Future<String?> uploadProfilePhoto(String localPath);
  
  /// Update privacy settings
  Future<void> updatePrivacySettings({required VisibilityType visibility});
  
  /// Save birth country information
  Future<void> saveBirthCountry(String birthCountry);
  
  /// Save current migration status
  Future<void> saveCurrentStatus(String currentStatus);
  
  /// Save migration journey steps
  Future<void> saveMigrationJourney(List<MigrationStep> migrationSteps);
  
  /// Save profession information
  Future<void> saveProfession(String profession, {String? industry});
  
  /// Save languages
  Future<void> saveLanguages(List<String> languages);
  
  /// Save interests
  Future<void> saveInterests(List<String> interests);
  
  /// Save basic profile information
  Future<void> saveBasicInfo({
    required String firstName,
    required String lastName,
    String? profilePhotoUrl,
  });
  
  /// Save display name
  Future<void> saveDisplayName(String displayName);
  
  /// Save bio
  Future<void> saveBio(String bio);
  
  /// Save location information
  Future<void> saveLocation({
    required String currentLocation,
    required String destinationCity,
  });
  
  /// Mark onboarding as completed
  Future<void> completeOnboarding();
  
  /// Check if onboarding is completed
  Future<bool> hasCompletedOnboarding();
}
