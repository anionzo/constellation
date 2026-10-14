---
id: doc-09d023ff349bd59e15ccd5fe31308934
title: 'Quire Real Photo Acquisition & Calm Authentication'
description: Specification for Real Photo Acquisition via image_picker and Calm Authentication with Guest Mode in Quire
createdAt: '2026-10-14T03:58:24.828Z'
updatedAt: '2026-10-14T04:09:59.478Z'
tags:
  - spec
  - approved
---

# Specification: Quire Real Photo Acquisition & Calm Authentication

## Overview

Bản đặc tả kỹ thuật nhằm hoàn thiện hai năng lực cốt lõi đưa ứng dụng Quire từ mức nguyên mẫu tĩnh sang ứng dụng thực chiến: (1) Cung cấp khả năng chọn tệp ảnh thật và chụp từ máy ảnh/webcam thiết bị thông qua `image_picker`, tích hợp vào chuỗi nén WebP của `media_storage` và hiển thị tác phẩm ngay trên bảng tin Khoảnh khắc; (2) Xây dựng luồng xác thực đăng nhập theo phong cách Calm Auth (Email OTP và nút Trải nghiệm ngay chế độ Khách) giữ trọn vẹn triết lý tĩnh lặng, không spam mật khẩu.

## Locked Decisions

- D1: Ưu tiên triển khai luồng Chụp & Tải ảnh thật từ thiết bị trước để người dùng có thể đưa ảnh thật của chính mình vào quy trình nén WebP và gửi khoảnh khắc ngay lập tức, tiếp theo là luồng Đăng nhập.
- D2: Tích hợp package chính thống `image_picker` vào `CameraGalleryService`, hỗ trợ chọn ảnh từ thư viện (`pickFromGallery`) và chụp từ camera (`capturePhoto`) mượt mà trên cả Web và Mobile.
- D3: Khi hoàn tất gửi ảnh (hết 900ms Undo), khoảnh khắc mới với ảnh thật và lời nhắn của người dùng sẽ được đưa ngay lên đầu bảng tin Khoảnh khắc (`MomentsTabView`) để xem, thả tim và thưởng thức ngay lập tức.
- D4: Thiết kế luồng Đăng nhập theo phong cách Calm Auth: Cho phép đăng nhập qua Email OTP / Magic Link, đồng thời cung cấp nút 'Trải nghiệm ngay' (Chế độ Khách / Guest Mode) để vào thẳng ứng dụng mà không bị rào cản.

## System Decision Impact

- Impact: none
- Decision: N/A
- Acceptance gate: Mọi sửa đổi tuân thủ hợp đồng package `media_storage`, `local_sync`, và kiến trúc bảo mật đã định nghĩa.

## Requirements

### Functional Requirements

- **FR-1 (Real Photo Picker)**: Tích hợp `image_picker` vào `apps/quire/pubspec.yaml`. Triển khai `NativeCameraGalleryService` thay thế stub cũ, cho phép người dùng mở hộp thoại chọn tệp ảnh thật (`.jpg`, `.png`, `.webp`) hoặc chụp từ camera/webcam.
- **FR-2 (Pipeline Nén & Preview Ảnh Thật)**: Khi người dùng chọn được ảnh từ máy, mảng byte ảnh thật được chuyển vào `ImageCompressor` để nén WebP (tỷ lệ 4:5), đồng thời cập nhật thumbnail xem trước trong `QuireComposeSheet` với ảnh thật của người dùng.
- **FR-3 (Feed Injection Sau Khi Gửi)**: Khi gửi khoảnh khắc thành công sau cửa sổ 900ms, khoảnh khắc mới cùng ảnh vừa chọn và lời nhắn phải được đẩy trực tiếp lên đầu danh sách feed của `MomentsTabView`.
- **FR-4 (Calm Auth Screen)**: Xây dựng màn hình đăng nhập `CalmAuthView` theo phong cách giấy ngà / than ấm, gồm: ô nhập Email, nút 'Gửi mã xác nhận', và nút 'Trải nghiệm chế độ Khách' (Guest Mode) để người dùng có thể tự do trải nghiệm mà không bị ép buộc đăng nhập.
- **FR-5 (Auth State Management)**: Quản lý trạng thái đăng nhập (Khách vs Đã đăng nhập email), hiển thị tên/email trong Tab `Bạn`, và cho phép 'Đăng xuất' trở về màn hình đăng nhập khi muốn.

