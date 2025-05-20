import '../../domain/entities/language.dart';

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
    // Handle nested Language object from user-language function
    if (json.containsKey('Language')) {
      final languageData = json['Language'] as Map<String, dynamic>;
      return LanguageModel(
        id: languageData['Id'] as int,
        isoCode: languageData['Code'] as String,
        name: languageData['Name'] as String,
        nativeName: languageData['NativeName'] as String?,
        isActive: true, // Assume active if it's in user languages
      );
    }
    
    // Direct language object from get-languages function
    return LanguageModel(
      id: json['Id'] as int,
      isoCode: json['Code'] as String, // Table uses 'Code' instead of 'IsoCode'
      name: json['Name'] as String,
      nativeName: json['NativeName'] as String?,
      isActive: json['IsActive'] as bool? ?? true,
    );
  }

  /// Convert LanguageModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Code': isoCode, // Use 'Code' instead of 'IsoCode' to match table structure
      'Name': name,
      'NativeName': nativeName,
      'IsActive': isActive,
    };
  }
}
