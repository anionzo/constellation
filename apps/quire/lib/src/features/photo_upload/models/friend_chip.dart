import 'package:meta/meta.dart';

/// Represents a friend in the user's finite circle (4–11 people) selectable for a moment.
@immutable
class FriendChip {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isSelected;

  const FriendChip({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isSelected = false,
  });

  FriendChip copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    bool? isSelected,
  }) {
    return FriendChip(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
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
