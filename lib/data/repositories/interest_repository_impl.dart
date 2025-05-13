import 'package:immigru/core/services/supabase_service.dart';
import 'package:immigru/data/models/interest_model.dart';
import 'package:immigru/domain/entities/interest.dart';
import 'package:immigru/domain/repositories/interest_repository.dart';

/// Implementation of the InterestRepository interface
class InterestRepositoryImpl implements InterestRepository {
  final SupabaseService _supabaseService;

  InterestRepositoryImpl(this._supabaseService);

  @override
  Future<List<Interest>> getInterests() async {
    try {
      // Call the edge function to get interests
      final response = await _supabaseService.client.functions.invoke('get-interests');
      
      // Parse the response data
      final data = response.data as Map<String, dynamic>;
      if (data['data'] == null) {
        return [];
      }
      
      // Parse the response and convert to Interest entities
      final List<dynamic> interestsJson = data['data'] as List<dynamic>;
      return interestsJson
          .map((json) => InterestModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Return empty list on error, could also throw a custom exception
      return [];
    }
  }
}
