import '../../domain/entities/language.dart';
import '../../domain/repositories/language_repository.dart';
import '../datasources/language_data_source.dart';
import 'package:immigru/new_core/logging/logger_interface.dart';

/// Implementation of the LanguageRepository interface
class LanguageRepositoryImpl implements LanguageRepository {
  final LanguageDataSource _dataSource;
  final LoggerInterface _logger;

  LanguageRepositoryImpl(this._dataSource, this._logger);

  @override
  Future<List<Language>> getLanguages() async {
    try {
      _logger.v('LanguageRepository: Getting all languages');
      return await _dataSource.getLanguages();
    } catch (e) {
      _logger.e('LanguageRepository: Failed to get languages', error: e);
      throw Exception('Failed to get languages: $e');
    }
  }

  @override
  Future<bool> saveUserLanguages(List<int> languageIds) async {
    try {
      _logger.v('LanguageRepository: Saving user languages: $languageIds');
      return await _dataSource.saveUserLanguages(languageIds);
    } catch (e) {
      _logger.e('LanguageRepository: Failed to save user languages', error: e);
      throw Exception('Failed to save user languages: $e');
    }
  }

  @override
  Future<List<Language>> getUserLanguages() async {
    try {
      _logger.v('LanguageRepository: Getting user languages');
      return await _dataSource.getUserLanguages();
    } catch (e) {
      _logger.e('LanguageRepository: Failed to get user languages', error: e);
      throw Exception('Failed to get user languages: $e');
    }
  }
}
