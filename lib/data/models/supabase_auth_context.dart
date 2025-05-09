import 'package:immigru/core/services/supabase_service.dart';
import 'package:immigru/domain/entities/auth_context.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementation of AuthContext using Supabase
class SupabaseAuthContext implements AuthContext {
  final SupabaseService _supabaseService;

  SupabaseAuthContext(this._supabaseService);

  @override
  User? get currentUser => _supabaseService.currentUser;

  @override
  Session? get currentSession => _supabaseService.currentSession;

  @override
  bool get isAuthenticated => _supabaseService.isAuthenticated;

  @override
  String? get userId => currentUser?.id;

  @override
  String? get userEmail => currentUser?.email;

  @override
  String? get userPhone => currentUser?.phone;

  @override
  Stream<AuthState> get onAuthStateChange => 
      _supabaseService.client.auth.onAuthStateChange;
}
