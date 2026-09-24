---
id: blhhrm
title: 'Quyết định công nghệ: Flutter (Dart) đa nền tảng + Lưu trữ Hybrid Local-First & Sync Online tùy chọn'
layer: project
category: decision
tags:
  - architecture
  - flutter
  - dart
  - database
  - local-first
  - sync
  - decision
createdAt: '2026-09-24T15:45:13.884Z'
updatedAt: '2026-09-24T15:45:13.884Z'
---

Quyết định kiến trúc cho giai đoạn triển khai (Implementation):
1. Ngôn ngữ & Framework: Flutter (Dart) đa nền tảng, xuất bản đồng thời cho Mobile (iOS, Android) và Web App từ một bộ mã nguồn duy nhất.
2. Chiến lược Lưu trữ: Hybrid Local-First. Mặc định lưu dữ liệu trực tiếp tại bộ nhớ cục bộ của máy (Local on-device: SQLite/Hive/Isar) đảm bảo chạy mượt offline, riêng tư và tốc độ phản hồi tức thì. Đồng thời hỗ trợ tùy chọn đồng bộ hóa lên cơ sở dữ liệu online của người dùng (User Online DB Sync) khi người dùng muốn đồng bộ dữ liệu giữa các thiết bị.
