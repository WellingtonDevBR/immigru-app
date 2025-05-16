import 'package:equatable/equatable.dart';

/// Base class for all auth events
abstract class AuthEvent extends Equatable {
  /// Constructor
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check the authentication status
class AuthCheckStatusEvent extends AuthEvent {}

/// Event to sign in with email and password
class AuthSignInWithEmailEvent extends AuthEvent {
  /// Email address
  final String email;
  
  /// Password
  final String password;

  /// Constructor
  const AuthSignInWithEmailEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Event to start phone authentication
class AuthStartPhoneAuthEvent extends AuthEvent {
  /// Phone number
  final String phoneNumber;

  /// Constructor
  const AuthStartPhoneAuthEvent({
    required this.phoneNumber,
  });

  @override
  List<Object> get props => [phoneNumber];
}

/// Event to verify phone authentication code
class AuthVerifyPhoneCodeEvent extends AuthEvent {
  /// Verification ID
  final String verificationId;
  
  /// SMS code
  final String code;

  /// Constructor
  const AuthVerifyPhoneCodeEvent({
    required this.verificationId,
    required this.code,
  });

  @override
  List<Object> get props => [verificationId, code];
}

/// Event to sign in with Google
class AuthSignInWithGoogleEvent extends AuthEvent {}

/// Event to sign up with email and password
class AuthSignUpWithEmailEvent extends AuthEvent {
  /// Email address
  final String email;
  
  /// Password
  final String password;

  /// Constructor
  const AuthSignUpWithEmailEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Event to sign out
class AuthSignOutEvent extends AuthEvent {}

/// Event to reset password
class AuthResetPasswordEvent extends AuthEvent {
  /// Email address
  final String email;

  /// Constructor
  const AuthResetPasswordEvent({
    required this.email,
  });

  @override
  List<Object> get props => [email];
}

/// Event to clear error messages
class AuthClearErrorEvent extends AuthEvent {}

/// Event to set a specific error message
class AuthSetErrorEvent extends AuthEvent {
  /// Error message
  final String message;
  
  /// Error code
  final String? code;

  /// Constructor
  const AuthSetErrorEvent({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

