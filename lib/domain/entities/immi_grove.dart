import 'package:equatable/equatable.dart';

/// Entity representing an ImmiGrove community
class ImmiGrove extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? type;
  final int? countryId;
  final int? visaId;
  final int? languageId;
  final bool isPublic;
  final String createdBy;
  final String? coverImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? memberCount;

  const ImmiGrove({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.type,
    this.countryId,
    this.visaId,
    this.languageId,
    required this.isPublic,
    required this.createdBy,
    this.coverImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.memberCount,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        type,
        countryId,
        visaId,
        languageId,
        isPublic,
        createdBy,
        coverImageUrl,
        createdAt,
        updatedAt,
        memberCount,
      ];
}
