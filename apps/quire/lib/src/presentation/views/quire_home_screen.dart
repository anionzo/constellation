import 'package:flutter/material.dart';
import '../theme/quire_tokens.dart';
import '../widgets/quire_circle_avatar.dart';
import 'quire_compose_sheet.dart';
import '../../features/photo_upload/models/friend_chip.dart';
import '../../features/photo_upload/models/photo_upload_input.dart';
import '../../features/photo_upload/machine/photo_upload_state_machine.dart';
import '../../features/photo_upload/services/quire_moment_uploader.dart';

/// Quire Home Screen with 4 core tabs.
/// Native status bar handled automatically by SafeArea & SystemChrome.
class QuireHomeScreen extends StatefulWidget {
  final QuireMomentUploader momentUploader;

  const QuireHomeScreen({
    Key? key,
    required this.momentUploader,
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

  final List<Map<String, dynamic>> _moments = [
    {
      'id': 'm1',
      'authorName': 'Mai',
      'authorInitials': 'M',
      'timeAgo': '2 GIỜ TRƯỚC',
      'imageUrl': 'https://picsum.photos/seed/moment-1/720/900',
      'caption': 'Buổi chiều nắng nhẹ trên hiên nhà cũ.',
      'liked': false,
    }
  ];

  void _openComposeSheet() {
    final stateMachine = PhotoUploadStateMachine(
      uploader: widget.momentUploader,
      circleId: 'default-circle-id',
    );

    // Placeholder mock 1x1 png image bytes for compose
    final mockBytes = List<int>.filled(1024, 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuireComposeSheet(
        input: PhotoUploadInput(
          rawBytes: mockBytes,
          source: PhotoSource.camera,
        ),
        availableFriends: _friends,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuireTokens.paperLight,
      body: SafeArea(
        top: true,
        bottom: false,
        child: IndexedStack(
          index: _currentTabIndex,
          children: [
            _buildReadingView(),
            _buildMomentsView(),
            _buildDiscoverView(),
            _buildYouView(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomTabBar(),
    );
  }

  Widget _buildMomentsView() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
      children: [
        Text('QUIRE · KHOẢNH KHẮC', style: QuireTokens.eyebrow()),
        const SizedBox(height: 4),
        Text('Từ những người bạn quen', style: QuireTokens.title()),
        const SizedBox(height: 4),
        Text('Chỉ 11 người trong vòng thân thiết xem được.', style: QuireTokens.body()),
        const SizedBox(height: 16),
        // Circles Horizontal Row
        SizedBox(
          height: 86,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _friends.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: [
                    QuireCircleAvatar(
                      initials: '+',
                      isUserAddCircle: true,
                      onTap: _openComposeSheet,
                    ),
                    const SizedBox(height: 6),
                    Text('Của bạn', style: QuireTokens.meta()),
                  ],
                );
              }
              final friend = _friends[index - 1];
              return Column(
                children: [
                  QuireCircleAvatar(
                    initials: friend.initials,
                    hasUnreadStory: index == 1,
                    onTap: () {},
                  ),
                  const SizedBox(height: 6),
                  Text(friend.name, style: QuireTokens.meta()),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Moments Feed List
        ..._moments.map((moment) => _buildMomentCard(moment)).toList(),
      ],
    );
  }

  Widget _buildMomentCard(Map<String, dynamic> moment) {
    return Container(
      margin: const EdgeInsets.only(top: 18.0),
      decoration: BoxDecoration(
        color: QuireTokens.surfaceLight,
        borderRadius: BorderRadius.circular(QuireTokens.rCard),
        border: Border.all(color: QuireTokens.ruleLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                QuireCircleAvatar(
                  initials: moment['authorInitials'],
                  size: 36.0,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      moment['authorName'],
                      style: const TextStyle(
                        fontFamily: QuireTokens.fontMono,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: QuireTokens.inkLight,
                      ),
                    ),
                    Text(moment['timeAgo'], style: QuireTokens.eyebrow()),
                  ],
                ),
              ],
            ),
          ),
          // Moment 4:5 Photo
          AspectRatio(
            aspectRatio: 4 / 5,
            child: Image.network(
              moment['imageUrl'],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: QuireTokens.s2Light,
                alignment: Alignment.center,
                child: Text('Khoảnh khắc', style: QuireTokens.meta()),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(moment['caption'], style: QuireTokens.body(scale: 1.05)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: QuireTokens.ruleLight)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      moment['liked'] = !moment['liked'];
                    });
                  },
                  icon: Icon(
                    moment['liked'] ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: moment['liked'] ? QuireTokens.accentLight : QuireTokens.ink2Light,
                  ),
                  label: Text('Thả tim', style: QuireTokens.meta()),
                ),
                TextButton.icon(
                  onPressed: _openComposeSheet,
                  icon: const Icon(Icons.camera_alt_outlined, size: 16, color: QuireTokens.ink2Light),
                  label: Text('Đáp lại bằng ảnh', style: QuireTokens.meta()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingView() => Center(child: Text('Trang Đọc Biên Tập', style: QuireTokens.h3()));
  Widget _buildDiscoverView() => Center(child: Text('Trang Khám Phá', style: QuireTokens.h3()));
  Widget _buildYouView() => Center(child: Text('Trang Bạn & Cài Đặt', style: QuireTokens.h3()));

  Widget _buildBottomTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: QuireTokens.paperLight,
        border: Border(top: BorderSide(color: QuireTokens.ruleLight)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(index: 0, label: 'Đọc', icon: Icons.menu_book_outlined),
              _buildTabItem(index: 1, label: 'Khoảnh khắc', icon: Icons.panorama_fish_eye),
              _buildTabItem(index: 2, label: 'Khám phá', icon: Icons.explore_outlined),
              _buildTabItem(index: 3, label: 'Bạn', icon: Icons.person_outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({required int index, required String label, required IconData icon}) {
    final isActive = _currentTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentTabIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? QuireTokens.accentLight : QuireTokens.ink3Light,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: QuireTokens.fontMono,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: isActive ? QuireTokens.accentLight : QuireTokens.ink3Light,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
