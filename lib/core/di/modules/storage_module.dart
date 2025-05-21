import 'package:get_it/get_it.dart';
import 'package:immigru/core/storage/local_storage.dart';
import 'package:immigru/core/storage/secure_storage.dart';

/// Storage module for dependency injection
/// Registers all storage-related dependencies
class StorageModule {
  /// Register all storage dependencies
  static Future<void> register(GetIt sl) async {
    // Register local storage
    final localStorage = await LocalStorage.getInstance();
    sl.registerLazySingleton<LocalStorage>(() => localStorage);

    // Register secure storage
    sl.registerLazySingleton<SecureStorage>(() => SecureStorage());
  }
}
