---
id: DFA-C7N9HD
title: "[quire-auth-media-02] Tích hợp pipeline nén WebP, preview ảnh thật và hiển thị lên đầu feed Khoảnh khắc"
status: done
priority: high
labels:
  - from-spec
  - spec:quire-real-photo-acquisition-calm-authentication
  - spec-date:2026-10-14
  - quire
  - moments
createdAt: '2026-10-14T04:00:18.409Z'
updatedAt: '2026-10-14T04:05:09.811Z'
completedAt: '2026-10-14T04:05:09.767Z'
timeSpent: 136
assignee: '@me'
spec: specs/2026-10-14/quire-real-photo-acquisition-calm-authentication
fulfills:
  - AC-3
  - AC-4
order: 20
---
# [quire-auth-media-02] Tích hợp pipeline nén WebP, preview ảnh thật và hiển thị lên đầu feed Khoảnh khắc

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Nén ảnh thật vừa chọn bằng ImageCompressor (WebP 4:5), hiển thị thumbnail ảnh thật trên Compose Sheet, và đưa khoảnh khắc mới lên ngay đầu bảng tin sau khi hết 900ms hoàn tác.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Mở tùy chọn Chụp ảnh hoặc Chọn từ thư viện khi bấm + Của bạn
- [x] #2 Nén và hiển thị thumbnail ảnh thật trên QuireComposeSheet
- [x] #3 Tự động đưa khoảnh khắc ảnh thật vừa gửi lên đầu feed Khoảnh khắc để tương tác
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Cập nhật MomentsTabView với hộp thoại chọn nguồn ảnh (Camera/Gallery) dùng NativeCameraGalleryService.
2. Mở QuireComposeSheet với byte ảnh thật.
3. Nhận callback khi gửi thành công và chèn khoảnh khắc mới vào đầu danh sách _moments.
4. Hỗ trợ hiển thị Image.memory trong card khoảnh khắc.
5. Chạy test và validate task.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Đã cập nhật MomentsTabView mở hộp thoại chọn nguồn ảnh thật từ máy/thư viện hoặc chụp camera/webcam bằng NativeCameraGalleryService. Đã truyền byte ảnh thật vào QuireComposeSheet kèm callback onMomentDispatched. Khi gửi thành công, khoảnh khắc mới với ảnh thật và lời nhắn được tự động đưa ngay lên đầu bảng tin để xem và thả tim. flutter analyze 0 issues.
Spec Decision Compliance: D1=pass, D2=pass, D3=pass, D4=pass
System Decision Impact: none — tuân thủ quy trình nén media_storage có sẵn
<!-- SECTION:NOTES:END -->

