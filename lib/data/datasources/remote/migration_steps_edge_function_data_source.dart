import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:immigru/core/services/edge_function_logger.dart';
import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Data source for interacting with the migration steps edge function
class MigrationStepsEdgeFunctionDataSource {
  final SupabaseService _supabaseService;
  final LoggerService _logger;
  final EdgeFunctionLogger _edgeFunctionLogger;

  MigrationStepsEdgeFunctionDataSource(this._supabaseService, this._logger)
      : _edgeFunctionLogger = EdgeFunctionLogger(_logger);

  /// Save migration steps data
  Future<Map<String, dynamic>> saveMigrationSteps({
    required List<Map<String, dynamic>> steps,
    List<Map<String, dynamic>>? deletedSteps,
  }) async {
    final timestamp = DateTime.now().toIso8601String();
    try {
      debugPrint('[$timestamp] 🚀 DATA SOURCE: saveMigrationSteps called with ${steps.length} steps');
      _logger.debug('MigrationSteps', 'Saving ${steps.length} migration steps');
      
      // CRITICAL: Create a deep copy of steps to avoid modifying the original data
      final processedSteps = steps.map((step) => Map<String, dynamic>.from(step)).toList();
      
      // Add deleted steps if provided
      final deletedStepsList = <Map<String, dynamic>>[];
      if (deletedSteps != null && deletedSteps.isNotEmpty) {
        debugPrint('[$timestamp] 🗑️ Processing ${deletedSteps.length} deleted steps');
        for (var deletedStep in deletedSteps) {
          if (deletedStep['id'] != null) {
            final processedDeletedStep = Map<String, dynamic>.from(deletedStep);
            processedDeletedStep['isDeleted'] = true;
            deletedStepsList.add(processedDeletedStep);
            debugPrint('[$timestamp] 🗑️ Marked step ${processedDeletedStep['id']} for deletion');
          }
        }
      }
      debugPrint('[$timestamp] 📝 Created deep copy of steps data');
      
      // Process steps to match the format expected by the edge function
      for (var i = 0; i < processedSteps.length; i++) {
        final step = processedSteps[i];
        
        // Log the original step data for debugging
        debugPrint('[$timestamp] 📋 Original step $i: $step');
        
        // Make sure we have the required fields
        if (step['countryId'] == null) {
          debugPrint('[$timestamp] ⚠️ Missing countryId for step $i');
          throw Exception('countryId is required for migration step $i');
        }
        
        // Add required fields if missing
        if (!step.containsKey('order')) {
          debugPrint('[$timestamp] 📝 Adding missing order field for step $i');
          step['order'] = i;
        }
        
        // Ensure boolean fields are properly formatted
        debugPrint('[$timestamp] 📝 Formatting boolean fields for step $i');
        step['isCurrentLocation'] = step['isCurrentLocation'] == true;
        step['isTargetDestination'] = step['isTargetDestination'] == true;
        step['wasSuccessful'] = step['wasSuccessful'] == true || step['wasSuccessful'] == null;
        
        // Add isDeleted field to indicate this is not a deletion request
        step['isDeleted'] = false;
        
        // Log the processed step data for debugging
        debugPrint('[$timestamp] 📋 Processed step $i: countryId=${step['countryId']}, '
            'countryName=${step['countryName']}, '
            'visaId=${step['visaId']}, '
            'visaName=${step['visaName']}');
      }
      
      // CRITICAL: Explicitly set action to 'save' to ensure we're not using 'get'
      final requestBody = {
        'action': 'save',  // EXPLICITLY set to 'save'
        'data': [...processedSteps, ...deletedStepsList],
      };
      
      // Log if we're sending any deleted steps
      if (deletedStepsList.isNotEmpty) {
        debugPrint('[$timestamp] 🗑️ Sending ${deletedStepsList.length} deleted steps to backend');
        for (var i = 0; i < deletedStepsList.length; i++) {
          debugPrint('[$timestamp] 🗑️ Deleted step $i: id=${deletedStepsList[i]['id']}');
        }
      }
      
      // Log the request details for debugging
      debugPrint('[$timestamp] 🚀 DATA SOURCE: Preparing request with ACTION="save" and ${processedSteps.length} steps');
      debugPrint('[$timestamp] 📝 Full request body: ${jsonEncode(requestBody)}');
      
      // Log the request for debugging
      _edgeFunctionLogger.logRequest(
        functionName: 'migration-steps',
        requestData: requestBody,
      );
      
      // Check if we have a valid auth token
      final session = _supabaseService.client.auth.currentSession;
      if (session == null) {
        debugPrint('[$timestamp] ❌ Authentication error: No active session');
        _logger.error('MigrationSteps', 'Authentication error: No active session');
        throw Exception('Authentication error: No active session');
      }
      debugPrint('[$timestamp] 🔑 Authentication token available: ${session.accessToken.substring(0, 10)}...');
      
      // Call the function with the correct name using POST method
      debugPrint('[$timestamp] 🔍 Calling Supabase edge function: migration-steps via POST');
      final stopwatch = Stopwatch()..start();
      final response = await _supabaseService.client.functions.invoke(
        'migration-steps',
        body: requestBody,
        method: HttpMethod.post,  // Explicitly use POST method
      );
      stopwatch.stop();
      
      // Log the response for debugging
      debugPrint('[$timestamp] 🔍 Edge function response received in ${stopwatch.elapsedMilliseconds}ms');
      _edgeFunctionLogger.logResponse(
        functionName: 'migration-steps',
        responseData: response.data,
      );
      
      debugPrint('[$timestamp] 🔍 Response status: ${response.status}');
      debugPrint('[$timestamp] 🔍 Response data: ${jsonEncode(response.data)}');
      
      // Check if the response is empty or null
      if (response.data == null) {
        debugPrint('[$timestamp] ❌ Edge function returned null data');
        _logger.error('MigrationSteps', 'Edge function returned null data');
        throw Exception('Edge function returned null data');
      }

      // Check if the response indicates an error
      if (response.data is Map && response.data['success'] == false) {
        final errorMessage = response.data['message'] ?? 'Unknown error';
        final errorDetails = response.data['error'] ?? '';
        debugPrint('[$timestamp] ❌ Edge function error: $errorMessage - $errorDetails');
        _logger.error('MigrationSteps', 'Edge function error: $errorMessage - $errorDetails');
        throw Exception('Edge function error: $errorMessage - $errorDetails');
      }
      
      debugPrint('[$timestamp] ✅ Successfully saved migration steps');
      _logger.debug('MigrationSteps', 'Successfully saved ${steps.length} migration steps');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[$timestamp] ❌ Error in saveMigrationSteps: $e');
      _logger.error('MigrationSteps', 'Error in saveMigrationSteps: $e');
      rethrow;
    }
  }
  
