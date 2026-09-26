---
title: G-01 Hướng dẫn dùng Impeccable Design Skills cho Agent CLI
description: 'Overlay workflow Impeccable v4.3.1 cho từng app Constellation: context/playbook hiện hành, target read-only, C-90/C-91, bounded verification và scope không hợp nhất.'
createdAt: '2026-09-24T00:00:00.000Z'
updatedAt: '2026-09-24T16:19:50.731Z'
tags:
  - constellation
  - design-skills
  - impeccable
  - overlay
  - governance
---

# G-01 Hướng dẫn dùng Impeccable Design Skills cho Agent CLI

> Bộ skill thiết kế UI/UX hàng đầu thế giới (Apache-2.0, ~70.4k ⭐ GitHub của Paul Bakaus) đã được tích hợp sẵn vào dự án tại `.opencode/skills/impeccable`, `.claude/skills/impeccable` và `.agent/skills/impeccable`.

---

## 1. Bản đồ tra cứu lệnh: overlay cho Constellation

G-01 chỉ là **project-specific overlay**; `.opencode/skills/impeccable/SKILL.md` (v4.3.1) là nguồn workflow/syntax hiện hành. Không copy toàn bộ skill vào đây và không tự tạo precedence mới.

- `context`: nạp context một lần mỗi phiên trước khi chọn playbook.
- `shape` / `critique`: xác định hoặc đánh giá UX trước khi sửa.
- `quieter` / `distill` / `typeset` / `layout` / `colorize`: tinh chỉnh surface theo playbook được chọn, không bắt buộc chạy toàn bộ chuỗi.
- `harden` / `adapt` / `clarify` / `optimize`: kiểm tra edge state, responsive, copy và performance.
- `audit` / `polish`: quality pass; `audit` là kiểm tra kỹ thuật, không phải chứng nhận WCAG production.
- `document` / `extract`: chỉ chạy trên implementation workspace/surface được duyệt; không ghi đè tài liệu Knowns hoặc tạo design system chung cho bốn app.
- `live`: visual iteration trong browser/sandbox được chỉ định; không đồng nghĩa sửa `designs/*` read-only.

Khi không có yêu cầu lệnh rõ ràng, Impeccable routing hiện hành quyết định hướng xử lý; G-01 không được tự chạy lệnh.
## 2. Quy trình làm việc chuẩn: overlay theo skill hiện hành

1. Chạy `impeccable context` một lần mỗi phiên với target/surface cụ thể; đọc playbook và `craft-floor.md` ngay trước UI edit theo SKILL.md.
2. Xác định target và incumbent visual truth; phân biệt refinement với redesign, không tự thay factual copy hoặc behavior.
3. Chạy command cần thiết theo routing hiện hành, không bắt buộc một pipeline cố định. Mọi thay đổi phải giữ C-90 và source read-only.
4. Kiểm tra bằng bounded pass: screenshot/defect scan, responsive/a11y spot-check, rồi một pass xác nhận tối đa; không tự chạy vòng lặp mở.
5. Chỉ `document`/`extract` trong implementation workspace đã được duyệt; app docs chỉ cập nhật khi claim đã được Lead duyệt.

`audit` không chứng nhận WCAG production; `clarify` không tự thu thập toàn bộ copy bị C-91 defer; `live` không sửa source `designs/*`.
## 3. Hướng dẫn áp dụng cho 4 App trong `designs/` (Tuân thủ C-90)

Mỗi app là một target/surface riêng. Không chạy Impeccable ở portfolio root để tạo một `DESIGN.md` chung, không đổi `designs/*`, và không biến app docs thành production SSOT.

### 3.1. Dream Journal — 22 screen inventory
- **Nguồn**: `designs/dream-journal/index.html`, `canvas.html`.
- **Tài liệu tham chiếu**: @doc/constellation/dream-journal-01-flow và @doc/constellation/dream-journal-02-data.
- **Surface trọng tâm**: `/quieter`, `/typeset`, `/animate`, `/harden` khi có yêu cầu cụ thể.
- **Guard**: giữ Cormorant Garamond + Be Vietnam Pro, 5 lớp vén, raw record an toàn khi lỗi mạng; không thêm gamification, tiên tri hoặc AI service ngoài scope.

### 3.2. Quire — 19 inventory items, state count cần tách lớp
- **Nguồn**: `designs/quire/prototype.html`, `design-board.html`, `index.html`.
- **Tài liệu tham chiếu**: @doc/constellation/quire-01-flow và @doc/constellation/quire-02-data.
- **Surface trọng tâm**: `/distill`, `/layout`, `/clarify`, `/harden` theo nhu cầu.
- **Guard**: giữ Newsreader + JetBrains Mono, circle thân mật (không áp trần cứng 12; prototype demo 11), activity log purge 30 ngày; read receipts mặc định tắt, vanity metrics/follower graph không được tự thêm.

### 3.3. After Midnight — 15 inventory items, số không gian chưa canonical
- **Nguồn**: `designs/after-midnight/v1 after midnight - interactive prototype.html` và canvas.
- **Tài liệu tham chiếu**: @doc/constellation/after-midnight-01-flow và @doc/constellation/after-midnight-02-data.
- **Surface trọng tâm**: `/quieter`, `/distill`, `/adapt`, `/animate` khi có yêu cầu.
- **Guard**: giữ Instrument Serif + IBM Plex, The Void không persist/sync, Sân thượng không CTA; không gọi 5/6/8 là canonical count nếu chưa có Lead decision.

### 3.4. Astraea — 18 visual panels, 16 routes, count chưa hợp nhất
- **Nguồn**: `designs/astraea/V2 astraea-nguyên mẫu tương tác.html` và bản đồ toàn cảnh.
- **Tài liệu tham chiếu**: @doc/constellation/astraea-01-flow và @doc/constellation/astraea-02-data.
- **Surface trọng tâm**: `/shape`, `/animate`, `/audit` spot-check, `/polish` khi có yêu cầu.
- **Guard**: giữ Cormorant Garamond + Jost + JetBrains Mono; không thêm Cinzel nếu source không có; nghi thức 6 bước, phản chiếu không tiên tri, 2-tap wipe; không gọi `audit` là WCAG certification.

Mọi thay đổi visual/copy phải được Lead duyệt trước khi cập nhật app docs; Impeccable không tự thay đổi source read-only.
## 4. Kỷ luật an toàn hệ thống (Safety & Governance)

1. **Precedence**: `KNOWNS.md` và skill Impeccable hiện hành đứng trên G-01. Không ghi đè shim runtime, `KNOWNS.md` hoặc tài liệu Knowns-managed.
2. **Scope**: `designs/*` là read-only; `/live`, `/document` và `/extract` chỉ chạy trong implementation workspace/sandbox đã được Lead cho phép. Không tạo `DESIGN.md` chung cho bốn app.
3. **Anti-mint**: không tự thêm API, schema, DB, auth, sync, AI prompt/guardrail, analytics hoặc asset license; các mục này thuộc C-91 `DEFERRED`.
4. **Evidence**: mọi thay đổi phải giữ source path, commit/ngày đọc, status `OBSERVED/PROPOSED/APPROVED/DEFERRED` và test evidence phù hợp.
5. **Validation**: sau cập nhật dùng `knowns_validate` (không dùng tên tool không tồn tại như `mcp__knowns_validate`), rồi chạy semantic cross-check cho C-90/C-91.
