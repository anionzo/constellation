import 'dart:async';
import 'dart:math';
import 'local_store_adapter.dart';
import 'sync_queue_item.dart';
import 'sync_status.dart';

/// Handler function that processes a single queued item over the network.
/// Returns `true` if operation succeeded; returns `false` or throws on failure.
typedef SyncHandler = Future<bool> Function(SyncQueueItem item);

/// Network connectivity provider contract.
typedef NetworkConnectivityChecker = Future<bool> Function();

/// Configuration options for the background dispatcher.
class DispatcherConfig {
  final int maxRetries;
  final Duration initialRetryDelay;
  final double backoffMultiplier;
  final Duration maxRetryDelay;

  const DispatcherConfig({
    this.maxRetries = 5,
    this.initialRetryDelay = const Duration(seconds: 2),
    this.backoffMultiplier = 2.0,
    this.maxRetryDelay = const Duration(minutes: 5),
  });
}

/// Orchestrates background dispatching of offline queue items.
class SyncDispatcher {
  final LocalStoreAdapter store;
  final NetworkConnectivityChecker isOnline;
  final DispatcherConfig config;

  final Map<String, SyncHandler> _handlers = {};
  bool _isLockedByGate = false;
  bool _isProcessing = false;

  SyncDispatcher({
    required this.store,
    required this.isOnline,
    this.config = const DispatcherConfig(),
  });

  /// Registers an executor for a specific `actionType`.
  void registerHandler(String actionType, SyncHandler handler) {
    _handlers[actionType] = handler;
  }

  /// Locks sync engine when VersionGate triggers ForceUpdate or Maintenance.
  void lockSync() {
    _isLockedByGate = true;
  }

  /// Unlocks sync engine when VersionGate clears.
  void unlockSync() {
    _isLockedByGate = false;
  }

  bool get isLocked => _isLockedByGate;

  /// Calculates next retry timestamp using exponential backoff with jitter.
  DateTime calculateNextRetry(int retryCount) {
    final exponentialMs = config.initialRetryDelay.inMilliseconds *
        pow(config.backoffMultiplier, retryCount).toDouble();
    final clampedMs = min(exponentialMs, config.maxRetryDelay.inMilliseconds.toDouble());
    // Add +/- 10% jitter to prevent thundering herd
    final jitter = (Random().nextDouble() * 0.2 - 0.1) * clampedMs;
    final totalMs = (clampedMs + jitter).round();
    return DateTime.now().add(Duration(milliseconds: totalMs));
  }

  /// Dispatches the next batch of eligible pending items.
  Future<int> dispatchPendingBatch({int limit = 10}) async {
    if (_isLockedByGate || _isProcessing) {
      return 0;
    }

    final online = await isOnline();
    if (!online) {
      return 0;
    }

    _isProcessing = true;
    var successCount = 0;

    try {
      final items = await store.getPendingItems(limit: limit);
      final now = DateTime.now();

      for (final item in items) {
        if (_isLockedByGate) break;

        // Skip items that have a future nextRetryAt
        if (item.nextRetryAt != null && item.nextRetryAt!.isAfter(now)) {
          continue;
        }

        final handler = _handlers[item.actionType];
        if (handler == null) {
          // No handler registered: mark dead letter to prevent indefinite stalling
          await store.update(item.copyWith(
            status: SyncStatus.deadLetter,
            errorMessage: 'No SyncHandler registered for actionType "${item.actionType}"',
          ));
          continue;
        }

        // Transition to inProgress
        await store.update(item.copyWith(
          status: SyncStatus.inProgress,
          lastAttemptAt: DateTime.now(),
        ));

        try {
          final success = await handler(item);
          if (success) {
            // Completed: delete from queue
            await store.remove(item.id);
            successCount++;
          } else {
            await _handleFailure(item, 'Handler returned false');
          }
        } catch (e) {
          await _handleFailure(item, e.toString());
        }
      }
    } finally {
      _isProcessing = false;
    }

    return successCount;
  }

  Future<void> _handleFailure(SyncQueueItem item, String error) async {
    final nextRetryCount = item.retryCount + 1;
    if (nextRetryCount >= config.maxRetries) {
      // Exceeded max retries -> Dead Letter
      await store.update(item.copyWith(
        status: SyncStatus.deadLetter,
        retryCount: nextRetryCount,
        errorMessage: error,
      ));
    } else {
      // Transient failure -> Backoff retry
      await store.update(item.copyWith(
        status: SyncStatus.failed,
        retryCount: nextRetryCount,
        nextRetryAt: calculateNextRetry(nextRetryCount),
        errorMessage: error,
      ));
    }
  }
}
