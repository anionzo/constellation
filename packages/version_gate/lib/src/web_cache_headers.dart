/// Web Cache Invalidation & HTTP Headers Specification for Constellation Web/PWA builds.
///
/// Prevents stale bundle lockups on mobile browsers and progressive web apps.
abstract final class WebCacheHeaders {
  /// HTTP Header map for index.html and flutter_service_worker.js.
  ///
  /// CRITICAL: These files MUST NEVER be cached by intermediate proxies or browsers.
  static const Map<String, String> htmlAndWorkerNoCacheHeaders = {
    'Cache-Control': 'no-cache, no-store, must-revalidate',
    'Pragma': 'no-cache',
    'Expires': '0',
  };

  /// HTTP Header map for static hashed assets (.wasm, .js, fonts, images).
  ///
  /// Long-term immutable caching because filename contains content hash.
  static const Map<String, String> hashedStaticAssetHeaders = {
    'Cache-Control': 'public, max-age=31536000, immutable',
  };

  /// Generates a cache-busting URI for asset scripts.
  static String appendCacheBust(String uri, String buildHash) {
    final delimiter = uri.contains('?') ? '&' : '?';
    return '$uri${delimiter}v=$buildHash';
  }

  /// Caddy server configuration snippet for Constellation PWA.
  static const String caddyConfigSnippet = '''
# Caddyfile snippet for Constellation Web
@noCacheFiles {
    path /index.html /flutter_service_worker.js /version.json
}
header @noCacheFiles {
    Cache-Control "no-cache, no-store, must-revalidate"
    Pragma "no-cache"
    Expires "0"
}

@staticAssets {
    path *.wasm *.js *.css *.png *.webp *.woff2
    not path /flutter_service_worker.js
}
header @staticAssets {
    Cache-Control "public, max-age=31536000, immutable"
}
''';

  /// Nginx server configuration snippet for Constellation PWA.
  static const String nginxConfigSnippet = '''
# Nginx snippet for Constellation Web
location ~* ^/(index\\.html|flutter_service_worker\\.js|version\\.json)\$ {
    add_header Cache-Control "no-cache, no-store, must-revalidate";
    add_header Pragma "no-cache";
    expires 0;
}

location ~* \\.(wasm|js|css|png|webp|woff2)\$ {
    expires 1y;
    add_header Cache-Control "public, max-age=31536000, immutable";
}
''';
}

/// Abstract contract for Flutter Web Service Worker controller change listener.
///
/// Detects when a new Service Worker takes control of the page and notifies the UI
/// to show a graceful reload banner: "Phiên bản mới đã sẵn sàng. Tải lại trang để cập nhật."
abstract interface class WebServiceWorkerReloadNotifier {
  /// Starts listening to `navigator.serviceWorker.addEventListener('controllerchange')`.
  void startListening({
    required void Function(String message) onNewVersionAvailable,
  });

  /// Triggers a clean page reload.
  void reloadPage();
}
