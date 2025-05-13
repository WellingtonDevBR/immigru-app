import 'package:immigru/domain/entities/immi_grove.dart';

/// Model class for ImmiGrove data from Supabase
class ImmiGroveModel extends ImmiGrove {
  const ImmiGroveModel({
    required String id,
    required String name,
    required String slug,
    String? description,
    String? type,
    int? countryId,
    int? visaId,
    int? languageId,
    required bool isPublic,
    required String createdBy,
    String? coverImageUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? memberCount,
  }) : super(
          id: id,
          name: name,
          slug: slug,
          description: description,
          type: type,
          countryId: countryId,
          visaId: visaId,
          languageId: languageId,
          isPublic: isPublic,
          createdBy: createdBy,
          coverImageUrl: coverImageUrl,
          createdAt: createdAt,
          updatedAt: updatedAt,
          memberCount: memberCount,
        );

  /// Create a model from a JSON map
  factory ImmiGroveModel.fromJson(Map<String, dynamic> json) {
    return ImmiGroveModel(
      id: json['Id'],
      name: json['Name'],
      slug: json['Slug'],
      description: json['Description'],
      type: json['Type'],
      countryId: json['CountryId'],
      visaId: json['VisaId'],
      languageId: json['LanguageId'],
      isPublic: json['IsPublic'] ?? true,
      createdBy: json['CreatedBy'],
      coverImageUrl: json['CoverImageUrl'],
      createdAt: DateTime.parse(json['CreatedAt']),
      updatedAt: DateTime.parse(json['UpdatedAt']),
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
