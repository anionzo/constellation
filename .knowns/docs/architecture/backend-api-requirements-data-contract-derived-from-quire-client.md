---
id: doc-c7681defdbceda03bc7b25cc2d298cdc
title: 'Backend API Requirements & Data Contract (Derived from Quire Client)'
description: 'Backend API Requirements and Data Contract derived from Quire Client features: Auth, Circle, Soft-Purge Moments, Articles visibility, and Chat'
createdAt: '2026-10-14T09:04:26.466Z'
updatedAt: '2026-10-14T09:21:41.311Z'
tags:
  - backend
  - api
  - contract
  - quire
  - golang
---

# Backend API Requirements & Data Contract (Derived from Quire Client)

> **Trạng thái:** CANONICAL SPECIFICATION — Đặc tả chuẩn mực về nghiệp vụ, mô hình dữ liệu và các API endpoints phục vụ cho việc xây dựng tầng Backend Golang BFF và CSDL Supabase.
> **Nguồn gốc:** Trích xuất từ các yêu cầu nghiệp vụ và hành vi thực tế của Quire Client (Frontend First).

---

## 1. Các Quy Tắc Nghiệp Vụ Cốt Lõi (Core Domain Rules)

1. **Phạm vi người đọc bài viết hai tầng (Two-Tier Article Visibility)**:
   - `is_public = true` (Công khai): Mọi người dùng trên toàn hệ thống (kể cả chưa kết bạn) đều có thể tìm kiếm, khám phá và đọc bài viết.
   - `is_public = false` (Chỉ vòng bạn bè): Bài viết chỉ xuất hiện và cho phép những người nằm trong vòng kết nối của tác giả truy cập.
2. **Vòng bạn bè không giới hạn trần cứng (Unconstrained Friends Circle)**:
   - Loại bỏ hoàn toàn giới hạn 11/12 người. Cho phép người dùng mở rộng vòng kết nối linh hoạt.
   - Hỗ trợ tạo liên kết mời cá nhân (`invite_url` / `invite_code`) với khả năng sao chép và tạo lại mã mới.
   - Hỗ trợ duyệt danh sách lời mời kết bạn đã nhận (`received_requests`) với hai hành động: Chấp nhận (`accept`) hoặc Bỏ qua (`decline`).
3. **Cơ chế Tự huỷ = Ẩn mềm (Soft-Expire / Archive) & Khôi phục (Zero-Loss Memory)**:
   - Khoảnh khắc sau thời hạn tự hủy (24h, 7 ngày, 30 ngày) sẽ **rút lui khỏi bảng tin của bạn bè** (`is_active = false`), nhưng **tuyệt đối không bị xóa khỏi CSDL**.
   - Dữ liệu được bảo toàn trong Kho lưu trữ kỷ niệm cá nhân của tác giả (`moments/archive`).
   - Tác giả có quyền bấm **Khôi phục (`restore`)** để đưa lại lên bảng tin bạn bè, hoặc chủ động **Xóa vĩnh viễn (`hard_delete`)**.
4. **Nguyên tắc hai chiều: Lưu được thì Xóa được (Bidirectional Saving & Deletion)**:
   - Mọi thực thể được lưu vào thư viện (bài viết, khoảnh khắc, bookmarks) bắt buộc phải có API xóa / gỡ lưu (`DELETE /api/v1/saved/:id`).
5. **Định danh `@username` duy nhất & Hồ sơ bạn bè**:
   - Mỗi người dùng sở hữu một `@username` duy nhất phục vụ định danh và tìm kiếm.
   - Cung cấp API xem hồ sơ cơ bản của bạn bè: Tên, `@username`, bio, nơi chốn, số khoảnh khắc chung, và trạng thái kết nối.
6. **Nhắn tin phản hồi gắn ngữ cảnh ảnh (Contextual Quoted Moments)**:
   - Hỗ trợ tin nhắn đính kèm trích dẫn khoảnh khắc (`quoted_moment_id` / thumbnail preview) để cuộc trò chuyện luôn rõ ngữ cảnh.

---

## 2. Mô Hình Dữ Liệu CSDL Yêu Cầu (Schema Requirements)

### 2.1. Bảng `profiles`
- `id` (UUID, PK, references `auth.users`)
- `email` (TEXT, unique, not null)
- `username` (VARCHAR(32), unique, not null, format: `^[a-z0-9._]+$`)
- `display_name` (VARCHAR(64), not null)
- `bio` (TEXT)
- `city` (VARCHAR(64))
- `avatar_path` (TEXT)
- `created_at` (TIMESTAMPTZ, default now())
- `updated_at` (TIMESTAMPTZ, default now())

