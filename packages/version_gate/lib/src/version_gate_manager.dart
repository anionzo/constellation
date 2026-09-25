import 'dart:async';
import 'force_update_delegate.dart';
import 'models/app_system_config.dart';
import 'models/version_gate_status.dart';
import 'repository/system_config_repository.dart';
import 'semver.dart';

/// Central coordinator for version gating across app lifecycle states.
class VersionGateManager {
  final SemVer currentAppVersion;
  final String platform;
  final SystemConfigRepository repository;
  final ForceUpdateDelegate? uiDelegate;
  final SyncLockListener? syncLockListener;

  final StreamController<VersionGateStatus> _statusController =
      StreamController<VersionGateStatus>.broadcast();

  VersionGateStatus? _lastStatus;

  VersionGateManager({
    required this.currentAppVersion,
    required this.platform,
    required this.repository,
    this.uiDelegate,
    this.syncLockListener,
  });

  /// Stream of version gate status changes.
  Stream<VersionGateStatus> get statusStream => _statusController.stream;

  /// Current evaluated status.
  VersionGateStatus? get currentStatus => _lastStatus;

  /// Lifecycle Hook 1: Invoked on application cold boot (Splash Screen).
  Future<VersionGateStatus> onAppBoot() async {
    return _evaluateGate();
  }

  /// Lifecycle Hook 2: Invoked when application returns from background (Resumed).
  Future<VersionGateStatus> onAppResume() async {
    return _evaluateGate();
  }

  /// Core evaluation logic based on SemVer 2.0.0 and AppSystemConfig.
  Future<VersionGateStatus> _evaluateGate() async {
    try {
      final config = await repository.fetchConfig(platform: platform);
      final status = evaluate(
        currentVersion: currentAppVersion,
        config: config,
      );

      _applyStatus(status);
      return status;
    } catch (e) {
      // Network error or fetch failure
      // Check if we have a cached config that requires blocking
      final cached = repository.cachedConfig;
      if (cached != null) {
        final cachedStatus = evaluate(
          currentVersion: currentAppVersion,
          config: cached,
        );
        if (cachedStatus.shouldBlockUI) {
          _applyStatus(cachedStatus);
          return cachedStatus;
        }
      }

      // If no cached blocking status, allow safe offline pass-through
      final fallback = OfflinePassThroughStatus(
        currentVersion: currentAppVersion,
        reason: e.toString(),
      );
      _applyStatus(fallback);
      return fallback;
    }
  }

  /// Pure functional evaluation of SemVer against system config.
  static VersionGateStatus evaluate({
    required SemVer currentVersion,
    required AppSystemConfig config,
  }) {
    // 1. Emergency Maintenance check takes highest precedence
    if (config.maintenanceMode) {
      return MaintenanceStatus(config: config);
    }

    // 2. Minimum Supported Version check (Force Update Gate)
    if (currentVersion < config.minSupportedVersion) {
      return ForceUpdateStatus(
        currentVersion: currentVersion,
        config: config,
      );
    }

    // 3. Latest Version check (Soft Update Notice)
    if (currentVersion < config.latestVersion) {
      return SoftUpdateStatus(
        currentVersion: currentVersion,
        config: config,
      );
    }

    // 4. Installed version is equal or higher than latest version
    return UpToDateStatus(
      currentVersion: currentVersion,
      latestVersion: config.latestVersion,
    );
  }

  void _applyStatus(VersionGateStatus status) {
    _lastStatus = status;
    _statusController.add(status);

    // Coordinate Sync Lock
    if (status.shouldLockSync) {
      syncLockListener?.lockSync();
    } else {
      syncLockListener?.unlockSync();
    }

    // Coordinate UI Delegate
    if (uiDelegate != null) {
      switch (status) {
        case MaintenanceStatus(:final config):
          uiDelegate!.showMaintenanceScreen(config: config);
        case ForceUpdateStatus(:final config, :final currentVersion):
          uiDelegate!.showForceUpdateScreen(
            config: config,
            currentVersion: currentVersion,
          );
        case SoftUpdateStatus(:final config, :final currentVersion):
          uiDelegate!.showSoftUpdatePrompt(
            config: config,
            currentVersion: currentVersion,
          );
        case UpToDateStatus():
        case OfflinePassThroughStatus():
          uiDelegate!.clearGateOverlays();
      }
    }
  }

  /// Disposes internal stream controllers.
  void dispose() {
    _statusController.close();
  }
}
