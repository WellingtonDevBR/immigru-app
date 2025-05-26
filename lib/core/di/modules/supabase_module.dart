import 'package:get_it/get_it.dart';
import 'package:immigru/core/network/edge_function_client.dart';
import 'package:immigru/core/storage/i_supabase_storage.dart';
import 'package:immigru/core/storage/supabase_storage_utils.dart';
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

    // Register Supabase storage utils
    if (!sl.isRegistered<ISupabaseStorage>()) {
      sl.registerLazySingleton<ISupabaseStorage>(() => SupabaseStorageUtils.instance);
    }
    
    // Register the concrete implementation for direct access if needed
    if (!sl.isRegistered<SupabaseStorageUtils>()) {
      sl.registerLazySingleton<SupabaseStorageUtils>(() => SupabaseStorageUtils.instance);
    }
  }
}
