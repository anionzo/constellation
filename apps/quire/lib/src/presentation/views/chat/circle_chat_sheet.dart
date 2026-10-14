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
  final String? quotedImageUrl;
  final Uint8List? quotedImageBytes;
  final String? quotedCaption;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    this.imageBytes,
    this.quotedImageUrl,
    this.quotedImageBytes,
    this.quotedCaption,
  });
}

class CircleChatSheet extends StatefulWidget {
  final FriendChip friend;
  final String? initialQuotedImageUrl;
  final Uint8List? initialQuotedImageBytes;
  final String? initialQuotedCaption;

  const CircleChatSheet({
    Key? key,
    required this.friend,
    this.initialQuotedImageUrl,
    this.initialQuotedImageBytes,
    this.initialQuotedCaption,
  }) : super(key: key);

  @override
  State<CircleChatSheet> createState() => _CircleChatSheetState();
}

class _CircleChatSheetState extends State<CircleChatSheet> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _quotedImageUrl;
  Uint8List? _quotedImageBytes;
  String? _quotedCaption;

  late final List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _quotedImageUrl = widget.initialQuotedImageUrl;
    _quotedImageBytes = widget.initialQuotedImageBytes;
    _quotedCaption = widget.initialQuotedCaption;

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
          quotedImageUrl: _quotedImageUrl,
          quotedImageBytes: _quotedImageBytes,
          quotedCaption: _quotedCaption,
        ),
      );

      // Clear quote after sending
      _quotedImageUrl = null;
      _quotedImageBytes = null;
      _quotedCaption = null;
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
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
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
                        // Quoted Moment Preview block if present
                        if (msg.quotedImageUrl != null || msg.quotedImageBytes != null) ...[
                          Container(
                            padding: const EdgeInsets.all(6),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
                              borderRadius: BorderRadius.circular(QuireTokens.rPhoto),
                              border: Border(left: BorderSide(color: QuireTokens.accentLight, width: 3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: msg.quotedImageBytes != null
                                      ? Image.memory(msg.quotedImageBytes!, width: 38, height: 38, fit: BoxFit.cover)
                                      : Image.network(msg.quotedImageUrl!, width: 38, height: 38, fit: BoxFit.cover),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Khoảnh khắc của ${widget.friend.name}',
                                        style: TextStyle(fontFamily: QuireTokens.fontMono, fontSize: 9, fontWeight: FontWeight.bold, color: QuireTokens.accentLight),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        msg.quotedCaption ?? 'Không có chú thích',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontFamily: QuireTokens.fontSerif, fontSize: 11.5, color: isDark ? QuireTokens.ink2Dark : QuireTokens.ink2Light),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Attached photo
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

                        // Message Text
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

          // Quoted Banner above input bar
          if (_quotedImageUrl != null || _quotedImageBytes != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: _quotedImageBytes != null
                        ? Image.memory(_quotedImageBytes!, width: 34, height: 34, fit: BoxFit.cover)
                        : Image.network(_quotedImageUrl!, width: 34, height: 34, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Đang phản hồi khoảnh khắc của ${widget.friend.name}', style: TextStyle(fontFamily: QuireTokens.fontMono, fontSize: 9.5, fontWeight: FontWeight.bold, color: QuireTokens.accentLight)),
                        Text(_quotedCaption ?? 'Khoảnh khắc', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: QuireTokens.fontSerif, fontSize: 11, color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      setState(() {
                        _quotedImageUrl = null;
                        _quotedImageBytes = null;
                        _quotedCaption = null;
                      });
                    },
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: ruleColor),
          ],

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
                      decoration: InputDecoration(
                        hintText: (_quotedImageUrl != null || _quotedImageBytes != null)
                            ? 'Viết phản hồi về bức ảnh này...'
                            : 'Nhập tin nhắn riêng tư...',
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
