---
title: 'CONVENTIONS — Quy ước kỹ thuật, tài liệu & tiêu chuẩn Constellation'
description: 'Quy ước toàn dự án: Observe-only Anti-Minting contract, cấu trúc thư mục, chuẩn hóa metadata Knowns, UTF-8 safety trên Windows, và quy trình kiểm định'
createdAt: '2026-09-24T00:00:00.000Z'
updatedAt: '2026-09-24T16:08:34.345Z'
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

Nguyên tắc **Observe-Only** áp dụng trực tiếp cho 8 app extraction docs (`constellation/<app>-01-flow` và `<app>-02-data`): chỉ ghi điều quan sát được từ prototype, kèm source, commit hash và ngày đọc. Tài liệu kiến trúc, pattern và guide ngoài phạm vi này có thể phân tích hoặc đề xuất hướng triển khai, nhưng phải ghi trạng thái rõ ràng.

### Status bắt buộc cho claim kiến trúc:
- `OBSERVED`: quan sát trực tiếp từ source prototype.
- `PROPOSED`: đề xuất triển khai, chưa được Lead/System Architect duyệt.
- `APPROVED`: quyết định đã được duyệt và có nguồn/ADR.
- `DEFERRED`: chủ động hoãn theo C-91.
- `FIXTURE`: clock, seed data, remote asset hoặc dữ liệu mẫu chỉ dùng thử nghiệm.
- `Chưa rõ — hỏi Lead`: ambiguity sản phẩm; không được đoán.

### Điều cấm tuyệt đối trong app extraction docs:
1. **Cấm bịa mã nguồn (Zero Phantom Code)**: không sample code, controller, router, class, interface hoặc snippet triển khai.
2. **Cấm bịa schema/API**: không tên field kỹ thuật, endpoint, REST/GraphQL hay HTTP verb; dữ liệu chỉ mô tả bằng nhóm quan sát + quy tắc văn xuôi.
3. **Cấm suy diễn chức năng chưa có**: màn unwired hoặc hành vi mơ hồ phải gắn `Chưa rõ — hỏi Lead` và nêu hậu quả nếu đoán sai.
4. **Cấm scope bleed**: không tự thêm auth, backend, sync, schema, AI prompt, visual redesign hoặc shared design system ngoài phạm vi được duyệt.
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

Do môi trường Windows và một số phiên bản CLI có nguy cơ làm hỏng dấu tiếng Việt khi truyền nội dung dài qua command line, quy trình chuẩn là:

1. **Ưu tiên Knowns MCP** dùng `knowns_update_doc` để cập nhật doc; không truyền nội dung tiếng Việt dài qua tham số CLI.
2. **Chỉ dùng ghi file trực tiếp khi MCP thực sự không khả dụng**: ghi UTF-8 không BOM, giữ nguyên frontmatter và ghi rõ đây là workaround tạm thời cho lỗi encoding.
3. **Không dùng direct write như workflow mặc định** và không ghi đè tài liệu Knowns-managed ngoài phạm vi được yêu cầu.
4. **Kiểm định ngay sau mọi cập nhật** bằng `knowns_validate`; nếu không thể chạy validator phải ghi rõ trạng thái chưa kiểm định.
## 5. Tính Bất biến của Submodule (`designs/*` Read-Only)

Thư mục `designs/` chứa 4 nguyên mẫu HTML/CSS/JS tự chứa. Đây là tài sản gốc đại diện cho kết quả thiết kế:

- **Tuyệt đối không sửa mã HTML/CSS nguồn**: Không chỉnh sửa, định dạng lại, tái cấu trúc hoặc thêm thư viện vào các tệp bên trong `designs/quire/`, `designs/dream-journal/`, `designs/astraea/`, và `designs/after-midnight/`.
- **Tôn trọng ranh giới Git Submodule**: Toàn bộ quan sát, bóc tách và phân tích phải được ghi vào `.knowns/docs/`.
- **Trích dẫn nguồn kiểm chứng**: Mọi nhận định trong tài liệu phải đính kèm đường dẫn tệp nguồn (ví dụ: `designs/quire/prototype.html` hoặc `designs/after-midnight/v1 after midnight - interactive prototype.html`).

---

## 6. Tiêu chuẩn Kiểm định Chất lượng (Validation Standards)

Trước khi coi tài liệu hoàn tất, chạy validation cấu trúc và một lượt semantic audit riêng:

```json
knowns_validate({ "scope": "docs", "strict": true })
```

### Tiêu chí nghiệm thu:
- **0 Errors / 0 Warnings**: frontmatter, metadata và reference cấu trúc hợp lệ.
- **Reference chính xác**: dùng cú pháp tham chiếu tài liệu chuẩn của Knowns; không trỏ nhầm `-01-flow` thành `-02-data` hoặc để reference dạng plain text.
- **Status rõ ràng**: claim phải phân biệt `OBSERVED`, `PROPOSED`, `APPROVED`, `DEFERRED`, `FIXTURE` và `Chưa rõ — hỏi Lead`.
- **Semantic cross-check**: đối chiếu số panel/route/state, retention, network/offline, privacy, anti-merge, accessibility và stack giữa các doc; validator cấu trúc không tự phát hiện mâu thuẫn này.
- **Provenance**: mọi claim quan sát phải có source path, commit hash/ngày đọc; claim kiểm định phải có phương pháp và trạng thái `chưa kiểm độc lập` nếu chưa audit.
