import 'package:local_sync/local_sync.dart';
import 'package:version_gate/version_gate.dart';

/// Bridge connecting SyncDispatcher lock control with VersionGateManager SyncLockListener contract.
///
/// Pure Dart component with zero Flutter/dart:ui dependency, allowing standalone testing.
class DispatcherSyncLockBridge implements SyncLockListener {
  final SyncDispatcher dispatcher;

  const DispatcherSyncLockBridge(this.dispatcher);

  @override
  void lockSync() => dispatcher.lockSync();

  @override
  void unlockSync() => dispatcher.unlockSync();
}
