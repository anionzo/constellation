import 'package:meta/meta.dart';
import 'package:media_storage/media_storage.dart';
import '../models/friend_chip.dart';
import '../models/photo_upload_input.dart';

/// Exhaustive sealed state hierarchy for Quire's Photo Upload state machine.
@immutable
sealed class PhotoUploadState {
  const PhotoUploadState();
}

/// Initial resting state before user initiates capture or selection.
final class PhotoUploadIdleState extends PhotoUploadState {
  const PhotoUploadIdleState();
}

/// State when camera permission is denied by the user or OS.
final class PhotoUploadPermissionDeniedState extends PhotoUploadState {
  final PhotoInputSource source;
  final String title;
  final String message;
  final String openSettingsLabel;
  final String chooseGalleryLabel;

  const PhotoUploadPermissionDeniedState({
    this.source = PhotoInputSource.camera,
    this.title = 'Quyền truy cập máy ảnh đang tắt',
    this.message = 'Quire cần quyền máy ảnh để chụp và gửi khoảnh khắc đến bạn bè.',
    this.openSettingsLabel = 'Mở cài đặt',
    this.chooseGalleryLabel = 'Chọn từ thư viện',
  });
}

/// State while client is cropping and compressing the image to WebP (max 1440px).
final class PhotoUploadPreprocessingState extends PhotoUploadState {
  final PhotoInputSource source;
  final String progressLabel;

  const PhotoUploadPreprocessingState({
    required this.source,
    this.progressLabel = 'Đang chuẩn bị ảnh…',
  });
}

/// Compose sheet state displaying thumbnail, note input, and Friend Chips.
final class PhotoUploadComposeState extends PhotoUploadState {
  final CompressedImageResult compressedImage;
  final List<FriendChip> availableFriends;
  final Set<String> selectedFriendIds;
  final String caption;
  final PhotoUploadContext context;

  const PhotoUploadComposeState({
    required this.compressedImage,
    required this.availableFriends,
    this.selectedFriendIds = const {},
    this.caption = '',
    required this.context,
  });

  /// Invariant: Must select at least 1 friend.
  bool get canSend => selectedFriendIds.isNotEmpty;

  int get selectedCount => selectedFriendIds.length;

  /// Dynamic send button label based on recipient count.
  String get sendButtonLabel {
    if (!canSend) {
      return 'Chọn ít nhất một người';
    }
    return 'Gửi cho $selectedCount người';
  }

  PhotoUploadComposeState copyWith({
    CompressedImageResult? compressedImage,
    List<FriendChip>? availableFriends,
    Set<String>? selectedFriendIds,
    String? caption,
    PhotoUploadContext? context,
  }) {
    return PhotoUploadComposeState(
      compressedImage: compressedImage ?? this.compressedImage,
      availableFriends: availableFriends ?? this.availableFriends,
      selectedFriendIds: selectedFriendIds ?? this.selectedFriendIds,
      caption: caption ?? this.caption,
      context: context ?? this.context,
    );
  }
}

/// Transient "Sending..." state locking the submit button immediately to prevent double-sends.
final class PhotoUploadSendingState extends PhotoUploadState {
  final String momentId;
  final int selectedCount;
  final String buttonLabel;
  final bool isButtonLocked;

  const PhotoUploadSendingState({
    required this.momentId,
    required this.selectedCount,
    this.buttonLabel = 'Đang gửi…',
    this.isButtonLocked = true,
  });
}

/// 900ms Undo Grace Window state displaying "Sent to {n}" and "Undo send".
final class PhotoUploadUndoGraceState extends PhotoUploadState {
  final String momentId;
  final int selectedCount;
  final int graceWindowRemainingMs;
  final String title;
  final String subtitle;
  final String undoButtonLabel;

  const PhotoUploadUndoGraceState({
    required this.momentId,
    required this.selectedCount,
    this.graceWindowRemainingMs = 900,
    required this.title,
    this.subtitle = 'Họ có thể thả tim, đáp lại bằng ảnh, hoặc giữ riêng.',
    this.undoButtonLabel = 'Hoàn tác',
  });

  factory PhotoUploadUndoGraceState.initial({
    required String momentId,
    required int selectedCount,
  }) {
    return PhotoUploadUndoGraceState(
      momentId: momentId,
      selectedCount: selectedCount,
      title: 'Đã gửi cho $selectedCount người',
      graceWindowRemainingMs: 900,
    );
  }
}

/// Terminal aborted state when user clicked "Undo send" within the 900ms window.
final class PhotoUploadAbortedState extends PhotoUploadState {
  final String message;

  const PhotoUploadAbortedState({
    this.message = 'Đã huỷ gửi. Không có gì rời khỏi ứng dụng.',
  });
}

/// Terminal dispatched state after 900ms window expired and moment was uploaded or queued.
final class PhotoUploadDispatchedState extends PhotoUploadState {
  final String momentId;
  final bool isOfflineQueued;
  final String statusMessage;

  const PhotoUploadDispatchedState({
    required this.momentId,
    required this.isOfflineQueued,
    required this.statusMessage,
  });
}
