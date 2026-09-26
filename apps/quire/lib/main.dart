import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_sync/local_sync.dart';
import 'package:media_storage/media_storage.dart';
import 'src/presentation/theme/quire_tokens.dart';
import 'src/presentation/views/quire_home_screen.dart';
import 'src/features/photo_upload/services/quire_moment_uploader.dart';

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

class QuireApp extends StatelessWidget {
  const QuireApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quire',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: QuireTokens.paperLight,
        fontFamily: QuireTokens.fontSerif,
        colorScheme: ColorScheme.fromSeed(
          seedColor: QuireTokens.accentLight,
          surface: QuireTokens.surfaceLight,
          background: QuireTokens.paperLight,
        ),
        useMaterial3: true,
      ),
      home: QuireHomeScreen(
        momentUploader: MockQuireMomentUploader(),
      ),
    );
  }
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
