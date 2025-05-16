import 'package:get_it/get_it.dart';
import 'package:immigru/core/services/supabase_service.dart';
import 'package:immigru/data/datasources/supabase_data_source.dart';

/// Supabase module for dependency injection
/// Registers all Supabase-related dependencies
class SupabaseModule {
  /// Register all Supabase dependencies
  static Future<void> register(GetIt sl) async {
    // Register Supabase service as a singleton that's immediately initialized
    if (!sl.isRegistered<SupabaseService>()) {
      final supabaseService = SupabaseService();
      await supabaseService.initialize();
      sl.registerLazySingleton<SupabaseService>(() => supabaseService);
    }
    
    // Register SupabaseDataSource
    if (!sl.isRegistered<SupabaseDataSource>()) {
      sl.registerLazySingleton<SupabaseDataSource>(
        () => SupabaseDataSourceImpl(sl<SupabaseService>()),
      );
    }
  }
}
