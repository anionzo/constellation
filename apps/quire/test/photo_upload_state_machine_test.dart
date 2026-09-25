import 'dart:async';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:media_storage/media_storage.dart';
import 'package:local_sync/local_sync.dart';
import 'package:quire/src/features/photo_upload/quire_photo_upload.dart';

class MockCameraGalleryService implements CameraGalleryService {
  bool hasPermission = true;
  bool requestGranted = true;
  RawPhotoFile? photoToReturn;

  @override
  Future<bool> hasCameraPermission() async => hasPermission;

  @override
  Future<bool> requestCameraPermission() async => requestGranted;

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<RawPhotoFile?> capturePhoto() async => photoToReturn;

  @override
  Future<RawPhotoFile?> pickFromGallery() async => photoToReturn;
}

class MockImageCompressor implements ImageCompressor {
  @override
  Future<CompressedImageResult> compress({required Uint8List rawBytes, required CompressOptions options}) async {
    return CompressedImageResult(
      bytes: rawBytes,
      width: 1440,
      height: 1800,
      format: ImageFormat.webp,
    );
  }

  @override
  Future<CompressedImageResult> compressAvatar(Uint8List rawBytes) async {
    return CompressedImageResult(
      bytes: rawBytes,
      width: 400,
      height: 400,
      format: ImageFormat.webp,
    );
  }

  @override
  Future<CompressedImageResult> compressMoment({required Uint8List rawBytes, CropAspectRatio cropRatio = CropAspectRatio.portrait4x5}) async {
    return CompressedImageResult(
      bytes: rawBytes,
      width: 1440,
      height: 1800,
      format: ImageFormat.webp,
    );
  }
}

class MockMediaStorageAdapter implements MediaStorageAdapter {
  final List<String> uploadedPaths = [];

  @override
  Future<String> uploadFile({required String bucket, required String path, required Uint8List bytes, required String contentType}) async {
    uploadedPaths.add(path);
    return path;
  }

  @override
  Future<void> deleteFile({required String bucket, required String path}) async {}

  @override
  Future<List<String>> deleteFiles({required String bucket, required List<String> paths}) async => paths;

  @override
  Future<List<StorageFileObject>> listFiles({required String bucket, String? prefix}) async => [];

  @override
  String getPublicUrl({required String bucket, required String path}) => 'https://cdn.example.com/$path';

  @override
  Future<String> createSignedUrl({required String bucket, required String path, required int expiresInSeconds}) async => 'https://signed.example.com/$path';

  @override
  Future<int> cleanupPreviousAvatars({required String userId, required String currentAvatarPath}) async => 0;
}

