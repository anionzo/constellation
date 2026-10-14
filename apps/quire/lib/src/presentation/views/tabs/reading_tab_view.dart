import 'package:flutter/material.dart';
import '../../theme/quire_tokens.dart';

class ArticleItem {
  final String id;
  final String title;
  final String excerpt;
  final String fullContent;
  final String author;
  final String readTime;
  final String date;
  final String imageUrl;
  bool isBookmarked;

  ArticleItem({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.fullContent,
    required this.author,
    required this.readTime,
    required this.date,
    required this.imageUrl,
    this.isBookmarked = false,
  });
}

class ReadingTabView extends StatefulWidget {
  const ReadingTabView({Key? key}) : super(key: key);

  @override
  State<ReadingTabView> createState() => _ReadingTabViewState();
}

class _ReadingTabViewState extends State<ReadingTabView> {
  final List<ArticleItem> _articles = [
    ArticleItem(
      id: 'art_1',
      title: 'Nghệ thuật của gạch men azulejo ở Lisbon',
      excerpt: 'Mặt tiền azulejo không đơn thuần là trang trí. Đó là tấm lưới giải quyết vi khí hậu và kể lại ký ức đô thị qua hàng thế kỷ.',
      fullContent: '''Mặt tiền azulejo không đơn thuần là trang trí. Đó là tấm lưới giải quyết vi khí hậu và kể lại ký ức đô thị qua hàng thế kỷ.

Khi tản bộ qua những con dốc lát đá hoa cương ở Alfama hay Chiado, bạn sẽ nhận ra ánh nắng phản chiếu dịu nhẹ trên lớp men gốm xanh lam và vàng đất. Lớp gốm này đóng vai trò như một màng ngăn nhiệt tự nhiên: giữ cho các bức tường đá mát rượi vào buổi trưa hè oi ả và phản xạ bớt gió ẩm từ cửa sông Tagus thổi vào mùa đông.

Nhưng điều kỳ diệu hơn cả là sự yên tĩnh mà chúng mang lại cho cảnh quan thị giác. Thay vì những tấm biển quảng cáo rực rỡ hay màu sơn công nghiệp chói gắt, từng phiến gạch men thủ công mang vết rạn tinh tế của thời gian. Mỗi viên gạch vẽ bằng tay là một nhịp thở chậm, nhắc nhở chúng ta về vẻ đẹp của những điều được tạo tác để tồn tại lâu hơn một đời người.''',
      author: 'Inês Castro',
      readTime: '7 phút đọc',
      date: 'Thứ Ba 14/09',
      imageUrl: 'https://picsum.photos/seed/lisbon/800/500',
    ),
    ArticleItem(
      id: 'art_2',
      title: 'Những thư viện im lặng ở cố đô Kyoto',
      excerpt: 'Giữa lòng cố đô náo nhiệt, có những căn phòng gỗ tối nơi người ta đến chỉ để nghe tiếng lật giấy và tiếng gió lùa qua rèm trúc.',
      fullContent: '''Giữa lòng cố đô náo nhiệt, có những căn phòng gỗ tối nơi người ta đến chỉ để nghe tiếng lật giấy và tiếng gió lùa qua rèm trúc.

Không có tiếng chuông điện thoại, không có tiếng gõ bàn phím gấp gáp. Ánh sáng tự nhiên lọc qua những nan trượt shoji bằng giấy washi mỏng manh, làm dịu đi mọi góc cạnh sắc nhọn của thế giới hiện đại.

Đọc sách ở đây không phải là một cuộc đua về số trang, mà là một cuộc hội ngộ với chính khoảng lặng bên trong mình.''',
      author: 'Kenji Sato',
      readTime: '5 phút đọc',
      date: 'Hôm qua',
      imageUrl: 'https://picsum.photos/seed/kyoto/800/500',
    ),
    ArticleItem(
      id: 'art_3',
      title: 'Ánh sáng buổi sớm trong hội hoạ Bắc Âu',
      excerpt: 'Tại sao những bức tranh của Hammershøi luôn khiến ta cảm thấy sự tĩnh mịch bao trùm như một chiếc áo ấm mùa đông?',
      fullContent: '''Tại sao những bức tranh của Hammershøi luôn khiến ta cảm thấy sự tĩnh mịch bao trùm như một chiếc áo ấm mùa đông?

Vilhelm Hammershøi vẽ những căn phòng vắng ở Copenhagen với gam màu xám tro, nâu đất và ánh sáng mờ ảo len qua khung cửa sổ cao. Không có kịch tính, không có chuyển động dữ dội. Chỉ có một người phụ nữ quay lưng, hoặc một cánh cửa khép hờ.

Đó là thứ nghệ thuật không tìm cách chiếm đoạt sự chú ý của bạn, mà kiên nhẫn chờ đợi bạn bước vào không gian của nó.''',
      author: 'Astrid Lind',
      readTime: '8 phút đọc',
      date: '10 tháng 9',
      imageUrl: 'https://picsum.photos/seed/nordic/800/500',
    ),
  ];

  void _openArticleDetail(ArticleItem article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final bgColor = isDark ? QuireTokens.paperDark : QuireTokens.paperLight;
        final surfaceColor = isDark ? QuireTokens.surfaceDark : QuireTokens.surfaceLight;
        final ruleColor = isDark ? QuireTokens.ruleDark : QuireTokens.ruleLight;

        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.96,
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
                        Text(article.readTime.toUpperCase(), style: QuireTokens.meta(isDark: isDark)),
                        IconButton(
                          icon: Icon(
                            article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: article.isBookmarked ? QuireTokens.accentLight : (isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                          ),
                          onPressed: () {
                            setState(() {
                              article.isBookmarked = !article.isBookmarked;
                            });
                            Navigator.pop(ctx);
                            _openArticleDetail(article);
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
                          ],
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(QuireTokens.rPhoto),
                          child: Image.network(
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
                            fontSize: 16.0,
                            height: 1.7,
                            color: isDark ? QuireTokens.inkDark : QuireTokens.inkLight,
                          ),
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
        const SizedBox(height: 4),
        Text('5 bài mới hôm nay', style: QuireTokens.title(isDark: isDark)),
        const SizedBox(height: 16),

        // Articles Feed
        ..._articles.map((article) {
          return Container(
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
                    child: Image.network(
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
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
