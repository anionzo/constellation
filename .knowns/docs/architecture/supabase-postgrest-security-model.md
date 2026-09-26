---
title: 'Supabase PostgREST & Database-as-Backend Security Model — Cơ Chế Tự Động Sinh API, Row-Level Security (RLS) & Mô Hình Bảo Mật Toàn Diện'
description: 'Giải mã chuyên sâu kiến trúc Database-as-the-Backend với Supabase Self-Hosted: Cơ chế PostgREST tự sinh REST API, mô hình 2 khóa anon/service_role, bảo mật hạt nhân RLS, triggers nghiệp vụ và ma trận phòng thủ.'
createdAt: '2026-09-26T05:01:55.517Z'
updatedAt: '2026-09-26T05:09:39.083Z'
tags:
  - constellation
  - architecture
  - backend
  - supabase
  - postgrest
  - rls
  - security
---

# Architecture: Supabase PostgREST & Database-as-Backend Security Model — Cơ Chế Tự Động Sinh API, Row-Level Security (RLS) & Mô Hình Bảo Mật Toàn Diện

> **Tài liệu tham chiếu SSOT**: Giải mã toàn diện kiến trúc **Database-as-the-Backend** (Thick Database, Thin Client). Trả lời chi tiết thắc mắc cốt lõi: *"Tại sao không cần viết backend CRUD bằng code tay (Node.js/Go/Java) mà hệ thống vẫn chạy được, cực nhanh và bảo mật tuyệt đối?"*

---

## 1. Trực Giác Kỹ Thuật: "Thật hả? Backend chơi vậy được á?"

### 1.1. Nỗi Đau Của Mô Hình Backend Truyền Thống (The "Boilerplate Tax")
Trong hơn 15 năm qua, hầu hết các hệ thống web/mobile đều đi theo mô hình 3 tầng (Three-Tier Architecture):
```text
Client (App/Web)  --->  Backend API (Node.js/Go/Java/Python)  --->  Database (PostgreSQL)
```
Trong mô hình này, **hơn 80% thời gian của lập trình viên backend bị lãng phí vào các tác vụ lặp đi lặp lại vô nghĩa (CRUD Boilerplate)**:
1. Viết Controller định tuyến HTTP route (`/api/v1/moments`).
2. Viết DTO / Schema Validator để kiểm tra kiểu dữ liệu đầu vào.
3. Viết Middleware giải mã JWT token để lấy `user_id`.
4. Viết Service Layer kiểm tra quyền hạn (Authorization check: *"User này có phải bạn của người đăng không?"*).
5. Viết ORM query (Prisma, TypeORM, Hibernate) để SELECT/INSERT dữ liệu.
6. Serialize kết quả thành JSON rồi trả về client.

**Hậu quả lớn nhất**: Lỗ hổng bảo mật luôn xuất hiện ở tầng Service Layer do con người sơ suất (bỏ quên `WHERE user_id = current_user`, quên kiểm tra quyền truy cập tài nguyên - IDOR Vulnerability, Broken Object Level Authorization).

### 1.2. Bước Nhảy Vọt Của "Database-as-the-Backend"
Thay vì viết một lớp API trung gian thủ công, Supabase tích hợp **PostgREST** — một dịch vụ web độc lập viết bằng ngôn ngữ **Haskell**, hoạt động theo triết lý:
> **"Cơ sở dữ liệu quan hệ của bạn ĐÃ LÀ một RESTful API hoàn chỉnh và an toàn."**

PostgREST đọc trực tiếp bảng biểu và schema từ PostgreSQL, tự động sinh ra toàn bộ RESTful API chuẩn mực (GET, POST, PATCH, DELETE, RPC) với các tính năng lọc (`?circle_id=eq.abc`), phân trang (`?limit=10&offset=0`), sắp xếp (`?order=created_at.desc`), và nhúng quan hệ (nested JSON).

**Đặc biệt: PostgREST không lưu trữ trạng thái (Stateless) và không có logic phân quyền riêng. Nó trao toàn bộ quyền kiểm soát bảo mật cho Row-Level Security (RLS) của chính PostgreSQL.**

---

