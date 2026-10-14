---
id: doc-7d776020dbcfad91fe33c34c6e575ff9
title: Business Use Cases And Processing Flows
description: "12 usecase nghiệp vụ Quire/Constellation kèm luồng xử lý từng bước (gửi khoảnh khắc, undo 900ms, offline replay, RLS đọc, purge 30 ngày, version gate, Dream Sanctum, The Void, avatar) + ma trận triển khai client/backend/test. [đã audit 2026-09-29]"
createdAt: '2026-09-29T10:14:14.722Z'
updatedAt: '2026-09-29T10:42:53.359Z'
tags:
  - constellation
  - usecase
  - business-flow
  - quire
  - rls
  - offline-sync
---

# Business Use Cases And Processing Flows — OBSERVED + PROPOSED + DEFERRED

> **Status:** từng UC gắn nhãn riêng. Nguồn: code client (`apps/quire`, `packages/*`), SQL (`backend/supabase/migrations/01-init-schema.sql`), thiết kế (`designs/quire/`).
> Bổ sung cho `constellation/quire-01-flow` (inventory 19 màn của prototype) — doc này đi theo **luồng xử lý nghiệp vụ xuyên app + backend**.

## Bảng tổng hợp UC

| ID | Use case | Actors | Trạng thái |
|---|---|---|---|
| UC-01 | Gửi khoảnh khắc cho vòng thân thiết | Người gửi | OBSERVED (client) / DEFERRED (uploader thật) |
| UC-02 | Hoàn tác gửi trong 900ms | Người gửi | OBSERVED |
| UC-03 | Gửi khi offline → hàng chờ → replay | App (nền) | OBSERVED (queue) / DEFERRED (replay chưa nối) |
| UC-04 | Nhận & xem khoảnh khắc trong vòng | Người nhận | OBSERVED (SQL) / DEFERRED (UI feed) |
| UC-05 | Thả tim khoảnh khắc | Người nhận | OBSERVED (SQL + UI cục bộ) |
| UC-06 | Tạo vòng & quản lý thành viên | Người tạo vòng | OBSERVED (SQL) |
| UC-07 | Tự hết hạn & purge 30 ngày | pg_cron | OBSERVED (SQL) |
| UC-08 | Boot version gate | App | OBSERVED (package) / DEFERRED (chưa nối vào app) |
| UC-09 | Ghi nhật ký giấc mơ + đính kèm | Tác giả | OBSERVED (SQL) / DEFERRED (chưa có app) |
| UC-10 | The Void — zero persistence | Mọi actor | OBSERVED (guard + test + SQL invariant) |
| UC-11 | Upload & thay avatar | Người dùng | OBSERVED (package + SQL) / DEFERRED (UI) |
| UC-12 | Đọc bài dài & lưu bài | Người đọc | PROPOSED (design-level, chưa có code đọc bài) |

---

## UC-01 · Gửi khoảnh khắc (luồng chính)

**Actor:** thành viên vòng · **Trigger:** bấm nút máy ảnh / "Đáp lại bằng ảnh"

**Precondition:** đã đăng nhập (`authenticated`), là thành viên `quire_circle_members`, chọn ≥1 bạn.

**Luồng xử lý (main flow):**
1. `PhotoUploadStateMachine.startCaptureFromCamera()` → kiểm tra quyền → `PhotoUploadPreprocessingState`.
2. `capturePhoto()` trả `RawPhotoFile` → `_processPhotoAndOpenCompose()`.
3. `imageCompressor.compressMoment(cropRatio: portrait4x5)` → WebP ≤1440px.
4. `fetchCircleFriends(circleId)` → `PhotoUploadComposeState` (chưa chọn ai → `canSend=false`).
5. User chọn chip bạn + caption (tùy chọn) → `SendTapped`.
6. `submitSend()`: kiểm invariant ≥1 bạn → `PhotoUploadSendingState` (khóa nút) → `PhotoUploadUndoGraceState` + `Timer(900ms)`.
7. Hết 900ms, chưa undo → `_executeBackgroundDispatch()` → `QuireMomentUploader.dispatchMoment()`:
   - **Online:** `uploadFile` bucket `quire-moments` path `{circle_id}/{moment_id}.webp` (image/webp) → `momentRow` (`expires_at = now+30d`) + `recipientRows` (`read_at=NULL`, `liked=false`) → `dbInserter`.
   - **Offline / upload lỗi:** → `_enqueueLocally()` → `SyncQueueItem(actionType:'upload_quire_moment', status:pending)` → `localStore.enqueue`.
8. → `PhotoUploadDispatchedState` → sheet đóng.

**Quy tắc nghiệp vụ:**
- R1 ≥1 người nhận (invariant `canSend`).
- R2 Khoảnh khắc sống 30 ngày (`expires_at`).
- R3 `read_at` mặc định NULL — read receipts OFF (Quiet Computing).
- R4 Đường dẫn do client sinh, nhưng DB chỉ nhận khi sender thuộc circle (RLS INSERT).
- R5 Client không tự thêm dòng recipient ngoài payload của sender (RLS INSERT chỉ cho sender).

