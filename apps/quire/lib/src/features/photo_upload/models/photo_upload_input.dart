import 'dart:typed_data';
import 'package:meta/meta.dart';

/// The origin of the captured/selected photo.
enum PhotoInputSource {
  camera,
  gallery,
}

/// Contextual metadata if moment is created from article or reply.
@immutable
class PhotoUploadContext {
  final String circleId;
  final String? articleId;
  final String? replyToMomentId;

  const PhotoUploadContext({
    required this.circleId,
    this.articleId,
    this.replyToMomentId,
  });

  bool get isArticleAttachment => articleId != null;
  bool get isMomentReply => replyToMomentId != null;
}

/// Raw in-memory photo file from camera or gallery.
@immutable
class RawPhotoFile {
  final Uint8List bytes;
  final PhotoInputSource source;
  final String? originalFileName;

  const RawPhotoFile({
    required this.bytes,
    required this.source,
    this.originalFileName,
  });
}
