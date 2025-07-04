import 'package:get_it/get_it.dart';
import 'package:immigru/core/di/modules/country_module.dart';
import 'package:immigru/core/di/modules/logging_module.dart';
import 'package:immigru/core/di/modules/network_module.dart';
import 'package:immigru/core/di/modules/performance_module.dart';
import 'package:immigru/core/di/modules/storage_module.dart';
import 'package:immigru/core/di/modules/supabase_module.dart';
import 'package:immigru/core/di/modules/theme_module.dart';

/// Core module for dependency injection
/// Registers all core dependencies like logging, network, storage, etc.
class CoreModule {
  /// Register all core dependencies
  static Future<void> register(GetIt sl) async {
    // Register logging dependencies
    await LoggingModule.register(sl);

    // Register Supabase dependencies (must be registered before network dependencies)
    await SupabaseModule.register(sl);

    // Register network dependencies
    await NetworkModule.register(sl);

    // Register storage dependencies
    await StorageModule.register(sl);

    // Register theme dependencies
    await ThemeModule.register(sl);

    // Register country dependencies
    await CountryModule.register(sl);
    
    // Register performance optimization dependencies
    await PerformanceModule.register(sl);
  }
}
