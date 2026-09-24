---
title: CONVENTIONS — Quy ước kỹ thuật, tài liệu & tiêu chuẩn Constellation
description: 'Quy ước toàn dự án: Observe-only Anti-Minting contract, cấu trúc thư mục, chuẩn hóa metadata Knowns, UTF-8 safety trên Windows, và quy trình kiểm định'
createdAt: '2026-09-24T00:00:00.000Z'
updatedAt: '2026-09-24T00:00:00.000Z'
tags:
  - constellation
  - conventions
  - standards
  - core
---

# CONVENTIONS — Quy ước kỹ thuật, tài liệu & tiêu chuẩn Constellation

> Bộ quy chuẩn kỹ thuật toàn diện điều chỉnh hành vi của kỹ sư, người bảo trì và các AI agent khi làm việc trong repository Constellation. Đảm bảo tính nhất quán của bộ nhớ Knowns, bảo vệ ranh giới thiết kế và ngăn chặn suy diễn tùy tiện.

---

## 1. Nguyên tắc Observe-Only & Anti-Minting (Kỷ luật S-01)

Nguyên tắc cốt lõi điều chỉnh việc ghi chép tài liệu trong toàn bộ dự án là **chỉ ghi nhận những gì quan sát được trực tiếp từ nguyên mẫu thực tế (Observe-Only)**:

### Điều cấm tuyệt đối (Anti-Minting Invariants):
1. **Cấm bịa mã nguồn (Zero Phantom Code)**: Tuyệt đối không viết code mẫu (sample code), snippet triển khai, controller, router, hay class TypeScript/Python dưới mọi hình thức trong tài liệu bóc tách.
2. **Cấm bịa đặt hợp đồng kỹ thuật (Zero Phantom Schemas/APIs)**:
   - Cấm đặt tên trường dữ liệu bằng tiếng Anh kỹ thuật (vd: `user_id: string`, `is_read: boolean`, `timestamp: number`).
   - Cấm định nghĩa RESTful endpoints, GraphQL queries/mutations, hay HTTP verbs (`POST /api/dreams`).
   - Dữ liệu chỉ được diễn đạt bằng **nhóm dữ liệu quan sát được + quy tắc nghiệp vụ văn xuôi tiếng Việt**.
3. **Cấm suy diễn chức năng chưa có**:
   - Khi gặp một màn hình chưa được nối dây (unwired), một nút chưa có tương tác hoặc hành vi chưa rõ ràng: **Gắn nhãn bắt buộc `Chưa rõ — hỏi Lead`**.
   - Kèm theo 1 dòng phân tích hậu quả nếu đội ngũ triển khai tự ý đoán sai.

```
[Mẫu chuẩn khi gặp điểm mơ hồ]
- Trạng thái: Chưa rõ — hỏi Lead
- Quan sát: Bấm nút 'Hoàn tất' không thấy chuyển màn hình trên nguyên mẫu.
- Hậu quả nếu đoán: Triển khai có thể tự ý lưu vào cơ sở dữ liệu làm hỏng tính chất tạm thời của luồng.
```

---

## 2. Cấu trúc Thư mục & Bản đồ Phân loại (.knowns/docs/)

Mọi tài liệu phục vụ quản lý dự án, kiến trúc và bóc tách thiết kế **BẮT BUỘC** nằm trong thư mục `.knowns/docs/`. Tuyệt đối không tạo thư mục `docs/` ở gốc repository và không tạo file tài liệu bên trong các thư mục con của `designs/*`.

| Thư mục | Mục đích sử dụng | Quy tắc đặt tên file | Ví dụ file |
|---|---|---|---|
| `.knowns/docs/` (Root) | Tài liệu điều phối tổng thể, kiến trúc vĩ mô và quy chuẩn toàn dự án | Viết hoa, chuẩn UPPERCASE không dấu | `README.md`, `ARCHITECTURE.md`, `CONVENTIONS.md` |
| `constellation/` | Tài liệu bóc tách từng màn hình và luồng chi tiết của 4 nguyên mẫu di động | `<app>-01-flow.md`, `<app>-02-data.md`, tiền tố `s-*`, `c-*` | `quire-01-flow.md`, `c-90-cross-matrix.md` |
| `architecture/` | Phân tích sâu nền tảng thiết kế chéo ứng dụng, hệ thống tokens, ranh giới bất biến | Kebab-case ngắn gọn, có nghĩa | `design-system-tokens.md`, `cross-app-invariants.md` |
| `patterns/` | Các quy luật và mô thức tương tác người dùng đặc thù (Calm UX, State Machines, Fallbacks) | Kebab-case phản ánh mẫu tương tác | `ephemeral-privacy-lifecycles.md`, `calm-anti-social-mechanics.md` |
| `guides/` | Hướng dẫn thực hành, cẩm nang mở file, thẩm định DevTools và quy trình bàn giao | Kebab-case hướng dẫn cụ thể | `prototype-navigation-inspection.md`, `prototype-to-implementation-boundary.md` |

