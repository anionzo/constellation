---
id: doc-bfa6466f9e4ef355c21886028d5d13d6
title: Quire App Implementation
description: 'Bản đồ triển khai app Quire: cấu trúc module, state machine 8 trạng thái, uploader online/offline, presentation, theme tokens + 10 gap DEFERRED đã chứng minh.'
createdAt: '2026-09-29T10:07:06.956Z'
updatedAt: '2026-10-14T08:13:52.245Z'
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

## 6. Hiện trạng các Gap kỹ thuật (Cập nhật 2026-10-14)

| # | Gap kỹ thuật ban đầu | Trạng thái hiện tại | Giải pháp đã triển khai |
|---|---|---|---|
| 1 | `main.dart` gắn Mock uploader | DEFERRED | Giữ cấu trúc Adapter DIP; sẵn sàng nối Supabase/BFF sau |
| 2 | `capturePhoto()` trả `null` | **RESOLVED** | Đã triển khai `NativeCameraGalleryService` dùng `image_picker` trên cả Web & Mobile |
| 3 | `version_gate` chưa import | **RESOLVED** | Đã tích hợp `VersionGateManager`, hook boot/resume và `ForceUpdateView` trong `main.dart` |
| 4 | `SyncDispatcher` chưa nối handler | **RESOLVED** | Đã khởi tạo `SyncDispatcher`, đăng ký `handleReplaySync` và nối `DispatcherSyncLockBridge` |
| 5 | Dark theme chưa wiring | **RESOLVED** | Đã triển khai `QuireTheme.dark()` và `ThemeController` chuyển đổi theme trực tiếp trên UI |
| 6 | Nút Gửi fail WCAG AA (3.4:1) | **RESOLVED** | Đã đổi nhãn nút sang `QuireTokens.onAccentLight` (#241E19) đạt tương phản **4.83:1** (đạt chuẩn AA) |
| 7 | `FilterChip` < 44px | **RESOLVED** | Đã cấu hình `MaterialTapTargetSize.padded` và padding vertical 10.0 đạt chuẩn ≥ 44px |
| 8 | UI string đa ngữ | PROPOSED | Sẵn sàng cho wave i18n tiếp theo |
| 9 | Feed ảnh mẫu | **RESOLVED** | Đã hỗ trợ hiển thị ảnh thật từ `image_picker` qua `Image.memory` ngay khi gửi |
| 10 | Local store persistence | PROPOSED | Giữ `LocalStoreAdapter` trừu tượng, sẵn sàng cắm SQLite/Drift |

### Các tính năng bổ sung mới (2026-10-14)
- **Xuất bản bài viết tạp chí (`PublishArticleSheet`)**: Hỗ trợ người dùng viết bài mới với tiêu đề, chủ đề, ảnh bìa từ máy và nội dung dài.
- **Nhắn tin riêng tư (`CircleChatSheet`)**: Khung chat yên tĩnh 1-1 giữa bạn bè, gửi tin nhắn và ảnh khoảnh khắc.
- **Tự huỷ khoảnh khắc linh hoạt**: Công tắc Bật/Tắt tự hủy, tùy chọn thời gian 24h, 7 ngày, 30 ngày từ thời điểm đăng hoặc giữ vĩnh viễn.
- **Chỉnh sửa hồ sơ (`ProfileEditSheet`)**: Đổi tên, bio và ảnh đại diện từ thiết bị.
- **Quản lý vòng bạn bè**: Thêm bạn mới và gỡ bạn bè khỏi vòng thân thiết.

## 7. Test hiện có (Cập nhật 2026-10-14)

Hiện có **3 file test / 14 tests** chạy bằng `package:test` (thuần Dart VM, không phụ thuộc engine `dart:ui`), đạt tỷ lệ **pass 100%**:

1. `apps/quire/test/photo_upload_state_machine_test.dart` (5 tests): Permission denied, compose invariant, khóa nút tức thì, cửa sổ hoàn tác 900ms, dispatch sau timer.
2. `apps/quire/test/quire_client_hardening_test.dart` (5 tests): Tính toán độ tương phản WCAG AA (4.83:1), VersionGate Force Update & Maintenance evaluation, DispatcherSyncLockBridge lock/unlock, và offline queue replay qua SyncDispatcher.
3. `apps/quire/test/photo_auth_flow_test.dart` (4 tests): Hợp đồng CameraGalleryService, tính toàn vẹn của RawPhotoFile, cấu trúc dữ liệu Feed Injection sau khi đăng ảnh, và logic xác thực email Calm Auth.

Toàn bộ mã nguồn Quire đạt chuẩn `flutter analyze` với **0 errors, 0 warnings**.

Xem thêm: `guides/testing-verification-strategy` (kế hoạch test đầy đủ).

## Quan hệ

- Contract package mà app phụ thuộc: `architecture/client-core-packages-contract`
- Design tokens/prototype: `architecture/quire-design-implementation`
- Data model backend: `architecture/supabase-data-model`
- Usecase & luồng xử lý: `constellation/business-use-cases-and-processing-flows`
