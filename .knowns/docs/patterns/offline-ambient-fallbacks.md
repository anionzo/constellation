---
title: 'Offline Resilience & Ambient Fallbacks — Dự phòng ngoại tuyến & Suy giảm thẩm mỹ duyên dáng'
description: Phân tích kiến trúc tự chứa không CDN, đồ họa vector SVG nội tuyến, tổng hợp âm thanh WebAudio, chuỗi phông chữ dự phòng có dấu tiếng Việt và xử lý ảnh mất mạng
createdAt: '2026-09-24T00:00:00.000Z'
updatedAt: '2026-09-24T16:23:49.399Z'
tags:
  - constellation
  - patterns
  - offline
  - resilience
  - fallback
  - webaudio
---

# Offline Resilience & Ambient Fallbacks — Dự phòng ngoại tuyến & Suy giảm thẩm mỹ duyên dáng

> Tài liệu phân tích các giải pháp kỹ thuật bảo đảm khả năng hoạt động ngoại tuyến (Offline-First), các chiến lược dự phòng khi mất kết nối mạng và cơ chế suy giảm thẩm mỹ êm ái (Graceful Aesthetic Degradation) trong 4 nguyên mẫu di động Constellation.

---

## 1. Kiến trúc Tự Chứa (Self-Contained Single-File Deliverable)

Prototype có phần lớn tài nguyên nội tuyến và có thể mở từ một file HTML, nhưng **không được gọi là zero-network tuyệt đối** khi vẫn có Google Fonts hoặc `picsum.photos`.

- Không dùng third-party framework/CDN cho code hoặc UI primitives.
- Google Fonts, ảnh placeholder và bất kỳ URL remote nào là dependency `OBSERVED`; production phải bundle/provision asset hoặc chấp nhận degraded mode theo ADR.
- Core ritual, local draft và fallback UI phải giữ được khi mất mạng; offline không được làm mất raw user data hoặc The Void.
- `WebAudio` là browser capability quan sát được, không phải production audio service.
## 2. Đồ họa Vector SVG Nội tuyến (78 Lá bài Tarot & Bầu trời Sao)

- **Nguồn quan sát**: `designs/astraea/readme.md#8EDE:35` & `designs/dream-journal/README.md#B48F:76`
- Thay vì sử dụng hàng trăm megabyte ảnh bitmap tải từ server, các nguyên mẫu tận dụng tối đa sức mạnh của vector SVG:

### Các triển khai đặc sắc:
1. **78 Lá bài Tarot trong Astraea**: Toàn bộ tranh minh họa của 22 lá Ẩn Chính và 56 lá Ẩn Phụ đều được vẽ hoàn toàn bằng các thẻ `<path>`, `<circle>`, `<polygon>` của SVG.
   - Ưu điểm: Dung lượng cực nhẹ, sắc nét ở mọi mật độ điểm ảnh Retina, có thể đổi màu các chi tiết theo CSS và không bao giờ bị vỡ hình khi mất mạng.
2. **Bầu trời sao & Chòm sao trong Dream Journal**: Bản đồ bầu trời đêm và các chòm sao được kết nối động bằng các đường line SVG vẽ theo tọa độ thời gian thực của các giấc mơ.

---

## 3. Tổng hợp Âm thanh Tại Chỗ bằng WebAudio (Synthesized Soundscapes)

- **Nguồn quan sát**: `designs/after-midnight/v1 after midnight - interactive prototype.html#19F5:410-439` & `readme.md#B144:78`
- Thay vì truyền tải các tệp âm thanh `.mp3` hay `.wav` cồng kềnh, After Midnight sử dụng trực tiếp API âm thanh bản địa của trình duyệt (**WebAudio API**) để tổng hợp không gian âm thanh đêm:

### Cơ chế hoạt động:
- **Tạo tiếng ồn trắng (Noise Generator)**: Sử dụng một bộ đệm âm thanh (`AudioBuffer`) chứa các số ngẫu nhiên toán học kết hợp với bộ lọc thông thấp (`BiquadFilterNode`) để mô phỏng tiếng mưa rơi ngoài hiên hoặc tiếng gió rít trên sân thượng.
- **Tiếng rè sóng radio analog**: Sử dụng bộ dao động sóng sin (`OscillatorNode`) kết hợp với điều chế tần số nhẹ để tái tạo âm thanh của một chiếc radio cổ đang dò đài trong đêm.
- **Hiệu quả**: Không tốn một byte băng thông mạng, âm thanh vô tận không bao giờ bị lặp đoạn (loop artifact).

---

## 4. Chuỗi Phông Chữ Dự Phòng & Bảo Toàn Dấu Tiếng Việt

- **Quan sát**: một số prototype dùng Google Fonts với fallback hệ thống; mất mạng không được làm mất khả năng đọc tiếng Việt.
- **Production contract**: asset/font phải được bundle hoặc cung cấp qua license đã duyệt; fallback phải được test trên Windows/macOS/iOS/Android và dynamic type.
- Chuỗi font, preload, license và cache strategy là `PROPOSED/DEFERRED`; không coi một `font-display` claim trong HTML là production guarantee.
## 5. Dự phòng Ảnh Mất Mạng (Graceful Image Degradation)

- **Quan sát**: Quire dùng ảnh remote `picsum.photos`; prototype có fallback thành khung nền có nhãn khi ảnh lỗi.
- **Invariant**: UI không được vỡ layout, mất nhãn hoặc làm lộ dữ liệu khi asset lỗi; tỷ lệ khung hình và alt/semantic label phải được giữ.
- **Production contract**: nguồn ảnh, license, cache, user-upload scope và offline cache là `PROPOSED/DEFERRED`; không tự coi placeholder remote là asset production-ready.
## 6. Hỗ trợ Giảm Chuyển Động (`prefers-reduced-motion`)

- **Nguồn quan sát**: Toàn bộ 4 nguyên mẫu (`designs/*`)
- Nhằm phục vụ những người dùng nhạy cảm với tiền đình hoặc muốn tiết kiệm pin tối đa:
  - Khi hệ điều hành bật chế độ `prefers-reduced-motion: reduce`, toàn bộ các hiệu ứng trượt màn hình, xoay 3D lá bài Tarot hay nhấp nháy sao đều được chuyển đổi ngay lập tức thành hiệu ứng mờ dần (crossfade) nhẹ nhàng hoặc hiển thị trực tiếp không qua hiệu ứng.

---

## 7. Ma trận Rủi ro Ngoại tuyến & Biện pháp Khắc Phục

| Tài nguyên | Rủi ro | Hành vi bắt buộc | Trạng thái quyết định |
|---|---|---|---|
| Google Fonts | FOIT, layout shift hoặc mất dấu | Có fallback đọc được; test cold-start offline | Asset strategy `DEFERRED` |
| WebAudio | Autoplay/interruption/battery | Chỉ phát sau opt-in; có stop/fallback; không giữ audio nền khi rời surface | Production audio `DEFERRED` |
| Ảnh bài viết | URL lỗi hoặc mất mạng | Giữ khung, alt/semantic label và layout ratio | Asset/license `DEFERRED` |
| AI reflection | Mất mạng giữa raw input và kết quả | Raw input phải an toàn; manual fallback/retry là `PROPOSED` | AI contract `DEFERRED` |

Không được coi placeholder đẹp là offline-first nếu chưa test data retention, request policy, keyboard fallback và recovery.
