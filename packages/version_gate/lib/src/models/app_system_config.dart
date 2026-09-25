import 'package:meta/meta.dart';
import '../semver.dart';

/// Represents the platform configuration fetched from Supabase `app_system_configs`.
@immutable
class AppSystemConfig {
  final String platform;
  final SemVer minSupportedVersion;
  final SemVer latestVersion;
  final String forceUpdateTitle;
  final String forceUpdateMessage;
  final String updateUrl;
  final bool maintenanceMode;
  final String? maintenanceNotice;

  const AppSystemConfig({
    required this.platform,
    required this.minSupportedVersion,
    required this.latestVersion,
    required this.forceUpdateTitle,
    required this.forceUpdateMessage,
    required this.updateUrl,
    required this.maintenanceMode,
    this.maintenanceNotice,
  });

  /// Factory constructor to deserialize Supabase JSON response.
  factory AppSystemConfig.fromJson(Map<String, dynamic> json) {
    return AppSystemConfig(
      platform: json['platform'] as String,
      minSupportedVersion: SemVer.parse(json['min_supported_version'] as String),
      latestVersion: SemVer.parse(json['latest_version'] as String),
      forceUpdateTitle: json['force_update_title'] as String? ?? 'Cập nhật phiên bản mới',
      forceUpdateMessage: json['force_update_message'] as String? ??
          'Vui lòng cập nhật ứng dụng để tiếp tục sử dụng an toàn.',
      updateUrl: json['update_url'] as String,
      maintenanceMode: json['maintenance_mode'] as bool? ?? false,
      maintenanceNotice: json['maintenance_notice'] as String?,
    );
  }

  /// Serializes configuration back to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'min_supported_version': minSupportedVersion.toString(),
      'latest_version': latestVersion.toString(),
      'force_update_title': forceUpdateTitle,
      'force_update_message': forceUpdateMessage,
      'update_url': updateUrl,
      'maintenance_mode': maintenanceMode,
      if (maintenanceNotice != null) 'maintenance_notice': maintenanceNotice,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSystemConfig &&
        other.platform == platform &&
        other.minSupportedVersion == minSupportedVersion &&
        other.latestVersion == latestVersion &&
        other.forceUpdateTitle == forceUpdateTitle &&
        other.forceUpdateMessage == forceUpdateMessage &&
        other.updateUrl == updateUrl &&
        other.maintenanceMode == maintenanceMode &&
        other.maintenanceNotice == maintenanceNotice;
  }

  @override
  int get hashCode => Object.hash(
        platform,
        minSupportedVersion,
        latestVersion,
        forceUpdateTitle,
        forceUpdateMessage,
        updateUrl,
        maintenanceMode,
        maintenanceNotice,
      );
}
