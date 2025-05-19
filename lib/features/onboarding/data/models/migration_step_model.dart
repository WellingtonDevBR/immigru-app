import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';

/// Model class for migration step
class MigrationStepModel extends MigrationStep {
  /// Constructor
  const MigrationStepModel({
    required super.id,
    required super.countryId,
    required super.countryCode,
    required super.countryName,
    required super.visaTypeId,
    required super.visaTypeName,
    super.startDate,
    super.endDate,
    super.isCurrentLocation = false,
    super.isTargetCountry = false,
    super.isBirthCountry = false,
    required super.order,
  });

  /// Create from JSON
  factory MigrationStepModel.fromJson(Map<String, dynamic> json) {
    // Log the incoming JSON for debugging
    
    // Extract the ID, handling both string and integer IDs
    final id = json['Id']?.toString() ?? json['id']?.toString() ?? '';
    
    // Handle different country ID formats
    String countryId = '';
    if (json.containsKey('CountryId')) {
      // Server-side format
      countryId = json['CountryId']?.toString() ?? '';
    } else if (json.containsKey('countryId')) {
      // Client-side format
      countryId = json['countryId']?.toString() ?? '';
    } else if (json.containsKey('Country') && json['Country'] is Map) {
      // Handle nested country data
      countryId = json['Country']['Id']?.toString() ?? '';
    }
    
    // Handle different visa ID formats
    int visaTypeId = 0;
    if (json.containsKey('VisaId')) {
      // Server-side format
      visaTypeId = int.tryParse(json['VisaId']?.toString() ?? '0') ?? 0;
    } else if (json.containsKey('visaId')) {
      // Server-side alternative format
      visaTypeId = int.tryParse(json['visaId']?.toString() ?? '0') ?? 0;
    } else if (json.containsKey('visaTypeId')) {
      // Client-side format
      visaTypeId = int.tryParse(json['visaTypeId']?.toString() ?? '0') ?? 0;
    }
    
    // Handle nested country and visa data
    String countryName = '';
    if (json.containsKey('countryName')) {
      countryName = json['countryName'] ?? '';
    } else if (json.containsKey('CountryName')) {
      countryName = json['CountryName'] ?? '';
    } else if (json.containsKey('Country') && json['Country'] is Map) {
      // Handle nested country data
      countryName = json['Country']['Name'] ?? '';
    }
    
    String visaName = '';
    if (json.containsKey('visaTypeName')) {
      visaName = json['visaTypeName'] ?? '';
    } else if (json.containsKey('VisaName')) {
      visaName = json['VisaName'] ?? '';
    } else if (json.containsKey('Visa') && json['Visa'] is Map) {
      // Handle nested visa data
      visaName = json['Visa']['VisaName'] ?? '';
    }
    
    // Get country code - CRITICAL for proper country selection when editing
    String countryCode = '';
    if (json.containsKey('countryCode') && json['countryCode'] != null) {
      countryCode = json['countryCode'];
    } else if (json.containsKey('CountryCode') && json['CountryCode'] != null) {
      countryCode = json['CountryCode'];
    } else if (json.containsKey('Country') && json['Country'] is Map && json['Country']['IsoCode'] != null) {
      // Extract from nested country object
      countryCode = json['Country']['IsoCode'];
    } else {
      // Try to find the country code by looking up the country by ID or name
      // This is a fallback for when the country code is not directly available

      
      // For Australia, we know the code is AU
      if (countryName.toLowerCase() == 'australia') {
        countryCode = 'AU';
      }
      // For Japan, we know the code is JP
      else if (countryName.toLowerCase() == 'japan') {
        countryCode = 'JP';
      }
      // For other common countries
      else if (countryName.toLowerCase() == 'united states') {
        countryCode = 'US';
      }
      else if (countryName.toLowerCase() == 'canada') {
        countryCode = 'CA';
      }
      else if (countryName.toLowerCase() == 'united kingdom') {
        countryCode = 'GB';
      }
      else if (countryName.toLowerCase() == 'brazil') {
        countryCode = 'BR';
      }
    }
    

    
    // Extract dates
    DateTime? startDate;
    if (json.containsKey('ArrivedAt') && json['ArrivedAt'] != null) {
      startDate = DateTime.parse(json['ArrivedAt']);
    } else if (json.containsKey('arrivedDate') && json['arrivedDate'] != null) {
      startDate = DateTime.parse(json['arrivedDate']);
    }
    
    DateTime? endDate;
    if (json.containsKey('LeftAt') && json['LeftAt'] != null) {
      endDate = DateTime.parse(json['LeftAt']);
    } else if (json.containsKey('leftDate') && json['leftDate'] != null) {
      endDate = DateTime.parse(json['leftDate']);
    }
    
    // Extract boolean flags
    bool isCurrentLocation = false;
    if (json.containsKey('IsCurrent')) {
      isCurrentLocation = json['IsCurrent'] == true;
    } else if (json.containsKey('isCurrentLocation')) {
      isCurrentLocation = json['isCurrentLocation'] == true;
    } else if (json.containsKey('isCurrent')) {
      isCurrentLocation = json['isCurrent'] == true;
    }
    
    // CRITICAL: Check all possible field names for target country flag
    bool isTargetCountry = false;
    // Debug: Log all possible target flags in the JSON

    
    if (json.containsKey('isTargetCountry')) {
      isTargetCountry = json['isTargetCountry'] == true;
    } else if (json.containsKey('IsTarget')) {
      isTargetCountry = json['IsTarget'] == true;
    } else if (json.containsKey('isTarget')) {
      isTargetCountry = json['isTarget'] == true;
    } else if (json.containsKey('isTargetDestination')) {
      isTargetCountry = json['isTargetDestination'] == true;
    }
    
    // Debug: Log the extracted target flag

    
    // Check for birth country flag
    bool isBirthCountry = false;
    if (json.containsKey('IsBirthCountry')) {
      isBirthCountry = json['IsBirthCountry'] == true;
    } else if (json.containsKey('isBirthCountry')) {
      isBirthCountry = json['isBirthCountry'] == true;
    } else {
      // Check if ID starts with 'birth_' as a fallback
      isBirthCountry = id.startsWith('birth_');
    }
    
    // Handle order field
    int order = 0;
    if (json.containsKey('order')) {
      order = int.tryParse(json['order'].toString()) ?? 0;
    } else if (json.containsKey('Order')) {
      order = int.tryParse(json['Order'].toString()) ?? 0;
    }
    
    return MigrationStepModel(
      id: id,
      countryId: int.tryParse(countryId) ?? 0, // Convert String to int for countryId
      countryCode: countryCode,
      countryName: countryName,
      visaTypeId: visaTypeId,
      visaTypeName: visaName,
      startDate: startDate,
      endDate: endDate,
      isCurrentLocation: isCurrentLocation,
      isTargetCountry: isTargetCountry,
      isBirthCountry: isBirthCountry, // Use the isBirthCountry flag
      order: order,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'countryId': countryId,
      'countryCode': countryCode,
      'countryName': countryName,
      'visaTypeId': visaTypeId,
      'visaTypeName': visaTypeName,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isCurrentLocation': isCurrentLocation,
      'isTargetCountry': isTargetCountry,
      'order': order,
    };
  }