## 2. Toàn Cảnh Luồng Dữ Liệu: Từ Client Đến Nhân PostgreSQL

```mermaid
sequenceDiagram
    autonumber
    actor User as Client (Flutter App)
    participant Kong as Kong API Gateway (:8000)
    participant GoTrue as GoTrue Auth (:9999)
    participant PostgREST as PostgREST (:3000)
    participant PG as PostgreSQL 15 Engine (:5432)

    Note over User,GoTrue: Bước 1: Đăng nhập & Cấp phát JWT
    User->>Kong: POST /auth/v1/token (Email/Password hoặc OTP)
    Kong->>GoTrue: Chuyển tiếp yêu cầu xác thực
    GoTrue->>PG: Xác thực bảng auth.users & sinh Access Token
    GoTrue-->>User: Trả JWT mang claims: { sub: user_uuid, role: "authenticated" }

    Note over User,PG: Bước 2: Gọi dữ liệu qua PostgREST
    User->>Kong: GET /rest/v1/quire_moments?circle_id=eq.abc<br>Headers: Authorization: Bearer <JWT>
    Kong->>PostgREST: Kiểm tra sơ bộ & Forward request
    Note over PostgREST,PG: Bước 3: PostgREST biên dịch HTTP thành SQL duy nhất
    PostgREST->>PG: Mở Transaction an toàn:<br>1. SET LOCAL ROLE authenticated;<br>2. SET LOCAL "request.jwt.claim.sub" = 'user_uuid';<br>3. Chạy SQL + Tự động ép điều kiện RLS
    PG->>PG: Bộ lọc RLS chặn mọi dòng ngoài quyền hạn<br>Triggers kiểm tra giới hạn nghiệp vụ
    PG-->>PostgREST: Trả về kết quả JSON nén (json_agg)
    PostgREST-->>Kong: Trả HTTP 200 OK + Payload JSON
    Kong-->>User: Render giao diện tức thì (< 15ms)
```

---

## 3. Kiến Trúc Token Bảo Mật & Vòng Đời Phiên (Token Lifecycle & Security Spec)

### 3.1. Phân Loại 3 Dạng Token Trong Hệ Thống

```text
                          ┌─── 1. ANON_KEY (Cố định, Public): Nhúng trong Client App (Flutter/Web)
                          │    Payload: { "role": "anon", "iss": "supabase" }
CÁC LOẠI TOKEN            │
TRONG HỆ THỐNG ───────────┼─── 2. SERVICE_ROLE_KEY (Cố định, Secret): CHỈ NẰM TRÊN VPS (.env)
                          │    Payload: { "role": "service_role" } -> BYPASS HOÀN TOÀN RLS!
                          │
                          └─── 3. USER TOKENS (Động, sinh ra khi đăng nhập):
                               ├─ Access Token (JWT ngắn hạn: sống 1 giờ / 3600s)
                               └─ Refresh Token (Opaque string dài hạn, xoay vòng liên tục)
```

### 3.2. Cấu Trúc Chi Tiết Của User `access_token` (JWT Payload)

Khi người dùng đăng nhập thành công qua GoTrue (`POST /auth/v1/token`), GoTrue ký một JWT bằng thuật toán **HMAC-SHA256 (`HS256`)** với khóa bí mật `JWT_SECRET` (tối thiểu 32 ký tự ngẫu nhiên) trên VPS:

```json
{
  "iss": "supabase",
  "sub": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "aud": "authenticated",
  "role": "authenticated",
  "email": "user@example.com",
  "exp": 1727202000,
  "iat": 1727198400,
  "app_metadata": {
    "provider": "email"
  },
  "user_metadata": {
    "display_name": "Mai",
    "avatar_url": "avatars/3fa85f64.../avatar_1727198400000.webp"
  }
}
```

- **Trường `sub` (Subject)**: Mang UUID của người dùng, liên kết 1:1 với `auth.users.id` và `public.profiles.id`.
- **Trường `exp` (Expiry)**: Thời điểm hết hạn sau đúng 3600 giây (1 giờ).

### 3.3. Quy Trình Xác Thực "Zero-DB Verification"

