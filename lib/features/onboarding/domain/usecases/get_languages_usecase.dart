import '../entities/language.dart';
import '../repositories/language_repository.dart';

/// Use case for getting all available languages
class GetLanguagesUseCase {
  final LanguageRepository repository;

  GetLanguagesUseCase(this.repository);

  /// Execute the use case
  Future<List<Language>> call() => repository.getLanguages();
}
