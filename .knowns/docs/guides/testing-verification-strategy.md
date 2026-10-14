---
id: doc-53b28b31052bcd127e0fb46a50005c13
title: Testing Verification Strategy
description: 'Chiến lược test: hiện trạng 5 file/22 test thuần package:test, cách chạy từng package, invariant đang được bảo vệ, kế hoạch bổ sung PROPOSED (RLS, purge, uploader, a11y contrast, CI).'
createdAt: '2026-09-29T10:09:20.072Z'
updatedAt: '2026-09-29T10:35:37.518Z'
tags:
  - constellation
  - testing
  - verification
  - quality
  - ci-proposed
---

# Testing & Verification Strategy — OBSERVED + PROPOSED

> **Status:** §1–§3 OBSERVED (test hiện có, cách chạy). §4–§6 PROPOSED (kế hoạch bổ sung, chưa có code).

## 1. Hiện trạng (OBSERVED)

**5 file test / 22 test**, thuần Dart (`package:test`), không có CI, không có root pubspec/melos:

| Package/App | File | SL | Trọng tâm |
|---|---|---|---|
| `local_sync` | `test/sync_queue_test.dart` | 4 | FIFO enqueue; **The Void invariant zero-persistence**; dispatcher chạy handler + xóa item khi success; dispatcher **halt khi VersionGate lock** |
| `media_storage` | `test/image_compressor_test.dart` | 5 | 3 path generator (avatar/moment/dream); **The Void invariant**; cleanup avatar cũ |
| `version_gate` | `test/semver_test.dart` | 4 | parse SemVer chuẩn; pre-release + build metadata; precedence; FormatException khi malformed |
| `version_gate` | `test/version_gate_manager_test.dart` | 4 | MaintenanceStatus + lock sync; ForceUpdate (< min); SoftUpdate (≤ x < latest); UpToDate |
| `quire` | `test/photo_upload_state_machine_test.dart` | 5 | permission denied; ComposeState invariant ≥1 friend; gửi → khóa nút + UndoGrace 900ms; **Undo hủy = 0 byte rời app** (chờ 1000ms, assert `uploadedPaths` rỗng + queue size 0); hết 900ms → dispatch |

Đặc điểm chung: mock tự viết trong file test (`MockCameraGalleryService`, `MockImageCompressor`, `MockMediaStorageAdapter`, `MemoryLocalStoreAdapter`) — không dùng `mockito`/`mocktail`.

## 2. Cách chạy (OBSERVED)

```bash
# Mỗi package là pubspec độc lập (path deps), chạy từ thư mục package:
cd packages/local_sync   && dart test
cd packages/media_storage && dart test
cd packages/version_gate  && dart test
cd apps/quire             && dart test   # dùng package:test, KHÔNG phải flutter_test
```

Không có script gộp. Chạy thủ công từng thư mục.

## 3. Invariant đã được test bảo vệ (OBSERVED)

1. **The Void non-persistence** — 2 test (local_sync, media_storage): không byte nào của The Void được enqueue/lưu.
2. **Offline-queue integrity** — dispatcher chỉ xóa item sau khi handler thành công; halt khi lock.
3. **Version gate matrix** — đủ 4 nhánh trạng thái (maintenance/force/soft/up-to-date).
4. **Undo 900ms zero-egress** — sau khi Undo, chờ vượt window vẫn không upload, không queue.
5. **Compose invariant** — không chọn bạn → `canSend=false`, label "Chọn ít nhất một người".

## 4. Kế hoạch bổ sung (PROPOSED — chưa implement)

**Ưu tiên cao:**
- `QuireMomentUploader`: online path (upload + insert row), offline path (enqueue), **fallback khi upload throw giữa chừng** — hiện chưa test.
- `purge_expired_quire_moments()` (SQL): hết hạn → xóa object + cascade recipients; test bằng pgTAP hoặc integration script.
- **RLS matrix per table**: mỗi policy 1 positive + 1 negative case (member đọc được, outsider 403; recipient không DELETE được row của mình...).

**Ưu tiên trung bình:**
- `DashedCirclePainter` snapshot/golden test (invariant: dashed ring, không gradient).
- Contrast check tự động (nút Gửi `#FFFFFF` trên `#E76136` = 3.4:1 → fail AA) — nên là test cố định để không regression.
- `SemVer` edge: `1.0.0+build` equality, large numeric identifiers.

**Ưu tiên thấp:**
- Widget test cho `QuireComposeSheet` (FilterChip touch target ≥44px), i18n key coverage (126 key EN/VI).
- E2E: capture → compose → send → undo, và send → 900ms → xuất hiện trong feed.

## 5. Gaps trong test hiện tại (DEFERRED)

- Không test `MockQuireMomentUploader` thay thế ở `main.dart` (uploader thật chưa tồn tại → không thể test).
- Không test `DefaultCameraGalleryService` (luôn trả `null`).
- Không test replay `upload_quire_moment` khỏi queue (handler chưa `registerHandler`).
- Không có CI (không `.github/workflows`) → test không tự chạy khi push.
- Chưa có coverage report / threshold.

## 6. Tiêu chí "xong" cho wave test tiếp theo (PROPOSED)

1. `dart test` xanh ở cả 4 package + app.
2. Có script gộp (Makefile hoặc melos) chạy toàn bộ.
3. Ít nhất 1 test bảo vệ mỗi invariant trong CONVENTIONS (The Void, offline-queue, version gate, 30-day expiry, RLS author-only).
4. A11y contrast check cho màu accent chính.

## Quan hệ

- code test: `apps/quire/test/`, `packages/*/test/`
- invariant gốc: `.knowns/docs/CONVENTIONS.md`, `patterns/ephemeral-privacy-lifecycles` (The Void)
- data model cần test RLS: `architecture/supabase-data-model`
