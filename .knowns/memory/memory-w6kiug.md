---
id: w6kiug
title: 'Workaround knowns CLI vỡ tiếng Việt: ghi file trực tiếp + validate'
layer: project
category: convention
tags:
  - knowns
  - cli-bug
  - encoding
  - workflow
createdAt: '2026-09-21T12:39:55.851Z'
updatedAt: '2026-09-21T12:39:55.851Z'
---

knowns CLI 0.18.3 trên Windows hỏng với nội dung tiếng Việt: (1) `doc create -c` sinh slug từ content khi có ký tự đặc biệt (dấu, `|`, backtick, →) gây lỗi rename khi tên quá dài; (2) argv qua CLI vỡ encoding UTF-8 (mojibake). Cách làm đúng: tạo doc placeholder ASCII ngắn qua CLI, rồi ghi nội dung UTF-8 trực tiếp vào `.knowns/docs/<folder>/<slug>.md` (giữ frontmatter title/description/tags), xong chạy `knowns validate --scope docs`. Đã áp dụng thành công cho 4 docs constellation (S-01, S-02, dream-journal-01/02).
