---
id: uw0sv7
title: 'Quyết định Backend & Storage: Supabase Self-Hosted (Docker), Chuẩn Upload Avatar & Cơ chế Version Gating'
layer: project
category: decision
tags:
  - architecture
  - backend
  - supabase
  - docker
  - storage
  - avatar
  - version-gating
  - decision
createdAt: '2026-09-24T16:22:04.752Z'
updatedAt: '2026-09-24T16:22:04.752Z'
---

Quyết định kiến trúc chính thức ngày 2026-09-24:
1. Backend & Sync Platform: Chọn Supabase Self-Hosted triển khai qua Docker trên VPS cá nhân (kết hợp Caddy/Nginx và Cloudflare CDN).
2. Chuẩn lưu trữ Avatar (Supabase Storage):
   - Bucket: `avatars` (public read).
   - Cấu trúc đường dẫn bắt buộc: `avatars/{user_id}/avatar_{timestamp}.webp` để chống kẹt cache CDN và browser.
   - Tiền xử lý tại client Flutter: crop vuông 1:1, resize tối đa 400x400px, nén WebP chất lượng 80-85% (dung lượng <100KB) trước khi gửi.
   - Bảo mật RLS: Storage Objects chỉ cho phép chính chủ `auth.uid()` ghi/xóa trong folder `{user_id}`.
3. Cơ chế Ép Cập Nhật Phiên Bản (Version Gating & Anti-Stale Cache):
   - Bảng `app_system_configs` trên Supabase lưu `min_supported_version` (SemVer).
   - Client Flutter kiểm tra lúc khởi động và khi resume từ background; nếu nhỏ hơn `min_supported_version`, app hiển thị màn hình khóa cứng (Force Update Screen) ngắt sync để tránh lệch schema.
   - Web/PWA: cấu hình Cache-Control `no-cache, no-store, must-revalidate` cho `index.html` và lắng nghe ServiceWorker `controllerchange` để tự động nhắc reload.
