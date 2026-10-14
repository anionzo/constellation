---
id: DFA-25QN1F
title: "[quire-hardening-03] Khởi tạo SyncDispatcher cấp ứng dụng và đăng ký handler replay upload_quire_moment"
status: done
priority: high
labels:
  - from-spec
  - spec:quire-client-hardening-invariants
  - spec-date:2026-10-13
  - quire
  - sync
createdAt: '2026-10-13T10:43:20.036Z'
updatedAt: '2026-10-13T11:09:08.637Z'
completedAt: '2026-10-13T11:09:08.587Z'
timeSpent: 59
assignee: '@me'
spec: specs/2026-10-13/quire-client-hardening-invariants
fulfills:
  - AC-5
order: 30
---
# [quire-hardening-03] Khởi tạo SyncDispatcher cấp ứng dụng và đăng ký handler replay upload_quire_moment

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Kết nối SyncDispatcher với LocalStoreAdapter và SyncLockListener; đăng ký action handler upload_quire_moment; kích hoạt xử lý hàng đợi tự động khi boot, resume và khi mạng phục hồi.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Bổ sung syncHandler vào QuireMomentUploader xử lý actionType upload_quire_moment
- [x] #2 Tạo DispatcherSyncLockBridge kết nối SyncDispatcher với VersionGateManager
- [x] #3 Khởi tạo SyncDispatcher cấp ứng dụng và kích hoạt dispatchPendingBatch khi boot và resume
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Bổ sung syncHandler vào QuireMomentUploader.
2. Tạo DispatcherSyncLockBridge trong main.dart.
3. Khởi tạo SyncDispatcher trong QuireApp, đăng ký handler upload_quire_moment và kết nối syncLock với VersionGateManager.
4. Kích hoạt replay khi boot và resume.
5. Chạy test và validate task.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Đã bổ sung handleReplaySync vào QuireMomentUploader để xử lý actionType upload_quire_moment. Đã tạo DispatcherSyncLockBridge liên kết khóa đồng bộ của SyncDispatcher với VersionGateManager. Khởi tạo SyncDispatcher cấp ứng dụng và kích hoạt dispatchPendingBatch tự động khi app boot và resume. Tests pass 100%.
Spec Decision Compliance: D1=pass, D2=pass, D3=pass, D4=pass
System Decision Impact: none — tuân thủ hợp đồng package local_sync có sẵn
<!-- SECTION:NOTES:END -->

