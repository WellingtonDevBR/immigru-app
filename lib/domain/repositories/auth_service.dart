import 'package:immigru/domain/entities/auth_context.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract service for authentication operations
abstract class AuthService {
  /// Get the current authentication context
  AuthContext get authContext;
  
  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email, 
    required String password,
  });
  
  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email, 
    required String password,
  });
  
  /// Sign in with phone number using OTP
  Future<AuthResponse> signInWithPhone({
    required String phone,
    required String otpCode,
  });
  
  /// Send OTP to phone number for verification
  Future<void> sendOtpToPhone({
    required String phone,
  });
  
  /// Sign in with Google OAuth
  Future<AuthResponse> signInWithGoogle();
  
  /// Sign out the current user
  Future<void> signOut();
  
  /// Reset password for a user
  Future<void> resetPassword(String email);
  
  /// Get a stream of authentication state changes
  Stream<AuthState> get onAuthStateChange;
  
  /// Check if the user's email is verified
  bool get isEmailVerified;
  
  /// Check if the user's phone is verified
  bool get isPhoneVerified;
}
