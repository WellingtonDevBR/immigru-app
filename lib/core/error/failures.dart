import 'package:immigru/core/network/models/failure.dart';

/// Represents a failure that occurred on the server.
class ServerFailure extends Failure {
  /// Creates a new [ServerFailure] instance.
  ///
  /// [message] is required and describes the failure.
  /// [code] is optional and can be used to provide an error code.
  /// [exception] is optional and can be used to provide the exception that caused the failure.
  const ServerFailure({
    required super.message,
    super.code,
    super.exception,
  });
}

/// Represents a failure that occurred due to a cache operation.
class CacheFailure extends Failure {
  /// Creates a new [CacheFailure] instance.
  ///
  /// [message] is required and describes the failure.
  /// [code] is optional and can be used to provide an error code.
  /// [exception] is optional and can be used to provide the exception that caused the failure.
  const CacheFailure({
    required super.message,
    super.code,
    super.exception,
  });
}

/// Represents a failure that occurred due to validation errors.
class ValidationFailure extends Failure {
  /// Creates a new [ValidationFailure] instance.
  ///
  /// [message] is required and describes the failure.
  /// [code] is optional and can be used to provide an error code.
  /// [exception] is optional and can be used to provide the exception that caused the failure.
  const ValidationFailure({
    required super.message,
    super.code,
    super.exception,
  });
}

/// Represents a failure that occurred during authentication operations.
class AuthFailure extends Failure {
  /// The original error that caused this failure, useful for specific error handling
  final dynamic originalError;

  /// Creates a new [AuthFailure] instance.
  ///
  /// [message] is required and describes the failure.
  /// [code] is optional and can be used to provide an error code.
  /// [exception] is optional and can be used to provide the exception that caused the failure.
  /// [originalError] is optional and can be used to provide the original error object.
  const AuthFailure({
    required super.message,
    super.code,
    super.exception,
    this.originalError,
  });
}
