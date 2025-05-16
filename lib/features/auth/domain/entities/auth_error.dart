/// Custom authentication error class
class AuthError implements Exception {
  /// Error message
  final String message;
  
  /// Error code for categorizing errors
  final String code;
  
  /// Whether this error should be displayed to the user
  final bool userVisible;

  /// Constructor
  AuthError({
    required this.message,
    required this.code,
    this.userVisible = true,
  });

  /// Create an invalid credentials error
  factory AuthError.invalidCredentials() {
    return AuthError(
      message: 'The email or password you entered is incorrect.',
      code: 'invalid_credentials',
    );
  }

  /// Create a user not found error
  factory AuthError.userNotFound() {
    return AuthError(
      message: 'No user found with this email address.',
      code: 'user_not_found',
    );
  }

  /// Create an email already in use error
  factory AuthError.emailAlreadyInUse() {
    return AuthError(
      message: 'This email is already registered. Please try logging in instead.',
      code: 'email_already_in_use',
    );
  }

  /// Create a weak password error
  factory AuthError.weakPassword() {
    return AuthError(
      message: 'The password provided is too weak. Please use a stronger password.',
      code: 'weak_password',
    );
  }
  
  /// Create a password length error
  factory AuthError.passwordTooShort() {
    return AuthError(
      message: 'Password must be at least 8 characters long.',
      code: 'password_too_short',
    );
  }
  
  /// Create a password complexity error
  factory AuthError.passwordComplexity() {
    return AuthError(
      message: 'Password must contain uppercase, lowercase, number, and special character.',
      code: 'password_complexity',
    );
  }
  
  /// Create a password mismatch error
  factory AuthError.passwordMismatch() {
    return AuthError(
      message: 'Passwords do not match. Please try again.',
      code: 'password_mismatch',
    );
  }

  /// Create a network error
  factory AuthError.network() {
    return AuthError(
      message: 'A network error occurred. Please check your connection and try again.',
      code: 'network_error',
    );
  }

  /// Create a server error
  factory AuthError.server() {
    return AuthError(
      message: 'A server error occurred. Please try again later.',
      code: 'server_error',
    );
  }

  /// Create a too many requests error
  factory AuthError.tooManyRequests() {
    return AuthError(
      message: 'Too many requests. Please try again later.',
      code: 'too_many_requests',
    );
  }

  /// Create an invalid OTP error
  factory AuthError.invalidOtp() {
    return AuthError(
      message: 'The verification code you entered is invalid. Please try again.',
      code: 'invalid_otp',
    );
  }

  /// Create an unknown error
  factory AuthError.unknown(String errorMessage) {
    return AuthError(
      message: 'An error occurred: $errorMessage',
      code: 'unknown',
    );
  }

  @override
  String toString() => message;
}
