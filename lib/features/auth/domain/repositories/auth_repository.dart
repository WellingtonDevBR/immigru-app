import 'package:immigru/features/auth/domain/entities/user.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Get the current authenticated user
  Future<User?> getCurrentUser();
  
  /// Sign in with email and password
  Future<User> signInWithEmailAndPassword(String email, String password);
  
  /// Sign in with phone number
  Future<void> signInWithPhone(String phoneNumber);
  
  /// Verify phone authentication code
  Future<User> verifyPhoneCode(String verificationId, String code);
  
  /// Sign in with Google
  Future<User> signInWithGoogle();
  
  /// Sign up with email and password
  Future<User> signUpWithEmailAndPassword(String email, String password);
  
  /// Sign out the current user
  Future<void> signOut();
  
  /// Reset password for the given email
  Future<void> resetPassword(String email);
  
  /// Check if the user is authenticated
  Future<bool> isAuthenticated();
  
  /// Get authentication state stream
  Stream<User?> get authStateChanges;
}
