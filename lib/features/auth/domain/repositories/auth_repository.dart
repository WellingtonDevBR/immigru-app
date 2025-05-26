import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Get the current authenticated user
  /// 
  /// Returns a User object if authenticated, null if not authenticated,
  /// or a Failure if an error occurs
  Future<Either<Failure, User?>> getCurrentUser();
  
  /// Sign in with email and password
  /// 
  /// Returns a User object on success or a Failure on error
  Future<Either<Failure, User>> signInWithEmailAndPassword(String email, String password);
  
  /// Sign in with phone number
  /// 
  /// Returns void on success or a Failure on error
  Future<Either<Failure, void>> signInWithPhone(String phoneNumber);
  
  /// Verify phone authentication code
  /// 
  /// Returns a User object on success or a Failure on error
  Future<Either<Failure, User>> verifyPhoneCode(String verificationId, String code);
  
  /// Sign in with Google
  /// 
  /// Returns a User object on success or a Failure on error
  Future<Either<Failure, User>> signInWithGoogle();
  
  /// Sign up with email and password
  /// 
  /// Returns a User object on success or a Failure on error
  Future<Either<Failure, User>> signUpWithEmailAndPassword(String email, String password);
  
  /// Sign out the current user
  /// 
  /// Returns void on success or a Failure on error
  Future<Either<Failure, void>> signOut();
  
  /// Reset password for the given email
  /// 
  /// Returns void on success or a Failure on error
  Future<Either<Failure, void>> resetPassword(String email);
  
  /// Check if the user is authenticated
  /// 
  /// Returns a boolean indicating authentication status or a Failure on error
  Future<Either<Failure, bool>> isAuthenticated();
  
  /// Get authentication state stream
  /// 
  /// This stream emits User objects when the auth state changes
  Stream<User?> get authStateChanges;
}
