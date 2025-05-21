import 'dart:convert';
import 'package:immigru/core/network/edge_function_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show HttpMethod;
import 'package:immigru/core/logging/logger_interface.dart';
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

      _logger
          .i('ImmiGroveDataSource: Fetching recommended ImmiGroves from API');
      _logger.d(
          'ImmiGroveDataSource: Calling recommended-immigroves with limit=$limit');

      // Check if we have a valid session before making the API call
      if (!await _client.hasValidSession()) {
        _logger.w(
            'ImmiGroveDataSource: No valid session found, returning empty list');
        return [];
      }

      final response = await _client.invoke<dynamic>(
        'recommended-immigroves',
        body: {},
        params: {
          'limit_count': limit.toString(),
        },
        method: HttpMethod.get,
      );

      _logger.d('ImmiGroveDataSource: Raw response: ${response.data}');

      if (response.isSuccess) {
        try {
          // Handle different response formats
          List<dynamic> immigrovesJson = [];

          if (response.data is Map<String, dynamic>) {
            // Standard format: {"data": [...]}
            final responseData = response.data as Map<String, dynamic>;
            immigrovesJson = responseData['data'] as List<dynamic>? ?? [];
          } else if (response.data is String) {
            // Sometimes the response might be a JSON string
            final responseString = response.data as String;
            if (responseString.isNotEmpty) {
              try {
                final decodedData = jsonDecode(responseString);
                if (decodedData is Map<String, dynamic>) {
                  immigrovesJson = decodedData['data'] as List<dynamic>? ?? [];
                } else if (decodedData is List) {
                  immigrovesJson = decodedData;
                }
              } catch (e) {
                _logger.e(
                    'ImmiGroveDataSource: Error parsing JSON string response',
                    error: e);
              }
            }
          } else if (response.data is List) {
            // Direct list format
            immigrovesJson = response.data as List<dynamic>;
          }

          _logger.i(
              'ImmiGroveDataSource: Received ${immigrovesJson.length} recommended ImmiGroves from API');

          if (immigrovesJson.isNotEmpty) {
            try {
              // Parse the response into ImmiGroveModel objects
              final immiGroves = immigrovesJson
                  .map((json) =>
                      ImmiGroveModel.fromJson(json as Map<String, dynamic>))
                  .toList();

              // Cache the results
              _cachedRecommendedImmiGroves = immiGroves;
              _shouldRefreshCache = false;

              return immiGroves;
            } catch (e, stackTrace) {
              _logger.e('ImmiGroveDataSource: Error parsing ImmiGrove models',
                  error: e, stackTrace: stackTrace);
            }
          }
        } catch (e, stackTrace) {
          _logger.e('ImmiGroveDataSource: Error parsing response data',
              error: e, stackTrace: stackTrace);
        }
      } else {
        _logger.e(
            'ImmiGroveDataSource: Failed to get recommended ImmiGroves from API',
            error: response.message);
      }

      // If we reach here, either the API call failed or returned empty data
      _logger.w(
          'ImmiGroveDataSource: No ImmiGroves available from API, returning empty list');
      return [];
    } catch (e, stackTrace) {
      _logger.e('ImmiGroveDataSource: Error getting recommended ImmiGroves',
          error: e, stackTrace: stackTrace);
      return [];
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

      if (response.isSuccess) {
        _logger.i(
            'ImmiGroveDataSource: Successfully joined ImmiGrove: $immiGroveId');
      } else {
        _logger.w(
            'ImmiGroveDataSource: API call failed, but continuing with UI update');
      }

      // Invalidate the cache since the user's joined ImmiGroves have changed
      _shouldRefreshCache = true;

      // If we have cached recommended ImmiGroves, update the isJoined flag
      if (_cachedRecommendedImmiGroves != null) {
        for (var i = 0; i < _cachedRecommendedImmiGroves!.length; i++) {
          if (_cachedRecommendedImmiGroves![i].id == immiGroveId) {
            _cachedRecommendedImmiGroves![i] =
                _cachedRecommendedImmiGroves![i].copyWith(isJoined: true);
            break;
          }
        }
      }
    } catch (e, stackTrace) {
      _logger.e('ImmiGroveDataSource: Error joining ImmiGrove',
          error: e, stackTrace: stackTrace);
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

      if (response.isSuccess) {
        _logger.i(
            'ImmiGroveDataSource: Successfully left ImmiGrove: $immiGroveId');
      } else {
        _logger.w(
            'ImmiGroveDataSource: API call failed, but continuing with UI update');
      }

      // Invalidate the cache since the user's joined ImmiGroves have changed
      _shouldRefreshCache = true;

      // If we have cached recommended ImmiGroves, update the isJoined flag
      if (_cachedRecommendedImmiGroves != null) {
        for (var i = 0; i < _cachedRecommendedImmiGroves!.length; i++) {
          if (_cachedRecommendedImmiGroves![i].id == immiGroveId) {
            _cachedRecommendedImmiGroves![i] =
                _cachedRecommendedImmiGroves![i].copyWith(isJoined: false);
            break;
          }
        }
      }
    } catch (e, stackTrace) {
      _logger.e('ImmiGroveDataSource: Error leaving ImmiGrove',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<ImmiGroveModel>> getJoinedImmiGroves() async {
    try {
      _logger.i('ImmiGroveDataSource: Fetching joined ImmiGroves from API');

      try {
        final response = await _client.invoke<dynamic>(
          'joined-immigroves',
          body: {},
        );

        if (response.isSuccess) {
          try {
            // Handle different response formats
            List<dynamic> immigrovesJson = [];

            if (response.data is Map<String, dynamic>) {
              final responseData = response.data as Map<String, dynamic>;
              immigrovesJson = responseData['data'] as List<dynamic>? ?? [];
            } else if (response.data is String) {
              final responseString = response.data as String;
              if (responseString.isNotEmpty) {
                try {
                  final decodedData = jsonDecode(responseString);
                  if (decodedData is Map<String, dynamic>) {
                    immigrovesJson =
                        decodedData['data'] as List<dynamic>? ?? [];
                  } else if (decodedData is List) {
                    immigrovesJson = decodedData;
                  }
                } catch (e) {
                  _logger.e(
                      'ImmiGroveDataSource: Error parsing JSON string response',
                      error: e);
                }
              }
            } else if (response.data is List) {
              immigrovesJson = response.data as List<dynamic>;
            }

            _logger.i(
                'ImmiGroveDataSource: Received ${immigrovesJson.length} joined ImmiGroves from API');

            if (immigrovesJson.isNotEmpty) {
              // Parse the response into ImmiGroveModel objects
              final immiGroves = immigrovesJson
                  .map((json) =>
                      ImmiGroveModel.fromJson(json as Map<String, dynamic>))
                  .toList();

              return immiGroves;
            }
          } catch (e, stackTrace) {
            _logger.e(
                'ImmiGroveDataSource: Error parsing joined ImmiGroves response',
                error: e,
                stackTrace: stackTrace);
          }
        } else {
          _logger.e('ImmiGroveDataSource: Failed to get joined ImmiGroves',
              error: response.error);
        }
      } catch (e, stackTrace) {
        // Handle 404 errors gracefully - function might not exist yet
        if (e.toString().contains('404') ||
            e.toString().contains('NOT_FOUND')) {
          _logger.w(
              'ImmiGroveDataSource: joined-immigroves function not found, this is expected if the function hasn\'t been deployed yet');
        } else {
          _logger.e(
              'ImmiGroveDataSource: Error calling joined-immigroves function',
              error: e,
              stackTrace: stackTrace);
        }
      }

      _logger.w(
          'ImmiGroveDataSource: No joined ImmiGroves available, returning empty list');
      return [];
    } catch (e, stackTrace) {
      _logger.e('ImmiGroveDataSource: Error getting joined ImmiGroves',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<void> saveSelectedImmiGroves(List<String> immiGroveIds) async {
    try {
      _logger
          .i('ImmiGroveDataSource: Saving selected ImmiGroves: $immiGroveIds');

      final response = await _client.invoke<dynamic>(
        'save-selected-immigroves',
        body: {
          'immigrove_ids': immiGroveIds,
        },
      );

      if (response.isSuccess) {
        _logger
            .i('ImmiGroveDataSource: Successfully saved selected ImmiGroves');
      } else {
        _logger.e('ImmiGroveDataSource: Failed to save selected ImmiGroves',
            error: response.message);
        // We'll continue without throwing an exception to allow the UI flow to continue
        _logger.w('ImmiGroveDataSource: Continuing despite API error');
      }

      // Invalidate the cache since the user's ImmiGroves have changed
      _shouldRefreshCache = true;
    } catch (e, stackTrace) {
      _logger.e('ImmiGroveDataSource: Error saving selected ImmiGroves',
          error: e, stackTrace: stackTrace);
      // We'll continue without throwing an exception to allow the UI flow to continue
      _logger.w('ImmiGroveDataSource: Continuing despite exception');
    }
  }

  /// Force refresh of the cache on next data fetch
  void refreshCache() {
    _shouldRefreshCache = true;
  }
}
