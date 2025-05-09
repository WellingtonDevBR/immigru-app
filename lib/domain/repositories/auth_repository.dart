import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({required String email, required String password});
  
  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({required String email, required String password});
  
  /// Send OTP to phone number
  Future<void> sendOtpToPhone({required String phone});
  
  /// Verify phone OTP and sign in
  Future<AuthResponse> verifyPhoneOtp({required String phone, required String otpCode});
  
  /// Sign out the current user
  Future<void> signOut();
  
  /// Reset password for a user
  Future<void> resetPassword(String email);
  
  /// Get the current user
  User? get currentUser;
  
  /// Check if user is authenticated
  bool get isAuthenticated;
}
