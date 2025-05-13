import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:immigru/core/config/supabase_config.dart';

/// Service class for interacting with Supabase
/// 
/// This class provides a clean interface for accessing Supabase functionality
/// throughout the application, following clean architecture principles.
class SupabaseService {
  late final SupabaseClient _client;
  static SupabaseService? _instance;

  // Private constructor for singleton pattern
  SupabaseService._();

  /// Factory constructor to get the singleton instance
  factory SupabaseService() {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// Initialize Supabase client
  /// 
  /// This method should be called before using any Supabase functionality,
  /// typically during app initialization. Note that Supabase should already
  /// be initialized in main.dart before calling this method.
  Future<void> initialize() async {
    try {
      // Get the already initialized Supabase instance
      _client = Supabase.instance.client;
    } catch (e) {
      print('Error initializing Supabase client: $e');
      // If Supabase is not initialized yet, initialize it
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        debug: true, // Enable debug mode for detailed logging
      );
      _client = Supabase.instance.client;
    }
    
    // Add auth state change listener for debugging
    _client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      
      switch (event) {
        case AuthChangeEvent.signedIn:
          break;
        case AuthChangeEvent.signedOut:
          break;
        case AuthChangeEvent.userUpdated:
          break;
        case AuthChangeEvent.passwordRecovery:
          break;
        case AuthChangeEvent.tokenRefreshed:
          break;
        case AuthChangeEvent.mfaChallengeVerified:
          break;
        default:
          break;
      }
    });
  }

  /// Get the Supabase client instance
  SupabaseClient get client => _client;

  /// Get the current user
  User? get currentUser => _client.auth.currentUser;

  /// Get the current session
  Session? get currentSession => _client.auth.currentSession;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  /// This method is deprecated. Use the implementation in SupabaseAuthService instead.
  /// 
  /// This is kept for backward compatibility but should not be used directly.
  /// The SupabaseAuthService provides a more robust implementation with proper
  /// error handling and logging.
  @Deprecated('Use SupabaseAuthService.signInWithGoogle() instead')
  Future<AuthResponse> signInWithGoogle() async {
    try {
      throw Exception('This method is deprecated. Use SupabaseAuthService.signInWithGoogle() instead.');
    } catch (e) {
      rethrow;
    }
  }

  // The native Google Sign-In implementation has been moved to SupabaseAuthService

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Reset password for a user
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }
  
  /// Send OTP to phone number
  Future<void> sendOtpToPhone({required String phone}) async {
    await _client.auth.signInWithOtp(phone: phone);
  }
  
  /// Verify phone OTP and sign in
  Future<AuthResponse> signInWithPhone({required String phone, required String otpCode}) async {
    return await _client.auth.verifyOTP(
      phone: phone,
      token: otpCode,
      type: OtpType.sms,
    );
  }

  /// Get data from a table
  Future<List<Map<String, dynamic>>> getDataFromTable(
    String tableName, {
    List<String>? columns,
    String? filter,
    List<String>? orderBy,
    int? limit,
    int? offset,
  }) async {
    // Use dynamic type to avoid type casting issues with Supabase query builders
    dynamic query = _client.from(tableName).select(columns?.join(',') ?? '*');

    if (filter != null) {
      // Using eq operator as an example - in real usage, parse the filter string
      // to determine the correct operator and value
      final parts = filter.split(':');
      if (parts.length == 2) {
        query = query.eq(parts[0], parts[1]);
      }
    }

    if (orderBy != null && orderBy.isNotEmpty) {
      for (final order in orderBy) {
        final isDesc = order.startsWith('-');
        final column = isDesc ? order.substring(1) : order;
        query = query.order(column, ascending: !isDesc);
      }
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    if (offset != null) {
      query = query.range(offset, offset + (limit ?? 10) - 1);
    }

    return await query;
  }

  /// Insert data into a table
  Future<List<Map<String, dynamic>>> insertIntoTable(
    String tableName,
    Map<String, dynamic> data,
  ) async {
    return await _client.from(tableName).insert(data).select();
  }

  /// Update data in a table
  Future<List<Map<String, dynamic>>> updateInTable(
    String tableName,
    Map<String, dynamic> data, {
    required String filter,
  }) async {
    // Parse filter in format 'column:value'
    final parts = filter.split(':');
    if (parts.length != 2) {
      throw ArgumentError('Filter must be in format "column:value"');
    }
    
    return await _client.from(tableName).update(data).eq(parts[0], parts[1]).select();
  }

  /// Delete data from a table
  Future<List<Map<String, dynamic>>> deleteFromTable(
    String tableName, {
    required String filter,
  }) async {
    // Parse filter in format 'column:value'
    final parts = filter.split(':');
    if (parts.length != 2) {
      throw ArgumentError('Filter must be in format "column:value"');
    }
    
    return await _client.from(tableName).delete().eq(parts[0], parts[1]).select();
  }
  
  /// Call a Supabase Edge Function
  /// 
  /// This method calls a Supabase Edge Function with the given name and optional parameters.
  /// It returns the response data as a dynamic object that can be cast to the appropriate type.
  Future<dynamic> callEdgeFunction(String functionName, {Map<String, dynamic>? params}) async {
    try {
      
      final response = await _client.functions.invoke(
        functionName,
        body: params,
      );
      
      if (response.status != 200) {
        throw Exception('Edge function error: ${response.status} - ${response.data}');
      }
      
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
