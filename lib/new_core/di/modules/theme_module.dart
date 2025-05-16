import 'package:get_it/get_it.dart';
import 'package:immigru/shared/theme/theme_provider.dart';

/// Theme module for dependency injection
/// Registers all theme-related dependencies
class ThemeModule {
  /// Register all theme dependencies
  static Future<void> register(GetIt sl) async {
    // Register theme provider as a singleton
    sl.registerLazySingleton<ThemeProvider>(() => ThemeProvider());
  }
}
