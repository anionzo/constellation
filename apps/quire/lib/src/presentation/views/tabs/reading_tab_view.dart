import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../theme/quire_tokens.dart';
import '../reading/publish_article_sheet.dart';
import '../../../features/api/bff_api_client.dart';

class ArticleItem {
  final String id;
  final String title;
  final String excerpt;
  final String fullContent;
  final String author;
  final String readTime;
  final String date;
  final String imageUrl;
  final Uint8List? coverBytes;
  bool isBookmarked;
  int likes;
  bool isLiked;
  final bool isPublic;

  ArticleItem({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.fullContent,
    required this.author,
    required this.readTime,
    required this.date,
    required this.imageUrl,
    this.coverBytes,
    this.isBookmarked = false,
    this.likes = 12,
    this.isLiked = false,
    this.isPublic = true,
  });
}

class ReadingTabView extends StatefulWidget {
  final BffApiClient? bffClient;
  const ReadingTabView({Key? key, this.bffClient}) : super(key: key);

  @override
  State<ReadingTabView> createState() => _ReadingTabViewState();
}

class _ReadingTabViewState extends State<ReadingTabView> {
  int _filterIndex = 0; // 0: Tất cả, 1: Công khai, 2: Vòng bạn bè, 3: Đã lưu
  @override
  void initState() {
    super.initState();
    _loadArticlesFromBackend();
  }

  bool _isLoading = true;
  final List<ArticleItem> _articles = [];

