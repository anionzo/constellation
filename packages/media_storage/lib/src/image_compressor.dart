import 'dart:typed_data';
import 'package:meta/meta.dart';
import 'crop_aspect_ratio.dart';

/// Supported image formats for media storage.
enum ImageFormat {
  webp('image/webp', 'webp'),
  jpeg('image/jpeg', 'jpg'),
  png('image/png', 'png');

  final String mimeType;
  final String extension;

  const ImageFormat(this.mimeType, this.extension);
}

/// Compression parameters adhering to Constellation zero-waste media specs.
@immutable
class CompressOptions {
  final ImageFormat format;
  final int quality;
  final int maxWidth;
  final int maxHeight;
  final CropAspectRatio cropRatio;

  const CompressOptions({
    this.format = ImageFormat.webp,
    this.quality = 82,
    this.maxWidth = 1440,
    this.maxHeight = 1440,
    this.cropRatio = CropAspectRatio.original,
  })  : assert(quality >= 1 && quality <= 100, 'Quality must be between 1 and 100'),
        assert(maxWidth > 0, 'maxWidth must be positive'),
        assert(maxHeight > 0, 'maxHeight must be positive');

  /// Standard preset for User Avatar: 1:1 square crop, max 400x400, WebP, quality 82.
  static const CompressOptions avatarPreset = CompressOptions(
    format: ImageFormat.webp,
    quality: 82,
    maxWidth: 400,
    maxHeight: 400,
    cropRatio: CropAspectRatio.square1x1,
  );

  /// Standard preset for Quire Moment / Story: 4:5 vertical crop, max 1440px, WebP, quality 82.
  static const CompressOptions momentPortraitPreset = CompressOptions(
    format: ImageFormat.webp,
    quality: 82,
    maxWidth: 1440,
    maxHeight: 1800,
    cropRatio: CropAspectRatio.portrait4x5,
  );

  /// Standard preset for Quire Moment / Square: 1:1 crop, max 1440px, WebP, quality 82.
  static const CompressOptions momentSquarePreset = CompressOptions(
    format: ImageFormat.webp,
    quality: 82,
    maxWidth: 1440,
    maxHeight: 1440,
    cropRatio: CropAspectRatio.square1x1,
  );

  /// Standard preset for Dream Journal Attachment: preserve aspect, max 1440px, WebP, quality 80.
  static const CompressOptions dreamAttachmentPreset = CompressOptions(
    format: ImageFormat.webp,
    quality: 80,
    maxWidth: 1440,
    maxHeight: 1440,
    cropRatio: CropAspectRatio.original,
  );
}

/// The result of an image compression pipeline.
@immutable
class CompressedImageResult {
  final Uint8List bytes;
  final int width;
  final int height;
  final ImageFormat format;

  const CompressedImageResult({
    required this.bytes,
    required this.width,
    required this.height,
    required this.format,
  });

  /// The size of the compressed payload in bytes.
  int get byteSize => bytes.length;

  /// Human-readable file size (e.g. "45.2 KB").
  String get formattedSize {
    if (byteSize < 1024) return '$byteSize B';
    if (byteSize < 1024 * 1024) {
      return '${(byteSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(byteSize / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

/// Abstract contract for Client-side Image Compression.
///
/// Implementations delegate to platform plugins (`flutter_image_compress`, `image` package)
/// while shielding callers from platform-specific code.
abstract interface class ImageCompressor {
  /// Compresses [rawBytes] according to [options].
  Future<CompressedImageResult> compress({
    required Uint8List rawBytes,
    required CompressOptions options,
  });

  /// Convenience method: compresses an avatar image using [CompressOptions.avatarPreset].
  Future<CompressedImageResult> compressAvatar(Uint8List rawBytes);

  /// Convenience method: compresses a moment image using [CompressOptions.momentPortraitPreset]
  /// or [CompressOptions.momentSquarePreset].
  Future<CompressedImageResult> compressMoment({
    required Uint8List rawBytes,
    CropAspectRatio cropRatio = CropAspectRatio.portrait4x5,
  });
}
