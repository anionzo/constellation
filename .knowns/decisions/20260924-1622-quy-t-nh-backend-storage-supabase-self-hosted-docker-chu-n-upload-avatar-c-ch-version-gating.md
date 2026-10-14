---
id: 20260924-1622-quy-t-nh-backend-storage-supabase-self-hosted-docker-chu-n-upload-avatar-c-ch-version-gating
title: 'Quyết định Backend & Storage: Supabase Self-Hosted (Docker), Chuẩn Upload Avatar & Cơ chế Version Gating'
status: draft
supersedes: []
supersededBy: []
tags:
  - legacy-memory-migration
sources:
  - '@memory/uw0sv7'
relatedDocs: []
relatedTasks: []
verification: []
createdAt: '2026-09-24T16:22:04.752Z'
updatedAt: '2026-09-29T10:45:55.009Z'
---

## Context

Migrated through reviewed provenance from legacy Decision Memory @memory/uw0sv7 (layer project, prior status active).

## Decision

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

## Alternatives Considered

The legacy Memory record did not encode alternatives in the System Decision lifecycle.

## Consequences

This Decision remains draft until linked evidence is verified. The legacy record stays in default retrieval until this Decision becomes current accepted guidance.
