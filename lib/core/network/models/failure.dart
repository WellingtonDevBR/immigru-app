/// Represents a failure in the application.
/// 
/// This class is used to represent failures that can occur in the application,
/// such as network errors, validation errors, or other types of failures.
class Failure {
  /// The message describing the failure.
  final String message;

  /// Optional error code for the failure.
  final String? code;

  /// Optional exception that caused the failure.
  final dynamic exception;

  /// Creates a new [Failure] instance.
  /// 
  /// [message] is required and describes the failure.
  /// [code] is optional and can be used to provide an error code.
  /// [exception] is optional and can be used to provide the exception that caused the failure.
  const Failure({
    required this.message,
    this.code,
    this.exception,
  });

  @override
  String toString() => 'Failure(message: $message, code: $code, exception: $exception)';
}
