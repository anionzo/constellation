import '../models/app_system_config.dart';

/// Abstract contract for fetching remote system configuration.
///
/// Follows Dependency Inversion Principle (DIP): domain and application logic
/// depend on this abstraction, never directly on a specific HTTP or Supabase client.
abstract interface class SystemConfigRepository {
  /// Fetches system configuration for the target [platform] ('android', 'ios', 'web').
  Future<AppSystemConfig> fetchConfig({required String platform});

  /// Optional: returns cached configuration if available from previous successful fetch.
  AppSystemConfig? get cachedConfig;

  /// Optional: saves configuration to local cache.
  Future<void> cacheConfig(AppSystemConfig config);
}
