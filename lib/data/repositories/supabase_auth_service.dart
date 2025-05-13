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
    Map<String, dynamic>? metadata,
    String? redirectTo,
  }) async {
    try {
      logger.logSignInAttempt('email_signup', email: email);
      
      final response = await _supabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: metadata,
        emailRedirectTo: redirectTo,
      );
      
      if (response.user != null) {
        logger.logSignInSuccess(
          'email_signup', 
          response.user?.id ?? 'unknown',
          email: response.user?.email,
        );
        
        // Check if email confirmation is required
        final bool emailConfirmationRequired = response.session == null && 
                                              response.user != null && 
                                              response.user!.emailConfirmedAt == null;
        
        if (emailConfirmationRequired) {
          logger.debug('SupabaseAuthService', 'Email confirmation required for user: ${response.user?.email}');
        }
      } else {
        logger.logSignInFailure('email_signup', 'No user returned from signup');
      }
      
      return response;
    } catch (e) {
      logger.logSignInFailure('email_signup', e, email: email);
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
      logger.i('Starting Google Sign-In process', category: LogCategory.auth);
      debugPrint('SupabaseAuthService: Starting Google Sign-In process');
      
      // Get client IDs from config
      final webClientId = GoogleAuthConfig.webClientId;
      final iosClientId = GoogleAuthConfig.iosClientId;
      final androidClientId = GoogleAuthConfig.androidClientId;
      
      debugPrint('SupabaseAuthService: Using web client ID: ${webClientId.substring(0, 10)}...');
      debugPrint('SupabaseAuthService: Using iOS client ID: ${iosClientId.substring(0, 10)}...');
      if (androidClientId.isNotEmpty) {
        debugPrint('SupabaseAuthService: Using Android client ID: ${androidClientId.substring(0, 10)}...');
      }
      
      // Initialize Google Sign-In with appropriate client IDs based on platform
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,  // Used for iOS
        serverClientId: webClientId,  // Used for web and as a fallback
        scopes: ['email', 'profile', 'openid'],  // openid scope is required for ID tokens
      );
      
      // Log the current configuration for debugging
      logger.i('Google Sign-In configured with:' '\nWeb Client ID: ${webClientId.substring(0, 10)}...' +
               '\niOS Client ID: ${iosClientId.substring(0, 10)}...', 
               category: LogCategory.auth);
      
      // Check if user is already signed in
      try {
        final isSignedIn = await googleSignIn.isSignedIn();
        debugPrint('SupabaseAuthService: User is already signed in: $isSignedIn');
        
        // Try to silently sign in if possible
        if (isSignedIn) {
          debugPrint('SupabaseAuthService: Attempting to reuse existing Google session');
          final googleUser = await googleSignIn.signInSilently();
          if (googleUser != null) {
            debugPrint('SupabaseAuthService: Silent sign-in successful for: ${googleUser.email}');
            final googleAuth = await googleUser.authentication;
            final idToken = googleAuth.idToken;
            final accessToken = googleAuth.accessToken;
            
            if (idToken != null) {
              debugPrint('SupabaseAuthService: Got valid ID token from silent sign-in, proceeding to Supabase auth');
              return await _signInToSupabaseWithGoogleTokens(idToken, accessToken);
            }
          }
        }
      } catch (e) {
        // Ignore errors during silent sign-in check
        debugPrint('SupabaseAuthService: Error checking existing session: $e');
        logger.i('Error checking Google session: $e', category: LogCategory.auth);
      }
      
      // Perform interactive sign-in
      logger.i('Initiating interactive Google sign-in', category: LogCategory.auth);
      debugPrint('SupabaseAuthService: Initiating interactive Google sign-in');
      
      final googleUser = await googleSignIn.signIn();
      
      // Handle user cancellation
      if (googleUser == null) {
        debugPrint('SupabaseAuthService: Google sign-in was canceled by user');
        logger.w('Google sign-in was canceled by user', category: LogCategory.auth);
        throw Exception('Google sign-in was canceled');
      }
      
      debugPrint('SupabaseAuthService: Google sign-in successful for user: ${googleUser.email}');
      logger.i('Google sign-in successful for user: ${googleUser.email}', category: LogCategory.auth);
      
      // Get auth details from Google
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      
      // Log token information (safely)
      debugPrint(
        'SupabaseAuthService: Received tokens - Access Token: ${accessToken != null ? "[present]" : "[missing]"}'
        ' ID Token: ${idToken != null ? "[present]" : "[missing]"}'
      );
      logger.i(
        'Received tokens - Access Token: ${accessToken != null ? "[present]" : "[missing]"}'
        ' ID Token: ${idToken != null ? "[present]" : "[missing]"}',
        category: LogCategory.auth
      );
      
      // Validate tokens
      if (idToken == null) {
        debugPrint('SupabaseAuthService: No ID Token received from Google');
        logger.e('No ID Token received from Google', category: LogCategory.auth);
        throw Exception('Authentication failed: Missing ID token');
      }
      
      return await _signInToSupabaseWithGoogleTokens(idToken, accessToken);
    } catch (e) {
      // Provide more user-friendly error messages
      logger.logSignInFailure('Google', e);
      debugPrint('SupabaseAuthService: Error during Google sign-in: $e');
      
      if (e.toString().contains('network_error')) {
        throw Exception('Google Sign-In failed: Network error. Please check your internet connection.');
      } else if (e.toString().contains('sign_in_failed') || e.toString().contains('sign_in_canceled')) {
        throw Exception('Google Sign-In was canceled or failed. Please try again.');
      } else if (e.toString().contains('ApiException: 10')) {
        throw Exception('Google Sign-In failed: Developer configuration error. Please contact support.');
      } else if (e.toString().contains('PlatformException')) {
        throw Exception('Google Sign-In failed: ${e.toString().split(',')[0]}');
      } else {
        rethrow;
      }
    }
  }
  
  /// Helper method to sign in to Supabase with Google tokens
  Future<AuthResponse> _signInToSupabaseWithGoogleTokens(String idToken, String? accessToken) async {
    debugPrint('SupabaseAuthService: Signing in to Supabase with Google tokens');
    logger.i('Signing in to Supabase with Google tokens', category: LogCategory.auth);
    
    try {
      final response = await _supabaseService.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      if (response.user != null) {
        debugPrint('SupabaseAuthService: Successfully signed in to Supabase with Google: ${response.user!.email}');
        logger.logSignInSuccess(
          'Google', 
          response.user!.id,
          email: response.user!.email,
        );
      } else {
        debugPrint('SupabaseAuthService: Google sign-in successful but no user returned from Supabase');
        logger.w('Google sign-in successful but no user returned from Supabase', category: LogCategory.auth);
      }
      
      return response;
    } catch (supabaseError) {
      debugPrint('SupabaseAuthService: Error signing in to Supabase with Google tokens: $supabaseError');
      logger.e('Error signing in to Supabase with Google tokens', 
        category: LogCategory.auth, error: supabaseError);
      throw Exception('Failed to authenticate with Supabase: $supabaseError');
    }
  }
  
  @override
  Future<void> resetPassword(String email) async {
    try {
      await _supabaseService.client.auth.resetPasswordForEmail(email);
    } catch (e) {
      debugPrint('Error resetting password: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseService.client.auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }
}
