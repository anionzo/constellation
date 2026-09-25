import 'models/app_system_config.dart';
import 'semver.dart';

/// Contract for the UI layer to render Version Gating and Maintenance states.
///
/// Ensures strict separation of concerns (SRP): VersionGateManager handles logic
/// and SemVer evaluation; ForceUpdateDelegate handles UI rendering and external actions.
abstract interface class ForceUpdateDelegate {
  /// Invoked when the app is in emergency maintenance mode.
  /// UI MUST present a non-dismissible maintenance view.
  void showMaintenanceScreen({
    required AppSystemConfig config,
  });

  /// Invoked when current version < minSupportedVersion.
  /// UI MUST present an unskippable force update view with single CTA.
  void showForceUpdateScreen({
    required AppSystemConfig config,
    required SemVer currentVersion,
  });

  /// Invoked when minSupportedVersion <= currentVersion < latestVersion.
  /// UI SHOULD present a non-intrusive banner or prompt that can be dismissed.
  void showSoftUpdatePrompt({
    required AppSystemConfig config,
    required SemVer currentVersion,
  });

  /// Invoked when currentVersion >= latestVersion or user dismisses soft update.
  void clearGateOverlays();

  /// Invoked to open the external store or PWA reload URL.
  Future<void> openUpdateUrl(String url);
}

/// Contract for listening to Sync Engine lock/unlock requirements.
abstract interface class SyncLockListener {
  /// Invoked immediately when ForceUpdate or Maintenance is triggered.
  /// Sync engine MUST immediately pause all network sync operations.
  void lockSync();

  /// Invoked when gate clears or safe offline pass-through is active.
  void unlockSync();
}
