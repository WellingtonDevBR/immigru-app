import 'package:immigru/data/datasources/supabase_data_source.dart';
import 'package:immigru/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementation of the AuthRepository using the SupabaseDataSource
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  User? get currentUser => _dataSource.currentUser;

  @override
  bool get isAuthenticated => _dataSource.isAuthenticated;

  @override
  Future<void> resetPassword(String email) {
    return _dataSource.resetPassword(email);
  }

  @override
  Future<AuthResponse> signInWithEmail({required String email, required String password}) {
    return _dataSource.signInWithEmail(email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }

  @override
  Future<AuthResponse> signUpWithEmail({required String email, required String password}) {
    return _dataSource.signUpWithEmail(email: email, password: password);
  }
  
  @override
  Future<void> sendOtpToPhone({required String phone}) {
    return _dataSource.sendOtpToPhone(phone: phone);
  }
  
  @override
  Future<AuthResponse> verifyPhoneOtp({required String phone, required String otpCode}) {
    return _dataSource.verifyPhoneOtp(phone: phone, otpCode: otpCode);
  }
}
