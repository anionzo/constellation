import 'dart:typed_data';
import 'media_storage_adapter.dart';
import 'storage_path_generator.dart';
import 'the_void_guard.dart';

/// Function signature for raw upload calls.
typedef RawStorageUploader = Future<String> Function({
  required String bucket,
  required String path,
  required Uint8List bytes,
  required String contentType,
});

/// Function signature for raw delete calls.
typedef RawStorageDeleter = Future<List<String>> Function({
  required String bucket,
  required List<String> paths,
});

/// Function signature for raw list calls.
typedef RawStorageLister = Future<List<StorageFileObject>> Function({
  required String bucket,
  String? prefix,
});

/// Function signature for generating public URLs.
typedef RawPublicUrlResolver = String Function({
  required String bucket,
  required String path,
});

/// Function signature for generating signed URLs.
typedef RawSignedUrlResolver = Future<String> Function({
  required String bucket,
  required String path,
  required int expiresInSeconds,
});

/// Production Supabase Storage adapter adhering to SOLID and Constellation invariants.
class SupabaseMediaStorageAdapter implements MediaStorageAdapter {
  final RawStorageUploader _uploader;
  final RawStorageDeleter _deleter;
  final RawStorageLister _lister;
  final RawPublicUrlResolver _publicUrlResolver;
  final RawSignedUrlResolver _signedUrlResolver;

  SupabaseMediaStorageAdapter({
    required RawStorageUploader uploader,
    required RawStorageDeleter deleter,
    required RawStorageLister lister,
    required RawPublicUrlResolver publicUrlResolver,
    required RawSignedUrlResolver signedUrlResolver,
  })  : _uploader = uploader,
        _deleter = deleter,
        _lister = lister,
        _publicUrlResolver = publicUrlResolver,
        _signedUrlResolver = signedUrlResolver;

  @override
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async {
    // Invariant Enforcement: The Void must never be stored.
    TheVoidStorageGuard.assertNotTheVoid(bucket: bucket, path: path);

    return _uploader(
      bucket: bucket,
      path: path,
      bytes: bytes,
      contentType: contentType,
    );
  }

  @override
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    TheVoidStorageGuard.assertNotTheVoid(bucket: bucket, path: path);
    await _deleter(bucket: bucket, paths: [path]);
  }

  @override
  Future<List<String>> deleteFiles({
    required String bucket,
    required List<String> paths,
  }) async {
    for (final p in paths) {
      TheVoidStorageGuard.assertNotTheVoid(bucket: bucket, path: p);
    }
    return _deleter(bucket: bucket, paths: paths);
  }

  @override
  Future<List<StorageFileObject>> listFiles({
    required String bucket,
    String? prefix,
  }) async {
    TheVoidStorageGuard.assertNotTheVoid(bucket: bucket, path: prefix ?? '');
    return _lister(bucket: bucket, prefix: prefix);
  }

  @override
  String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    TheVoidStorageGuard.assertNotTheVoid(bucket: bucket, path: path);
    return _publicUrlResolver(bucket: bucket, path: path);
  }

  @override
  Future<String> createSignedUrl({
    required String bucket,
    required String path,
    required int expiresInSeconds,
  }) async {
    TheVoidStorageGuard.assertNotTheVoid(bucket: bucket, path: path);
    return _signedUrlResolver(
      bucket: bucket,
      path: path,
      expiresInSeconds: expiresInSeconds,
    );
  }

  @override
  Future<int> cleanupPreviousAvatars({
    required String userId,
    required String currentAvatarPath,
  }) async {
    final currentFileName = currentAvatarPath.split('/').last;

    // List all files in user's avatar directory
    final files = await listFiles(
      bucket: StoragePathGenerator.avatarsBucket,
      prefix: userId,
    );

    // Identify stale avatar files that differ from the newly uploaded one
    final stalePaths = files
        .where((file) {
          final name = file.name;
          // Must match avatar_*.webp pattern and not be current active file
          return name.startsWith('avatar_') &&
              name.endsWith('.webp') &&
              name != currentFileName;
        })
        .map((file) => '$userId/${file.name}')
        .toList();

    if (stalePaths.isEmpty) {
      return 0;
    }

    final deleted = await deleteFiles(
      bucket: StoragePathGenerator.avatarsBucket,
      paths: stalePaths,
    );

    return deleted.length;
  }
}
