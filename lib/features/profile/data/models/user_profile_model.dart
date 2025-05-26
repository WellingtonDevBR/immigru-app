import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/features/profile/domain/entities/user_profile.dart';

/// Model class for UserProfile that handles JSON serialization/deserialization
class UserProfileModel extends UserProfile {
  /// Constructor
  const UserProfileModel({
    required super.user,
    required super.fullName,
    required super.userName,
    required super.displayName,
    super.bio,
    super.avatarUrl,
    super.coverImageUrl,
    super.gender,
    super.birthdate,
    super.currentCity,
    super.profession,
    super.industry,
    super.originCountry,
    super.migrationStage,
    super.destinationCity,
    super.relationshipStatus,
    super.isMentor,
    super.hasCompletedOnboarding,
    required super.createdAt,
    required super.updatedAt,
    super.showEmail,
    super.showLocation,
    super.showBirthdate,
    super.showProfession,
    super.showJourneyInfo,
    super.showRelationshipStatus,
  });

  /// Create a UserProfileModel from a JSON map
  factory UserProfileModel.fromJson(Map<String, dynamic> json, User user) {
    return UserProfileModel(
      user: user,
      fullName: json['FullName'] ?? '',
      userName: json['UserName'] ?? '',
      displayName: json['DisplayName'] ?? '',
      bio: json['Bio'],
      avatarUrl: json['AvatarUrl'],
      coverImageUrl: json['CoverImageUrl'],
      gender: json['Gender'],
      birthdate: json['Birthdate'] != null
          ? DateTime.parse(json['Birthdate'])
          : null,
      currentCity: json['CurrentCity'],
      profession: json['Profession'],
      industry: json['Industry'],
      originCountry: json['OriginCountry'],
      migrationStage: json['MigrationStage'],
      destinationCity: json['DestinationCity'],
      relationshipStatus: json['RelationshipStatus'],
      isMentor: json['IsMentor'] ?? false,
      hasCompletedOnboarding: json['HasCompletedOnboarding'] ?? false,
      createdAt: json['CreatedAt'] != null
          ? DateTime.parse(json['CreatedAt'])
          : DateTime.now(),
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.parse(json['UpdatedAt'])
          : DateTime.now(),
      showEmail: json['ShowEmail'] ?? 'private',
      showLocation: json['ShowLocation'] ?? 'private',
      showBirthdate: json['ShowBirthdate'] ?? 'private',
      showProfession: json['ShowProfession'] ?? 'private',
      showJourneyInfo: json['ShowJourneyInfo'] ?? 'private',
      showRelationshipStatus: json['ShowRelationshipStatus'] ?? 'private',
    );
  }



  /// Convert this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'UserId': user.id,
      'FullName': fullName,
      'UserName': userName,
      'DisplayName': displayName,
      'Bio': bio,
      'AvatarUrl': avatarUrl,
      'CoverImageUrl': coverImageUrl,
      'Gender': gender,
      'Birthdate': birthdate?.toIso8601String(),
      'CurrentCity': currentCity,
      'Profession': profession,
      'Industry': industry,
      'OriginCountry': originCountry,
      'MigrationStage': migrationStage,
      'DestinationCity': destinationCity,
      'RelationshipStatus': relationshipStatus,
      'IsMentor': isMentor,
      'HasCompletedOnboarding': hasCompletedOnboarding,
      'ShowEmail': showEmail,
      'ShowLocation': showLocation,
      'ShowBirthdate': showBirthdate,
      'ShowProfession': showProfession,
      'ShowJourneyInfo': showJourneyInfo,
      'ShowRelationshipStatus': showRelationshipStatus,
    };
  }

  /// Create a UserProfileModel from a UserProfile entity
  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      user: profile.user,
      fullName: profile.fullName,
      userName: profile.userName,
      displayName: profile.displayName,
      bio: profile.bio,
      avatarUrl: profile.avatarUrl,
      coverImageUrl: profile.coverImageUrl,
      gender: profile.gender,
      birthdate: profile.birthdate,
      currentCity: profile.currentCity,
      profession: profile.profession,
      industry: profile.industry,
      originCountry: profile.originCountry,
      migrationStage: profile.migrationStage,
      destinationCity: profile.destinationCity,
      relationshipStatus: profile.relationshipStatus,
      isMentor: profile.isMentor,
      hasCompletedOnboarding: profile.hasCompletedOnboarding,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
      showEmail: profile.showEmail,
      showLocation: profile.showLocation,
      showBirthdate: profile.showBirthdate,
      showProfession: profile.showProfession,
      showJourneyInfo: profile.showJourneyInfo,
      showRelationshipStatus: profile.showRelationshipStatus,
    );
  }
}
