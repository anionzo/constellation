---
id: DFA-W1ZH6M
title: "[quire-hardening-04] Cấu hình hệ thống Theme kép Sáng/Tối (QuireTokens) và ThemeController cho MaterialApp"
status: done
priority: medium
labels:
  - from-spec
  - spec:quire-client-hardening-invariants
  - spec-date:2026-10-13
  - quire
  - theme
createdAt: '2026-10-13T10:43:20.071Z'
updatedAt: '2026-10-13T11:10:14.817Z'
completedAt: '2026-10-13T11:10:14.773Z'
timeSpent: 41
assignee: '@me'
spec: specs/2026-10-13/quire-client-hardening-invariants
fulfills:
  - AC-6
order: 40
---
# [quire-hardening-04] Cấu hình hệ thống Theme kép Sáng/Tối (QuireTokens) và ThemeController cho MaterialApp

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Xây dựng helper QuireTheme tạo đầy đủ ThemeData cho Light và Dark mode từ QuireTokens; thiết lập ThemeController (ValueNotifier<ThemeMode>) và kết nối vào MaterialApp.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Xây dựng helper QuireTheme cung cấp ThemeData.light() và ThemeData.dark() chuẩn token
- [x] #2 Xây dựng ThemeController (ValueNotifier<ThemeMode>) hỗ trợ chuyển đổi chủ động
- [x] #3 Kết nối QuireTheme và ThemeController vào MaterialApp trong QuireApp
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Tạo file apps/quire/lib/src/presentation/theme/quire_theme.dart với ThemeData light/dark và ThemeController.
2. Cập nhật main.dart cấu hình theme, darkTheme và themeMode cho MaterialApp.
3. Kiểm tra chuyển đổi theme và overlay style.
4. Chạy test và validate task.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Đã xây dựng QuireTheme tại apps/quire/lib/src/presentation/theme/quire_theme.dart cung cấp ThemeData.light() (paperLight #FBF9F5) và ThemeData.dark() (paperDark #1A1612). Đã xây dựng ThemeController kế thừa ValueNotifier<ThemeMode>. Tích hợp đầy đủ vào MaterialApp trong QuireApp. Tests pass 100%.
Spec Decision Compliance: D1=pass, D2=pass, D3=pass, D4=pass
System Decision Impact: none — tuân thủ design tokens QuireTokens có sẵn
<!-- SECTION:NOTES:END -->

