import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_sync/local_sync.dart';
import 'package:media_storage/media_storage.dart';
import 'package:version_gate/version_gate.dart';
import 'src/presentation/theme/quire_tokens.dart';
import 'src/presentation/theme/quire_theme.dart';
import 'src/presentation/views/force_update_view.dart';
import 'src/presentation/views/calm_auth_view.dart';
import 'src/presentation/views/quire_home_screen.dart';
import 'src/features/photo_upload/services/quire_moment_uploader.dart';
import 'src/features/version_gate/dispatcher_sync_lock_bridge.dart';
import 'src/features/api/bff_api_client.dart';
import 'src/features/auth/auth_session_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Native phone status bar configuration:
  // Transparent status bar with dark icons (matching the phone system clock & battery naturally)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: QuireTokens.paperLight,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const QuireApp());
}

class QuireApp extends StatefulWidget {
  final VersionGateManager? versionGateManager;
  final QuireMomentUploader? momentUploader;
  final SyncDispatcher? syncDispatcher;
  final ThemeController? themeController;

  const QuireApp({
    Key? key,
    this.versionGateManager,
    this.momentUploader,
    this.syncDispatcher,
    this.themeController,
  }) : super(key: key);

  @override
  State<QuireApp> createState() => _QuireAppState();
}

class _QuireAppState extends State<QuireApp> with WidgetsBindingObserver {
  late final VersionGateManager _versionGateManager;
  late final QuireMomentUploader _momentUploader;
  late final SyncDispatcher _syncDispatcher;
  late final ThemeController _themeController;
  VersionGateStatus? _currentGateStatus;
  final BffApiClient _bffClient = BffApiClient();
  late final AuthSessionManager _sessionManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionManager = AuthSessionManager(apiClient: _bffClient);
    _sessionManager.addListener(_onSessionChanged);
    _sessionManager.init();

    _momentUploader = widget.momentUploader ?? MockQuireMomentUploader();
    _themeController = widget.themeController ?? ThemeController();
    _themeController.addListener(_onThemeChanged);
    _syncDispatcher = widget.syncDispatcher ??
        SyncDispatcher(
          store: _momentUploader.localStore,
          isOnline: _momentUploader.isOnline,
        );

    // Register offline replay handler for Quire moments
    _syncDispatcher.registerHandler(
      'upload_quire_moment',
      _momentUploader.handleReplaySync,
    );

    _versionGateManager = widget.versionGateManager ??
        VersionGateManager(
          currentAppVersion: SemVer.parse('1.0.0'),
          platform: 'ios',
          syncLockListener: DispatcherSyncLockBridge(_syncDispatcher),
          repository: StaticSystemConfigRepository(
            AppSystemConfig(
              platform: 'ios',
              minSupportedVersion: SemVer.parse('1.0.0'),
              latestVersion: SemVer.parse('1.0.0'),
              forceUpdateTitle: 'Cập nhật ứng dụng',
              forceUpdateMessage: 'Phiên bản mới của Constellation đã sẵn sàng.',
              updateUrl: 'https://apps.apple.com/app/constellation',
              maintenanceMode: false,
            ),
          ),
        );

    _versionGateManager.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _currentGateStatus = status;
        });
      }
    });

    // Hook 1: Cold Boot evaluation & background sync replay
    _versionGateManager.onAppBoot().then((_) {
      _syncDispatcher.dispatchPendingBatch();
    });

    // Persistent session restoration is handled reactively by _sessionManager.init()
  }

  @override
  void dispose() {
    _sessionManager.removeListener(_onSessionChanged);
    _themeController.removeListener(_onThemeChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onSessionChanged() {
    if (mounted) setState(() {});
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Hook 2: Resumed from background & background sync replay
    if (state == AppLifecycleState.resumed) {
      _versionGateManager.onAppResume().then((_) {
        _syncDispatcher.dispatchPendingBatch();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = _currentGateStatus?.shouldBlockUI ?? false;

    return MaterialApp(
      title: 'Quire',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      theme: QuireTheme.light(),
      darkTheme: QuireTheme.dark(),
      themeMode: _themeController.value,
      home: isBlocked
          ? _buildBlockedView()
          : (!_sessionManager.isInitialized
              ? Container(
                  color: _themeController.value == ThemeMode.dark ? QuireTokens.paperDark : QuireTokens.paperLight,
                )
              : (!_sessionManager.isAuthenticated
                  ? CalmAuthView(sessionManager: _sessionManager)
                  : QuireHomeScreen(
                      bffClient: _bffClient,
                      momentUploader: _momentUploader,
                      themeController: _themeController,
                      currentUserEmail: _sessionManager.userEmail,
                      onSignOut: () => _sessionManager.logout(),
                    ))),
    );
  }

  Widget _buildBlockedView() {
    final status = _currentGateStatus;
    if (status is ForceUpdateStatus) {
      return ForceUpdateView(
        title: status.config.forceUpdateTitle,
        message: status.config.forceUpdateMessage,
        updateUrl: status.config.updateUrl,
        isMaintenance: false,
        onRetry: () => _versionGateManager.onAppBoot(),
      );
    } else if (status is MaintenanceStatus) {
      return ForceUpdateView(
        title: status.config.forceUpdateTitle,
        message: status.config.maintenanceNotice ?? status.config.forceUpdateMessage,
        updateUrl: status.config.updateUrl,
        isMaintenance: true,
        onRetry: () => _versionGateManager.onAppBoot(),
      );
    }
    return const SizedBox.shrink();
  }
}

/// Enables mouse, touch, trackpad, and stylus drag scrolling across web and desktop.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

/// Static / In-memory SystemConfigRepository for standalone execution and testing.
class StaticSystemConfigRepository implements SystemConfigRepository {
  final AppSystemConfig config;
  const StaticSystemConfigRepository(this.config);

  @override
  AppSystemConfig? get cachedConfig => config;

  @override
  Future<AppSystemConfig> fetchConfig({required String platform}) async => config;

  @override
  Future<void> cacheConfig(AppSystemConfig config) async {}
}


/// Mock uploader for standalone execution and demonstration.
class MockQuireMomentUploader extends QuireMomentUploader {
  MockQuireMomentUploader()
      : super(
          storageAdapter: _MockStorageAdapter(),
          dbInserter: ({required momentRow, required recipientRows}) async {},
          localStore: MemoryLocalStoreAdapter(),
          isOnline: () async => true,
        );
}

class _MockStorageAdapter implements MediaStorageAdapter {
  @override
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async => path;

  @override
  Future<void> deleteFile({required String bucket, required String path}) async {}

  @override
  Future<List<String>> deleteFiles({required String bucket, required List<String> paths}) async => paths;

  @override
  Future<List<StorageFileObject>> listFiles({required String bucket, String? prefix}) async => [];

  @override
  String getPublicUrl({required String bucket, required String path}) => 'https://cdn.example.com/$path';

  @override
  Future<String> createSignedUrl({required String bucket, required String path, required int expiresInSeconds}) async =>
      'https://signed.example.com/$path';

  @override
  Future<int> cleanupPreviousAvatars({required String userId, required String currentAvatarPath}) async => 0;
}
