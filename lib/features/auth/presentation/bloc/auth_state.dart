import 'package:equatable/equatable.dart';
import 'package:immigru/features/auth/domain/entities/auth_error.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';

/// Authentication state
class AuthState extends Equatable {
  /// Whether the app is loading
  final bool isLoading;
  
  /// Whether the user is authenticated
  final bool isAuthenticated;
  
  /// The current user
  final User? user;
  
  /// Error message
  final String? errorMessage;
  
  /// Error code for categorizing errors
  final String? errorCode;
  
  /// Phone verification ID (for phone authentication)
  final String? verificationId;
  
  /// Whether the phone verification code has been sent
  final bool isCodeSent;

  /// Constructor
  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.errorMessage,
    this.errorCode,
    this.verificationId,
    this.isCodeSent = false,
  });

  /// Initial state
  factory AuthState.initial() => const AuthState();

  /// Loading state
  AuthState loading() => copyWith(
        isLoading: true,
        errorMessage: null,
      );

  /// Authenticated state
  AuthState authenticated(User user) => copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        errorMessage: null,
      );

  /// Unauthenticated state
  AuthState unauthenticated() => copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        errorMessage: null,
      );

  /// Error state with message only
  AuthState error(String message) => copyWith(
        isLoading: false,
        errorMessage: message,
        errorCode: 'unknown',
      );
      
  /// Error state with code
  AuthState errorWithCode(String message, String code) => copyWith(
        isLoading: false,
        errorMessage: message,
        errorCode: code,
      );
      
  /// Error state from AuthError
  AuthState errorFromAuthError(AuthError error) => copyWith(
        isLoading: false,
        errorMessage: error.message,
        errorCode: error.code,
      );

  /// Phone verification code sent state
  AuthState codeSent(String verificationId) => copyWith(
        isLoading: false,
        verificationId: verificationId,
        isCodeSent: true,
        errorMessage: null,
      );

  /// Create a copy of this state with the given fields replaced with new values
  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? errorMessage,
    String? errorCode,
    String? verificationId,
    bool? isCodeSent,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      errorMessage: errorMessage,
      errorCode: errorCode,
      verificationId: verificationId ?? this.verificationId,
      isCodeSent: isCodeSent ?? this.isCodeSent,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isAuthenticated,
        user,
        errorMessage,
        errorCode,
        verificationId,
        isCodeSent,
      ];
}
