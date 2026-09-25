/// Exception thrown when code attempts to persist or upload data from After Midnight's The Void.
class TheVoidPersistenceViolationException implements Exception {
  final String message;
  final String? pathAttempted;

  const TheVoidPersistenceViolationException({
    required this.message,
    this.pathAttempted,
  });

  @override
  String toString() =>
      'TheVoidPersistenceViolationException: $message (attempted: $pathAttempted). '
      'Violates Constellation Invariant 2 & Cross-App Invariant 4: '
      'The Void is strictly zero-byte and zero-persistence.';
}

/// Runtime guard preventing any storage interaction with The Void content.
abstract final class TheVoidStorageGuard {
  /// Asserts that a target bucket or storage operation is not associated with The Void.
  static void assertNotTheVoid({
    required String bucket,
    required String path,
  }) {
    final lowerBucket = bucket.toLowerCase();
    final lowerPath = path.toLowerCase();

    if (lowerBucket.contains('void') ||
        lowerBucket.contains('after_midnight') ||
        lowerBucket.contains('after-midnight') ||
        lowerPath.contains('void')) {
      throw TheVoidPersistenceViolationException(
        message: 'Forbidden attempt to route The Void data to Supabase Storage.',
        pathAttempted: '$bucket/$path',
      );
    }
  }
}
