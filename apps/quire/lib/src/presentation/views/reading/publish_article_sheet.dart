import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../theme/quire_tokens.dart';
import '../tabs/reading_tab_view.dart';
import '../../../features/photo_upload/services/native_camera_gallery_service.dart';

class PublishArticleSheet extends StatefulWidget {
  final void Function(ArticleItem newArticle) onArticlePublished;

  const PublishArticleSheet({
    Key? key,
    required this.onArticlePublished,
  }) : super(key: key);

  @override
  State<PublishArticleSheet> createState() => _PublishArticleSheetState();
}

class _PublishArticleSheetState extends State<PublishArticleSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _excerptController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String _selectedCategory = 'Tản văn';
  final List<String> _categories = ['Tản văn', 'Kiến trúc', 'Nội thất', 'Du lịch', 'Nghệ thuật', 'Triết học'];
  Uint8List? _coverBytes;
  bool _isPublic = true;
  String _errorMessage = '';

  @override
  void dispose() {
    _titleController.dispose();
    _excerptController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final photo = await NativeCameraGalleryService().pickFromGallery();
    if (photo != null) {
      setState(() {
        _coverBytes = photo.bytes;
      });
    }
  }

  void _publish() {
    final title = _titleController.text.trim();
    final excerpt = _excerptController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập tiêu đề bài viết.');
      return;
    }
    if (content.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập nội dung bài viết.');
      return;
    }

    // Estimate reading time (~200 words per minute)
    final wordCount = content.split(RegExp(r'\s+')).length;
    final minutes = (wordCount / 180).ceil().clamp(2, 25);

    final newArticle = ArticleItem(
      id: 'article_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      excerpt: excerpt.isNotEmpty ? excerpt : (content.length > 120 ? '${content.substring(0, 120)}...' : content),
      fullContent: content,
      author: 'Bạn',
      readTime: '$minutes phút đọc',
      date: 'Vừa xong',
      imageUrl: _coverBytes != null ? '' : 'https://picsum.photos/seed/article_${DateTime.now().millisecond}/800/500',
      coverBytes: _coverBytes,
      isPublic: _isPublic,
    );

    widget.onArticlePublished(newArticle);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? QuireTokens.paperDark : QuireTokens.paperLight;
    final surfaceColor = isDark ? QuireTokens.surfaceDark : QuireTokens.surfaceLight;
    final ruleColor = isDark ? QuireTokens.ruleDark : QuireTokens.ruleLight;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.94),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(QuireTokens.rSheet)),
        border: Border.all(color: ruleColor),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text('SOẠN BÀI VIẾT MỚI', style: QuireTokens.eyebrow(isDark: isDark)),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: QuireTokens.accentLight,
                    foregroundColor: QuireTokens.onAccentLight,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(QuireTokens.rBtn)),
                    elevation: 0,
                  ),
                  onPressed: _publish,
                  child: const Text('Xuất bản', style: TextStyle(fontFamily: QuireTokens.fontSerif, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: ruleColor),

          // Scrollable Editor Form
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              children: [
                if (_errorMessage.isNotEmpty) ...[
                  Text(
                    _errorMessage,
                    style: const TextStyle(fontFamily: QuireTokens.fontSerif, color: Color(0xFFC13832), fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                ],

                // Cover Image Picker
                InkWell(
                  onTap: _pickCoverImage,
                  borderRadius: BorderRadius.circular(QuireTokens.rPhoto),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(QuireTokens.rPhoto),
                      border: Border.all(color: ruleColor),
                    ),
                    child: _coverBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(QuireTokens.rPhoto),
                            child: Image.memory(_coverBytes!, fit: BoxFit.cover, width: double.infinity),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined, size: 36, color: QuireTokens.accentLight),
                              const SizedBox(height: 8),
                              Text('Chọn ảnh bìa bài viết', style: QuireTokens.meta(isDark: isDark)),
                              const SizedBox(height: 4),
                              Text('Khuyến nghị tỷ lệ 16:9 ngang', style: TextStyle(fontFamily: QuireTokens.fontMono, fontSize: 9.5, color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Category Chips Selector
                Text('CHỦ ĐỀ BÀI VIẾT', style: QuireTokens.eyebrow(isDark: isDark)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                      backgroundColor: surfaceColor,
                      selectedColor: isDark ? QuireTokens.accentSoftDark : QuireTokens.accentSoftLight,
                      labelStyle: TextStyle(
                        fontFamily: QuireTokens.fontMono,
                        fontSize: 11,
                        color: isSelected ? QuireTokens.accentInkLight : (isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                        side: BorderSide(color: isSelected ? QuireTokens.accentLight : ruleColor),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Audience Scope Selector (Public vs Close Friends)
                Text('PHẠM VI NGƯỜI ĐỌC', style: QuireTokens.eyebrow(isDark: isDark)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    ChoiceChip(
                      avatar: Icon(_isPublic ? Icons.public : Icons.public_outlined, size: 16),
                      label: const Text('Tất cả mọi người (Công khai)'),
                      selected: _isPublic,
                      onSelected: (_) => setState(() => _isPublic = true),
                      backgroundColor: surfaceColor,
                      selectedColor: isDark ? QuireTokens.accentSoftDark : QuireTokens.accentSoftLight,
                      labelStyle: TextStyle(
                        fontFamily: QuireTokens.fontMono,
                        fontSize: 11,
                        fontWeight: _isPublic ? FontWeight.bold : FontWeight.normal,
                        color: _isPublic ? QuireTokens.accentInkLight : (isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999), side: BorderSide(color: _isPublic ? QuireTokens.accentLight : ruleColor)),
                    ),
                    ChoiceChip(
                      avatar: Icon(!_isPublic ? Icons.people : Icons.people_outline, size: 16),
                      label: const Text('Chỉ vòng bạn bè (Riêng tư)'),
                      selected: !_isPublic,
                      onSelected: (_) => setState(() => _isPublic = false),
                      backgroundColor: surfaceColor,
                      selectedColor: isDark ? QuireTokens.accentSoftDark : QuireTokens.accentSoftLight,
                      labelStyle: TextStyle(
                        fontFamily: QuireTokens.fontMono,
                        fontSize: 11,
                        fontWeight: !_isPublic ? FontWeight.bold : FontWeight.normal,
                        color: !_isPublic ? QuireTokens.accentInkLight : (isDark ? QuireTokens.inkDark : QuireTokens.inkLight),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999), side: BorderSide(color: !_isPublic ? QuireTokens.accentLight : ruleColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _isPublic
                      ? '🌐 Tất cả mọi người (kể cả chưa kết bạn) đều có thể tìm và đọc bài viết này.'
                      : '🔒 Chỉ những người bạn trong vòng thân thiết của bạn mới đọc được.',
                  style: QuireTokens.meta(isDark: isDark).copyWith(fontSize: 10),
                ),
                const SizedBox(height: 20),
                // Title Input
                Text('TIÊU ĐỀ BÀI VIẾT', style: QuireTokens.eyebrow(isDark: isDark)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(QuireTokens.rField),
                    border: Border.all(color: ruleColor),
                  ),
                  child: TextField(
                    controller: _titleController,
                    style: QuireTokens.title(isDark: isDark).copyWith(fontSize: 20),
                    decoration: InputDecoration(
                      hintText: 'Nhập tiêu đề tạp chí...',
                      hintStyle: TextStyle(fontFamily: QuireTokens.fontSerif, color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Excerpt Input
                Text('TRÍCH DẪN NGẮN (TÙY CHỌN)', style: QuireTokens.eyebrow(isDark: isDark)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(QuireTokens.rField),
                    border: Border.all(color: ruleColor),
                  ),
                  child: TextField(
                    controller: _excerptController,
                    maxLines: 2,
                    style: QuireTokens.body(isDark: isDark),
                    decoration: InputDecoration(
                      hintText: 'Một câu tóm tắt cốt lõi bài viết...',
                      hintStyle: TextStyle(fontFamily: QuireTokens.fontSerif, color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Full Content Input
                Text('NỘI DUNG TOÀN VĂN', style: QuireTokens.eyebrow(isDark: isDark)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(QuireTokens.rField),
                    border: Border.all(color: ruleColor),
                  ),
                  child: TextField(
                    controller: _contentController,
                    maxLines: 12,
                    style: QuireTokens.body(isDark: isDark).copyWith(fontSize: 15, height: 1.6),
                    decoration: InputDecoration(
                      hintText: 'Kể lại câu chuyện, suy tưởng hoặc góc nhìn của bạn. Hỗ trợ xuống dòng thành từng đoạn văn...',
                      hintStyle: TextStyle(fontFamily: QuireTokens.fontSerif, color: isDark ? QuireTokens.ink3Dark : QuireTokens.ink3Light),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
