import 'dart:convert';
import 'package:immigru/domain/entities/profile.dart';

/// Model class for Profile data
class ProfileModel extends Profile {
  const ProfileModel({
    super.id,
    super.userId,
    super.firstName,
    super.lastName,
    super.fullName,
    super.userName,
    super.displayName,
    super.bio,
    super.currentLocation,
    super.destinationCity,
    super.originCountry,
    super.migrationStage,
    super.profilePhotoUrl,
    super.coverImageUrl,
    super.profession,
    super.industry,
    super.gender,
    super.birthdate,
    super.relationshipStatus,
    super.languages,
    super.interests,
    super.migrationJourney,
    super.isMentor,
    super.showEmail,
    super.showLocation,
    super.showBirthdate,
    super.showProfession,
    super.showJourneyInfo,
    super.showRelationshipStatus,
  });

  /// Create a ProfileModel from a JSON map
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Convert visibility types from string to enum
    VisibilityType parseVisibility(String? value) {
      if (value == null) return VisibilityType.private;
      
      switch (value.toLowerCase()) {
        case 'public': return VisibilityType.public;
        case 'friends': return VisibilityType.friends;
        case 'connections': return VisibilityType.connections;
        case 'private':
        default: return VisibilityType.private;
      }
    }
    
    // Parse languages and interests from JSON
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is String) {
        try {
          // Try to parse as JSON string
          final List<dynamic> parsed = jsonDecode(value) as List<dynamic>;
          return parsed.map((e) => e.toString()).toList();
        } catch (_) {
          return [];
        }
      } else if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }
    
    // Parse birthdate
    DateTime? parseBirthdate(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return null;
        }
      }
      return null;
    }
    
    return ProfileModel(
      id: json['Id'] as String?,
      userId: json['UserId'] as String?,
      firstName: json['FirstName'] as String? ?? json['first_name'] as String?,
      lastName: json['LastName'] as String? ?? json['last_name'] as String?,
      fullName: json['FullName'] as String?,
      userName: json['UserName'] as String?,
      displayName: json['DisplayName'] as String? ?? json['display_name'] as String?,
      bio: json['Bio'] as String? ?? json['bio'] as String?,
      currentLocation: json['CurrentCity'] as String? ?? json['current_location'] as String?,
      destinationCity: json['DestinationCity'] as String? ?? json['destination_city'] as String?,
      originCountry: json['OriginCountry'] as String?,
      migrationStage: json['MigrationStage'] as String?,
      profilePhotoUrl: json['AvatarUrl'] as String? ?? json['profile_photo_url'] as String?,
      coverImageUrl: json['CoverImageUrl'] as String?,
      profession: json['Profession'] as String?,
      industry: json['Industry'] as String?,
      gender: json['Gender'] as String?,
      birthdate: parseBirthdate(json['Birthdate']),
      relationshipStatus: json['RelationshipStatus'] as String?,
      languages: parseStringList(json['Languages']),
      interests: parseStringList(json['Interests']),
      migrationJourney: json['MigrationJourney'] as String?,
      isMentor: json['IsMentor'] as bool? ?? false,
      showEmail: parseVisibility(json['ShowEmail'] as String?),
      showLocation: parseVisibility(json['ShowLocation'] as String?),
      showBirthdate: parseVisibility(json['ShowBirthdate'] as String?),
      showProfession: parseVisibility(json['ShowProfession'] as String?),
      showJourneyInfo: parseVisibility(json['ShowJourneyInfo'] as String?),
      showRelationshipStatus: parseVisibility(json['ShowRelationshipStatus'] as String?),
    );
  }
  
  /// Create a ProfileModel from a domain entity
  factory ProfileModel.fromEntity(Profile entity) {
    return ProfileModel(
      id: entity.id,
      userId: entity.userId,
      firstName: entity.firstName,
      lastName: entity.lastName,
      fullName: entity.fullName,
      userName: entity.userName,
      displayName: entity.displayName,
      bio: entity.bio,
      currentLocation: entity.currentLocation,
      destinationCity: entity.destinationCity,
      originCountry: entity.originCountry,
      migrationStage: entity.migrationStage,
      profilePhotoUrl: entity.profilePhotoUrl,
      coverImageUrl: entity.coverImageUrl,
      profession: entity.profession,
      industry: entity.industry,
      gender: entity.gender,
      birthdate: entity.birthdate,
      relationshipStatus: entity.relationshipStatus,
      languages: entity.languages,
      interests: entity.interests,
      migrationJourney: entity.migrationJourney,
      isMentor: entity.isMentor,
      showEmail: entity.showEmail,
      showLocation: entity.showLocation,
      showBirthdate: entity.showBirthdate,
      showProfession: entity.showProfession,
      showJourneyInfo: entity.showJourneyInfo,
      showRelationshipStatus: entity.showRelationshipStatus,
    );
  }

  /// Convert ProfileModel to a JSON map
  Map<String, dynamic> toJson() {
    // Convert visibility enum to string
    String visibilityToString(VisibilityType visibility) {
      switch (visibility) {
        case VisibilityType.public: return 'public';
        case VisibilityType.friends: return 'friends';
        case VisibilityType.connections: return 'connections';
        case VisibilityType.private:
          return 'private';
      }
    }
    
    return {
      'Id': id,
      'UserId': userId,
      'FirstName': firstName,
      'LastName': lastName,
      'FullName': fullName ?? (firstName != null && lastName != null ? '$firstName $lastName' : null),
      'UserName': userName,
      'DisplayName': displayName,
      'Bio': bio,
      'CurrentCity': currentLocation,
      'DestinationCity': destinationCity,
      'OriginCountry': originCountry,
      'MigrationStage': migrationStage,
      'AvatarUrl': profilePhotoUrl,
      'CoverImageUrl': coverImageUrl,
      'Profession': profession,
      'Industry': industry,
      'Gender': gender,
      'Birthdate': birthdate?.toIso8601String(),
      'RelationshipStatus': relationshipStatus,
      'Languages': languages.isNotEmpty ? languages : null,
      'Interests': interests.isNotEmpty ? interests : null,
      'MigrationJourney': migrationJourney,
      'IsMentor': isMentor,
      'ShowEmail': visibilityToString(showEmail),
      'ShowLocation': visibilityToString(showLocation),
      'ShowBirthdate': visibilityToString(showBirthdate),
      'ShowProfession': visibilityToString(showProfession),
      'ShowJourneyInfo': visibilityToString(showJourneyInfo),
      'ShowRelationshipStatus': visibilityToString(showRelationshipStatus),
    };
  }
}
