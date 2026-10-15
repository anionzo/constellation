import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../theme/quire_tokens.dart';
import '../../widgets/quire_circle_avatar.dart';
import '../quire_compose_sheet.dart';
import '../../../features/photo_upload/models/friend_chip.dart';
import '../../../features/photo_upload/models/photo_upload_input.dart';
import '../../../features/photo_upload/machine/photo_upload_state_machine.dart';
import '../../../features/photo_upload/services/quire_moment_uploader.dart';
import '../../../features/photo_upload/services/camera_gallery_service.dart';
import '../../../features/photo_upload/services/native_camera_gallery_service.dart';
import '../chat/circle_chat_sheet.dart';
import '../chat/circle_inbox_sheet.dart';
import '../../../features/api/bff_api_client.dart';

class MomentsTabView extends StatefulWidget {
  final BffApiClient? bffClient;
  final List<FriendChip> friends;
  final QuireMomentUploader momentUploader;

  const MomentsTabView({
    Key? key,
    this.bffClient,
    required this.friends,
    required this.momentUploader,
  }) : super(key: key);
  @override
  State<MomentsTabView> createState() => _MomentsTabViewState();
}

class _MomentsTabViewState extends State<MomentsTabView> {
  final CameraGalleryService _cameraService = NativeCameraGalleryService();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadMomentsFromBackend();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    if (widget.bffClient == null) return;
    try {
      final count = await widget.bffClient!.getUnreadMessageCount();
      if (mounted) setState(() => _unreadCount = count);
    } catch (_) {}
  }

  bool _isLoading = true;
  final List<Map<String, dynamic>> _moments = [];
  Future<void> _loadMomentsFromBackend() async {
    setState(() => _isLoading = true);
    if (widget.bffClient == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final res = await widget.bffClient!.getMomentsFeed();
      if (res != null && res['data'] is List) {
        final List<dynamic> list = res['data'] as List<dynamic>;
        if (mounted) {
          setState(() {
            _moments.clear();
            for (final item in list) {
              final m = item as Map<String, dynamic>;
              _moments.add({
                'id': m['id']?.toString() ?? '',
                'sender_id': m['sender_id']?.toString() ?? '',
                'author': m['sender_name']?.toString() ?? 'Bạn',
                'authorInitials': m['sender_initials']?.toString() ?? 'B',
                'timeAgo': 'Vừa xong',
                'imageUrl': (m['image_url'] != null && m['image_url'].toString().isNotEmpty)
                    ? m['image_url'].toString()
                    : 'https://picsum.photos/seed/${m['id']}/800/800',
                'caption': m['caption']?.toString() ?? '',
                'liked': m['is_liked'] == true,
                'likesCount': (m['likes_count'] as num?)?.toInt() ?? 0,
              });
            }
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openPhotoSourceSelector() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? QuireTokens.paperDark : QuireTokens.paperLight;
    final ruleColor = isDark ? QuireTokens.ruleDark : QuireTokens.ruleLight;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
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
              Text('CHIA SẺ KHOẢNH KHẮC', style: QuireTokens.eyebrow(isDark: isDark)),
              const SizedBox(height: 4),
              Text('Chọn nguồn ảnh của bạn', style: QuireTokens.title(isDark: isDark)),
              const SizedBox(height: 18),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(QuireTokens.rCard),
                  side: BorderSide(color: ruleColor),
                ),
                leading: const Icon(Icons.photo_library_outlined, color: QuireTokens.accentLight),
                title: Text('Chọn ảnh từ máy / Thư viện', style: QuireTokens.h3(isDark: isDark).copyWith(fontSize: 16)),
                subtitle: Text('Tải ảnh từ máy tính hoặc thư viện ảnh', style: QuireTokens.meta(isDark: isDark)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final photo = await _cameraService.pickFromGallery();
                  if (photo != null) {
                    _openComposeWithPhoto(photo.bytes, PhotoSource.gallery);
                  } else {
                    final sampleBytes = Uint8List.fromList(List<int>.filled(1024, 0));
                    _openComposeWithPhoto(sampleBytes, PhotoSource.gallery);
                  }
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(QuireTokens.rCard),
                  side: BorderSide(color: ruleColor),
                ),
                leading: const Icon(Icons.camera_alt_outlined, color: QuireTokens.accentLight),
                title: Text('Chụp ảnh từ Camera / Webcam', style: QuireTokens.h3(isDark: isDark).copyWith(fontSize: 16)),
                subtitle: Text('Chụp ảnh trực tiếp từ thiết bị của bạn', style: QuireTokens.meta(isDark: isDark)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final photo = await _cameraService.capturePhoto();
                  if (photo != null) {
                    _openComposeWithPhoto(photo.bytes, PhotoSource.camera);
                  } else {
                    final sampleBytes = Uint8List.fromList(List<int>.filled(1024, 0));
                    _openComposeWithPhoto(sampleBytes, PhotoSource.camera);
                  }
                },
              ),
              const SizedBox(height: 18),
            ],
          ),
        );
      },
    );
  }

  void _openComposeWithPhoto(Uint8List rawBytes, PhotoSource source) {
    final stateMachine = PhotoUploadStateMachine(
      uploader: widget.momentUploader,
      fetchCircleFriends: (_) async => widget.friends,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuireComposeSheet(
        input: PhotoUploadInput(
          rawBytes: rawBytes,
          source: source,
        ),
        availableFriends: widget.friends,
        stateMachine: stateMachine,
        onClose: () => Navigator.pop(ctx),
        onShowToast: (msg) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg, style: const TextStyle(fontFamily: QuireTokens.fontSerif)),
              backgroundColor: QuireTokens.inkLight,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
          );
        },
        onMomentDispatched: (caption) {
          setState(() {
            _moments.insert(0, {
              'id': 'moment_${DateTime.now().millisecondsSinceEpoch}',
              'author': 'Bạn',
              'authorInitials': 'B',
              'timeAgo': 'Vừa xong',
              'imageBytes': rawBytes,
              'caption': caption.isNotEmpty ? caption : 'Khoảnh khắc vừa chia sẻ',
              'liked': false,
              'likesCount': 0,
            });
          });
        },
      ),
    );
  }

  void _openChatWith(
    FriendChip friend, {
    String? quotedImageUrl,
    Uint8List? quotedImageBytes,
    String? quotedCaption,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CircleChatSheet(
        bffClient: widget.bffClient,
        friend: friend,
        initialQuotedImageUrl: quotedImageUrl,
        initialQuotedImageBytes: quotedImageBytes,
        initialQuotedCaption: quotedCaption,
      ),
    );
  }

  void _openInbox() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CircleInboxSheet(bffClient: widget.bffClient, friends: widget.friends),
    );
  }

  void _openStory(int initialIndex) {
    int currentIndex = initialIndex.clamp(0, widget.friends.isNotEmpty ? widget.friends.length - 1 : 0);
    bool isLiked = false;
    int likeCount = 3;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStoryState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            final friend = widget.friends[currentIndex];
            final storyCaptions = [
              'Tản bộ chiều chủ nhật, không vội vã.',
              'Góc sách quen ở quán cà phê cũ.',
              'Mưa đầu mùa trên hiên nhà.',
              'Ánh hoàng hôn buông trên bến cảng.',
              'Tách trà nóng và một trang tản văn hay.',
            ];
            final caption = storyCaptions[currentIndex % storyCaptions.length];

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 680),
                decoration: BoxDecoration(
                  color: isDark ? QuireTokens.surfaceDark : QuireTokens.surfaceLight,
                  borderRadius: BorderRadius.circular(QuireTokens.rSheet),
                  border: Border.all(color: isDark ? QuireTokens.ruleDark : QuireTokens.ruleLight),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Story Top Bar & Segmented Progress across friends
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: List.generate(
                              widget.friends.length.clamp(1, 6),
                              (i) => Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(right: i < widget.friends.length.clamp(1, 6) - 1 ? 4.0 : 0),
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: i == (currentIndex % 6)
                                        ? QuireTokens.accentLight
                                        : (isDark ? QuireTokens.ruleDark : QuireTokens.ruleLight),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
                                    child: Text(
                                      friend.initials,
                                      style: TextStyle(
                                        fontFamily: QuireTokens.fontMono,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(friend.name, style: QuireTokens.h3(isDark: isDark).copyWith(fontSize: 15)),
                                      Text('${currentIndex + 1} / ${widget.friends.length} · 2 giờ trước',
                                          style: QuireTokens.meta(isDark: isDark).copyWith(fontSize: 9)),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () => Navigator.pop(ctx),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Story Image with Left/Right Tap Navigation
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(QuireTokens.rPhoto),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                'https://picsum.photos/seed/story_${friend.initials}/800/1000',
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
                                  child: const Icon(Icons.photo, size: 64),
                                ),
                              ),
                              // Tap left: previous friend
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                width: 140,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    if (currentIndex > 0) {
                                      setStoryState(() {
                                        currentIndex--;
                                        isLiked = false;
                                      });
                                    }
                                  },
                                ),
                              ),
                              // Tap right: next friend
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                width: 140,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    if (currentIndex < widget.friends.length - 1) {
                                      setStoryState(() {
                                        currentIndex++;
                                        isLiked = false;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Story Caption & Interactive Actions
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            caption,
                            style: QuireTokens.body(isDark: isDark).copyWith(
                              fontStyle: FontStyle.italic,
                              fontSize: 15.0,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              // In-story like button
                              IconButton(
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: isLiked ? const Color(0xFFC13832) : (isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                                  size: 22,
                                ),
                                onPressed: () {
                                  setStoryState(() {
                                    isLiked = !isLiked;
                                    likeCount = isLiked ? likeCount + 1 : likeCount - 1;
                                  });
                                },
                              ),
                              Text(
                                '$likeCount',
                                style: TextStyle(
                                  fontFamily: QuireTokens.fontMono,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isLiked ? const Color(0xFFC13832) : (isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Reply with photo action
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                                    side: BorderSide(color: isDark ? QuireTokens.ruleDark : QuireTokens.ruleLight),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(QuireTokens.rBtn),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _openPhotoSourceSelector();
                                  },
                                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                                  label: Text(
                                    'Đáp lại bằng ảnh',
                                    style: QuireTokens.button(isDark: isDark),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? QuireTokens.surfaceDark : QuireTokens.surfaceLight;
    final ruleColor = isDark ? QuireTokens.ruleDark : QuireTokens.ruleLight;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('QUIRE · KHOẢNH KHẮC', style: QuireTokens.eyebrow(isDark: isDark)),
                  const SizedBox(height: 4),
                  Text(
                    'Từ những người bạn quen',
                    style: QuireTokens.title(isDark: isDark),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline, size: 22),
                      tooltip: 'Hộp thư vòng bạn bè',
                      onPressed: () {
                        setState(() => _unreadCount = 0);
                        _openInbox();
                      },
                    ),
                    if (_unreadCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: QuireTokens.accentLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined, size: 24),
                  tooltip: 'Chụp ảnh nhanh',
                  onPressed: _openPhotoSourceSelector,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('Chỉ những người trong vòng thân thiết của bạn xem được.', style: QuireTokens.body(isDark: isDark)),
        const SizedBox(height: 16),

        // Circle Avatars Row
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            itemCount: widget.friends.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: [
                    QuireCircleAvatar(
                      initials: '+',
                      isUserAddCircle: true,
                      onTap: _openPhotoSourceSelector,
                    ),
                    const SizedBox(height: 6),
                    Text('Của bạn', style: QuireTokens.meta(isDark: isDark)),
                  ],
                );
              }
              final friend = widget.friends[index - 1];
              return Column(
                children: [
                  QuireCircleAvatar(
                    initials: friend.initials,
                    hasUnreadStory: index == 1, // Mai has unread dashed ring
                    onTap: () => _openStory(index - 1),
                  ),
                  const SizedBox(height: 6),
                  Text(friend.name, style: QuireTokens.meta(isDark: isDark)),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Live Moments Feed Cards
        if (_isLoading) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ] else if (_moments.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.panorama_fish_eye, size: 36, color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light),
                  const SizedBox(height: 12),
                  Text(
                    'Chưa có khoảnh khắc nào từ bạn bè.',
                    style: QuireTokens.title(isDark: isDark).copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Hãy bấm nút chụp ảnh ở giữa để chia sẻ khoảnh khắc đầu tiên lên CSDL!',
                    textAlign: TextAlign.center,
                    style: QuireTokens.body(isDark: isDark),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          for (final moment in _moments)
            Builder(
              builder: (context) {
                final isLiked = moment['liked'] as bool? ?? false;
                final count = (moment['likesCount'] as num?)?.toInt() ?? 0;
                final imageBytes = moment['imageBytes'] as Uint8List?;

                return Container(
            margin: const EdgeInsets.only(bottom: 20.0),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(QuireTokens.rCard),
              border: Border.all(color: ruleColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header of card
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
                        child: Text(
                          moment['authorInitials'] as String,
                          style: TextStyle(
                            fontFamily: QuireTokens.fontMono,
                            fontWeight: FontWeight.bold,
                            color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(moment['author'] as String, style: QuireTokens.h3(isDark: isDark).copyWith(fontSize: 15)),
                          Text(moment['timeAgo'] as String, style: QuireTokens.meta(isDark: isDark).copyWith(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Card Photo: Image.memory for real uploaded bytes or Image.network for mock fixtures
                ClipRRect(
                  borderRadius: BorderRadius.circular(QuireTokens.rPhoto),
                  child: imageBytes != null
                      ? Image.memory(
                          imageBytes,
                          height: 280,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          moment['imageUrl'] as String,
                          height: 280,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 280,
                            color: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
                            child: const Icon(Icons.broken_image, size: 48),
                          ),
                        ),
                ),

                // Caption
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Text(
                    moment['caption'] as String,
                    style: QuireTokens.body(isDark: isDark).copyWith(fontSize: 15.0),
                  ),
                ),

                // Action Bar: Thả tim & Đáp lại bằng ảnh
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 16, 10),
                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          final willLike = !isLiked;
                          setState(() {
                            moment['liked'] = willLike;
                            moment['likesCount'] = willLike ? count + 1 : (count > 0 ? count - 1 : 0);
                          });
                          await widget.bffClient?.toggleLikeMoment(moment['id']?.toString() ?? '');
                        },
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? const Color(0xFFC13832) : (isDark ? QuireTokens.ink2Dark : QuireTokens.ink2Light),
                        ),
                        label: Text(
                          isLiked ? '$count tim' : 'Thả tim',
                          style: QuireTokens.meta(isDark: isDark),
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          final authorName = moment['author']?.toString() ?? 'Bạn bè';
                          final authorInitials = moment['authorInitials']?.toString() ?? 'B';
                          final senderId = moment['sender_id']?.toString() ?? '';

                          final friend = widget.friends.firstWhere(
                            (f) => f.id == senderId || f.name == authorName,
                            orElse: () => FriendChip(
                              id: senderId.isNotEmpty ? senderId : '11111111-1111-1111-1111-111111111111',
                              name: authorName,
                              initials: authorInitials,
                            ),
                          );
                          _openChatWith(
                            friend,
                            quotedImageUrl: moment['imageUrl'] as String?,
                            quotedImageBytes: moment['imageBytes'] as Uint8List?,
                            quotedCaption: moment['caption'] as String?,
                          );
                        },
                        icon: const Icon(Icons.reply_outlined, size: 16),
                        label: Text('Phản hồi ảnh', style: QuireTokens.meta(isDark: isDark)),
                      ),
                      const SizedBox(width: 6),
                      TextButton.icon(
                        onPressed: _openPhotoSourceSelector,
                        icon: const Icon(Icons.camera_alt_outlined, size: 16),
                        label: Text('Đáp lại', style: QuireTokens.meta(isDark: isDark)),
                      ),
                    ],
                  ),
                ),
              ],
              ),
            );
          },
        ),
      ],
    ],
  );
  }
}