### 2.2. Bảng `circle_members`
- `id` (UUID, PK)
- `user_id` (UUID, FK -> profiles.id)
- `friend_id` (UUID, FK -> profiles.id)
- `status` (VARCHAR(16), 'active' | 'blocked')
- `created_at` (TIMESTAMPTZ, default now())
- `UNIQUE(user_id, friend_id)`

### 2.3. Bảng `circle_invites` & `circle_requests`
- `id` (UUID, PK)
- `sender_id` (UUID, FK -> profiles.id)
- `recipient_id` (UUID, FK -> profiles.id, nullable cho public invite link)
- `invite_code` (VARCHAR(32), unique, not null)
- `status` (VARCHAR(16), 'pending' | 'accepted' | 'declined' | 'expired')
- `created_at` (TIMESTAMPTZ, default now())
- `expires_at` (TIMESTAMPTZ)

### 2.4. Bảng `articles`
- `id` (UUID, PK)
- `author_id` (UUID, FK -> profiles.id)
- `title` (VARCHAR(255), not null)
- `excerpt` (TEXT)
- `full_content` (TEXT, not null)
- `category` (VARCHAR(32), not null)
- `cover_image_path` (TEXT)
- `read_time_minutes` (INT, default 5)
- `is_public` (BOOLEAN, default true) — *Ranh giới công khai vs bạn bè*
- `likes_count` (INT, default 0)
- `created_at` (TIMESTAMPTZ, default now())

### 2.5. Bảng `moments`
- `id` (UUID, PK)
- `sender_id` (UUID, FK -> profiles.id)
- `circle_id` (UUID)
- `image_path` (TEXT, not null)
- `caption` (TEXT)
- `auto_purge_duration_seconds` (INT, nullable — null nghĩa là không tự hủy)
- `purged_at` (TIMESTAMPTZ, nullable — cờ ẩn khỏi feed bạn bè)
- `is_archived` (BOOLEAN, default false)
- `likes_count` (INT, default 0)
- `created_at` (TIMESTAMPTZ, default now())

### 2.6. Bảng `saved_items` (Bookmarks)
- `id` (UUID, PK)
- `user_id` (UUID, FK -> profiles.id)
- `target_type` (VARCHAR(16), 'article' | 'moment')
- `target_id` (UUID, not null)
- `created_at` (TIMESTAMPTZ, default now())
- `UNIQUE(user_id, target_type, target_id)`

### 2.7. Bảng `chat_messages`
- `id` (UUID, PK)
- `sender_id` (UUID, FK -> profiles.id)
- `recipient_id` (UUID, FK -> profiles.id)
- `message_text` (TEXT, not null)
- `image_path` (TEXT, nullable)
- `quoted_moment_id` (UUID, nullable, FK -> moments.id) — *Trích dẫn ảnh*
- `sent_at` (TIMESTAMPTZ, default now())
- `read_at` (TIMESTAMPTZ, nullable)

---

## 3. Đặc Tả Các API Endpoints (Dành cho Golang BFF)

### 3.1. Xác thực & Hồ sơ cá nhân (Auth & Profile)
- `POST /api/v1/auth/otp/send`: Gửi mã OTP đăng nhập qua Email.
- `POST /api/v1/auth/otp/verify`: Xác minh OTP, trả về JWT access token.
- `GET /api/v1/profile/me`: Lấy thông tin hồ sơ của chính mình.
- `PUT /api/v1/profile/me`: Cập nhật tên, `@username`, bio, thành phố, avatar.
- `GET /api/v1/profile/:username`: Lấy hồ sơ cơ bản của bạn bè bằng `@username`.

### 3.2. Vòng bạn bè & Lời mời (Circle & Invites)
- `GET /api/v1/circle/friends`: Lấy danh sách bạn bè trong vòng.
- `DELETE /api/v1/circle/friends/:friendId`: Gỡ bạn khỏi vòng.
- `POST /api/v1/circle/invites/generate`: Tạo hoặc sinh lại mã mời kết bạn cá nhân.
- `GET /api/v1/circle/requests/received`: Lấy danh sách lời mời kết bạn đã nhận.
- `POST /api/v1/circle/requests/:requestId/accept`: Chấp nhận kết bạn.
- `POST /api/v1/circle/requests/:requestId/decline`: Bỏ qua lời mời.

### 3.3. Bài viết tạp chí (Articles)
- `GET /api/v1/articles`: Lấy danh sách bài viết (hỗ trợ filter `scope=public|circle|saved` và `topic`).
- `GET /api/v1/articles/:id`: Đọc toàn văn bài viết.
- `POST /api/v1/articles`: Xuất bản bài viết mới (kèm cờ `is_public`).
- `POST /api/v1/articles/:id/like`: Thả tim bài viết.
- `POST /api/v1/articles/:id/bookmark`: Lưu bài viết vào thư viện.
- `DELETE /api/v1/articles/:id/bookmark`: Bỏ lưu bài viết (Lưu được thì xóa được).

