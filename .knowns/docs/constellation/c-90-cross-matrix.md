---
title: C-90 Cross-matrix chống-merge + done-checklist
description: 'So sánh chéo 4 app: điểm cố ý khác nhau, guard chống merge, checklist nghiệm thu từng app'
createdAt: '2026-09-21T13:45:00.000Z'
updatedAt: '2026-09-21T13:45:00.000Z'
tags:
  - constellation
  - cross-matrix
---

# C-90 Cross-matrix chống-merge + done-checklist

> Ngày chốt: 2026-09-21. Nguồn: 8 docs app trong folder `constellation` + readme/brief/notes gốc 4 submodule.

## 1. Ma trận so sánh (điểm cố ý khác nhau — không đồng nhất hóa)

| Khía cạnh | dream-journal | quire | after-midnight | astraea |
|---|---|---|---|---|
| Cửa thời gian | Không (mở mọi lúc) | Không | Có — 00:00–05:00, ban ngày khóa | Không |
| Ngôn ngữ | Việt hoàn toàn | Song ngữ EN/VI (126 keys) | Việt văn chương + nhãn ASCII | Việt, giọng thơ không tiên tri |
| Điều hướng | 5 tab + FAB giữa | 4 tab + settings 4 tầng | 5 tab chỉ hiện trong đêm | Tab + luồng nghi thức tuyến tính |
| Màu nhấn hiếm | Đỏ thẫm `#941D2E` | Cam son `#E76136`/`#F0834E` | Đỏ vang `#6E2028` | Vàng cổ `#C9A86A` duy nhất |
| Nền | Đen `#05050A` | Giấy `#FBF9F5` / than ấm `#1A1612` | Đen tuyền `#080808` | Tím than `#0B0A12` |
| Chữ tiêu đề | Cormorant Garamond | Newsreader | Instrument Serif | Serif trang nhã |
| Chữ dữ liệu | Be Vietnam Pro | JetBrains Mono | IBM Plex Mono | Sans gọn |
| Kẻ tách khối | Hairline mờ | Hairline giấy | — | — |
| Vòng chưa xem | Sao sáng dần | Nét đứt (không màu rực) | Sao ghim | — |
| AI | Phản chiếu, không khẳng định | Không có AI | Không có AI | Phản chiếu, không tiên tri |
| Xóa dữ liệu | Lưu trữ tích lũy | Tự xóa 30 ngày (activity); xóa với mọi người (moment) | Void không bao giờ lưu | Xóa toàn bộ sau 2 chạm |
| Cấm đặc thù | Gamification, mạng xã hội, xanh chủ đạo | Follower/streak/push thúc, gọi là mạng xã hội | Lưu Void, sửa thư niêm phong, CTA sân thượng | Tiên tri/gieo sợ, coi demo là thật |

- Guard chống merge: khác biệt trên là ý đồ thiết kế, không phải thiếu sót. Mọi đề xuất "thống nhất" phải hỏi Lead trước.
- Guard chống redesign lén: docs chỉ enrich dữ liệu + logic quan sát; mọi đề xuất đổi visual/token là out-scope.

## 2. Done-checklist (tick khi xong)

- [x] S-01 quy ước + S-02 template (observe-only, anti-mint, §1–§7)
- [x] dream-journal 2 docs (22/22 màn khớp index + canvas; brief 640 dòng đã phủ)
- [x] quire 2 docs (19 màn theo README; prototype board-only đã flag; EN/VI 126 keys)
- [x] after-midnight 2 docs (15 màn khớp 2 file; time-gate + Void + niêm phong)
- [x] astraea 2 docs (đối chiếu 18/16/14/13 đã flag + giả thuyết tạm; ritual 6 bước)
- [x] C-90 cross-matrix (doc này)
- [ ] C-91 backlog defer (doc tiếp theo)
- [ ] Lead duyệt mức khóa + 4 nhóm `Chưa rõ` lớn (astraea đếm màn, Lưu trữ ban ngày, bản thảo dở khi hết giờ, đích sau-lưu astraea)

## 3. Nhóm `Chưa rõ` tồn đọng chuyển sang kiến trúc sau (không block docs)

1. Astraea chuẩn đếm màn (18/16/14/13) — board 18 thắng tạm cho kiểm kê, 16 tuyến thắng tạm cho điều hướng.
2. After-midnight: Lưu trữ ban ngày mở hay khóa; số phận bản thảo dở lúc 05:00; 5 vs 8 không gian đêm.
3. Astraea: đích sau-lưu; phạm vi bản đầu của hàng phụ; ví dụ nào giữ lại production.
4. Quire: quan hệ "theo dõi" vs "vòng bạn"; thu hồi ảnh đã xem khi hoàn tác; 5 trạng thái chưa vẽ dựng theo văn nào.
5. Dream: công thức chuỗi đêm/độ mạnh sao; nối giấc mơ liên quan + ngưỡng sáng dần; lưu nháp/đồng bộ.
6. Chung: mọi claim WCAG/a11y/offline/font đều `chưa kiểm độc lập` — phải đo lại trước release.
