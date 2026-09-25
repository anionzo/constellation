import 'package:meta/meta.dart';
import '../semver.dart';
import 'app_system_config.dart';

/// The evaluated status of the version gate on app boot or resume.
@immutable
sealed class VersionGateStatus {
  const VersionGateStatus();

  /// Whether sync engine MUST be paused immediately.
  bool get shouldLockSync;

  /// Whether user interaction with the main app must be blocked.
  bool get shouldBlockUI;
}

/// The installed version meets or exceeds the latest version.
final class UpToDateStatus extends VersionGateStatus {
  final SemVer currentVersion;
  final SemVer latestVersion;

  const UpToDateStatus({
    required this.currentVersion,
    required this.latestVersion,
  });

  @override
  bool get shouldLockSync => false;

  @override
  bool get shouldBlockUI => false;
}

/// The installed version is supported, but a newer version is available.
/// Displays a soft, non-intrusive notification.
final class SoftUpdateStatus extends VersionGateStatus {
  final SemVer currentVersion;
  final AppSystemConfig config;

  const SoftUpdateStatus({
    required this.currentVersion,
    required this.config,
  });

  @override
  bool get shouldLockSync => false;

  @override
  bool get shouldBlockUI => false;
}

/// The installed version is below the minimum supported version.
/// MUST lock sync engine and present unskippable update screen.
final class ForceUpdateStatus extends VersionGateStatus {
  final SemVer currentVersion;
  final AppSystemConfig config;

  const ForceUpdateStatus({
    required this.currentVersion,
    required this.config,
  });

  @override
  bool get shouldLockSync => true;

  @override
  bool get shouldBlockUI => true;
}

/// The backend is in emergency maintenance mode.
/// MUST lock sync engine and show calm maintenance screen.
final class MaintenanceStatus extends VersionGateStatus {
  final AppSystemConfig config;

  const MaintenanceStatus({
    required this.config,
  });

  @override
  bool get shouldLockSync => true;

  @override
  bool get shouldBlockUI => true;
}

/// Network is unreachable during boot/resume check.
/// Falls back safely without trapping users if no prior force block was cached.
final class OfflinePassThroughStatus extends VersionGateStatus {
  final SemVer currentVersion;
  final String? reason;

  const OfflinePassThroughStatus({
    required this.currentVersion,
    this.reason,
  });

  @override
  bool get shouldLockSync => false;

  @override
  bool get shouldBlockUI => false;
}
