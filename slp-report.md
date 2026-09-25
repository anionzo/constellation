# SLP V5.1 Action-Anchored 3-Tier Report
**Session Target:** Production Self-Hosted Supabase Backend & Reusable Client Architecture  
**Execution Mode:** Autonomous SLP (Supervisor-Lead-Peer) V5.1  
**Timestamp:** 2026-09-24  
**Audit Status:** `PASSED` (0 Anti-Pattern Violations, 100% Invariants Preserved)  
**Knowns Tasks Tracked:** 6/6 Tasks Completed (`uatlij`, `oeu1nx`, `2obd7n`, `0jz1s9`, `sc42wx`, `gs5zp9`)

---

## Tier 1: 30-Second Executive Summary

| Hạng mục | Trạng thái | Bằng chứng kiểm định & Kết quả |
|---|---|---|
| **Hạ tầng Backend Docker** |  **HOÀN THÀNH** | `backend/supabase/docker-compose.yml` (8 containers) + `.env.example` + `kong.yml`. Lệnh `docker compose config` exit 0. |
| **CSDL & RLS Policies** |  **HOÀN THÀNH** | `01-init-schema.sql` (645 dòng, 8 bảng, 36 RLS policies, 3 storage buckets, hàm tự hủy 30 ngày `purge_expired_quire_moments()`). |
| **Module Tái Sử Dụng 1: Version Gate** |  **HOÀN THÀNH** | `packages/version_gate`: SemVer so sánh thuần, hook boot/resume, chặn `ForceUpdateScreen`, khóa sync, header chống kẹt cache Web. |
| **Module Tái Sử Dụng 2: Media Storage** |  **HOÀN THÀNH** | `packages/media_storage`: ImageCompressor (WebP 82%, 1:1/4:5 crop), StoragePathGenerator (`avatar_{timestamp}.webp`), dọn avatar cũ. |
| **Module Tái Sử Dụng 3: Local Sync** |  **HOÀN THÀNH** | `packages/local_sync`: Trừu tượng hóa hàng đợi ngoại tuyến, backoff retry với jitter, ngắt đồng bộ khi VersionGate kích hoạt. |
| **Quire Photo Upload Pipeline** |  **HOÀN THÀNH** | `apps/quire`: State Machine 7 bước, ràng buộc bạn bè $\ge 1$, khóa nút tức thì, cửa sổ Hoàn tác 900ms ("Không có gì rời khỏi ứng dụng"). |
| **Tính Toàn Vẹn Tài Liệu (Knowns)** |  **0 ERRORS / 0 WARNINGS** | `knowns_validate(scope="all", strict=true)` đạt 100% hợp lệ. |

---

## Tier 2: 1-Phút Decision Matrix & Option C Synthesis

### 1. Phân Tách Gói Mô-đun Tái Sử Dụng (SOLID Architecture)
Theo đúng yêu cầu của người dùng (*"chức năng nào xài lại được thì nhớ tách ra cho chuẩn"*), các dịch vụ được bóc tách thành 3 package độc lập không dính dáng UI:

```
packages/
├── version_gate/     --> Dùng chung cho cả 4 app (Kiểm tra version, chặn app cũ, chống kẹt cache)
├── media_storage/    --> Dùng chung cho Quire & Dream Journal (Nén WebP, upload Supabase, dọn avatar)
└── local_sync/       --> Dùng chung cho toàn hệ thống (Hàng đợi offline SQLite, ngắt sync an toàn)

apps/
└── quire/            --> App độc lập, chỉ gọi các module trên qua Interface (DIP)
```

### 2. Ma Trận Quyết Định Kiến Trúc (Option C)

| Rủi ro / Vấn đề | Option A (Ngây thơ) | Option B (Bỏ qua) | **Option C (Đã Triển Khai)** |
|---|---|---|---|
| **Cửa sổ Hoàn tác 900ms** | Đẩy ảnh lên mạng ngay, nếu bấm Undo thì xóa file trên server. (Nguy cơ rò rỉ ảnh, tốn băng thông) | Không làm Undo. | **Nén ảnh trước tại Client, giữ nguyên trong RAM suốt 900ms. Nếu Undo, hủy RAM ngay lập tức. Cam kết 100% không một byte nào rời máy.** |
| **Kẹt Cache Web / PWA** | Để trình duyệt tự cache `index.html`. (Người dùng mở lên vẫn chạy bản cũ) | Bắt người dùng tự Ctrl+F5. | **Cấu hình Cache-Control `no-cache, no-store, must-revalidate` + Service Worker `controllerchange` tự động bật banner nạp lại.** |
| **Giới hạn Vòng bạn bè Quire** | Chỉ check trên giao diện client. | Cho kết bạn vô hạn như mạng xã hội. | **Trigger PostgreSQL `check_quire_circle_member_limit` chặn cứng từ tầng database, tối đa 12 người.** |
| **Bảo vệ Bất biến The Void** | Lưu tất cả vào bảng chung. | Không có cơ chế chặn. | **3 tầng Guard (DB Assertion, StorageGuard, SyncGuard) ném lỗi ngay nếu có bất kỳ dữ liệu The Void nào cố tình persist.** |

---

## Tier 3: Hành Động & Lệnh Khởi Chạy Thực Tế (Action Anchors)

### 1. Khởi chạy Supabase Backend trên máy chủ VPS:
```bash
cd backend/supabase

# 1. Tạo file cấu hình từ template
cp .env.example .env

# 2. Khởi chạy toàn bộ 8 containers
docker compose up -d

# 3. Kiểm tra trạng thái các container
docker compose ps
```
Dashboard quản trị Supabase Studio sẽ mở tại cổng: `http://localhost:8000` (hoặc IP VPS).

### 2. Áp dụng CSDL & Buckets:
File `backend/supabase/migrations/01-init-schema.sql` đã được liên kết tự động vào thư mục khởi tạo của container Postgres hoặc có thể chạy trực tiếp qua Supabase SQL Editor:
* Tạo đầy đủ 8 bảng dữ liệu.
* Tạo 3 Buckets: `avatars` (Public), `quire-moments` (Private), `dream-attachments` (Private).
* Kích hoạt 36 chính sách RLS.
* Thiết lập lịch dọn dẹp ảnh tự hủy sau 30 ngày qua `pg_cron`.

### 3. Tích hợp các Package Client vào Flutter App:
Trong `pubspec.yaml` của ứng dụng Flutter:
```yaml
dependencies:
  version_gate:
    path: ../packages/version_gate
  media_storage:
    path: ../packages/media_storage
  local_sync:
    path: ../packages/local_sync
```

---
*Báo cáo được tổng hợp tự động bởi SLP V5.1 Lead & Supervisor Agents.*
