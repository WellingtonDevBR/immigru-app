import 'package:equatable/equatable.dart';
import 'package:immigru/domain/entities/user.dart';

class AuthState extends Equatable {
  final User? user;
  final bool isLoading;
  final bool isAuthenticated;
  final bool hasError;
  final String? errorMessage;
  final bool isOtpSent;
  final bool isPasswordResetSent;
  final bool needsEmailVerification;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.hasError = false,
    this.errorMessage,
    this.isOtpSent = false,
    this.isPasswordResetSent = false,
    this.needsEmailVerification = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isAuthenticated,
    bool? hasError,
    String? errorMessage,
    bool? isOtpSent,
    bool? isPasswordResetSent,
    bool? needsEmailVerification,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      isPasswordResetSent: isPasswordResetSent ?? this.isPasswordResetSent,
      needsEmailVerification: needsEmailVerification ?? this.needsEmailVerification,
    );
  }

  factory AuthState.initial() {
    return const AuthState();
  }

  factory AuthState.loading() {
    return const AuthState(isLoading: true);
  }

  factory AuthState.authenticated(User user) {
    return AuthState(
      user: user,
      isAuthenticated: true,
    );
  }

  factory AuthState.error(String message) {
    return AuthState(
      hasError: true,
      errorMessage: message,
    );
  }
  
  factory AuthState.otpSent() {
    return const AuthState(
      isOtpSent: true,
    );
  }
  
  factory AuthState.passwordResetSent() {
    return const AuthState(
      isPasswordResetSent: true,
    );
  }
  
  factory AuthState.emailVerificationNeeded(User user) {
    return AuthState(
      user: user,
      needsEmailVerification: true,
      isLoading: false,
    );
  }

  @override
  List<Object?> get props => [user, isLoading, isAuthenticated, hasError, errorMessage, isOtpSent, isPasswordResetSent, needsEmailVerification];
}
