import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../theme/quire_tokens.dart';
import '../../../features/photo_upload/models/friend_chip.dart';
import '../../../features/photo_upload/services/native_camera_gallery_service.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final String time;
  final Uint8List? imageBytes;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    this.imageBytes,
  });
}

class CircleChatSheet extends StatefulWidget {
  final FriendChip friend;

  const CircleChatSheet({
    Key? key,
    required this.friend,
  }) : super(key: key);

  @override
  State<CircleChatSheet> createState() => _CircleChatSheetState();
}

class _CircleChatSheetState extends State<CircleChatSheet> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    // Sample initial quiet messages
    _messages = [
      ChatMessage(
        id: '1',
        text: 'Cậu xem bức ảnh tớ vừa chụp ở góc phố cũ chưa?',
        isMe: false,
        time: '14:02',
      ),
      ChatMessage(
        id: '2',
        text: 'Nắng chiều đẹp lắm, tớ thả tim rồi đó!',
        isMe: true,
        time: '14:05',
      ),
      ChatMessage(
        id: '3',
        text: 'Cuối tuần này nếu rảnh tản bộ tiếp nhé.',
        isMe: false,
        time: '14:06',
      ),
    ];
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage({String? text, Uint8List? imageBytes}) {
    final content = text ?? _msgController.text.trim();
    if (content.isEmpty && imageBytes == null) return;

    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: content,
          isMe: true,
          time: timeStr,
          imageBytes: imageBytes,
        ),
      );
    });

    _msgController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickPhotoAndSend() async {
    final photo = await NativeCameraGalleryService().pickFromGallery();
    if (photo != null) {
      _sendMessage(text: 'Đã chia sẻ 1 ảnh khoảnh khắc', imageBytes: photo.bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? QuireTokens.paperDark : QuireTokens.paperLight;
    final surfaceColor = isDark ? QuireTokens.surfaceDark : QuireTokens.surfaceLight;
    final ruleColor = isDark ? QuireTokens.ruleDark : QuireTokens.ruleLight;

    return Container(
      constraints: const BoxConstraints(maxHeight: 650),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
                  child: Text(
                    widget.friend.initials,
                    style: TextStyle(
                      fontFamily: QuireTokens.fontMono,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.friend.name, style: QuireTokens.h3(isDark: isDark).copyWith(fontSize: 16)),
                      Text('Trò chuyện riêng tư trong vòng', style: QuireTokens.meta(isDark: isDark).copyWith(fontSize: 9)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: ruleColor),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: msg.isMe
                          ? (isDark ? QuireTokens.accentSoftDark : QuireTokens.accentSoftLight)
                          : surfaceColor,
                      borderRadius: BorderRadius.circular(QuireTokens.rCard),
                      border: Border.all(
                        color: msg.isMe
                            ? (isDark ? QuireTokens.accentDark : QuireTokens.accentLight)
                            : ruleColor,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (msg.imageBytes != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(QuireTokens.rPhoto),
                            child: Image.memory(
                              msg.imageBytes!,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          msg.text,
                          style: TextStyle(
                            fontFamily: QuireTokens.fontSerif,
                            fontSize: 14.0,
                            color: msg.isMe
                                ? (isDark ? QuireTokens.inkDark : QuireTokens.accentInkLight)
                                : (isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg.time,
                          style: QuireTokens.meta(isDark: isDark).copyWith(fontSize: 8.5),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, color: ruleColor),

          // Message Input Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined, color: QuireTokens.accentLight),
                  onPressed: _pickPhotoAndSend,
                  tooltip: 'Gửi ảnh',
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(QuireTokens.rField),
                      border: Border.all(color: ruleColor),
                    ),
                    child: TextField(
                      controller: _msgController,
                      style: TextStyle(fontFamily: QuireTokens.fontSerif, color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                      decoration: const InputDecoration(
                        hintText: 'Nhập tin nhắn riêng tư...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: QuireTokens.accentLight),
                  onPressed: () => _sendMessage(),
                  tooltip: 'Gửi',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
