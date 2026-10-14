---
id: doc-9d44dbfe04863402ffc5cf56c024fa74
title: 'Client Core Packages Contract — Hợp đồng API 3 package lõi: local_sync, media_storage, version_gate'
description: '''Bảng hợp đồng API công bố của 3 package lõi Constellation (ports, presets, trạng thái, guard), kèm wiring recipe và seam kết nối giữa chúng. Trạng thái OBSERVED lấy trực tiếp từ source packages/.'''
createdAt: '2026-09-29T09:09:28.424Z'
updatedAt: '2026-09-29T10:41:20.464Z'
tags:
  - constellation
  - architecture
  - packages
  - contracts
  - local-first
  - solid
---

# Client Core Packages Contract — Hợp đồng API 3 package lõi

> **Trạng thái: `OBSERVED`** — toàn bộ chữ ký, hằng số và trạng thái trong doc này đọc trực tiếp từ source tại `packages/local_sync/`, `packages/media_storage/`, `packages/version_gate/` (ngày đọc 2026-09-29). Đây là **skeleton contract** dùng chung cho mọi app Constellation; app mới bắt buộc đọc doc này trước khi nối package.

---

## 0. Bảng tổng quan 3 package

| Package | Vai trò trong xương sống | Port abstraction chính | Guard riêng |
|---|---|---|---|
| `local_sync` | Hàng đợi ngoại tuyến + dispatcher nền | `LocalStoreAdapter`, `SyncHandler` | `TheVoidSyncGuard` |
| `media_storage` | Nén ảnh WebP + Storage adapter + path chuẩn hoá | `ImageCompressor`, `MediaStorageAdapter` | `TheVoidStorageGuard` |
| `version_gate` | SemVer gate + chống kẹt cache + sync lock | `SystemConfigRepository`, `ForceUpdateDelegate`, `SyncLockListener` | — |

Mọi package đều **pure Dart, không phụ thuộc Flutter SDK** (chỉ `meta`), test bằng `dart test`. Đường dẫn nối trong `pubspec.yaml`:

```yaml
dependencies:
  version_gate:   { path: ../../packages/version_gate }
  media_storage:  { path: ../../packages/media_storage }
  local_sync:     { path: ../../packages/local_sync }
```

---

## 1. `local_sync` — Hàng đợi Local-First

### 1.1. Bảng trạng thái hàng đợi (`SyncStatus`)

| Status | Ý nghĩa | Terminal? | Retry được? |
|---|---|---|---|
| `pending` | Chờ mạng/dispatch | không | có |
| `inProgress` | Đang gửi qua mạng | không | không |
| `completed` | Đã sync thành công (xóa khỏi queue) | **có** | không |
| `failed` | Lỗi tạm, đã đặt `nextRetryAt` | không | có |
| `deadLetter` | Vượt `maxRetries` hoặc thiếu handler; chặn queue | **có** | không |

Quy tắc: `isTerminal = completed || deadLetter`; `canRetry = pending || failed`.

### 1.2. `SyncQueueItem` (model hàng đợi)

Field bắt buộc: `id`, `actionType`, `payload` (Map), `createdAt`. Field mặc định: `status=pending`, `retryCount=0`, `maxRetries=5`. Field tùy chọn: `lastAttemptAt`, `nextRetryAt`, `errorMessage`.

`toJson()` dùng key snake_case (`action_type`, `retry_count`, `created_at`…) — hợp đồng lưu SQLite/Drift/KV, không đổi tên tùy tiện.

### 1.3. `LocalStoreAdapter` (port bắt buộc mọi adapter)

```dart
Future<void> enqueue(SyncQueueItem item);
Future<void> update(SyncQueueItem item);
Future<void> remove(String id);                 // chỉ gọi khi success
Future<SyncQueueItem?> getById(String id);
Future<List<SyncQueueItem>> getPendingItems({int limit = 50}); // pending + failed, createdAt ASC
Future<List<SyncQueueItem>> getFailedItems();
Future<int> getQueueSize();                     // đếm item KHÔNG terminal
Future<void> clearAll();                        // test / account reset
```

Hiện có duy nhất `MemoryLocalStoreAdapter` (in-memory). **Adapter bền vững SQLite/Drift/Hive chưa tồn tại** → offline queue chưa sống qua restart app. Adapter thực thi `TheVoidSyncGuard.assertNotTheVoid(item)` ngay trong `enqueue()` và `update()`.

### 1.4. `SyncDispatcher`

```dart
void registerHandler(String actionType, SyncHandler handler);
void lockSync();  void unlockSync();  bool get isLocked;
Future<int> dispatchPendingBatch({int limit = 10});
```

`DispatcherConfig` mặc định: `maxRetries=5`, `initialRetryDelay=2s`, `backoffMultiplier=2.0`, `maxRetryDelay=5m`.

