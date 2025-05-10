import 'package:immigru/domain/entities/onboarding_data.dart';

/// Data model for onboarding information
class OnboardingDataModel extends OnboardingData {
  const OnboardingDataModel({
    super.birthCountry,
    super.currentStatus,
    super.migrationSteps = const [],
    super.profession,
    super.isCompleted = false,
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
    );
  }
}

/// Data model for migration step information
class MigrationStepModel extends MigrationStep {
  const MigrationStepModel({
    required super.country,
    required super.year,
    super.status = '',
    super.isCurrentLocation = false,
    super.notes,
  });

  /// Create a model from a JSON map
  factory MigrationStepModel.fromJson(Map<String, dynamic> json) {
    return MigrationStepModel(
      country: json['country'],
      year: json['year'] ?? DateTime.now().year,
      status: json['status'] ?? '',
      isCurrentLocation: json['isCurrentLocation'] ?? false,
      notes: json['notes'],
    );
  }

  /// Convert model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'year': year,
      'status': status,
      'isCurrentLocation': isCurrentLocation,
      'notes': notes,
    };
  }

  /// Create a model from a domain entity
  factory MigrationStepModel.fromEntity(MigrationStep entity) {
    return MigrationStepModel(
      country: entity.country,
      year: entity.year,
      status: entity.status,
      isCurrentLocation: entity.isCurrentLocation,
      notes: entity.notes,
    );
  }
}
