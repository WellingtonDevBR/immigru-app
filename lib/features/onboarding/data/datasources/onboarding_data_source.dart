import 'package:immigru/new_core/network/edge_function_client.dart';
import 'package:immigru/new_core/logging/logger_interface.dart';

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
  final LoggerInterface _logger;
  
  /// Constructor
  OnboardingSupabaseDataSource({
    required EdgeFunctionClient client,
    required LoggerInterface logger,
  }) : _client = client,
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
      
      _logger.i('OnboardingDataSource: Successfully saved data for step: $step');
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
      _logger.e('OnboardingDataSource: Error getting onboarding data', error: e);
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
      
      final isComplete = (response.data as Map<String, dynamic>)['is_complete'] as bool? ?? false;
      _logger.i('OnboardingDataSource: Onboarding complete status: $isComplete');
      return isComplete;
    } catch (e) {
      _logger.e('OnboardingDataSource: Error checking onboarding status', error: e);
      rethrow;
    }
  }
  
  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    try {
      _logger.i('OnboardingDataSource: Marking onboarding as complete');
      
      // Use the update_profile action instead of complete_onboarding
      // since the backend doesn't have a complete_onboarding action
      final response = await _client.invoke<dynamic>(
        'user-profile',
        body: {
          'action': 'update_profile',
          'data': {
            'onboarding_completed': true
          }
        },
      );
      
      if (!response.isSuccess) {
        _logger.e('OnboardingDataSource: Failed to mark onboarding as complete', 
            error: response.message);
        throw Exception(response.message);
      }
      
      _logger.i('OnboardingDataSource: Successfully marked onboarding as complete');
    } catch (e) {
      _logger.e('OnboardingDataSource: Error marking onboarding as complete', error: e);
      rethrow;
    }
  }
}
