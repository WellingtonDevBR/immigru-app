import 'package:equatable/equatable.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';

/// Enhanced user profile entity with additional profile information
class UserProfile extends Equatable {
  /// Basic user information
  final User user;
  
  /// User's full name
  final String fullName;
  
  /// User's username
  final String userName;
  
  /// User's display name
  final String displayName;
  
  /// User's bio or about me text
  final String? bio;
  
  /// URL to the user's avatar
  final String? avatarUrl;
  
  /// URL to the user's cover image
  final String? coverImageUrl;
  
  /// User's gender
  final String? gender;
  
  /// User's birthdate
  final DateTime? birthdate;
  
  /// User's current city
  final String? currentCity;
  
  /// User's profession
  final String? profession;
  
  /// User's industry
  final String? industry;
  
  /// User's origin country
  final String? originCountry;
  
  /// User's migration stage
  final String? migrationStage;
  
  /// User's destination city
  final String? destinationCity;
  
  /// User's relationship status
  final String? relationshipStatus;
  
  /// Whether the user is a mentor
  final bool isMentor;
  
  /// Whether the user has completed onboarding
  final bool hasCompletedOnboarding;
  
  /// Date when the profile was created
  final DateTime createdAt;
  
  /// Date when the profile was last updated
  final DateTime updatedAt;
  
  /// Privacy settings for email visibility
  final String showEmail;
  
  /// Privacy settings for location visibility
  final String showLocation;
  
  /// Privacy settings for birthdate visibility
  final String showBirthdate;
  
  /// Privacy settings for profession visibility
  final String showProfession;
  
  /// Privacy settings for journey info visibility
  final String showJourneyInfo;
  
  /// Privacy settings for relationship status visibility
  final String showRelationshipStatus;
  
  /// Constructor
  const UserProfile({
    required this.user,
    required this.fullName,
    required this.userName,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    this.coverImageUrl,
    this.gender,
    this.birthdate,
    this.currentCity,
    this.profession,
    this.industry,
    this.originCountry,
    this.migrationStage,
    this.destinationCity,
    this.relationshipStatus,
    this.isMentor = false,
    this.hasCompletedOnboarding = false,
    required this.createdAt,
    required this.updatedAt,
    this.showEmail = 'private',
    this.showLocation = 'private',
    this.showBirthdate = 'private',
    this.showProfession = 'private',
    this.showJourneyInfo = 'private',
    this.showRelationshipStatus = 'private',
  });
  
  /// Create a copy of this profile with the given fields replaced with new values
  UserProfile copyWith({
    User? user,
    String? fullName,
    String? userName,
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? coverImageUrl,
    String? gender,
    DateTime? birthdate,
    String? currentCity,
    String? profession,
    String? industry,
    String? originCountry,
    String? migrationStage,
    String? destinationCity,
    String? relationshipStatus,
    bool? isMentor,
    bool? hasCompletedOnboarding,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? showEmail,
    String? showLocation,
    String? showBirthdate,
    String? showProfession,
    String? showJourneyInfo,
    String? showRelationshipStatus,
  }) {
    return UserProfile(
      user: user ?? this.user,
      fullName: fullName ?? this.fullName,
      userName: userName ?? this.userName,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      gender: gender ?? this.gender,
      birthdate: birthdate ?? this.birthdate,
      currentCity: currentCity ?? this.currentCity,
      profession: profession ?? this.profession,
      industry: industry ?? this.industry,
      originCountry: originCountry ?? this.originCountry,
      migrationStage: migrationStage ?? this.migrationStage,
      destinationCity: destinationCity ?? this.destinationCity,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      isMentor: isMentor ?? this.isMentor,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      showEmail: showEmail ?? this.showEmail,
      showLocation: showLocation ?? this.showLocation,
      showBirthdate: showBirthdate ?? this.showBirthdate,
      showProfession: showProfession ?? this.showProfession,
      showJourneyInfo: showJourneyInfo ?? this.showJourneyInfo,
      showRelationshipStatus: showRelationshipStatus ?? this.showRelationshipStatus,
    );
  }
  
  @override
  List<Object?> get props => [
    user,
    fullName,
    userName,
    displayName,
    bio,
    avatarUrl,
    coverImageUrl,
    gender,
    birthdate,
    currentCity,
    profession,
    industry,
    originCountry,
    migrationStage,
    destinationCity,
    relationshipStatus,
    isMentor,
    hasCompletedOnboarding,
    createdAt,
    updatedAt,
    showEmail,
    showLocation,
    showBirthdate,
    showProfession,
    showJourneyInfo,
    showRelationshipStatus,
  ];
}
