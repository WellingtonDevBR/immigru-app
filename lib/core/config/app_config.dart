import 'package:immigru/core/config/environment_config.dart';
import 'package:immigru/core/config/storage_config.dart';

/// Central configuration class that exports all app configurations
class AppConfig {
  /// Private constructor to prevent instantiation
  AppConfig._();
  
  /// Environment configuration
  static final environment = EnvironmentConfig;
  
  /// Storage configuration
  static final storage = StorageConfig;
}
