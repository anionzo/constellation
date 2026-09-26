import 'dart:async';
import 'package:media_storage/media_storage.dart';
import '../models/friend_chip.dart';
import '../models/photo_upload_input.dart';
import '../services/camera_gallery_service.dart';
import '../services/quire_moment_uploader.dart';
import '../state/photo_upload_event.dart';
import '../state/photo_upload_state.dart';

/// State Machine controlling the Quire photo upload workflow.
class PhotoUploadStateMachine {
  final CameraGalleryService cameraGalleryService;
  final ImageCompressor imageCompressor;
  final QuireMomentUploader uploader;
  final String currentUserId;
  final Future<List<FriendChip>> Function(String circleId) fetchCircleFriends;

  final StreamController<PhotoUploadState> _stateController =
      StreamController<PhotoUploadState>.broadcast();

  PhotoUploadState _state = const PhotoUploadIdleState();
  Timer? _undoTimer;
  bool _isUndoTriggered = false;

  PhotoUploadStateMachine({
    CameraGalleryService? cameraGalleryService,
    ImageCompressor? imageCompressor,
    required this.uploader,
    String? currentUserId,
    Future<List<FriendChip>> Function(String circleId)? fetchCircleFriends,
    String? circleId,
  })  : cameraGalleryService = cameraGalleryService ?? const DefaultCameraGalleryService(),
        imageCompressor = imageCompressor ?? const DefaultImageCompressor(),
        currentUserId = currentUserId ?? 'current-user-id',
        fetchCircleFriends = fetchCircleFriends ?? ((_) async => const []);

  PhotoUploadState get state => _state;
  Stream<PhotoUploadState> get stateStream => _stateController.stream;

