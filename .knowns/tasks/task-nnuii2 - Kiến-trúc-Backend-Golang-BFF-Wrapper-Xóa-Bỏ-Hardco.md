---
id: nnuii2
title: 'Kiến trúc Backend Golang BFF Wrapper & Xóa Bỏ Hardcode 12 Bạn Bè'
status: done
priority: high
labels:
  - backend
  - architecture
  - golang
  - bff
createdAt: '2026-09-26T05:13:48.186Z'
updatedAt: '2026-09-26T05:14:17.611Z'
timeSpent: 0
---
# Kiến trúc Backend Golang BFF Wrapper & Xóa Bỏ Hardcode 12 Bạn Bè

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Đặc tả kiến trúc dịch vụ Golang BFF đóng cổng DB công cộng, bọc ngoài Supabase, tập trung hóa logic nghiệp vụ, và loại bỏ hoàn toàn giới hạn cứng 12 bạn bè. Xem @doc/architecture/backend-golang-bff-wrapper.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Đặc tả kiến trúc phân tầng Golang BFF Service bọc ngoài Supabase
- [x] #2 Thiết kế middleware xác thực Supabase JWT bằng JWT_SECRET
- [x] #3 Loại bỏ triệt để trigger giới hạn 12 bạn bè trong PostgreSQL
- [x] #4 Đặc tả pipeline xử lý và tự hủy ảnh khoảnh khắc Quire Moments sau 30 ngày
- [x] #5 Đặc tả Version Gating endpoint và khả năng mở rộng NTP time server
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Đã hoàn thành tài liệu architecture/backend-golang-bff-wrapper và cập nhật migration loại bỏ trần cứng 12 bạn bè.
<!-- SECTION:NOTES:END -->

