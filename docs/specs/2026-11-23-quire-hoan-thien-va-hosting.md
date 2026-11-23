# Spec: Hoàn thiện luồng thật cho Quire và chọn hosting miễn phí

- Ngày: 2026-11-23
- Trạng thái: Draft, chờ duyệt
- Phạm vi: `apps/quire`, `packages/*`, `backend/go_service`, `backend/supabase`
- Ghi chú: file này nằm ngoài `.knowns/` vì quy ước repo không cho sửa tay tài liệu do Knowns quản lý. Khi duyệt xong có thể import vào Knowns bằng CLI.

## 1. Bối cảnh

Khung của Quire đã khá đủ. Client Flutter gọi đúng 29 endpoint mà Go BFF cung cấp, và backend build, vet sạch sau khi chạy `go mod tidy`. Tuy vậy, khi rà code (commit `8058774`), vẫn thấy vài luồng cốt lõi đang chạy bằng mock hoặc hardcode:

| # | Vấn đề | Bằng chứng |
|---|---|---|
| P1 | Upload ảnh moment là giả | `lib/main.dart` có `runApp(const QuireApp())` và dùng `MockQuireMomentUploader` mặc định. `BffMomentUploader` không được khởi tạo ở đâu |
| P2 | Ảnh từ server không hiển thị | `handlers.go` PostMoment gán `ImageURL = ImagePath`, tức là đường dẫn storage chứ không phải URL |
| P3 | BFF âm thầm rơi về MemoryRepository khi không nối được DB | `cmd/server/main.go` cấp token `mock-access-token-*`, khiến mọi route được bảo vệ trả 401 |
| P4 | Chat polling 2.5 giây | `circle_chat_sheet.dart:71`, trong khi SSE `/api/v1/chat/stream` có sẵn nhưng không dùng |
| P5 | Version gate giả | Backend luôn trả `1.0.0`. Client dùng `StaticSystemConfigRepository` với `platform: 'ios'` gán cứng |
| P6 | Dữ liệu mock còn sót | Khoảng 25 chỗ dùng `picsum.photos` hoặc `example.com`, ví dụ phần lưu trữ ở `you_tab_view.dart:1014` |
| P7 | Profile bạn bè chưa nối | Client chưa gọi `GET /api/v1/profile/{username}` |
| S1 | Secret mặc định | `config.go` fallback `JWT_SECRET` về một chuỗi công khai |
| S2 | SSE xác thực lỏng | `StreamEvents` gọi `jwt.Parse` mà không ép HS256 và không kiểm tra token đã bị thu hồi |
| S3 | Migration nguy hiểm | `06-clean-database-and-seed-10-accounts.sql` xoá dữ liệu và seed mật khẩu `password123` |
| B1 | Thiếu `go.sum` | `go build` lỗi khi chạy trực tiếp, còn Dockerfile phải chạy `go mod tidy` lúc build |
| B2 | Thiếu khai báo `http` trong `pubspec.yaml` | Hiện chỉ chạy được nhờ dependency transitive |
| B3 | Không có test Go, README mặc định | `go test ./...` báo "no test files" |
| D1 | Hai schema song song cho moments và vòng bạn | `01` tạo `quire_moments`, `quire_circles`, `quire_circle_members` (circle UUID, có storage policy). Nhưng BFF chỉ dùng `public.moments` (`02`, `circle_id VARCHAR DEFAULT 'circle_1'`) và `public.circle_members` (quan hệ bạn bè user và friend). Client gửi `circleId: 'default-circle-id'` |
| D2 | Bảng lõi nằm trong migration seed | `public.circle_members` được tạo trong `04-seed-real-data.sql` |

## 2. Quyết định hosting: dùng DB online miễn phí hay tự host?

Giới hạn gói free, đọc ngày 2026-11-23:

