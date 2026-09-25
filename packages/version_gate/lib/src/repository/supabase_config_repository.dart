import 'dart:async';
import '../models/app_system_config.dart';
import 'system_config_repository.dart';

/// Type signature for Supabase REST query invoker.
typedef SupabaseQueryRunner = Future<Map<String, dynamic>?> Function({
  required String table,
  required String platform,
});

/// Production implementation of [SystemConfigRepository] querying Supabase `app_system_configs`.
class SupabaseConfigRepository implements SystemConfigRepository {
  final SupabaseQueryRunner _queryRunner;
  AppSystemConfig? _cachedConfig;

  SupabaseConfigRepository({
    required SupabaseQueryRunner queryRunner,
    AppSystemConfig? initialCache,
  })  : _queryRunner = queryRunner,
        _cachedConfig = initialCache;

  @override
  AppSystemConfig? get cachedConfig => _cachedConfig;

  @override
  Future<void> cacheConfig(AppSystemConfig config) async {
    _cachedConfig = config;
  }

  @override
  Future<AppSystemConfig> fetchConfig({required String platform}) async {
    try {
      final data = await _queryRunner(
        table: 'app_system_configs',
        platform: platform,
      );

      if (data == null) {
        throw StateError('No system config row found for platform "$platform"');
      }

      final config = AppSystemConfig.fromJson(data);
      await cacheConfig(config);
      return config;
    } catch (e) {
      // Re-throw so caller/manager can decide whether to fall back to cache or offline pass-through
      rethrow;
    }
  }
}
