import 'package:supabase_flutter/supabase_flutter.dart';

/// Data source for onboarding operations
class OnboardingDataSource {
  final SupabaseClient _client;
  
  /// Constructor
  OnboardingDataSource({SupabaseClient? client}) 
      : _client = client ?? Supabase.instance.client;
  
  /// Save onboarding data for a specific step
  Future<void> saveStepData(String step, Map<String, dynamic> data) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    // Call the edge function to save the data
    await _client.functions.invoke(
      'user-profile',
      body: {
        'action': 'save',
        'step': step,
        'data': data,
      },
    );
  }
  
  /// Get onboarding data
  Future<Map<String, dynamic>> getOnboardingData() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    // Call the edge function to get the data
    final response = await _client.functions.invoke(
      'user-profile',
      body: {
        'action': 'get',
      },
    );
    
    if (response.status != 200) {
      throw Exception('Failed to get onboarding data: ${response.data}');
    }
    
    return response.data as Map<String, dynamic>;
  }
  
  /// Check if onboarding is complete
  Future<bool> isOnboardingComplete() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return false;
    }
    
    // Call the edge function to check status
    final response = await _client.functions.invoke(
      'user-profile',
      body: {
        'action': 'checkStatus',
      },
    );
    
    if (response.status != 200) {
      return false;
    }
    
    return (response.data as Map<String, dynamic>)['isComplete'] as bool? ?? false;
  }
  
  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    // Update the user profile to mark onboarding as complete
    await _client
        .from('profiles')
        .update({'has_completed_onboarding': true})
        .eq('id', userId);
  }
}
