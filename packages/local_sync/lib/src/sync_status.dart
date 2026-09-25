/// Lifecycle status of an item in the local sync queue.
enum SyncStatus {
  /// Item is queued locally and waiting for network/dispatch.
  pending,

  /// Item is currently being dispatched over the network.
  inProgress,

  /// Item successfully synced to remote backend.
  completed,

  /// Item encountered a transient failure and is scheduled for retry.
  failed,

  /// Item reached maximum retry attempts or failed permanently; stopped from blocking queue.
  deadLetter;

  bool get isTerminal => this == completed || this == deadLetter;
  bool get canRetry => this == pending || this == failed;
}
