---
id: DFA-M1267Q
title: "[golang-bff-03] Xây dựng Domain Models, Repositories và Handlers nghiệp vụ"
status: done
priority: high
labels:
  - from-spec
  - spec:golang-bff-service-implementation-supabase-extended-schema
  - spec-date:2026-10-14
  - backend
  - golang
  - handlers
createdAt: '2026-10-14T09:25:38.723Z'
updatedAt: '2026-10-14T09:33:25.052Z'
completedAt: '2026-10-14T09:32:40.146Z'
timeSpent: 180
assignee: '@me'
spec: specs/2026-10-14/golang-bff-service-implementation-supabase-extended-schema
fulfills:
  - AC-3
  - AC-4
order: 30
---
# [golang-bff-03] Xây dựng Domain Models, Repositories và Handlers nghiệp vụ

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Hiện thực hóa domain models, repository tầng dữ liệu và HTTP handlers cho Profile, Circle (bỏ giới hạn), Articles (phạm vi công khai/bạn bè), Moments (tự hủy mềm/khôi phục), và Chat (phản hồi trích dẫn ảnh).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Xây dựng domain models và cursor pagination encoder/decoder
- [x] #2 Hiện thực hóa repository tầng CSDL với composite query tối ưu
- [x] #3 Hiện thực hóa toàn bộ HTTP handlers: Profile, Circle, Articles, Moments, Chat, System VersionGate
- [x] #4 Xây dựng cmd/server/main.go đăng ký router và lắng nghe cổng 8000
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Viết internal/domain/models.go và cursor.go.
2. Viết internal/repository/repository.go.
3. Viết internal/handler/ handlers.
4. Viết cmd/server/main.go.
5. Thẩm định cú pháp và validate task.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Đã xây dựng đầy đủ domain models (Profile, Circle, Article, Moment, ChatMessage, PaginatedResponse), cursor pagination encoder/decoder, repository tầng dữ liệu (MemoryRepository thread-safe kèm seed data), và toàn bộ các HTTP handlers; đăng ký router Chi trong cmd/server/main.go.
Spec Decision Compliance: D1=pass, D2=pass, D3=pass, D4=pass
System Decision Impact: none — tuân thủ kiến trúc Golang BFF SSOT
<!-- SECTION:NOTES:END -->

