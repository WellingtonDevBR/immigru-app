import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/core/services/supabase_service.dart';
import 'package:immigru/data/models/language_model.dart';
import 'package:immigru/domain/entities/language.dart';
import 'package:immigru/domain/repositories/language_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementation of the LanguageRepository interface
class LanguageRepositoryImpl implements LanguageRepository {
  final SupabaseService _supabaseService;
  final LoggerService _logger = LoggerService();

  LanguageRepositoryImpl(this._supabaseService);

  @override
  Future<List<Language>> getLanguages() async {
    try {
      // Call the edge function to get languages
      final response = await _supabaseService.client.functions.invoke('get-languages');
      
      // Parse the response data
      final data = response.data as Map<String, dynamic>;
      if (data['data'] == null) {
        return [];
      }
      
      // Parse the response and convert to Language entities
      final List<dynamic> languagesJson = data['data'] as List<dynamic>;
      return languagesJson
          .map((json) => LanguageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.error('LanguageRepositoryImpl', 'Error getting languages: $e');
      // Return empty list on error, could also throw a custom exception
      return [];
    }
  }
  
  @override
  Future<bool> saveUserLanguages(List<int> languageIds) async {
    try {
      _logger.debug('LanguageRepositoryImpl', 'Saving user languages: $languageIds');
      
      // Call the user-language edge function to save languages
      final response = await _supabaseService.client.functions.invoke(
        'user-language',
        body: {'languageIds': languageIds},
      );
      
      _logger.debug('LanguageRepositoryImpl', 'Save user languages response: ${response.data}');
      
      // Check if the response indicates success
      final data = response.data as Map<String, dynamic>;
      return data['success'] == true;
    } catch (e) {
      _logger.error('LanguageRepositoryImpl', 'Error saving user languages: $e');
      return false;
    }
  }
  
  @override
  Future<List<Language>> getUserLanguages() async {
    try {
      _logger.debug('LanguageRepositoryImpl', 'Getting user languages');
      
      // Call the user-language edge function to get user languages
      // Explicitly specify method and headers for the GET request
      final response = await _supabaseService.client.functions.invoke(
        'user-language',
        // Use the correct HttpMethod enum value instead of a string
        headers: {'Content-Type': 'application/json'},
        method: HttpMethod.get,
      );
      
      _logger.debug('LanguageRepositoryImpl', 'User languages response received: ${response.status}');
      
      // Parse the response data
      final data = response.data as Map<String, dynamic>;
      _logger.debug('LanguageRepositoryImpl', 'Response data: $data');
      
      if (data['data'] == null) {
        _logger.debug('LanguageRepositoryImpl', 'No languages data found in response');
        return [];
      }
      
      // Parse the response and convert to Language entities
      final List<dynamic> languagesJson = data['data'] as List<dynamic>;
      _logger.debug('LanguageRepositoryImpl', 'Found ${languagesJson.length} languages in response');
      
      final languages = languagesJson.map((json) {
        // The response includes the Language object nested under the 'Language' key
        final languageData = json['Language'] as Map<String, dynamic>;
        _logger.debug('LanguageRepositoryImpl', 'Processing language: ${languageData['Name']} (${languageData['Code']})');
        return LanguageModel.fromJson(languageData);
      }).toList();
      
      _logger.debug('LanguageRepositoryImpl', 'Returning ${languages.length} languages');
      return languages;
    } catch (e) {
      _logger.error('LanguageRepositoryImpl', 'Error getting user languages: $e');
      return [];
    }
  }
}
