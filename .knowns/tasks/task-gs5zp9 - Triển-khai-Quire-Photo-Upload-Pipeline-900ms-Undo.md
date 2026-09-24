---
id: gs5zp9
title: 'Triển khai Quire Photo Upload Pipeline & 900ms Undo State Machine'
status: done
priority: high
labels:
  - quire
  - client
  - photo-upload
  - state-machine
createdAt: '2026-09-24T16:46:21.960Z'
updatedAt: '2026-09-24T16:52:23.670Z'
timeSpent: 0
order: 6
---
# Triển khai Quire Photo Upload Pipeline & 900ms Undo State Machine

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Xây dựng luồng gửi ảnh khoảnh khắc hoàn chỉnh của Quire: Chụp ảnh/Thư viện, Compose Sheet chọn bạn bè (bắt buộc >= 1), khóa nút 'Đang gửi...', cửa sổ Hoàn tác 900ms ('Send cancelled. Nothing left the app.'), và đẩy ảnh lên quire-moments. Xem @doc/architecture/quire-photo-upload-logic.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Khởi tạo app/feature apps/quire
- [x] #2 Triển khai PhotoUploadStateMachine với đầy đủ các trạng thái
- [x] #3 Triển khai xử lý lỗi quyền Camera và 2 lối thoát (PermissionDeniedState)
- [x] #4 Ràng buộc chọn >= 1 bạn bè trong vòng 4-11 người mới kích hoạt nút gửi
- [x] #5 Khóa nút tức thì khi gửi (SendingState) để chống bấm đúp
- [x] #6 Cửa sổ Hoàn tác 900ms với nút 'Hoàn tác' hủy gửi và cam kết 'Không có gì rời khỏi ứng dụng'
- [x] #7 Đẩy ảnh lên bucket quire-moments và ghi DB quire_moments với thời hạn 30 ngày (expires_at)
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Đã triển khai hoàn chỉnh State Machine cho luồng gửi ảnh của Quire trong apps/quire. Đảm bảo đúng cam kết thiết kế của nguyên mẫu prototype.html và design-notes.md. Đã có bộ unit test photo_upload_state_machine_test.dart.
<!-- SECTION:NOTES:END -->

