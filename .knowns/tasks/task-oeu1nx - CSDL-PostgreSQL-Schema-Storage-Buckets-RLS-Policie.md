---
id: oeu1nx
title: 'CSDL PostgreSQL Schema, Storage Buckets & RLS Policies'
status: done
priority: high
labels:
  - backend
  - database
  - rls
  - sql
createdAt: '2026-09-24T16:45:11.097Z'
updatedAt: '2026-09-26T05:13:15.472Z'
timeSpent: 0
order: 2
---
# CSDL PostgreSQL Schema, Storage Buckets & RLS Policies

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Viết script SQL 01-init-schema.sql khởi tạo các bảng app_system_configs, profiles, quire_circles, quire_circle_members, quire_moments, quire_moment_recipients, dream_entries, dream_attachments. Tạo 3 storage buckets (avatars, quire-moments, dream-attachments), thiết lập Row-Level Security (RLS) và cấu hình pg_cron tự động dọn dẹp sau 30 ngày. Xem @doc/architecture/backend-supabase-version-gating và @doc/architecture/quire-photo-upload-logic.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Tạo bảng app_system_configs, profiles, quire_circles, quire_circle_members, quire_moments, quire_moment_recipients
- [x] #2 Tạo bảng dream_entries, dream_attachments
- [x] #3 Khởi tạo 3 storage buckets: avatars, quire-moments, dream-attachments
- [x] #4 Thiết lập 36 chính sách Row-Level Security (RLS) bảo vệ dữ liệu và file storage
- [x] #5 Thiết lập pg_cron và hàm purge_expired_quire_moments() tự hủy khoảnh khắc sau 30 ngày
- [x] #6 Loại bỏ trigger khóa cứng 12 bạn bè trong SQL, chuyển quyền quản lý sang Golang BFF
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Đã hoàn thành file migration backend/supabase/migrations/01-init-schema.sql chuẩn Postgres 15. Kích hoạt Row-Level Security trên toàn bộ 8 bảng dữ liệu và 3 bucket storage. Đảm bảo bất biến The Void (zero persistence), tự hủy sau 30 ngày. Đã loại bỏ trigger khóa cứng 12 bạn bè để tầng Golang BFF quản lý linh hoạt.
<!-- SECTION:NOTES:END -->

