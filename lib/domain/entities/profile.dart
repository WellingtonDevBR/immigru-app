import 'package:equatable/equatable.dart';

/// Enum for visibility settings
enum VisibilityType {
  private,
  public,
  friends,
  connections
}

/// Entity representing user profile information
class Profile extends Equatable {
  final String? id;
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? userName;
  final String? displayName;
  final String? bio;
  final String? currentLocation;
  final String? destinationCity;
  final String? originCountry;
  final String? migrationStage;
  final String? profilePhotoUrl;
  final String? coverImageUrl;
  final String? profession;
  final String? industry;
  final String? gender;
  final DateTime? birthdate;
  final String? relationshipStatus;
  final List<String> languages;
  final List<String> interests;
  final String? migrationJourney;
  final bool isMentor;
  
  // Privacy settings
  final VisibilityType showEmail;
  final VisibilityType showLocation;
  final VisibilityType showBirthdate;
  final VisibilityType showProfession;
  final VisibilityType showJourneyInfo;
  final VisibilityType showRelationshipStatus;
  
  // Derived property for backward compatibility
  bool get isPrivate => 
      showEmail == VisibilityType.private && 
      showLocation == VisibilityType.private &&
      showBirthdate == VisibilityType.private &&
      showProfession == VisibilityType.private &&
      showJourneyInfo == VisibilityType.private;

  const Profile({
    this.id,
    this.userId,
    this.firstName,
    this.lastName,
    this.fullName,
    this.userName,
    this.displayName,
    this.bio,
    this.currentLocation,
    this.destinationCity,
    this.originCountry,
    this.migrationStage,
    this.profilePhotoUrl,
    this.coverImageUrl,
    this.profession,
    this.industry,
    this.gender,
    this.birthdate,
    this.relationshipStatus,
    this.languages = const [],
    this.interests = const [],
    this.migrationJourney,
    this.isMentor = false,
    this.showEmail = VisibilityType.private,
    this.showLocation = VisibilityType.private,
    this.showBirthdate = VisibilityType.private,
    this.showProfession = VisibilityType.private,
    this.showJourneyInfo = VisibilityType.private,
    this.showRelationshipStatus = VisibilityType.private,
  });

  /// Create a copy of this Profile with the given fields replaced with new values
  Profile copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? lastName,
    String? fullName,
    String? userName,
    String? displayName,
    String? bio,
    String? currentLocation,
    String? destinationCity,
    String? originCountry,
    String? migrationStage,
    String? profilePhotoUrl,
    String? coverImageUrl,
    String? profession,
    String? industry,
    String? gender,
    DateTime? birthdate,
    String? relationshipStatus,
    List<String>? languages,
    List<String>? interests,
    String? migrationJourney,
    bool? isMentor,
    VisibilityType? showEmail,
    VisibilityType? showLocation,
    VisibilityType? showBirthdate,
    VisibilityType? showProfession,
    VisibilityType? showJourneyInfo,
    VisibilityType? showRelationshipStatus,
  }) {
    return Profile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      userName: userName ?? this.userName,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      currentLocation: currentLocation ?? this.currentLocation,
      destinationCity: destinationCity ?? this.destinationCity,
      originCountry: originCountry ?? this.originCountry,
      migrationStage: migrationStage ?? this.migrationStage,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      profession: profession ?? this.profession,
      industry: industry ?? this.industry,
      gender: gender ?? this.gender,
      birthdate: birthdate ?? this.birthdate,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      languages: languages ?? this.languages,
      interests: interests ?? this.interests,
      migrationJourney: migrationJourney ?? this.migrationJourney,
      isMentor: isMentor ?? this.isMentor,
      showEmail: showEmail ?? this.showEmail,
      showLocation: showLocation ?? this.showLocation,
      showBirthdate: showBirthdate ?? this.showBirthdate,
      showProfession: showProfession ?? this.showProfession,
      showJourneyInfo: showJourneyInfo ?? this.showJourneyInfo,
      showRelationshipStatus: showRelationshipStatus ?? this.showRelationshipStatus,
    );
  }
  
  /// Create an empty profile
  factory Profile.empty() => const Profile();

  @override
  List<Object?> get props => [
        id,
        userId,
        firstName,
        lastName,
        fullName,
        userName,
        displayName,
        bio,
        currentLocation,
        destinationCity,
        originCountry,
        migrationStage,
        profilePhotoUrl,
        coverImageUrl,
        profession,
        industry,
        gender,
        birthdate,
        relationshipStatus,
        languages,
        interests,
        migrationJourney,
        isMentor,
        showEmail,
        showLocation,
        showBirthdate,
        showProfession,
        showJourneyInfo,
        showRelationshipStatus,
      ];
}
