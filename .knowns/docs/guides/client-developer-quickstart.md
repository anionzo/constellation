---
title: Client Developer Quickstart — Cẩm nang khởi động nhanh cho lập trình viên Client
description: Hướng dẫn thiết lập môi trường Flutter SDK, kết nối 3 package lõi qua path dependency, kiểm thử đơn vị và checklist khởi tạo các app tiếp theo
createdAt: '2026-09-26T04:57:47.003Z'
updatedAt: '2026-09-26T04:57:47.003Z'
tags:
  - constellation
  - guides
  - client
  - flutter
  - quickstart
---

# Client Developer Quickstart — Cẩm nang khởi động nhanh cho lập trình viên Client

> Cẩm nang thực chiến tinh gọn hướng dẫn lập trình viên Flutter/Dart thiết lập môi trường, liên kết các package dùng chung, chạy kiểm thử và khởi tạo ứng dụng mới trong Constellation.

---

## 1. Yêu Cầu Môi Trường & Cấu Trúc Monorepo

Hệ thống mã nguồn client được tổ chức theo mô hình Monorepo thuần túy:

```text
├── apps/
│   ├── quire/                 # App mẫu: Quire (Private Moments & Editorial)
│   ├── dream_journal/         # (Dự kiến) App ghi nhật ký giấc mơ
│   ├── after_midnight/        # (Dự kiến) App không gian đêm tĩnh lặng
│   └── astraea/               # (Dự kiến) App chiêm nghiệm Tarot
└── packages/
    ├── version_gate/          # Kiểm tra SemVer & chống kẹt cache Web/PWA
    ├── media_storage/         # Nén ảnh WebP & dọn dẹp Storage
    └── local_sync/            # Hàng đợi ngoại tuyến & Dispatcher
```

- **Flutter SDK**: `>= 3.19.x` (Channel `stable`)
- **Dart SDK**: `>= 3.3.x < 4.0.0`
- Kiểm tra cài đặt:
  ```bash
  flutter --version
  dart --version
  ```

---

## 2. Kết Nối Package Dùng Chung (Path Dependency)

Toàn bộ package nội bộ liên kết qua đường dẫn tương đối (Path Dependency), không publish lên pub.dev:

Trong file `apps/<app_name>/pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  meta: ^1.11.0

  # Các package lõi dùng chung của Constellation
  version_gate:
    path: ../../packages/version_gate
  media_storage:
    path: ../../packages/media_storage
  local_sync:
    path: ../../packages/local_sync
```

Nạp dependencies:
```bash
# Nạp cho từng package
cd packages/version_gate && dart pub get
cd ../media_storage && dart pub get
cd ../local_sync && dart pub get

# Nạp cho app
cd ../../apps/quire && flutter pub get
```

---

## 3. Cấu Hình Biến Môi Trường Client

Tạo file cấu hình hoặc biến môi trường cho ứng dụng client (`apps/<app_name>/.env` hoặc Dart define):

```properties
# Điểm cuối Kong API Gateway (Local dev: port 8000; Production: domain HTTPS)
SUPABASE_URL=http://localhost:8000

# Public Anonymous Key (ANON_KEY ký bằng JWT_SECRET)
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

> **Quy tắc an toàn sống còn**:
> - Client **CHỈ ĐƯỢC PHÉP** sử dụng `ANON_KEY`.
> - **TUYỆT ĐỐI KHÔNG** đưa `SERVICE_ROLE_KEY` vào client code hay file assets của ứng dụng.

---

## 4. Lệnh Kiểm Thử Đơn Vị (Unit Test) & Khởi Chạy

### Chạy kiểm thử cho các package lõi:
```bash
# Test bộ phân tích SemVer & Version Gate
cd packages/version_gate && dart test

# Test chuỗi nén ảnh WebP & Storage Adapter
cd ../media_storage && dart test

# Test hàng đợi đồng bộ ngoại tuyến & Sync Guard
cd ../local_sync && dart test
```

### Chạy kiểm thử cho ứng dụng:
```bash
# Test State Machine 900ms Hoàn tác & Luồng gửi ảnh của Quire
cd apps/quire && flutter test
```

### Chạy ứng dụng trên môi trường Web:
```bash
cd apps/quire && flutter run -d chrome
```

---

## 5. Checklist Khởi Tạo 3 Ứng Dụng Tiếp Theo

Khi bắt đầu khởi tạo `apps/dream_journal`, `apps/after_midnight` hoặc `apps/astraea`:

1. **Khởi tạo độc lập**: Tạo thư mục mới trong `apps/<app_name>` với file `pubspec.yaml` độc lập.
2. **Khai báo package tối thiểu**: Chỉ import các package thực sự cần (`version_gate`, `local_sync`, `media_storage`).
3. **Bảo toàn thế giới thị giác riêng (Anti-Merge C-90)**:
   - Tuyệt đối **không copy** bảng màu, typography hay tokens của Quire sang app khác.
   - Mỗi app phải tự định nghĩa tokens và giao diện riêng khớp với trích xuất nguyên mẫu tại @doc/architecture/design-system-tokens.
4. **Bảo vệ ranh giới The Void (After Midnight)**:
   - Luôn sử dụng `TheVoidStorageGuard` và `TheVoidSyncGuard` để đảm bảo nội dung nhập vào The Void không bao giờ lưu đĩa hay phát sinh network request.
5. **Tuân thủ chuẩn Calm UX**:
   - Mặc định giữ im lặng, không thêm badge đếm thông báo đỏ, không popup giục giã retention.

---

## 6. Tham Chiếu Tài Liệu Liên Quan

- Kiến trúc Backend & Version Gating: @doc/architecture/backend-supabase-version-gating
- Ranh giới tái sử dụng & Nguyên lý SOLID: @doc/architecture/modular-reusable-components
- Logic State Machine mẫu Quire: @doc/architecture/quire-photo-upload-logic
- Hàng rào chống sáp nhập 4 app: @doc/constellation/c-90-cross-matrix
