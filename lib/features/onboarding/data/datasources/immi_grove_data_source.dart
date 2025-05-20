import 'package:immigru/new_core/network/edge_function_client.dart';
import 'package:immigru/new_core/logging/logger_interface.dart';
import '../models/immi_grove_model.dart';

/// Data source interface for ImmiGrove operations
abstract class ImmiGroveDataSource {
  /// Get recommended ImmiGroves for the current user
  Future<List<ImmiGroveModel>> getRecommendedImmiGroves({int limit = 6});

  /// Join an ImmiGrove
  Future<void> joinImmiGrove(String immiGroveId);

  /// Leave an ImmiGrove
  Future<void> leaveImmiGrove(String immiGroveId);

  /// Get ImmiGroves that the user has joined
  Future<List<ImmiGroveModel>> getJoinedImmiGroves();

  /// Save selected ImmiGroves
  Future<void> saveSelectedImmiGroves(List<String> immiGroveIds);
}

/// Implementation of ImmiGroveDataSource using Supabase Edge Functions
class ImmiGroveSupabaseDataSource implements ImmiGroveDataSource {
  final EdgeFunctionClient _client;
  final LoggerInterface _logger;
  
  // Cache for recommended ImmiGroves
  List<ImmiGroveModel>? _cachedRecommendedImmiGroves;
  
  // Cache for joined ImmiGroves
  List<ImmiGroveModel>? _cachedJoinedImmiGroves;
  
  // Flag to indicate if the cache should be refreshed
  bool _shouldRefreshCache = true;

  /// Creates a new ImmiGroveSupabaseDataSource
  ImmiGroveSupabaseDataSource({
    required EdgeFunctionClient client,
    required LoggerInterface logger,
  })  : _client = client,
        _logger = logger;

  @override
  Future<List<ImmiGroveModel>> getRecommendedImmiGroves({int limit = 6}) async {
    try {
      // Return cached data if available and cache refresh is not required
      if (_cachedRecommendedImmiGroves != null && !_shouldRefreshCache) {
        _logger.i('ImmiGroveDataSource: Using cached recommended ImmiGroves');
        return _cachedRecommendedImmiGroves!;
      }

      _logger.i('ImmiGroveDataSource: Fetching recommended ImmiGroves from API');
      
      final response = await _client.invoke<dynamic>(
        'recommended-immigroves',
        body: {
          'limit_count': limit,
        },
      );

      if (!response.isSuccess) {
        _logger.e('ImmiGroveDataSource: Failed to get recommended ImmiGroves', 
            error: response.message);
        throw Exception(response.message);
      }

      final responseData = response.data as Map<String, dynamic>;
      final immigrovesJson = responseData['data'] as List<dynamic>? ?? [];

      _logger.i('ImmiGroveDataSource: Received ${immigrovesJson.length} recommended ImmiGroves');

      // Parse the response into ImmiGroveModel objects
      final immiGroves = immigrovesJson
          .map((json) => ImmiGroveModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Cache the results
      _cachedRecommendedImmiGroves = immiGroves;
      _shouldRefreshCache = false;

      return immiGroves;
    } catch (e) {
      _logger.e('ImmiGroveDataSource: Error getting recommended ImmiGroves', error: e);
      rethrow;
    }
  }

  @override
  Future<void> joinImmiGrove(String immiGroveId) async {
    try {
      _logger.i('ImmiGroveDataSource: Joining ImmiGrove: $immiGroveId');
      
      final response = await _client.invoke<dynamic>(
        'join-immigrove',
        body: {
          'immigrove_id': immiGroveId,
        },
      );

      if (!response.isSuccess) {
        _logger.e('ImmiGroveDataSource: Failed to join ImmiGrove', 
            error: response.message);
        throw Exception(response.message);
      }

      _logger.i('ImmiGroveDataSource: Successfully joined ImmiGrove: $immiGroveId');
      
      // Invalidate the cache since the user's joined ImmiGroves have changed
      _shouldRefreshCache = true;
      _cachedJoinedImmiGroves = null;
    } catch (e) {
      _logger.e('ImmiGroveDataSource: Error joining ImmiGrove', error: e);
      rethrow;
    }
  }

  @override
  Future<void> leaveImmiGrove(String immiGroveId) async {
    try {
      _logger.i('ImmiGroveDataSource: Leaving ImmiGrove: $immiGroveId');
      
      final response = await _client.invoke<dynamic>(
        'leave-immigrove',
        body: {
          'immigrove_id': immiGroveId,
        },
      );

      if (!response.isSuccess) {
        _logger.e('ImmiGroveDataSource: Failed to leave ImmiGrove', 
            error: response.message);
        throw Exception(response.message);
      }

      _logger.i('ImmiGroveDataSource: Successfully left ImmiGrove: $immiGroveId');
      
      // Invalidate the cache since the user's joined ImmiGroves have changed
      _shouldRefreshCache = true;
      _cachedJoinedImmiGroves = null;
    } catch (e) {
      _logger.e('ImmiGroveDataSource: Error leaving ImmiGrove', error: e);
      rethrow;
    }
  }

  @override
  Future<List<ImmiGroveModel>> getJoinedImmiGroves() async {
    try {
      // Return cached data if available and cache refresh is not required
      if (_cachedJoinedImmiGroves != null && !_shouldRefreshCache) {
        _logger.i('ImmiGroveDataSource: Using cached joined ImmiGroves');
        return _cachedJoinedImmiGroves!;
      }

      _logger.i('ImmiGroveDataSource: Fetching joined ImmiGroves from API');
      
      final response = await _client.invoke<dynamic>(
        'joined-immigroves',
        body: {},
      );

      if (!response.isSuccess) {
        _logger.e('ImmiGroveDataSource: Failed to get joined ImmiGroves', 
            error: response.message);
        throw Exception(response.message);
      }

      final responseData = response.data as Map<String, dynamic>;
      final immigrovesJson = responseData['data'] as List<dynamic>? ?? [];

      _logger.i('ImmiGroveDataSource: Received ${immigrovesJson.length} joined ImmiGroves');

      // Parse the response into ImmiGroveModel objects
      final immiGroves = immigrovesJson
          .map((json) => ImmiGroveModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Cache the results
      _cachedJoinedImmiGroves = immiGroves;
      _shouldRefreshCache = false;

      return immiGroves;
    } catch (e) {
      _logger.e('ImmiGroveDataSource: Error getting joined ImmiGroves', error: e);
      rethrow;
    }
  }

  @override
  Future<void> saveSelectedImmiGroves(List<String> immiGroveIds) async {
    try {
      _logger.i('ImmiGroveDataSource: Saving selected ImmiGroves: $immiGroveIds');
      
      final response = await _client.invoke<dynamic>(
        'save-selected-immigroves',
        body: {
          'immigrove_ids': immiGroveIds,
        },
      );

      if (!response.isSuccess) {
        _logger.e('ImmiGroveDataSource: Failed to save selected ImmiGroves', 
            error: response.message);
        throw Exception(response.message);
      }

      _logger.i('ImmiGroveDataSource: Successfully saved selected ImmiGroves');
      
      // Invalidate the cache since the user's ImmiGroves have changed
      _shouldRefreshCache = true;
      _cachedJoinedImmiGroves = null;
    } catch (e) {
      _logger.e('ImmiGroveDataSource: Error saving selected ImmiGroves', error: e);
      rethrow;
    }
  }
  
  /// Force refresh of the cache on next data fetch
  void refreshCache() {
    _shouldRefreshCache = true;
  }
}
