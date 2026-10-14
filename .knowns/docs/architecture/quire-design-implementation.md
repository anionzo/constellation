---
id: doc-54be6b764f1e379d9b0433410952a537
title: Quire Design Implementation
description: 'Ánh xạ thiết kế Quire (design-notes, prototype, README) sang Flutter: bảng màu khớp token, 6 quyết định thiết kế, WCAG đã kiểm, 7 khoảng cách DEFERRED gồm contrast nút Gửi fail AA và dark theme chưa wiring.'
createdAt: '2026-09-29T10:11:43.675Z'
updatedAt: '2026-09-29T10:42:53.261Z'
tags:
  - constellation
  - quire
  - design
  - design-tokens
  - accessibility
  - prototype
---

# Quire Design Implementation — OBSERVED (design) + PROPOSED (bridge)

> **Status:** §1–§4 OBSERVED (nguồn thiết kế `designs/quire/`, token ánh xạ vào code). §5–§7 PROPOSED/DEFERRED (khoảng cách chưa đóng).

## 1. Nguồn thiết kế (OBSERVED)

| Tệp | Vai trò |
|---|---|
| `designs/quire/design-notes.md` | Vấn đề, người dùng, 4 nguyên tắc, 6 quyết định chính, V1→V2, "cố ý không làm" |
| `designs/quire/README.md` | Định vị sản phẩm, bảng token, 19 màn hình, số liệu WCAG đã kiểm |
| `designs/quire/prototype.html` | Nguyên mẫu tương tác: 4 tab, cài đặt 4 tầng, theme sáng/tối, i18n EN/VI |
| `designs/quire/design-board.html` | Bảng thiết kế 19 màn theo luồng (kéo/lăn/undo được) |
| `designs/quire/previews/*.png` | 6 ảnh xem trước |

Đối tượng: người đọc 25–40 tuổi quen tạp chí + nhóm bạn thân 4–12 người. Không follower, không streak, không badge, không notification thúc ép, không gọi là "mạng xã hội".

## 2. Nguyên tắc & quyết định (OBSERVED — design-notes.md)

1. **Quiet by default** — UI im lặng mặc định; người dùng chủ động bật mọi thứ gây chú ý.
2. **Read receipts mặc định tắt** — đọc không thành nghĩa vụ phản hồi.
3. **Dark mode là than ấm** (`#1A1612`) chứ không đen tuyền — giữ chất giấy.
4. **Một accent duy nhất** cho toàn app (`#E76136` cam son).
5. Chia khối bằng **hairline** thay bóng đổ (giấy in ≠ bảng điều khiển).
6. Story ring **nét đứt thay gradient**.
7. **Serif (Newsreader) cho nội dung + mono (JetBrains Mono) cho nhãn/số liệu**.
8. Bo góc 10–22px (mềm nhưng vẫn là chữ nhật có chủ đích).

## 3. Hệ màu (OBSERVED — khớp 100% với `QuireTokens`)

| Token | Sáng | Tối |
|---|---|---|
| paper | `#FBF9F5` | `#1A1612` |
| surface | `#FFFEFD` | `#25211C` |
| s2 / s3 | `#F5F0EA` / `#ECE6DD` | `#312C26` / `#3A342C` |
| ink / ink2 / ink3 | `#241E19` / `#605851` / `#726A64` | `#ECE9E4` / `#ADA8A1` / `#A39E96` |
| rule / rule2 | `#E8E3DB` / `#D7D1C8` | `#37322C` / `#4D4740` |
| accent / accent-ink / accent-soft | `#E76136` / `#A52014` / `#FFE2D2` | `#F0834E` / `#FFA26E` / `#592A17` |
| gold / danger | `#DBA84A` / `#C13832` | `#E0B45F` / `#F07F77` |

**Lệch có chủ đích:** prototype có `--on-accent: #241E19` (chữ đậm trên nền accent), còn Flutter dùng `Colors.white` trên accent → xem §6.

Radii: 10/14/13/13/18/22 (= QuireTokens rPhoto/rPlate/rBtn/rField/rCard/rSheet).

## 4. WCAG đã kiểm theo design (OBSERVED — README)

Chữ chính 15.67:1, chữ phụ 6.63:1, chữ bậc ba 5.04:1, chữ nhấn 7.09:1, nhãn trên nút nhấn **4.83:1 sáng / 6.91:1 tối**. Mọi vùng chạm trong nguyên mẫu **≥44px**.

## 5. Ánh xạ design → Flutter (OBSERVED)

| Thiết kế | Trong code |
|---|---|
| Bảng token sáng/tối | `QuireTokens` (đủ 2 bảng) |
| Hairline thay bóng đổ | `Border.all(ruleLight)` trên card, `elevation: 0` |
| Story ring nét đứt | `DashedCirclePainter` (gap 4, strokeWidth 2) — có comment "invariant: dashed instead of gradient" |
| Serif + mono pairing | `fontSerif='Newsreader'`, `fontMono='JetBrains Mono'`, eyebrow/meta dùng mono |
| 4 tab | `QuireHomeScreen` IndexedStack (Đọc/Khoảnh khắc/Khám phá/Bạn) |
| Luồng gửi ảnh (compose → gửi → undo) | `QuireComposeSheet` + state machine 900ms |
| Không đo lường | Không follower/streak/badge trong UI |

## 6. Khoảng cách chưa đóng (DEFERRED / PROPOSED)

| # | Khoảng cách | Bằng chứng | Mức |
|---|---|---|---|
| 1 | **Dark theme chưa wiring** — token tối có đủ nhưng `main.dart` chỉ tạo light `ThemeData` | main.dart:36-44 | DEFERRED |
| 2 | **Contrast lệch design**: design 规定 `on-accent #241E19` (4.83:1 đạt AA), code dùng `Colors.white` trên `#E76136` ≈ 3.4:1 → **fail AA** | compose_sheet:231 vs prototype `--on-accent` | **HIGH** |
| 3 | **Touch target**: design ≥44px, `FilterChip` mặc định ≈32px | compose_sheet:182 | HIGH |
| 4 | **i18n chưa map**: prototype có bảng EN/VI ~150 key; code hardcode string VI trong state/widget | photo_upload_state.dart, compose_sheet | MEDIUM |
| 5 | **Gold/danger tokens chưa có** trong `QuireTokens` (chỉ có accent) | quire_tokens.dart | LOW |
| 6 | Feed dùng `picsum.photos` fixture thay ảnh thật | home_screen:48 | LOW (prototype) |
| 7 | 19 màn trong design-board; app mới có 4 tab placeholder + 1 compose flow | home_screen:253-255 | MEDIUM |

## 7. "Cố ý không làm" — checklist bảo toàn (PROPOSED)

Khi mở rộng app, không được thêm: follower graph, con số đo quan hệ, badge/streak, notification thúc ép, nhãn "mạng xã hội", read-receipt mặc định bật, gradient story ring, bóng đổ thay hairline, accent thứ hai tùy tiện.

## Quan hệ

- Triển khai runtime: `architecture/quire-app-implementation`
- Contract package: `architecture/client-core-packages-contract`
- Test a11y/contrast đề xuất: `guides/testing-verification-strategy` §4
- Usecase & luồng xử lý: `constellation/business-use-cases-and-processing-flows`
