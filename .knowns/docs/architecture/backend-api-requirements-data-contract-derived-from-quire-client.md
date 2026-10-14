---
id: doc-c7681defdbceda03bc7b25cc2d298cdc
title: 'Backend API Requirements & Data Contract (Derived from Quire Client)'
description: 'Backend API Requirements and Data Contract derived from Quire Client features: Auth, Circle, Soft-Purge Moments, Articles visibility, and Chat'
createdAt: '2026-10-14T09:04:26.466Z'
updatedAt: '2026-10-14T09:04:26.466Z'
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
