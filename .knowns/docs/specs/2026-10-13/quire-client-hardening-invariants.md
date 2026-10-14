---
id: doc-79f050e92aaee5305383558ed0ca66d4
title: 'Quire Client Hardening & Invariants'
description: 'Specification for Quire Client Hardening: WCAG AA contrast, Version Gate lifecycle, SyncDispatcher offline replay, and Dual Theme system'
createdAt: '2026-10-13T10:42:01.592Z'
updatedAt: '2026-10-13T11:15:17.158Z'
tags:
  - spec
  - draft
  - review-required
---

# Specification: Quire Client Hardening & Invariants

## Overview

Bản đặc tả kỹ thuật nhằm hoàn thiện các ranh giới kiến trúc và khoảng cách (gaps) cốt lõi của ứng dụng Quire (`apps/quire`) trước khi mở rộng tính năng. Đợt triển khai này tập trung vào 4 trọng tâm: chuẩn hóa độ tương phản trợ năng WCAG AA cho nút Gửi, tích hợp `VersionGateManager` vào vòng đời ứng dụng với màn hình khóa cứng `ForceUpdateView`, kích hoạt động cơ đồng bộ nền ngoại tuyến `SyncDispatcher` với action handler `upload_quire_moment`, và kết nối hệ thống Theme Sáng / Tối (`QuireTokens`) hoàn chỉnh.

## Locked Decisions

- D1: Phạm vi tập trung vào Client Hardening & Invariants (Fix WCAG AA nút Gửi, wiring VersionGateManager vào lifecycle, kích hoạt SyncDispatcher offline replay, và wiring Dark Theme). Chưa mở rộng native camera hay live backend ngoài.
- D2: Khi VersionGate kích hoạt trạng thái `force_update` hoặc `maintenance`, Quire hiển thị màn hình khóa cứng toàn màn hình (`ForceUpdateView` / `MaintenanceView`) theo đúng design tokens của Quire, đồng thời ngắt đồng bộ nền qua `SyncLockListener`.
- D3: Quire hỗ trợ song song Theme Sáng (giấy ngà `#FBF9F5`) và Tối (than ấm `#1A1612`) sinh từ `QuireTokens`. Mặc định dùng `ThemeMode.system`, quản lý qua `ThemeController` (`ValueNotifier<ThemeMode>`) để cho phép chuyển đổi chủ động.
- D4: `SyncDispatcher` được khởi tạo tại cấp ứng dụng, đăng ký action handler `upload_quire_moment`, và kích hoạt replay khi boot ứng dụng, app resume, hoặc khi có kết nối mạng trở lại.

## System Decision Impact

- Impact: none
- Decision: N/A
- Acceptance gate: Toàn bộ thay đổi nằm trong phạm vi client Flutter `apps/quire`, tuân thủ 100% hợp đồng có sẵn của các core packages (`version_gate`, `local_sync`, `media_storage`).

## Requirements

### Functional Requirements

- **FR-1 (WCAG AA Contrast)**: Nút Gửi trong `QuireComposeSheet` phải dùng màu chữ trên nền accent theo đúng token thiết kế `--on-accent: #241E19` (hoặc biến thể tối ưu của QuireTokens) để đạt tỷ lệ tương phản ≥ 4.5:1 (chuẩn AA cho văn bản thông thường).
- **FR-2 (Touch Target)**: Các `FilterChip` chọn bạn bè trong `QuireComposeSheet` phải đảm bảo touch target tối thiểu 44x44px theo chuẩn a11y.
- **FR-3 (Version Gate Lifecycle)**: `VersionGateManager` phải được tích hợp vào `main.dart` / root widget, tự động kiểm tra phiên bản lúc khởi động (`boot`) và khi ứng dụng hoạt động trở lại từ background (`resume`).
- **FR-4 (Force Update UI)**: Khi `VersionGateManager` phát hiện phiên bản thấp hơn `min_supported_version` hoặc hệ thống đang bảo trì, ứng dụng phải chặn toàn bộ tương tác và hiển thị `ForceUpdateView` với giao diện tĩnh chuẩn Quire (font Newsreader, nền giấy/than ấm, thông báo và nút chuyển đến Store URL).
- **FR-5 (Offline Sync Dispatcher)**: `SyncDispatcher` phải được khởi tạo với `LocalStoreAdapter` và `SyncLockListener` kết nối với `VersionGateManager`. Đăng ký handler xử lý tác vụ `upload_quire_moment` để tự động đẩy lại các khoảnh khắc đang chờ (`pending`) khi có mạng.
- **FR-6 (Dual Theme System)**: Ứng dụng phải hỗ trợ cả hai bảng màu Light (`paperLight #FBF9F5`) và Dark (`paperDark #1A1612`), cấu hình đầy đủ `theme` và `darkTheme` trong `MaterialApp`, lắng nghe `ThemeController` và thay đổi mượt mà.

### Non-Functional Requirements