Khi Client gửi request kèm `Authorization: Bearer <access_token>`:
1. **PostgREST** kiểm tra tính hợp lệ của chữ ký HMAC-SHA256 ngay trong RAM bằng biến môi trường `PGRST_JWT_SECRET` (< 0.1ms). **Không cần query database để kiểm tra session!**
2. Nếu token giả mạo hoặc hết hạn: PostgREST trả ngay HTTP `401 Unauthorized` tại tầng proxy, Database không tốn một chu kỳ CPU nào.
3. Nếu token hợp lệ: PostgREST mượn connection từ pool, mở một transaction và thực hiện cơ chế cô lập phiên `SET LOCAL`.

### 3.4. Vòng Đời Token Trên Client & Cơ Chế Chống Văng (Auto-Refresh)

1. **Lưu trữ an toàn trên thiết bị**:
   - **Mobile (Flutter iOS / Android)**: Token được lưu vào phần cứng bảo mật qua `flutter_secure_storage` (iOS Keychain và Android KeyStore/EncryptedSharedPreferences với mã hóa AES-256).
   - **Web / PWA**: Lưu trong bộ nhớ an toàn hoặc LocalStorage với luồng PKCE.
2. **Cơ chế Tự động Làm mới (Refresh Token Rotation)**:
   - `access_token` chỉ sống **1 giờ** để giảm thiểu rủi ro nếu bị bắt gói tin mạng.
   - Thư viện `supabase_flutter` chạy một bộ đếm ngầm. Trước khi token hết hạn 5 phút (phút thứ 55), nó tự động gửi `refresh_token` lên GoTrue:
     ```http
     POST /auth/v1/token?grant_type=refresh_token
     ```
   - GoTrue kiểm tra trong bảng `auth.refresh_tokens`:
     - Nếu hợp lệ: Cấp một cặp `access_token` mới + `refresh_token` mới, đồng thời **hủy ngay lập tức refresh_token cũ** (chống Replay Attack).
     - Người dùng lướt app liên tục mà không bao giờ bị gián đoạn hay phải đăng nhập lại.
3. **Đăng xuất & Thu hồi phiên khẩn cấp (Session Revocation)**:
   - Khi bấm **Đăng xuất**: GoTrue xóa dòng token trong bảng `auth.refresh_tokens`.
   - Nếu tài khoản bị nghi ngờ hack: Admin hoặc người dùng chọn *"Đăng xuất khỏi tất cả thiết bị"*, hệ thống xóa sạch toàn bộ `auth.refresh_tokens` của `user_id` đó. Kẻ gian dù cầm `access_token` cũ cũng chỉ dùng được tối đa vài phút, sau đó vĩnh viễn không thể refresh được nữa.

---

## 4. Kiến Trúc Bảo Mật Đa Tầng (Multi-Layer Security Architecture)

### 4.1. Mô Hình 2 Khóa: `anon_key` vs `service_role_key`

| Đặc điểm | `SUPABASE_ANON_KEY` (Khóa Công Khai) | `SUPABASE_SERVICE_ROLE_KEY` (Khóa Tuyệt Mật) |
|---|---|---|
| **Vị trí lưu trữ** | Nhúng công khai trong Client Flutter, Web JS, trình duyệt | **CHỈ LƯU TRÊN SERVER** (.env trên VPS, bí mật) |
| **Vai trò DB gán ngầm** | `anon` (chưa đăng nhập) hoặc `authenticated` (khi gửi kèm User JWT) | `service_role` (Quyền Siêu Quản Trị) |
| **Quyền hạn RLS** | **BẮT BUỘC TUÂN THỦ RLS 100%**. Không có RLS = không xem được gì | **BYPASS RLS HOÀN TOÀN** (Toàn quyền đọc/ghi toàn bộ CSDL) |
| **Hậu quả nếu lộ** | **HOÀN TOÀN VÔ HẠI**. Người khác cầm key này cũng chỉ thao tác được dữ liệu được phép bởi RLS | **NGUY CƠ TOÀN BỘ CSDL BỊ ĐÁNH CẮP HOẶC XÓA** |
| **Mục đích sử dụng** | Cho Client gọi API thông thường | Cho các tác vụ Migration, Backup, Admin Cron Job |

