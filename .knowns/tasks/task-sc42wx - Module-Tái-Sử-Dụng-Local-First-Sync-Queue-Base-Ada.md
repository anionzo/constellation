---
id: sc42wx
title: 'Module Tái Sử Dụng: Local-First Sync Queue Base Adapter'
status: done
priority: medium
labels:
  - modular
  - reusable
  - client
  - local-first
createdAt: '2026-09-24T16:46:08.293Z'
updatedAt: '2026-09-24T16:52:05.461Z'
timeSpent: 0
order: 5
---
# Module Tái Sử Dụng: Local-First Sync Queue Base Adapter

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Tách module độc lập packages/core/local_sync: Interface trừu tượng cho lưu trữ ngoại tuyến SQLite/Drift và hàng đợi đồng bộ nền (pending_sync_queue) khi mất kết nối mạng. Xem @doc/architecture/modular-reusable-components.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Khởi tạo package packages/local_sync độc lập
- [x] #2 Triển khai SyncQueueItem hỗ trợ trạng thái pending, inProgress, completed, failed, deadLetter
- [x] #3 Triển khai LocalStoreAdapter interface và MemoryLocalStoreAdapter
- [x] #4 Triển khai SyncDispatcher với exponential backoff và random jitter
- [x] #5 Tích hợp Sync Lock ngắt đồng bộ khi ForceUpdate hoặc Maintenance được kích hoạt
- [x] #6 Triển khai TheVoidSyncGuard bảo vệ bất biến The Void
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Đã triển khai hoàn chỉnh package packages/local_sync trừu tượng hóa toàn bộ hàng đợi đồng bộ ngoại tuyến, hỗ trợ retry và ngắt đồng bộ theo tín hiệu VersionGate. Đã có bộ unit test sync_queue_test.dart.
<!-- SECTION:NOTES:END -->

