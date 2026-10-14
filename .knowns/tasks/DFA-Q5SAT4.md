---
id: DFA-Q5SAT4
title: "[quire-auth-media-03] Xây dựng màn hình đăng nhập CalmAuthView với Email OTP và Chế độ Khách"
status: done
priority: high
labels:
  - from-spec
  - spec:quire-real-photo-acquisition-calm-authentication
  - spec-date:2026-10-14
  - quire
  - auth
createdAt: '2026-10-14T04:00:18.469Z'
updatedAt: '2026-10-14T04:07:21.553Z'
completedAt: '2026-10-14T04:07:21.312Z'
timeSpent: 114
assignee: '@me'
spec: specs/2026-10-14/quire-real-photo-acquisition-calm-authentication
fulfills:
  - AC-5
  - AC-6
order: 30
---
# [quire-auth-media-03] Xây dựng màn hình đăng nhập CalmAuthView với Email OTP và Chế độ Khách

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Thiết kế màn hình đăng nhập tĩnh lặng chuẩn Calm: nhập email nhận mã OTP, kèm nút Trải nghiệm ngay (Chế độ Khách) để vào thẳng app, và hỗ trợ đăng xuất trong tab Bạn.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Xây dựng widget CalmAuthView hỗ trợ nhập Email OTP và nút Trải nghiệm ngay chế độ Khách
- [x] #2 Tích hợp luồng chuyển đổi trạng thái Auth vào QuireApp trong main.dart
- [x] #3 Hỗ trợ hiển thị thông tin tài khoản và nút Đăng xuất trong YouTabView
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Tạo file apps/quire/lib/src/presentation/views/calm_auth_view.dart.
2. Cập nhật YouTabView thêm nút Đăng xuất và hiển thị trạng thái tài khoản.
3. Cập nhật main.dart quản lý trạng thái Auth và chuyển đổi mượt mà giữa CalmAuthView và QuireHomeScreen.
4. Chạy flutter analyze và validate task.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Đã xây dựng CalmAuthView tại apps/quire/lib/src/presentation/views/calm_auth_view.dart hỗ trợ đăng nhập Email OTP và nút Trải nghiệm ngay chế độ Khách. Đã tích hợp luồng Auth vào QuireApp trong main.dart. Đã cập nhật YouTabView hiển thị email tài khoản hiện tại và nút Đăng xuất trở về CalmAuthView. flutter analyze 0 issues.
Spec Decision Compliance: D1=pass, D2=pass, D3=pass, D4=pass
System Decision Impact: none — tuân thủ thiết kế Calm Auth
<!-- SECTION:NOTES:END -->

