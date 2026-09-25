import 'package:test/test.dart';
import 'package:local_sync/local_sync.dart';

void main() {
  group('Local Sync Queue & Dispatcher', () {
    late MemoryLocalStoreAdapter store;

    setUp(() {
      store = MemoryLocalStoreAdapter();
    });

    test('enqueues and retrieves pending items in FIFO order', () async {
      final now = DateTime.now();
      final item1 = SyncQueueItem(
        id: 'item-1',
        actionType: 'upload_quire_moment',
        payload: {'moment_id': 'm1'},
        createdAt: now.subtract(const Duration(seconds: 10)),
      );
      final item2 = SyncQueueItem(
        id: 'item-2',
        actionType: 'upload_quire_moment',
        payload: {'moment_id': 'm2'},
        createdAt: now,
      );

      await store.enqueue(item2);
      await store.enqueue(item1);

      final pending = await store.getPendingItems();
      expect(pending.length, equals(2));
      expect(pending.first.id, equals('item-1'));
      expect(pending.last.id, equals('item-2'));
    });

    test('enforces The Void Invariant (Strict Zero-Persistence)', () async {
      final voidItem = SyncQueueItem(
        id: 'void-1',
        actionType: 'after_midnight_void_thought',
        payload: {'thought': 'Ephemeral secret'},
        createdAt: DateTime.now(),
      );

      expect(
        () => store.enqueue(voidItem),
        throwsA(isA<TheVoidSyncViolationException>()),
      );
    });

    test('dispatcher executes handlers and deletes item on success', () async {
      final item = SyncQueueItem(
        id: 'sync-1',
        actionType: 'test_action',
        payload: {'key': 'value'},
        createdAt: DateTime.now(),
      );
      await store.enqueue(item);

      var handled = false;
      final dispatcher = SyncDispatcher(
        store: store,
        isOnline: () async => true,
      );

      dispatcher.registerHandler('test_action', (queuedItem) async {
        handled = true;
        return true;
      });

      final count = await dispatcher.dispatchPendingBatch();
      expect(count, equals(1));
      expect(handled, isTrue);
      expect(await store.getQueueSize(), equals(0));
    });

    test('dispatcher halts dispatch when sync is locked by VersionGate', () async {
      final item = SyncQueueItem(
        id: 'sync-2',
        actionType: 'test_action',
        payload: {},
        createdAt: DateTime.now(),
      );
      await store.enqueue(item);

      final dispatcher = SyncDispatcher(
        store: store,
        isOnline: () async => true,
      );

      dispatcher.lockSync(); // Simulating ForceUpdate or Maintenance
      final count = await dispatcher.dispatchPendingBatch();

      expect(count, equals(0));
      expect(await store.getQueueSize(), equals(1));
    });
  });
}
