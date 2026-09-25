import '../models/photo_upload_input.dart';

/// Abstract service contract for camera, gallery, and device permissions.
///
/// Follows Dependency Inversion Principle (DIP): allows testing without real hardware.
abstract interface class CameraGalleryService {
  /// Checks whether camera permission is currently granted.
  Future<bool> hasCameraPermission();

  /// Requests camera permission from the operating system.
  Future<bool> requestCameraPermission();

  /// Directs user to OS application settings if permission was permanently denied.
  Future<void> openAppSettings();

  /// Opens camera viewfinder and captures a photo.
  /// Returns `null` if cancelled or denied.
  Future<RawPhotoFile?> capturePhoto();

  /// Opens device gallery picker.
  /// Returns `null` if user dismissed without selection.
  Future<RawPhotoFile?> pickFromGallery();
}
