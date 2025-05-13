import 'package:immigru/core/services/supabase_service.dart';
import 'package:immigru/data/models/language_model.dart';
import 'package:immigru/domain/entities/language.dart';
import 'package:immigru/domain/repositories/language_repository.dart';

/// Implementation of the LanguageRepository interface
class LanguageRepositoryImpl implements LanguageRepository {
  final SupabaseService _supabaseService;

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
      // Return empty list on error, could also throw a custom exception
      return [];
    }
  }
}
