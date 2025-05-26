/// Configuration for environment variables
class EnvironmentConfig {
  /// Private constructor to prevent instantiation
  EnvironmentConfig._();
  
  /// Supabase URL
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://kkdhnvapcbwwqapsnnfg.supabase.co',
  );
  
  /// Supabase anonymous key
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtrZGhudmFwY2J3d3FhcHNubmZnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM5OTkzMTAsImV4cCI6MjA1OTU3NTMxMH0._Xf1x7dSkdVYP1HcV6yZSsyyq6xT_xkrjJgdzg9z-yM',
  );
  
  /// API base URL
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.immigru.com',
  );
  
  /// Storage base URL
  static const String storageBaseUrl = String.fromEnvironment(
    'STORAGE_BASE_URL',
    defaultValue: 'https://kkdhnvapcbwwqapsnnfg.supabase.co/storage/v1',
  );
  
  /// Environment name (development, staging, production)
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  /// Whether the app is running in debug mode
  static const bool isDebug = bool.fromEnvironment(
    'DEBUG',
    defaultValue: true,
  );
  
  /// Whether to use mock data for testing
  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: false,
  );
  
  /// Cache duration in minutes
  static const int cacheDurationMinutes = int.fromEnvironment(
    'CACHE_DURATION_MINUTES',
    defaultValue: 30,
  );
}