---

## 3. Tiêu chuẩn Metadata Frontmatter (YAML Frontmatter)

Mọi tệp tài liệu markdown trong hệ thống Knowns phải mở đầu bằng khối frontmatter YAML hợp lệ. Thiếu trường `description` sẽ khiến lệnh kiểm định `knowns validate` báo lỗi:

```yaml
---
title: Tiêu đề rõ ràng của tài liệu
description: 'Tóm tắt súc tích nội dung và phạm vi tài liệu (1-2 câu ngắn, không dùng markdown phức tạp)'
createdAt: '2026-09-24T00:00:00.000Z'
updatedAt: '2026-09-24T00:00:00.000Z'
tags:
  - constellation
  - tag-chuyen-biet
---
```

### Các quy tắc bắt buộc về Frontmatter:
- **Title**: Ngắn gọn, có tiền tố phân loại nếu cần thiết (ví dụ: `README — ...`, `ARCHITECTURE — ...`).
- **Description**: Bắt buộc phải có; mô tả súc tích mục đích tài liệu để công cụ tìm kiếm ngữ nghĩa (semantic search) và retrieval của agent hoạt động hiệu quả.
- **Tags**: Tối thiểu 2 thẻ tag; thẻ đầu tiên luôn là `constellation`.
- **Dấu nháy đơn**: Bọc chuỗi `description` trong dấu nháy đơn (`'...'`) nếu có chứa các ký tự đặc biệt như dấu hai chấm, dấu gạch nối, hoặc dấu ngoặc vuông.

---

## 4. An toàn Bảng mã UTF-8 trên Windows (Memory w6kiug)

Do đặc thù môi trường Windows và phiên bản công cụ Knowns CLI (0.18.3), việc xử lý ký tự tiếng Việt có dấu qua các tham số dòng lệnh (CLI arguments) có nguy cơ gây vỡ bảng mã (mojibake) hoặc sinh slug tệp tin lỗi từ nội dung:

### Quy trình thao tác tệp an toàn:
1. **Không dùng `knowns doc create -c "<nội dung tiếng Việt>"`**: Tránh truyền trực tiếp văn bản tiếng Việt dài qua tham số CLI.
2. **Ghi tệp UTF-8 trực tiếp**: Sử dụng công cụ ghi file chuẩn (`write` / `fs.writeFile`) ghi thẳng tệp `.md` vào đúng vị trí thư mục trong `.knowns/docs/` với định dạng UTF-8 không BOM.
3. **Giữ nguyên Frontmatter**: Đảm bảo tệp tạo mới có đầy đủ khối YAML frontmatter hợp lệ như quy định ở Mục 3.
4. **Kiểm định sau khi tạo**: Chạy kiểm định ngay bằng công cụ `knowns validate` để đảm bảo hệ thống nhận diện tệp thành công.

---

## 5. Tính Bất biến của Submodule (`designs/*` Read-Only)

Thư mục `designs/` chứa 4 nguyên mẫu HTML/CSS/JS tự chứa. Đây là tài sản gốc đại diện cho kết quả thiết kế:

- **Tuyệt đối không sửa mã HTML/CSS nguồn**: Không chỉnh sửa, định dạng lại, tái cấu trúc hoặc thêm thư viện vào các tệp bên trong `designs/quire/`, `designs/dream-journal/`, `designs/astraea/`, và `designs/after-midnight/`.
- **Tôn trọng ranh giới Git Submodule**: Toàn bộ quan sát, bóc tách và phân tích phải được ghi vào `.knowns/docs/`.
- **Trích dẫn nguồn kiểm chứng**: Mọi nhận định trong tài liệu phải đính kèm đường dẫn tệp nguồn (ví dụ: `designs/quire/prototype.html` hoặc `designs/after-midnight/v1 after midnight - interactive prototype.html`).

---

## 6. Tiêu chuẩn Kiểm định Chất lượng (Validation Standards)

Trước khi coi một tác vụ hoàn tất, bắt buộc phải chạy kiểm tra tính toàn vẹn của hệ thống tài liệu:

```json
// Chạy kiểm tra toàn bộ tài liệu qua MCP
mcp__knowns__validate({ "scope": "docs" })
```

### Tiêu chí nghiệm thu:
- **0 Errors**: Không có bất kỳ lỗi cú pháp, thiếu description hay lỗi phân tích frontmatter nào.
- **0 Warnings**: Không có cảnh báo cấu trúc nghiêm trọng.
- **Tham chiếu hợp lệ**: Các liên kết tham chiếu tài liệu phải sử dụng cú pháp tham chiếu chính xác (ví dụ: @doc/constellation/quire-01-flow hoặc @doc/README).
- **Tránh ký tự dính vào tham chiếu**: Khi trỏ tài liệu bằng tiền tố `@doc` (theo sau bởi dấu gạch chéo và tên tài liệu), tránh đặt sát dấu backtick hoặc dấu chấm câu khiến bộ phân tích regex nhận diện sai tên đường dẫn.