| | Supabase Free | Neon Free + Cloudflare R2 | Tự host (hiện tại) |
|---|---|---|---|
| Postgres | 500 MB/project, tối đa 2 project active | 1 GB/project, 100 CU-giờ/tháng, scale-to-zero sau 5 phút | Tuỳ VPS |
| Lưu file | 1 GB, tối đa 50 MB/file | R2: 10 GB, egress miễn phí | Tuỳ VPS |
| Egress | 5 GB + 5 GB cached | Neon 5 GB, R2 miễn phí | Tuỳ VPS |
| Auth | Có sẵn (GoTrue), 50k MAU | Không dùng được `auth.users` của Supabase | Có |
| Điểm trừ | Bị **pause sau 1 tuần không hoạt động**, không có backup tự động | Phải viết lại phần dính `auth.*` và `storage.*`, thêm adapter S3 | Tốn tiền VPS, tự vận hành 8 container |

**Khuyến nghị: Supabase Cloud Free.**

- Schema đang phụ thuộc trực tiếp vào `auth.users`, `storage.buckets`, `storage.objects` và RLS. Chuyển lên Supabase Cloud gần như chỉ là áp lại migration, còn Neon + R2 thì phải viết lại khá nhiều.
- Quy mô Quire nhỏ (vòng bạn tối đa 12 người, ảnh WebP khoảng 150 KB), nên 500 MB DB và 1 GB storage là đủ cho giai đoạn đầu.
- Rủi ro chính là bị pause khi app không có người dùng trong 1 tuần. Khi đó chỉ cần bấm resume trong dashboard. Lúc có người dùng thật thì nâng lên Pro, có backup tự động.
- Neon + R2 là phương án dự phòng, khi cần nhiều storage hơn hoặc muốn bỏ hẳn phụ thuộc vào Supabase.

Go BFF vẫn cần một nơi chạy riêng. Đây là câu hỏi mở (mục 6).

### Những việc cần làm khi lên Supabase Cloud

1. Bỏ khối shim `CREATE TABLE IF NOT EXISTS auth.users / storage.buckets / storage.objects` ở `01-init-schema.sql`, hoặc tách ra file chỉ dành cho local, để tránh đụng schema do Supabase quản lý.
2. Chuyển `04` và `06` thành seed riêng cho dev (`backend/supabase/seed/`). Không bao giờ áp chúng lên cloud.
3. Áp migration bằng Supabase CLI (`supabase db push`) theo đúng thứ tự.
4. BFF kết nối qua Supavisor. Nên dùng **session pooler (cổng 5432)**. Nếu dùng transaction pooler (cổng 6543) thì phải đặt `default_query_exec_mode=simple_protocol` cho pgx, vì transaction mode không hỗ trợ prepared statement.
5. BFF đang tự ký JWT HS256 bằng `JWT_SECRET` và tự kiểm tra mật khẩu trong `auth.users`. Cách này không phụ thuộc khoá ký của Supabase, nên giữ nguyên được. Cần kiểm tra lại lúc làm: project Supabase mới có còn cho insert trực tiếp vào `auth.users` không, hay phải chuyển sang gọi GoTrue Admin API.
6. Storage dùng service role key, và key này chỉ nằm ở BFF, không bao giờ xuống client.

## 3. Thiết kế các hạng mục

### W0. Thống nhất schema moments và vòng bạn (D1, D2). Làm trước W1

Mô hình mà BFF và UI đang chạy thật là **vòng bạn theo từng người**: mỗi user có danh sách bạn trong `public.circle_members`, và feed hiện moment của chính mình cùng của bạn bè. Không có khái niệm "circle UUID" nào ở client. Vì vậy:

- **Nguồn dữ liệu duy nhất là `public.moments` và `public.circle_members`.** Các bảng `quire_moments`, `quire_moment_recipients`, `quire_circles`, `quire_circle_members` ở `01` không có ai dùng. Viết migration mới để drop chúng, hoặc ít nhất đánh dấu deprecated, kèm hàm `purge_expired_quire_moments()` và các policy storage dựa trên chúng. Hàm purge 30 ngày được viết lại cho `public.moments`.
- Chuyển `CREATE TABLE public.circle_members` (cùng index và RLS nếu có) từ `04` sang một migration schema mới (ví dụ `08-circle-members-schema.sql`), để khi tách seed ra ở W6 thì bảng không bị mất.
- Bỏ cột `circle_id` khỏi luồng moment, hoặc giữ cột nhưng không bắt buộc. Path ảnh đổi thành `quire-moments/{sender_id}/{moment_id}.webp`.
- Quy tắc quyền: người upload phải là `sender_id`. Người xem phải là sender hoặc có row `circle_members(user_id = viewer, friend_id = sender, status = 'active')`, giống điều kiện đang dùng ở `GetFeed`.
- Storage policy viết lại theo `sender_id`. Thực tế, bucket chỉ truy cập qua signed URL do BFF cấp bằng service key, nên policy chỉ là lớp phòng thủ thứ hai.

