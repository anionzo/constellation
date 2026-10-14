import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../theme/quire_tokens.dart';
import '../../theme/quire_theme.dart';
import '../../../features/photo_upload/models/friend_chip.dart';
import '../../../features/photo_upload/services/native_camera_gallery_service.dart';

class YouTabView extends StatefulWidget {
  final ThemeController themeController;
  final List<FriendChip> friends;
  final String currentUserEmail;
  final String currentUserName;
  final String currentUserBio;
  final Uint8List? currentUserAvatarBytes;
  final void Function(String name, String bio, Uint8List? avatarBytes)? onProfileUpdated;
  final void Function(FriendChip newFriend)? onAddFriend;
  final void Function(String friendId)? onRemoveFriend;
  final VoidCallback? onSignOut;

  const YouTabView({
    Key? key,
    required this.themeController,
    required this.friends,
    this.currentUserEmail = 'Khách trải nghiệm',
    this.currentUserName = 'Bạn',
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
  final TextEditingController _addFriendController = TextEditingController();

  @override
  void dispose() {
    _addFriendController.dispose();
    super.dispose();
  }

  void _openEditProfileSheet() {
    final nameController = TextEditingController(text: widget.currentUserName);
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
                        onPressed: () {
                          widget.onProfileUpdated?.call(
                            nameController.text.trim(),
                            bioController.text.trim(),
                            selectedAvatar,
                          );
                          Navigator.pop(ctx);
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
                          onPressed: () {
                            final name = _addFriendController.text.trim();
                            if (name.isNotEmpty) {
                              final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
                              final newChip = FriendChip(
                                id: 'f_${DateTime.now().millisecondsSinceEpoch}',
                                name: name,
                                initials: initials.isNotEmpty ? initials : name[0].toUpperCase(),
                              );
                              widget.onAddFriend?.call(newChip);
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
                              label: Text(
                                f.name,
                                style: TextStyle(
                                  fontFamily: QuireTokens.fontSerif,
                                  color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                                ),
                              ),
                              deleteIcon: const Icon(Icons.close, size: 14),
                              onDeleted: () {
                                widget.onRemoveFriend?.call(f.id);
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
              _buildQuickRow('Đã lưu (Saved)', '9 bài viết & bộ sưu tập', 'https://picsum.photos/seed/saved_thumb/120/120', ruleColor, isDark),
              Divider(height: 1, indent: 68, color: ruleColor),
              _buildQuickRow('Khoảnh khắc của bạn', '12 đã chia sẻ · 4 tuần này', 'https://picsum.photos/seed/shared_thumb/120/120', ruleColor, isDark),
              Divider(height: 1, indent: 68, color: ruleColor),
              _buildQuickRow('Lịch sử đọc', 'Bốn bài tháng này', 'https://picsum.photos/seed/history_thumb/120/120', ruleColor, isDark),
              Divider(height: 1, indent: 68, color: ruleColor),
              _buildQuickRow('Mời bạn thân', 'Còn ba lời mời kết nối', 'https://picsum.photos/seed/invite_thumb/120/120', ruleColor, isDark),
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
              onPressed: widget.onSignOut,
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

  Widget _buildQuickRow(String title, String subtitle, String imageUrl, Color ruleColor, bool isDark) {
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
      onTap: () {},
    );
  }
}
