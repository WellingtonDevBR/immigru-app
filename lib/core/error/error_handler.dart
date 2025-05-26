import 'package:flutter/material.dart';
import 'package:immigru/core/error/exceptions.dart' as app_exceptions;
import 'package:immigru/core/error/failures.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A utility class that provides standardized error handling across the application.
/// 
/// This class helps to:
/// 1. Convert exceptions to appropriate failure types
/// 2. Log errors consistently
/// 3. Provide user-friendly error messages
class ErrorHandler {
  final UnifiedLogger _logger;
  
  /// Private constructor for singleton pattern
  ErrorHandler._({UnifiedLogger? logger}) : _logger = logger ?? UnifiedLogger();
  
  /// Singleton instance
  static final ErrorHandler _instance = ErrorHandler._();
  
  /// Get the singleton instance
  static ErrorHandler get instance => _instance;
  
  /// Handles any exception and converts it to an appropriate Failure
  /// 
  /// This method should be used in repositories to convert exceptions to failures
  /// for consistent error handling throughout the application.
  Failure handleException(dynamic exception, {String? tag, String? customMessage}) {
    final errorTag = tag ?? 'ErrorHandler';
    
    // Log the exception
    _logger.e(
      customMessage ?? 'An error occurred',
      error: exception,
      tag: errorTag,
    );
    
    // Convert exception to appropriate failure type
    if (exception is app_exceptions.AuthException) {
      return _handleAuthException(exception, errorTag);
    } else if (exception is AuthException) {
      return _handleSupabaseAuthException(exception, errorTag);
    } else if (exception is PostgrestException) {
      return _handlePostgrestException(exception, errorTag);
    } else if (exception is StorageException) {
      return _handleStorageException(exception, errorTag);
    } else if (exception is app_exceptions.ServerException) {
      return ServerFailure(
        message: exception.message,
        exception: exception,
      );
    } else if (exception is app_exceptions.CacheException) {
      return CacheFailure(
        message: exception.message,
        exception: exception,
      );
    } else if (exception is app_exceptions.ValidationException) {
      return ValidationFailure(
        message: exception.message,
        exception: exception,
      );
    } else {
      // Handle unknown exceptions
      return Failure(
        message: customMessage ?? 'An unexpected error occurred',
        exception: exception,
      );
    }
  }
  
  /// Handles application-defined authentication exceptions
  Failure _handleAuthException(app_exceptions.AuthException exception, String tag) {
    _logger.e('Auth error: ${exception.message}', tag: tag, error: exception);
    
    return AuthFailure(
      message: exception.message,
      code: 'APP_AUTH_ERROR',
      exception: exception,
    );
  }
  
  /// Handles Supabase authentication exceptions
  Failure _handleSupabaseAuthException(AuthException exception, String tag) {
    _logger.e('Supabase auth error: ${exception.message}', tag: tag, error: exception);
    
    // Map common auth error messages to user-friendly messages
    final message = _mapAuthErrorToUserFriendlyMessage(exception.message);
    
    return AuthFailure(
      message: message,
      code: exception.statusCode,
      exception: exception,
    );
  }
  
  /// Handles Supabase Postgrest exceptions
  Failure _handlePostgrestException(PostgrestException exception, String tag) {
    _logger.e(
      'Database error: ${exception.message}',
      tag: tag,
      error: exception,
    );
    
    return ServerFailure(
      message: 'Database operation failed: ${exception.message}',
      code: exception.code,
      exception: exception,
    );
  }
  
  /// Handles Supabase Storage exceptions
  Failure _handleStorageException(StorageException exception, String tag) {
    _logger.e(
      'Storage error: ${exception.message}',
      tag: tag,
      error: exception,
    );
    
    return ServerFailure(
      message: 'File storage operation failed: ${exception.message}',
      code: exception.statusCode.toString(),
      exception: exception,
    );
  }
  
  /// Maps authentication error messages to user-friendly messages
  String _mapAuthErrorToUserFriendlyMessage(String errorMessage) {
    // Common Supabase auth error messages
    if (errorMessage.contains('Invalid login credentials')) {
      return 'Invalid email or password. Please try again.';
    } else if (errorMessage.contains('Email not confirmed')) {
      return 'Please verify your email before logging in.';
    } else if (errorMessage.contains('User already registered')) {
      return 'An account with this email already exists.';
    } else if (errorMessage.contains('Password should be at least')) {
      return 'Password is too short. Please use at least 6 characters.';
    } else if (errorMessage.contains('rate limit')) {
      return 'Too many attempts. Please try again later.';
    }
    
    // Default message for unknown auth errors
    return 'Authentication failed: $errorMessage';
  }
  
  /// Shows a standardized error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  /// Shows a standardized success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  /// Shows a standardized info snackbar
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Extension on BuildContext to easily show error snackbars
extension ErrorHandlingContext on BuildContext {
  /// Shows an error snackbar
  void showErrorSnackBar(String message) {
    ErrorHandler.showErrorSnackBar(this, message);
  }
  
  /// Shows a success snackbar
  void showSuccessSnackBar(String message) {
    ErrorHandler.showSuccessSnackBar(this, message);
  }
  
  /// Shows an info snackbar
  void showInfoSnackBar(String message) {
    ErrorHandler.showInfoSnackBar(this, message);
  }
}
