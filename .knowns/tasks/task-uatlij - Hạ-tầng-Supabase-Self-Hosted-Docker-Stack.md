---
id: uatlij
title: Hạ tầng Supabase Self-Hosted Docker Stack
status: done
priority: high
labels:
  - backend
  - docker
  - supabase
createdAt: '2026-09-24T16:44:55.428Z'
updatedAt: '2026-09-24T16:51:03.426Z'
timeSpent: 0
order: 1
---
# Hạ tầng Supabase Self-Hosted Docker Stack

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Thiết lập thư mục docker/supabase với docker-compose.yml hoàn chỉnh (Postgres 15, Kong, GoTrue, PostgREST, Realtime, Storage, Studio) và file .env.example chuẩn bảo mật. Xem @doc/architecture/backend-supabase-version-gating.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Khởi tạo backend/supabase/docker-compose.yml đầy đủ 8 services
- [x] #2 Khởi tạo backend/supabase/.env.example với cấu hình bảo mật
- [x] #3 Cấu hình API Gateway Kong (kong.yml)
- [x] #4 Xác thực cú pháp docker compose config thành công
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Hoàn tất triển khai Supabase Self-Hosted Docker Compose stack với 8 container: db (Postgres 15), kong (API Gateway), auth (GoTrue), rest (PostgREST), realtime, storage, meta, studio. Đã kiểm tra cú pháp thành công với lệnh: docker compose --env-file backend/supabase/.env.example -f backend/supabase/docker-compose.yml config --quiet (exit code 0).
<!-- SECTION:NOTES:END -->

