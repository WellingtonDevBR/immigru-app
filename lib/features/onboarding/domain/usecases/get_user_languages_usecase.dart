import '../entities/language.dart';
import '../repositories/language_repository.dart';

/// Use case for getting user's selected languages
class GetUserLanguagesUseCase {
  final LanguageRepository repository;

  GetUserLanguagesUseCase(this.repository);

  /// Execute the use case
  Future<List<Language>> call() => repository.getUserLanguages();
}
