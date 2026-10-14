import 'package:image_picker/image_picker.dart';
import '../models/photo_upload_input.dart';
import 'camera_gallery_service.dart';

/// Real hardware and platform implementation using `image_picker`.
/// Works seamlessly on Web (file dialog & webcam) and Mobile (native Camera & Gallery).
class NativeCameraGalleryService implements CameraGalleryService {
  final ImagePicker _picker;

  NativeCameraGalleryService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  @override
  Future<bool> hasCameraPermission() async => true;

  @override
  Future<bool> requestCameraPermission() async => true;

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<RawPhotoFile?> capturePhoto() async {
    try {
      final xFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );
      if (xFile == null) return null;
      final bytes = await xFile.readAsBytes();
      return RawPhotoFile(
        bytes: bytes,
        source: PhotoInputSource.camera,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<RawPhotoFile?> pickFromGallery() async {
    try {
      final xFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );
      if (xFile == null) return null;
      final bytes = await xFile.readAsBytes();
      return RawPhotoFile(
        bytes: bytes,
        source: PhotoInputSource.gallery,
      );
    } catch (_) {
      return null;
    }
  }
}