Quy tắc dispatcher (**bất biến**):
1. `isLocked == true` (do `version_gate`) → trả `0`, không đụng network.
2. Offline → trả `0`.
3. Item không có handler → chuyển thẳng `deadLetter` (không treo queue).
4. Handler ném lỗi / trả `false` → `retryCount++`; dưới `maxRetries` thì `failed` + `nextRetryAt = backoff ±10% jitter`; bằng `maxRetries` thì `deadLetter`.
5. Handler trả `true` → `store.remove(id)`.

`SyncHandler = Future<bool> Function(SyncQueueItem)`; `NetworkConnectivityChecker = Future<bool> Function()`.

### 1.5. Guard The Void (`TheVoidSyncGuard`)

Ném `TheVoidSyncViolationException` nếu: `actionType` chứa `void` / `after_midnight_void` / `after-midnight-void`, **hoặc** key payload chứa `void_thought` hoặc bằng `void_text`.

---

## 2. `media_storage` — Nén ảnh & Storage

### 2.1. Bảng preset nén (`CompressOptions`) — hợp đồng zero-waste

| Preset | Crop | Max size | Quality | Dùng cho |
|---|---|---|---|---|
| `avatarPreset` | `square1x1` | 400×400 | 82 | Avatar |
| `momentPortraitPreset` | `portrait4x5` | 1440×1800 | 82 | Quire Moment dọc |
| `momentSquarePreset` | `square1x1` | 1440×1440 | 82 | Quire Moment vuông |
| `dreamAttachmentPreset` | `original` | 1440×1440 | 80 | Dream attachment |

Định dạng mặc định `ImageFormat.webp` (`image/webp`). `assert` trong constructor: `1 <= quality <= 100`, `maxWidth/Height > 0`.

```dart
Future<CompressedImageResult> compress({required Uint8List rawBytes, required CompressOptions options});
Future<CompressedImageResult> compressAvatar(Uint8List rawBytes);
Future<CompressedImageResult> compressMoment({required Uint8List rawBytes, CropAspectRatio cropRatio = portrait4x5});
```

`CompressedImageResult`: `bytes`, `width`, `height`, `format`, getter `byteSize`, `formattedSize`.

> `DefaultImageCompressor` là **passthrough** (trả nguyên bytes, không nén) — chỉ dành cho demo/headless. App production phải cung cấp compressor thật.

`CropAspectRatio` = `square1x1 (1:1)` | `portrait4x5 (4:5)` | `original (0:0, không crop)`.

### 2.2. Bảng bucket & path (`StoragePathGenerator`)

| Bucket | Public? | Path pattern | Generator |
|---|---|---|---|
| `avatars` | **public** | `{userId}/avatar_{timestamp}.webp` | `avatarPath(userId:, timestamp:)` |
| `quire-moments` | private | `{circleId}/{momentId}.webp` | `quireMomentPath(circleId:, momentId:)` |
| `dream-attachments` | private | `{userId}/{dreamId}/{photoId}.webp` | `dreamAttachmentPath(...)` |

Hỗ trợ: `extractAvatarTimestamp(path)` → `int?` (match `^avatar_(\d+)\.webp$`). Timestamped path là cơ chế phá cache CDN/trình duyệt — không đổi pattern.

### 2.3. `MediaStorageAdapter` (port)

```dart
Future<String> uploadFile({bucket, path, bytes, contentType});
Future<void>   deleteFile({bucket, path});
Future<List<String>> deleteFiles({bucket, paths});
Future<List<StorageFileObject>> listFiles({bucket, prefix});
String getPublicUrl({bucket, path});                              // bucket public
Future<String> createSignedUrl({bucket, path, expiresInSeconds}); // bucket private
Future<int> cleanupPreviousAvatars({userId, currentAvatarPath});  // GC, trả số file đã xóa
```

`SupabaseMediaStorageAdapter` **không import SDK** — nhận 5 function qua constructor (`RawStorageUploader`, `RawStorageDeleter`, `RawStorageLister`, `RawPublicUrlResolver`, `RawSignedUrlResolver`), do composition root của app tiêm Supabase client vào.

**Bất biến**: mọi method (trừ `cleanupPreviousAvatars` nội bộ) đều gọi `TheVoidStorageGuard.assertNotTheVoid(bucket, path)` **trước** khi chạm network.

### 2.4. Guard The Void (`TheVoidStorageGuard`)

Ném `TheVoidPersistenceViolationException` nếu `bucket` chứa `void` | `after_midnight` | `after-midnight`, **hoặc** `path` chứa `void`.

---

## 3. `version_gate` — Ép cập nhật & chống kẹt cache

### 3.1. Bảng trạng thái gate (`VersionGateStatus` — sealed)

| Status | Điều kiện | `shouldLockSync` | `shouldBlockUI` | Hành vi UI |
|---|---|---|---|---|
| `MaintenanceStatus` | `maintenance_mode = true` | **true** | **true** | Màn bảo trì không đóng được |
| `ForceUpdateStatus` | `current < minSupportedVersion` | **true** | **true** | Màn ép update, 1 CTA |
| `SoftUpdateStatus` | `minSupported <= current < latest` | false | false | Banner nhắc, dismiss được |
| `UpToDateStatus` | `current >= latest` | false | false | `clearGateOverlays()` |
| `OfflinePassThroughStatus` | fetch lỗi + cache không chặn | false | false | Cho qua an toàn |

