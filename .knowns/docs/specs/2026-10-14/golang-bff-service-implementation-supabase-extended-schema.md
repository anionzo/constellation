---
id: doc-649a9b7e9cf60c17080bdd94ba1a8c83
title: 'Golang BFF Service Implementation & Supabase Extended Schema'
description: Specification for Golang BFF Service Implementation and Supabase Extended Schema Migration for Constellation Quire
createdAt: '2026-10-14T09:25:07.096Z'
updatedAt: '2026-10-14T09:35:46.802Z'
tags:
  - spec
  - approved
  - backend
  - golang
  - bff
  - supabase
---

# Specification: Golang BFF Service Implementation & Supabase Extended Schema

## Overview

Bản đặc tả kỹ thuật triển khai dịch vụ Backend Golang BFF (Backend-for-Frontend) bọc ngoài Supabase, đóng vai trò là Business Logic Engine và API Gateway duy nhất phục vụ ứng dụng Quire và các ứng dụng tiếp theo trong Constellation. Dịch vụ này đóng cổng CSDL trực tiếp ra ngoài Internet, xác thực JWT tập trung, quản lý nghiệp vụ không giới hạn bạn bè, kiểm soát thời hạn tự hủy mềm (Soft-purge), phân trang con trỏ (Cursor-based Pagination), và cung cấp API phản hồi ảnh trích dẫn trong chat.

## Locked Decisions

- D1: Cấu trúc mã nguồn tuân thủ Standard Go Project Layout (cmd/server, internal/config, domain, handler, middleware, repository, storage). Module name: `constellation/backend/go_service`.
- D2: Tầng xác thực sử dụng JWT Middleware xác minh chữ ký HMAC-SHA256 bằng `JWT_SECRET` từ Supabase Auth (GoTrue), trích xuất `user_id` từ claim `sub` vào `context.Context` cho toàn bộ các handler nội bộ.
- D3: Nghiệp vụ bạn bè loại bỏ hoàn toàn trần cứng 12 người; nghiệp vụ khoảnh khắc áp dụng cơ chế tự hủy mềm (Soft-purge vào kho lưu trữ cá nhân kèm API khôi phục lên feed); nghiệp vụ bài viết hỗ trợ phạm vi 2 tầng (Public vs Circle-only).
- D4: Đóng gói dịch vụ bằng Docker Multi-stage build (Alpine / Scratch < 25MB), tích hợp vào `backend/supabase/docker-compose.yml` chạy trên cùng mạng nội bộ Docker với PostgreSQL và Kong.

## System Decision Impact

- Impact: none
- Decision: N/A
- Acceptance gate: Tuân thủ 100% tài liệu kiến trúc SSOT `@doc/architecture/backend-golang-bff-wrapper` và `@doc/architecture/backend-api-requirements-data-contract-derived-from-quire-client`.

## Requirements

### Functional Requirements

- **FR-1 (Go Service Scaffolding)**: Khởi tạo module `go.mod`, file cấu hình nạp biến môi trường (`.env` / config struct), router HTTP (chuẩn `net/http` hoặc lightweight Chi router) và điểm khởi chạy `cmd/server/main.go`.
- **FR-2 (Middleware Core)**: Triển khai các middleware: `AuthMiddleware` (xác thực Supabase JWT qua `JWT_SECRET`), `CorsMiddleware`, `LoggerMiddleware`, `RecoverMiddleware`.
- **FR-3 (Domain & Handlers)**:
  - `Auth & Profile Handler`: Lấy hồ sơ cá nhân (`GET /api/v1/profile/me`), cập nhật hồ sơ (`PUT /api/v1/profile/me`), lấy hồ sơ bạn bè (`GET /api/v1/profile/:username`).
  - `Circle & Invites Handler`: Danh sách bạn bè, tạo/đổi link mời kết bạn, danh sách lời mời nhận được, đồng ý/từ chối kết bạn, gỡ bạn khỏi vòng.
  - `Articles Handler`: Lấy bài viết (phân trang Cursor, lọc Public/Circle/Saved), xuất bản bài viết mới, thả tim, bookmark và bỏ lưu (`DELETE /api/v1/articles/:id/bookmark`).
  - `Moments Handler`: Bảng tin khoảnh khắc còn hiệu lực, đăng khoảnh khắc kèm thời hạn tự hủy, kho lưu trữ kỷ niệm riêng (`/api/v1/moments/archive`), khôi phục khoảnh khắc (`/api/v1/moments/:id/restore`), xóa vĩnh viễn.
  - `Chat Handler`: Hộp thư tập trung (`/api/v1/chat/inbox`), lịch sử tin nhắn 1-1, gửi tin nhắn có đính kèm ảnh trích dẫn (`quoted_moment_id`).
- **FR-4 (Cursor Pagination Standard)**: Toàn bộ API danh sách trả về phong bì chuẩn `Universal Paginated Envelope` với `next_cursor` và `has_more`.
- **FR-5 (Supabase Extended Migration)**: Viết script SQL `backend/supabase/migrations/02-quire-extended-schema.sql` bổ sung các bảng `chat_messages`, `circle_invites`, `circle_requests`, `saved_items`, các cột mới và composite index cho cursor pagination.
- **FR-6 (Docker Integration)**: Viết `Dockerfile` cho Go service và tích hợp container `bff` vào `backend/supabase/docker-compose.yml`.

### Non-Functional Requirements

- **NFR-1 (Security)**: Không bao giờ để lộ service_role secret hoặc public database port ra ngoài Internet mà không qua middleware xác thực.
- **NFR-2 (Performance)**: Phân trang con trỏ tận dụng Composite Index B-Tree đạt thời gian phản hồi < 50ms cho truy vấn feed.
- **NFR-3 (Lightweight Footprint)**: Image Docker Golang BFF sau build tối ưu < 30MB.

## Acceptance Criteria

- [x] **AC-1**: Cấu trúc module Golang BFF hoàn chỉnh và biên dịch thành công không có lỗi cú pháp.
- [x] **AC-2**: Middleware xác thực JWT chặn các request không có token hoặc token không hợp lệ (trả về 401 Unauthorized), và cho phép token hợp lệ đi qua kèm `userID` trong context.
- [x] **AC-3**: Toàn bộ các handler nghiệp vụ (Profile, Circle, Articles, Moments, Chat) được đăng ký trên router và tuân thủ 100% hợp đồng JSON request/response.
- [x] **AC-4**: Phân trang Cursor trả về phong bì chuẩn `{data: [...], pagination: {has_more, next_cursor, limit}}`.
- [x] **AC-5**: File migration `02-quire-extended-schema.sql` có cú pháp PostgreSQL 15 hoàn chỉnh, đầy đủ bảng, khóa ngoại, RLS và chỉ mục composite.
- [x] **AC-6**: File `Dockerfile` và `docker-compose.yml` cấu hình hoàn chỉnh cho service `bff`.

## Task Links

- @task-DFA-DZ8N53 — `[golang-bff-01] Mở rộng CSDL PostgreSQL với migration 02-quire-extended-schema.sql` [done]
- @task-DFA-04305S — `[golang-bff-02] Khởi tạo module Golang go_service, cấu hình và Middleware JWT xác thực` [done]
- @task-DFA-M1267Q — `[golang-bff-03] Xây dựng Domain Models, Repositories và Handlers nghiệp vụ` [done]
- @task-DFA-JHW64Y — `[golang-bff-04] Đóng gói Dockerfile multi-stage và tích hợp service bff vào docker-compose.yml` [done]
