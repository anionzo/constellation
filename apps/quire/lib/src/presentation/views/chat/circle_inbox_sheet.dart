import 'package:flutter/material.dart';
import '../../theme/quire_tokens.dart';
import '../../../features/photo_upload/models/friend_chip.dart';
import 'circle_chat_sheet.dart';

class CircleInboxSheet extends StatelessWidget {
  final List<FriendChip> friends;

  const CircleInboxSheet({
    Key? key,
    required this.friends,
  }) : super(key: key);

  void _openChat(BuildContext context, FriendChip friend) {
    Navigator.pop(context); // Close inbox
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CircleChatSheet(friend: friend),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? QuireTokens.paperDark : QuireTokens.paperLight;
    final ruleColor = isDark ? QuireTokens.ruleDark : QuireTokens.ruleLight;

    final sampleSnippets = [
      'Nắng chiều đẹp lắm, tớ thả tim rồi đó!',
      'Ghé quán cà phê quen, đọc xong chương cuối.',
      'Cơn mưa rào đầu mùa nhìn qua cửa sổ.',
      'Cuối tuần này tản bộ tiếp nhé.',
      'Bức ảnh chụp góc ban công trông rất bình yên.',
    ];

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

          // Conversations List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: friends.length,
              separatorBuilder: (_, __) => Divider(height: 1, indent: 68, color: ruleColor),
              itemBuilder: (context, index) {
                final friend = friends[index];
                final snippet = sampleSnippets[index % sampleSnippets.length];

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
                    snippet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: QuireTokens.body(isDark: isDark).copyWith(
                      fontSize: 13,
                      color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light,
                    ),
                  ),
                  trailing: Text(
                    '${(index + 1) * 2}h',
                    style: QuireTokens.meta(isDark: isDark).copyWith(fontSize: 9.5),
                  ),
                  onTap: () => _openChat(context, friend),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