> **Nguyên tắc vàng**: Tuyệt đối không bao giờ đưa `service_role_key` vào bất kỳ file code client nào (`apps/quire`, `packages/`). Mọi giao tiếp từ app mobile/web chỉ dùng `anon_key` kết hợp JWT của người dùng.

### 4.2. Row-Level Security (RLS) — Bức Tường Lửa Ở Cấp Nhân Hệ Thống

RLS là tính năng bảo mật cấp hạt nhân của PostgreSQL từ phiên bản 9.5. Khi bật RLS trên một bảng:
```sql
ALTER TABLE public.quire_moments ENABLE ROW LEVEL SECURITY;
```
**Bất kỳ câu lệnh `SELECT`, `INSERT`, `UPDATE`, `DELETE` nào từ client đều KHÔNG THỂ chạm vào dữ liệu trừ khi thỏa mãn tường minh ít nhất một chính sách (POLICY).**

#### Hai Mệnh Đề Then Chốt: `USING` và `WITH CHECK`
1. **`USING` (Áp dụng cho SELECT, UPDATE, DELETE)**:
   - Đóng vai trò như một mệnh đề `WHERE` bắt buộc được engine của PostgreSQL tự động chèn vào câu truy vấn.
   - Client có cố tình gửi `SELECT * FROM quire_moments` (không có WHERE) thì database vẫn tự động chuyển thành:
     ```sql
     SELECT * FROM quire_moments 
     WHERE (circle_id IN (
         SELECT circle_id FROM public.quire_circle_members WHERE user_id = auth.uid()
     ));
     ```
2. **`WITH CHECK` (Áp dụng cho INSERT, UPDATE)**:
   - Kiểm tra dữ liệu *mới* sắp được ghi vào database. Nếu không thỏa mãn điều kiện, PostgreSQL hủy transaction ngay lập tức và ném lỗi `403 Forbidden` về client.
   - Ví dụ: Người dùng A không thể nào INSERT một moment với `sender_id = B`:
     ```sql
     CREATE POLICY "Moments Insert Policy" ON public.quire_moments
     FOR INSERT WITH CHECK (
         sender_id = auth.uid() -- Bắt buộc người gửi phải là chính chủ JWT
     );
     ```

### 4.3. Cơ Chế Cô Lập Phiên JWT (`SET LOCAL`)

1. PostgREST mượn connection từ pool và khởi chạy một transaction riêng biệt:
   ```sql
   BEGIN;
   SET LOCAL ROLE authenticated;
   SET LOCAL "request.jwt.claim.sub" = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
   SET LOCAL "request.jwt.claim.role" = 'authenticated';
   SET LOCAL "request.jwt.claim.email" = 'user@domain.com';
   SELECT * FROM public.profiles;
   COMMIT;
   ```
2. Hàm helper `auth.uid()` được định nghĩa sẵn trong schema `auth`:
   ```sql
   CREATE OR REPLACE FUNCTION auth.uid() 
   RETURNS uuid 
   LANGUAGE sql STABLE 
   AS $$
     SELECT nullif(current_setting('request.jwt.claim.sub', true), '')::uuid;
   $$;
   ```
3. Nhờ cơ chế `SET LOCAL`, các biến môi trường này **chỉ tồn tại trong đúng 1 transaction duy nhất**. Khi transaction kết thúc, kết nối trả về pool ở trạng thái vô danh. Hoàn toàn không có hiện tượng rò rỉ session hay xung đột giữa hàng ngàn người dùng đồng thời.

---

## 5. Hai Phương Án Triển Khai Thực Tế Trong Dự Án (Deployment Topologies)

Hệ thống Constellation hỗ trợ hai mô hình triển khai backend linh hoạt tùy theo giai đoạn phát triển:

### Phương Án A: Direct PostgREST + RLS (Pure Supabase BaaS — Tinh Gọn & Siêu Tốc)
- **Mô tả**: Client Flutter kết nối trực tiếp vào Kong Gateway qua `anon_key` và JWT. Toàn bộ CRUD do PostgREST phục vụ, phân quyền do PostgreSQL RLS đảm nhiệm.
- **Ưu điểm**: Zero-backend code, thời gian đưa tính năng ra thị trường (Time-to-Market) cực nhanh, độ trễ p95 < 10ms, tốn dưới 100MB RAM toàn hệ thống.
- **Phù hợp**: Giai đoạn phát triển nguyên mẫu, khởi chạy nhanh các tính năng dữ liệu chuẩn.

