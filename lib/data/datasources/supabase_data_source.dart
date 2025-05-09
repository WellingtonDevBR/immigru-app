import 'package:immigru/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract class defining the contract for Supabase data operations
abstract class SupabaseDataSource {
  Future<AuthResponse> signInWithEmail({required String email, required String password});
  Future<AuthResponse> signUpWithEmail({required String email, required String password});
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<void> sendOtpToPhone({required String phone});
  Future<AuthResponse> verifyPhoneOtp({required String phone, required String otpCode});
  Future<List<Map<String, dynamic>>> getDataFromTable(String tableName, {List<String>? columns, String? filter});
  Future<List<Map<String, dynamic>>> insertIntoTable(String tableName, Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> updateInTable(String tableName, Map<String, dynamic> data, {required String filter});
  Future<List<Map<String, dynamic>>> deleteFromTable(String tableName, {required String filter});
  User? get currentUser;
  bool get isAuthenticated;
  SupabaseClient get client;
}

/// Implementation of the SupabaseDataSource using the SupabaseService
class SupabaseDataSourceImpl implements SupabaseDataSource {
  final SupabaseService _supabaseService;

  SupabaseDataSourceImpl(this._supabaseService);

  @override
  User? get currentUser => _supabaseService.currentUser;

  @override
  bool get isAuthenticated => _supabaseService.isAuthenticated;
  
  @override
  SupabaseClient get client => _supabaseService.client;

  @override
  Future<List<Map<String, dynamic>>> deleteFromTable(String tableName, {required String filter}) {
    return _supabaseService.deleteFromTable(tableName, filter: filter);
  }

  @override
  Future<List<Map<String, dynamic>>> getDataFromTable(String tableName, {List<String>? columns, String? filter}) {
    return _supabaseService.getDataFromTable(
      tableName,
      columns: columns,
      filter: filter,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> insertIntoTable(String tableName, Map<String, dynamic> data) {
    return _supabaseService.insertIntoTable(tableName, data);
  }

  @override
  Future<void> resetPassword(String email) {
    return _supabaseService.resetPassword(email);
  }

  @override
  Future<AuthResponse> signInWithEmail({required String email, required String password}) {
    return _supabaseService.signInWithEmail(email: email, password: password);
  }

  @override
  Future<AuthResponse> signUpWithEmail({required String email, required String password}) {
    return _supabaseService.signUpWithEmail(email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return _supabaseService.signOut();
  }
  
  @override
  Future<void> sendOtpToPhone({required String phone}) async {
    await _supabaseService.client.auth.signInWithOtp(phone: phone);
  }
  
  @override
  Future<AuthResponse> verifyPhoneOtp({required String phone, required String otpCode}) async {
    return await _supabaseService.client.auth.verifyOTP(
      phone: phone,
      token: otpCode,
      type: OtpType.sms,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> updateInTable(String tableName, Map<String, dynamic> data, {required String filter}) {
    return _supabaseService.updateInTable(tableName, data, filter: filter);
  }
}
