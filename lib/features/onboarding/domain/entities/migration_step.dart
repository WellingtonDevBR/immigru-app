import 'package:equatable/equatable.dart';

/// Represents a step in the user's migration journey
class MigrationStep extends Equatable {
  /// Unique identifier for the step
  final String id;

  /// Country ID from the database
  final int countryId;

  /// ISO code of the country
  final String countryCode;

  /// Name of the country
  final String countryName;

  /// Visa type ID
  final int visaTypeId;

  /// Name of the visa type
  final String visaTypeName;

  /// Start date of residence in this country
  final DateTime? startDate;

  /// End date of residence in this country (null if still living there)
  final DateTime? endDate;

  /// Whether this is the user's current location
  final bool isCurrentLocation;
  
  /// Whether this is the user's target destination country
  final bool isTargetCountry;

  /// Whether this is the user's birth country
  final bool isBirthCountry;

  /// Order of this step in the migration journey
  final int order;

  /// Constructor
  const MigrationStep({
    required this.id,
    required this.countryId,
    required this.countryCode,
    required this.countryName,
    required this.visaTypeId,
    required this.visaTypeName,
    this.startDate,
    this.endDate,
    this.isCurrentLocation = false,
    this.isTargetCountry = false,
    this.isBirthCountry = false,
    required this.order,
  });

  /// Create a copy of this step with updated values
  MigrationStep copyWith({
    String? id,
    int? countryId,
    String? countryCode,
    String? countryName,
    int? visaTypeId,
    String? visaTypeName,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrentLocation,
    bool? isTargetCountry,
    bool? isBirthCountry,
    int? order,
  }) {
    // CRITICAL: Log the target country flag to debug preservation issues
    print('MigrationStep.copyWith: Original isTargetCountry=$isTargetCountry, this.isTargetCountry=${this.isTargetCountry}');
    
    final result = MigrationStep(
      id: id ?? this.id,
      countryId: countryId ?? this.countryId,
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      visaTypeId: visaTypeId ?? this.visaTypeId,
      visaTypeName: visaTypeName ?? this.visaTypeName,
      startDate: startDate ?? this.startDate,
      // CRITICAL: For endDate, we need to handle null explicitly
      // If endDate is explicitly set to null, use null, otherwise use the provided value or the current value
      endDate: endDate, // This allows setting endDate to null
      isCurrentLocation: isCurrentLocation ?? this.isCurrentLocation,
      // CRITICAL: Preserve the target country flag
      isTargetCountry: isTargetCountry ?? this.isTargetCountry,
      isBirthCountry: isBirthCountry ?? this.isBirthCountry,
      order: order ?? this.order,
    );
    
    // Log the result for debugging
    print('MigrationStep.copyWith: Result isTargetCountry=${result.isTargetCountry}');
    
    return result;
  }

  /// Create an empty migration step
  factory MigrationStep.empty() {
    return MigrationStep(
      id: '',
      countryId: 0,
      countryCode: '',
      countryName: '',
      visaTypeId: 0,
      visaTypeName: '',
      isCurrentLocation: false,
      isTargetCountry: false,
      isBirthCountry: false,
      order: 0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        countryId,
        countryCode,
        countryName,
        visaTypeId,
        visaTypeName,
        startDate,
        endDate,
        isCurrentLocation,
        isTargetCountry,
        isBirthCountry,
        order,
      ];
}