- **NFR-1 (The Void & Privacy Invariants)**: Dữ liệu thuộc The Void tuyệt đối không được phép đưa vào hàng đợi `SyncDispatcher` hoặc lưu vào storage (đã có Guard kiểm tra).
- **NFR-2 (Clean State Isolation)**: Không phá vỡ bất biến State Machine 900ms Undo hiện có trong `PhotoUploadStateMachine`.
- **NFR-3 (Test Coverage)**: Mọi module mới hoặc logic wiring phải có unit test đi kèm, chạy qua với `dart test`.

## Acceptance Criteria

- [x] **AC-1**: Nút Gửi khoảnh khắc trong `QuireComposeSheet` hiển thị màu chữ đạt tỷ lệ tương phản ≥ 4.5:1 (đo kiểm với nền `#E76136`).
- [x] **AC-2**: Touch target của `FilterChip` trong sheet soạn khoảnh khắc đạt kích thước tối thiểu 44px.
- [x] **AC-3**: `VersionGateManager` được khởi tạo và kích hoạt đánh giá phiên bản thành công khi ứng dụng khởi động.
- [x] **AC-4**: Khi `VersionGateManager` trả về `ForceUpdateStatus` hoặc `MaintenanceStatus`, giao diện chuyển sang `ForceUpdateView` toàn màn hình và `SyncDispatcher` chuyển sang trạng thái khóa (`isLocked == true`).
- [x] **AC-5**: `SyncDispatcher` đăng ký thành công handler `upload_quire_moment`. Khi gọi `dispatchPending()`, các item offline được xử lý tuần tự và xóa khỏi hàng đợi khi thành công.
- [x] **AC-6**: `QuireApp` cấu hình đủ `ThemeData` cho cả chế độ sáng và tối từ `QuireTokens`. Chuyển đổi giữa Light và Dark mode phản ánh đúng màu nền `paperLight` và `paperDark`.
- [x] **AC-7**: Toàn bộ unit tests của `apps/quire` và 3 packages chạy pass 100% không có lỗi.

## Scenarios

### Scenario 1: Khởi động app với phiên bản hết hạn (Force Update)
**Given** Hệ thống cấu hình `min_supported_version = '2.0.0'` và phiên bản app hiện tại là `'1.0.0'`
**When** Người dùng mở ứng dụng Quire
**Then** `VersionGateManager` trả về `ForceUpdateStatus`, ứng dụng hiển thị `ForceUpdateView` ngăn chặn truy cập, và hàng đợi `SyncDispatcher` bị khóa hoàn toàn.

### Scenario 2: Gửi khoảnh khắc khi ngoại tuyến và tự động đồng bộ khi có mạng
**Given** Thiết bị đang mất mạng và người dùng hoàn tất gửi 1 khoảnh khắc sau 900ms
**When** Khoảnh khắc được lưu vào offline queue với trạng thái `pending`
**And** Thiết bị có kết nối mạng trở lại và `SyncDispatcher` kích hoạt `dispatchPending()`
**Then** Handler `upload_quire_moment` được gọi, dữ liệu được gửi thành công, và item được dọn dẹp khỏi hàng đợi.

### Scenario 3: Chuyển đổi giao diện Sáng / Tối
**Given** Ứng dụng đang ở chế độ Sáng với nền `paperLight` (`#FBF9F5`)
**When** Hệ điều hành chuyển sang chế độ Dark Mode hoặc người dùng toggle qua `ThemeController`
**Then** Giao diện cập nhật sang nền `paperDark` (`#1A1612`), chữ chuyển sang dải ink tối, và thanh điều hướng hệ thống cập nhật màu sắc tương ứng.

## Technical Notes

- `apps/quire/pubspec.yaml` đã có dependency `version_gate`, `local_sync`, `media_storage`. Chỉ cần import và wiring.
- Cần bổ sung `onAccentLight` (`#241E19`) vào `QuireTokens` để chuẩn hóa token chữ trên nút accent sáng.
- Tạo widget `ForceUpdateView` tại `apps/quire/lib/src/presentation/views/force_update_view.dart`.
- Tạo `QuireTheme` helper để đóng gói `ThemeData.light()` và `ThemeData.dark()` đồng nhất.

## Task Links

- @task-DFA-9JFBXT — `[quire-hardening-01] Chuẩn hóa độ tương phản WCAG AA nút Gửi và touch target FilterChip` [done]
- @task-DFA-2T6SJK — `[quire-hardening-02] Tích hợp VersionGateManager vào vòng đời app và xây dựng màn hình ForceUpdateView` [done]
- @task-DFA-25QN1F — `[quire-hardening-03] Khởi tạo SyncDispatcher cấp ứng dụng và đăng ký handler replay upload_quire_moment` [done]
- @task-DFA-W1ZH6M — `[quire-hardening-04] Cấu hình hệ thống Theme kép Sáng/Tối (QuireTokens) và ThemeController cho MaterialApp` [done]
- @task-DFA-GG2JT0 — `[quire-hardening-05] Thẩm định tổng thể và bổ sung bộ Unit Test cho Quire Client Hardening` [done]

## Open Questions

Không còn câu hỏi mở nào tồn đọng sau Phase 0.
