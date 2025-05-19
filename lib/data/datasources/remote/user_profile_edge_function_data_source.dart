import 'package:immigru/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Data source for interacting with the user profile edge function
class UserProfileEdgeFunctionDataSource {
  final SupabaseService _supabaseService;

  UserProfileEdgeFunctionDataSource(this._supabaseService);

  /// Save data for a specific onboarding step
  Future<void> saveStepData({
    required String step,
    required Map<String, dynamic> data,
    bool isCompleted = false,
  }) async {
    try {
      final requestBody = {
        'action': 'save', // Explicitly set the action
        'step': step,
        'data': data,
        'isCompleted': isCompleted,
      };

      // Log the request to the edge function
      try {
        final response = await _supabaseService.client.functions
            .invoke('user-profile', body: requestBody, method: HttpMethod.post);

        // Check if the response is empty or null
        if (response.data == null) {
          // Log the response from the edge function
          throw Exception('Edge function returned null data');
        }

        // Handle case where response data is an empty map
        if (response.data is Map && (response.data as Map).isEmpty) {
          // Log the response from the edge function
          // Don't throw an exception for empty responses

          return;
        }

        final responseData = response.data as Map<String, dynamic>?;

        // Log the response from the edge function
        if (responseData == null) {
          throw Exception('Edge function returned null data');
        }

        if (responseData.containsKey('error') &&
            responseData['error'] != null) {
          throw Exception(
              'Edge function response error: ${responseData['error']}');
        }

        if (responseData.containsKey('message')) {}
      } catch (e) {
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get the user profile data
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final requestBody = {
        'action': 'get',
      };

      // Log the request to the edge function
      final response = await _supabaseService.client.functions
          .invoke('user-profile', body: requestBody, method: HttpMethod.post);

      final responseData = response.data as Map<String, dynamic>?;

      // Log the response from the edge function
      if (responseData == null || responseData['error'] != null) {
        throw Exception(
            'Failed to get profile data: ${responseData?['error'] ?? 'Unknown error'}');
      }

      return responseData['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Check if the user has completed the onboarding process
  Future<bool> checkOnboardingStatus() async {
    try {
      final requestBody = {
        'action': 'checkStatus',
      };

      // Log the request to the edge function
      final response = await _supabaseService.client.functions
          .invoke('user-profile', body: requestBody, method: HttpMethod.post);

      final responseData = response.data as Map<String, dynamic>?;

      // Log the response from the edge function
      if (responseData == null || responseData['error'] != null) {
        throw Exception(
            'Failed to check onboarding status: ${responseData?['error'] ?? 'Unknown error'}');
      }

      final data = responseData['data'] as Map<String, dynamic>;
      return data['completed'] as bool;
    } catch (e) {
      rethrow;
    }
  }
}
