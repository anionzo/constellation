---
id: 2obd7n
title: 'Module Tái Sử Dụng: Version Gate & Chống Kẹt Cache (SemVer)'
status: done
priority: high
labels:
  - modular
  - reusable
  - client
  - versioning
createdAt: '2026-09-24T16:45:31.077Z'
updatedAt: '2026-09-24T16:51:33.440Z'
timeSpent: 0
order: 3
---
# Module Tái Sử Dụng: Version Gate & Chống Kẹt Cache (SemVer)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Tách module độc lập packages/core/version_gate dùng chung cho toàn bộ app: Kiểm tra min_supported_version từ Supabase app_system_configs, so sánh SemVer, hiển thị màn hình khóa cứng ForceUpdateScreen khi app cũ, và cấu hình header chống cache Web/PWA. Xem @doc/architecture/backend-supabase-version-gating.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Khởi tạo package packages/version_gate độc lập
- [x] #2 Triển khai thuật toán so sánh SemVer 2.0.0 thuần Dart (semver.dart)
- [x] #3 Triển khai VersionGateManager lắng nghe boot và resume
- [x] #4 Triển khai ForceUpdateDelegate và giao diện khóa sync SyncLockListener
- [x] #5 Định nghĩa header Cache-Control no-cache, no-store cho Web/PWA và ServiceWorker listener
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Đã triển khai hoàn chỉnh package packages/version_gate dùng chung cho cả 4 app Constellation. Khi app phát hiện min_supported_version > current_version hoặc maintenance_mode = true, module tự động khóa động cơ sync và kích hoạt ForceUpdateScreen. Đã có bộ unit test semver_test.dart và version_gate_manager_test.dart.
<!-- SECTION:NOTES:END -->

