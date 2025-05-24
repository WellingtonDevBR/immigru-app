/// Exception thrown when there is a server error
class ServerException implements Exception {
  /// Error message
  final String message;

  /// Create a new ServerException
  ServerException({required this.message});

  @override
  String toString() => 'ServerException: $message';
}

/// Exception thrown when there is a cache error
class CacheException implements Exception {
  /// Error message
  final String message;

  /// Create a new CacheException
  CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

/// Exception thrown when there is a validation error
class ValidationException implements Exception {
  /// Error message
  final String message;

  /// Create a new ValidationException
  ValidationException({required this.message});

  @override
  String toString() => 'ValidationException: $message';
}

/// Exception thrown when there is an authentication error
class AuthException implements Exception {
  /// Error message
  final String message;

  /// Create a new AuthException
  AuthException({required this.message});

  @override
  String toString() => 'AuthException: $message';
}