Điều kiện nghiệm thu: `grep -rn "default-circle-id\|circle_1" apps/quire/lib backend` không còn kết quả. Áp toàn bộ migration lên DB trống (không seed) thì có đủ bảng mà BFF cần.

### W1. Luồng ảnh moment thật (P1, P2). Ưu tiên cao nhất

Luồng mới dùng signed upload URL để client không cần giữ key Supabase:

1. Client nén ảnh WebP (dùng `media_storage`) và giữ trong RAM trong cửa sổ Undo 900ms như hiện tại.
2. Client gọi `POST /api/v1/moments/upload-url` với `{moment_id}`. BFF lấy `sender_id` từ JWT, rồi gọi Storage API `createSignedUploadUrl` cho path `quire-moments/{sender_id}/{moment_id}.webp` (theo W0).
3. Client `PUT` ảnh lên signed URL đó.
4. Client gọi `POST /api/v1/moments` với `image_path`. BFF kiểm tra path thuộc thư mục `{sender_id}/` của chính người gửi và object đã tồn tại, rồi insert vào `public.moments`.
5. Khi trả về feed hoặc archive, BFF sinh **signed download URL** (TTL khoảng 1 giờ) vào trường `image_url`. Bucket để private.

Thay đổi:
- `main.dart`: tạo `BffApiClient`, `BffMomentUploader` và adapter storage thật, rồi truyền vào `QuireApp`. `MockQuireMomentUploader` chỉ dùng cho test.
- Trong `media_storage`: thêm `SignedUrlMediaStorageAdapter` để upload theo URL do BFF cấp.
- Go: thêm `internal/storage` (client cho Supabase Storage REST), endpoint `upload-url`, và sinh signed URL trong `GetFeed`, `GetArchive`.

Điều kiện nghiệm thu:
- Đăng moment xong thì object có trong bucket và row có trong `public.moments`.
- Người nhận khác mở feed thì thấy ảnh thật, không phải ô xám.
- Bấm Undo trong 900ms thì không có request mạng nào được gửi.
- Gửi `image_path` nằm ngoài thư mục của chính mình thì bị trả 403. Người không phải bạn của sender thì không nhận được signed URL của ảnh.

### W2. Backend fail-fast (P3, S1, S2, B1)

- Bỏ fallback MemoryRepository ở production. Chỉ bật khi đặt `APP_ENV=dev` và `ALLOW_MEMORY_REPO=1`. Ngoài trường hợp đó, nếu không kết nối được DB thì `log.Fatal`.
- `JWT_SECRET` trống hoặc ngắn hơn 32 ký tự khi không ở `dev` thì cũng `log.Fatal`.
- Gom logic parse token của `AuthMiddleware` và `StreamEvents` vào một hàm dùng chung: ép `jwt.WithValidMethods([]string{"HS256"})` và kiểm tra `IsTokenRevoked`.
- Commit `go.sum`. Dockerfile bỏ `go mod tidy` và `|| true`, thay bằng `go mod download` + `go build -mod=readonly`.

Điều kiện nghiệm thu:
- Server không khởi động khi thiếu DB hoặc secret ở môi trường production.
- Token dùng sai thuật toán ký hoặc đã bị thu hồi thì SSE trả 401.

### W3. Chat realtime qua SSE (P4)

- Client mở SSE tới `/api/v1/chat/stream`. Web dùng `EventSource` với `?token=`, mobile dùng HTTP stream.
- Khi mất kết nối thì reconnect với backoff có jitter. Polling chỉ còn là fallback, với chu kỳ 30 giây.
- Cần lưu ý: token nằm trên query string sẽ bị ghi vào access log. Nên che tham số `token` trong log, hoặc cấp vé SSE ngắn hạn qua `POST /api/v1/chat/stream-ticket`.

