import 'package:immigru/domain/entities/immi_grove.dart';

/// Model class for ImmiGrove data from Supabase
class ImmiGroveModel extends ImmiGrove {
  const ImmiGroveModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
    super.type,
    super.countryId,
    super.visaId,
    super.languageId,
    required super.isPublic,
    required super.createdBy,
    super.coverImageUrl,
    required super.createdAt,
    required super.updatedAt,
    super.memberCount,
  });

  /// Create a model from a JSON map
  factory ImmiGroveModel.fromJson(Map<String, dynamic> json) {
    return ImmiGroveModel(
      id: json['Id'] ?? '',
      name: json['Name'] ?? 'Unknown Community',
      slug: json['Slug'] ?? '',
      description: json['Description'],
      type: json['Type'],
      countryId: json['CountryId'],
      visaId: json['VisaId'],
      languageId: json['LanguageId'],
      isPublic: json['IsPublic'] ?? true,
      createdBy: json['CreatedBy'] ?? '',
      coverImageUrl: json['CoverImageUrl'],
      createdAt: json['CreatedAt'] != null ? DateTime.parse(json['CreatedAt']) : DateTime.now(),
      updatedAt: json['UpdatedAt'] != null ? DateTime.parse(json['UpdatedAt']) : DateTime.now(),
      memberCount: json['MemberCount'],
    );
  }

  /// Convert model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'Slug': slug,
      'Description': description,
      'Type': type,
      'CountryId': countryId,
      'VisaId': visaId,
      'LanguageId': languageId,
      'IsPublic': isPublic,
      'CreatedBy': createdBy,
      'CoverImageUrl': coverImageUrl,
      'CreatedAt': createdAt.toIso8601String(),
      'UpdatedAt': updatedAt.toIso8601String(),
      'MemberCount': memberCount,
    };
  }

  /// Create a model from an entity
  factory ImmiGroveModel.fromEntity(ImmiGrove entity) {
    return ImmiGroveModel(
      id: entity.id,
      name: entity.name,
      slug: entity.slug,
      description: entity.description,
      type: entity.type,
      countryId: entity.countryId,
      visaId: entity.visaId,
      languageId: entity.languageId,
      isPublic: entity.isPublic,
      createdBy: entity.createdBy,
      coverImageUrl: entity.coverImageUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      memberCount: entity.memberCount,
    );
  }
}
