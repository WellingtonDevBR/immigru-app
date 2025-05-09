import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:immigru/core/config/google_auth_config.dart';
import 'package:immigru/core/services/auth_logger.dart';
import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/core/services/supabase_service.dart';
import 'package:immigru/data/models/supabase_auth_context.dart';
import 'package:immigru/domain/entities/auth_context.dart';
import 'package:immigru/domain/repositories/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementation of AuthService using Supabase
class SupabaseAuthService implements AuthService {
  final SupabaseService _supabaseService;
  late final SupabaseAuthContext _authContext;
  
  /// Constructor
  SupabaseAuthService(this._supabaseService) {
    _authContext = SupabaseAuthContext(_supabaseService);
    
    // Listen for auth state changes and log them
    _supabaseService.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      logger.logAuthEvent(event, session: session);
    });
  }

  @override
  AuthContext get authContext => _authContext;

  @override
  Stream<AuthState> get onAuthStateChange => 
      _supabaseService.client.auth.onAuthStateChange;

  @override
  bool get isEmailVerified => 
      _supabaseService.currentUser?.emailConfirmedAt != null;

  @override
  bool get isPhoneVerified => 
      _supabaseService.currentUser?.phoneConfirmedAt != null;

  @override
  Future<AuthResponse> signInWithEmail({
    required String email, 
    required String password,
  }) async {
    try {
      logger.logSignInAttempt('email', email: email);
      
      final response = await _supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      logger.logSignInSuccess(
        'email', 
        response.user?.id ?? 'unknown',
        email: response.user?.email,
      );
      
      return response;
    } catch (e) {
      logger.logSignInFailure('email', e, email: email);
      rethrow;
    }
  }

  @override
  Future<AuthResponse> signUpWithEmail({
    required String email, 
    required String password,
  }) async {
    try {
      final response = await _supabaseService.client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      debugPrint('Error signing up with email: $e');
      rethrow;
    }
  }

  @override
  Future<AuthResponse> signInWithPhone({
    required String phone,
    required String otpCode,
  }) async {
    try {
      logger.logSignInAttempt('phone', phone: phone);
      
      final response = await _supabaseService.client.auth.verifyOTP(
        phone: phone,
        token: otpCode,
        type: OtpType.sms,
      );
      
      logger.logSignInSuccess(
        'phone', 
        response.user?.id ?? 'unknown',
        phone: phone,
      );
      
      return response;
    } catch (e) {
      logger.logSignInFailure('phone', e, phone: phone);
      rethrow;
    }
  }

  @override
  Future<void> sendOtpToPhone({required String phone}) async {
    try {
      logger.i('Sending OTP to phone: $phone', category: LogCategory.auth);
      
      await _supabaseService.client.auth.signInWithOtp(
        phone: phone,
      );
      
      logger.i('OTP sent successfully to phone: $phone', category: LogCategory.auth);
    } catch (e) {
      logger.e('Error sending OTP to phone: $phone', category: LogCategory.auth, error: e);
      rethrow;
    }
  }

  @override
  Future<AuthResponse> signInWithGoogle() async {
    try {
      logger.logSignInAttempt('Google');
      
      if (kIsWeb) {
        // For web, use the built-in Supabase OAuth flow
        await _supabaseService.client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: Uri.base.origin,
        );
        
        // For web OAuth flow, we don't get a session immediately as the user is redirected
        logger.i('Google sign-in initiated for web', category: LogCategory.auth);
        
        // Return an empty AuthResponse as the actual auth will happen after redirect
        // The app will handle the redirect and complete the auth flow
        return AuthResponse();
      } else {
        // For mobile platforms, use the native Google Sign-In
        return await _nativeGoogleSignIn();
      }
    } catch (e) {
      logger.logSignInFailure('Google', e);
      
      // Provide a more user-friendly error message
      if (e.toString().contains('ApiException: 10')) {
        throw Exception('Google Sign-In failed: Developer configuration error. Please contact support.');
      } else if (e.toString().contains('PlatformException')) {
        throw Exception('Google Sign-In failed: ${e.toString().split(',')[0]}');
      } else {
        rethrow;
      }
    }
  }
  
  /// Native Google Sign-In implementation for mobile platforms
  /// 
  /// This method handles the platform-specific Google Sign-In flow and then
  /// authenticates with Supabase using the obtained tokens.
  Future<AuthResponse> _nativeGoogleSignIn() async {
    try {
      // First, try to sign out from any previous Google Sign-In session
      // This helps prevent cached credentials issues
      final GoogleSignIn googleSignIn = GoogleSignIn();
      try {
        await googleSignIn.signOut();
        logger.i('Signed out of previous Google session', category: LogCategory.auth);
      } catch (e) {
        // Ignore errors during sign out
        logger.i('No previous Google session to sign out from', category: LogCategory.auth);
      }
      
      // Get client IDs from config
      final webClientId = GoogleAuthConfig.webClientId;
      final iosClientId = GoogleAuthConfig.iosClientId;
      
      // Re-initialize Google Sign-In with appropriate client IDs
      final GoogleSignIn newGoogleSignIn = GoogleSignIn(
        clientId: iosClientId,  // Used for iOS
        serverClientId: webClientId,  // Used for Android and as a fallback
        scopes: ['email', 'profile', 'openid'],  // Added openid scope which is required for ID tokens
      );
      
      // Sign in with Google - with additional error handling
      logger.i('Initiating Google sign-in', category: LogCategory.auth);
      final googleUser = await newGoogleSignIn.signIn().catchError((error) {
        logger.e('Error during Google sign-in process', category: LogCategory.auth, error: error);
        throw Exception('Failed to initiate Google sign-in: $error');
      });
      
      if (googleUser == null) {
        logger.w('Google sign-in was canceled by user', category: LogCategory.auth);
        throw Exception('Google sign-in was canceled');
      }
      
      logger.i('Google sign-in successful, getting authentication tokens', category: LogCategory.auth);
      
      // Get auth details from Google with additional error handling
      final googleAuth = await googleUser.authentication.catchError((error) {
        logger.e('Error getting Google authentication tokens', category: LogCategory.auth, error: error);
        throw Exception('Failed to get authentication tokens: $error');
      });
      
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      
      // Log token information (safely)
      logger.i(
        'Received tokens - Access Token: ${accessToken != null ? "[present]" : "[missing]"}' +
        ' ID Token: ${idToken != null ? "[present]" : "[missing]"}',
        category: LogCategory.auth
      );
      
      // Validate tokens
      if (accessToken == null) {
        logger.e('No Access Token received from Google', category: LogCategory.auth);
        throw Exception('No Access Token found. Please try again or contact support.');
      }
      
      if (idToken == null) {
        logger.e('No ID Token received from Google', category: LogCategory.auth);
        throw Exception('No ID Token found. Please try again or contact support.');
      }
      
      // Sign in to Supabase with the Google ID token
      logger.i('Signing in to Supabase with Google tokens', category: LogCategory.auth);
      final response = await _supabaseService.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      ).catchError((error) {
        logger.e('Error signing in to Supabase with Google tokens', category: LogCategory.auth, error: error);
        throw Exception('Failed to authenticate with Supabase: $error');
      });
      
      if (response.user != null) {
        logger.logSignInSuccess(
          'Google', 
          response.user!.id,
          email: response.user!.email,
        );
      } else {
        logger.w('Google sign-in successful but no user returned from Supabase', category: LogCategory.auth);
      }
      
      return response;
    } catch (e) {
      logger.logSignInFailure('Google', e);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final userId = _supabaseService.currentUser?.id;
      final email = _supabaseService.currentUser?.email;
      
      await _supabaseService.client.auth.signOut();
      
      if (userId != null) {
        logger.i('User signed out | User ID: $userId | Email: ${email ?? 'unknown'}', category: LogCategory.auth);
      }
    } catch (e) {
      logger.e('Error signing out', category: LogCategory.auth, error: e);
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      logger.i('Requesting password reset for email: $email', category: LogCategory.auth);
      
      await _supabaseService.client.auth.resetPasswordForEmail(
        email,
        redirectTo: kIsWeb ? null : 'io.supabase.immigru://reset-callback/',
      );
      
      logger.i('Password reset email sent to: $email', category: LogCategory.auth);
    } catch (e) {
      logger.e('Error resetting password for email: $email', category: LogCategory.auth, error: e);
      rethrow;
    }
  }
}
