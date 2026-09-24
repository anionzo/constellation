---
title: 'Temporal & Ritual State Machines — Máy trạng thái thời gian & Nghi thức tương tác'
description: Phân tích máy trạng thái 4 nấc thời gian After Midnight, luồng nghi thức 6 bước tuần tự Astraea, và chuỗi chuyển hóa từ ghi chép thô đến hé lộ tác phẩm Dream Journal
createdAt: '2026-09-24T00:00:00.000Z'
updatedAt: '2026-09-24T16:25:25.998Z'
tags:
  - constellation
  - patterns
  - temporal
  - ritual
  - state-machine
---

# Temporal & Ritual State Machines — Máy trạng thái thời gian & Nghi thức tương tác

> Tài liệu phân tích các cỗ máy trạng thái (State Machines) điều khiển nhịp độ thời gian tự nhiên, các nghi thức tương tác tuần tự không thể đảo lộn và các giai đoạn chuyển hóa tâm lý trong các ứng dụng Constellation.

---

## 1. Nhịp điệu Thời gian & Ma sát Tích cực (Frictional Restraint)

Khác với các ứng dụng hiện đại luôn cố gắng tối ưu hóa tốc độ ("1-click", "instant gratification"), Constellation chủ động đưa vào **Ma sát Tích cực (Positive Friction)**. Thời gian được đối xử như một chất liệu thiết kế:
- Buộc người dùng phải sống chậm lại.
- Tạo khoảng lặng để suy ngẫm trước khi đưa ra quyết định hoặc đón nhận một thông điệp.
- Tạo cảm giác linh thiêng và trân trọng cho các trải nghiệm cá nhân.

---

## 2. Cổng Thời gian Diurnal 4 Nấc After Midnight (Diurnal State Machine)

Prototype có các mốc quan sát sau; interval ghi theo quy ước nửa mở để tránh chồng lấn:

- **Day**: `[06:00, 18:00)`
- **Dusk**: `[18:00, 00:00)`
- **Midnight**: `[00:00, 05:00)`
- **Dawn**: `[05:00, 06:00)`

- Client clock là `FIXTURE`/best-effort; timezone, DST, clock rollback và trusted-time là `DEFERRED`.
- ở Midnight có 6 điểm đến được liệt kê cùng The Void; số “5/8 không gian” là nhãn nguồn chưa canonical, không dùng làm production count.
- Lời nhắc nghỉ trong prototype là ambient copy, không phải OS push; nếu muốn notification phải qua consent/C-90.
## 3. Nghi thức Rút Bài 6 Bước Tuần Tự Astraea (Non-Commutative Ritual Order)

- **Nguồn quan sát**: `designs/astraea/V2 astraea-nguyên mẫu tương tác.html#9352:376-464, 728-732`
- **Bất biến Nghi thức**: giữ đúng thứ tự *Hỏi → Chọn trải → Xòe/chọn → Lật từng lá → Đọc thông điệp → Lưu Nhật ký*; không nhảy cóc hoặc tự thêm CTA.
- Bước 1–4 là ritual/session tạm; kết quả chỉ được coi là **committed** khi người dùng hoàn tất Bước 6. Nếu prototype có state/commit khác, phải ghi `Chưa rõ — hỏi Lead` và không suy ra persistence.
- Thoát trước Bước 6 không được tự động tạo bài đọc đã lưu; reload, back gesture, double-tap và recovery là test case `PROPOSED`.
- Draft/atomic commit, cancel và retry không được đặt tên class/schema trong pattern; chỉ mô tả hành vi sau khi có ADR.
## 4. Cơ chế Lật Thẻ 3D & Chuyển đổi Xuôi / Ngược (Card Reveal Dynamics)

- **Hiệu ứng lật 3D**: Mỗi lá bài Tarot là một thẻ 3D hai mặt dựng bằng CSS `transform: rotateY()`. Mặt sau mang hoa văn hình học thiên văn; mặt trước là tranh minh họa vector SVG độc bản.
- **Công tắc Xuôi / Ngược (Upright / Reversed Toggle)**:
  - Mỗi lá bài có 2 chiều diễn giải đối lập.
  - Khi người dùng gạt công tắc Xuôi/Ngược tại màn hình chi tiết, thẻ bài xoay 180 độ và toàn bộ 4 lớp diễn giải (ý nghĩa chính, tình duyên, sự nghiệp, phát triển bản thân) tự động chuyển hóa văn bản tương ứng.

---

## 5. Chuỗi Chuyển Hóa Giấc Mơ trong Dream Journal

- **Nguồn quan sát**: `designs/dream-journal/index.html` và `canvas.html`.
- Chuỗi hành vi được ghi nhận: **ghi thô → hé lộ → mảnh ghép/biểu tượng → chiêm nghiệm → tích lũy nội tâm**.
- “Chiêm nghiệm” trong prototype là UX/copy hoặc loading/error state; AI provider, prompt, dữ liệu gửi đi và công thức sao/chuỗi đêm là `DEFERRED`.
- Không được biến chuỗi thành pipeline bắt buộc nếu prototype cho phép back/recovery; mỗi transition, offline, partial save và manual note phải được kiểm chứng riêng.
## 6. Ma trận Chuyển Trạng thái & Failure-Modes Kỹ thuật

| Cỗ máy trạng thái | Failure-mode | Hậu quả | Test/contract cần trước khi chốt |
|---|---|---|---|
| **Diurnal Gate** | Chuyển 04:59 → 05:00 khi đang có draft | Mất dữ liệu hoặc mất niềm tin | Quyết định draft boundary tại 05:00; warning/recovery không tự thêm |
| **Tarot Ritual** | Thoát/reload trước Bước 6 | Bài chưa commit bị lẫn vào Nhật ký | Chỉ commit sau Bước 6; back/reload/double-tap |
| **Dream flow** | Lỗi mạng giữa raw input và reflection | Mất raw record hoặc mất manual fallback | Giữ raw record; retry/offline/manual note là `PROPOSED` |
| **Radio/Audio** | Rời surface khi audio đang phát | Pin tăng hoặc audio nền gây khó chịu | Lifecycle/opt-in/interruption test; implementation `DEFERRED` |

Các “biện pháp” như timer 5 phút, commit atomic, provider cụ thể hoặc tên event không được ghi như đã chốt trong docs-only.
