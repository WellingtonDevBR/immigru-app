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

/// Use case for saving user languages
class SaveUserLanguagesUseCase {
  final LanguageRepository _repository;

  SaveUserLanguagesUseCase(this._repository);

  /// Call method to execute the use case
  /// 
  /// [languageIds] is a list of language IDs to save
  Future<bool> call(List<int> languageIds) async {
    return await _repository.saveUserLanguages(languageIds);
  }
}

/// Use case for getting user languages
class GetUserLanguagesUseCase {
  final LanguageRepository _repository;

  GetUserLanguagesUseCase(this._repository);

  /// Call method to execute the use case
  Future<List<Language>> call() async {
    return await _repository.getUserLanguages();
  }
}