void main() {
  group("Quire Photo Upload State Machine", () {
    late MockCameraGalleryService cameraService;
    late MockImageCompressor compressor;
    late MockMediaStorageAdapter storageAdapter;
    late MemoryLocalStoreAdapter localStore;
    late QuireMomentUploader uploader;
    late PhotoUploadStateMachine machine;

    final circleFriends = [
      const FriendChip(id: 'friend-1', name: 'Alice'),
      const FriendChip(id: 'friend-2', name: 'Bob'),
      const FriendChip(id: 'friend-3', name: 'Charlie'),
    ];

    setUp(() {
      cameraService = MockCameraGalleryService();
      compressor = MockImageCompressor();
      storageAdapter = MockMediaStorageAdapter();
      localStore = MemoryLocalStoreAdapter();
      uploader = QuireMomentUploader(
        storageAdapter: storageAdapter,
        dbInserter: ({required momentRow, required recipientRows}) async {},
        localStore: localStore,
        isOnline: () async => true,
      );

      machine = PhotoUploadStateMachine(
        cameraGalleryService: cameraService,
        imageCompressor: compressor,
        uploader: uploader,
        currentUserId: 'test-user-id',
        fetchCircleFriends: (circleId) async => circleFriends,
      );
    });

    tearDown(() {
      machine.dispose();
    });

    test('transitions to PermissionDeniedState when camera permission denied', () async {
      cameraService.hasPermission = false;
      cameraService.requestGranted = false;

      await machine.startCaptureFromCamera(
        context: const PhotoUploadContext(circleId: 'circle-1'),
      );

      expect(machine.state, isA<PhotoUploadPermissionDeniedState>());
      final state = machine.state as PhotoUploadPermissionDeniedState;
      expect(state.title, equals('Quyền truy cập máy ảnh đang tắt'));
    });

    test('transitions to ComposeState after photo capture and enforces friend picker invariant >= 1', () async {
      cameraService.photoToReturn = RawPhotoFile(
        bytes: Uint8List.fromList([1, 2, 3, 4]),
        source: PhotoInputSource.camera,
      );

      await machine.startCaptureFromCamera(
        context: const PhotoUploadContext(circleId: 'circle-1'),
      );

      expect(machine.state, isA<PhotoUploadComposeState>());
      final compose = machine.state as PhotoUploadComposeState;

      // Invariant: no friends selected yet -> canSend must be false
      expect(compose.canSend, isFalse);
      expect(compose.sendButtonLabel, equals('Chọn ít nhất một người'));

      // Select Alice
      machine.toggleFriend('friend-1');
      final updatedCompose = machine.state as PhotoUploadComposeState;
      expect(updatedCompose.canSend, isTrue);
      expect(updatedCompose.selectedCount, equals(1));
      expect(updatedCompose.sendButtonLabel, equals('Gửi cho 1 người'));

      // Select Bob
      machine.toggleFriend('friend-2');
      final multiCompose = machine.state as PhotoUploadComposeState;
      expect(multiCompose.selectedCount, equals(2));
      expect(multiCompose.sendButtonLabel, equals('Gửi cho 2 người'));
    });

    test('submitSend immediately locks button in SendingState and triggers 900ms Undo grace window', () async {
      cameraService.photoToReturn = RawPhotoFile(
        bytes: Uint8List.fromList([1, 2, 3, 4]),
        source: PhotoInputSource.camera,
      );

      await machine.startCaptureFromCamera(
        context: const PhotoUploadContext(circleId: 'circle-1'),
      );

      machine.toggleFriend('friend-1');

      // Tap send
      final future = machine.submitSend();

      // State is immediately in UndoGraceState (with SendingState having preceded)
      expect(machine.state, isA<PhotoUploadUndoGraceState>());
      final undoState = machine.state as PhotoUploadUndoGraceState;
      expect(undoState.title, equals('Đã gửi cho 1 người'));
      expect(undoState.undoButtonLabel, equals('Hoàn tác'));

      await future;
    });

    test('tapping Undo within 900ms window aborts send and leaves zero data in storage or network', () async {
      cameraService.photoToReturn = RawPhotoFile(
        bytes: Uint8List.fromList([1, 2, 3, 4]),
        source: PhotoInputSource.camera,
      );

      await machine.startCaptureFromCamera(
        context: const PhotoUploadContext(circleId: 'circle-1'),
      );

      machine.toggleFriend('friend-1');
      await machine.submitSend();

      expect(machine.state, isA<PhotoUploadUndoGraceState>());

      // User hits Undo before 900ms elapses
      machine.triggerUndo();

      expect(machine.state, isA<PhotoUploadAbortedState>());
      final aborted = machine.state as PhotoUploadAbortedState;
      expect(aborted.message, equals('Đã huỷ gửi. Không có gì rời khỏi ứng dụng.'));

      // Wait 1000ms to verify background timer does NOT fire
      await Future.delayed(const Duration(milliseconds: 1000));

      expect(storageAdapter.uploadedPaths, isEmpty);
      expect(await localStore.getQueueSize(), equals(0));
    });

    test('900ms window expiration dispatches moment to storage and database', () async {
      cameraService.photoToReturn = RawPhotoFile(
        bytes: Uint8List.fromList([1, 2, 3, 4]),
        source: PhotoInputSource.camera,
      );

      await machine.startCaptureFromCamera(
        context: const PhotoUploadContext(circleId: 'circle-1'),
      );

      machine.toggleFriend('friend-1');
      await machine.submitSend();

      // Wait 1100ms for 900ms timer to expire
      await Future.delayed(const Duration(milliseconds: 1100));

      expect(machine.state, isA<PhotoUploadDispatchedState>());
      final dispatched = machine.state as PhotoUploadDispatchedState;
      expect(dispatched.isOfflineQueued, isFalse);
      expect(storageAdapter.uploadedPaths.length, equals(1));
    });
  });
}
