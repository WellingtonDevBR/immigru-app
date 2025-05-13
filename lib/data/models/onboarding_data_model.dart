import 'package:immigru/domain/entities/onboarding_data.dart';
import 'package:immigru/data/models/visa_model.dart';

/// Data model for onboarding information
class OnboardingDataModel extends OnboardingData {
  const OnboardingDataModel({
    super.birthCountry,
    super.currentStatus,
    super.migrationSteps = const [],
    super.profession,
    super.isCompleted = false,
    super.languages = const [],
    super.interests = const [],
    super.fullName,
    super.displayName,
    super.bio,
    super.profilePhotoUrl,
    super.currentLocation,
    super.destinationCity,
    super.isPrivate,
  });

  /// Create a model from a JSON map
  factory OnboardingDataModel.fromJson(Map<String, dynamic> json) {
    return OnboardingDataModel(
      birthCountry: json['birthCountry'],
      currentStatus: json['currentStatus'],
      migrationSteps: json['migrationSteps'] != null
          ? List<MigrationStepModel>.from(
              (json['migrationSteps'] as List).map(
                (step) => MigrationStepModel.fromJson(step),
              ),
            )
          : [],
      profession: json['profession'],
      isCompleted: json['isCompleted'] ?? false,
      languages: json['languages'] != null
          ? List<String>.from(json['languages'])
          : [],
      interests: json['interests'] != null
          ? List<String>.from(json['interests'])
          : [],
      fullName: json['fullName'],
      displayName: json['displayName'],
      bio: json['bio'],
      profilePhotoUrl: json['profilePhotoUrl'],
      currentLocation: json['currentLocation'],
      destinationCity: json['destinationCity'],
      isPrivate: json['isPrivate'] ?? false,
    );
  }

  /// Convert model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'birthCountry': birthCountry,
      'currentStatus': currentStatus,
      'migrationSteps': migrationSteps
          .map((step) => (step as MigrationStepModel).toJson())
          .toList(),
      'profession': profession,
      'isCompleted': isCompleted,
      'languages': languages,
      'interests': interests,
      'fullName': fullName,
      'displayName': displayName,
      'bio': bio,
      'profilePhotoUrl': profilePhotoUrl,
      'currentLocation': currentLocation,
      'destinationCity': destinationCity,
      'isPrivate': isPrivate,
    };
  }

  /// Create a model from a domain entity
  factory OnboardingDataModel.fromEntity(OnboardingData entity) {
    return OnboardingDataModel(
      birthCountry: entity.birthCountry,
      currentStatus: entity.currentStatus,
      migrationSteps: entity.migrationSteps
          .map((step) => MigrationStepModel.fromEntity(step))
          .toList(),
      profession: entity.profession,
      isCompleted: entity.isCompleted,
      languages: entity.languages,
      interests: entity.interests,
      fullName: entity.fullName,
      displayName: entity.displayName,
      bio: entity.bio,
      profilePhotoUrl: entity.profilePhotoUrl,
      currentLocation: entity.currentLocation,
      destinationCity: entity.destinationCity,
      isPrivate: entity.isPrivate,
    );
  }
}

/// Data model for migration step information
class MigrationStepModel extends MigrationStep {
  const MigrationStepModel({
    super.id,
    super.order,
    required super.countryId,
    required super.countryName,
    super.visaId,
    super.visaName = '',
    super.arrivedDate,
    super.leftDate,
    super.isCurrentLocation = false,
    super.isTargetDestination = false,
    super.notes,
    super.migrationReason,
    super.wasSuccessful = true,
  });

  /// Create a model from a JSON map
  factory MigrationStepModel.fromJson(Map<String, dynamic> json) {
    return MigrationStepModel(
      id: json['Id'] ?? json['id'],
      order: json['Order'] ?? json['order'],
      countryId: json['CountryId'] ?? json['countryId'],
      countryName: json['countryName'] ?? '', // This will need to be populated separately
      visaId: json['VisaId'] ?? json['visaId'],
      visaName: json['visaName'] ?? '', // This will need to be populated separately
      arrivedDate: json['ArrivedAt'] != null || json['arrivedAt'] != null
          ? DateTime.parse(json['ArrivedAt'] ?? json['arrivedAt'])
          : null,
      leftDate: json['LeftAt'] != null || json['leftAt'] != null
          ? DateTime.parse(json['LeftAt'] ?? json['leftAt'])
          : null,
      isCurrentLocation: json['IsCurrent'] ?? json['isCurrent'] ?? false,
      isTargetDestination: json['IsTarget'] ?? json['isTarget'] ?? false,
      notes: json['Notes'] ?? json['notes'],
      migrationReason: MigrationReasonUtils.fromString(
          json['MigrationReason'] ?? json['migrationReason']),
      wasSuccessful: json['WasSuccessful'] ?? json['wasSuccessful'] ?? true,
    );
  }

  /// Convert model to a JSON map
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'CountryId': countryId,
      'ArrivedAt': arrivedDate?.toIso8601String(),
      'LeftAt': leftDate?.toIso8601String(),
      'IsCurrent': isCurrentLocation,
      'IsTarget': isTargetDestination,
      'Notes': notes,
      'WasSuccessful': wasSuccessful,
    };
    
    if (id != null) data['Id'] = id;
    if (order != null) data['Order'] = order;
    if (visaId != null) data['VisaId'] = visaId;
    if (migrationReason != null) data['MigrationReason'] = migrationReason!.toJson();
    
    return data;
  }

  /// Create a model from a domain entity
  factory MigrationStepModel.fromEntity(MigrationStep entity) {
    return MigrationStepModel(
      id: entity.id,
      order: entity.order,
      countryId: entity.countryId,
      countryName: entity.countryName,
      visaId: entity.visaId,
      visaName: entity.visaName,
      arrivedDate: entity.arrivedDate,
      leftDate: entity.leftDate,
      isCurrentLocation: entity.isCurrentLocation,
      isTargetDestination: entity.isTargetDestination,
      notes: entity.notes,
      migrationReason: entity.migrationReason,
      wasSuccessful: entity.wasSuccessful,
    );
  }
}
