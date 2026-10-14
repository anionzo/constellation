---
id: doc-bfa6466f9e4ef355c21886028d5d13d6
title: Quire App Implementation
description: 'Bản đồ triển khai app Quire: cấu trúc module, state machine 8 trạng thái, uploader online/offline, presentation, theme tokens + 10 gap DEFERRED đã chứng minh.'
createdAt: '2026-09-29T10:07:06.956Z'
updatedAt: '2026-09-29T10:42:39.613Z'
tags:
  - constellation
  - quire
  - flutter
  - implementation
  - state-machine
  - prototype
---

# Quire App Implementation — OBSERVED

> **Status:** OBSERVED — đọc từ source `apps/quire/lib` (commit hiện tại).
> **Không phải design doc:** chỉ mô tả code đang chạy, kèm gap đã chứng minh (DEFERRED).

## 1. Cấu trúc module

```
apps/quire/lib/
├── main.dart                                  # bootstrap + theme light + Mock uploader
└── src/
    ├── features/photo_upload/
    │   ├── quire_photo_upload.dart            # barrel export
    │   ├── machine/photo_upload_state_machine.dart
    │   ├── state/photo_upload_state.dart       # sealed states (8)
    │   ├── state/photo_upload_event.dart       # sealed events (12)
    │   ├── models/photo_upload_input.dart      # PhotoUploadContext, RawPhotoFile, PhotoUploadInput
    │   ├── models/friend_chip.dart             # FriendChip + initials + ==
    │   ├── services/camera_gallery_service.dart
    │   ├── services/quire_moment_uploader.dart
    │   └── ui/quire_compose_sheet_contract.dart
    └── presentation/
        ├── theme/quire_tokens.dart             # design tokens
        ├── views/quire_home_screen.dart        # 4 tabs, IndexedStack
        ├── views/quire_compose_sheet.dart      # bottom sheet compose
        └── widgets/quire_circle_avatar.dart    # dashed-ring avatar
```

## 2. State Machine (`PhotoUploadStateMachine`)

**Trạng thái (sealed, `photo_upload_state.dart`):**

| State | Vai trò | Ghi chú |
|---|---|---|
| `PhotoUploadIdleState` | trạng thái nghỉ | start & reset về đây |
| `PhotoUploadPermissionDeniedState` | từ chối quyền máy ảnh | copy VI hardcode trong state |
| `PhotoUploadPreprocessingState` | crop + nén WebP | `progressLabel` mặc định |
| `PhotoUploadComposeState` | sheet soạn | invariant `canSend => selectedFriendIds.isNotEmpty` |
| `PhotoUploadSendingState` | khóa nút ngay | `isButtonLocked = true` |
| `PhotoUploadUndoGraceState` | cửa sổ 900ms | factory `.initial()` |
| `PhotoUploadAbortedState` | user bấm Hoàn tác | "Không có gì rời khỏi ứng dụng" |
| `PhotoUploadDispatchedState` | đã upload/queue | `isOfflineQueued` |

**Sự kiện (sealed, `photo_upload_event.dart`):** `CaptureFromCameraRequested`, `SelectFromGalleryRequested`, `PermissionDeniedEncountered`, `PhotoRawAcquired`, `PreprocessingCompleted`, `FriendToggled`, `CaptionChanged`, `SendTapped`, `UndoWindowStarted`, `UndoTapped`, `UndoWindowExpired`, `ResetToIdle`.

**Luồng chuẩn (`machine/photo_upload_state_machine.dart`):**

1. `startCaptureFromCamera()` → check quyền → `Preprocessing` → `capturePhoto()`.
2. `_processPhotoAndOpenCompose()` → `imageCompressor.compressMoment(cropRatio: portrait4x5)` → `fetchCircleFriends(circleId)` → `ComposeState` (chưa chọn ai).
3. `submitSend()` → invariant `canSend` → `SendingState` (khóa nút) → `UndoGraceState.initial()` → `Timer(900ms)`.
4. Timer fire, chưa undo → `_executeBackgroundDispatch()` → `uploader.dispatchMoment(...)` → `DispatchedState`.
5. `triggerUndo()` trong 900ms → hủy timer → `AbortedState`.
6. `reset()` khi đóng sheet → hủy timer → `IdleState`.

`process(PhotoUploadEvent)` là dispatcher switch; `startComposeWithPhoto()` bypass capture (dùng khi đã có ảnh).

## 3. Uploader (`QuireMomentUploader`)