**Data:** `storage.objects`(bucket `quire-moments`) + `public.quire_moments` + `public.quire_moment_recipients`.

**Exception flows:**
- E1 Quyền camera bị từ chối → `PhotoUploadPermissionDeniedState` (2 lựa chọn: Mở cài đặt / Chọn thư viện).
- E2 `capturePhoto()`/`pickFromGallery()` trả `null` → về `IdleState`.
- E3 Chưa chọn bạn → nút disable, label "Chọn ít nhất một người".
- E4 Upload throw giữa chừng → rơi vào nhánh offline queue (không mất ảnh).

**Chưa đủ điều kiện production (DEFERRED):** `main.dart` đang gắn `MockQuireMomentUploader`; `DefaultCameraGalleryService.capturePhoto()` luôn trả `null`.

---

## UC-02 · Hoàn tác gửi trong 900ms

**Trigger:** bấm "Hoàn tác" trong `PhotoUploadUndoGraceState`

**Luồng:** `triggerUndo()` → set `_isUndoTriggered=true` → hủy `_undoTimer` → `PhotoUploadAbortedState` → toast "Đã huỷ gửi. Không có gì rời khỏi ứng dụng." → sheet đóng → `reset()` về Idle.

**Quy tắc:** **zero-egress** — không byte nào rời app (test chứng minh: chờ 1000ms vượt window → `uploadedPaths` rỗng, `getQueueSize()==0`).

---

## UC-03 · Offline queue → replay (SyncDispatcher)

**Luồng enqueue (OBSERVED):** `dispatchMoment` khi `isOnline()==false` hoặc upload lỗi → `SyncQueueItem{id: momentId, actionType:'upload_quire_moment', payload:{...}, status: pending}`.

**Luồng replay (OBSERVED trong package, DEFERRED trong app):**
1. `dispatchPendingBatch(limit:10)` — thoát ngay nếu `isLocked` (VersionGate) hoặc đang xử lý hoặc offline.
2. Lấy pending items; bỏ qua item có `nextRetryAt > now`.
3. Không có `SyncHandler` cho `actionType` → chuyển **deadLetter** (không stall vô hạn).
4. Chuyển `inProgress` → gọi handler:
   - `true` → **xóa item khỏi queue** (success).
   - `false`/throw → `_handleFailure`: `retryCount+1`; nếu ≥ `maxRetries(5)` → **deadLetter**, ngược lại → `failed` + `nextRetryAt = backoff(2s ×2^n, cap 5m, jitter ±10%)`.

**DEFERRED:** app chưa tạo `SyncDispatcher`, chưa `registerHandler('upload_quire_moment', ...)` → hàng chờ offline hiện không bao giờ được replay.

---

## UC-04 · Nhận & xem khoảnh khắc

**Luồng (SQL, OBSERVED):**
1. Sender tạo moment → dòng recipient cho từng người được chọn.
2. Người nhận đọc feed: RLS `SELECT` trên `quire_moments` cho sender hoặc người có trong `moment_recipients`.
3. Đọc ảnh: RLS trên `storage.objects` bucket `quire-moments` — folder[1] là UUID circle **và** user thuộc circle đó.
4. (UI feed thật: DEFERRED — hiện chỉ có fixture `picsum.photos` trong `QuireHomeScreen`.)

**Quan sát lệch (đáng lưu ý):** row DB chỉ hiện cho sender/recipient, nhưng **object ảnh đọc được với mọi thành viên circle** (có path). Nên path coi như bí mật bên trong vòng.

**Exception:** hết hạn → row + file bị purge (xem UC-07); người ngoài vòng → cả DB lẫn storage đều 403.

---

## UC-05 · Thả tim

**Luồng:** UI `QuireHomeScreen` toggle cục bộ (`moment['liked']`, chưa ghi DB) → đường production dự kiến: UPDATE `quire_moment_recipients.liked` — RLS chỉ cho `recipient_id = auth.uid()` (mỗi người tự toggled trạng thái của mình; sender không sửa được liked của người khác).

## UC-06 · Tạo vòng & quản lý thành viên

**Luồng:** INSERT `quire_circles` (`created_by = auth.uid()`) → trigger `on_circle_created` tự thêm creator làm member đầu tiên → creator thêm/bớt thành viên (RLS INSERT/DELETE chỉ creator) → thành viên tự rời (DELETE `user_id = auth.uid()`).

**Quy tắc:** giới hạn số thành viên **không hardcode trong DB** (trigger 12 thành viên đã drop) — "managed at Golang Backend". Design nói vòng 4–12 người; client giao diện 4–11 (friend chips).

## UC-07 · Tự hết hạn 30 ngày (purge)

