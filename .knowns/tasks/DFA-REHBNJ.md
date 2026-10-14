---
id: DFA-REHBNJ
title: "[quire-auth-media-01] Tích hợp image_picker và xây dựng NativeCameraGalleryService cho ảnh thật"
status: done
priority: high
labels:
  - from-spec
  - spec:quire-real-photo-acquisition-calm-authentication
  - spec-date:2026-10-14
  - quire
  - media
createdAt: '2026-10-14T04:00:18.354Z'
updatedAt: '2026-10-14T04:02:35.983Z'
completedAt: '2026-10-14T04:02:35.916Z'
timeSpent: 115
assignee: '@me'
spec: specs/2026-10-14/quire-real-photo-acquisition-calm-authentication
fulfills:
  - AC-1
  - AC-2
order: 10
---
# [quire-auth-media-01] Tích hợp image_picker và xây dựng NativeCameraGalleryService cho ảnh thật

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Thêm dependency image_picker vào pubspec.yaml, hiện thực hóa NativeCameraGalleryService cho phép mở hộp thoại chọn tệp ảnh thật hoặc chụp camera trên cả Web và Mobile.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Thêm image_picker vào apps/quire/pubspec.yaml và chạy flutter pub get thành công
- [x] #2 Triển khai NativeCameraGalleryService kế thừa CameraGalleryService sử dụng ImagePicker
- [x] #3 Hỗ trợ pickFromGallery và capturePhoto trả về RawPhotoFile từ tệp ảnh thật
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Thêm image_picker vào pubspec.yaml.
2. Chạy flutter pub get.
3. Cập nhật camera_gallery_service.dart với NativeCameraGalleryService.
4. Chạy flutter analyze và validate task.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Đã thêm dependency image_picker: ^1.1.2 vào apps/quire/pubspec.yaml và chạy flutter pub get thành công. Đã triển khai NativeCameraGalleryService kết nối với ImagePicker hỗ trợ pickFromGallery và capturePhoto trả về RawPhotoFile từ tệp ảnh thật trên cả Web và Mobile. flutter analyze 0 issues.
Spec Decision Compliance: D1=pass, D2=pass, D3=pass, D4=pass
System Decision Impact: none — tuân thủ interface CameraGalleryService có sẵn
<!-- SECTION:NOTES:END -->

