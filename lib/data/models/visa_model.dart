import 'package:immigru/domain/entities/visa.dart';

/// Model class for Visa entity
class VisaModel extends Visa {
  const VisaModel({
    required super.id,
    required super.countryId,
    required super.visaName,
    required super.visaCode,
    required super.type,
    super.pathwayToPR,
    super.allowsWork,
    required super.description,
    super.externalLink,
    super.isPublic,
  });

  /// Create a VisaModel from a JSON map
  factory VisaModel.fromJson(Map<String, dynamic> json) {
    return VisaModel(
      id: json['Id'] ?? json['id'],
      countryId: json['CountryId'] ?? json['countryId'],
      visaName: json['VisaName'] ?? json['visaName'],
      visaCode: json['VisaCode'] ?? json['visaCode'],
      type: json['Type'] ?? json['type'],
      pathwayToPR: json['PathwayToPR'] ?? json['pathwayToPR'] ?? false,
      allowsWork: json['AllowsWork'] ?? json['allowsWork'] ?? false,
      description: json['Description'] ?? json['description'],
      externalLink: json['ExternalLink'] ?? json['externalLink'],
      isPublic: json['IsPublic'] ?? json['isPublic'] ?? true,
    );
  }

  /// Convert this VisaModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'CountryId': countryId,
      'VisaName': visaName,
      'VisaCode': visaCode,
      'Type': type,
      'PathwayToPR': pathwayToPR,
      'AllowsWork': allowsWork,
      'Description': description,
      'ExternalLink': externalLink,
      'IsPublic': isPublic,
    };
  }
}

/// Extension to convert MigrationReason enum to/from string
extension MigrationReasonUtils on MigrationReason {
  static MigrationReason? fromString(String? value) {
    if (value == null) return null;
    
    return MigrationReason.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == value.toLowerCase(),
      orElse: () => MigrationReason.other,
    );
  }

  String toJson() {
    return toString().split('.').last.toLowerCase();
  }
}
