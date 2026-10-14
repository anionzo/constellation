---
id: 20260924-1545-quy-t-nh-c-ng-ngh-flutter-dart-a-n-n-t-ng-l-u-tr-hybrid-local-first-sync-online-t-y-ch-n
title: 'Quyết định công nghệ: Flutter (Dart) đa nền tảng + Lưu trữ Hybrid Local-First & Sync Online tùy chọn'
status: draft
supersedes: []
supersededBy: []
tags:
  - legacy-memory-migration
sources:
  - '@memory/blhhrm'
relatedDocs: []
relatedTasks: []
verification: []
createdAt: '2026-09-24T15:45:13.884Z'
updatedAt: '2026-09-29T10:45:54.504Z'
---

## Context

Migrated through reviewed provenance from legacy Decision Memory @memory/blhhrm (layer project, prior status active).

## Decision

Quyết định kiến trúc cho giai đoạn triển khai (Implementation):
1. Ngôn ngữ & Framework: Flutter (Dart) đa nền tảng, xuất bản đồng thời cho Mobile (iOS, Android) và Web App từ một bộ mã nguồn duy nhất.
2. Chiến lược Lưu trữ: Hybrid Local-First. Mặc định lưu dữ liệu trực tiếp tại bộ nhớ cục bộ của máy (Local on-device: SQLite/Hive/Isar) đảm bảo chạy mượt offline, riêng tư và tốc độ phản hồi tức thì. Đồng thời hỗ trợ tùy chọn đồng bộ hóa lên cơ sở dữ liệu online của người dùng (User Online DB Sync) khi người dùng muốn đồng bộ dữ liệu giữa các thiết bị.

## Alternatives Considered

The legacy Memory record did not encode alternatives in the System Decision lifecycle.

## Consequences

This Decision remains draft until linked evidence is verified. The legacy record stays in default retrieval until this Decision becomes current accepted guidance.