- `dispatchMoment()` → `isOnline()`:
  - **Online:** `uploadFile(bucket: quire-moments, contentType: 'image/webp')` → chuẩn bị `momentRow` (expires_at = now + 30 ngày) + `recipientRows` (read_at `null`, liked `false`) → `dbInserter(...)`.
  - **Offline hoặc upload throw:** `_enqueueLocally()` → `SyncQueueItem(actionType: 'upload_quire_moment', status: pending)` → `localStore.enqueue()`.
- Kết quả `MomentDispatchResult{isSuccess, isOfflineQueued, message}` — message VI hardcode.
- Đường dẫn: `StoragePathGenerator.quireMomentPath(circleId, momentId)`.

## 4. Presentation

- **`QuireHomeScreen`**: `IndexedStack` 4 tab (Đọc / Khoảnh khắc / Khám phá / Bạn), mặc định tab 1. Mock 11 `FriendChip` (vòng thân thiết 4–11 người) + 1 moment fixture `picsum.photos`. `_openComposeSheet()` tạo `PhotoUploadStateMachine` mới mỗi lần mở.
- **`QuireComposeSheet`**: thumbnail 72px `Image.memory`, TextField caption, `Wrap` of `FilterChip`, nút Gửi. View "xong" (UndoGrace) có `LinearProgressIndicator` chạy 900ms (tick 30ms). Lắng nghe `stateStream` qua `StreamSubscription`.
- **`QuireCircleAvatar`**: 3 nhánh — `isUserAddCircle` (icon +), `imageUrl` (network, fallback initials), initials. `hasUnreadStory` → `DashedCirclePainter` (vòng đứt nét, invariant: không gradient).

## 5. Theme (`QuireTokens`)

- Light: `paperLight #FBF9F5`, `accentLight #E76136` (terracotta), `ruleLight #E8E3DB`, ink 3 bậc.
- Dark: `paperDark #1A1612` (không pure black), `accentDark #F0834E`.
- Radii: rPhoto 10 / rPlate 14 / rBtn 13 / rField 13 / rCard 18 / rSheet 22.
- Font: `Newsreader` (serif) + `JetBrains Mono` (eyebrow/meta).
- Style factory: `title()`, `h3()`, `body()`, `eyebrow()`, `meta()`, `button()` — có tham số `isDark` (chưa được dùng vì chưa có dark theme wiring).

## 6. Gap đã chứng minh (DEFERRED)

| # | Gap | Bằng chứng |
|---|---|---|
| 1 | `main.dart:47` gắn `MockQuireMomentUploader` — chưa có uploader thật (Supabase) | đọc main.dart |
| 2 | `DefaultCameraGalleryService.capturePhoto()` trả `null` luôn →luồng capture thật chưa tồn tại | `camera_gallery_service.dart:39` |
| 3 | `version_gate` khai báo trong pubspec nhưng không import trong app | grep `package:version_gate` → 0 match |
| 4 | `SyncDispatcher` không được khởi tạo trong app; handler `upload_quire_moment` chưa `registerHandler` → queue offline không bao giờ được replay | không có trong main.dart |
| 5 | Dark palette tồn tại nhưng `main.dart` chỉ gắn light `ThemeData` | main.dart:36-44 |
| 6 | Nút Gửi `Colors.white` trên nền `#E76136` ≈ 3.4:1 → fail WCAG AA (cần ≥4.5) | compose_sheet:208,231 |
| 7 | `FilterChip` mặc định ≈32px < 44px touch target | compose_sheet:182 |
| 8 | String UI hardcode tiếng Việt trong state/widget (prototype có sẵn i18n 126 key EN/VI nhưng chưa map) | photo_upload_state.dart, compose_sheet |
| 9 | Feed dùng ảnh `picsum.photos` fixture | home_screen:48 |
| 10 | `MemoryLocalStoreAdapter` là adapter duy nhất được nối (mất queue khi restart process) | main.dart:59 |

## 7. Test hiện có

Một file: `apps/quire/test/photo_upload_state_machine_test.dart` — 5 test (permission denied, compose invariant ≥1 friend, gửi khóa nút + UndoGrace, Undo hủy + không upload gì, hết 900ms → dispatch). Chạy bằng `package:test` (không phải flutter_test) với mock tự viết.

Xem thêm: `guides/testing-verification-strategy` (kế hoạch test đầy đủ).

## Quan hệ

- Contract package mà app phụ thuộc: `architecture/client-core-packages-contract`
- Design tokens/prototype: `architecture/quire-design-implementation`
- Data model backend: `architecture/supabase-data-model`
- Usecase & luồng xử lý: `constellation/business-use-cases-and-processing-flows`