### 3.4. Khoảnh khắc & Tự hủy mềm (Moments & Soft-Purge)
- `GET /api/v1/moments/feed`: Lấy bảng tin khoảnh khắc còn hiệu lực trong vòng.
- `POST /api/v1/moments`: Đăng khoảnh khắc mới (kèm cấu hình thời hạn tự hủy).
- `POST /api/v1/moments/:id/like`: Thả tim khoảnh khắc.
- `GET /api/v1/moments/archive`: Lấy kho lưu trữ kỷ niệm riêng của tác giả (các khoảnh khắc đã tự hủy khỏi feed).
- `POST /api/v1/moments/:id/restore`: Khôi phục khoảnh khắc lên bảng tin bạn bè.
- `DELETE /api/v1/moments/:id`: Xóa vĩnh viễn khoảnh khắc khỏi kho lưu trữ.

### 3.5. Nhắn tin riêng tư (Chat Messages)
- `GET /api/v1/chat/inbox`: Lấy danh sách cuộc trò chuyện với các bạn bè.
- `GET /api/v1/chat/:friendId/messages`: Lấy lịch sử tin nhắn 1-1.
- `POST /api/v1/chat/:friendId/messages`: Gửi tin nhắn mới (hỗ trợ `quoted_moment_id` và đính kèm ảnh).

---

## 4. Chuẩn Mực Phân Trang Dùng Chung Đa Ứng Dụng (Cross-App Cursor Pagination & Infinite Scroll Standard)

> **Mục đích:** Đây là chuẩn kiến trúc phân trang bắt buộc dùng chung cho toàn bộ các ứng dụng trong hệ sinh thái Constellation (**Quire, Dream Journal, Astraea, After Midnight**) ở cả tầng Backend (Golang BFF / SQL) và Client (Flutter), ngăn chặn hoàn toàn việc tải ồ ạt toàn bộ dữ liệu cùng lúc.

### 4.1. Lựa Chọn Công Nghệ: Cursor-based Pagination (Thay vì Offset-based)

1. **Kháng hoàn toàn lỗi nhảy/trùng dữ liệu (Anti-Duplication)**:
   - Khi phân trang bằng số trang truyền thống (`page=1, page=2`), nếu có bạn bè vừa đăng một khoảnh khắc mới lên đầu bảng tin, toàn bộ dữ liệu bị dịch chuyển xuống 1 nấc. Khi người dùng cuộn xuống trang 2, họ sẽ bị xem lại một bài viết đã xem ở trang 1.
   - **Cursor-based** sử dụng con trỏ thời gian cố định của bản ghi cuối cùng (`(created_at, id)`). Dù có bao nhiêu bài mới chèn vào đầu trang, trang tiếp theo vẫn luôn lấy chính xác từ điểm dừng trước đó.
2. **Tối ưu hóa hiệu năng CSDL O(log N)**:
   - Khi dữ liệu lên đến hàng trăm ngàn bài viết, lệnh `OFFSET 50000` của SQL sẽ buộc PostgreSQL phải duyệt qua 50,000 dòng rồi mới trả về kết quả (gây chậm chạp và tốn CPU).
   - Cursor Pagination dùng mệnh đề `WHERE (created_at, id) < ($cursor_time, $cursor_id)` kết hợp với Composite Index `(created_at DESC, id DESC)`, cho phép PostgreSQL nhảy thẳng đến bản ghi cần lấy với độ phức tạp **O(log N)**.

### 4.2. Cấu Trúc Tham Số Yêu Cầu (Query Parameters)

Mọi API danh sách hỗ trợ cuộn tải thêm đều tuân theo chuẩn query:

```http
GET /api/v1/{resource}?limit=20&cursor=eyJ0IjoiMjAyNi0xMC0xNFQxNTozMDowMFoiLCJpZCI6ImFiYyJ9&direction=next
```

- `limit` (int, tùy chọn): Số lượng bản ghi mỗi trang. Mặc định: `20`. Tối đa cho phép: `50`.
- `cursor` (string, tùy chọn): Chuỗi mã hóa Base64 không để lộ cấu trúc nội bộ (opaque string). Trang đầu tiên truyền `null` hoặc bỏ trống.
- `direction` (string, tùy chọn): `next` (mặc định — cuộn xuống lấy dữ liệu cũ hơn) hoặc `prev` (lấy dữ liệu mới hơn khi ở giữa danh sách).

### 4.3. Cấu Trúc Phong Bì Phản Hồi Chuẩn (Universal Paginated Envelope)

Mọi response phân trang trên toàn bộ các app Constellation bắt buộc phải bọc trong Envelope chuẩn:

