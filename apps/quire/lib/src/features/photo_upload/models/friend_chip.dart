import 'package:meta/meta.dart';

/// Represents a friend in the user's circle with rich profile details.
@immutable
class FriendChip {
  final String id;
  final String name;
  final String? username;
  final String? bio;
  final String? city;
  final int sharedMomentsCount;
  final String? avatarUrl;
  final String? _initials;
  final bool isSelected;

  const FriendChip({
    required this.id,
    required this.name,
    this.username,
    this.bio,
    this.city,
    this.sharedMomentsCount = 8,
    this.avatarUrl,
    String? initials,
    this.isSelected = false,
  }) : _initials = initials;

  String get displayUsername {
    if (username != null && username!.isNotEmpty) return username!;
    if (name.isEmpty) return '@friend';
    return '@${name.toLowerCase().replaceAll(RegExp(r'\s+'), '.')}';
  }

  String get displayBio => bio ?? 'Chia sẻ những khoảng lặng bình yên trong ngày.';
  String get displayCity => city ?? 'Lisbon';

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
    String? username,
    String? bio,
    String? city,
    int? sharedMomentsCount,
    String? avatarUrl,
    String? initials,
    bool? isSelected,
  }) {
    return FriendChip(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      city: city ?? this.city,
      sharedMomentsCount: sharedMomentsCount ?? this.sharedMomentsCount,
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
        other.username == username &&
        other.isSelected == isSelected;
  }

  @override
  int get hashCode => Object.hash(id, name, username, isSelected);
}
