import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:immigru/domain/entities/auth_context.dart';
import 'package:immigru/domain/repositories/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Session manager for handling authentication state across the app
class SessionManager extends ChangeNotifier {
  final AuthService _authService;
  
  /// Current authentication state
  AuthState _authState = const AuthState(AuthChangeEvent.initialSession, null);
  
  /// Stream subscription for auth state changes
  StreamSubscription<AuthState>? _authSubscription;
  
  /// Constructor
  SessionManager(this._authService) {
    _initAuthListener();
  }
  
  /// Initialize the authentication state listener
  void _initAuthListener() {
    _authSubscription = _authService.onAuthStateChange.listen((state) {
      _authState = state;
      notifyListeners();
    });
  }
  
  /// Get the current authentication context
  AuthContext get authContext => _authService.authContext;
  
  /// Get the current authentication state
  AuthState get authState => _authState;
  
  /// Check if the user is authenticated
  bool get isAuthenticated => _authService.authContext.isAuthenticated;
  
  /// Get the current user ID
  String? get userId => _authService.authContext.userId;
  
  /// Get the current user email
  String? get userEmail => _authService.authContext.userEmail;
  
  /// Get the current user phone
  String? get userPhone => _authService.authContext.userPhone;
  
  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email, 
    required String password,
  }) async {
    final response = await _authService.signInWithEmail(
      email: email, 
      password: password,
    );
    return response;
  }
  
  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email, 
    required String password,
  }) async {
    final response = await _authService.signUpWithEmail(
      email: email, 
      password: password,
    );
    return response;
  }
  
  /// Sign in with phone number using OTP
  Future<AuthResponse> signInWithPhone({
    required String phone,
    required String otpCode,
  }) async {
    final response = await _authService.signInWithPhone(
      phone: phone,
      otpCode: otpCode,
    );
    return response;
  }
  
  /// Send OTP to phone number for verification
  Future<void> sendOtpToPhone({
    required String phone,
  }) async {
    await _authService.sendOtpToPhone(phone: phone);
  }
  
  /// Sign in with Google OAuth
  Future<AuthResponse> signInWithGoogle() async {
    final response = await _authService.signInWithGoogle();
    return response;
  }
  
  /// Sign out the current user
  Future<void> signOut() async {
    await _authService.signOut();
  }
  
  /// Reset password for a user
  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }
  
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
