/// Version Gating, SemVer Precedence Comparison, and Anti-Stale Cache Library.
library version_gate;

export 'src/semver.dart';
export 'src/models/app_system_config.dart';
export 'src/models/version_gate_status.dart';
export 'src/repository/system_config_repository.dart';
export 'src/repository/supabase_config_repository.dart';
export 'src/force_update_delegate.dart';
export 'src/version_gate_manager.dart';
export 'src/web_cache_headers.dart';
