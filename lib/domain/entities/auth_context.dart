import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract representation of authentication context
/// 
/// This class provides a clean interface for accessing authentication state
/// and user information throughout the application.
abstract class AuthContext {
  /// The current authenticated user, or null if not authenticated
  User? get currentUser;
  
  /// The current session, or null if not authenticated
  Session? get currentSession;
  
  /// Whether the user is currently authenticated
  bool get isAuthenticated;
  
  /// The user's unique identifier, or null if not authenticated
  String? get userId;
  
  /// The user's email address, or null if not available
  String? get userEmail;
  
  /// The user's phone number, or null if not available
  String? get userPhone;
  
  /// Stream of authentication state changes
  Stream<AuthState> get onAuthStateChange;
}
