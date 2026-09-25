import 'dart:typed_data';
import 'package:meta/meta.dart';

/// Metadata representation of a file in Supabase Storage.
@immutable
class StorageFileObject {
  final String name;
  final String? id;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final DateTime? lastAccessedAt;
  final Map<String, dynamic>? metadata;

  const StorageFileObject({
    required this.name,
    this.id,
    this.updatedAt,
    this.createdAt,
    this.lastAccessedAt,
    this.metadata,
  });

  factory StorageFileObject.fromJson(Map<String, dynamic> json) {
    return StorageFileObject(
      name: json['name'] as String,
      id: json['id'] as String?,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      lastAccessedAt: json['last_accessed_at'] != null ? DateTime.tryParse(json['last_accessed_at'] as String) : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Abstract contract for Supabase Storage operations.
///
/// Follows Dependency Inversion Principle (DIP): clients depend on this abstraction,
/// allowing easy mocking, testing, and decoupling from supabase_flutter SDK.
abstract interface class MediaStorageAdapter {
  /// Uploads binary data to a target bucket and storage path.
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String contentType,
  });

  /// Deletes a single file from the target bucket.
  Future<void> deleteFile({
    required String bucket,
    required String path,
  });

  /// Deletes multiple files in a batch from the target bucket.
  Future<List<String>> deleteFiles({
    required String bucket,
    required List<String> paths,
  });

  /// Lists all files in the bucket under an optional directory prefix.
  Future<List<StorageFileObject>> listFiles({
    required String bucket,
    String? prefix,
  });

  /// Gets the public CDN URL for a file in a public bucket (e.g. `avatars`).
  String getPublicUrl({
    required String bucket,
    required String path,
  });

  /// Generates a temporary Signed URL for a private bucket (e.g. `quire-moments`).
  Future<String> createSignedUrl({
    required String bucket,
    required String path,
    required int expiresInSeconds,
  });

  /// Garbage collection: Deletes older avatar files in `avatars/{userId}/`
  /// preserving only the file specified by [currentAvatarPath].
  Future<int> cleanupPreviousAvatars({
    required String userId,
    required String currentAvatarPath,
  });
}
