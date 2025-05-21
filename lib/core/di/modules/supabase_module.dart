import 'package:get_it/get_it.dart';
import 'package:immigru/core/network/edge_function_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase module for dependency injection
/// Registers all Supabase-related dependencies
class SupabaseModule {
  /// Register all Supabase dependencies
  static Future<void> register(GetIt sl) async {
    // Register Supabase client
    if (!sl.isRegistered<SupabaseClient>()) {
      sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
    }

    // Register Edge Function client
    if (!sl.isRegistered<EdgeFunctionClient>()) {
      final supabaseService = EdgeFunctionClient();
      sl.registerLazySingleton<EdgeFunctionClient>(() => supabaseService);
    }
  }
}
