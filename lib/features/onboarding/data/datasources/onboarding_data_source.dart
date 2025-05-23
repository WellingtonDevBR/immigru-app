import 'package:immigru/core/network/edge_function_client.dart';
import 'package:immigru/core/logging/logger_interface.dart' as new_core;
import 'package:get_it/get_it.dart';
import 'package:immigru/features/onboarding/presentation/bloc/immi_grove/immi_grove_bloc.dart';

/// Data source interface for onboarding operations
abstract class OnboardingDataSource {
  /// Save onboarding data for a specific step
  Future<void> saveStepData(String step, Map<String, dynamic> data);

  /// Get onboarding data
  Future<Map<String, dynamic>> getOnboardingData();

  /// Check if onboarding is complete
  Future<bool> isOnboardingComplete();

  /// Mark onboarding as complete
  Future<void> completeOnboarding();
}

/// Implementation of OnboardingDataSource using Supabase Edge Functions
class OnboardingSupabaseDataSource implements OnboardingDataSource {
  final EdgeFunctionClient _client;
  final new_core.LoggerInterface _logger;

  /// Constructor
  OnboardingSupabaseDataSource({
    required EdgeFunctionClient client,
    required new_core.LoggerInterface logger,
  })  : _client = client,
        _logger = logger;

  @override
  Future<void> saveStepData(String step, Map<String, dynamic> data) async {
    try {
      _logger.i('OnboardingDataSource: Saving data for step: $step');

      final response = await _client.invoke<dynamic>(
        'user-profile',
        body: {
          'action': 'save',
          'step': step,
          'data': data,
        },
      );

      if (!response.isSuccess) {
        _logger.e('OnboardingDataSource: Failed to save step data',
            error: response.message);
        throw Exception(response.message);
      }

      _logger
          .i('OnboardingDataSource: Successfully saved data for step: $step');
    } catch (e) {
      _logger.e('OnboardingDataSource: Error saving step data', error: e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getOnboardingData() async {
    try {
      _logger.i('OnboardingDataSource: Fetching onboarding data');

      final response = await _client.invoke<dynamic>(
        'user-profile',
        body: {
          'action': 'get',
        },
      );

      if (!response.isSuccess) {
        _logger.e('OnboardingDataSource: Failed to get onboarding data',
            error: response.message);
        throw Exception(response.message);
      }

      _logger.i('OnboardingDataSource: Successfully fetched onboarding data');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      _logger.e('OnboardingDataSource: Error getting onboarding data',
          error: e);
      rethrow;
    }
  }

  @override
  Future<bool> isOnboardingComplete() async {
    try {
      _logger.i('OnboardingDataSource: Checking if onboarding is complete');

      final response = await _client.invoke<dynamic>(
        'user-profile',
        body: {
          'action': 'check_complete',
        },
      );

      if (!response.isSuccess) {
        _logger.e('OnboardingDataSource: Failed to check onboarding status',
            error: response.message);
        throw Exception(response.message);
      }

      final isComplete =
          (response.data as Map<String, dynamic>)['is_complete'] as bool? ??
              false;
      _logger
          .i('OnboardingDataSource: Onboarding complete status: $isComplete');
      return isComplete;
    } catch (e) {
      _logger.e('OnboardingDataSource: Error checking onboarding status',
          error: e);
      rethrow;
    }
  }

  /// Mark onboarding as complete
  @override
  Future<void> completeOnboarding() async {
    try {
      _logger.i('OnboardingDataSource: Marking onboarding as complete');

      // Get the selected ImmiGrove IDs from the ImmiGroveBloc
      final immiGroveBloc = GetIt.instance<ImmiGroveBloc>();
      final selectedImmiGroveIds =
          immiGroveBloc.state.selectedImmiGroveIds.toList();

      _logger.i(
          'OnboardingDataSource: Selected ImmiGrove IDs: $selectedImmiGroveIds');

      // First try the 'save' action with step 'completed' to mark onboarding as complete
      // This will update the User table with HasCompletedOnboarding = true
      try {
        _logger.i(
            'OnboardingDataSource: Attempting to mark onboarding as complete with primary method');
        _logger.i(
            'OnboardingDataSource: Calling user-profile edge function with action=save, step=completed');

        final response = await _client.invoke<dynamic>(
          'user-profile',
          body: {
            'action': 'save',
            'step': 'completed',
            'data': {
              'immiGroveIds': selectedImmiGroveIds,
              'hasCompletedOnboarding': true, // Explicitly set this flag
            }
          },
        );

        _logger.i(
            'OnboardingDataSource: Primary method response received: ${response.isSuccess}');
        if (response.data != null) {
          _logger.i('OnboardingDataSource: Response data: ${response.data}');
        }

        if (response.isSuccess) {
          _logger.i(
              'OnboardingDataSource: Successfully marked onboarding as complete with primary method');
          return;
        } else {
          _logger.w(
              'OnboardingDataSource: Primary method failed, trying fallback',
              error: response.message);
        }
      } catch (primaryError) {
        _logger.w(
            'OnboardingDataSource: Primary method failed with exception, trying fallback',
            error: primaryError);
      }

      // Fallback method 1: Use update_profile action to directly set HasCompletedOnboarding
      try {
        _logger.i(
            'OnboardingDataSource: Attempting fallback method 1 to mark onboarding as complete');
        _logger.i(
            'OnboardingDataSource: Calling user-profile edge function with action=update');

        final fallbackResponse = await _client.invoke<dynamic>(
          'user-profile',
          body: {
            'action': 'update',
            'data': {'HasCompletedOnboarding': true}
          },
        );

        _logger.i(
            'OnboardingDataSource: Fallback method 1 response received: ${fallbackResponse.isSuccess}');
        if (fallbackResponse.data != null) {
          _logger.i(
              'OnboardingDataSource: Fallback method 1 response data: ${fallbackResponse.data}');
        }

        if (fallbackResponse.isSuccess) {
          _logger.i(
              'OnboardingDataSource: Successfully marked onboarding as complete using fallback method 1');
          return;
        } else {
          _logger.w(
              'OnboardingDataSource: Fallback method 1 failed, trying fallback method 2',
              error: fallbackResponse.message);
        }
      } catch (fallbackError) {
        _logger.w(
            'OnboardingDataSource: Fallback method 1 failed with exception, trying fallback method 2',
            error: fallbackError);
      }

      // Fallback method 2: Use direct database update as a last resort
      _logger.i(
          'OnboardingDataSource: Attempting fallback method 2 to mark onboarding as complete');
      _logger.i(
          'OnboardingDataSource: Calling user-profile edge function with action=direct_update');

      final fallbackResponse = await _client.invoke<dynamic>(
        'user-profile',
        body: {
          'action': 'direct_update',
          'table': 'UserProfile',
          'data': {'HasCompletedOnboarding': true}
        },
      );

      _logger.i(
          'OnboardingDataSource: Fallback method 2 response received: ${fallbackResponse.isSuccess}');
      if (fallbackResponse.data != null) {
        _logger.i(
            'OnboardingDataSource: Fallback method 2 response data: ${fallbackResponse.data}');
      }

      if (!fallbackResponse.isSuccess) {
        _logger.e(
            'OnboardingDataSource: Failed to mark onboarding as complete with all methods',
            error: fallbackResponse.message);
        throw Exception('Failed to mark onboarding as complete');
      } else {
        _logger.i(
            'OnboardingDataSource: Successfully marked onboarding as complete using fallback method 2');
      }

      _logger.i(
          'OnboardingDataSource: Successfully marked onboarding as complete using fallback method');
    } catch (e) {
      _logger.e('OnboardingDataSource: Error marking onboarding as complete',
          error: e);
      rethrow;
    }
  }
}
