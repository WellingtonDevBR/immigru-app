import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/auth/domain/entities/auth_error.dart';
import 'package:immigru/features/auth/domain/usecases/login_usecase.dart';
import 'package:immigru/features/auth/domain/usecases/logout_usecase.dart';
import 'package:immigru/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:immigru/features/auth/domain/usecases/signup_usecase.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_event.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_state.dart';

/// BLoC for authentication
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmailUseCase _loginWithEmailUseCase;
  final LoginWithPhoneUseCase _loginWithPhoneUseCase;
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;
  final LogoutUseCase _logoutUseCase;
  final SignUpWithEmailUseCase _signUpWithEmailUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  
  StreamSubscription? _authStateSubscription;

  /// Constructor
  AuthBloc({
    required LoginWithEmailUseCase loginWithEmailUseCase,
    required LoginWithPhoneUseCase loginWithPhoneUseCase,
    required LoginWithGoogleUseCase loginWithGoogleUseCase,
    required LogoutUseCase logoutUseCase,
    required SignUpWithEmailUseCase signUpWithEmailUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
  })  : _loginWithEmailUseCase = loginWithEmailUseCase,
        _loginWithPhoneUseCase = loginWithPhoneUseCase,
        _loginWithGoogleUseCase = loginWithGoogleUseCase,
        _logoutUseCase = logoutUseCase,
        _signUpWithEmailUseCase = signUpWithEmailUseCase,
        _checkAuthStatusUseCase = checkAuthStatusUseCase,
        _resetPasswordUseCase = resetPasswordUseCase,
        super(AuthState.initial()) {
    on<AuthCheckStatusEvent>(_onCheckAuthStatus);
    on<AuthSignInWithEmailEvent>(_onSignInWithEmail);
    on<AuthStartPhoneAuthEvent>(_onStartPhoneAuth);
    on<AuthVerifyPhoneCodeEvent>(_onVerifyPhoneCode);
    on<AuthSignInWithGoogleEvent>(_onSignInWithGoogle);
    on<AuthSignUpWithEmailEvent>(_onSignUpWithEmail);
    on<AuthSignOutEvent>(_onSignOut);
    on<AuthResetPasswordEvent>(_onResetPassword);
    on<AuthClearErrorEvent>(_onClearError);
    on<AuthSetErrorEvent>(_onSetError);
    
    // Listen to auth state changes
    initAuthStateSubscription();
  }

  void initAuthStateSubscription() {
    _authStateSubscription?.cancel();
    _authStateSubscription = _checkAuthStatusUseCase.authStateChanges.listen((user) {
      if (user != null) {
        // User is signed in, update the auth state
        add(AuthCheckStatusEvent());
      } else {
        // User is signed out, update the auth state
        add(AuthCheckStatusEvent());
      }
    });
  }

  Future<void> _onCheckAuthStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());
    try {
      final isAuthenticated = await _checkAuthStatusUseCase();
      if (isAuthenticated) {
        final user = await _checkAuthStatusUseCase.getCurrentUser();
        if (user != null) {
          emit(state.authenticated(user));
        } else {
          emit(state.unauthenticated());
        }
      } else {
        emit(state.unauthenticated());
      }
    } catch (e) {
      if (kDebugMode) {
        print('Auth status check error: ${e.toString()}');
      }
      emit(state.error('Unable to verify authentication status. Please try again.'));
    }
  }

  Future<void> _onSignInWithEmail(
    AuthSignInWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());
    try {
      final user = await _loginWithEmailUseCase(event.email, event.password);
      emit(state.authenticated(user));
    } catch (e) {
      if (kDebugMode) {
        print('Sign in error: ${e.toString()}');
      }
      
      if (e is AuthError) {
        final errorState = state.errorFromAuthError(e);
        if (kDebugMode) {
          print('Emitting error state: ${errorState.errorMessage} with code: ${errorState.errorCode}');
        }
        emit(errorState);
      } else {
        final errorMessage = 'Failed to sign in. Please check your credentials and try again.';
        if (kDebugMode) {
          print('Emitting generic error: $errorMessage');
        }
        emit(state.error(errorMessage));
      }
    }
  }

  Future<void> _onStartPhoneAuth(
    AuthStartPhoneAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());
    try {
      await _loginWithPhoneUseCase.startPhoneAuth(event.phoneNumber);
      emit(state.codeSent(event.phoneNumber));
    } catch (e) {
      if (kDebugMode) {
        print('Phone auth start error: ${e.toString()}');
      }
      
      if (e is AuthError) {
        final errorState = state.errorFromAuthError(e);
        if (kDebugMode) {
          print('Emitting error state: ${errorState.errorMessage} with code: ${errorState.errorCode}');
        }
        emit(errorState);
      } else {
        final errorMessage = 'Failed to send verification code. Please check your phone number and try again.';
        if (kDebugMode) {
          print('Emitting generic error: $errorMessage');
        }
        emit(state.error(errorMessage));
      }
    }
  }

  Future<void> _onVerifyPhoneCode(
    AuthVerifyPhoneCodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());
    try {
      final user = await _loginWithPhoneUseCase.verifyCode(
        event.verificationId,
        event.code,
      );
      emit(state.authenticated(user));
    } catch (e) {
      if (kDebugMode) {
        print('Phone code verification error: ${e.toString()}');
      }
      
      if (e is AuthError) {
        final errorState = state.errorFromAuthError(e);
        if (kDebugMode) {
          print('Emitting error state: ${errorState.errorMessage} with code: ${errorState.errorCode}');
        }
        emit(errorState);
      } else if (e.toString().contains('invalid')) {
        final errorMessage = 'Invalid verification code. Please try again.';
        if (kDebugMode) {
          print('Emitting generic error: $errorMessage');
        }
        emit(state.error(errorMessage));
      } else {
        final errorMessage = 'Failed to verify code. Please try again.';
        if (kDebugMode) {
          print('Emitting generic error: $errorMessage');
        }
        emit(state.error(errorMessage));
      }
    }
  }

  Future<void> _onSignInWithGoogle(
    AuthSignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());
    try {
      final user = await _loginWithGoogleUseCase();
      emit(state.authenticated(user));
    } catch (e) {
      if (kDebugMode) {
        print('Google sign in error: ${e.toString()}');
      }
      
      if (e is AuthError) {
        final errorState = state.errorFromAuthError(e);
        if (kDebugMode) {
          print('Emitting error state: ${errorState.errorMessage} with code: ${errorState.errorCode}');
        }
        emit(errorState);
      } else if (e.toString().contains('canceled') || e.toString().contains('cancelled')) {
        final errorMessage = 'Google sign-in was cancelled.';
        if (kDebugMode) {
          print('Emitting generic error: $errorMessage');
        }
        emit(state.error(errorMessage));
      } else if (e.toString().contains('network')) {
        final errorMessage = 'Network error. Please check your connection and try again.';
        if (kDebugMode) {
          print('Emitting generic error: $errorMessage');
        }
        emit(state.error(errorMessage));
      } else {
        final errorMessage = 'Failed to sign in with Google. Please try again.';
        if (kDebugMode) {
          print('Emitting generic error: $errorMessage');
        }
        emit(state.error(errorMessage));
      }
    }
  }

  Future<void> _onSignUpWithEmail(
    AuthSignUpWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());
    try {
      final user = await _signUpWithEmailUseCase(event.email, event.password);
      emit(state.authenticated(user));
    } catch (e) {
      if (kDebugMode) {
        print('Sign up error: ${e.toString()}');
      }
      
      if (e is AuthError) {
        final errorState = state.errorFromAuthError(e);
        if (kDebugMode) {
          print('Emitting error state: ${errorState.errorMessage} with code: ${errorState.errorCode}');
        }
        emit(errorState);
      } else if (e.toString().contains('already') || e.toString().contains('exists')) {
        final errorMessage = 'This email is already registered. Please try logging in instead.';
        if (kDebugMode) {
          print('Emitting generic error: $errorMessage');
        }
        emit(state.error(errorMessage));
      } else if (e.toString().toLowerCase().contains('password')) {
        final errorMessage = 'Password is too weak. Please use a stronger password.';
        if (kDebugMode) {
          print('Emitting generic error: $errorMessage');
        }
        emit(state.error(errorMessage));
      } else if (e.toString().contains('network')) {
        final errorMessage = 'Network error. Please check your connection and try again.';
        if (kDebugMode) {
          print('Emitting generic error: $errorMessage');
        }
        emit(state.error(errorMessage));
      } else {
        final errorMessage = 'Failed to create account. Please try again.';
        if (kDebugMode) {
          print('Emitting generic error: $errorMessage');
        }
        emit(state.error(errorMessage));
      }
    }
  }

  Future<void> _onSignOut(
    AuthSignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());
    try {
      await _logoutUseCase();
      emit(state.unauthenticated());
    } catch (e) {
      if (kDebugMode) {
        print('Sign out error: ${e.toString()}');
      }
      
      // Even if sign out fails, we still want to show the user as signed out in the UI
      // This prevents the user from being stuck in a logged-in state in the UI
      emit(state.unauthenticated());
    }
  }

  Future<void> _onResetPassword(
    AuthResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());
    try {
      // Call the resetPassword use case
      await _resetPasswordUseCase(email: event.email);
      
      // Always return success regardless of whether the email exists
      // This is a security best practice to prevent email enumeration attacks
      emit(state.copyWith(
        isLoading: false,
        errorMessage: null,
      ));
      
      if (kDebugMode) {
        print('Password reset email sent or would have been sent if account exists');
      }
    } catch (e) {
      // For security reasons, don't reveal specific errors
      // Just log them for debugging purposes
      if (kDebugMode) {
        print('Error in reset password flow: ${e.toString()}');
      }
      
      // Still show success to the user to prevent email enumeration
      emit(state.copyWith(
        isLoading: false,
        errorMessage: null,
      ));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
  
  /// Handle clear error event
  Future<void> _onClearError(AuthClearErrorEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(errorMessage: null, errorCode: null));
  }
  
  /// Handle set error event
  Future<void> _onSetError(AuthSetErrorEvent event, Emitter<AuthState> emit) async {
    // Set the error message
    emit(state.copyWith(errorMessage: event.message, errorCode: event.code));
    
    // Automatically clear the error after 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    // Only clear if the current error message matches what we set
    // This prevents clearing a different error that might have been set in the meantime
    if (state.errorMessage == event.message) {
      emit(state.copyWith(errorMessage: null, errorCode: null));
    }
  }
}
