import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/quire_tokens.dart';
import '../theme/quire_theme.dart';
import 'quire_shell.dart';
import 'tabs/reading_tab_view.dart';
import 'tabs/moments_tab_view.dart';
import 'tabs/discover_tab_view.dart';
import 'tabs/you_tab_view.dart';
import '../../features/photo_upload/models/friend_chip.dart';
import '../../features/photo_upload/services/quire_moment_uploader.dart';
import '../../features/api/bff_api_client.dart';

/// Quire Home Screen with 4 fully implemented interactive tabs:
/// 1. Đọc (Editorial Reading Feed & Detail Sheet)
/// 2. Khoảnh khắc (Moments, Stories Viewer & 900ms Undo Compose)
/// 3. Khám phá (Search & Curated Editorial Shelf)
/// 4. Bạn (Profile & 4-tier Settings with Theme Switcher)
class QuireHomeScreen extends StatefulWidget {
  final BffApiClient? bffClient;
  final QuireMomentUploader momentUploader;
  final ThemeController? themeController;

  final String currentUserEmail;
  final VoidCallback? onSignOut;

  const QuireHomeScreen({
    Key? key,
    this.bffClient,
    required this.momentUploader,
    this.themeController,
    this.currentUserEmail = 'Khách trải nghiệm',
    this.onSignOut,
  }) : super(key: key);
  @override
  State<QuireHomeScreen> createState() => _QuireHomeScreenState();
}

class _QuireHomeScreenState extends State<QuireHomeScreen> {
  int _currentTabIndex = 0; // Default to Reading tab so users see the article compose banner immediately

  String _userName = 'Bạn';
  String _username = '@ban.quire';
  String _userBio = 'Thành viên từ tháng 3 · Lisbon';
  Uint8List? _userAvatarBytes;
  List<FriendChip> _friends = [];
  Timer? _notificationPoller;
  int _lastUnreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadFriendsFromBackend();
    _startNotificationPolling();
  }

  @override
  void dispose() {
    _notificationPoller?.cancel();
    super.dispose();
  }

  Future<void> _loadFriendsFromBackend() async {
    if (widget.bffClient == null) return;
    try {
      final list = await widget.bffClient!.getFriends();
      if (list.isNotEmpty && mounted) {
        setState(() {
          _friends = list.map((item) {
            final id = item['id']?.toString() ?? '';
            final name = item['name']?.toString() ?? 'Bạn';
            final initials = item['initials']?.toString() ?? (name.isNotEmpty ? name[0].toUpperCase() : 'B');
            return FriendChip(id: id, name: name, initials: initials);
          }).toList();
        });
      }
    } catch (_) {}
  }

  void _startNotificationPolling() {
    _notificationPoller = Timer.periodic(const Duration(seconds: 4), (_) async {
      if (!mounted || widget.bffClient == null) return;
      try {
        final unread = await widget.bffClient!.getUnreadMessageCount();
        if (unread > _lastUnreadCount && mounted) {
          _lastUnreadCount = unread;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Bạn có $unread tin nhắn mới trong hộp thư vòng bạn bè!',
                style: const TextStyle(fontFamily: QuireTokens.fontSerif),
              ),
              backgroundColor: QuireTokens.accentLight,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (_) {}
    });
  }

  void _onProfileUpdated(String name, String username, String bio, Uint8List? avatarBytes) {
    setState(() {
      if (name.isNotEmpty) _userName = name;
      if (username.isNotEmpty) _username = username;
      if (bio.isNotEmpty) _userBio = bio;
      _userAvatarBytes = avatarBytes;
    });
  }

  void _onAddFriend(FriendChip newFriend) {
    setState(() {
      _friends.add(newFriend);
    });
  }

  void _onRemoveFriend(String friendId) {
    setState(() {
      _friends.removeWhere((f) => f.id == friendId);
    });
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? QuireTokens.paperDark : QuireTokens.paperLight;
    final ruleColor = isDark ? QuireTokens.ruleDark : QuireTokens.ruleLight;

    return QuireShell(
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          top: true,
          bottom: false,
          child: IndexedStack(
            index: _currentTabIndex,
            children: [
              ReadingTabView(bffClient: widget.bffClient),
              MomentsTabView(
                bffClient: widget.bffClient,
                friends: _friends,
                momentUploader: widget.momentUploader,
              ),
              const DiscoverTabView(),
              YouTabView(
                bffClient: widget.bffClient,
                themeController: widget.themeController ?? ThemeController(),
                friends: _friends,
                currentUserEmail: widget.currentUserEmail,
                currentUserName: _userName,
                currentUsername: _username,
                currentUserBio: _userBio,
                currentUserAvatarBytes: _userAvatarBytes,
                onProfileUpdated: _onProfileUpdated,
                onAddFriend: _onAddFriend,
                onRemoveFriend: _onRemoveFriend,
                onSignOut: widget.onSignOut,
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomTabBar(isDark, bgColor, ruleColor),
      ),
    );
  }

  Widget _buildBottomTabBar(bool isDark, Color bgColor, Color ruleColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: ruleColor)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(index: 0, label: 'Đọc', icon: Icons.menu_book_outlined, isDark: isDark),
              _buildTabItem(index: 1, label: 'Khoảnh khắc', icon: Icons.panorama_fish_eye, isDark: isDark),
              _buildTabItem(index: 2, label: 'Khám phá', icon: Icons.explore_outlined, isDark: isDark),
              _buildTabItem(index: 3, label: 'Bạn', icon: Icons.person_outline, isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    final isActive = _currentTabIndex == index;
    final activeColor = isDark ? QuireTokens.accentDark : QuireTokens.accentLight;
    final inactiveColor = isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentTabIndex = index;
            });
          },
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? activeColor : inactiveColor,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: QuireTokens.fontMono,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
