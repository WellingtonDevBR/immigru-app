import 'package:equatable/equatable.dart';

/// Entity representing a visa type
class Visa extends Equatable {
  final int id;
  final int countryId;
  final String visaName;
  final String visaCode;
  final String type;
  final bool pathwayToPR;
  final bool allowsWork;
  final String description;
  final String? externalLink;
  final bool isPublic;

  const Visa({
    required this.id,
    required this.countryId,
    required this.visaName,
    required this.visaCode,
    required this.type,
    this.pathwayToPR = false,
    this.allowsWork = false,
    required this.description,
    this.externalLink,
    this.isPublic = true,
  });

  /// Create a copy of this Visa with the given fields replaced with new values
  Visa copyWith({
    int? id,
    int? countryId,
    String? visaName,
    String? visaCode,
    String? type,
    bool? pathwayToPR,
    bool? allowsWork,
    String? description,
    String? externalLink,
    bool? isPublic,
  }) {
    return Visa(
      id: id ?? this.id,
      countryId: countryId ?? this.countryId,
      visaName: visaName ?? this.visaName,
      visaCode: visaCode ?? this.visaCode,
      type: type ?? this.type,
      pathwayToPR: pathwayToPR ?? this.pathwayToPR,
      allowsWork: allowsWork ?? this.allowsWork,
      description: description ?? this.description,
      externalLink: externalLink ?? this.externalLink,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  @override
  List<Object?> get props => [
        id,
        countryId,
        visaName,
        visaCode,
        type,
        pathwayToPR,
        allowsWork,
        description,
        externalLink,
        isPublic,
      ];
}

/// Enum representing migration reasons
enum MigrationReason {
  work,
  study,
  family,
  refugee,
  retirement,
  investment,
  lifestyle,
  other
}

/// Extension to convert MigrationReason enum to string
extension MigrationReasonExtension on MigrationReason {
  String get displayName {
    switch (this) {
      case MigrationReason.work:
        return 'Work';
      case MigrationReason.study:
        return 'Study';
      case MigrationReason.family:
        return 'Family';
      case MigrationReason.refugee:
        return 'Refugee/Safety';
      case MigrationReason.retirement:
        return 'Retirement';
      case MigrationReason.investment:
        return 'Investment';
      case MigrationReason.lifestyle:
        return 'Lifestyle';
      case MigrationReason.other:
        return 'Other';
    }
  }
}
