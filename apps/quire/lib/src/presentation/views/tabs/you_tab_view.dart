import 'package:flutter/material.dart';
import '../../theme/quire_tokens.dart';
import '../../theme/quire_theme.dart';
import '../../../features/photo_upload/models/friend_chip.dart';

class YouTabView extends StatefulWidget {
  final ThemeController themeController;
  final List<FriendChip> friends;
  final String currentUserEmail;
  final VoidCallback? onSignOut;

  const YouTabView({
    Key? key,
    required this.themeController,
    required this.friends,
    this.currentUserEmail = 'Khách trải nghiệm',
    this.onSignOut,
  }) : super(key: key);
  @override
  State<YouTabView> createState() => _YouTabViewState();
}

class _YouTabViewState extends State<YouTabView> {
  bool _readReceiptsEnabled = false; // Quiet invariant: Off by default

  void _openCircleSheet() {
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
                  Text('VÒNG THÂN THIẾT', style: QuireTokens.eyebrow(isDark: isDark)),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('11 người bạn quen', style: QuireTokens.title(isDark: isDark)),
              const SizedBox(height: 8),
              Text(
                'Khoảnh khắc chỉ được chia sẻ trong vòng tròn hữu hạn này. Không có chế độ công khai.',
                style: QuireTokens.body(isDark: isDark),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: widget.friends.map((f) {
                  return Chip(
                    backgroundColor: isDark ? QuireTokens.surfaceDark : QuireTokens.surfaceLight,
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
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
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

        // Profile Card
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
                child: Text(
                  'B',
                  style: TextStyle(
                    fontFamily: QuireTokens.fontMono,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.currentUserEmail, style: QuireTokens.h3(isDark: isDark)),
                  const SizedBox(height: 4),
                  Text(
                    widget.currentUserEmail == 'Khách trải nghiệm'
                        ? 'Chế độ khách · Chưa liên kết email'
                        : 'Đã xác thực · Lisbon',
                    style: QuireTokens.meta(isDark: isDark),
                  ),
                ],
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
                      Icon(isDark ? Icons.dark_mode : Icons.light_mode, size: 20, color: QuireTokens.accentLight),
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
          title: Text('Vòng thân thiết (11 người)', style: QuireTokens.h3(isDark: isDark).copyWith(fontSize: 16)),
          subtitle: Text('Quản lý ai xem được khoảnh khắc', style: QuireTokens.meta(isDark: isDark)),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tự huỷ khoảnh khắc', style: QuireTokens.body(isDark: isDark)),
                    Text('Sau 30 ngày', style: QuireTokens.meta(isDark: isDark)),
                  ],
                ),
              ),
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
        if (widget.onSignOut != null) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: ruleColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(QuireTokens.rBtn),
                ),
              ),
              onPressed: widget.onSignOut,
              icon: const Icon(Icons.logout_outlined, size: 18),
              label: Text(
                'Đăng xuất / Đổi tài khoản',
                style: QuireTokens.button(isDark: isDark),
              ),
            ),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}
