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
                  style: TextStyle(fontFamily: QuireTokens.fontSerif, color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                  decoration: InputDecoration(
                    hintText: 'Kiến trúc, tản văn, du lịch...',
                    hintStyle: TextStyle(
                      fontFamily: QuireTokens.fontSerif,
                      color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light,
                    ),
                    border: InputBorder.none,
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

        // Curated List Cards
        ..._curatedList.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 14.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(QuireTokens.rCard),
              border: Border.all(color: ruleColor),
            ),
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
          );
        }).toList(),
      ],
    );
  }
}
