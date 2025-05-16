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
    required super.order,
  });

  /// Create from JSON
  factory MigrationStepModel.fromJson(Map<String, dynamic> json) {
    // Log the incoming JSON for debugging
    print('Creating MigrationStepModel from JSON: $json');
    
    // Handle different ID formats from the server
    String id = '';
    if (json.containsKey('Id')) {
      // Server-side ID format
      id = json['Id']?.toString() ?? '';
    } else if (json.containsKey('id')) {
      // Client-side ID format
      id = json['id']?.toString() ?? '';
    }
    
    // Handle different country ID formats
    int countryId = 0;
    if (json.containsKey('CountryId')) {
      // Server-side format
      countryId = int.tryParse(json['CountryId']?.toString() ?? '0') ?? 0;
    } else if (json.containsKey('countryId')) {
      // Client-side format
      countryId = int.tryParse(json['countryId']?.toString() ?? '0') ?? 0;
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
    
    // Handle date fields
    DateTime? startDate;
    if (json['startDate'] != null) {
      try {
        startDate = DateTime.parse(json['startDate']);
      } catch (e) {
        print('Error parsing startDate: ${json['startDate']}');
      }
    } else if (json['ArrivedAt'] != null) {
      try {
        startDate = DateTime.parse(json['ArrivedAt']);
      } catch (e) {
        print('Error parsing ArrivedAt: ${json['ArrivedAt']}');
      }
    }
    
    DateTime? endDate;
    if (json['endDate'] != null) {
      try {
        endDate = DateTime.parse(json['endDate']);
      } catch (e) {
        print('Error parsing endDate: ${json['endDate']}');
      }
    } else if (json['LeftAt'] != null) {
      try {
        endDate = DateTime.parse(json['LeftAt']);
      } catch (e) {
        print('Error parsing LeftAt: ${json['LeftAt']}');
      }
    }
    
    // Handle boolean flags
    bool isCurrentLocation = false;
    if (json.containsKey('isCurrentLocation')) {
      isCurrentLocation = json['isCurrentLocation'] == true;
    } else if (json.containsKey('IsCurrent')) {
      isCurrentLocation = json['IsCurrent'] == true;
    }
    
    bool isTargetCountry = false;
    if (json.containsKey('isTargetCountry')) {
      isTargetCountry = json['isTargetCountry'] == true;
    } else if (json.containsKey('IsTarget')) {
      isTargetCountry = json['IsTarget'] == true;
    }
    
    // Handle order field
    int order = 0;
    if (json.containsKey('order')) {
      order = int.tryParse(json['order'].toString()) ?? 0;
    } else if (json.containsKey('Order')) {
      order = int.tryParse(json['Order'].toString()) ?? 0;
    }
    
    // Get country code
    String countryCode = json['countryCode'] ?? json['CountryCode'] ?? '';
    
    return MigrationStepModel(
      id: id,
      countryId: countryId,
      countryCode: countryCode,
      countryName: countryName,
      visaTypeId: visaTypeId,
      visaTypeName: visaName,
      startDate: startDate,
      endDate: endDate,
      isCurrentLocation: isCurrentLocation,
      isTargetCountry: isTargetCountry,
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
      'IsCurrent': isCurrentLocation,
      'isCurrentLocation': isCurrentLocation, // Include both formats for compatibility
      'IsTarget': isTargetCountry,
      'isTargetCountry': isTargetCountry, // Include both formats for compatibility
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
