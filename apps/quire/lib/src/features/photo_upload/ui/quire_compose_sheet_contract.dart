import 'dart:typed_data';
import '../models/friend_chip.dart';

/// Contract for the UI layer rendering Quire's Compose Sheet and Undo overlay.
///
/// Follows Interface Segregation Principle (ISP).
abstract interface class QuireComposeSheetContract {
  /// Renders permission fallback view.
  void showPermissionDeniedModal({
    required String title,
    required String message,
    required VoidCallback onOpenSettings,
    required VoidCallback onChooseGallery,
  });

  /// Updates the compose sheet UI with the current thumbnail and chips.
  void renderComposeView({
    required Uint8List thumbnailBytes,
    required List<FriendChip> friendChips,
    required bool canSend,
    required String sendButtonLabel,
    required void Function(String friendId) onToggleFriend,
    required void Function(String text) onCaptionChanged,
    required VoidCallback onSend,
  });

  /// Renders the 900ms Undo grace window overlay.
  void renderUndoWindow({
    required String title,
    required String subtitle,
    required String undoLabel,
    required VoidCallback onUndo,
  });

  /// Displays the toast: "Đã huỷ gửi. Không có gì rời khỏi ứng dụng."
  void showAbortToast(String message);

  /// Dismisses all compose modals and returns to active tab.
  void dismissComposeFlow();
}

typedef VoidCallback = void Function();
