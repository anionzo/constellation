import 'package:flutter/material.dart';
import '../../theme/quire_tokens.dart';
import '../../../features/photo_upload/models/friend_chip.dart';
import '../../../features/api/bff_api_client.dart';
import 'circle_chat_sheet.dart';

class CircleInboxSheet extends StatelessWidget {
  final BffApiClient? bffClient;
  final List<FriendChip> friends;

  const CircleInboxSheet({
    Key? key,
    this.bffClient,
    required this.friends,
  }) : super(key: key);

  void _openChat(BuildContext context, FriendChip friend) {
    Navigator.pop(context); // Close inbox
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CircleChatSheet(
        bffClient: bffClient,
        friend: friend,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? QuireTokens.paperDark : QuireTokens.paperLight;
    final ruleColor = isDark ? QuireTokens.ruleDark : QuireTokens.ruleLight;

    return Container(
      constraints: const BoxConstraints(maxHeight: 620),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(QuireTokens.rSheet)),
        border: Border.all(color: ruleColor),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HỘP THƯ VÒNG BẠN BÈ', style: QuireTokens.eyebrow(isDark: isDark)),
                    const SizedBox(height: 2),
                    Text('Trò chuyện & Phản hồi', style: QuireTokens.title(isDark: isDark).copyWith(fontSize: 20)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: ruleColor),

          // Live Database Conversations List
          Expanded(
            child: FutureBuilder<List<dynamic>?>(
              future: bffClient?.getInbox(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                }

                final rawList = snapshot.data;
                // If backend returned inbox items, use them; otherwise fallback to friends list
                if (rawList != null && rawList.isNotEmpty) {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: rawList.length,
                    separatorBuilder: (_, __) => Divider(height: 1, indent: 68, color: ruleColor),
                    itemBuilder: (context, index) {
                      final item = rawList[index] as Map<String, dynamic>;
                      final friendId = item['friend_id']?.toString() ?? '';
                      final friendName = item['friend_name']?.toString() ?? 'Bạn';
                      final initials = item['friend_initials']?.toString() ??
                          (friendName.isNotEmpty ? friendName[0].toUpperCase() : 'B');
                      final lastMsg = item['last_message']?.toString() ?? 'Bấm vào để bắt đầu cuộc trò chuyện...';
                      final unreadCount = (item['unread_count'] as num?)?.toInt() ?? 0;

                      final friendChip = FriendChip(id: friendId, name: friendName, initials: initials);

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        leading: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
                              child: Text(
                                initials,
                                style: TextStyle(
                                  fontFamily: QuireTokens.fontMono,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                                ),
                              ),
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: QuireTokens.accentLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          friendName,
                          style: QuireTokens.h3(isDark: isDark).copyWith(
                            fontSize: 15.5,
                            fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          lastMsg,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: QuireTokens.body(isDark: isDark).copyWith(
                            fontSize: 13,
                            color: unreadCount > 0
                                ? (isDark ? QuireTokens.inkDark : QuireTokens.inkLight)
                                : (isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light),
                            fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        trailing: unreadCount > 0
                            ? Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: QuireTokens.accentLight,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : const Icon(Icons.arrow_forward_ios, size: 12),
                        onTap: () => _openChat(context, friendChip),
                      );
                    },
                  );
                }

                // Fallback to active friends list
                if (friends.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 36, color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light),
                          const SizedBox(height: 12),
                          Text(
                            'Chưa có cuộc trò chuyện nào.',
                            style: QuireTokens.title(isDark: isDark).copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hãy kết nối thêm bạn bè vào vòng để bắt đầu trò chuyện yên lặng.',
                            textAlign: TextAlign.center,
                            style: QuireTokens.body(isDark: isDark),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: friends.length,
                  separatorBuilder: (_, __) => Divider(height: 1, indent: 68, color: ruleColor),
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
                        child: Text(
                          friend.initials,
                          style: TextStyle(
                            fontFamily: QuireTokens.fontMono,
                            fontWeight: FontWeight.bold,
                            color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                          ),
                        ),
                      ),
                      title: Text(
                        friend.name,
                        style: QuireTokens.h3(isDark: isDark).copyWith(fontSize: 15.5),
                      ),
                      subtitle: Text(
                        'Bấm vào để bắt đầu cuộc trò chuyện...',
                        style: QuireTokens.body(isDark: isDark).copyWith(
                          fontSize: 13,
                          color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light,
                        ),
                      ),
                      onTap: () => _openChat(context, friend),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
