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

/// Quire Home Screen with 4 fully implemented interactive tabs:
/// 1. Đọc (Editorial Reading Feed & Detail Sheet)
/// 2. Khoảnh khắc (Moments, Stories Viewer & 900ms Undo Compose)
/// 3. Khám phá (Search & Curated Editorial Shelf)
/// 4. Bạn (Profile & 4-tier Settings with Theme Switcher)
class QuireHomeScreen extends StatefulWidget {
  final QuireMomentUploader momentUploader;
  final ThemeController? themeController;

  final String currentUserEmail;
  final VoidCallback? onSignOut;

  const QuireHomeScreen({
    Key? key,
    required this.momentUploader,
    this.themeController,
    this.currentUserEmail = 'Khách trải nghiệm',
    this.onSignOut,
  }) : super(key: key);
  @override
  State<QuireHomeScreen> createState() => _QuireHomeScreenState();
}

class _QuireHomeScreenState extends State<QuireHomeScreen> {
  int _currentTabIndex = 1; // Default to Moments tab

  // 11 Close Friends Circle Mock (Finite Circle Invariant)
  final List<FriendChip> _friends = const [
    FriendChip(id: 'f1', name: 'Mai', initials: 'M'),
    FriendChip(id: 'f2', name: 'Tuấn', initials: 'T'),
    FriendChip(id: 'f3', name: 'Linh', initials: 'L'),
    FriendChip(id: 'f4', name: 'An', initials: 'A'),
    FriendChip(id: 'f5', name: 'Hà', initials: 'H'),
    FriendChip(id: 'f6', name: 'Khoa', initials: 'K'),
    FriendChip(id: 'f7', name: 'Trang', initials: 'TR'),
    FriendChip(id: 'f8', name: 'Duy', initials: 'D'),
    FriendChip(id: 'f9', name: 'Bảo', initials: 'B'),
    FriendChip(id: 'f10', name: 'Việt', initials: 'V'),
    FriendChip(id: 'f11', name: 'Quỳnh', initials: 'Q'),
  ];


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
              const ReadingTabView(),
              MomentsTabView(
                friends: _friends,
                momentUploader: widget.momentUploader,
              ),
              const DiscoverTabView(),
              YouTabView(
                themeController: widget.themeController ?? ThemeController(),
                friends: _friends,
                currentUserEmail: widget.currentUserEmail,
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
