---
id: doc-d01c2d8cf93b6e1eaabf3c7471bac766
title: Supabase Data Model
description: 'Data model Supabase: 8 bảng app + auth/storage stubs, RLS đầy đủ, 3 bucket, purge 30 ngày pg_cron, invariant The Void non-persistence.'
createdAt: '2026-09-29T10:08:17.208Z'
updatedAt: '2026-09-29T10:42:53.165Z'
tags:
  - constellation
  - supabase
  - postgres
  - rls
  - data-model
  - quire
---

# Supabase Data Model — OBSERVED

> **Status:** OBSERVED — trích từ `backend/supabase/migrations/01-init-schema.sql` (774 dòng, PostgreSQL 15+, Supabase self-hosted).
> Mọi bảng đều **ENABLE RLS**. Không có bảng nào chứa dữ liệu The Void (kiểm chứng bằng invariant §9).

## 1. Bảng ứng dụng (public schema)

| Bảng | PK | FK chính | Mục đích |
|---|---|---|---|
| `app_system_configs` | `platform` (CHECK android/ios/web) | — | Version gating + maintenance mode |
| `profiles` | `id` | → `auth.users.id` ON DELETE CASCADE | Hồ sơ 1:1, avatar_url |
| `quire_circles` | `id` | `created_by` → auth.users | Vòng thân thiết Quire |
| `quire_circle_members` | `(circle_id, user_id)` | → circles, auth.users | Thành viên; giới hạn do Backend quản lý |
| `quire_moments` | `id` | `circle_id`, `sender_id`, `reply_to_moment_id` (self) | Ảnh khoảnh khắc, tự hết hạn 30 ngày |
| `quire_moment_recipients` | `(moment_id, recipient_id)` | → moments, auth.users | Trạng thái người nhận: `read_at NULL`, `liked` |
| `dream_entries` | `id` | `user_id` → auth.users | Nhật ký giấc mơ, `veil_layer` 1–5, `lucidity_level` 1–5 |
| `dream_attachments` | `id` | `dream_id`, `user_id` | Đính kèm ảnh giấc mơ |

Schema phụ: `auth.users` (stub mở rộng cho FK sớm), `storage.buckets`, `storage.objects`.

## 2. Version gating (`app_system_configs`)

- Cột: `min_supported_version`, `latest_version`, `force_update_title/message`, `update_url`, `maintenance_mode`, `maintenance_notice`.
- RLS: **public read** (anon + authenticated đọc lúc boot để evaluate gate); **chỉ `service_role` mutate**.
- Seed 3 dòng (android/ios/web) `1.0.0` với message VI + link store.

## 3. Quire — Quyền riêng tư theo vòng

**`quire_circles`** RLS:
- SELECT: creator hoặc là thành viên (EXISTS trong members).
- INSERT: `created_by = auth.uid()`.
- UPDATE/DELETE: chỉ creator.

**`quire_circle_members`** RLS:
- SELECT: chính mình, hoặc cùng circle, hoặc là creator circle.
- INSERT: chỉ creator circle thêm.
- DELETE: tự rời, hoặc creator xóa.

Trigger `on_circle_created` → tự thêm creator làm thành viên đầu tiên.
**Ghi chú migration:** trigger giới hạn 12 thành viên đã bị drop — "Limit/policy managed at Golang Backend" (không hardcode ceiling trong DB).

**`quire_moments`** RLS:
- SELECT: sender hoặc có dòng trong `moment_recipients`.
- INSERT: `sender_id = auth.uid()` **và** sender là thành viên của `circle_id`.
- UPDATE/DELETE: sender.

**`quire_moment_recipients`** RLS:
- SELECT: recipient hoặc sender của moment.
- INSERT: chỉ sender của moment (client không tự thêm người nhận).
- UPDATE: recipient (đánh dấu liked/read của chính mình).
- **DELETE: không có policy** → recipient không thể bỏ nhận (theo đúng thiết kế).

`read_at` DEFAULT NULL — "Quiet Computing: read receipts OFF by default" (không tạo áp lực xã hội).

## 4. Dream Journal — Strict Sanctum

- 8 policy author-only trên `dream_entries` + `dream_attachments` (SELECT/INSERT/UPDATE/DELETE đều `user_id = auth.uid()`).
- Ràng buộc CHECK: `lucidity_level 1..5`, `veil_layer 1..5` NOT NULL DEFAULT 1.
- `dream_attachments` INSERT additionally kiểm tra attachment thuộc dream của chính mình.
- Không có policy chia sẻ → không đường nào đọc được giấc mơ người khác.

## 5. Storage buckets & RLS trên `storage.objects`

| Bucket | Public | Limit | MIME | Đường dẫn mẫu |
|---|---|---|---|---|
| `avatars` | ✅ | 1MB | webp/jpeg/png | `avatars/{user_id}/avatar_{timestamp}.webp` |
| `quire-moments` | ❌ | 5MB | webp/jpeg/png | `quire-moments/{circle_id}/{moment_id}.webp` |
| `dream-attachments` | ❌ | 10MB | webp/jpeg/png | `dream-attachments/{user_id}/{dream_id}/{photo_id}.webp` |

- **avatars**: public SELECT; INSERT/UPDATE/DELETE yêu cầu folder[1] = `auth.uid()`.
- **quire-moments**: folder[1] phải match regex UUID **và** user thuộc circle đó (SELECT + INSERT); DELETE chỉ sender có `image_path` khớp.
- **dream-attachments**: folder[1] = `auth.uid()` (SELECT/INSERT/DELETE).

## 6. Purge tự động 30 ngày

- Hàm `public.purge_expired_quire_moments()` (SECURITY DEFINER): (1) xóa file trong `storage.objects` where `expires_at < NOW()`, (2) DELETE moments → cascade `moment_recipients`. Trả về `(purged_moments_count, purged_storage_files_count)`.
- `pg_cron` schedule `0 3 * * *` (03:00 UTC daily), job name `daily_purge_expired_quire_moments`; nếu extension chưa active → `RAISE NOTICE` bỏ qua (hàm vẫn chạy tay được).

## 7. Invariant — The Void Non-Persistence (§9)

Migration tự kiểm chứng: nếu tồn tại bảng `public` nào tên LIKE `%void%` hoặc `%midnight%` → `RAISE EXCEPTION 'CRITICAL INVARIANT VIOLATION'`. Dữ liệu After Midnight / The Void **không bao giờ** chạm persistence.

## 8. Infrastructure / roles

- Roles tạo: `supabase_admin`, `anon`, `authenticated`, `service_role` (BYPASSRLS), `supabase_auth_admin`, `supabase_storage_admin`; password kế thừa từ `postgres`.
- Extensions: `uuid-ossp`, `pgcrypto`, `pg_cron`.
- Helpers: `auth.uid()/role()/email()` đọc JWT claim qua `current_setting`; `storage.foldername/filename/extension`.
- Trigger `on_auth_user_created` → `handle_new_user()` tự tạo `profiles` row (display_name ưu tiên metadata → email prefix → `User {8 ký tự id}`).

## Quan hệ

- Client contract đọc bảng này: `architecture/client-core-packages-contract` (VersionGateStatus, WebCacheHeaders).
- Luồng ghi dữ liệu từ app: `architecture/quire-app-implementation` §3 (`dispatchMoment` → `momentRow`/`recipientRows`).
- Kế hoạch test RLS/purge: `guides/testing-verification-strategy`.
- Usecase & luồng xử lý: `constellation/business-use-cases-and-processing-flows`.
