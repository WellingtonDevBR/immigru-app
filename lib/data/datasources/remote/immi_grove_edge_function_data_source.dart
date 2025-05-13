import 'dart:convert';
import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/core/services/supabase_service.dart';

/// Data source for ImmiGrove edge functions
class ImmiGroveEdgeFunctionDataSource {
  final SupabaseService _supabaseService;
  final LoggerService _logger;

  ImmiGroveEdgeFunctionDataSource({
    required SupabaseService supabaseService,
    required LoggerService logger,
  })  : _supabaseService = supabaseService,
        _logger = logger;

  /// Get recommended ImmiGroves from the edge function
  Future<Map<String, dynamic>> getRecommendedImmiGroves({int limit = 6}) async {
    try {
      final client = _supabaseService.client;
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await client.functions.invoke(
        'recommended-immigroves',
        body: jsonEncode({
          'user_id': user.id,
          'limit_count': limit,
        }),
      );

      if (response.status != 200) {
        throw Exception('Failed to get recommended ImmiGroves: Status ${response.status}');
      }

      return response.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      _logger.error(
        'ImmiGroveEdgeFunctionDataSource',
        'Error getting recommended ImmiGroves',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Join an ImmiGrove community
  Future<void> joinImmiGrove(String immiGroveId) async {
    try {
      final client = _supabaseService.client;
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await client.from('UserImmiGrove')
        .insert({
          'UserId': user.id,
          'ImmiGroveId': immiGroveId,
          'IsAdmin': false,
        })
        .select()
        .single();

      // Response validation handled by Supabase client
    } catch (e, stackTrace) {
      _logger.error(
        'ImmiGroveEdgeFunctionDataSource',
        'Error joining ImmiGrove',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Leave an ImmiGrove community (soft delete)
  Future<void> leaveImmiGrove(String immiGroveId) async {
    try {
      final client = _supabaseService.client;
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now().toIso8601String();
      
      final response = await client.from('UserImmiGrove')
        .update({
          'DeletedAt': now,
        })
        .eq('UserId', user.id)
        .eq('ImmiGroveId', immiGroveId)
        .select();

      if (response.isEmpty) {
        throw Exception('Failed to leave ImmiGrove: No matching record found');
      }
    } catch (e, stackTrace) {
      _logger.error(
        'ImmiGroveEdgeFunctionDataSource',
        'Error leaving ImmiGrove',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get ImmiGroves that the user has joined
  Future<List<Map<String, dynamic>>> getJoinedImmiGroves() async {
    try {
      final client = _supabaseService.client;
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await client.from('immigrovemembersview')
        .select()
        .eq('UserId', user.id)
        .order('JoinedAt', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      _logger.error(
        'ImmiGroveEdgeFunctionDataSource',
        'Error getting joined ImmiGroves',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
