import 'package:immigru/domain/entities/language.dart';

/// Model class for Language data
class LanguageModel extends Language {
  const LanguageModel({
    required super.id,
    required super.isoCode,
    required super.name,
    super.nativeName,
    super.isActive,
  });

  /// Create a LanguageModel from a JSON map
  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['Id'] as int,
      isoCode: json['IsoCode'] as String,
      name: json['Name'] as String,
      nativeName: json['NativeName'] as String?,
      isActive: json['IsActive'] as bool? ?? true,
    );
  }

  /// Convert LanguageModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'IsoCode': isoCode,
      'Name': name,
      'NativeName': nativeName,
      'IsActive': isActive,
    };
  }
}