  void _transition(PhotoUploadState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  /// Directly open compose with an already acquired photo.
  Future<void> startComposeWithPhoto({
    required RawPhotoFile photo,
    required PhotoUploadContext context,
  }) async {
    await _processPhotoAndOpenCompose(photo: photo, context: context);
  }

  /// Processes input events adhering to the PhotoUploadEvent contract.
  Future<void> process(PhotoUploadEvent event) async {
    switch (event) {
      case CaptureFromCameraRequested(:final context):
        await startCaptureFromCamera(context: context);
      case SelectFromGalleryRequested(:final context):
        await startSelectionFromGallery(context: context);
      case PhotoRawAcquired(:final rawPhoto, :final context):
        await startComposeWithPhoto(photo: rawPhoto, context: context);
      case FriendToggled(:final friendId):
        toggleFriend(friendId);
      case CaptionChanged(:final newCaption):
        updateCaption(newCaption);
      case SendTapped():
        await submitSend();
      case UndoTapped():
        triggerUndo();
      case ResetToIdle():
        reset();
      default:
        break;
    }
  }

  /// Entry Point: Initiate capture from camera.
  Future<void> startCaptureFromCamera({required PhotoUploadContext context}) async {
    final hasPermission = await cameraGalleryService.hasCameraPermission();
    if (!hasPermission) {
      final granted = await cameraGalleryService.requestCameraPermission();
      if (!granted) {
        _transition(const PhotoUploadPermissionDeniedState(source: PhotoInputSource.camera));
        return;
      }
    }

    _transition(const PhotoUploadPreprocessingState(source: PhotoInputSource.camera));

    final photo = await cameraGalleryService.capturePhoto();
    if (photo == null) {
      _transition(const PhotoUploadIdleState());
      return;
    }

    await _processPhotoAndOpenCompose(photo: photo, context: context);
  }

  /// Entry Point: Select from photo gallery.
  Future<void> startSelectionFromGallery({required PhotoUploadContext context}) async {
    _transition(const PhotoUploadPreprocessingState(source: PhotoInputSource.gallery));

    final photo = await cameraGalleryService.pickFromGallery();
    if (photo == null) {
      _transition(const PhotoUploadIdleState());
      return;
    }

    await _processPhotoAndOpenCompose(photo: photo, context: context);
  }

  /// Preprocesses photo (1:1/4:5 crop, WebP compression <= 1440px) and presents Compose Sheet.
  Future<void> _processPhotoAndOpenCompose({
    required RawPhotoFile photo,
    required PhotoUploadContext context,
  }) async {
    _transition(const PhotoUploadPreprocessingState(source: PhotoInputSource.camera));

    // Compress using 4:5 vertical preset for stories, or 1:1 if preferred
    final compressed = await imageCompressor.compressMoment(
      rawBytes: photo.bytes,
      cropRatio: CropAspectRatio.portrait4x5,
    );

    final friends = await fetchCircleFriends(context.circleId);

    // Initial Compose State: no friend pre-selected
    _transition(PhotoUploadComposeState(
      compressedImage: compressed,
      availableFriends: friends,
      selectedFriendIds: const {},
      caption: '',
      context: context,
    ));
  }

  /// Toggle friend selection in Compose Sheet.
  void toggleFriend(String friendId) {
    if (_state is! PhotoUploadComposeState) return;
    final composeState = _state as PhotoUploadComposeState;

    final updated = Set<String>.from(composeState.selectedFriendIds);
    if (updated.contains(friendId)) {
      updated.remove(friendId);
    } else {
      updated.add(friendId);
    }

    _transition(composeState.copyWith(selectedFriendIds: updated));
  }

  /// Update optional caption/note.
  void updateCaption(String caption) {
    if (_state is! PhotoUploadComposeState) return;
    final composeState = _state as PhotoUploadComposeState;
    _transition(composeState.copyWith(caption: caption));
  }

  /// User taps Send button:
  /// 1. Immediately locks button in SendingState.
  /// 2. Opens 900ms Undo Grace Window.
  Future<void> submitSend() async {
    if (_state is! PhotoUploadComposeState) return;
    final composeState = _state as PhotoUploadComposeState;

    // Enforce Invariant: At least 1 friend must be selected
    if (!composeState.canSend) {
      return;
    }

    final momentId = DateTime.now().millisecondsSinceEpoch.toString();
    final selectedCount = composeState.selectedCount;

    // Step 4: Immediately lock button in SendingState
    _transition(PhotoUploadSendingState(
      momentId: momentId,
      selectedCount: selectedCount,
    ));

    _isUndoTriggered = false;

    // Step 5: Transition to 900ms Undo Window
    _transition(PhotoUploadUndoGraceState.initial(
      momentId: momentId,
      selectedCount: selectedCount,
    ));

    // Start 900ms countdown timer
    _undoTimer?.cancel();
    _undoTimer = Timer(const Duration(milliseconds: 900), () async {
      if (!_isUndoTriggered) {
        await _executeBackgroundDispatch(
          momentId: momentId,
          composeState: composeState,
        );
      }
    });
  }

  /// User taps "Hoàn tác" / "Undo send" within the 900ms grace window.
  void triggerUndo() {
    if (_state is! PhotoUploadUndoGraceState) return;

    _isUndoTriggered = true;
    _undoTimer?.cancel();
    _undoTimer = null;

    // Abort mechanism: send cancelled, zero bytes leave app
    _transition(const PhotoUploadAbortedState());
  }

  /// Background dispatch after 900ms grace period finishes.
  Future<void> _executeBackgroundDispatch({
    required String momentId,
    required PhotoUploadComposeState composeState,
  }) async {
    final result = await uploader.dispatchMoment(
      momentId: momentId,
      circleId: composeState.context.circleId,
      senderId: currentUserId,
      imageBytes: composeState.compressedImage.bytes,
      recipientIds: composeState.selectedFriendIds,
      caption: composeState.caption.isNotEmpty ? composeState.caption : null,
      articleId: composeState.context.articleId,
      replyToMomentId: composeState.context.replyToMomentId,
    );

    _transition(PhotoUploadDispatchedState(
      momentId: momentId,
      isOfflineQueued: result.isOfflineQueued,
      statusMessage: result.message,
    ));
  }

  /// Reset to idle when sheet is closed.
  void reset() {
    _undoTimer?.cancel();
    _undoTimer = null;
    _isUndoTriggered = false;
    _transition(const PhotoUploadIdleState());
  }

  void dispose() {
    _undoTimer?.cancel();
    _stateController.close();
  }
}
