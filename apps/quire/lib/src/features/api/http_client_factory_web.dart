import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

/// Web HTTP client with automatic Cookie persistence and credentials enabled.
http.Client createHttpClient() {
  final client = BrowserClient();
  client.withCredentials = true;
  return client;
}
