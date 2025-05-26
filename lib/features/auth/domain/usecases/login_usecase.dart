import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/features/auth/domain/repositories/auth_repository.dart';

/// Use case for user login with email and password
class LoginWithEmailUseCase {
  final AuthRepository _repository;

  /// Constructor
  LoginWithEmailUseCase(this._repository);

  /// Execute the login use case
  /// 
  /// Returns Either a User on success or a Failure on errorF
  Future<Either<Failure, User>> call(String email, String password) {
    return _repository.signInWithEmailAndPassword(email, password);
  }
}

/// Use case for user login with phone
class LoginWithPhoneUseCase {
  final AuthRepository _repository;

  /// Constructor
  LoginWithPhoneUseCase(this._repository);

  /// Start the phone authentication process
  /// 
  /// Returns Either void on success or a Failure on error
  Future<Either<Failure, void>> startPhoneAuth(String phoneNumber) {
    return _repository.signInWithPhone(phoneNumber);
  }

  /// Verify the phone authentication code
  /// 
  /// Returns Either a User on success or a Failure on error
  Future<Either<Failure, User>> verifyCode(String verificationId, String code) {
    return _repository.verifyPhoneCode(verificationId, code);
  }
}

/// Use case for user login with Google
class LoginWithGoogleUseCase {
  final AuthRepository _repository;

  /// Constructor
  LoginWithGoogleUseCase(this._repository);

  /// Execute the Google login use case
  /// 
  /// Returns Either a User on success or a Failure on error
  Future<Either<Failure, User>> call() {
    return _repository.signInWithGoogle();
  }
}

/// Use case for checking authentication status
class CheckAuthStatusUseCase {
  final AuthRepository _repository;

  /// Constructor
  CheckAuthStatusUseCase(this._repository);

  /// Execute the check auth status use case
  /// 
  /// Returns Either a boolean on success or a Failure on error
  Future<Either<Failure, bool>> call() {
    return _repository.isAuthenticated();
  }

  /// Get the current user
  /// 
  /// Returns Either a User object or null on success, or a Failure on error
  Future<Either<Failure, User?>> getCurrentUser() {
    return _repository.getCurrentUser();
  }

  /// Get authentication state changes
  Stream<User?> get authStateChanges => _repository.authStateChanges;
}
