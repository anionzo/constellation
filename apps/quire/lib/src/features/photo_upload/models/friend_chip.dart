import 'package:meta/meta.dart';

/// Represents a friend in the user's finite circle (4–11 people) selectable for a moment.
@immutable
class FriendChip {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? _initials;
  final bool isSelected;

  const FriendChip({
    required this.id,
    required this.name,
    this.avatarUrl,
    String? initials,
    this.isSelected = false,
  }) : _initials = initials;

  String get initials {
    if (_initials != null && _initials!.isNotEmpty) return _initials!;
    if (name.isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length > 2 ? 2 : name.length).toUpperCase();
  }

  FriendChip copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? initials,
    bool? isSelected,
  }) {
    return FriendChip(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      initials: initials ?? _initials,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FriendChip &&
        other.id == id &&
        other.name == name &&
        other.isSelected == isSelected;
  }

  @override
  int get hashCode => Object.hash(id, name, isSelected);
}
