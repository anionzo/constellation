---
title: 'Modular Architecture & Reusable Component Standards — Kiến trúc module hóa, thành phần tái sử dụng & Nguyên lý SOLID'
description: Chuẩn mực thiết kế cấu trúc module, bóc tách chức năng độc lập theo nguyên lý SOLID, thư viện UI primitives và các dịch vụ dùng chung có thể tái sử dụng
createdAt: '2026-09-24T00:00:00.000Z'
updatedAt: '2026-09-24T16:15:18.354Z'
tags:
  - constellation
  - architecture
  - modularity
  - reusable-components
  - solid-principles
---

# Modular Architecture & Reusable Component Standards — Kiến trúc module hóa, thành phần tái sử dụng & Nguyên lý SOLID

> Tài liệu quy chuẩn hóa kiến trúc thành phần (Component Architecture), phân rã chức năng theo nguyên lý SOLID, thiết lập thư viện khối giao diện nguyên thủy (UI Primitives) và các module dịch vụ dùng lại được. Đảm bảo mã nguồn sau này khi triển khai đạt tính module hóa cao nhất, dễ bảo trì, dễ kiểm thử và độc lập xử lý.

---

## 1. Triết lý Module hóa & Bóc tách Chức năng (PROPOSED)

Tài liệu này đề xuất ranh giới module cho production Flutter/Dart; không phải layout hay implementation đã được duyệt. Mỗi app giữ domain, state machine, lifecycle, storage policy và visual namespace riêng.

### Có thể chia sẻ
- UI primitive trung lập, accessibility primitive, locale/format helper, asset loader, audio capability, clock capability và test harness.
- Shared package chỉ được chứa hành vi không mang identity, dữ liệu, navigation, theme hoặc business rule của một app.

### Không được chia sẻ
- Palette, typography, token namespace, navigation shell, ritual order, retention/deletion policy, social graph, user identity và seed data.
- Không dùng shared abstraction để làm nội dung của bốn app thay thế lẫn nhau; abstraction chỉ thuộc tầng trung lập.
- Mọi đề xuất mới phải được gắn `PROPOSED` và đối chiếu C-90 trước khi trở thành `APPROVED`.

Prototype HTML/JS chỉ là bằng chứng quan sát; không được biến tên file, class hoặc browser API trong prototype thành contract production.
## 2. Áp dụng Toàn diện Bộ 5 Nguyên lý SOLID (PROPOSED)

- **SRP**: presentation, domain rules, lifecycle, platform capability và test harness có trách nhiệm riêng; UI không tự quyết định retention hoặc network.
- **OCP**: thêm ritual/state của một app không được sửa domain hoặc visual language của app khác.
- **LSP**: chỉ thay thế khi giữ đúng capability; read-receipt component không thể thay thế privacy-safe component.
- **ISP**: interface nhỏ theo nhu cầu, không gom audio, clock, storage, i18n và social graph vào một abstraction.
- **DIP**: domain không phụ thuộc Flutter platform, web API, storage engine hay provider cụ thể; adapter được chọn sau ADR.

Các ví dụ trong prototype chỉ dùng để giải thích nguyên tắc. Không tạo class, interface, schema hoặc storage adapter trực tiếp từ một component HTML.
## 3. Thư viện Khối Giao diện Nguyên thủy Tái sử dụng (PROPOSED)

Chỉ primitive có semantics trung lập mới được đưa vào shared package. Không dùng shared card/domain contract để ép bốn app dùng chung nội dung hoặc trạng thái.

- Button/action primitive: tối thiểu 44×44px, focus ring rõ, pressed/disabled/loading states; màu, bo góc và typography nhận từ app.
- Modal/sheet primitive: semantics, focus trap, keyboard dismissal và safe-area behavior; không mang nội dung hoặc CTA của app.
- Divider/surface primitive: nhận token riêng của từng app, không dùng global palette.
- Empty/loading/error primitive: nhận nội dung và semantics từ flow; không tự thêm CTA, retry hay retention behavior.
- Accessibility primitive: keyboard, screen-reader, touch alternative và reduced-motion; đây là hạ tầng trung lập, không phải design system chung.

Mọi primitive dùng chung phải có test riêng và không được làm mất khác biệt của bốn thế giới thị giác.
## 4. Các Tiện ích & Dịch vụ Dùng chung (PROPOSED)

Chỉ capability trung lập được tách ra; mỗi app vẫn sở hữu policy, lifecycle và UX context.

- **Audio capability**: phát/dừng/điều chỉnh và trạng th interruption; không quyết định app nào được phát âm thanh, không tự bật.
- **Clock capability**: đọc thời gian và timezone; client clock là `FIXTURE`/best-effort, không phải security boundary.
- **Locale/format capability**: format ngày, số và ngôn ngữ; không gộp dictionary, voice hoặc copy identity của Quire vào app khác.
- **Asset/vector capability**: nạp asset theo namespace và license; không gom 78 lá bài, bầu trời hoặc icon identity của từng app vào một registry chung.
- **Privacy/storage capability**: cung cấp port/adapter trung lập; ownership, retention, deletion và sync eligibility vẫn thuộc từng domain.

Các tên service cụ thể, storage engine, provider và implementation detail chỉ được thêm sau ADR; không dùng WebAudio/IndexedDB trong prototype làm production contract.
## 5. Cấu trúc Thư mục Triển khai Đề xuất (PROPOSED, Flutter/Dart)

Blueprint dưới đây chỉ là **hướng tổ chức để review**, không phải layout đã được duyệt. Không suy ra tên file, package, schema hoặc dependency từ prototype HTML.

```text
apps/
├── quire/                  # domain, presentation, lifecycle và assets riêng
├── dream-journal/          # domain, presentation, lifecycle và assets riêng
├── astraea/                # domain, presentation, lifecycle và assets riêng
└── after-midnight/         # domain, presentation, lifecycle và assets riêng

packages/
├── ui-primitives/          # semantics/accessibility trung lập
├── platform-adapters/      # audio, clock, locale, asset, storage capability
└── test-harness/           # accessibility, lifecycle và fixture isolation

contracts/                  # ADR/status/proposed contract sau khi được duyệt
```

Mỗi `apps/*` phải có namespace visual, state machine, storage boundary và test riêng. `packages/` không được chứa theme, navigation, social graph, user identity, retention policy hoặc nội dung domain của bất kỳ app nào.
