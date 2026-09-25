import 'package:test/test.dart';
import 'package:version_gate/version_gate.dart';

class MockSystemConfigRepository implements SystemConfigRepository {
  AppSystemConfig? configToReturn;
  AppSystemConfig? _cached;

  @override
  AppSystemConfig? get cachedConfig => _cached;

  @override
  Future<void> cacheConfig(AppSystemConfig config) async {
    _cached = config;
  }

  @override
  Future<AppSystemConfig> fetchConfig({required String platform}) async {
    if (configToReturn != null) {
      _cached = configToReturn;
      return configToReturn!;
    }
    throw StateError('Network unavailable');
  }
}

class MockSyncLockListener implements SyncLockListener {
  bool isLocked = false;

  @override
  void lockSync() {
    isLocked = true;
  }

  @override
  void unlockSync() {
    isLocked = false;
  }
}

void main() {
  group('VersionGateManager Evaluation', () {
    late MockSystemConfigRepository repo;
    late MockSyncLockListener syncLock;

    setUp(() {
      repo = MockSystemConfigRepository();
      syncLock = MockSyncLockListener();
    });

    test('triggers MaintenanceStatus and locks sync when maintenance_mode is true', () async {
      repo.configToReturn = AppSystemConfig(
        platform: 'android',
        minSupportedVersion: SemVer.parse('1.0.0'),
        latestVersion: SemVer.parse('2.0.0'),
        forceUpdateTitle: 'Bảo trì hệ thống',
        forceUpdateMessage: 'Hệ thống đang bảo trì.',
        updateUrl: 'https://example.com',
        maintenanceMode: true,
      );

      final manager = VersionGateManager(
        currentAppVersion: SemVer.parse('1.5.0'),
        platform: 'android',
        repository: repo,
        syncLockListener: syncLock,
      );

      final status = await manager.onAppBoot();

      expect(status, isA<MaintenanceStatus>());
      expect(status.shouldLockSync, isTrue);
      expect(status.shouldBlockUI, isTrue);
      expect(syncLock.isLocked, isTrue);
    });

    test('triggers ForceUpdateStatus when app version < minSupportedVersion', () async {
      repo.configToReturn = AppSystemConfig(
        platform: 'ios',
        minSupportedVersion: SemVer.parse('1.5.0'),
        latestVersion: SemVer.parse('2.0.0'),
        forceUpdateTitle: 'Cập nhật bắt buộc',
        forceUpdateMessage: 'Vui lòng cập nhật.',
        updateUrl: 'https://apple.com',
        maintenanceMode: false,
      );

      final manager = VersionGateManager(
        currentAppVersion: SemVer.parse('1.2.0'),
        platform: 'ios',
        repository: repo,
        syncLockListener: syncLock,
      );

      final status = await manager.onAppBoot();

      expect(status, isA<ForceUpdateStatus>());
      expect(status.shouldLockSync, isTrue);
      expect(status.shouldBlockUI, isTrue);
      expect(syncLock.isLocked, isTrue);
    });

    test('triggers SoftUpdateStatus when minSupported <= current < latest', () async {
      repo.configToReturn = AppSystemConfig(
        platform: 'android',
        minSupportedVersion: SemVer.parse('1.0.0'),
        latestVersion: SemVer.parse('1.5.0'),
        forceUpdateTitle: 'Có bản mới',
        forceUpdateMessage: 'Cập nhật nhẹ.',
        updateUrl: 'https://play.google.com',
        maintenanceMode: false,
      );

      final manager = VersionGateManager(
        currentAppVersion: SemVer.parse('1.2.0'),
        platform: 'android',
        repository: repo,
        syncLockListener: syncLock,
      );

      final status = await manager.onAppBoot();

      expect(status, isA<SoftUpdateStatus>());
      expect(status.shouldLockSync, isFalse);
      expect(status.shouldBlockUI, isFalse);
      expect(syncLock.isLocked, isFalse);
    });

    test('triggers UpToDateStatus when current >= latest', () async {
      repo.configToReturn = AppSystemConfig(
        platform: 'web',
        minSupportedVersion: SemVer.parse('1.0.0'),
        latestVersion: SemVer.parse('1.5.0'),
        forceUpdateTitle: 'Update',
        forceUpdateMessage: 'Update msg',
        updateUrl: 'https://web.quire.app',
        maintenanceMode: false,
      );

      final manager = VersionGateManager(
        currentAppVersion: SemVer.parse('1.5.0'),
        platform: 'web',
        repository: repo,
        syncLockListener: syncLock,
      );

      final status = await manager.onAppBoot();

      expect(status, isA<UpToDateStatus>());
      expect(status.shouldLockSync, isFalse);
      expect(status.shouldBlockUI, isFalse);
    });
  });
}
