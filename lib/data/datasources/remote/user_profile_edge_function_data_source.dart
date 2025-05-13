import 'package:immigru/core/services/edge_function_logger.dart';
import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/core/services/supabase_service.dart';

/// Data source for interacting with the user profile edge function
class UserProfileEdgeFunctionDataSource {
  final SupabaseService _supabaseService;
  final LoggerService _logger;
  final EdgeFunctionLogger _edgeFunctionLogger;
  
  UserProfileEdgeFunctionDataSource(this._supabaseService, this._logger)
      : _edgeFunctionLogger = EdgeFunctionLogger(_logger);
  
  /// Save data for a specific onboarding step
  Future<void> saveStepData({
    required String step,
    required Map<String, dynamic> data,
    bool isCompleted = false,
  }) async {
    try {
      print('==== EDGE FUNCTION REQUEST - START ====');
      print('Step: $step');
      print('Data: $data');
      print('Is Completed: $isCompleted');
      
      _logger.debug('UserProfileEdgeFunctionDataSource', 'Saving data for step: $step');
      _logger.debug('UserProfileEdgeFunctionDataSource', 'Data content: ${data.toString()}');
      
      final requestBody = {
        'action': 'save', // Explicitly set the action
        'step': step,
        'data': data,
        'isCompleted': isCompleted,
      };
      
      print('Request body: $requestBody');
      
      // Log the request to the edge function
      _edgeFunctionLogger.logRequest(
        functionName: 'user-profile',
        requestData: requestBody,
        step: step,
      );
      
      print('Sending request to edge function...');
      
      try {
        final response = await _supabaseService.client
          .functions
          .invoke('user-profile', body: requestBody);
          
        print('==== EDGE FUNCTION RESPONSE - START ====');
        print('Response status: ${response.status}');
        print('Response data: ${response.data}');
        
        final responseData = response.data as Map<String, dynamic>?;
        
        // Log the response from the edge function
        _edgeFunctionLogger.logResponse(
          functionName: 'user-profile',
          responseData: responseData,
          step: step,
          isSuccess: responseData != null && responseData['error'] == null,
        );
        
        if (responseData == null) {
          print('WARNING: Edge function returned null data');
          throw Exception('Edge function returned null data');
        }
        
        if (responseData.containsKey('error') && responseData['error'] != null) {
          print('ERROR: Edge function response contains error:');
          print('Error: ${responseData['error']}');
          throw Exception('Edge function response error: ${responseData['error']}');
        }
        
        print('SUCCESS: Edge function request completed successfully');
        if (responseData.containsKey('message')) {
          print('Success message: ${responseData['message']}');
        }
        
        print('==== EDGE FUNCTION RESPONSE - END ====');
      } catch (e) {
        print('ERROR: Exception during edge function call: $e');
        rethrow;
      }
      
      _logger.debug('UserProfileEdgeFunctionDataSource', 'Successfully saved data for step: $step');
    } catch (e) {
      _logger.error('UserProfileEdgeFunctionDataSource', 'Error saving data for step: $step', error: e);
      rethrow;
    }
  }
  
  /// Get the user profile data
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      _logger.debug('UserProfileEdgeFunctionDataSource', 'Getting user profile data');
      
      final requestBody = {
        'action': 'get',
      };
      
      // Log the request to the edge function
      _edgeFunctionLogger.logRequest(
        functionName: 'user-profile',
        requestData: requestBody,
        step: 'get',
      );
      
      final response = await _supabaseService.client
        .functions
        .invoke('user-profile', body: requestBody);
        
      final responseData = response.data as Map<String, dynamic>?;
      
      // Log the response from the edge function
      _edgeFunctionLogger.logResponse(
        functionName: 'user-profile',
        responseData: responseData,
        step: 'get',
        isSuccess: responseData != null && responseData['error'] == null,
      );
      
      if (responseData == null || responseData['error'] != null) {
        throw Exception('Failed to get profile data: ${responseData?['error'] ?? 'Unknown error'}');
      }
      
      _logger.debug('UserProfileEdgeFunctionDataSource', 'Successfully got user profile data');
      
      return responseData['data'] as Map<String, dynamic>;
    } catch (e) {
      _logger.error('UserProfileEdgeFunctionDataSource', 'Error getting user profile data', error: e);
      rethrow;
    }
  }
  
  /// Check if the user has completed the onboarding process
  Future<bool> checkOnboardingStatus() async {
    try {
      _logger.debug('UserProfileEdgeFunctionDataSource', 'Checking onboarding status');
      
      final requestBody = {
        'action': 'checkStatus',
      };
      
      // Log the request to the edge function
      _edgeFunctionLogger.logRequest(
        functionName: 'user-profile',
        requestData: requestBody,
        step: 'checkStatus',
      );
      
      final response = await _supabaseService.client
        .functions
        .invoke('user-profile', body: requestBody);
        
      final responseData = response.data as Map<String, dynamic>?;
      
      // Log the response from the edge function
      _edgeFunctionLogger.logResponse(
        functionName: 'user-profile',
        responseData: responseData,
        step: 'checkStatus',
        isSuccess: responseData != null && responseData['error'] == null,
      );
      
      if (responseData == null || responseData['error'] != null) {
        throw Exception('Failed to check onboarding status: ${responseData?['error'] ?? 'Unknown error'}');
      }
      
      _logger.debug('UserProfileEdgeFunctionDataSource', 'Successfully checked onboarding status');
      
      final data = responseData['data'] as Map<String, dynamic>;
      return data['completed'] as bool;
    } catch (e) {
      _logger.error('UserProfileEdgeFunctionDataSource', 'Error checking onboarding status', error: e);
      rethrow;
    }
  }
}
