import 'package:immigru/domain/entities/language.dart';

/// Repository interface for language-related operations
abstract class LanguageRepository {
  /// Get a list of all available languages
  Future<List<Language>> getLanguages();
}