### Non-Functional Requirements

- **NFR-1 (Graceful Fallback)**: Nếu người dùng hủy chọn ảnh trong hộp thoại file dialog, app phải giữ trạng thái an toàn không bị crash hoặc treo sheet.
- **NFR-2 (Web & Mobile Interoperability)**: `image_picker` hoạt động đồng nhất trên cả Web (qua `image_picker_for_web`) và Mobile Native.

## Acceptance Criteria

- [x] **AC-1**: Bấm vào nút `+ Của bạn` trên bảng tin Khoảnh khắc mở ra tùy chọn Chọn ảnh từ máy hoặc Chụp ảnh.
- [x] **AC-2**: Hộp thoại chọn tệp của hệ điều hành/trình duyệt mở ra, cho phép chọn ảnh thật từ máy tính/điện thoại.
- [x] **AC-3**: Ảnh thật sau khi chọn được hiển thị rõ nét trên ô xem trước (thumbnail) của sheet soạn khoảnh khắc kèm dung lượng đã nén.
- [x] **AC-4**: Bấm Gửi và sau 900ms không bấm Hoàn tác: khoảnh khắc ảnh thật vừa chọn xuất hiện ngay trên đầu bảng tin Khoảnh khắc, có thể bấm Thả tim.
- [x] **AC-5**: Màn hình Calm Auth hiển thị thanh nhã, hỗ trợ nhập email và có nút 'Trải nghiệm ngay' (Guest Mode) chuyển mượt mà vào giao diện chính.
- [x] **AC-6**: Trong Tab `Bạn`, hiển thị trạng thái tài khoản hiện tại kèm nút 'Đăng xuất' / 'Đổi tài khoản'.
- [x] **AC-7**: Toàn bộ unit tests và flutter analyze đạt kết quả 100% pass, 0 errors, 0 warnings.

## Scenarios

### Scenario 1: Người dùng chọn ảnh thật từ máy tính và gửi khoảnh khắc
**Given** Người dùng đang ở tab Khoảnh khắc
**When** Bấm vào avatar `+ Của bạn` và chọn một tệp ảnh thật từ máy
**Then** Khung soạn khoảnh khắc hiện thumbnail ảnh thật, chọn bạn bè `Mai`, bấm Gửi
**And** Sau 900ms thanh tiến trình kết thúc, tấm ảnh thật của người dùng xuất hiện trên đầu feed Khoảnh khắc.

### Scenario 2: Trải nghiệm ứng dụng với chế độ Khách (Guest Mode)
**Given** Ứng dụng mở lần đầu ở màn hình Đăng nhập Calm Auth
**When** Người dùng chọn 'Trải nghiệm ngay (Chế độ Khách)'
**Then** Ứng dụng lập tức chuyển vào giao diện 4 Tab mà không yêu cầu nhập thông tin, trong tab 'Bạn' hiển thị danh xưng Khách.

## Technical Notes

- Bổ sung `image_picker: ^1.1.2` vào `apps/quire/pubspec.yaml`.
- Viết `NativeCameraGalleryService` kế thừa `CameraGalleryService` sử dụng `ImagePicker().pickImage(...)`.
- Xây dựng `CalmAuthView` tại `apps/quire/lib/src/presentation/views/calm_auth_view.dart`.

## Task Links

- @task-DFA-REHBNJ — `[quire-auth-media-01] Tích hợp image_picker và xây dựng NativeCameraGalleryService cho ảnh thật` [done]
- @task-DFA-C7N9HD — `[quire-auth-media-02] Tích hợp pipeline nén WebP, preview ảnh thật và hiển thị lên đầu feed Khoảnh khắc` [done]
- @task-DFA-Q5SAT4 — `[quire-auth-media-03] Xây dựng màn hình đăng nhập CalmAuthView với Email OTP và Chế độ Khách` [done]
- @task-DFA-GYPHZQ — `[quire-auth-media-04] Bổ sung unit tests và thẩm định toàn diện cho luồng Photo & Auth` [done]

## Open Questions

Không còn câu hỏi mở nào tồn đọng.
