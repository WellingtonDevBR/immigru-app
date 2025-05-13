import 'package:immigru/domain/entities/language.dart';

/// Repository interface for language-related operations
abstract class LanguageRepository {
  /// Get a list of all available languages
  Future<List<Language>> getLanguages();
  
  /// Save user languages
  /// 
  /// [languageIds] is a list of language IDs to save
  Future<bool> saveUserLanguages(List<int> languageIds);
  
  /// Get user languages
  Future<List<Language>> getUserLanguages();
}
