---
id: ox8q0n
title: Cross-App Cursor Pagination and Infinite Scroll Standard
key: cross-app-cursor-pagination-and-infinite-scroll-standard
layer: project
category: convention
status: active
tags:
  - constellation
  - pagination
  - infinite-scroll
  - cross-app
createdAt: '2026-10-14T09:22:05.508Z'
updatedAt: '2026-10-14T09:22:05.508Z'
---

Chuẩn mực phân trang bắt buộc cho cả 4 ứng dụng Constellation (Quire, Dream Journal, Astraea, After Midnight): Sử dụng Cursor-based Pagination dựa trên con trỏ (created_at DESC, id DESC) thay vì offset-based để kháng trùng lặp khi có bản ghi mới. Response bọc trong phong bì chuẩn Universal Paginated Envelope {data: [...], pagination: {has_more, next_cursor, limit}}. CSDL tạo Composite Index giảm dần, phía Client dùng ScrollController với threshold 200px tải tăng dần và pull-to-refresh.
