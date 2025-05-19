import 'package:equatable/equatable.dart';
import 'visa.dart'; // Import for MigrationReason enum

/// Entity representing user onboarding data
class OnboardingData extends Equatable {
  final String? birthCountry;
  final String? currentStatus;
  final List<MigrationStep> migrationSteps;
  final String? profession;
  final List<String> languages;
  final List<String> interests;
  
  // Profile data
  final String? fullName;
  final String? displayName;
  final String? bio;
  final String? currentLocation;
  final String? destinationCity;
  final String? profilePhotoUrl;
  final bool isPrivate;
  
  // ImmiGroves data
  final List<String> selectedImmiGroves;
  
  final bool isCompleted;

  const OnboardingData({
    this.birthCountry,
    this.currentStatus,
    this.migrationSteps = const [],
    this.profession,
    this.languages = const [],
    this.interests = const [],
    this.fullName,
    this.displayName,
    this.bio,
    this.currentLocation,
    this.destinationCity,
    this.profilePhotoUrl,
    this.isPrivate = false,
    this.selectedImmiGroves = const [],
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
    String? fullName,
    String? displayName,
    String? bio,
    String? currentLocation,
    String? destinationCity,
    String? profilePhotoUrl,
    bool? isPrivate,
    List<String>? selectedImmiGroves,
    bool? isCompleted,
  }) {
    return OnboardingData(
      birthCountry: birthCountry ?? this.birthCountry,
      currentStatus: currentStatus ?? this.currentStatus,
      migrationSteps: migrationSteps ?? this.migrationSteps,
      profession: profession ?? this.profession,
      languages: languages ?? this.languages,
      interests: interests ?? this.interests,
      fullName: fullName ?? this.fullName,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      currentLocation: currentLocation ?? this.currentLocation,
      destinationCity: destinationCity ?? this.destinationCity,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      isPrivate: isPrivate ?? this.isPrivate,
      selectedImmiGroves: selectedImmiGroves ?? this.selectedImmiGroves,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Create an empty onboarding data object
  factory OnboardingData.empty() => const OnboardingData(
        fullName: '',
        displayName: '',
        bio: '',
        currentLocation: '',
        destinationCity: '',
        profilePhotoUrl: '',
        isPrivate: false,
        selectedImmiGroves: [],
      );

  @override
  List<Object?> get props => [
        birthCountry,
        currentStatus,
        migrationSteps,
        profession,
        languages,
        interests,
        fullName,
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
    // Ensure countryId is a number
    dynamic countryIdValue;
    if (countryId is int) {
      countryIdValue = countryId;
    } else if (countryId is String) {
      try {
        countryIdValue = countryId.toString();
      } catch (e) {
        // Log error but continue
        print('Error parsing countryId: $e');
        countryIdValue = countryId; // Keep original value as fallback
      }
    } else {
      countryIdValue = countryId; // Keep original value as fallback
    }
      
    // Ensure visaId is a number if present
    dynamic visaIdValue;
    if (visaId != null) {
      if (visaId is int) {
        visaIdValue = visaId;
      } else if (visaId is String) {
        try {
          visaIdValue = visaId.toString();
        } catch (e) {
          // Log error but continue
          print('Error parsing visaId: $e');
          visaIdValue = visaId; // Keep original value as fallback
        }
      } else {
        visaIdValue = visaId; // Keep original value as fallback
      }
    }
    
    return {
      'id': id,
      'order': order,
      'countryId': countryIdValue ?? countryId,
      'countryName': countryName,
      'visaId': visaIdValue ?? visaId,
      'visaName': visaName,
      'arrivedDate': arrivedDate?.toIso8601String(),
      'leftDate': leftDate?.toIso8601String(),
      'isCurrentLocation': isCurrentLocation == true, // Ensure boolean conversion
      'isTargetDestination': isTargetDestination == true, // Ensure boolean conversion
      'notes': notes,
      'migrationReason': migrationReason?.name,
      'wasSuccessful': wasSuccessful == true, // Ensure boolean conversion
      // Add fields expected by the edge function
      'isDeleted': false, // Add this field to indicate it's not a deletion request
    };
  }
}
