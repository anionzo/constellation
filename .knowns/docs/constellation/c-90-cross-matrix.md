---
title: C-90 Cross-matrix chống-merge + done-checklist
description: 'So sánh chéo 4 app: điểm cố ý khác nhau, guard chống merge, checklist nghiệm thu từng app'
createdAt: '2026-09-21T13:45:00.000Z'
updatedAt: '2026-09-24T16:21:21.959Z'
tags:
  - constellation
  - cross-matrix
---

# C-90 Cross-matrix chống-merge + done-checklist

> Ngày chốt: 2026-09-21. Nguồn: 8 docs app trong folder `constellation` + readme/brief/notes gốc 4 submodule.

## 1. Ma trận so sánh (điểm cố ý khác nhau — không đồng nhất hóa)

| Khía cạnh | dream-journal | quire | after-midnight | astraea |
|---|---|---|---|---|
| Cửa thời gian | Không (mở mọi lúc) | Không | Có — 00:00–05:00; mở sớm là fixture | Không |
| Ngôn ngữ | Việt-first, có thể có quote trang trí tiếng Anh | Song ngữ EN/VI (126 keys) | Việt văn chương + nhãn ASCII | Việt, giọng thơ không tiên tri |
| Điều hướng | 5 tab + FAB giữa | 4 tab + settings nhiều tầng | 5 shortcut chỉ hiện trong đêm | Tab chính + ritual tuyến tính |
| Màu nhấn hiếm | Đỏ thẫm `#941D2E` | Cam son `#E76136`/`#F0834E` | Đỏ vang `#6E2028` | Vàng cổ `#C9A86A` duy nhất |
| Nền | Đen `#05050A` | Giấy `#FBF9F5` / than ấm `#1A1612` | Đen tuyền `#080808` | Tím than `#0B0A12` |
| Chữ tiêu đề | Cormorant Garamond | Newsreader | Instrument Serif | Cormorant Garamond |
| Chữ dữ liệu | Be Vietnam Pro | JetBrains Mono | IBM Plex Mono | Jost + JetBrains Mono |
| AI | UX/copy phản chiếu; service `DEFERRED` | Không có AI | Không có AI | Diễn giải gợi mở; service `DEFERRED` |
| Xóa dữ liệu | Lưu trữ tích lũy | Activity log tự hủa sau 30 ngày; xóa moment theo scope | Void không lưu | Xóa local data sau 2 chạm; effective deletion chưa chứng minh |
| Cấm đặc thù | Gamification, mạng xã hội, xanh chủ đạo | Follower/streak/push thúc, vanity metrics | Lưu Void, sửa thư niêm phong, CTA sân thượng | Tiên tri/gieo sợ, coi demo là thật |

- Guard chống merge: khác biệt trên là ý đồ thiết kế, không phải thiếu sót. Mọi đề xuất “thống nhất” phải hỏi Lead.
- Guard chống redesign: docs chỉ enrich dữ liệu + logic quan sát; visual/token redesign nằm ngoài phạm vi.
- Số inventory phải ghi kèm loại đếm (`visual panel`, `route`, `screen/state`, `fixture`); không dùng một số chung cho các loại khác nhau.
## 2. Done-checklist

- [x] S-01 scope/status model + S-02 template
- [x] dream-journal 2 docs (22 screen inventory; source/commit/date recorded)
- [x] quire 2 docs (19 inventory items; rendered vs promised states separated)
- [x] after-midnight 2 docs (15 inventory items; destination/space count remains unresolved)
- [x] astraea 2 docs (18 visual panels / 16 routes / other source labels retained; no false canonical count)
- [x] C-90 cross-matrix and C-91 DEFERRED registry exist
- [x] Governance docs distinguish `OBSERVED/PROPOSED/APPROVED/DEFERRED/FIXTURE`
- [ ] Lead chốt các quyết định sản phẩm còn mở: Astraea count, After Midnight archive/05:00 drafts, Quire read-receipt scope, post-save destination và các boundary tương ứng
- [ ] Chạy semantic cross-check cuối và accessibility/offline audit độc lập trước release

`[x]` ở đây chỉ xác nhận tài liệu tồn tại và phạm vi đã được ghi; không có nghĩa mục C-91 đã được triển khai.
## 3. Nhóm `Chưa rõ` tồn đọng chuyển sang quyết định/ADR sau (không tự đoán)

1. **Astraea**: canonical count giữa 18 visual panels, 16 routes, 14 tên và 13 label; đích sau lưu; phạm vi các màn phụ; fixture nào được giữ.
2. **After Midnight**: Lưu trử có mở ban ngày không; bản thảo dở lúc 05:00; cách phân loại 5/6/8 không gian/điểm đến.
3. **Quire**: read-receipt mặc định và ngữ cảnh dòng “ON”; metrics/activity visibility; quan hệ theo dõi vs vòng bạn; unsend sau khi đã xem; số state rendered/promised.
4. **Dream Journal**: draft/sync/conflict, điều kiện lưu, công thức chòm sao/chuỗi đêm và offline retry.
5. **Chung**: WCAG/a11y, offline asset/font, license, remote dependency, accessibility audit và mọi claim `chưa kiểm độc lập`.

Các mục này chỉ được chuyển từ `Chưa rõ` sang quyết định sản phẩm khi Lead duyệt và có acceptance criteria/test evidence.
