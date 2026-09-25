import 'dart:async';
import 'dart:typed_data';
import 'package:local_sync/local_sync.dart';
import 'package:media_storage/media_storage.dart';

/// Database insert function signature for loose coupling.
typedef MomentDbInserter = Future<void> Function({
  required Map<String, dynamic> momentRow,
  required List<Map<String, dynamic>> recipientRows,
});

/// Network check signature.
typedef NetworkChecker = Future<bool> Function();

/// Result of moment dispatch operation.
class MomentDispatchResult {
  final bool isSuccess;
  final bool isOfflineQueued;
  final String message;

  const MomentDispatchResult({
    required this.isSuccess,
    required this.isOfflineQueued,
    required this.message,
  });
}

/// Dispatches moments to Supabase Storage and Database, with automatic offline queue fallback.
class QuireMomentUploader {
  final MediaStorageAdapter storageAdapter;
  final MomentDbInserter dbInserter;
  final LocalStoreAdapter localStore;
  final NetworkChecker isOnline;

  QuireMomentUploader({
    required this.storageAdapter,
    required this.dbInserter,
    required this.localStore,
    required this.isOnline,
  });

  /// Uploads moment to storage & database, or safely enqueues in offline storage.
  Future<MomentDispatchResult> dispatchMoment({
    required String momentId,
    required String circleId,
    required String senderId,
    required Uint8List imageBytes,
    required Set<String> recipientIds,
    String? caption,
    String? articleId,
    String? replyToMomentId,
  }) async {
    final online = await isOnline();

    final storagePath = StoragePathGenerator.quireMomentPath(
      circleId: circleId,
      momentId: momentId,
    );

    if (online) {
      try {
        // 1. Upload compressed image to private quire-moments bucket
        await storageAdapter.uploadFile(
          bucket: StoragePathGenerator.quireMomentsBucket,
          path: storagePath,
          bytes: imageBytes,
          contentType: 'image/webp',
        );

        // 2. Prepare database rows (30-day ephemeral expires_at, read_at NULL by default)
        final now = DateTime.now();
        final expiresAt = now.add(const Duration(days: 30));

        final momentRow = {
          'id': momentId,
          'circle_id': circleId,
          'sender_id': senderId,
          'image_path': storagePath,
          'caption': caption,
          'article_id': articleId,
          'reply_to_moment_id': replyToMomentId,
          'created_at': now.toIso8601String(),
          'expires_at': expiresAt.toIso8601String(),
        };

        // Read receipts OFF: read_at is explicitly null
        final recipientRows = recipientIds.map((recipientId) {
          return {
            'moment_id': momentId,
            'recipient_id': recipientId,
            'read_at': null,
            'liked': false,
          };
        }).toList();

        await dbInserter(
          momentRow: momentRow,
          recipientRows: recipientRows,
        );

        return const MomentDispatchResult(
          isSuccess: true,
          isOfflineQueued: false,
          message: 'Khoảnh khắc đã được gửi thành công.',
        );
      } catch (e) {
        // If remote upload fails unexpectedly, fall back to offline queue
        return _enqueueLocally(
          momentId: momentId,
          circleId: circleId,
          senderId: senderId,
          storagePath: storagePath,
          recipientIds: recipientIds,
          caption: caption,
          articleId: articleId,
          replyToMomentId: replyToMomentId,
        );
      }
    } else {
      // Offline fallback: save to local queue
      return _enqueueLocally(
        momentId: momentId,
        circleId: circleId,
        senderId: senderId,
        storagePath: storagePath,
        recipientIds: recipientIds,
        caption: caption,
        articleId: articleId,
        replyToMomentId: replyToMomentId,
      );
    }
  }

  Future<MomentDispatchResult> _enqueueLocally({
    required String momentId,
    required String circleId,
    required String senderId,
    required String storagePath,
    required Set<String> recipientIds,
    String? caption,
    String? articleId,
    String? replyToMomentId,
  }) async {
    final queueItem = SyncQueueItem(
      id: momentId,
      actionType: 'upload_quire_moment',
      payload: {
        'moment_id': momentId,
        'circle_id': circleId,
        'sender_id': senderId,
        'storage_path': storagePath,
        'recipient_ids': recipientIds.toList(),
        'caption': caption,
        'article_id': articleId,
        'reply_to_moment_id': replyToMomentId,
      },
      createdAt: DateTime.now(),
      status: SyncStatus.pending,
    );

    await localStore.enqueue(queueItem);

    return const MomentDispatchResult(
      isSuccess: true,
      isOfflineQueued: true,
      message: 'Đã lưu ngoại tuyến. Khoảnh khắc sẽ được gửi đi khi có mạng trở lại.',
    );
  }
}
