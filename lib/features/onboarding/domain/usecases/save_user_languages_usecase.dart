import '../repositories/language_repository.dart';

/// Use case for saving user selected languages
class SaveUserLanguagesUseCase {
  final LanguageRepository repository;

  SaveUserLanguagesUseCase(this.repository);

  /// Execute the use case
  /// 
  /// [languageIds] is a list of language IDs to save
  Future<bool> call(List<int> languageIds) => repository.saveUserLanguages(languageIds);
}
