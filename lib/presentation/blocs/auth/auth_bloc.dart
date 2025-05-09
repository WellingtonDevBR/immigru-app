import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/services/session_manager.dart';
import 'package:immigru/domain/entities/user.dart';
import 'package:immigru/domain/usecases/auth_usecases.dart';
import 'package:immigru/presentation/blocs/auth/auth_event.dart';
import 'package:immigru/presentation/blocs/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SessionManager _sessionManager;
  final SendOtpToPhoneUseCase _sendOtpToPhoneUseCase;
  final VerifyPhoneOtpUseCase _verifyPhoneOtpUseCase;
  
  AuthBloc({
    required SessionManager sessionManager,
    required SendOtpToPhoneUseCase sendOtpToPhoneUseCase,
    required VerifyPhoneOtpUseCase verifyPhoneOtpUseCase,
  }) : 
    _sessionManager = sessionManager,
    _sendOtpToPhoneUseCase = sendOtpToPhoneUseCase,
    _verifyPhoneOtpUseCase = verifyPhoneOtpUseCase,
    super(AuthState.initial()) {
    on<AuthLoginEvent>(_onLogin);
    on<AuthSignupEvent>(_onSignup);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthGoogleLoginEvent>(_onGoogleLogin);
    on<AuthPhoneLoginEvent>(_onPhoneLogin);
    on<AuthSendOtpEvent>(_onSendOtp);
    on<AuthResetPasswordEvent>(_onResetPassword);
  }

  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthState.loading());
      
      final response = await _sessionManager.signInWithEmail(
        email: event.email,
        password: event.password,
      );
      
      if (response.user != null) {
        final user = User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          name: response.user!.userMetadata?['name'] as String? ?? 'User',
        );
        
        emit(AuthState.authenticated(user));
      } else {
        emit(AuthState.error('Login failed'));
      }
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onSignup(AuthSignupEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthState.loading());
      
      final response = await _sessionManager.signUpWithEmail(
        email: event.email,
        password: event.password,
      );
      
      if (response.user != null) {
        final user = User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          name: event.name ?? 'User',
        );
        
        emit(AuthState.authenticated(user));
      } else {
        emit(AuthState.error('Signup failed'));
      }
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }
  
  Future<void> _onGoogleLogin(AuthGoogleLoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthState.loading());
      
      final response = await _sessionManager.signInWithGoogle();
      
      if (response.user != null) {
        final user = User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          name: response.user!.userMetadata?['name'] as String? ?? 'User',
        );
        
        emit(AuthState.authenticated(user));
      } else {
        emit(AuthState.error('Google login failed'));
      }
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }
  
  Future<void> _onPhoneLogin(AuthPhoneLoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthState.loading());
      
      // Use the dedicated use case for phone verification
      final response = await _verifyPhoneOtpUseCase(
        phone: event.phone,
        otpCode: event.otpCode,
      );
      
      if (response.user != null) {
        final user = User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          name: response.user!.userMetadata?['name'] as String? ?? 'User',
          phone: event.phone, // Use the phone number from the event
        );
        
        emit(AuthState.authenticated(user));
      } else {
        emit(AuthState.error('Phone verification failed'));
      }
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }
  
  Future<void> _onSendOtp(AuthSendOtpEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthState.loading());
      
      // Use the dedicated use case for sending OTP
      await _sendOtpToPhoneUseCase(phone: event.phone);
      
      emit(AuthState.otpSent());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }
  
  Future<void> _onResetPassword(AuthResetPasswordEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthState.loading());
      
      await _sessionManager.resetPassword(event.email);
      
      emit(AuthState.passwordResetSent());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthState.loading());
      
      // This is a mock implementation - in a real app, you would call a repository
      // to sign out the user
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      emit(AuthState.initial());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onCheckStatus(AuthCheckStatusEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthState.loading());
      
      // This is a mock implementation - in a real app, you would check if the user
      // is already logged in (e.g., using shared preferences or a secure storage)
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // For demo purposes, let's assume the user is not logged in
      emit(AuthState.initial());
      
      // If the user was logged in, you would do something like:
      // final user = User(id: '1', email: 'test@example.com', name: 'Test User');
      // emit(AuthState.authenticated(user));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }
}
