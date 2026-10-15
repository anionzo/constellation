import 'package:flutter/material.dart';
import '../../theme/quire_tokens.dart';
import '../../../features/api/bff_api_client.dart';

class DiscoverTabView extends StatefulWidget {
  final BffApiClient? bffClient;

  const DiscoverTabView({
    Key? key,
    this.bffClient,
  }) : super(key: key);

  @override
  State<DiscoverTabView> createState() => _DiscoverTabViewState();
}

class _DiscoverTabViewState extends State<DiscoverTabView> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _topics = ['Tất cả', '#noithat', '#kientruc', '#vanhoa', '#thietke'];
  int _selectedTopicIndex = 0;
  String _searchQuery = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _articles = [];

  @override
  void initState() {
    super.initState();
    _loadTopicsAndArticles();
  }

  Future<void> _loadTopicsAndArticles() async {
    setState(() => _isLoading = true);
    if (widget.bffClient == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final topicsFuture = widget.bffClient!.getArticleTopics();
      final articlesFuture = widget.bffClient!.getArticles(scope: 'public');

      final results = await Future.wait([topicsFuture, articlesFuture]);
      final topics = results[0] as List<Map<String, dynamic>>;
      final articlesData = results[1] as Map<String, dynamic>?;

      if (mounted) {
        setState(() {
          if (topics.isNotEmpty) {
            _topics = [
              'Tất cả',
              ...topics.map((t) => t['display_tag']?.toString() ?? '').where((s) => s.isNotEmpty),
            ];
          }

          _articles.clear();
          if (articlesData != null && articlesData['data'] is List) {
            final list = articlesData['data'] as List<dynamic>;
            for (final item in list) {
              _articles.add(item as Map<String, dynamic>);
            }
          }
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredArticles {
    return _articles.where((art) {
      final title = art['title']?.toString().toLowerCase() ?? '';
      final excerpt = art['excerpt']?.toString().toLowerCase() ?? '';
      final author = art['author_name']?.toString().toLowerCase() ?? '';
      final category = art['category']?.toString().toLowerCase() ?? '';

      // Topic filter
      if (_selectedTopicIndex > 0 && _selectedTopicIndex < _topics.length) {
        final selectedTag = _topics[_selectedTopicIndex].toLowerCase();
        final tagWithoutHash = selectedTag.replaceAll('#', '');
        if (!category.contains(tagWithoutHash)) {
          return false;
        }
      }

      // Search query filter
      if (_searchQuery.isNotEmpty) {
        return title.contains(_searchQuery) ||
            excerpt.contains(_searchQuery) ||
            author.contains(_searchQuery) ||
            category.contains(_searchQuery);
      }

      return true;
    }).toList();
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
                    hintText: 'Tìm theo tiêu đề, hashtag #noithat, tác giả...',
                    hintStyle: TextStyle(
                      fontFamily: QuireTokens.fontSerif,
                      color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light,
                      fontSize: 13.5,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Dynamic Hashtags Horizontal Selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _topics.asMap().entries.map((entry) {
              final idx = entry.key;
              final topic = entry.value;
              final isSelected = _selectedTopicIndex == idx;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(topic),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedTopicIndex = idx),
                  backgroundColor: surfaceColor,
                  selectedColor: isDark ? QuireTokens.accentDark : QuireTokens.accentLight,
                  labelStyle: TextStyle(
                    fontFamily: QuireTokens.fontMono,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : (isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                    side: BorderSide(color: isSelected ? Colors.transparent : ruleColor),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        Text('BÀI VIẾT TUYỂN CHỌN (POSTGRESQL)', style: QuireTokens.eyebrow(isDark: isDark)),
        const SizedBox(height: 12),

        // Curated List Rendering
        if (_isLoading) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ] else if (_filteredArticles.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 40, color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light),
                  const SizedBox(height: 12),
                  Text(
                    'Không tìm thấy bài viết nào phù hợp.',
                    style: QuireTokens.title(isDark: isDark).copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Thử tìm với từ khóa hoặc hashtag khác trên kệ sách.',
                    style: QuireTokens.body(isDark: isDark),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          ..._filteredArticles.map((art) {
            final title = art['title']?.toString() ?? 'Bài viết';
            final category = art['category']?.toString() ?? '#noithat';
            final author = art['author_name']?.toString() ?? 'Tác giả';
            final readTime = '${art['read_time_minutes'] ?? 5} phút';
            final coverUrl = (art['cover_image_path'] != null && art['cover_image_path'].toString().isNotEmpty)
                ? art['cover_image_path'].toString()
                : 'https://picsum.photos/seed/${art['id']}/600/400';

            return Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(QuireTokens.rCard),
                border: Border.all(color: ruleColor),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(QuireTokens.rCard),
                onTap: () => _openArticleDetail(context, art),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(QuireTokens.rPhoto),
                        child: Image.network(
                          coverUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
                            child: const Icon(Icons.menu_book, size: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.toUpperCase(),
                              style: TextStyle(
                                fontFamily: QuireTokens.fontMono,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: QuireTokens.accentLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: QuireTokens.h3(isDark: isDark).copyWith(fontSize: 14.5),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$author · $readTime',
                              style: QuireTokens.meta(isDark: isDark).copyWith(fontSize: 9.5),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 12, color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  void _openArticleDetail(BuildContext context, Map<String, dynamic> art) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final bgColor = isDark ? QuireTokens.paperDark : QuireTokens.paperLight;
        final ruleColor = isDark ? QuireTokens.ruleDark : QuireTokens.ruleLight;

        final title = art['title']?.toString() ?? 'Bài viết';
        final author = art['author_name']?.toString() ?? 'Tác giả';
        final content = art['full_content']?.toString() ?? (art['excerpt']?.toString() ?? '');
        final tag = art['category']?.toString() ?? '#noithat';
        final readTime = '${art['read_time_minutes'] ?? 5} phút đọc';

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
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tag.toUpperCase(), style: TextStyle(fontFamily: QuireTokens.fontMono, color: QuireTokens.accentLight, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(title, style: QuireTokens.title(isDark: isDark).copyWith(fontSize: 22)),
                  const SizedBox(height: 6),
                  Text('$author · $readTime', style: QuireTokens.meta(isDark: isDark)),
                  const Divider(height: 32),
                  Text(
                    content,
                    style: QuireTokens.body(isDark: isDark).copyWith(height: 1.8, fontSize: 16),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
