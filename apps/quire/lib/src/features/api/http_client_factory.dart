import 'package:http/http.dart' as http;
import 'http_client_factory_stub.dart'
    if (dart.library.html) 'http_client_factory_web.dart';

/// Returns a cross-platform HTTP client.
/// On Web, automatically enables `withCredentials = true` so the browser
/// includes and updates HttpOnly cookies on every request.
http.Client createPlatformHttpClient() => createHttpClient();