  /// Convert to edge function format
  Map<String, dynamic> toEdgeFunctionFormat() {
    // Convert to the format expected by the edge function
    return {
      // Use numeric ID if possible, otherwise use the string ID
      'id': int.tryParse(id) ?? id,
      'CountryId': countryId,
      'countryId': countryId, // Include both formats for compatibility
      'CountryName': countryName,
      'countryName': countryName, // Include both formats for compatibility
      'VisaId': visaTypeId,
      'visaId': visaTypeId, // Include both formats for compatibility
      'VisaName': visaTypeName,
      'visaName': visaTypeName, // Include both formats for compatibility
      // Map date fields to the expected format
      'ArrivedAt': startDate?.toIso8601String(),
      'arrivedDate': startDate?.toIso8601String(), // Include both formats for compatibility
      'LeftAt': endDate?.toIso8601String(),
      'leftDate': endDate?.toIso8601String(), // Include both formats for compatibility
      // Map boolean flags to the expected format
      // CRITICAL: Include all possible variations of the current and target flags
      'IsCurrent': isCurrentLocation,
      'isCurrentLocation': isCurrentLocation,
      'isCurrent': isCurrentLocation,
      
      // CRITICAL: Ensure target country flag is sent in all possible formats
      'IsTarget': isTargetCountry,
      'isTargetCountry': isTargetCountry,
      'isTarget': isTargetCountry,
      'isTargetDestination': isTargetCountry,
      // Include order field
      'Order': order,
      'order': order, // Include both formats for compatibility
      // Add additional fields required by the server
      'WasSuccessful': true, // Default to true
      'wasSuccessful': true, // Include both formats for compatibility
    };
  }

  /// Create from entity
  factory MigrationStepModel.fromEntity(MigrationStep entity) {
    return MigrationStepModel(
      id: entity.id,
      countryId: entity.countryId,
      countryCode: entity.countryCode,
      countryName: entity.countryName,
      visaTypeId: entity.visaTypeId,
      visaTypeName: entity.visaTypeName,
      startDate: entity.startDate,
      endDate: entity.endDate,
      isCurrentLocation: entity.isCurrentLocation,
      order: entity.order,
    );
  }

  /// Create a list of models from a list of entities
  static List<MigrationStepModel> fromEntityList(List<MigrationStep> entities) {
    return entities.map((entity) => MigrationStepModel.fromEntity(entity)).toList();
  }
}
