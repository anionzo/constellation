---
title: 'Calm Computing & Anti-Social Mechanics — Cơ chế tương tác tĩnh & Chống thao túng tâm lý'
description: Phân tích các nguyên tắc Calm Computing, danh mục cấm tuyệt đối (Anti-Features), không gian tĩnh lặng phi hành động, mặc định im lặng và giọng đối thoại phản chiếu không phán xét
createdAt: '2026-09-24T00:00:00.000Z'
updatedAt: '2026-09-24T16:22:25.470Z'
tags:
  - constellation
  - patterns
  - calm-ux
  - anti-social
  - ethics
---

# Calm Computing & Anti-Social Mechanics — Cơ chế tương tác tĩnh & Chống thao túng tâm lý

> Tài liệu khảo sát các nguyên lý Điện toán Điềm tĩnh (Calm Computing), các cơ chế chống thao túng tâm lý (Anti-Retention) và triết lý thiết kế tôn trọng nhân phẩm người dùng trong 4 nguyên mẫu Constellation. Xác lập chuẩn mực đạo đức phần mềm để ngăn chặn sự xâm lấn của các mẫu đen (dark patterns).

---

## 1. Triết lý Calm Computing & Anti-Retention trong Constellation

Phần lớn các sản phẩm công nghệ tiêu dùng hiện đại được thiết kế để tối đa hóa "thời gian trên màn hình" (Screen Time) và "tỷ lệ giữ chân người dùng" (Retention Rate) thông qua các vòng lặp kích thích dopamine (Dopamine Loops).

Ngược lại, Constellation xem công nghệ như **một công cụ tĩnh lặng**:
- Ứng dụng chỉ hiện diện khi người dùng thực sự cần đến.
- Khi người dùng hoàn thành việc đọc một bài viết, ghi lại một giấc mơ hay rút một lá bài, ứng dụng chủ động khuyến khích họ cất điện thoại và quay lại với cuộc sống thực.
- Thành công của sản phẩm được đo bằng **độ sâu lắng và sự bình yên trong tâm trí**, chứ không phải số phút người dùng dán mắt vào màn hình.

---

## 2. Danh mục Cấm Tuyệt đối (Negative Invariants / Anti-Features)

Để bảo vệ triết lý trên khỏi sự thoái hóa dần trong quá trình phát triển tính năng, Constellation thiết lập một bản hiến chương các tính năng bị nghiêm cấm:

```
+--------------------------------------------------------------------------+
| HIẾN CHƯƠNG CHỐNG THAO TÚNG TÂM LÝ (THE CALM CHARTER)                   |
+--------------------------------------------------------------------------+
| 1. CẤM ĐIỂM DANH CHUỖI NGÀY (STREAKS): Không đếm ngày liên tục, không     |
|    đe dọa mất chuỗi để ép người dùng mở app mỗi ngày.                    |
| 2. CẤM HUY HIỆU DANH HIỆU (BADGES): Không trao phần thưởng ảo để biến     |
|    hành vi ghi chép cá nhân thành trò chơi cày cuốc (gamification).      |
| 3. CẤM CHỈ SỐ DANH VỌNG (VANITY METRICS): Không hiển thị số lượt thích,  |
|    số lượt chia sẻ, hay số lượt xem công khai.                           |
| 4. CẤM LUỒNG VÔ TẬN (INFINITE FEEDS): Mọi danh sách bài đọc hay khoảnh   |
|    khắc đều có điểm dừng rõ ràng (Finite Boundaries).                    |
| 5. CẤM THÚC GIỤC BẰNG THÔNG BÁO (RETENTION PUSH): Tuyệt đối không gửi     |
|    các câu thông báo như 'Đã lâu bạn chưa mở app!' hay 'Đừng bỏ lỡ!'.    |
+--------------------------------------------------------------------------+
```

---

## 3. Không gian Phi hành động (Contemplative Stasis: Sân thượng / Rooftop)

- **Nguồn quan sát**: `designs/after-midnight/v1 after midnight - interactive prototype.html#19F5:510` & `after-midnight-01-flow.md:30, 63`
- **Khái niệm**: Trong After Midnight có một không gian độc nhất vô nhị mang tên **Sân thượng (The Rooftop)**.

### Đặc tính quan sát được của Sân thượng:
- Không có bất kỳ biểu mẫu (form) nhập liệu nào.
- Không có bất kỳ nút hành động chính (Primary CTA) nào.
- Không có luồng cuộn nội dung hay bài đăng của người khác.
- **Mục đích duy nhất**: Chỉ có hình ảnh đường chân trời thành phố mờ ảo trong đêm, tiếng gió nhẹ tổng hợp từ WebAudio, và một lời nhắn buông bỏ: *"Gió đêm trên này lạnh hơn dưới phố. Cứ đứng đây bao lâu tùy bạn."*
- Đây là biểu tượng cao nhất của **Trạng thái Dừng lại Tự nguyện (Contemplative Stasis)**.

---

## 4. Mặc định Im lặng (Quiet by Default)

- **Quire**: read receipts mặc định tắt; mọi prototype copy/trạng thái ghi “ON” phải được đánh dấu `Chưa rõ — hỏi Lead`, không được dùng làm default production. Không thêm vanity metrics hoặc notification thúc quay lại.
- **After Midnight**: âm thanh radio/mưa tắt mặc định và chỉ phát sau thao tác chủ động. Nhắc nghỉ trong prototype không được tự biến thành OS push hoặc retention notification.
- **Chung**: mọi social signal hoặc activity log phải có retention, visibility và purpose riêng; “chỉ hiển thị trong Activity” không đồng nghĩa được phép thu thập read event nếu invariant cấm.
## 5. Giọng Đối thoại Phản chiếu (Reflective Voice, Non-Deterministic)

- **Nguồn quan sát**: UX/copy prototype tại `designs/dream-journal/` và `designs/astraea/`; chưa có provider, prompt, guardrail hay dịch vụ AI production.
- Khi có implementation được duyệt, Dream Journal và Astraea chỉ được phản chiếu, không phán xét, không tiên tri và không gieo sợ.
- Mọi request model, dữ liệu gửi đi, retention và fallback local phải được đánh dấu `PROPOSED/DEFERRED`; nội dung tĩnh trong prototype không được gọi là AI production.
- Câu hỏi mở và voice signature phải bảo toàn theo source; không tự dịch hoặc tạo prompt/guardrail trong docs-only.
## 6. Ma trận Nguy cơ Thoái hóa sang Dark Patterns (Risk Analysis)

| Nguyên tắc | Nguy cơ | Hậu quả | Biện pháp governance |
|---|---|---|---|
| Vòng bạn hữu hạn | Mở toàn bộ danh bạ hoặc biến thành follower graph | Mạng spam, mất riêng tư | Giữ tối đa 12; demo 11; không thêm social graph |
| Không đếm ngày | Biến lịch sáng dần thành streak/điểm số | Tạo áp lực và cảm giác tội lỗi | Cấm streak, badge, leaderboard và vanity metrics |
| Quiet defaults | Bật read receipt, push hoặc reminder theo mặc định | Theo dõi và níu kéo người dùng | Mặc định tắt; mọi exception phải được Lead duyệt |
| Giọng phản chiếu | Biến reflection thành fortune-telling, phán xét hoặc AI upsell | Gieo sợ, mất niềm tin | Provider/prompt/guardrail `DEFERRED`; chỉ giữ voice invariant |

Các biện pháp implementation cụ thể không được ghi như đã chốt trong pattern này; chúng thuộc ADR/test sau khi thoát docs-only.
