import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/core/services/supabase_service.dart';
import 'package:immigru/data/models/interest_model.dart';
import 'package:immigru/domain/entities/interest.dart';
import 'package:immigru/domain/repositories/interest_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementation of the InterestRepository interface
class InterestRepositoryImpl implements InterestRepository {
  final SupabaseService _supabaseService;
  final LoggerService _logger = LoggerService();

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
      _logger.error('InterestRepositoryImpl', 'Error getting interests: $e');
      // Return empty list on error, could also throw a custom exception
      return [];
    }
  }
  
  @override
  Future<bool> saveUserInterests(List<int> interestIds) async {
    try {
      _logger.debug('InterestRepositoryImpl', 'Saving user interests: $interestIds');
      
      // Call the user-interest edge function to save interests
      final response = await _supabaseService.client.functions.invoke(
        'user-interest',
        body: {'interestIds': interestIds},
      );
      
      _logger.debug('InterestRepositoryImpl', 'Save user interests response: ${response.data}');
      
      // Check if the response indicates success
      final data = response.data as Map<String, dynamic>;
      return data['success'] == true;
    } catch (e) {
      _logger.error('InterestRepositoryImpl', 'Error saving user interests: $e');
      return false;
    }
  }
  
  @override
  Future<List<Interest>> getUserInterests() async {
    try {
      _logger.debug('InterestRepositoryImpl', 'Getting user interests');
      
      // Call the user-interest edge function to get user interests
      // Explicitly specify method and headers for the GET request
      final response = await _supabaseService.client.functions.invoke(
        'user-interest',
        method: HttpMethod.get,
        headers: {'Content-Type': 'application/json'},
      );
      
      _logger.debug('InterestRepositoryImpl', 'User interests response received: ${response.status}');
      
      // Parse the response data
      final data = response.data as Map<String, dynamic>;
      _logger.debug('InterestRepositoryImpl', 'Response data: $data');
      
      if (data['data'] == null) {
        _logger.debug('InterestRepositoryImpl', 'No interests data found in response');
        return [];
      }
      
      // Parse the response and convert to Interest entities
      final List<dynamic> interestsJson = data['data'] as List<dynamic>;
      _logger.debug('InterestRepositoryImpl', 'Found ${interestsJson.length} interests in response');
      
      final interests = interestsJson.map((json) {
        // The response includes the Interest object nested under the 'Interest' key
        final interestData = json['Interest'] as Map<String, dynamic>;
        _logger.debug('InterestRepositoryImpl', 'Processing interest: ${interestData['Name']}');
        return InterestModel.fromJson(interestData);
      }).toList();
      
      _logger.debug('InterestRepositoryImpl', 'Returning ${interests.length} interests');
      return interests;
    } catch (e) {
      _logger.error('InterestRepositoryImpl', 'Error getting user interests: $e');
      return [];
    }
  }
}
