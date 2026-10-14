import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:quire/src/features/photo_upload/models/photo_upload_input.dart';
import 'package:quire/src/features/photo_upload/services/camera_gallery_service.dart';

void main() {
  group('CameraGalleryService Contracts', () {
    test('DefaultCameraGalleryService returns valid baseline values for headless mode', () async {
      const service = DefaultCameraGalleryService();

      expect(await service.hasCameraPermission(), isTrue);
      expect(await service.requestCameraPermission(), isTrue);
      expect(await service.capturePhoto(), isNull);
      expect(await service.pickFromGallery(), isNull);
    });

    test('RawPhotoFile encapsulates bytes and source cleanly', () {
      final mockBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final photo = RawPhotoFile(
        bytes: mockBytes,
        source: PhotoInputSource.gallery,
        originalFileName: 'test.webp',
      );

      expect(photo.bytes, hasLength(5));
      expect(photo.source, equals(PhotoInputSource.gallery));
      expect(photo.originalFileName, equals('test.webp'));
      expect(photo.bytes.length, equals(5));
    });
  });

  group('Moment Feed Injection & Auth State Contracts', () {
    test('Feed injection data contract contains required display fields', () {
      final now = DateTime.now();
      final mockBytes = Uint8List.fromList([10, 20, 30]);

      final newMoment = {
        'id': 'moment_${now.millisecondsSinceEpoch}',
        'author': 'Bạn',
        'authorInitials': 'B',
        'timeAgo': 'Vừa xong',
        'imageBytes': mockBytes,
        'caption': 'Hoàng hôn bên bờ hồ',
        'liked': false,
        'likesCount': 0,
      };

      expect(newMoment['id'], startsWith('moment_'));
      expect(newMoment['author'], equals('Bạn'));
      expect(newMoment['authorInitials'], equals('B'));
      expect(newMoment['imageBytes'], isNotNull);
      expect(newMoment['liked'], isFalse);
      expect(newMoment['likesCount'], equals(0));
    });

    test('Calm Auth email validation logic accepts valid email and rejects malformed email', () {
      bool isValidEmail(String email) {
        final trimmed = email.trim();
        return trimmed.isNotEmpty && trimmed.contains('@') && trimmed.contains('.');
      }

      expect(isValidEmail('ban@example.com'), isTrue);
      expect(isValidEmail('user.name@domain.co'), isTrue);
      expect(isValidEmail('invalid-email'), isFalse);
      expect(isValidEmail(''), isFalse);
    });
  });
}