  Future<void> _loadArticlesFromBackend() async {
    setState(() => _isLoading = true);
    if (widget.bffClient == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    String? scope;
    if (_filterIndex == 1) scope = 'public';
    if (_filterIndex == 2) scope = 'circle';
    if (_filterIndex == 3) scope = 'saved';

    try {
      final res = await widget.bffClient!.getArticles(scope: scope);
      if (res != null && res['data'] is List) {
        final List<dynamic> list = res['data'] as List<dynamic>;
        if (mounted) {
          setState(() {
            _articles.clear();
            for (final item in list) {
              final m = item as Map<String, dynamic>;
              _articles.add(ArticleItem(
                id: m['id']?.toString() ?? '',
                title: m['title']?.toString() ?? '',
                excerpt: m['excerpt']?.toString() ?? '',
                fullContent: m['full_content']?.toString() ?? '',
                author: m['author_name']?.toString() ?? 'Tác giả',
                readTime: '${m['read_time_minutes'] ?? 5} phút đọc',
                date: 'Hôm nay',
                imageUrl: (m['cover_image_path'] != null && m['cover_image_path'].toString().isNotEmpty)
                    ? m['cover_image_path'].toString()
                    : 'https://picsum.photos/seed/${m['id']}/800/500',
                likes: (m['likes_count'] as num?)?.toInt() ?? 0,
                isPublic: m['is_public'] == true,
                isBookmarked: m['is_bookmarked'] == true,
              ));
            }
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openPublishSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PublishArticleSheet(
        onArticlePublished: (newArticle) {
          widget.bffClient?.publishArticle(
            title: newArticle.title,
            category: 'Ghi chép',
            excerpt: newArticle.excerpt,
            fullContent: newArticle.fullContent,
            isPublic: newArticle.isPublic,
            coverImagePath: newArticle.imageUrl,
          ).then((_) => _loadArticlesFromBackend());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Bài viết đã được xuất bản lên Quire!', style: TextStyle(fontFamily: QuireTokens.fontSerif)),
              backgroundColor: QuireTokens.accentLight,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
          );
        },
      ),
    );
  }

  void _openArticleDetail(ArticleItem article) {
    double fontSize = 16.0;

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
                      // Grabber & Top Navigation
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, size: 20),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                            // Font Size Adjuster (14px - 16px - 19px)
                            Row(
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(minimumSize: const Size(32, 32), padding: EdgeInsets.zero),
                                  onPressed: () => setSheetState(() => fontSize = 14.0),
                                  child: Text('A', style: TextStyle(fontSize: 13, fontWeight: fontSize == 14.0 ? FontWeight.bold : FontWeight.normal, color: fontSize == 14.0 ? QuireTokens.accentLight : (isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light))),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(minimumSize: const Size(32, 32), padding: EdgeInsets.zero),
                                  onPressed: () => setSheetState(() => fontSize = 16.0),
                                  child: Text('A', style: TextStyle(fontSize: 16, fontWeight: fontSize == 16.0 ? FontWeight.bold : FontWeight.normal, color: fontSize == 16.0 ? QuireTokens.accentLight : (isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light))),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(minimumSize: const Size(32, 32), padding: EdgeInsets.zero),
                                  onPressed: () => setSheetState(() => fontSize = 19.0),
                                  child: Text('A', style: TextStyle(fontSize: 19, fontWeight: fontSize == 19.0 ? FontWeight.bold : FontWeight.normal, color: fontSize == 19.0 ? QuireTokens.accentLight : (isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light))),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                color: article.isBookmarked ? QuireTokens.accentLight : (isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                              ),
                              onPressed: () {
                                setState(() {
                                  article.isBookmarked = !article.isBookmarked;
                                });
                                setSheetState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: ruleColor),

                      // Article Content Body
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                          children: [
                            Text(
                              article.title,
                              style: QuireTokens.title(isDark: isDark).copyWith(fontSize: 26, height: 1.25),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(article.author, style: QuireTokens.meta(isDark: isDark)),
                                Text(' · ', style: TextStyle(color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light)),
                                Text(article.date, style: QuireTokens.meta(isDark: isDark)),
                                Text(' · ', style: TextStyle(color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light)),
                                Text(article.readTime, style: QuireTokens.meta(isDark: isDark)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(QuireTokens.rPhoto),
                              child: article.coverBytes != null
                                  ? Image.memory(article.coverBytes!, height: 220, width: double.infinity, fit: BoxFit.cover)
                                  : Image.network(
                                      article.imageUrl,
                                      height: 220,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 220,
                                        color: surfaceColor,
                                        child: const Icon(Icons.image, size: 48),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              article.fullContent,
                              style: QuireTokens.body(isDark: isDark).copyWith(
                                fontSize: fontSize,
                                height: 1.7,
                                color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                              ),
                            ),
                            const SizedBox(height: 36),

                            // In-Article 4 Action Buttons
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    setSheetState(() {
                                      article.isLiked = !article.isLiked;
                                      article.likes = article.isLiked ? article.likes + 1 : article.likes - 1;
                                    });
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    article.isLiked ? Icons.favorite : Icons.favorite_border,
                                    size: 18,
                                    color: article.isLiked ? const Color(0xFFC13832) : (isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                                  ),
                                  label: Text('${article.likes} tim', style: QuireTokens.meta(isDark: isDark)),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      article.isBookmarked = !article.isBookmarked;
                                    });
                                    setSheetState(() {});
                                  },
                                  icon: Icon(
                                    article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                    size: 18,
                                    color: article.isBookmarked ? QuireTokens.accentLight : (isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                                  ),
                                  label: Text(article.isBookmarked ? 'Đã lưu' : 'Lưu', style: QuireTokens.meta(isDark: isDark)),
                                ),
                              ],
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
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('HÔM NAY Ở QUIRE', style: QuireTokens.eyebrow(isDark: isDark)),
            Text('Thứ Ba 14/09', style: QuireTokens.meta(isDark: isDark)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_articles.length} bài viết', style: QuireTokens.title(isDark: isDark)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? QuireTokens.accentDark : QuireTokens.accentLight,
                foregroundColor: isDark ? QuireTokens.onAccentDark : QuireTokens.onAccentLight,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(QuireTokens.rBtn)),
                elevation: 0,
              ),
              onPressed: _openPublishSheet,
              icon: const Icon(Icons.edit_note_rounded, size: 18),
              label: const Text('Viết bài', style: TextStyle(fontFamily: QuireTokens.fontSerif, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Prominent Article Creation Banner
        InkWell(
          onTap: _openPublishSheet,
          borderRadius: BorderRadius.circular(QuireTokens.rCard),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: isDark ? QuireTokens.accentSoftDark : QuireTokens.accentSoftLight,
              borderRadius: BorderRadius.circular(QuireTokens.rCard),
              border: Border.all(color: isDark ? QuireTokens.accentDark : QuireTokens.accentLight, width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: QuireTokens.accentLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_note_rounded, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SOẠN BÀI VIẾT MỚI', style: TextStyle(fontFamily: QuireTokens.fontMono, fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? QuireTokens.accentDark : QuireTokens.accentInkLight)),
                      const SizedBox(height: 2),
                      Text('Chia sẻ câu chuyện & góc nhìn của bạn', style: QuireTokens.h3(isDark: isDark).copyWith(fontSize: 14.5)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? QuireTokens.accentDark : QuireTokens.accentInkLight),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Filter Chips (All / Public / Circle / Saved)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Tất cả'),
                selected: _filterIndex == 0,
                onSelected: (_) { setState(() => _filterIndex = 0); _loadArticlesFromBackend(); },
                selectedColor: isDark ? QuireTokens.accentSoftDark : QuireTokens.accentSoftLight,
                labelStyle: TextStyle(
                  fontFamily: QuireTokens.fontMono,
                  fontSize: 11,
                  fontWeight: _filterIndex == 0 ? FontWeight.bold : FontWeight.normal,
                  color: _filterIndex == 0 ? QuireTokens.accentInkLight : (isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999), side: BorderSide(color: ruleColor)),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                avatar: Icon(_filterIndex == 1 ? Icons.public : Icons.public_outlined, size: 14),
                label: const Text('Công khai'),
                selected: _filterIndex == 1,
                onSelected: (_) { setState(() => _filterIndex = 1); _loadArticlesFromBackend(); },
                selectedColor: isDark ? QuireTokens.accentSoftDark : QuireTokens.accentSoftLight,
                labelStyle: TextStyle(
                  fontFamily: QuireTokens.fontMono,
                  fontSize: 11,
                  fontWeight: _filterIndex == 1 ? FontWeight.bold : FontWeight.normal,
                  color: _filterIndex == 1 ? QuireTokens.accentInkLight : (isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999), side: BorderSide(color: ruleColor)),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                avatar: Icon(_filterIndex == 2 ? Icons.people : Icons.people_outline, size: 14),
                label: const Text('Vòng bạn bè'),
                selected: _filterIndex == 2,
                onSelected: (_) { setState(() => _filterIndex = 2); _loadArticlesFromBackend(); },
                selectedColor: isDark ? QuireTokens.accentSoftDark : QuireTokens.accentSoftLight,
                labelStyle: TextStyle(
                  fontFamily: QuireTokens.fontMono,
                  fontSize: 11,
                  fontWeight: _filterIndex == 2 ? FontWeight.bold : FontWeight.normal,
                  color: _filterIndex == 2 ? QuireTokens.accentInkLight : (isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999), side: BorderSide(color: ruleColor)),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text('Đã lưu (${_articles.where((a) => a.isBookmarked).length})'),
                selected: _filterIndex == 3,
                onSelected: (_) { setState(() => _filterIndex = 3); _loadArticlesFromBackend(); },
                selectedColor: isDark ? QuireTokens.accentSoftDark : QuireTokens.accentSoftLight,
                labelStyle: TextStyle(
                  fontFamily: QuireTokens.fontMono,
                  fontSize: 11,
                  fontWeight: _filterIndex == 3 ? FontWeight.bold : FontWeight.normal,
                  color: _filterIndex == 3 ? QuireTokens.accentInkLight : (isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999), side: BorderSide(color: ruleColor)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Live Database Articles Feed
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
        ] else if (_articles.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.menu_book_outlined, size: 36, color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light),
                  const SizedBox(height: 12),
                  Text(
                    'Chưa có bài viết nào trong mục này.',
                    style: QuireTokens.title(isDark: isDark).copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Hãy bấm "Viết bài" ở trên để chia sẻ câu chuyện đầu tiên lên CSDL!',
                    textAlign: TextAlign.center,
                    style: QuireTokens.body(isDark: isDark),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          for (final article in _articles)
            Container(
            margin: const EdgeInsets.only(bottom: 20.0),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(QuireTokens.rCard),
              border: Border.all(color: ruleColor),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(QuireTokens.rCard),
              onTap: () => _openArticleDetail(article),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(QuireTokens.rCard)),
                    child: article.coverBytes != null
                        ? Image.memory(article.coverBytes!, height: 180, width: double.infinity, fit: BoxFit.cover)
                        : Image.network(
                            article.imageUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 180,
                              color: isDark ? QuireTokens.s2Dark : QuireTokens.s2Light,
                              alignment: Alignment.center,
                              child: const Icon(Icons.menu_book, size: 36),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          style: QuireTokens.h3(isDark: isDark),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          article.excerpt,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: QuireTokens.body(isDark: isDark).copyWith(
                            color: isDark ? QuireTokens.ink2Dark : QuireTokens.ink2Light,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${article.author} · ${article.readTime}'.toUpperCase(),
                              style: QuireTokens.meta(isDark: isDark),
                            ),
                            Row(
                              children: [
                                Text('${article.likes} tim', style: QuireTokens.meta(isDark: isDark)),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: Icon(
                                    article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                    size: 18,
                                    color: article.isBookmarked
                                        ? QuireTokens.accentLight
                                        : (isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      article.isBookmarked = !article.isBookmarked;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