```json
{
  "data": [
    {
      "id": "mom_8921",
      "title": "...",
      "created_at": "2026-10-14T15:30:00Z"
    }
  ],
  "pagination": {
    "has_more": true,
    "next_cursor": "eyJ0IjoiMjAyNi0xMC0xNFQxNTozMDowMFoiLCJpZCI6Im1vbV84OTIxIn0=",
    "prev_cursor": null,
    "limit": 20,
    "total_count": 142
  }
}
```

- `has_more` (boolean): Báo hiệu cho Client biết còn dữ liệu phía sau hay không. Nếu `false`, Client dừng lắng nghe sự kiện cuộn xuống đáy.
- `next_cursor` (string | null): Con trỏ để truyền vào request kế tiếp. Nếu `has_more == false`, trả về `null`.
- `total_count` (int, tùy chọn): Tổng số bản ghi (chỉ trả về khi cần hiển thị trên giao diện như số bài đã lưu).

### 4.4. Yêu Cầu Chỉ Mục CSDL PostgreSQL (Database Indexing Blueprint)

Trong file migration SQL tiếp theo, toàn bộ các bảng danh sách phải được tạo Composite Index hai cột theo thứ tự giảm dần:

```sql
-- Index tối ưu cho Feed khoảnh khắc & Tự hủy
CREATE INDEX idx_moments_cursor ON public.moments (circle_id, is_archived, created_at DESC, id DESC);

-- Index tối ưu cho Danh sách bài viết tạp chí
CREATE INDEX idx_articles_cursor ON public.articles (is_public, created_at DESC, id DESC);

-- Index tối ưu cho Lịch sử chat 1-1
CREATE INDEX idx_chat_messages_cursor ON public.chat_messages (sender_id, recipient_id, sent_at DESC, id DESC);

-- Index tối ưu cho Danh sách đã lưu (Bookmarks)
CREATE INDEX idx_saved_items_cursor ON public.saved_items (user_id, created_at DESC, id DESC);
```

### 4.5. Mẫu Hình Triển Khai Phía Client Flutter (Infinite Scroll Pattern)

Phía Client (Flutter) áp dụng mẫu hình chuẩn tự động kích hoạt tải thêm khi người dùng cuộn gần tới đáy:

```dart
class PagingScrollManager {
  final ScrollController scrollController;
  final Future<void> Function() onLoadMore;
  final double thresholdPixels;

  bool _isLoadingMore = false;
  bool _hasMore = true;

  PagingScrollManager({
    required this.scrollController,
    required this.onLoadMore,
    this.thresholdPixels = 200.0,
  }) {
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isLoadingMore || !_hasMore) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;

    // Kích hoạt tải thêm khi còn cách đáy danh sách 200px
    if (maxScroll - currentScroll <= thresholdPixels) {
      _executeLoadMore();
    }
  }

  Future<void> _executeLoadMore() async {
    _isLoadingMore = true;
    try {
      await onLoadMore();
    } finally {
      _isLoadingMore = false;
    }
  }

  void updateHasMore(bool hasMore) => _hasMore = hasMore;
  void dispose() => scrollController.removeListener(_onScroll);
}
```

- **Trải nghiệm Calm tĩnh lặng**:
  - Không hiện pop-up phiền toái.
  - Ở đáy danh sách khi `isLoadingMore == true`: chỉ hiển thị một vạch xoay nhẹ nhàng `SizedBox(height: 24, child: CircularProgressIndicator(strokeWidth: 2))`.
  - Khi `hasMore == false`: hiển thị dòng kết thúc tĩnh lặng: *"Đã đọc hết nội dung gần đây · Không còn mục cũ hơn."*
  - Kéo từ trên xuống (Pull-to-refresh) bằng `RefreshIndicator` để làm mới danh sách và đưa cursor về đầu trang.

### 4.6. Bảng Ma Trận Tái Sử Dụng Trên Cả 4 Ứng Dụng Constellation

| Ứng dụng | Danh mục áp dụng phân trang Lazy Load | Khóa con trỏ (Cursor Key) | Hạn mức trang (Page Limit) |
|---|---|---|---|
| **Quire** | Bảng tin Khoảnh khắc, Danh sách bài viết Đọc, Kệ sách Khám phá, Hộp thư Chat, Danh sách Đã lưu | `(created_at, id)` | 15–20 mục |
| **Dream Journal** | Dòng thời gian Giấc mơ (Dream Timeline), Danh sách tệp đính kèm âm thanh/hình ảnh | `(recorded_date, id)` | 10–15 giấc mơ |
| **Astraea** | Lịch sử trải bài Tarot (Tarot Reading Logs), Danh sách câu hỏi chiêm nghiệm | `(spread_date, id)` | 12 phiên trải bài |
| **After Midnight** | Khoảng không tản văn đêm (00:00–05:00), Kho lưu trữ thư niêm phong | `(midnight_timestamp, id)` | 10 tản văn |