**Thứ tự evaluate (bất biến)**: maintenance → force → soft → upToDate. On error: dùng `repository.cachedConfig` nếu status cached `shouldBlockUI`, ngược lại `OfflinePassThroughStatus`.

### 3.2. `VersionGateManager`

```dart
Future<VersionGateStatus> onAppBoot();    // cold boot / splash
Future<VersionGateStatus> onAppResume();  // resume từ background
Stream<VersionGateStatus> get statusStream;
static VersionGateStatus evaluate({required SemVer currentVersion, required AppSystemConfig config});
```

Constructor nhận: `currentAppVersion` (SemVer), `platform`, `repository`, `uiDelegate?`, `syncLockListener?`. Mỗi lần evaluate xong → phát status lên stream, gọi `lockSync()/unlockSync()` và switch UI delegate tương ứng.

### 3.3. `AppSystemConfig` (khớp cột `app_system_configs`)

Field Dart ↔ cột SQL: `platform`, `minSupportedVersion`↔`min_supported_version`, `latestVersion`↔`latest_version`, `forceUpdateTitle`, `forceUpdateMessage`, `updateUrl`↔`update_url`, `maintenanceMode`↔`maintenance_mode`, `maintenanceNotice?`↔`maintenance_notice`. JSON thiếu title/message → dùng copy mặc định tiếng Việt.

### 3.4. Port & UI contract

- `SystemConfigRepository` → `fetchConfig({platform})` + getter `cachedConfig`; adapter `SupabaseConfigRepository`.
- `ForceUpdateDelegate`: `showMaintenanceScreen`, `showForceUpdateScreen`, `showSoftUpdatePrompt`, `clearGateOverlays`, `openUpdateUrl`.
- `SyncLockListener`: `lockSync()`, `unlockSync()` — **chính là `SyncDispatcher` của `local_sync`**.

### 3.5. `WebCacheHeaders` (Web/PWA)

- `htmlAndWorkerNoCacheHeaders`: `Cache-Control: no-cache, no-store, must-revalidate`, `Pragma: no-cache`, `Expires: 0` → áp cho `index.html`, `flutter_service_worker.js`, `version.json`.
- `hashedStaticAssetHeaders`: `public, max-age=31536000, immutable` → `.wasm/.js/.css/.png/.webp/.woff2`.
- `appendCacheBust(uri, buildHash)`.
- `caddyConfigSnippet` / `nginxConfigSnippet` sẵn để dán vào server config.
- `WebServiceWorkerReloadNotifier`: nghe `controllerchange` → hiện banner "Phiên bản mới đã sẵn sàng. Tải lại trang để cập nhật." rồi `reloadPage()`.

---

## 4. Wiring recipe (cách nối 3 package với nhau)

```text
VersionGateManager(syncLockListener: SyncDispatcher, uiDelegate: <App's gate UI>)
        │ lockSync()/unlockSync()
        ▼
SyncDispatcher(store: LocalStoreAdapter, isOnline: NetworkChecker)
        │ registerHandler('upload_quire_moment', handler)
        ▼
QuireMomentUploader(storageAdapter: MediaStorageAdapter,
                    dbInserter: <Supabase insert>,
                    localStore: LocalStoreAdapter,
                    isOnline: NetworkChecker)
        │ uploadFile() → TheVoidStorageGuard → Supabase Storage
        └─ offline/failure → localStore.enqueue(SyncQueueItem)
```

Trình tự khởi động chuẩn cho app:

1. Khởi tạo `SupabaseClient` (ANON key only) → tạo 5 raw function cho `SupabaseMediaStorageAdapter`.
2. Khởi tạo `LocalStoreAdapter` (memory hiện tại) + `SyncDispatcher`.
3. `dispatcher.registerHandler('upload_quire_moment', ...)` — handler upload lại bytes từ payload rồi `dbInserter`.
4. Khởi tạo `VersionGateManager` với `syncLockListener: dispatcher` → `await onAppBoot()`.
5. Đăng ký `WidgetsBindingObserver` → `onAppResume()`.

> **Gap đang mở (`PROPOSED`)**: hiện chưa có adapter bền vững cho `LocalStoreAdapter`, chưa có handler `upload_quire_moment` nào được `registerHandler`, và `version_gate` chưa được khởi tạo trong `apps/quire` (xem @doc/architecture/quire-app-implementation).

---

## 5. Tham chiếu

- Nguyên lý module & SOLID: @doc/architecture/modular-reusable-components
- Bản đồ implementation Quire: @doc/architecture/quire-app-implementation
- Hợp đồng version gating phía backend: @doc/architecture/backend-supabase-version-gating
- Quy trình kiểm thử các package: @doc/guides/testing-verification-strategy
