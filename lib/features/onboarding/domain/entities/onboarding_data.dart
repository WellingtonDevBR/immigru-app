import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';

/// Entity representing user onboarding data
class OnboardingData {
  /// User's birth country ID
  final int? birthCountry;
  
  /// User's current country ID
  final int? currentCountry;
  
  /// User's visa ID
  final int? visaId;
  
  /// User's current status in migration journey
  final String? currentStatus;
  
  /// User's migration steps
  final List<MigrationStep> migrationSteps;
  
  /// User's profession
  final String? profession;
  
  /// User's selected interests
  final List<String> interests;
  
  /// User's selected languages
  final List<String> languages;
  
  /// User's selected ImmiGroves
  final List<String> selectedImmiGroves;
  
  /// User's full name
  final String? fullName;
  
  /// User's display name
  final String? displayName;
  
  /// User's bio
  final String? bio;
  
  /// User's current location
  final String? currentLocation;
  
  /// User's destination city
  final String? destinationCity;
  
  /// URL to user's profile photo
  final String? profilePhotoUrl;
  
  /// Whether user's profile is private
  final bool isPrivate;
  
  /// Whether onboarding is completed
  final bool isCompleted;
  
  /// Constructor
  const OnboardingData({
    this.birthCountry,
    this.currentCountry,
    this.visaId,
    this.currentStatus,
    this.migrationSteps = const [],
    this.profession,
    this.interests = const [],
    this.languages = const [],
    this.selectedImmiGroves = const [],
    this.fullName,
    this.displayName,
    this.bio,
    this.currentLocation,
    this.destinationCity,
    this.profilePhotoUrl,
    this.isPrivate = false,
    this.isCompleted = false,
  });
  
  /// Create a copy of this data with the given fields replaced with new values
  OnboardingData copyWith({
    int? birthCountry,
    int? currentCountry,
    int? visaId,
    String? currentStatus,
    List<MigrationStep>? migrationSteps,
    String? profession,
    List<String>? interests,
    List<String>? languages,
    List<String>? selectedImmiGroves,
    String? fullName,
    String? displayName,
    String? bio,
    String? currentLocation,
    String? destinationCity,
    String? profilePhotoUrl,
    bool? isPrivate,
    bool? isCompleted,
  }) {
    return OnboardingData(
      birthCountry: birthCountry ?? this.birthCountry,
      currentCountry: currentCountry ?? this.currentCountry,
      visaId: visaId ?? this.visaId,
      currentStatus: currentStatus ?? this.currentStatus,
      migrationSteps: migrationSteps ?? this.migrationSteps,
      profession: profession ?? this.profession,
      interests: interests ?? this.interests,
      languages: languages ?? this.languages,
      selectedImmiGroves: selectedImmiGroves ?? this.selectedImmiGroves,
      fullName: fullName ?? this.fullName,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      currentLocation: currentLocation ?? this.currentLocation,
      destinationCity: destinationCity ?? this.destinationCity,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      isPrivate: isPrivate ?? this.isPrivate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
  
  @override
  String toString() {
    return 'OnboardingData(birthCountry: $birthCountry, currentStatus: $currentStatus, interests: $interests, languages: $languages, selectedImmiGroves: $selectedImmiGroves, isCompleted: $isCompleted)';
  }
}
