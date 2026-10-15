import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/quire_tokens.dart';
import '../../theme/quire_theme.dart';
import '../profile/friend_profile_sheet.dart';
import '../chat/circle_chat_sheet.dart';
import '../../../features/photo_upload/models/friend_chip.dart';
import '../../../features/photo_upload/services/native_camera_gallery_service.dart';
import '../../../features/api/bff_api_client.dart';

class YouTabView extends StatefulWidget {
  final BffApiClient? bffClient;
  final ThemeController themeController;
  final List<FriendChip> friends;
  final String currentUserEmail;
  final String currentUserName;
  final String currentUsername;
  final String currentUserBio;
  final Uint8List? currentUserAvatarBytes;
  final void Function(String name, String username, String bio, Uint8List? avatarBytes)? onProfileUpdated;
  final void Function(FriendChip newFriend)? onAddFriend;
  final void Function(String friendId)? onRemoveFriend;
  final VoidCallback? onSignOut;

  const YouTabView({
    Key? key,
    this.bffClient,
    required this.themeController,
    required this.friends,
    this.currentUserEmail = 'Khách trải nghiệm',
    this.currentUserName = 'Bạn',
    this.currentUsername = '@ban.quire',
    this.currentUserBio = 'Thành viên từ tháng 3 · Lisbon',
    this.currentUserAvatarBytes,
    this.onProfileUpdated,
    this.onAddFriend,
    this.onRemoveFriend,
    this.onSignOut,
  }) : super(key: key);

  @override
  State<YouTabView> createState() => _YouTabViewState();
}

class _YouTabViewState extends State<YouTabView> {
  bool _readReceiptsEnabled = false; // Quiet invariant: Off by default
  bool _autoPurgeEnabled = true;
  String _autoPurgeDuration = '30 ngày'; // '24 giờ', '7 ngày', '30 ngày'
  @override
  void initState() {
    super.initState();
    _loadProfileFromBackend();
  }

  Future<void> _loadProfileFromBackend() async {
    if (widget.bffClient == null) return;
    try {
      final p = await widget.bffClient!.getMyProfile();
      if (p != null && mounted) {
        final name = p['display_name']?.toString() ?? '';
        final username = p['username']?.toString() ?? '';
        final bio = p['bio']?.toString() ?? '';
        if (name.isNotEmpty || username.isNotEmpty) {
          widget.onProfileUpdated?.call(name, username, bio, widget.currentUserAvatarBytes);
        }
      }
    } catch (_) {}
  }

