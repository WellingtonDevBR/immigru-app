import 'package:flutter/foundation.dart';
import 'package:immigru/features/onboarding/data/models/language_model.dart';
import 'package:immigru/core/network/edge_function_client.dart';
import 'package:immigru/core/logging/logger_interface.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Data source interface for language-related operations
abstract class LanguageDataSource {
  /// Get all available languages
  Future<List<LanguageModel>> getLanguages();

  /// Save user languages
  Future<bool> saveUserLanguages(List<int> languageIds);

  /// Get user languages
  Future<List<LanguageModel>> getUserLanguages();
}

/// Implementation of LanguageDataSource using Supabase Edge Functions
class LanguageSupabaseDataSource implements LanguageDataSource {
  final EdgeFunctionClient _client;
  final LoggerInterface _logger;

  // Cache for user languages to prevent unnecessary API calls
  List<LanguageModel>? _cachedUserLanguages;
  bool _shouldRefreshCache = true;

  LanguageSupabaseDataSource(this._client, this._logger);

  @override
  Future<List<LanguageModel>> getLanguages() async {
    try {
      _logger.i('LanguageDataSource: Fetching languages from Supabase');
      final response = await _client.invoke<dynamic>(
        'get-languages',
        body: {},
      );

      if (!response.isSuccess) {
        _logger.e('LanguageDataSource: Failed to get languages',
            error: response.message);
        throw Exception(response.message);
      }

      // The response format is { data: [...] }
      final responseData = response.data as Map<String, dynamic>;
      final languagesJson = responseData['data'] as List<dynamic>? ?? [];

      _logger.i(
          'LanguageDataSource: Received ${languagesJson.length} languages from Supabase');

      if (kDebugMode && languagesJson.isNotEmpty) {
        _logger.i(
            'LanguageDataSource: Response data structure: ${languagesJson.runtimeType}');
        _logger.i(
            'LanguageDataSource: First item structure: ${languagesJson.first.runtimeType}');
        _logger.i(
            'LanguageDataSource: First item content: ${languagesJson.first}');
      }

      return languagesJson
          .map((json) => LanguageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('LanguageDataSource: Failed to get languages', error: e);
      // Return empty list on error to match old architecture behavior
      return [];
    }
  }

  @override
  Future<bool> saveUserLanguages(List<int> languageIds) async {
    try {
      // Validate input - don't save empty arrays
      if (languageIds.isEmpty) {
        _logger.w(
            'LanguageDataSource: Attempted to save empty language array, ignoring request');
        return false;
      }

      _logger.i('LanguageDataSource: SAVING USER LANGUAGES: $languageIds');

      // First try the dedicated user-language edge function
      try {
        // Prepare the request body - EXACTLY as Postman expects it
        final requestBody = {
          'languageIds': languageIds,
        };

        _logger.i('LanguageDataSource: Request body: $requestBody');

        // Use the ORIGINAL user-language edge function that works with Postman
        _logger.i('LanguageDataSource: Invoking user-language edge function');
        final response = await _client.invoke<dynamic>(
          'user-language',
          body: requestBody,
          method: HttpMethod.post,
        );

        // Log the complete response for debugging
        _logger.i(
            'LanguageDataSource: Response from user-language: ${response.data}');

        if (response.isSuccess) {
          // Mark the cache as needing refresh after successful save
          // This ensures we'll get fresh data next time getUserLanguages is called
          _shouldRefreshCache = true;

          _logger.i(
              'LanguageDataSource: Successfully saved languages via user-language edge function');
          return true;
        }

        _logger.w('LanguageDataSource: Primary method failed, trying fallback',
            error: response.message);
      } catch (primaryError) {
        _logger.w(
            'LanguageDataSource: Primary method failed with exception, trying fallback',
            error: primaryError);
      }

      // Fallback method: Use user-profile edge function with a simplified payload
      try {
        _logger.i(
            'LanguageDataSource: Trying fallback with user-profile edge function');
        final fallbackResponse = await _client.invoke<dynamic>(
          'user-profile',
          body: {
            'action': 'save',
            'step': 'languages',
            'data': {
              'languages': languageIds,
            }
          },
        );

        if (!fallbackResponse.isSuccess) {
          _logger.e('LanguageDataSource: Fallback method also failed',
              error: fallbackResponse.message);
          return false;
        }

        // Mark the cache as needing refresh after successful save
        _shouldRefreshCache = true;

        _logger.i(
            'LanguageDataSource: Successfully saved languages via fallback method');
        return true;
      } catch (fallbackError) {
        _logger.e('LanguageDataSource: Fallback method failed with exception',
            error: fallbackError);
        return false;
      }
    } catch (e) {
      _logger.e('LanguageDataSource: CRITICAL ERROR - $e');
      _logger.e('LanguageDataSource: Failed to save user languages', error: e);
      return false;
    }
  }

  @override
  Future<List<LanguageModel>> getUserLanguages() async {
    try {
      // If we have cached languages and don't need to refresh, return the cache
      if (_cachedUserLanguages != null && !_shouldRefreshCache) {
        _logger.i(
            'LanguageDataSource: Returning cached user languages (${_cachedUserLanguages!.length})');
        return _cachedUserLanguages!;
      }

      _logger.i('LanguageDataSource: Fetching user languages from server');

      // Add retry logic with exponential backoff for network issues
      int retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          final response = await _client.invoke<dynamic>(
            'user-language',
            body: {},
            method: HttpMethod.get,
          );

          // Log the complete response for debugging
          _logger.i('LanguageDataSource: Raw response: ${response.data}');

          if (!response.isSuccess) {
            _logger.e('LanguageDataSource: Failed to get user languages',
                error: response.message);
            throw Exception(response.message);
          }

          // The response format is { data: [...] }
          final responseData = response.data as Map<String, dynamic>;
          final userLanguagesJson =
              responseData['data'] as List<dynamic>? ?? [];

          _logger.i(
              'LanguageDataSource: Received ${userLanguagesJson.length} user languages');

          // Extract the Language objects from the UserLanguage join table
          final languages = userLanguagesJson.map((json) {
            // Check if this is a UserLanguage object with a nested Language object
            if (json is Map<String, dynamic> && json.containsKey('Language')) {
              // Extract the Language object
              final languageJson = json['Language'] as Map<String, dynamic>;
              return LanguageModel.fromJson(languageJson);
            } else {
              // If it's already a Language object, use it directly
              return LanguageModel.fromJson(json as Map<String, dynamic>);
            }
          }).toList();

          _logger.i(
              'LanguageDataSource: Parsed ${languages.length} language models');

          // Update the cache
          _cachedUserLanguages = languages;
          _shouldRefreshCache = false;

          return languages;
        } catch (e) {
          retryCount++;
          if (retryCount >= maxRetries) {
            // If we've exhausted all retries, rethrow the exception
            _logger.e('LanguageDataSource: Failed after $maxRetries retries',
                error: e);
            rethrow;
          }

          // Wait with exponential backoff before retrying
          final waitTime = Duration(milliseconds: 500 * (1 << retryCount));
          _logger.w('LanguageDataSource: Retry $retryCount after $waitTime');
          await Future.delayed(waitTime);
        }
      }

      // This should never be reached due to the while loop and exception handling
      return [];
    } catch (e) {
      _logger.e('LanguageDataSource: Failed to get user languages', error: e);
      // Return empty list on error to match old architecture behavior
      return [];
    }
  }
}
