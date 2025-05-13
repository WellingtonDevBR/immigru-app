import 'package:immigru/domain/entities/language.dart';
import 'package:immigru/domain/repositories/language_repository.dart';

/// Use case for getting all available languages
class GetLanguagesUseCase {
  final LanguageRepository _repository;

  GetLanguagesUseCase(this._repository);

  /// Call method to execute the use case
  Future<List<Language>> call() async {
    return await _repository.getLanguages();
  }
}
