import 'package:immigru/new_core/logging/logger_interface.dart';
import 'package:immigru/new_core/network/edge_function_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/interest_model.dart';

/// Data source interface for Interest data
abstract class InterestDataSource {
  /// Get all available interests
  Future<List<InterestModel>> getInterests();

  /// Save user's selected interests
  Future<bool> saveUserInterests(List<int> interestIds);

  /// Get user's selected interests
  Future<List<InterestModel>> getUserInterests();
}

/// Implementation of InterestDataSource using Supabase edge functions
class InterestSupabaseDataSource implements InterestDataSource {
  final EdgeFunctionClient _client;
  final LoggerInterface _logger;

  /// Create a new InterestSupabaseDataSource
  InterestSupabaseDataSource({
    required EdgeFunctionClient client,
    required LoggerInterface logger,
  })  : _client = client,
        _logger = logger;

  @override
  Future<List<InterestModel>> getInterests() async {
    try {
      _logger.i('InterestDataSource: Fetching all interests');
      final response = await _client.invoke<dynamic>('get-interests',
          body: {}, method: HttpMethod.get);

      if (!response.isSuccess) {
        _logger.e('InterestDataSource: Failed to get interests',
            error: response.message);
        return [];
      }

      final data = response.data as Map<String, dynamic>;
      _logger.i('InterestDataSource: Successfully fetched interests');

      return data['data'] == null
          ? []
          : (data['data'] as List<dynamic>)
              .map((json) => InterestModel.fromJson(json))
              .toList();
    } catch (e) {
      _logger.e('InterestDataSource: Failed to get interests', error: e);
      return [];
    }
  }

  @override
  Future<bool> saveUserInterests(List<int> interestIds) async {
    try {
      _logger.i('InterestDataSource: Saving user interests: $interestIds');
      
      // First, delete existing user interests to prevent duplicate key violations
      final deleteResponse = await _client.invoke<dynamic>(
        'user-interest',
        body: {
          'action': 'delete_all'
        },
        method: HttpMethod.post,
      );
      
      if (!deleteResponse.isSuccess) {
        _logger.w('InterestDataSource: Failed to delete existing interests, continuing anyway',
            error: deleteResponse.message);
        // Continue anyway, as this might be a first-time setup
      } else {
        _logger.i('InterestDataSource: Successfully deleted existing user interests');
      }
      
      // Now add the new interests
      final response = await _client.invoke<dynamic>(
        'user-interest',
        body: {
          'action': 'save',
          'interestIds': interestIds,
        },
        method: HttpMethod.post,
      );

      if (!response.isSuccess) {
        _logger.e('InterestDataSource: Failed to save user interests',
            error: response.message);
        return false;
      }

      _logger.i('InterestDataSource: Successfully saved user interests');
      return true;
    } catch (e) {
      _logger.e('InterestDataSource: Failed to save user interests', error: e);
      return false;
    }
  }

  @override
  Future<List<InterestModel>> getUserInterests() async {
    try {
      _logger.i('InterestDataSource: Fetching user interests');
      final response = await _client.invoke<dynamic>(
        'user-interest',
        body: {},
        method: HttpMethod.get,
      );

      if (!response.isSuccess) {
        _logger.e('InterestDataSource: Failed to get user interests',
            error: response.message);
        return [];
      }

      final data = response.data as Map<String, dynamic>;
      _logger.i('InterestDataSource: Successfully fetched user interests');

      return data['data'] == null
          ? []
          : (data['data'] as List<dynamic>)
              .map((json) => InterestModel.fromJson(json))
              .toList();
    } catch (e) {
      _logger.e('InterestDataSource: Failed to get user interests', error: e);
      return [];
    }
  }
}
