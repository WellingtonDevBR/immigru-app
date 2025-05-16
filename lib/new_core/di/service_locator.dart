import 'package:get_it/get_it.dart';
import 'package:immigru/new_core/di/modules/core_module.dart';
import 'package:immigru/new_core/di/modules/feature_module.dart';

/// Service locator for dependency injection
/// This is the main entry point for the dependency injection system
class ServiceLocator {
  /// The singleton instance of GetIt
  static final GetIt instance = GetIt.instance;
  
  /// Initialize the service locator with all modules
  static Future<void> init() async {
    // Register core modules first
    await CoreModule.register(instance);
    
    // Register feature modules
    await FeatureModule.registerAll(instance);
  }
  
  /// Reset the service locator (useful for testing)
  static Future<void> reset() async {
    if (instance.isRegistered<GetIt>()) {
      await instance.reset();
    }
  }
}
