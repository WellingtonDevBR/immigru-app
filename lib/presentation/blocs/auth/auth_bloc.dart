import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/core/services/session_manager.dart';
import 'package:immigru/domain/entities/user.dart';
import 'package:immigru/domain/usecases/auth_usecases.dart';
import 'package:immigru/presentation/blocs/auth/auth_event.dart';
import 'package:immigru/presentation/blocs/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SessionManager _sessionManager;
  final SendOtpToPhoneUseCase _sendOtpToPhoneUseCase;
  final VerifyPhoneOtpUseCase _verifyPhoneOtpUseCase;
  final LoggerService _logger = LoggerService();
  
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
        metadata: event.agreeToTerms ? {'agreed_to_terms': true} : null,
      );
      
      if (response.user != null) {
        final user = User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          name: event.name ?? 'User',
        );
        
        // Check if email confirmation is required
        // Supabase returns session as null when email verification is needed
        final bool emailConfirmationRequired = response.session == null && 
                                             response.user != null && 
                                             response.user!.emailConfirmedAt == null;
        
        if (emailConfirmationRequired) {
          _logger.debug('AuthBloc', 'Email verification required for user: ${user.email}');
          emit(AuthState.emailVerificationNeeded(user));
        } else {
          emit(AuthState.authenticated(user));
        }
      } else {
        emit(AuthState.error('Signup failed'));
      }
    } catch (e) {
      _logger.error('AuthBloc', 'Error during signup', error: e);
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
      
      _logger.debug('Auth', 'Checking authentication status');
      
      // Check if the user is already logged in using SessionManager
      final currentUser = await _sessionManager.getCurrentUser();
      
      if (currentUser != null) {
        _logger.debug('Auth', 'User is already authenticated: ${currentUser.email}');
        emit(AuthState.authenticated(currentUser));
      } else {
        _logger.debug('Auth', 'User is not authenticated');
        emit(AuthState.initial());
      }
    } catch (e) {
      _logger.error('Auth', 'Error checking authentication status: $e');
      emit(AuthState.error(e.toString()));
    }
  }
}
