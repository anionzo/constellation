import 'package:meta/meta.dart';

/// Storage bucket constants and standardized path generators for Supabase Storage.
abstract final class StoragePathGenerator {
  /// Bucket identifiers.
  static const String avatarsBucket = 'avatars';
  static const String quireMomentsBucket = 'quire-moments';
  static const String dreamAttachmentsBucket = 'dream-attachments';

  /// Generates timestamped avatar path: `avatars/{userId}/avatar_{timestamp}.webp`.
  ///
  /// Timestamp avoids CDN/browser cache locks and enables garbage collection of previous avatars.
  static String avatarPath({
    required String userId,
    int? timestamp,
  }) {
    final ts = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    return '$userId/avatar_$ts.webp';
  }

  /// Generates Quire moment path: `quire-moments/{circleId}/{momentId}.webp`.
  static String quireMomentPath({
    required String circleId,
    required String momentId,
  }) {
    return '$circleId/$momentId.webp';
  }

  /// Generates Dream Journal attachment path: `dream-attachments/{userId}/{dreamId}/{photoId}.webp`.
  static String dreamAttachmentPath({
    required String userId,
    required String dreamId,
    required String photoId,
  }) {
    return '$userId/$dreamId/$photoId.webp';
  }

  /// Extracts the timestamp from an avatar filename/path.
  ///
  /// Returns `null` if the filename does not match the `avatar_{timestamp}.webp` pattern.
  static int? extractAvatarTimestamp(String path) {
    final fileName = path.split('/').last;
    final regex = RegExp(r'^avatar_(\d+)\.webp$');
    final match = regex.firstMatch(fileName);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }
}