**Luồng (03:00 UTC hàng ngày qua pg_cron):** `purge_expired_quire_moments()` → (a) DELETE `storage.objects` where `name = image_path` hoặc khớp `{circle_id}/{moment_id}%` → (b) DELETE `quire_moments` where `expires_at < NOW()` → cascade `moment_recipients` → trả `(purged_moments_count, purged_storage_files_count)`.

**Exception:** pg_cron chưa active → RAISE NOTICE, hàm vẫn chạy tay được.

## UC-08 · Boot version gate

**Luồng (`VersionGateManager.onAppBoot()` / `onAppResume()`):**
1. `repository.fetchConfig(platform)` → `app_system_configs` (RLS public read).
2. `evaluate()` theo thứ tự ưu tiên: **maintenance_mode → MaintenanceStatus**; `current < min_supported → ForceUpdateStatus`; `current < latest → SoftUpdateStatus`; ngược lại `UpToDateStatus`.
3. `_applyStatus`: `shouldLockSync` → `syncLockListener.lockSync()` (khóa `SyncDispatcher`); UI delegate hiện overlay tương ứng / `clearGateOverlays`.
4. **Fetch lỗi:** dùng `cachedConfig` — nếu cached yêu cầu block → vẫn block; nếu không → `OfflinePassThroughStatus` (cho qua an toàn offline).

**DEFERRED:** package có đủ + 4 test xanh, nhưng app chưa import `version_gate` (khởi tạo ở đâu cũng chưa).

## UC-09 · Ghi nhật ký giấc mơ (Dream Journal)

**Luồng:** INSERT `dream_entries` (tự điền `veil_layer` 1–5, `lucidity_level` 1–5 nullable) → INSERT `dream_attachments` (kiểm tra dream thuộc mình) → file vào bucket `dream-attachments/{user_id}/{dream_id}/`.

**Quy tắc:** **Strict Sanctum** — 8 policy author-only, không đường chia sẻ; không đọc được giấc mơ người khác dưới mọi vai trò.

## UC-10 · The Void — zero persistence (invariant)

**Luồng bảo vệ (3 tầng, OBSERVED):**
1. **Client:** `TheVoidSyncGuard` (local_sync) + `TheVoidGuard` (media_storage) chặn enqueue/upload dữ liệu The Void — có test riêng ở 2 package.
2. **Dispatcher:** item The Void không bao giờ lọt vào hàng chờ (test: `enforces The Void Invariant (Strict Zero-Persistence)`).
3. **DB:** migration §9 tự kiểm — tồn tại bảng `public` tên LIKE `%void%`/`%midnight%` → `RAISE EXCEPTION 'CRITICAL INVARIANT VIOLATION'`.

## UC-11 · Upload & thay avatar

**Luồng:** `StoragePathGenerator` sinh `avatars/{user_id}/avatar_{timestamp}.webp` → `uploadFile` bucket `avatars` (public, limit 1MB) → `cleanupPreviousAvatars(userId, currentAvatarPath)` xóa bản cũ → ghi `profiles.avatar_url`. RLS storage: folder[1] phải bằng `auth.uid()`.

## UC-12 · Đọc bài dài & lưu bài (PROPOSED)

Theo `designs/quire` (19 màn): Home → Reader → Save → Library → Writer. **Chưa có code** (tab Đọc hiện là placeholder `Text('Trang Đọc Biên Tập')`). Quy tắc design đã chốt: không follower, không streak, không badge, không notification thúc ép; hairline thay bóng đổ; accent đơn nhất.

---

## Ma trận trạng thái triển khai

| Hạng mục | Client | Backend (SQL) | Test |
|---|---|---|---|
| Gửi khoảnh khắc (luồng happy) | ✅ (mock uploader) | ✅ | ✅ 5 test state machine |
| Undo 900ms zero-egress | ✅ | — | ✅ |
| Offline enqueue | ✅ | — | ✅ |
| Offline replay | ❌ chưa nối | — | ✅ dispatcher (package) |
| Version gate | ❌ chưa nối | ✅ seed + RLS | ✅ 8 test |
| RLS moment/circle/recipient | — | ✅ | ❌ chưa có |
| Purge 30 ngày | — | ✅ | ❌ chưa có |
| Dream Sanctum | ❌ chưa có app | ✅ | ❌ |
| The Void invariant | ✅ | ✅ | ✅ 2 test |
| Avatar | ⚠️ path+cleanup có, UI chưa | ✅ | ✅ path/cleanup |
| Feed đọc bài | ❌ placeholder | — | — |

## Quan hệ

- Inventory 19 màn prototype: `constellation/quire-01-flow`, dữ liệu prototype: `constellation/quire-02-data`
- Triển khai client: `architecture/quire-app-implementation`
- Data model + RLS: `architecture/supabase-data-model`
- Contract 3 package: `architecture/client-core-packages-contract`
- Kế hoạch test cho các UC chưa có test: `guides/testing-verification-strategy`