  /// Get migration steps for the current user
  Future<List<Map<String, dynamic>>> getMigrationSteps() async {
    final timestamp = DateTime.now().toIso8601String();
    try {
      debugPrint('[$timestamp] 🔍 MigrationStepsEdgeFunctionDataSource.getMigrationSteps called');
      
      // IMPORTANT: Always use explicit 'get' action for retrieving data
      final requestBody = {
        'action': 'get',
      };
      
      debugPrint('[$timestamp] 📝 Prepared request body with EXPLICIT action: "get"');
      _edgeFunctionLogger.logRequest(
        functionName: 'migration-steps',
        requestData: requestBody,
      );

      // Check if we have a valid auth token
      final session = _supabaseService.client.auth.currentSession;
      if (session == null) {
        debugPrint('[$timestamp] ❌ Authentication error: No active session');
        _logger.error('MigrationSteps', 'Authentication error: No active session');
        throw Exception('Authentication error: No active session');
      }
      debugPrint('[$timestamp] 🔑 Authentication token available: ${session.accessToken.substring(0, 10)}...');
      
      // Call the function with the correct name using POST method
      debugPrint('[$timestamp] 🔍 Calling Supabase edge function: migration-steps via POST for GET action');
      final stopwatch = Stopwatch()..start();
      final response = await _supabaseService.client.functions.invoke(
        'migration-steps',
        body: requestBody,
        method: HttpMethod.post,
      );
      stopwatch.stop();
      
      debugPrint('[$timestamp] 🔍 Edge function response received in ${stopwatch.elapsedMilliseconds}ms');
      _edgeFunctionLogger.logResponse(
        functionName: 'migration-steps',
        responseData: response.data,
      );
      
      if (response.data == null) {
        debugPrint('[$timestamp] ⚠️ Edge function returned null data for GET request');
        return [];
      }

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == true && responseData['data'] != null) {
        final steps = List<Map<String, dynamic>>.from(responseData['data']);
        debugPrint('[$timestamp] ✅ Successfully retrieved ${steps.length} migration steps');
        return steps;
      } else {
        debugPrint('[$timestamp] ⚠️ Edge function returned unsuccessful response: $responseData');
        return [];
      }
    } catch (e) {
      debugPrint('[$timestamp] ❌ Error in getMigrationSteps: $e');
      _logger.error('MigrationSteps', 'Error retrieving migration steps: $e');
      return [];
    }
  }
}
