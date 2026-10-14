---
id: DFA-DZ8N53
title: "[golang-bff-01] Mở rộng CSDL PostgreSQL với migration 02-quire-extended-schema.sql"
status: done
priority: high
labels:
  - from-spec
  - spec:golang-bff-service-implementation-supabase-extended-schema
  - spec-date:2026-10-14
  - backend
  - sql
  - migration
createdAt: '2026-10-14T09:25:38.633Z'
updatedAt: '2026-10-14T09:27:10.296Z'
completedAt: '2026-10-14T09:27:10.258Z'
timeSpent: 59
assignee: '@me'
spec: specs/2026-10-14/golang-bff-service-implementation-supabase-extended-schema
fulfills:
  - AC-5
order: 10
---
# [golang-bff-01] Mở rộng CSDL PostgreSQL với migration 02-quire-extended-schema.sql

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Viết script migration backend/supabase/migrations/02-quire-extended-schema.sql khởi tạo các bảng chat_messages, circle_invites, circle_requests, saved_items, bổ sung cột mới cho articles/moments/profiles, kích hoạt RLS và composite index cho phân trang cursor.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Tạo file migration backend/supabase/migrations/02-quire-extended-schema.sql
- [x] #2 Bổ sung các bảng chat_messages, circle_invites, circle_requests, saved_items
- [x] #3 Tạo chỉ mục composite B-Tree (created_at DESC, id DESC) cho Cursor-based Pagination
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Đọc migration 01 hiện tại để đối chiếu cấu trúc.
2. Viết file migration 02-quire-extended-schema.sql chuẩn PostgreSQL 15.
3. Kích hoạt RLS và thiết lập chính sách bảo mật cho các bảng mới.
4. Thẩm định cú pháp SQL và validate task.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Đã tạo file migration backend/supabase/migrations/02-quire-extended-schema.sql chuẩn PostgreSQL 15, mở rộng bảng profiles, articles, moments; tạo các bảng circle_invites, circle_requests, saved_items, chat_messages; thiết lập Composite Indexes B-Tree cho Cursor Pagination và cấu hình RLS đầy đủ.
Spec Decision Compliance: D1=pass, D2=pass, D3=pass, D4=pass
System Decision Impact: none — mở rộng schema theo đặc tả kiến trúc
<!-- SECTION:NOTES:END -->

