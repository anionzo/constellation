import 'sync_queue_item.dart';

/// Exception thrown when attempting to queue or sync data originating from The Void.
class TheVoidSyncViolationException implements Exception {
  final String actionType;
  final String message;

  const TheVoidSyncViolationException({
    required this.actionType,
    required this.message,
  });

  @override
  String toString() =>
      'TheVoidSyncViolationException: $message (actionType: "$actionType"). '
      'Violates Constellation Invariant 2: After Midnight The Void data must never enter local persistence or sync queue.';
}

/// Guard utility enforcing The Void invariant on local sync items.
abstract final class TheVoidSyncGuard {
  /// Asserts that the given [item] does not represent or contain The Void data.
  static void assertNotTheVoid(SyncQueueItem item) {
    final lowerAction = item.actionType.toLowerCase();
    if (lowerAction.contains('void') ||
        lowerAction.contains('after_midnight_void') ||
        lowerAction.contains('after-midnight-void')) {
      throw TheVoidSyncViolationException(
        actionType: item.actionType,
        message: 'Forbidden attempt to enqueue The Void payload into offline sync queue.',
      );
    }

    final payloadKeys = item.payload.keys.map((k) => k.toLowerCase()).toList();
    if (payloadKeys.any((k) => k.contains('void_thought') || k == 'void_text')) {
      throw TheVoidSyncViolationException(
        actionType: item.actionType,
        message: 'Payload contains forbidden Void keys.',
      );
    }
  }
}
