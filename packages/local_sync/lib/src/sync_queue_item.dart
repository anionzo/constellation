import 'package:meta/meta.dart';
import 'sync_status.dart';

/// An individual task or payload queued in the local offline store.
@immutable
class SyncQueueItem {
  final String id;
  final String actionType;
  final Map<String, dynamic> payload;
  final SyncStatus status;
  final int retryCount;
  final int maxRetries;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  final DateTime? nextRetryAt;
  final String? errorMessage;

  const SyncQueueItem({
    required this.id,
    required this.actionType,
    required this.payload,
    this.status = SyncStatus.pending,
    this.retryCount = 0,
    this.maxRetries = 5,
    required this.createdAt,
    this.lastAttemptAt,
    this.nextRetryAt,
    this.errorMessage,
  });

  /// Creates a copy with modified fields.
  SyncQueueItem copyWith({
    String? id,
    String? actionType,
    Map<String, dynamic>? payload,
    SyncStatus? status,
    int? retryCount,
    int? maxRetries,
    DateTime? createdAt,
    DateTime? lastAttemptAt,
    DateTime? nextRetryAt,
    String? errorMessage,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Serializes to a JSON-compatible map for SQLite or key-value storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action_type': actionType,
      'payload': payload,
      'status': status.name,
      'retry_count': retryCount,
      'max_retries': maxRetries,
      'created_at': createdAt.toIso8601String(),
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt!.toIso8601String(),
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt!.toIso8601String(),
      if (errorMessage != null) 'error_message': errorMessage,
    };
  }

  /// Deserializes from a JSON-compatible map.
  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] as String,
      actionType: json['action_type'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      status: SyncStatus.values.byName(json['status'] as String),
      retryCount: json['retry_count'] as int? ?? 0,
      maxRetries: json['max_retries'] as int? ?? 5,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastAttemptAt: json['last_attempt_at'] != null
          ? DateTime.parse(json['last_attempt_at'] as String)
          : null,
      nextRetryAt: json['next_retry_at'] != null
          ? DateTime.parse(json['next_retry_at'] as String)
          : null,
      errorMessage: json['error_message'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncQueueItem &&
        other.id == id &&
        other.actionType == actionType &&
        other.status == status &&
        other.retryCount == retryCount;
  }

  @override
  int get hashCode => Object.hash(id, actionType, status, retryCount);
}
