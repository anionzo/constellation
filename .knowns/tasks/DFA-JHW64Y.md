---
id: DFA-JHW64Y
title: "[golang-bff-04] Đóng gói Dockerfile multi-stage và tích hợp service bff vào docker-compose.yml"
status: done
priority: medium
labels:
  - from-spec
  - spec:golang-bff-service-implementation-supabase-extended-schema
  - spec-date:2026-10-14
  - backend
  - docker
  - compose
createdAt: '2026-10-14T09:25:38.761Z'
updatedAt: '2026-10-14T09:35:15.065Z'
completedAt: '2026-10-14T09:35:15.023Z'
timeSpent: 80
assignee: '@me'
spec: specs/2026-10-14/golang-bff-service-implementation-supabase-extended-schema
fulfills:
  - AC-6
order: 40
---
# [golang-bff-04] Đóng gói Dockerfile multi-stage và tích hợp service bff vào docker-compose.yml

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Viết Dockerfile multi-stage build tối ưu cho Go service và tích hợp service bff vào file docker-compose.yml kết nối mạng nội bộ Supabase.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Tạo Dockerfile multi-stage build cho Go service
- [x] #2 Cập nhật backend/supabase/docker-compose.yml bổ sung container bff
- [x] #3 Kiểm tra cú pháp docker compose config thành công
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Tạo backend/go_service/Dockerfile.
2. Cập nhật backend/supabase/docker-compose.yml.
3. Chạy docker compose config để xác thực cú pháp.
4. Validate task và cập nhật spec.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Đã tạo Dockerfile multi-stage build cho Go service (builder -> alpine:3.19 < 20MB); cập nhật backend/supabase/docker-compose.yml bổ sung service bff trên mạng supabase-net kết nối với Postgres và GoTrue; kiểm tra docker compose config hợp lệ exit code 0.
Spec Decision Compliance: D1=pass, D2=pass, D3=pass, D4=pass
System Decision Impact: none — tuân thủ kiến trúc Docker multi-stage
<!-- SECTION:NOTES:END -->

