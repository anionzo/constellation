---
title: S-02 Mẫu trích xuất prototype
description: 'Template trích xuất HTML prototype: bảng inventory màn hình, nhóm dữ liệu quan sát, quy tắc copy, tokens/a11y tham chiếu'
createdAt: '2026-09-19T07:53:26.791Z'
updatedAt: '2026-09-24T16:07:33.513Z'
tags:
  - constellation
  - template
---

# S-02 Mẫu trích xuất prototype

Dùng chung cho 4 app. Đếm màn từ HTML thực tế, không copy số trong readme một cách mù quáng (readme astraea ghi 18, comment prototype ghi 13–14 — đã flag).

## 1. Bảng inventory màn hình (cho `<app>-01`)

| Màn | Vào từ đâu | Ra tới đâu | Dữ liệu vào (quan sát) | Dữ liệu ra (quan sát) | Bị chặn khi nào | Rỗng / Tải / Lỗi / Khóa |
|---|---|---|---|---|---|---|

Cột điều kiện thời gian fold vào bảng (time-gate 00:00–05:00, nghi thức rút bài, vén 5 lớp, setting 4 tầng) — không tách doc temporal riêng.

## 2. Nhóm dữ liệu quan sát (cho `<app>-02`)

Liệt kê nhóm (vd "bài đọc tarot", "giấc mơ + mảnh ghép", "khoảnh khắc ảnh + người nhận") + vòng đời hiển thị quan sát được. Không tên field, không kiểu, không ràng buộc kỹ thuật.

## 3. Copy

- Chuỗi ngắn (CTA, empty/error text): trích toàn văn + file nguồn.
- Văn dài: 1–2 quote giọng văn + trỏ file. Không copy-paste hàng loạt (rủi ro encoding vỡ dấu đã thấy ở title After Midnight/Astraea).

## 4. Tokens / a11y / offline

- **Nguồn quan sát (SSOT)**: source prototype tại `designs/*` và commit/ngày đọc. README và `architecture/design-system-tokens` là tài liệu tổng hợp/derived, không thay thế source.
- App doc chỉ ghi rule/claim quan sát được và ghi rõ mức độ kiểm chứng: `đã quan sát`, `chưa kiểm độc lập` hoặc `DEFERRED`.
- Các con số contrast, font fallback, offline và accessibility không được gọi là production certification. Nếu prototype có 40px nhưng hợp đồng hệ thống là 44px, ghi rõ đây là **observed deviation** và cần audit/ADR, không tự hạ contract xuống 40px.
## 5. Failure-mode (cho `<app>-02`, 3–5 dòng)

Mỗi dòng: `ambiguity → hậu quả nếu implement đoán sai`. Không BLOCKER pipeline trừ khi Lead chỉ định.