Điều kiện nghiệm thu: tin nhắn hiện ở máy người nhận trong dưới 1 giây khi đang mở sheet chat, và không còn request nào lặp lại mỗi 2.5 giây.

### W4. Version gate thật (P5)

- Thêm bảng `app_versions(platform, min_supported_version, latest_version, is_maintenance_mode, update_url, ...)`. `GetVersionGate` đọc từ bảng này.
- Client dùng `BffSystemConfigRepository`, xác định platform từ `kIsWeb` hoặc `defaultTargetPlatform`, và cache bằng `shared_preferences`.
- `currentAppVersion` không còn gán cứng `1.0.0` trong `main.dart`, mà đọc từ bản build đang cài (`package_info_plus`, tức `version` trong `pubspec.yaml`).

Điều kiện nghiệm thu: đặt `min_supported_version = 1.1.0` thì build `1.0.0` hiện `ForceUpdateScreen`, còn build `1.1.0` vào app bình thường. Cả hai trường hợp đều có test.

### W5. Dọn mock và nối nốt UI (P6, P7)

- Thay toàn bộ `picsum.photos` và `example.com` trong `lib/` bằng dữ liệu từ API, kèm empty state đúng thiết kế.
- Phần lưu trữ ở tab You dùng `GET /api/v1/moments/archive`.
- Friend profile sheet gọi `GET /api/v1/profile/{username}`.

Điều kiện nghiệm thu: `grep -rn "picsum\|example.com" apps/quire/lib` không còn kết quả.

### W6. Dữ liệu và migration an toàn (S3)

- Sau khi W0 đã chuyển phần schema (`circle_members`) ra khỏi `04`, chuyển phần dữ liệu còn lại của 04 và 06 sang `backend/supabase/seed/dev-seed.sql`. Đầu file kiểm tra một biến như `app.env = 'dev'`, sai thì dừng.
- Mật khẩu seed lấy từ biến môi trường, không ghi thẳng vào file.

### W7. Chất lượng (B2, B3)

- Thêm `http` vào `dependencies` của `pubspec.yaml`.
- Go: viết test cho middleware auth, cho kiểm tra quyền thành viên circle, và cho cursor pagination (dùng `MemoryRepository` hoặc testcontainers).
- Viết README ở thư mục gốc và README cho `apps/quire`: cách chạy local, biến môi trường, cách deploy lên Supabase Cloud.
- CI bằng GitHub Actions: `go vet`, `go test`, `flutter analyze`, `flutter test`.

## 4. Thứ tự thực hiện

1. **W2 + W7 phần build** (go.sum, Dockerfile, pubspec): nhỏ, giúp các bước sau build ổn định.
2. **W0 + W6**: thống nhất schema, tách seed.
3. **Lên Supabase Cloud**: tạo project, áp migration đã dọn.
4. **W1**: luồng ảnh thật, là tính năng cốt lõi.
5. **W5**: dọn mock.
6. **W3**: chat realtime.
7. **W4**: version gate.
8. **W7 phần còn lại**: test, CI, README.

Mỗi bước là một PR riêng.

## 5. Ngoài phạm vi

- Ba app còn lại (after-midnight, astraea, dream-journal).
- Push notification.
- Nâng cấp lên gói trả phí.

## 6. Câu hỏi mở

1. Go BFF chạy ở đâu? Có thể là Fly.io, Render, Koyeb hay Google Cloud Run (gói free hoặc rẻ). Cần chọn trước bước 2. Lưu ý: nếu host sleep khi không có request thì SSE sẽ bị ngắt.
2. Có muốn giữ khả năng chạy self-host bằng Docker cho dev local không? Đề xuất là giữ, vì `docker-compose.yml` hiện có vẫn dùng tốt cho local.
3. Thời gian lưu ảnh moment: vẫn giữ 30 ngày như `purge_expired_quire_moments()`, hay đổi?

## Nguồn

- Supabase pricing: https://supabase.com/pricing
- Neon free plan: https://neon.com/docs/introduction/free-tier
- Cloudflare R2 pricing: https://developers.cloudflare.com/r2/pricing/
