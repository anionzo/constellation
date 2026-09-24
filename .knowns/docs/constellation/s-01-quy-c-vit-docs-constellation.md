---
title: S-01 Quy ước viết docs constellation
description: 'Quy ước viết docs cho 4 app designs: vị trí .knowns/docs, mức khóa observe-only, cấm mint contract và sample code'
createdAt: '2026-09-19T07:53:23.725Z'
updatedAt: '2026-09-24T16:07:12.124Z'
tags:
  - constellation
  - conventions
---

# S-01 Quy ước viết docs constellation

Mức khóa: **observe-only** — mỗi doc chỉ ghi điều quan sát được từ prototype + nguồn kiểm chứng (file + ngày đọc). Không suy diễn thêm cho liền mạch. Cái gì chưa rõ thì gắn nhãn, không tự bịa.

## 1. Vị trí và phạm vi

- Quy ước này áp dụng cho **8 tài liệu bóc tách trực tiếp từ 4 prototype** trong `.knowns/docs/constellation/`: mỗi app có một `<app>-01-flow` và một `<app>-02-data`.
- `README`, `ARCHITECTURE`, `CONVENTIONS`, `architecture/*`, `patterns/*` và `guides/*` có phạm vi riêng; chúng không bị S-01 ép trở thành inventory prototype.
- Không tạo `docs/` ở root và không ghi vào `designs/*`; source prototype là read-only.
- Mỗi app doc ghi commit hash của 4 submodule, ngày đọc và đường dẫn file nguồn. Tài liệu app là snapshot derived, không thay thế source tại commit đã pin.
## 2. Cấm tuyệt đối (anti-mint)

- Trong 8 app extraction docs: cấm sample code, tên field/schema, API, endpoint, interface, class hoặc bất kỳ contract kỹ thuật được suy diễn từ mock.
- Dữ liệu chỉ được mô tả bằng nhóm quan sát được, vòng đời hiển thị và quy tắc nghiệp vụ bằng văn xuôi.
- Cấm redesign visual/token, cấm thống nhất bốn app và cấm ghi thay đổi trực tiếp vào `designs/*`.
- Tài liệu kiến trúc/pattern/guide ngoài phạm vi app extraction có thể đề xuất hướng triển khai, nhưng phải gắn nhãn `PROPOSED` hoặc `DEFERRED`; không được biến đề xuất thành hợp đồng đã duyệt.
## 3. Nhãn bắt buộc

- `Quan sát:` điều thấy trực tiếp trong HTML/readme/brief/notes.
- `Chưa rõ — hỏi Lead:` ambiguity, không đoán. Mỗi cái map 1 dòng hậu quả nếu implement đoán sai.
- `PROPOSED:` hướng kiến trúc tương lai chưa được Lead/System Architect phê duyệt.
- `APPROVED:` quyết định đã được duyệt; chỉ dùng cho contract nằm ngoài app extraction.
- `DEFERRED:` chủ động hoãn theo C-91.
- `FIXTURE:` dữ liệu/clock/asset chỉ dùng để thử nghiệm, không phải dữ liệu production.
## 4. Mục lục chung (§1–§7)

Mọi doc app dùng chung số mục để kiểm completeness cơ học (không đồng nhất nội dung/visual): §1 Screens, §2 Flows, §3 Data, §4 States, §5 Tokens, §6 Copy, §7 Rules/Not-do.

## 5. Thứ tự + done-when

`S-01 → S-02 → dream-journal → quire → after-midnight → astraea → C-90 → C-91`.

- Đối chiếu số màn phải ghi riêng `visual panel`, `route`, `screen/state` và `fixture`; không ép các số khác nhau thành một con số chung.
- Extraction hoàn tất khi mỗi app đủ 2 docs, có nguồn/commit/ngày đọc, và mọi ambiguity đã được ghi `Chưa rõ — hỏi Lead` cùng hậu quả.
- C-90 chỉ đóng trạng thái sau khi Lead duyệt các quyết định còn mở; việc C-91 đã tồn tại không đồng nghĩa các mục deferred đã được triển khai.
