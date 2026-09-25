import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:media_storage/media_storage.dart';

void main() {
  group('Media Storage & Path Generators', () {
    test('generates timestamped avatar path correctly', () {
      final path = StoragePathGenerator.avatarPath(
        userId: 'user-uuid-123',
        timestamp: 1727198400000,
      );
      expect(path, equals('user-uuid-123/avatar_1727198400000.webp'));
      expect(StoragePathGenerator.extractAvatarTimestamp(path), equals(1727198400000));
    });

    test('generates Quire moment path correctly', () {
      final path = StoragePathGenerator.quireMomentPath(
        circleId: 'circle-uuid-456',
        momentId: 'moment-uuid-789',
      );
      expect(path, equals('circle-uuid-456/moment-uuid-789.webp'));
    });

    test('generates Dream Journal attachment path correctly', () {
      final path = StoragePathGenerator.dreamAttachmentPath(
        userId: 'user-1',
        dreamId: 'dream-2',
        photoId: 'photo-3',
      );
      expect(path, equals('user-1/dream-2/photo-3.webp'));
    });

    test('enforces The Void Invariant (Strict Zero-Persistence)', () {
      expect(
        () => TheVoidStorageGuard.assertNotTheVoid(
          bucket: 'the-void-thoughts',
          path: 'thought_1.webp',
        ),
        throwsA(isA<TheVoidPersistenceViolationException>()),
      );

      expect(
        () => TheVoidStorageGuard.assertNotTheVoid(
          bucket: 'after_midnight_media',
          path: 'void/message.webp',
        ),
        throwsA(isA<TheVoidPersistenceViolationException>()),
      );
    });

    test('cleans up previous avatars properly', () async {
      final deletedPaths = <String>[];

      final adapter = SupabaseMediaStorageAdapter(
        uploader: ({required bucket, required bytes, required contentType, required path}) async => path,
        deleter: ({required bucket, required paths}) async {
          deletedPaths.addAll(paths);
          return paths;
        },
        lister: ({required bucket, prefix}) async {
          return [
            const StorageFileObject(name: 'avatar_1700000000000.webp'),
            const StorageFileObject(name: 'avatar_1710000000000.webp'),
            const StorageFileObject(name: 'avatar_1727198400000.webp'), // Current
          ];
        },
        publicUrlResolver: ({required bucket, required path}) => 'https://cdn.quire.app/$bucket/$path',
        signedUrlResolver: ({required bucket, required expiresInSeconds, required path}) async =>
            'https://signed.quire.app/$bucket/$path',
      );

      final count = await adapter.cleanupPreviousAvatars(
        userId: 'user-123',
        currentAvatarPath: 'user-123/avatar_1727198400000.webp',
      );

      expect(count, equals(2));
      expect(deletedPaths, contains('user-123/avatar_1700000000000.webp'));
      expect(deletedPaths, contains('user-123/avatar_1710000000000.webp'));
      expect(deletedPaths, isNot(contains('user-123/avatar_1727198400000.webp')));
    });
  });
}
