import 'package:equatable/equatable.dart';
import 'visa.dart';

/// Entity representing user onboarding data
class OnboardingData extends Equatable {
  final String? birthCountry;
  final String? currentStatus;
  final List<MigrationStep> migrationSteps;
  final String? profession;
  final List<String> languages;
  final List<String> interests;
  
  // Profile data
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? bio;
  final String? currentLocation;
  final String? destinationCity;
  final String? profilePhotoUrl;
  final bool isPrivate;
  
  final bool isCompleted;

  const OnboardingData({
    this.birthCountry,
    this.currentStatus,
    this.migrationSteps = const [],
    this.profession,
    this.languages = const [],
    this.interests = const [],
    this.firstName,
    this.lastName,
    this.displayName,
    this.bio,
    this.currentLocation,
    this.destinationCity,
    this.profilePhotoUrl,
    this.isPrivate = false,
    this.isCompleted = false,
  });

  /// Create a copy of this OnboardingData with the given fields replaced with new values
  OnboardingData copyWith({
    String? birthCountry,
    String? currentStatus,
    List<MigrationStep>? migrationSteps,
    String? profession,
    List<String>? languages,
    List<String>? interests,
    String? firstName,
    String? lastName,
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
      currentStatus: currentStatus ?? this.currentStatus,
      migrationSteps: migrationSteps ?? this.migrationSteps,
      profession: profession ?? this.profession,
      languages: languages ?? this.languages,
      interests: interests ?? this.interests,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      currentLocation: currentLocation ?? this.currentLocation,
      destinationCity: destinationCity ?? this.destinationCity,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      isPrivate: isPrivate ?? this.isPrivate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Create an empty onboarding data object
  factory OnboardingData.empty() => const OnboardingData(
        firstName: '',
        lastName: '',
        displayName: '',
        bio: '',
        currentLocation: '',
        destinationCity: '',
        profilePhotoUrl: '',
        isPrivate: false,
      );

  @override
  List<Object?> get props => [
        birthCountry,
        currentStatus,
        migrationSteps,
        profession,
        languages,
        interests,
        firstName,
        lastName,
        displayName,
        bio,
        currentLocation,
        destinationCity,
        profilePhotoUrl,
        isPrivate,
        isCompleted,
      ];
}

/// Entity representing a step in the user's migration journey
class MigrationStep extends Equatable {
  final int? id;
  final int? order;
  final int countryId;
  final String countryName; // For display purposes
  final int? visaId;
  final String visaName; // For display purposes
  final DateTime? arrivedDate;
  final DateTime? leftDate;
  final bool isCurrentLocation;
  final bool isTargetDestination;
  final String? notes;
  final MigrationReason? migrationReason;
  final bool wasSuccessful;

  const MigrationStep({
    this.id,
    this.order,
    required this.countryId,
    required this.countryName,
    this.visaId,
    this.visaName = '',
    this.arrivedDate,
    this.leftDate,
    this.isCurrentLocation = false,
    this.isTargetDestination = false,
    this.notes,
    this.migrationReason,
    this.wasSuccessful = true,
  });

  /// Create a copy of this MigrationStep with the given fields replaced with new values
  MigrationStep copyWith({
    int? id,
    int? order,
    int? countryId,
    String? countryName,
    int? visaId,
    String? visaName,
    DateTime? arrivedDate,
    DateTime? leftDate,
    bool? isCurrentLocation,
    bool? isTargetDestination,
    String? notes,
    MigrationReason? migrationReason,
    bool? wasSuccessful,
  }) {
    return MigrationStep(
      id: id ?? this.id,
      order: order ?? this.order,
      countryId: countryId ?? this.countryId,
      countryName: countryName ?? this.countryName,
      visaId: visaId ?? this.visaId,
      visaName: visaName ?? this.visaName,
      arrivedDate: arrivedDate ?? this.arrivedDate,
      leftDate: leftDate ?? this.leftDate,
      isCurrentLocation: isCurrentLocation ?? this.isCurrentLocation,
      isTargetDestination: isTargetDestination ?? this.isTargetDestination,
      notes: notes ?? this.notes,
      migrationReason: migrationReason ?? this.migrationReason,
      wasSuccessful: wasSuccessful ?? this.wasSuccessful,
    );
  }

  @override
  List<Object?> get props => [
        countryId,
        countryName,
        visaId,
        visaName,
        arrivedDate,
        leftDate,
        isCurrentLocation,
        isTargetDestination,
        notes,
        migrationReason,
        wasSuccessful,
      ];
      
  /// Convert the migration step to a JSON map
  Map<String, dynamic> toJson() {
    // Log the migration step data before serialization
    print('Serializing migration step with visaId: $visaId');
    print('isCurrentLocation: $isCurrentLocation');
    print('isTargetDestination: $isTargetDestination');
    print('wasSuccessful: $wasSuccessful');
    
    return {
      'id': id,
      'order': order,
      'countryId': countryId,
      'countryName': countryName,
      'visaId': visaId, // Ensure this is sent correctly
      'visaName': visaName,
      'arrivedDate': arrivedDate?.toIso8601String(),
      'leftDate': leftDate?.toIso8601String(),
      'isCurrentLocation': isCurrentLocation == true, // Ensure boolean conversion
      'isTargetDestination': isTargetDestination == true, // Ensure boolean conversion
      'notes': notes,
      'migrationReason': migrationReason?.name,
      'wasSuccessful': wasSuccessful == true, // Ensure boolean conversion
    };
  }
}
