import 'package:meta/meta.dart';
import 'package:media_storage/media_storage.dart';
import '../models/friend_chip.dart';
import '../models/photo_upload_input.dart';

/// Sealed hierarchy of input events processed by Quire's Photo Upload state machine.
@immutable
sealed class PhotoUploadEvent {
  const PhotoUploadEvent();
}

/// User triggered camera capture.
final class CaptureFromCameraRequested extends PhotoUploadEvent {
  final PhotoUploadContext context;
  const CaptureFromCameraRequested({required this.context});
}

/// User triggered gallery selection.
final class SelectFromGalleryRequested extends PhotoUploadEvent {
  final PhotoUploadContext context;
  const SelectFromGalleryRequested({required this.context});
}

/// System or user rejected camera permissions.
final class PermissionDeniedEncountered extends PhotoUploadEvent {
  final PhotoInputSource source;
  const PermissionDeniedEncountered({required this.source});
}

/// Raw image bytes successfully loaded from camera or gallery.
final class PhotoRawAcquired extends PhotoUploadEvent {
  final RawPhotoFile rawPhoto;
  final PhotoUploadContext context;
  const PhotoRawAcquired({
    required this.rawPhoto,
    required this.context,
  });
}

/// Image compression finished; presents Compose sheet.
final class PreprocessingCompleted extends PhotoUploadEvent {
  final CompressedImageResult compressedImage;
  final List<FriendChip> friends;
  final PhotoUploadContext context;
  const PreprocessingCompleted({
    required this.compressedImage,
    required this.friends,
    required this.context,
  });
}

/// User toggles a friend chip selection in the compose sheet.
final class FriendToggled extends PhotoUploadEvent {
  final String friendId;
  const FriendToggled({required this.friendId});
}

/// User updates the optional moment note.
final class CaptionChanged extends PhotoUploadEvent {
  final String newCaption;
  const CaptionChanged({required this.newCaption});
}

/// User taps the "Gửi cho {n} người" button.
final class SendTapped extends PhotoUploadEvent {
  const SendTapped();
}

/// Internal timer tick or start for the 900ms undo window.
final class UndoWindowStarted extends PhotoUploadEvent {
  final String momentId;
  final int selectedCount;
  const UndoWindowStarted({
    required this.momentId,
    required this.selectedCount,
  });
}

/// User taps "Hoàn tác" / "Undo send" within the 900ms window.
final class UndoTapped extends PhotoUploadEvent {
  const UndoTapped();
}

/// 900ms grace window elapsed without user undo; proceeds to final dispatch.
final class UndoWindowExpired extends PhotoUploadEvent {
  const UndoWindowExpired();
}

/// Closes the sheet and resets machine to idle.
final class ResetToIdle extends PhotoUploadEvent {
  const ResetToIdle();
}
