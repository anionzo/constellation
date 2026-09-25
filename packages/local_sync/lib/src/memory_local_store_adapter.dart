import 'local_store_adapter.dart';
import 'sync_queue_item.dart';
import 'sync_status.dart';
import 'the_void_sync_guard.dart';

/// In-memory implementation of [LocalStoreAdapter] for deterministic tests and ephemeral sessions.
class MemoryLocalStoreAdapter implements LocalStoreAdapter {
  final Map<String, SyncQueueItem> _items = {};

  @override
  Future<void> enqueue(SyncQueueItem item) async {
    // Invariant Enforcement
    TheVoidSyncGuard.assertNotTheVoid(item);
    _items[item.id] = item;
  }

  @override
  Future<void> update(SyncQueueItem item) async {
    TheVoidSyncGuard.assertNotTheVoid(item);
    _items[item.id] = item;
  }

  @override
  Future<void> remove(String id) async {
    _items.remove(id);
  }

  @override
  Future<SyncQueueItem?> getById(String id) async {
    return _items[id];
  }

  @override
  Future<List<SyncQueueItem>> getPendingItems({int limit = 50}) async {
    final list = _items.values
        .where((item) => item.status == SyncStatus.pending || item.status == SyncStatus.failed)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return list.take(limit).toList();
  }

  @override
  Future<List<SyncQueueItem>> getFailedItems() async {
    return _items.values
        .where((item) => item.status == SyncStatus.failed)
        .toList();
  }

  @override
  Future<int> getQueueSize() async {
    return _items.values
        .where((item) => !item.status.isTerminal)
        .length;
  }

  @override
  Future<void> clearAll() async {
    _items.clear();
  }
}
