import 'dart:math' as math;
import 'package:test/test.dart';
import 'package:version_gate/version_gate.dart';
import 'package:local_sync/local_sync.dart';
import 'package:media_storage/media_storage.dart';
import 'package:quire/src/features/photo_upload/services/quire_moment_uploader.dart';
import 'package:quire/src/features/version_gate/dispatcher_sync_lock_bridge.dart';

void main() {
  group('Quire Client Hardening — WCAG AA & Design Tokens Contrast', () {
    test('Calculated contrast ratio between accentLight (#E76136) and onAccentLight (#241E19) satisfies WCAG AA (>= 4.5:1)', () {
      // W3C relative luminance calculation from 32-bit ARGB values
      double relativeLuminance(int argb) {
        final rVal = (argb >> 16) & 0xFF;
        final gVal = (argb >> 8) & 0xFF;
        final bVal = argb & 0xFF;

        double channel(int value) {
          final s = value / 255.0;
          return s <= 0.03928 ? s / 12.92 : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
        }

        final r = channel(rVal);
        final g = channel(gVal);
        final b = channel(bVal);
        return 0.2126 * r + 0.7152 * g + 0.0722 * b;
      }

      const accentLightHex = 0xFFE76136;
      const onAccentLightHex = 0xFF241E19;

      final lAccent = relativeLuminance(accentLightHex);
      final lOnAccent = relativeLuminance(onAccentLightHex);

      final lighter = math.max(lAccent, lOnAccent);
      final darker = math.min(lAccent, lOnAccent);
      final contrastRatio = (lighter + 0.05) / (darker + 0.05);

      // Must be >= 4.5:1 for WCAG AA normal text
      expect(contrastRatio, greaterThanOrEqualTo(4.5));
    });
  });

  group('Quire Client Hardening — VersionGate & SyncLock Bridge', () {
    test('VersionGate evaluation blocks UI and sync when app is outdated (Force Update)', () async {
      final config = AppSystemConfig(
        platform: 'ios',
        minSupportedVersion: SemVer.parse('2.0.0'),
        latestVersion: SemVer.parse('2.0.0'),
        forceUpdateTitle: 'Cần cập nhật',
        forceUpdateMessage: 'Phiên bản không còn được hỗ trợ.',
        updateUrl: 'https://example.com/update',
        maintenanceMode: false,
      );

      final manager = VersionGateManager(
        currentAppVersion: SemVer.parse('1.0.0'),
        platform: 'ios',
        repository: _StaticConfigRepo(config),
      );

      final status = await manager.onAppBoot();
      expect(status, isA<ForceUpdateStatus>());
      expect(status.shouldBlockUI, isTrue);
      expect(status.shouldLockSync, isTrue);
    });

    test('VersionGate evaluation blocks UI and sync when system is in emergency maintenance', () async {
      final config = AppSystemConfig(
        platform: 'ios',
        minSupportedVersion: SemVer.parse('1.0.0'),
        latestVersion: SemVer.parse('1.0.0'),
        forceUpdateTitle: 'Bảo trì hệ thống',
        forceUpdateMessage: 'Hệ thống đang được nâng cấp.',
        updateUrl: 'https://example.com/status',
        maintenanceMode: true,
      );

      final manager = VersionGateManager(
        currentAppVersion: SemVer.parse('1.0.0'),
        platform: 'ios',
        repository: _StaticConfigRepo(config),
      );

      final status = await manager.onAppBoot();
      expect(status, isA<MaintenanceStatus>());
      expect(status.shouldBlockUI, isTrue);
      expect(status.shouldLockSync, isTrue);
    });

    test('DispatcherSyncLockBridge locks and unlocks SyncDispatcher immediately', () {
      final store = MemoryLocalStoreAdapter();
      final dispatcher = SyncDispatcher(
        store: store,
        isOnline: () async => true,
      );
      final bridge = DispatcherSyncLockBridge(dispatcher);

      expect(dispatcher.isLocked, isFalse);

      bridge.lockSync();
      expect(dispatcher.isLocked, isTrue);

      bridge.unlockSync();
      expect(dispatcher.isLocked, isFalse);
    });
  });

  group('Quire Client Hardening — Offline Replay via SyncDispatcher', () {
    test('SyncDispatcher replays upload_quire_moment queue item and cleans up on success', () async {
      final store = MemoryLocalStoreAdapter();
      Map<String, dynamic>? receivedMomentRow;
      List<Map<String, dynamic>>? receivedRecipientRows;

      final uploader = QuireMomentUploader(
        storageAdapter: _TestStorageAdapter(),
        dbInserter: ({required momentRow, required recipientRows}) async {
          receivedMomentRow = momentRow;
          receivedRecipientRows = recipientRows;
        },
        localStore: store,
        isOnline: () async => true,
      );

      // Pre-populate an offline queue item
      final queueItem = SyncQueueItem(
        id: 'moment_test_123',
        actionType: 'upload_quire_moment',
        payload: {
          'moment_id': 'moment_test_123',
          'circle_id': 'circle_test_456',
          'sender_id': 'user_test_789',
          'storage_path': 'circle_test_456/moment_test_123.webp',
          'recipient_ids': ['friend_1', 'friend_2'],
          'caption': 'Hoàng hôn bên bờ hồ',
          'article_id': null,
          'reply_to_moment_id': null,
        },
        createdAt: DateTime.now(),
        status: SyncStatus.pending,
      );

      await store.enqueue(queueItem);
      expect((await store.getPendingItems()).length, equals(1));

      // Configure dispatcher
      final dispatcher = SyncDispatcher(
        store: store,
        isOnline: () async => true,
      );
      dispatcher.registerHandler('upload_quire_moment', uploader.handleReplaySync);

      // Dispatch pending batch
      final successCount = await dispatcher.dispatchPendingBatch();

      expect(successCount, equals(1));
      expect((await store.getPendingItems()).length, equals(0));
      expect(receivedMomentRow, isNotNull);
      expect(receivedMomentRow!['id'], equals('moment_test_123'));
      expect(receivedMomentRow!['caption'], equals('Hoàng hôn bên bờ hồ'));
      expect(receivedRecipientRows, hasLength(2));
      expect(receivedRecipientRows![0]['recipient_id'], equals('friend_1'));
      expect(receivedRecipientRows![0]['read_at'], isNull); // Read receipts OFF invariant
    });
  });
}

class _StaticConfigRepo implements SystemConfigRepository {
  final AppSystemConfig config;
  const _StaticConfigRepo(this.config);

  @override
  AppSystemConfig? get cachedConfig => config;

  @override
  Future<AppSystemConfig> fetchConfig({required String platform}) async => config;

  @override
  Future<void> cacheConfig(AppSystemConfig config) async {}
}

class _TestStorageAdapter implements MediaStorageAdapter {
  @override
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required dynamic bytes,
    required String contentType,
  }) async => path;

  @override
  Future<void> deleteFile({required String bucket, required String path}) async {}

  @override
  Future<List<String>> deleteFiles({required String bucket, required List<String> paths}) async => paths;

  @override
  Future<List<StorageFileObject>> listFiles({required String bucket, String? prefix}) async => [];

  @override
  String getPublicUrl({required String bucket, required String path}) => 'https://cdn.example.com/$path';

  @override
  Future<String> createSignedUrl({required String bucket, required String path, required int expiresInSeconds}) async =>
      'https://signed.example.com/$path';

  @override
  Future<int> cleanupPreviousAvatars({required String userId, required String currentAvatarPath}) async => 0;
}
