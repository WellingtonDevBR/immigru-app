import 'package:equatable/equatable.dart';

/// Entity representing user onboarding data
class OnboardingData extends Equatable {
  final String? birthCountry;
  final String? currentStatus;
  final List<MigrationStep> migrationSteps;
  final String? profession;
  final bool isCompleted;

  const OnboardingData({
    this.birthCountry,
    this.currentStatus,
    this.migrationSteps = const [],
    this.profession,
    this.isCompleted = false,
  });

  /// Create a copy of this OnboardingData with the given fields replaced with new values
  OnboardingData copyWith({
    String? birthCountry,
    String? currentStatus,
    List<MigrationStep>? migrationSteps,
    String? profession,
    bool? isCompleted,
  }) {
    return OnboardingData(
      birthCountry: birthCountry ?? this.birthCountry,
      currentStatus: currentStatus ?? this.currentStatus,
      migrationSteps: migrationSteps ?? this.migrationSteps,
      profession: profession ?? this.profession,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Empty onboarding data
  factory OnboardingData.empty() => const OnboardingData();

  @override
  List<Object?> get props => [
        birthCountry,
        currentStatus,
        migrationSteps,
        profession,
        isCompleted,
      ];
}

/// Entity representing a step in the user's migration journey
class MigrationStep extends Equatable {
  final String country;
  final int year;
  final String status;
  final bool isCurrentLocation;
  final String? notes;

  const MigrationStep({
    required this.country,
    required this.year,
    this.status = '',
    this.isCurrentLocation = false,
    this.notes,
  });

  /// Create a copy of this MigrationStep with the given fields replaced with new values
  MigrationStep copyWith({
    String? country,
    int? year,
    String? status,
    bool? isCurrentLocation,
    String? notes,
  }) {
    return MigrationStep(
      country: country ?? this.country,
      year: year ?? this.year,
      status: status ?? this.status,
      isCurrentLocation: isCurrentLocation ?? this.isCurrentLocation,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        country,
        year,
        status,
        isCurrentLocation,
        notes,
      ];
}
