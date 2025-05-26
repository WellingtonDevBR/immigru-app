import 'package:dartz/dartz.dart';
import 'package:immigru/core/error/error_handler.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/auth/data/datasources/auth_data_source.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of the AuthRepository interface
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  /// Constructor
  AuthRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await _dataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(ErrorHandler.instance.handleException(
        e,
        tag: 'AuthRepositoryImpl',
        customMessage: 'Failed to get current user',
      ));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword(String email, String password) async {
    try {
      final user = await _dataSource.signInWithEmailAndPassword(email, password);
      return Right(user);
    } catch (e) {
      return Left(ErrorHandler.instance.handleException(
        e,
        tag: 'AuthRepositoryImpl',
        customMessage: 'Failed to sign in with email and password',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> signInWithPhone(String phoneNumber) async {
    try {
      await _dataSource.signInWithPhone(phoneNumber);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.instance.handleException(
        e,
        tag: 'AuthRepositoryImpl',
        customMessage: 'Failed to sign in with phone',
      ));
    }
  }

  @override
  Future<Either<Failure, User>> verifyPhoneCode(String verificationId, String code) async {
    try {
      final user = await _dataSource.verifyPhoneCode(verificationId, code);
      return Right(user);
    } catch (e) {
      return Left(ErrorHandler.instance.handleException(
        e,
        tag: 'AuthRepositoryImpl',
        customMessage: 'Failed to verify phone code',
      ));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final user = await _dataSource.signInWithGoogle();
      return Right(user);
    } catch (e) {
      return Left(ErrorHandler.instance.handleException(
        e,
        tag: 'AuthRepositoryImpl',
        customMessage: 'Failed to sign in with Google',
      ));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final user = await _dataSource.signUpWithEmailAndPassword(email, password);
      return Right(user);
    } catch (e) {
      return Left(ErrorHandler.instance.handleException(
        e,
        tag: 'AuthRepositoryImpl',
        customMessage: 'Failed to sign up with email and password',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.instance.handleException(
        e,
        tag: 'AuthRepositoryImpl',
        customMessage: 'Failed to sign out',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _dataSource.resetPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.instance.handleException(
        e,
        tag: 'AuthRepositoryImpl',
        customMessage: 'Failed to reset password',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final isAuth = await _dataSource.isAuthenticated();
      return Right(isAuth);
    } catch (e) {
      return Left(ErrorHandler.instance.handleException(
        e,
        tag: 'AuthRepositoryImpl',
        customMessage: 'Failed to check authentication status',
      ));
    }
  }

  @override
  Stream<User?> get authStateChanges => _dataSource.authStateChanges;
}
