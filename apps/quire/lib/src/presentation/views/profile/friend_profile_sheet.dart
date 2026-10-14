import 'package:flutter/material.dart';
import '../../theme/quire_tokens.dart';
import '../../../features/photo_upload/models/friend_chip.dart';

class FriendProfileSheet extends StatelessWidget {
  final FriendChip friend;
  final bool hasUnreadStory;
  final VoidCallback? onOpenChat;
  final VoidCallback? onOpenStory;
  final VoidCallback? onRemoveFriend;

  const FriendProfileSheet({
    Key? key,
    required this.friend,
    this.hasUnreadStory = false,
    this.onOpenChat,
    this.onOpenStory,
    this.onRemoveFriend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? QuireTokens.paperDark : QuireTokens.paperLight;
    final surfaceColor = isDark ? QuireTokens.surfaceDark : QuireTokens.surfaceLight;
    final ruleColor = isDark ? QuireTokens.ruleDark : QuireTokens.ruleLight;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(QuireTokens.rSheet)),
        border: Border.all(color: ruleColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar with Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('HỒ SƠ BẠN BÈ', style: QuireTokens.eyebrow(isDark: isDark)),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Avatar, Name, Username and Location Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: hasUnreadStory ? onOpenStory : null,
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
                  child: Text(
                    friend.initials,
                    style: TextStyle(
                      fontFamily: QuireTokens.fontMono,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.name,
                      style: QuireTokens.title(isDark: isDark).copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      friend.displayUsername,
                      style: TextStyle(
                        fontFamily: QuireTokens.fontMono,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? QuireTokens.accentDark : QuireTokens.accentLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '📍 ${friend.displayCity} · Vòng thân thiết',
                      style: QuireTokens.meta(isDark: isDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Bio Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(QuireTokens.rCard),
              border: Border.all(color: ruleColor),
            ),
            child: Text(
              friend.displayBio,
              style: QuireTokens.body(isDark: isDark).copyWith(
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Friendship Stats Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
              borderRadius: BorderRadius.circular(QuireTokens.rCard),
              border: Border.all(color: ruleColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${friend.sharedMomentsCount}',
                      style: TextStyle(fontFamily: QuireTokens.fontMono, fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                    ),
                    const SizedBox(height: 2),
                    Text('Khoảnh khắc chung', style: QuireTokens.meta(isDark: isDark).copyWith(fontSize: 9)),
                  ],
                ),
                Container(width: 1, height: 28, color: ruleColor),
                Column(
                  children: [
                    Text(
                      'Tháng 3',
                      style: TextStyle(fontFamily: QuireTokens.fontMono, fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                    ),
                    const SizedBox(height: 2),
                    Text('Kết nối từ', style: QuireTokens.meta(isDark: isDark).copyWith(fontSize: 9)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Action Buttons: Chat & Story
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? QuireTokens.accentDark : QuireTokens.accentLight,
                    foregroundColor: isDark ? QuireTokens.onAccentDark : QuireTokens.onAccentLight,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(QuireTokens.rBtn)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onOpenChat?.call();
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Nhắn tin riêng'),
                ),
              ),
              if (hasUnreadStory && onOpenStory != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                      side: BorderSide(color: isDark ? QuireTokens.ruleDark : QuireTokens.ruleLight),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(QuireTokens.rBtn)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      onOpenStory?.call();
                    },
                    icon: const Icon(Icons.panorama_fish_eye, size: 18),
                    label: const Text('Xem Story'),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Remove Friend button
          if (onRemoveFriend != null)
            Center(
              child: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: const Color(0xFFC13832)),
                onPressed: () {
                  Navigator.pop(context);
                  onRemoveFriend?.call();
                },
                icon: const Icon(Icons.person_remove_outlined, size: 16),
                label: const Text(
                  'Gỡ khỏi vòng bạn bè',
                  style: TextStyle(fontFamily: QuireTokens.fontSerif, fontSize: 13),
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