### Phương Án B: Golang BFF Wrapper + Supabase Hạ Tầng (Enterprise & Mở Rộng Linh Hoạt)
- **Mô tả**: Xây dựng một dịch vụ Backend độc lập bằng **Golang** đóng vai trò BFF (Backend-For-Frontend) đứng trước toàn bộ hạ tầng Supabase (chi tiết tại @doc/architecture/backend-golang-bff-wrapper).
- **Cơ chế triển khai**:
  1. **Đóng kín cổng database**: Cổng PostgreSQL (`5432`) và PostgREST (`3000`) bị đóng hoàn toàn khỏi Internet, chỉ lắng nghe trong mạng nội bộ Docker network.
  2. **Go Middleware xác thực JWT**: Giải mã và kiểm tra chữ ký `JWT_SECRET`, lấy `user_id` đưa vào `context.Context`.
  3. **Quản lý quan hệ bạn bè linh hoạt**: Không áp đặt giới hạn cứng 12 bạn bè trong CSDL trigger (đã bãi bỏ trigger `check_quire_circle_member_limit`), chuyển logic kiểm soát vòng kết nối sang tầng Go Service.
  4. **Tích hợp ngoại vi nâng cao**: Chạy NTP client xác thực thời gian thực (chống gian lận giờ trong After Midnight 00:00–05:00), tích hợp FCM Push Notification, kết nối dịch vụ AI.
- **Ưu điểm**: Kiểm soát tuyệt đối logic nghiệp vụ, dễ viết unit test/integration test trong Go, bảo mật đa tầng.

---

## 6. Ma Trận Phòng Thủ & Ứng Phó Rủi Ro (Security Hardening Matrix)

| Nguy cơ tấn công | Cách thức kẻ xấu thực hiện | Cơ chế phòng thủ của hệ thống |
|---|---|---|
| **SQL Injection** | Nhập chuỗi độc hại qua tham số URL (`?name='; DROP TABLE--`) | **Kháng 100%**: PostgREST không nối chuỗi SQL. Nó dùng AST parser dịch URL thành câu lệnh SQL có tham số hóa (Parameterized Queries). |
| **Khai thác IDOR (Xem trộm dữ liệu người khác)** | Đổi UUID trong URL thành UUID của người khác | **Bị triệt tiêu hoàn toàn bởi RLS**: PostgreSQL chỉ trả về dữ liệu nếu `auth.uid()` có trong danh sách bạn bè được chia sẻ. Kẻ xấu nhận về mảng rỗng `[]` (HTTP 200) hoặc lỗi `403`. |
| **Spam / Tấn công từ chối dịch vụ (DDoS)** | Gửi hàng ngàn request liên tục vào API Gateway Kong | Kong cấu hình plugin `rate-limiting`: giới hạn 100 req/phút trên mỗi IP hoặc User ID. |
| **Query quá nặng làm sập DB (Query Bomb)** | Gửi request `GET /rest/v1/huge_table?select=*` | Cấu hình `PGRST_MAX_ROWS = 1000` trong PostgREST. Không một request nào được phép kéo quá 1000 dòng dữ liệu một lúc. |
| **Rò rỉ Service Role Key** | Đưa nhầm key vào code frontend | Script CI/CD quét secret (`trufflehog` / git hook). Biến `SUPABASE_SERVICE_ROLE_KEY` chỉ tồn tại trong file `.env` trên VPS. |

---

## 7. Tham Chiếu Tài Liệu Liên Quan

- Kiến trúc Golang BFF Wrapper bọc ngoài Supabase: @doc/architecture/backend-golang-bff-wrapper
- Hạ tầng Docker Supabase & Version Gating: @doc/architecture/backend-supabase-version-gating
- Đặc tả luồng tải ảnh Quire & 900ms Undo: @doc/architecture/quire-photo-upload-logic
- Hướng dẫn khởi động cho lập trình viên Client: @doc/guides/client-developer-quickstart
