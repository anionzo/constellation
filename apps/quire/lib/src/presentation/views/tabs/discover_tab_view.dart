import 'package:flutter/material.dart';
import '../../theme/quire_tokens.dart';

class DiscoverTabView extends StatefulWidget {
  const DiscoverTabView({Key? key}) : super(key: key);

  @override
  State<DiscoverTabView> createState() => _DiscoverTabViewState();
}

class _DiscoverTabViewState extends State<DiscoverTabView> {
  final List<String> _topics = ['Tất cả', 'Kiến trúc', 'Nội thất', 'Du lịch', 'Tản văn'];
  int _selectedTopicIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _curatedList = [
    {
      'title': 'Bóng râm trong kiến trúc nhiệt đới',
      'category': 'Kiến trúc',
      'author': 'Nguyễn Văn An',
      'readTime': '6 phút',
      'imageUrl': 'https://picsum.photos/seed/shade/600/400',
    },
    {
      'title': 'Gỗ mun và đất nung: Sự mộc mạc của đồ thủ công',
      'category': 'Nội thất',
      'author': 'Claire Dubois',
      'readTime': '4 phút',
      'imageUrl': 'https://picsum.photos/seed/wood/600/400',
    },
    {
      'title': 'Một mình qua những thị trấn sương mù vùng Alentejo',
      'category': 'Du lịch',
      'author': 'Tiago Silva',
      'readTime': '9 phút',
      'imageUrl': 'https://picsum.photos/seed/fog/600/400',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? QuireTokens.surfaceDark : QuireTokens.surfaceLight;
    final ruleColor = isDark ? QuireTokens.ruleDark : QuireTokens.ruleLight;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
      children: [
        Text('KHÁM PHÁ', style: QuireTokens.eyebrow(isDark: isDark)),
        const SizedBox(height: 4),
        Text('Kệ sách biên tập', style: QuireTokens.title(isDark: isDark)),
        const SizedBox(height: 16),

        // Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(QuireTokens.rField),
            border: Border.all(color: ruleColor),
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 20, color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  style: TextStyle(fontFamily: QuireTokens.fontSerif, color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                  decoration: InputDecoration(
                    hintText: 'Kiến trúc, tản văn, du lịch...',
                    hintStyle: TextStyle(
                      fontFamily: QuireTokens.fontSerif,
                      color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light,
                    ),
                    border: InputBorder.none,
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Topics Filter Chips
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _topics.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isSelected = _selectedTopicIndex == index;
              return ChoiceChip(
                label: Text(_topics[index]),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedTopicIndex = index),
                backgroundColor: surfaceColor,
                selectedColor: isDark ? QuireTokens.accentSoftDark : QuireTokens.accentSoftLight,
                labelStyle: TextStyle(
                  fontFamily: QuireTokens.fontMono,
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? (isDark ? QuireTokens.accentDark : QuireTokens.accentInkLight)
                      : (isDark ? QuireTokens.ink2Dark : QuireTokens.ink2Light),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: BorderSide(color: isSelected ? QuireTokens.accentLight : ruleColor),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        Text('ĐỌC NHIỀU NHẤT TUẦN', style: QuireTokens.eyebrow(isDark: isDark)),
        const SizedBox(height: 12),

        // Filtered Curated List Cards
        ..._buildFilteredList(surfaceColor, ruleColor, isDark),
      ],
    );
  }

  List<Widget> _buildFilteredList(Color surfaceColor, Color ruleColor, bool isDark) {
    final selectedTopic = _topics[_selectedTopicIndex];
    final filtered = _curatedList.where((item) {
      final matchesTopic = selectedTopic == 'Tất cả' || item['category'] == selectedTopic;
      final matchesQuery = _searchQuery.isEmpty ||
          item['title']!.toLowerCase().contains(_searchQuery) ||
          item['author']!.toLowerCase().contains(_searchQuery) ||
          item['category']!.toLowerCase().contains(_searchQuery);
      return matchesTopic && matchesQuery;
    }).toList();

    if (filtered.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 36.0),
          child: Center(
            child: Text(
              'Không tìm thấy bài viết phù hợp.',
              style: QuireTokens.meta(isDark: isDark),
            ),
          ),
        ),
      ];
    }

    return filtered.map((item) {
      return Container(
        margin: const EdgeInsets.only(bottom: 14.0),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(QuireTokens.rCard),
          border: Border.all(color: ruleColor),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(QuireTokens.rCard),
          onTap: () => _openArticleDetail(context, item),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(QuireTokens.rPhoto),
              child: Image.network(
                item['imageUrl']!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
                  child: const Icon(Icons.menu_book),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item['category']} · ${item['readTime']}'.toUpperCase(),
                    style: QuireTokens.meta(isDark: isDark).copyWith(fontSize: 9),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['title']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: QuireTokens.h3(isDark: isDark).copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['author']!,
                    style: QuireTokens.meta(isDark: isDark).copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
            ),
          ),
        ),
      );
    }).toList();
  }

  void _openArticleDetail(BuildContext context, Map<String, String> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final bgColor = isDark ? QuireTokens.paperDark : QuireTokens.paperLight;
        final ruleColor = isDark ? QuireTokens.ruleDark : QuireTokens.ruleLight;

        return DraggableScrollableSheet(
          initialChildSize: 0.94,
          minChildSize: 0.5,
          maxChildSize: 0.98,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(QuireTokens.rSheet)),
                border: Border.all(color: ruleColor),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(icon: const Icon(Icons.arrow_back, size: 20), onPressed: () => Navigator.pop(ctx)),
                        Text(item['readTime']!.toUpperCase(), style: QuireTokens.meta(isDark: isDark)),
                        IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: ruleColor),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                      children: [
                        Text(item['title']!, style: QuireTokens.title(isDark: isDark).copyWith(fontSize: 26, height: 1.25)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(item['author']!, style: QuireTokens.meta(isDark: isDark)),
                            Text(' · ', style: TextStyle(color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light)),
                            Text(item['category']!, style: QuireTokens.meta(isDark: isDark)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(QuireTokens.rPhoto),
                          child: Image.network(item['imageUrl']!, height: 220, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '''Không gian yên tĩnh mở ra giữa những thanh âm của ngày mới. Từng chi tiết trong bài viết này được chọn lọc để bạn thưởng thức với tốc độ của riêng mình, không bị giục giã hay phân tâm.

Khi đọc chậm lại, ta nhận ra rằng những điều giá trị nhất thường ẩn mình trong những góc khuất giản dị nhất của cuộc sống.''',
                          style: QuireTokens.body(isDark: isDark).copyWith(fontSize: 16, height: 1.7),
                        ),
                        const SizedBox(height: 48),
                      ],
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
}
