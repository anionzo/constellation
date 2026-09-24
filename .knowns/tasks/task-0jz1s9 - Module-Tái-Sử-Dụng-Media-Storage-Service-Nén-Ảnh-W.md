---
id: 0jz1s9
title: 'Module Tái Sử Dụng: Media Storage Service & Nén Ảnh WebP Client'
status: done
priority: high
labels:
  - modular
  - reusable
  - client
  - storage
createdAt: '2026-09-24T16:45:51.266Z'
updatedAt: '2026-09-24T16:51:50.699Z'
timeSpent: 0
order: 4
---
# Module Tái Sử Dụng: Media Storage Service & Nén Ảnh WebP Client

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Tách module độc lập packages/core/media_storage dùng chung cho Quire (Avatar/Moments) và Dream Journal (Dream Attachments): Chuỗi nén ảnh WebP 1:1/4:5 max 1440px/400px (<350KB), upload Supabase Storage với đường dẫn timestamp chuẩn hóa ({user_id}/avatar_{timestamp}.webp), và dọn dẹp file cũ. Xem @doc/architecture/backend-supabase-version-gating và @doc/architecture/quire-photo-upload-logic.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Khởi tạo package packages/media_storage độc lập
- [x] #2 Triển khai ImageCompressor hỗ trợ 4 preset (avatarPreset 1:1, momentPortraitPreset 4:5, momentSquarePreset 1:1, dreamAttachmentPreset)
- [x] #3 Triển khai StoragePathGenerator chuẩn hóa đường dẫn {user_id}/avatar_{timestamp}.webp
- [x] #4 Triển khai TheVoidStorageGuard chặn dữ liệu The Void lên cloud
- [x] #5 Triển khai MediaStorageAdapter và SupabaseMediaStorageAdapter kèm hàm dọn avatar cũ cleanupPreviousAvatars
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Đã triển khai hoàn chỉnh package packages/media_storage dùng chung cho Quire (Moments/Avatars) và Dream Journal (Dream Attachments). Đã có bộ unit test image_compressor_test.dart.
<!-- SECTION:NOTES:END -->

