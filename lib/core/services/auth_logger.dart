import 'package:immigru/core/services/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Extension for the LoggerService to handle authentication logging
extension AuthLogger on LoggerService {
  /// Log an authentication event
  void logAuthEvent(AuthChangeEvent event, {Session? session}) {
    final eventName = event.toString().split('.').last;
    String? userId;
    String? email;
    
    if (session != null && session.user != null) {
      userId = session.user.id;
      email = session.user.email;
    }
    
    String message = 'Auth Event: $eventName';
    if (userId != null) {
      message += ' | User ID: $userId';
    }
    if (email != null) {
      message += ' | Email: $email';
    }
    
    i(message, category: LogCategory.auth);
  }

  /// Log a sign-in attempt
  void logSignInAttempt(String provider, {String? email, String? phone}) {
    String message = 'Sign-in attempt with $provider';
    if (email != null) {
      message += ' | Email: $email';
    }
    if (phone != null) {
      message += ' | Phone: $phone';
    }
    
    i(message, category: LogCategory.auth);
  }

  /// Log a sign-in success
  void logSignInSuccess(String provider, String userId, {String? email, String? phone}) {
    String message = 'Sign-in successful with $provider | User ID: $userId';
    if (email != null) {
      message += ' | Email: $email';
    }
    if (phone != null) {
      message += ' | Phone: $phone';
    }
    
    i(message, category: LogCategory.auth);
  }

  /// Log a sign-in failure
  void logSignInFailure(String provider, dynamic error, {StackTrace? stackTrace, String? email, String? phone}) {
    String message = 'Sign-in failed with $provider';
    if (email != null) {
      message += ' | Email: $email';
    }
    if (phone != null) {
      message += ' | Phone: $phone';
    }
    
    e(message, category: LogCategory.auth, error: error, stackTrace: stackTrace);
  }

  /// Log OAuth token information (for debugging)
  void logOAuthTokens({String? provider, String? accessToken, String? idToken}) {
    if (accessToken != null) {
      final truncatedToken = _truncateToken(accessToken);
      d('$provider Access Token: $truncatedToken (${accessToken.length} chars)', category: LogCategory.auth);
    }
    
    if (idToken != null) {
      final truncatedToken = _truncateToken(idToken);
      d('$provider ID Token: $truncatedToken (${idToken.length} chars)', category: LogCategory.auth);
    }
  }
  
  /// Helper method to truncate tokens for logging
  String _truncateToken(String token) {
    if (token.length <= 20) return token;
    return '${token.substring(0, 20)}...';
  }
}
