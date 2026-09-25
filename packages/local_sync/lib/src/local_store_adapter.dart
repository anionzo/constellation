import 'sync_queue_item.dart';

/// Abstract storage contract for persistent offline queue.
///
/// Follows Dependency Inversion Principle (DIP): domain sync logic interacts
/// with this port. Concrete adapters (SQLite, Drift, Hive, In-Memory) plug into it.
abstract interface class LocalStoreAdapter {
  /// Appends a new item to the sync queue.
  Future<void> enqueue(SyncQueueItem item);

  /// Updates an existing item (e.g. status transition, retryCount increment).
  Future<void> update(SyncQueueItem item);

  /// Permanently removes an item from the queue (upon successful completion).
  Future<void> remove(String id);

  /// Retrieves an item by its unique ID.
  Future<SyncQueueItem?> getById(String id);

  /// Returns items eligible for dispatch (ordered by `createdAt` ASC).
  Future<List<SyncQueueItem>> getPendingItems({int limit = 50});

  /// Returns items currently in `failed` state.
  Future<List<SyncQueueItem>> getFailedItems();

  /// Total count of active items in queue (pending, inProgress, failed).
  Future<int> getQueueSize();

  /// Clears all items (used in testing or account reset).
  Future<void> clearAll();
}
