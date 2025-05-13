import 'dart:convert';
import 'package:immigru/core/services/logger_service.dart';

/// A specialized logger for edge function interactions
/// This logger specifically tracks all data sent to and received from
/// Supabase edge functions during the onboarding process
class EdgeFunctionLogger {
  final LoggerService _logger;
  
  /// Constructor
  EdgeFunctionLogger(this._logger);
  
  /// Log a request to an edge function
  void logRequest({
    required String functionName,
    required Map<String, dynamic> requestData,
    String? step,
    String? action,
  }) {
    final requestJson = jsonEncode(requestData);
    final stepInfo = step != null ? ' for step: $step' : '';
    final actionInfo = action != null ? ' with action: $action' : '';
    
    _logger.debug(
      'EdgeFunction',
      '➡️ REQUEST to $functionName$stepInfo$actionInfo',
    );
    
    _logger.debug(
      'EdgeFunction',
      '📤 REQUEST PAYLOAD: $requestJson',
    );
  }
  
  /// Log a response from an edge function
  void logResponse({
    required String functionName,
    required dynamic responseData,
    String? step,
    String? action,
    bool isSuccess = true,
  }) {
    final responseJson = responseData != null ? jsonEncode(responseData) : 'null';
    final stepInfo = step != null ? ' for step: $step' : '';
    final actionInfo = action != null ? ' with action: $action' : '';
    final statusEmoji = isSuccess ? '✅' : '❌';
    
    _logger.debug(
      'EdgeFunction',
      '⬅️ RESPONSE from $functionName$stepInfo$actionInfo: $statusEmoji',
    );
    
    _logger.debug(
      'EdgeFunction',
      '📥 RESPONSE PAYLOAD: $responseJson',
    );
  }
  
  /// Log an error during edge function interaction
  void logError({
    required String functionName,
    required Object error,
    StackTrace? stackTrace,
    String? step,
    String? action,
  }) {
    final stepInfo = step != null ? ' for step: $step' : '';
    final actionInfo = action != null ? ' with action: $action' : '';
    
    _logger.error(
      'EdgeFunction',
      '❌ ERROR in $functionName$stepInfo$actionInfo',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
