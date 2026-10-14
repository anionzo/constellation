---
id: DFA-2T6SJK
title: "[quire-hardening-02] Tích hợp VersionGateManager vào vòng đời app và xây dựng màn hình ForceUpdateView"
status: done
priority: high
labels:
  - from-spec
  - spec:quire-client-hardening-invariants
  - spec-date:2026-10-13
  - quire
  - version_gate
createdAt: '2026-10-13T10:43:20.002Z'
updatedAt: '2026-10-13T11:07:10.849Z'
completedAt: '2026-10-13T11:07:10.796Z'
timeSpent: 96
assignee: '@me'
spec: specs/2026-10-13/quire-client-hardening-invariants
fulfills:
  - AC-3
  - AC-4
order: 20
---
# [quire-hardening-02] Tích hợp VersionGateManager vào vòng đời app và xây dựng màn hình ForceUpdateView

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Import và kết nối version_gate vào main.dart lúc boot và resume; xây dựng màn hình khóa tĩnh ForceUpdateView (nền giấy ngà/than ấm, font Newsreader) và kết nối SyncLockListener ngắt sync khi có yêu cầu cập nhật hoặc bảo trì.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Tạo widget ForceUpdateView với phong cách Calm chuẩn QuireTokens
- [x] #2 Tích hợp VersionGateManager vào root của QuireApp lắng nghe boot và AppLifecycleState.resumed
- [x] #3 Chuyển sang ForceUpdateView toàn màn hình khi trạng thái là force_update hoặc maintenance
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Tạo file apps/quire/lib/src/presentation/views/force_update_view.dart theo design tokens.
2. Cập nhật main.dart để quản lý VersionGateManager và AppLifecycleListener/WidgetsBindingObserver.
3. Thử nghiệm đánh giá phiên bản lúc khởi động và khi app resume.
4. Chạy dart test và validate task.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Đã xây dựng ForceUpdateView tại apps/quire/lib/src/presentation/views/force_update_view.dart theo đúng phong cách Calm và token Quire. Đã tích hợp VersionGateManager vào QuireApp với WidgetsBindingObserver lắng nghe boot và resume. Tự động chuyển sang ForceUpdateView khi trạng thái là force_update hoặc maintenance. Tests pass 100%.
Spec Decision Compliance: D1=pass, D2=pass, D3=pass, D4=pass
System Decision Impact: none — tuân thủ hợp đồng package version_gate có sẵn
<!-- SECTION:NOTES:END -->

