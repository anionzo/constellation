---
title: S-01 Quy ước viết docs constellation
description: 'Quy ước viết docs cho 4 app designs: vị trí .knowns/docs, mức khóa observe-only, cấm mint contract và sample code'
createdAt: '2026-09-19T07:53:23.725Z'
updatedAt: '2026-09-19T07:53:23.725Z'
tags:
  - constellation
  - conventions
---

# S-01 Quy ước viết docs constellation

Mức khóa: **observe-only** — mỗi doc chỉ ghi điều quan sát được từ prototype + nguồn kiểm chứng (file + ngày đọc). Không suy diễn thêm cho liền mạch. Cái gì chưa rõ thì gắn nhãn, không tự bịa.

## 1. Vị trí

- Mọi doc nằm trong `.knowns/docs`, folder `constellation`. Không tạo `docs/` root, không viết vào trong `designs/*` (tôn trọng git-submodule boundary, không sửa HTML nguồn).
- Header mỗi doc app ghi 1 lần: commit-hash 4 submodule + ngày đọc. Từng mục ghi `file nguồn` (vd `designs/quire/prototype.html`).

## 2. Cấm tuyệt đối (anti-mint)

- Cấm sample code dưới mọi hình thức.
- Cấm đặt tên field, schema, API, endpoint, interface, class — kể cả gắn nhãn "khái niệm". Dữ liệu mô tả bằng nhóm quan-sát-được + quy tắc văn xuôi.
- Cấm redesign visual/token, cấm merge 4 app thành 1 product.

## 3. Nhãn bắt buộc

- `Quan sát:` điều thấy trực tiếp trong HTML/readme/brief/notes.
- `Chưa rõ — hỏi Lead:` ambiguity, không đoán. Mỗi cái map 1 dòng hậu quả nếu implement đoán sai.

## 4. Mục lục chung (§1–§7)

Mọi doc app dùng chung số mục để kiểm completeness cơ học (không đồng nhất nội dung/visual): §1 Screens, §2 Flows, §3 Data, §4 States, §5 Tokens, §6 Copy, §7 Rules/Not-do.

## 5. Thứ tự + done-when

`S-01 → S-02 → dream-journal → quire → after-midnight → astraea → C-90 → C-91`. Đối chiếu đếm màn astraea (18 vs 13–14) chạy song song, tối đa 30 phút, board thắng tạm + flag. Done khi mỗi app đủ 2 docs + checklist C-90 tick hết.