  void _showLogoutSecurityDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? QuireTokens.surfaceDark : QuireTokens.surfaceLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(QuireTokens.rCard)),
          title: Text(
            'Bảo mật phiên đăng nhập',
            style: QuireTokens.title(isDark: isDark).copyWith(fontSize: 18),
          ),
          content: Text(
            'Bạn muốn đăng xuất khỏi thiết bị này hay thu hồi toàn bộ token trên tất cả các thiết bị để đảm bảo an toàn?',
            style: QuireTokens.body(isDark: isDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Hủy', style: QuireTokens.meta(isDark: isDark)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await widget.bffClient?.logout();
                widget.onSignOut?.call();
              },
              child: const Text('Đăng xuất thiết bị này', style: TextStyle(color: Color(0xFFC13832))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC13832),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await widget.bffClient?.logoutAll();
                widget.onSignOut?.call();
              },
              child: const Text('Đăng xuất TẤT CẢ thiết bị'),
            ),
          ],
        );
      },
    );
  }
  final TextEditingController _addFriendController = TextEditingController();

  @override
  void dispose() {
    _addFriendController.dispose();
    super.dispose();
  }

  void _openFriendProfile(FriendChip friend) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FriendProfileSheet(
        friend: friend,
        hasUnreadStory: friend.name == 'Mai',
        onOpenChat: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => CircleChatSheet(bffClient: widget.bffClient, friend: friend),
          );
        },
        onRemoveFriend: () {
          widget.onRemoveFriend?.call(friend.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã gỡ ${friend.name} khỏi vòng bạn bè.')),
          );
        },
      ),
    );
  }
  void _openEditProfileSheet() {
    final nameController = TextEditingController(text: widget.currentUserName);
    final usernameController = TextEditingController(text: widget.currentUsername);
    final bioController = TextEditingController(text: widget.currentUserBio);
    Uint8List? selectedAvatar = widget.currentUserAvatarBytes;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            final bgColor = isDark ? QuireTokens.paperDark : QuireTokens.paperLight;
            final surfaceColor = isDark ? QuireTokens.surfaceDark : QuireTokens.surfaceLight;
            final ruleColor = isDark ? QuireTokens.ruleDark : QuireTokens.ruleLight;

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('HỒ SƠ CỦA BẠN', style: QuireTokens.eyebrow(isDark: isDark)),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Chỉnh sửa thông tin', style: QuireTokens.title(isDark: isDark)),
                    const SizedBox(height: 20),

                    // Avatar Picker
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
                            backgroundImage: selectedAvatar != null ? MemoryImage(selectedAvatar!) : null,
                            child: selectedAvatar == null
                                ? Text(
                                    widget.currentUserName.isNotEmpty ? widget.currentUserName[0].toUpperCase() : 'B',
                                    style: TextStyle(
                                      fontFamily: QuireTokens.fontMono,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () async {
                                final photo = await NativeCameraGalleryService().pickFromGallery();
                                if (photo != null) {
                                  setSheetState(() {
                                    selectedAvatar = photo.bytes;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: QuireTokens.accentLight,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: bgColor, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name Input
                    Text('TÊN HIỂN THỊ', style: QuireTokens.eyebrow(isDark: isDark)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(QuireTokens.rField),
                        border: Border.all(color: ruleColor),
                      ),
                      child: TextField(
                        controller: nameController,
                        style: TextStyle(fontFamily: QuireTokens.fontSerif, color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                        decoration: const InputDecoration(border: InputBorder.none),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Username Input
                    Text('TÊN ĐỊNH DANH (@USERNAME)', style: QuireTokens.eyebrow(isDark: isDark)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(QuireTokens.rField),
                        border: Border.all(color: ruleColor),
                      ),
                      child: TextField(
                        controller: usernameController,
                        style: TextStyle(fontFamily: QuireTokens.fontMono, fontWeight: FontWeight.bold, color: QuireTokens.accentLight),
                        decoration: const InputDecoration(border: InputBorder.none),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bio Input
                    Text('TIỂU SỬ & NƠI CHỐN', style: QuireTokens.eyebrow(isDark: isDark)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(QuireTokens.rField),
                        border: Border.all(color: ruleColor),
                      ),
                      child: TextField(
                        controller: bioController,
                        style: TextStyle(fontFamily: QuireTokens.fontSerif, color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                        decoration: const InputDecoration(border: InputBorder.none),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? QuireTokens.accentDark : QuireTokens.accentLight,
                          foregroundColor: isDark ? QuireTokens.onAccentDark : QuireTokens.onAccentLight,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(QuireTokens.rBtn)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          var uname = usernameController.text.trim();
                          if (!uname.startsWith('@')) uname = '@$uname';
                          widget.onProfileUpdated?.call(
                            nameController.text.trim(),
                            uname,
                            bioController.text.trim(),
                            selectedAvatar,
                          );
                          await widget.bffClient?.updateMyProfile(
                            displayName: nameController.text.trim(),
                            username: uname,
                            bio: bioController.text.trim(),
                            city: 'Lisbon',
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        child: Text(
                          'Lưu thay đổi',
                          style: TextStyle(
                            fontFamily: QuireTokens.fontSerif,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark ? QuireTokens.onAccentDark : QuireTokens.onAccentLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openCircleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            final bgColor = isDark ? QuireTokens.paperDark : QuireTokens.paperLight;
            final surfaceColor = isDark ? QuireTokens.surfaceDark : QuireTokens.surfaceLight;
            final ruleColor = isDark ? QuireTokens.ruleDark : QuireTokens.ruleLight;

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 620),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('VÒNG THÂN THIẾT', style: QuireTokens.eyebrow(isDark: isDark)),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${widget.friends.length} người bạn thân', style: QuireTokens.title(isDark: isDark)),
                    const SizedBox(height: 6),
                    Text(
                      'Khoảnh khắc chỉ được chia sẻ trong vòng tròn hữu hạn này. Bạn có thể thêm hoặc bớt thành viên.',
                      style: QuireTokens.body(isDark: isDark),
                    ),
                    const SizedBox(height: 16),

                    // Add friend input
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14.0),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(QuireTokens.rField),
                              border: Border.all(color: ruleColor),
                            ),
                            child: TextField(
                              controller: _addFriendController,
                              style: TextStyle(fontFamily: QuireTokens.fontSerif, color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                              decoration: const InputDecoration(
                                hintText: 'Nhập tên bạn mới...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: QuireTokens.accentLight,
                            foregroundColor: QuireTokens.onAccentLight,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(QuireTokens.rBtn)),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            final name = _addFriendController.text.trim();
                            if (name.isNotEmpty) {
                              final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
                              final newChip = FriendChip(
                                id: 'f_${DateTime.now().millisecondsSinceEpoch}',
                                name: name,
                                initials: initials.isNotEmpty ? initials : name[0].toUpperCase(),
                              );
                              widget.onAddFriend?.call(newChip);
                              await widget.bffClient?.addFriendByUsername(name);
                              _addFriendController.clear();
                              setSheetState(() {});
                            }
                          },
                          child: const Text('Thêm'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Friends Chips list with remove button
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: widget.friends.map((f) {
                            return Chip(
                              backgroundColor: surfaceColor,
                              side: BorderSide(color: ruleColor),
                              avatar: CircleAvatar(
                                backgroundColor: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
                                child: Text(
                                  f.initials,
                                  style: TextStyle(
                                    fontFamily: QuireTokens.fontMono,
                                    fontSize: 10,
                                    color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                                  ),
                                ),
                              ),
                              label: InkWell(
                                onTap: () => _openFriendProfile(f),
                                child: Text(
                                  f.name,
                                  style: TextStyle(
                                    fontFamily: QuireTokens.fontSerif,
                                    color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                                  ),
                                ),
                              ),
                              deleteIcon: const Icon(Icons.close, size: 14),
                              onDeleted: () async {
                                widget.onRemoveFriend?.call(f.id);
                                await widget.bffClient?.removeFriend(f.id);
                                setSheetState(() {});
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
        Text('BẠN', style: QuireTokens.eyebrow(isDark: isDark)),
        const SizedBox(height: 4),

        // Profile Card with Edit Action
        Container(
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(QuireTokens.rCard),
            border: Border.all(color: ruleColor),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
                backgroundImage: widget.currentUserAvatarBytes != null ? MemoryImage(widget.currentUserAvatarBytes!) : null,
                child: widget.currentUserAvatarBytes == null
                    ? Text(
                        widget.currentUserName.isNotEmpty ? widget.currentUserName[0].toUpperCase() : 'B',
                        style: TextStyle(
                          fontFamily: QuireTokens.fontMono,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.currentUserName, style: QuireTokens.h3(isDark: isDark)),
                    Text(widget.currentUsername, style: TextStyle(fontFamily: QuireTokens.fontMono, fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? QuireTokens.accentDark : QuireTokens.accentLight)),
                    const SizedBox(height: 2),
                    Text(widget.currentUserBio, style: QuireTokens.meta(isDark: isDark)),
                    const SizedBox(height: 4),
                    Text(
                      widget.currentUserEmail,
                      style: TextStyle(
                        fontFamily: QuireTokens.fontMono,
                        fontSize: 10,
                        color: isDark ? QuireTokens.accentDark : QuireTokens.accentInkLight,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: 'Chỉnh sửa hồ sơ',
                onPressed: _openEditProfileSheet,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Reading Activity Summary
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(QuireTokens.rCard),
            border: Border.all(color: ruleColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ĐÃ ĐỌC XONG THÁNG NÀY', style: QuireTokens.eyebrow(isDark: isDark)),
              const SizedBox(height: 6),
              Text(
                'Bốn bài đã đọc, đã dọn sạch.',
                style: QuireTokens.h3(isDark: isDark).copyWith(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Không có danh sách chờ tồn đọng.',
                style: QuireTokens.body(isDark: isDark),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4 Quick Cards with Cover Thumbs (from prototype.html)
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(QuireTokens.rCard),
            border: Border.all(color: ruleColor),
          ),
          child: Column(
            children: [
              _buildQuickRow('Đã lưu (Saved)', '9 bài viết & bộ sưu tập', 'https://picsum.photos/seed/saved_thumb/120/120', ruleColor, isDark, onTap: _openSavedSheet),
              Divider(height: 1, indent: 68, color: ruleColor),
              _buildQuickRow('Khoảnh khắc của bạn', '12 đã chia sẻ · 4 tuần này', 'https://picsum.photos/seed/shared_thumb/120/120', ruleColor, isDark, onTap: _openMyArchiveSheet),
              Divider(height: 1, indent: 68, color: ruleColor),
              _buildQuickRow('Lịch sử đọc', 'Bốn bài tháng này', 'https://picsum.photos/seed/history_thumb/120/120', ruleColor, isDark, onTap: _openHistorySheet),
              Divider(height: 1, indent: 68, color: ruleColor),
              _buildQuickRow('Mời bạn thân', 'Tạo link & Lời mời kết bạn', 'https://picsum.photos/seed/invite_thumb/120/120', ruleColor, isDark, onTap: _openInviteSheet),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Settings Section
        Text('CÀI ĐẶT', style: QuireTokens.eyebrow(isDark: isDark)),
        const SizedBox(height: 12),

        // Theme Switcher Tile
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(QuireTokens.rCard),
            border: Border.all(color: ruleColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, size: 20, color: QuireTokens.accentLight),
                      const SizedBox(width: 10),
                      Text('Giao diện & Theme', style: QuireTokens.h3(isDark: isDark).copyWith(fontSize: 16)),
                    ],
                  ),
                  Text(
                    isDark ? 'Tối (Than ấm)' : 'Sáng (Giấy ngà)',
                    style: QuireTokens.meta(isDark: isDark),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Nền tối giữ chất giấy: than ấm (#1A1612), không bao giờ đen tuyền.',
                style: QuireTokens.meta(isDark: isDark),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: !isDark ? QuireTokens.accentSoftLight : Colors.transparent,
                        side: BorderSide(color: !isDark ? QuireTokens.accentLight : ruleColor),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () => widget.themeController.setThemeMode(ThemeMode.light),
                      child: Text(
                        'Sáng',
                        style: TextStyle(
                          fontFamily: QuireTokens.fontSerif,
                          fontWeight: !isDark ? FontWeight.bold : FontWeight.normal,
                          color: !isDark ? QuireTokens.accentInkLight : (isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isDark ? QuireTokens.accentSoftDark : Colors.transparent,
                        side: BorderSide(color: isDark ? QuireTokens.accentLight : ruleColor),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () => widget.themeController.setThemeMode(ThemeMode.dark),
                      child: Text(
                        'Tối',
                        style: TextStyle(
                          fontFamily: QuireTokens.fontSerif,
                          fontWeight: isDark ? FontWeight.bold : FontWeight.normal,
                          color: isDark ? QuireTokens.accentDark : (isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Circle Management Tile
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(QuireTokens.rCard),
            side: BorderSide(color: ruleColor),
          ),
          tileColor: surfaceColor,
          leading: const Icon(Icons.people_outline, color: QuireTokens.accentLight),
          title: Text('Vòng thân thiết (${widget.friends.length} người)', style: QuireTokens.h3(isDark: isDark).copyWith(fontSize: 16)),
          subtitle: const Text('Thêm hoặc bớt bạn bè trong vòng', style: TextStyle(fontFamily: QuireTokens.fontMono, fontSize: 10)),
          trailing: const Icon(Icons.chevron_right, size: 20),
          onTap: _openCircleSheet,
        ),
        const SizedBox(height: 14),

        // Privacy Tile
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(QuireTokens.rCard),
            border: Border.all(color: ruleColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RIÊNG TƯ & BẢO MẬT', style: QuireTokens.eyebrow(isDark: isDark)),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeTrackColor: QuireTokens.accentLight,
                title: Text('Xác nhận đã xem (Read receipts)', style: QuireTokens.body(isDark: isDark)),
                subtitle: Text('Mặc định tắt. Đọc không thành nghĩa vụ trả lời.', style: QuireTokens.meta(isDark: isDark)),
                value: _readReceiptsEnabled,
                onChanged: (val) {
                  setState(() => _readReceiptsEnabled = val);
                },
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeTrackColor: QuireTokens.accentLight,
                title: Text('Tự huỷ khoảnh khắc', style: QuireTokens.body(isDark: isDark)),
                subtitle: Text(
                  _autoPurgeEnabled
                      ? 'Tự động dọn dẹp sau $_autoPurgeDuration từ khi đăng'
                      : 'Đang tắt: Giữ vĩnh viễn (Không tự huỷ)',
                  style: QuireTokens.meta(isDark: isDark),
                ),
                value: _autoPurgeEnabled,
                onChanged: (val) {
                  setState(() => _autoPurgeEnabled = val);
                },
              ),
              if (_autoPurgeEnabled) ...[
                const SizedBox(height: 8),
                Row(
                  children: ['24 giờ', '7 ngày', '30 ngày'].map((dur) {
                    final isSel = _autoPurgeDuration == dur;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(dur),
                        selected: isSel,
                        onSelected: (_) => setState(() => _autoPurgeDuration = dur),
                        selectedColor: isDark ? QuireTokens.accentSoftDark : QuireTokens.accentSoftLight,
                        labelStyle: TextStyle(
                          fontFamily: QuireTokens.fontMono,
                          fontSize: 10.5,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          color: isSel ? QuireTokens.accentInkLight : (isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                          side: BorderSide(color: isSel ? QuireTokens.accentLight : ruleColor),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Calm Philosophy Card
        Container(
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            color: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
            borderRadius: BorderRadius.circular(QuireTokens.rCard),
            border: Border.all(color: ruleColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('IM LẶNG LÀ MẶC ĐỊNH', style: QuireTokens.eyebrow(isDark: isDark)),
              const SizedBox(height: 8),
              Text(
                'Không đếm lượt theo dõi, không chuỗi ngày streak, không nhắc nhở quay lại. Đọc một bài, chia sẻ một tấm ảnh cho đúng người.',
                style: QuireTokens.body(isDark: isDark).copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),

        // Sign Out Button with high-contrast red terracotta styling
        if (widget.onSignOut != null) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? const Color(0xFFF07F77) : const Color(0xFFC13832),
                side: BorderSide(color: isDark ? const Color(0xFF592A17) : const Color(0xFFFFD2CA)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(QuireTokens.rBtn),
                ),
              ),
              onPressed: _showLogoutSecurityDialog,
              icon: Icon(Icons.logout_outlined, size: 18, color: isDark ? const Color(0xFFF07F77) : const Color(0xFFC13832)),
              label: Text(
                'Đăng xuất / Đổi tài khoản',
                style: TextStyle(
                  fontFamily: QuireTokens.fontSerif,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.5,
                  color: isDark ? const Color(0xFFF07F77) : const Color(0xFFC13832),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  void _openSavedSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final bgColor = isDark ? QuireTokens.paperDark : QuireTokens.paperLight;
        final ruleColor = isDark ? QuireTokens.ruleDark : QuireTokens.ruleLight;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              constraints: const BoxConstraints(maxHeight: 580),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('THƯ VIỆN LƯU TRỮ (POSTGRESQL)', style: QuireTokens.eyebrow(isDark: isDark)),
                      IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Bài viết đã lưu', style: QuireTokens.title(isDark: isDark)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<Map<String, dynamic>?>(
                      future: widget.bffClient?.getArticles(scope: 'saved'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                        }
                        final items = snapshot.data?['data'] as List<dynamic>? ?? [];
                        if (items.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.bookmark_border, size: 36, color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Chưa có bài viết nào được lưu.',
                                    style: QuireTokens.title(isDark: isDark).copyWith(fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Bấm vào biểu tượng bookmark ở góc bài viết để lưu vào thư viện đọc sau.',
                                    textAlign: TextAlign.center,
                                    style: QuireTokens.body(isDark: isDark),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) => Divider(color: ruleColor),
                          itemBuilder: (context, index) {
                            final art = items[index] as Map<String, dynamic>;
                            final id = art['id']?.toString() ?? '';
                            final title = art['title']?.toString() ?? 'Bài viết';
                            final author = art['author_name']?.toString() ?? 'Tác giả';
                            final tag = art['category']?.toString() ?? '#noithat';

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.bookmark, color: QuireTokens.accentLight),
                              title: Text(title, style: QuireTokens.h3(isDark: isDark).copyWith(fontSize: 15)),
                              subtitle: Text('$tag · $author', style: QuireTokens.meta(isDark: isDark)),
                              trailing: IconButton(
                                icon: const Icon(Icons.bookmark_remove_outlined, color: Color(0xFFC13832), size: 20),
                                tooltip: 'Bỏ lưu',
                                onPressed: () async {
                                  await widget.bffClient?.unbookmarkArticle(id);
                                  setSheetState(() {});
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openMyArchiveSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final bgColor = isDark ? QuireTokens.paperDark : QuireTokens.paperLight;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('KỶ NIỆM RIÊNG CỦA BẠN', style: QuireTokens.eyebrow(isDark: isDark)),
                  IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 4),
              Text('Khoảnh khắc lưu trữ', style: QuireTokens.title(isDark: isDark)),
              const SizedBox(height: 8),
              Text(
                'Những khoảnh khắc đã tự động ẩn khỏi bảng tin của bạn bè sau thời hạn tự huỷ. Dữ liệu kỷ niệm của bạn luôn được bảo toàn nguyên vẹn.',
                style: QuireTokens.body(isDark: isDark),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? QuireTokens.surfaceDark : QuireTokens.surfaceLight,
                  borderRadius: BorderRadius.circular(QuireTokens.rCard),
                  border: Border.all(color: ruleColor),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(QuireTokens.rPhoto),
                      child: Image.network('https://picsum.photos/seed/archived_1/120/120', width: 56, height: 56, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hoàng hôn bên bờ hồ', style: QuireTokens.h3(isDark: isDark).copyWith(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('Đã ẩn sau 30 ngày · Vẫn lưu an toàn', style: QuireTokens.meta(isDark: isDark)),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã khôi phục khoảnh khắc lên bảng tin thành công!')),
                            );
                          },
                          child: const Text('Khôi phục'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFC13832)),
                          tooltip: 'Xóa vĩnh viễn',
                          onPressed: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã xóa vĩnh viễn khoảnh khắc khỏi kho lưu trữ.')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _openHistorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final bgColor = isDark ? QuireTokens.paperDark : QuireTokens.paperLight;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('LỊCH SỬ ĐỌC BÀI', style: QuireTokens.eyebrow(isDark: isDark)),
                  IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 4),
              Text('Bốn bài đã đọc xong', style: QuireTokens.title(isDark: isDark)),
              const SizedBox(height: 8),
              Text('Không còn bài nào chờ. Bạn đã đọc trọn vẹn và tĩnh lặng trong tháng này.', style: QuireTokens.body(isDark: isDark)),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _openInviteSheet() {
    String inviteCode = 'QUIRE-${widget.currentUserName.replaceAll(' ', '').toUpperCase()}-8921';
    final List<Map<String, String>> receivedRequests = [
      {'id': 'req_1', 'name': 'Lan Hương', 'initials': 'LH', 'time': 'Hôm qua', 'bio': 'Đà Lạt · Bạn cùng lớp'},
      {'id': 'req_2', 'name': 'Đức Minh', 'initials': 'DM', 'time': '3 giờ trước', 'bio': 'Hà Nội · Thích nhiếp ảnh'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            final bgColor = isDark ? QuireTokens.paperDark : QuireTokens.paperLight;
            final surfaceColor = isDark ? QuireTokens.surfaceDark : QuireTokens.surfaceLight;
            final ruleColor = isDark ? QuireTokens.ruleDark : QuireTokens.ruleLight;
            final inviteUrl = 'https://quire.app/join/$inviteCode';

            return Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('KẾT NỐI BẠN BÈ', style: QuireTokens.eyebrow(isDark: isDark)),
                      IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Liên kết & Lời mời kết bạn', style: QuireTokens.title(isDark: isDark)),
                  const SizedBox(height: 6),
                  Text(
                    'Chia sẻ riêng tư trong vòng kết nối của bạn, không giới hạn số lượng thành viên.',
                    style: QuireTokens.body(isDark: isDark),
                  ),
                  const SizedBox(height: 20),

                  // Section 1: Personal Invite Link
                  Text('LIÊN KẾT KẾT BẠN CỦA BẠN', style: QuireTokens.eyebrow(isDark: isDark)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(QuireTokens.rField),
                      border: Border.all(color: ruleColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.link_rounded, size: 20, color: QuireTokens.accentLight),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                inviteUrl,
                                style: TextStyle(
                                  fontFamily: QuireTokens.fontMono,
                                  fontSize: 12,
                                  color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: QuireTokens.accentLight,
                                  foregroundColor: QuireTokens.onAccentLight,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(QuireTokens.rBtn)),
                                  elevation: 0,
                                ),
                                onPressed: () async {
                                  await Clipboard.setData(ClipboardData(text: inviteUrl));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Đã sao chép liên kết mời vào bộ nhớ tạm: $inviteUrl')),
                                  );
                                },
                                icon: const Icon(Icons.copy_rounded, size: 16),
                                label: const Text('Sao chép liên kết'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: ruleColor),
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(QuireTokens.rBtn)),
                              ),
                              onPressed: () {
                                setSheetState(() {
                                  inviteCode = 'QUIRE-${widget.currentUserName.replaceAll(' ', '').toUpperCase()}-${DateTime.now().millisecond}';
                                });
                              },
                              child: const Icon(Icons.refresh, size: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section 2: Received Friend Requests
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('LỜI MỜI ĐÃ NHẬN (${receivedRequests.length})', style: QuireTokens.eyebrow(isDark: isDark)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (receivedRequests.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('Không có lời mời kết bạn nào đang chờ.', style: QuireTokens.meta(isDark: isDark)),
                    )
                  else
                    ...receivedRequests.map((req) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(QuireTokens.rCard),
                          border: Border.all(color: ruleColor),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
                              child: Text(
                                req['initials']!,
                                style: TextStyle(fontFamily: QuireTokens.fontMono, fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(req['name']!, style: QuireTokens.h3(isDark: isDark).copyWith(fontSize: 14.5)),
                                  Text('${req['bio']} · ${req['time']}', style: QuireTokens.meta(isDark: isDark).copyWith(fontSize: 9.5)),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setSheetState(() {
                                  receivedRequests.removeWhere((r) => r['id'] == req['id']);
                                });
                              },
                              child: Text('Bỏ qua', style: QuireTokens.meta(isDark: isDark)),
                            ),
                            const SizedBox(width: 4),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: QuireTokens.accentLight,
                                foregroundColor: QuireTokens.onAccentLight,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(QuireTokens.rBtn)),
                                elevation: 0,
                              ),
                              onPressed: () {
                                final newChip = FriendChip(
                                  id: req['id']!,
                                  name: req['name']!,
                                  initials: req['initials']!,
                                );
                                widget.onAddFriend?.call(newChip);
                                setSheetState(() {
                                  receivedRequests.removeWhere((r) => r['id'] == req['id']);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Đã thêm ${req['name']} vào vòng bạn bè!')),
                                );
                              },
                              child: const Text('Đồng ý', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickRow(String title, String subtitle, String imageUrl, Color ruleColor, bool isDark, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(QuireTokens.rPhoto),
        child: Image.network(
          imageUrl,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 44,
            height: 44,
            color: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
            child: const Icon(Icons.bookmark_border, size: 20),
          ),
        ),
      ),
      title: Text(title, style: QuireTokens.h3(isDark: isDark).copyWith(fontSize: 15)),
      subtitle: Text(subtitle, style: QuireTokens.meta(isDark: isDark)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }
}
