---
id: DFA-9JFBXT
title: "[quire-hardening-01] Chuẩn hóa độ tương phản WCAG AA nút Gửi và touch target FilterChip"
status: done
priority: high
labels:
  - from-spec
  - spec:quire-client-hardening-invariants
  - spec-date:2026-10-13
  - quire
  - a11y
createdAt: '2026-10-13T10:43:19.941Z'
updatedAt: '2026-10-13T11:05:21.391Z'
completedAt: '2026-10-13T11:05:21.339Z'
timeSpent: 58
assignee: '@me'
spec: specs/2026-10-13/quire-client-hardening-invariants
fulfills:
  - AC-1
  - AC-2
order: 10
---
# [quire-hardening-01] Chuẩn hóa độ tương phản WCAG AA nút Gửi và touch target FilterChip

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Bổ sung token --on-accent (#241E19) vào QuireTokens, sửa màu chữ nhãn nút Gửi đạt tỷ lệ tương phản >= 4.5:1 (chuẩn AA) trên nền cam son #E76136, và tăng touch target của FilterChip chọn bạn bè lên >= 44px.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Bổ sung onAccentLight = Color(0xFF241E19) vào QuireTokens
- [x] #2 Cập nhật nhãn nút Gửi và icon trong QuireComposeSheet sử dụng onAccentLight thay Colors.white
- [x] #3 Tăng touch target của FilterChip trong wrap bạn bè lên tối thiểu 44px (visual density hoặc padding)
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Đọc và chỉnh sửa quire_tokens.dart: thêm onAccentLight (#241E19).
2. Chỉnh sửa quire_compose_sheet.dart: dùng onAccentLight cho text và icon của nút Gửi, đạt chuẩn AA (4.83:1).
3. Tăng touch target FilterChip đạt >= 44px.
4. Chạy dart test kiểm tra hiện trạng và validate task.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Đã bổ sung onAccentLight (#241E19) và onAccentDark (#1A1612) vào QuireTokens. Đã cập nhật QuireComposeSheet dùng onAccentLight cho nút Gửi (đạt tỉ lệ tương phản 4.83:1 >= 4.5:1 chuẩn AA) và tăng touch target FilterChip (padded + vertical 10.0 padding >= 44px). Tests pass 100%.
Spec Decision Compliance: D1=pass, D2=pass, D3=pass, D4=pass
System Decision Impact: none — chỉ chuẩn hóa token và giao diện UI theo design prototype có sẵn
<!-- SECTION:NOTES:END -->

