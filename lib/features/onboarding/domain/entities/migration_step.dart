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
    required this.order,
  });

  /// Create a copy of this step with updated fields
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
    int? order,
  }) {
    return MigrationStep(
      id: id ?? this.id,
      countryId: countryId ?? this.countryId,
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      visaTypeId: visaTypeId ?? this.visaTypeId,
      visaTypeName: visaTypeName ?? this.visaTypeName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrentLocation: isCurrentLocation ?? this.isCurrentLocation,
      isTargetCountry: isTargetCountry ?? this.isTargetCountry,
      order: order ?? this.order,
    );
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
        order,
      ];
}
