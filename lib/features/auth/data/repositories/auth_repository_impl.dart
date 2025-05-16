import 'package:immigru/features/auth/data/datasources/auth_data_source.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of the AuthRepository interface
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  /// Constructor
  AuthRepositoryImpl(this._dataSource);

  @override
  Future<User?> getCurrentUser() {
    return _dataSource.getCurrentUser();
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) {
    return _dataSource.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<void> signInWithPhone(String phoneNumber) {
    return _dataSource.signInWithPhone(phoneNumber);
  }

  @override
  Future<User> verifyPhoneCode(String verificationId, String code) {
    return _dataSource.verifyPhoneCode(verificationId, code);
  }

  @override
  Future<User> signInWithGoogle() {
    return _dataSource.signInWithGoogle();
  }

  @override
  Future<User> signUpWithEmailAndPassword(String email, String password) {
    return _dataSource.signUpWithEmailAndPassword(email, password);
  }

  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }

  @override
  Future<void> resetPassword(String email) {
    return _dataSource.resetPassword(email);
  }

  @override
  Future<bool> isAuthenticated() {
    return _dataSource.isAuthenticated();
  }

  @override
  Stream<User?> get authStateChanges => _dataSource.authStateChanges;
}
