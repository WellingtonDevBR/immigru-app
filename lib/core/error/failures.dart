import 'package:immigru/core/network/models/failure.dart';

/// Represents a failure that occurred on the server.
class ServerFailure extends Failure {
  /// Creates a new [ServerFailure] instance.
  /// 
  /// [message] is required and describes the failure.
  /// [code] is optional and can be used to provide an error code.
  /// [exception] is optional and can be used to provide the exception that caused the failure.
  const ServerFailure({
    required String message,
    String? code,
    dynamic exception,
  }) : super(
          message: message,
          code: code,
          exception: exception,
        );
}

/// Represents a failure that occurred due to a cache operation.
class CacheFailure extends Failure {
  /// Creates a new [CacheFailure] instance.
  /// 
  /// [message] is required and describes the failure.
  /// [code] is optional and can be used to provide an error code.
  /// [exception] is optional and can be used to provide the exception that caused the failure.
  const CacheFailure({
    required String message,
    String? code,
    dynamic exception,
  }) : super(
          message: message,
          code: code,
          exception: exception,
        );
}
