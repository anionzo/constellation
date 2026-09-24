---
title: dream-journal-02 — Dữ liệu + quy tắc + failure
description: 'Nhóm dữ liệu quan sát dream-journal, vòng đời hiển thị, tokens/a11y, copy giọng văn, danh sách cấm + 5 failure-mode'
createdAt: '2026-09-21T12:45:00.000Z'
updatedAt: '2026-09-21T12:45:00.000Z'
tags:
  - constellation
  - dream-journal
---

# dream-journal-02 — Dữ liệu + quy tắc + failure

> Submodule `designs/dream-journal` @ `3f3205a`. Ngày đọc: 2026-09-21. File nguồn chính: `designs/dream-journal/docs/brief.md`, `designs/dream-journal/README.md`, `designs/dream-journal/index.html`.

## §1 Screens — rút gọn (chi tiết xem `constellation/dream-journal-01`)

- Quan sát: 22 màn / 7 nhóm; 5 tab Đêm nay/Nhật ký/Bản đồ mơ/Bầu trời/Hồ sơ + FAB "Ghi lại" 60px giữa (README; index.html tabbar). Nếu đoán sai: sai cấu trúc điều hướng tối giản.
- Quan sát: 5 lớp vén Giấc mơ → Ảo ảnh → Ký ức → Cảm xúc → Bản ngã (brief; README nhóm 6). Nếu đoán sai thứ tự: vỡ ý nghĩa vén dần.

## §2 Flows — rút gọn (chi tiết xem `constellation/dream-journal-01`)

- Quan sát: mạch ghi → hé lộ → chi tiết → chiêm nghiệm → lưu trữ thành chòm sao (README 7 nhóm). Nếu đoán sai: đảo Hé lộ lên trước khi lưu.
- Quan sát: lỗi mạng giữ bản ghi gốc an toàn trên thiết bị, luôn có lối ghi chú thủ công (index.html error). Nếu đoán sai: mất dữ liệu khi offline.

## §3 Data — nhóm quan sát + vòng đời hiển thị (văn xuôi, không tên field/kiểu)

- Quan sát: nhóm kể giấc mơ = đoạn văn tự nhiên + giọng nói/ảnh/vẽ tay/thẻ/cảm xúc/người/địa điểm/vật/biểu tượng; câu gợi mở mẫu: nơi giấc mơ đưa tới, điều còn nhớ, người xuất hiện, cảm xúc, điều không giải thích được, chuyện trước khi tỉnh (brief ghi âm). Nếu đoán sai: rút gọn thành 1 ô text, mất trải nghiệm kể trong mơ.
- Quan sát: nhóm hé lộ = tiêu đề + ngày + bối cảnh ngủ + tranh siêu thực khổ lớn, phong cách mỹ thuật điện ảnh, cấm hoạt hình (brief hé lộ + chỉ đạo nghệ thuật). Nếu đoán sai: minh họa hoạt hình sẽ vỡ chỉ đạo nghệ thuật.
- Quan sát: nhóm mảnh ghép = mảnh nhỏ trôi quanh tranh chính, chạm mở rộng ghi chú sâu tại chỗ (brief mảnh ghép). Nếu đoán sai: danh sách tĩnh, mất cảm giác khám phá.
- Quan sát: nhóm chiêm nghiệm = biểu tượng + cảm xúc + chủ đề có thể + câu hỏi phản chiếu; AI ở thế phản chiếu, không khẳng định khoa học, không tiên đoán tương lai (brief phân tích). Nếu đoán sai: diễn giải như kết luận khoa học, rủi ro đạo đức/pháp lý.
- Quan sát: nhóm bản đồ = nút sao nối theo biểu tượng/địa điểm/người/cảm xúc/chủ đề/hình ảnh; biểu tượng lặp sáng dần (brief bản đồ). Nếu đoán sai: nối ngẫu nhiên, bản đồ mất ý nghĩa.
- Quan sát: nhóm lịch âm = sao theo ngày, độ mạnh ảnh hưởng độ lớn sao; là kho lưu trữ mặt trăng cá nhân, không phải công cụ năng suất (brief lịch). Nếu đoán sai: thêm streak/huy hiệu thành app năng suất.
- Quan sát: nhóm bầu trời = sao/giấc mơ, chòm sao/chủ đề lặp, vùng trời/giai đoạn cảm xúc; càng ghi càng rộng và riêng (brief bầu trời). Nếu đoán sai: bầu trời giống nhau mọi người, mất tính tích lũy cá nhân.
- Quan sát: nhóm lưu trữ nội tâm = số giấc mơ, biểu tượng/cảm xúc lặp lại, xem nhiều, chòm sao, chuỗi đêm; trình bày như kho tâm lý, không phải thống kê (brief hồ sơ). Nếu đoán sai: bảng thành tích, vỡ định vị riêng tư.
- Quan sát: vòng đời 1 giấc mơ = ghi → hé lộ tác phẩm → đọc chi tiết theo thứ tự tranh lớn, tiêu đề, ngày, nhật ký gốc, mảnh ghép, biểu tượng, cảm xúc, phản chiếu, ghi chú cá nhân, giấc mơ liên quan, vị trí bầu trời → tỏa vào lịch/bản đồ/bầu trời/hồ sơ (brief chi tiết). Nếu đoán sai: phản chiếu trước nhật ký gốc sẽ đảo mạch đọc.
- Chưa rõ — hỏi Lead: quy tắc nối giấc mơ liên quan + ngưỡng sáng dần + công thức chuỗi đêm/độ mạnh sao. Nếu đoán sai: chòm sao nối sai, số liệu gây hiểu lầm thành tích.
- Chưa rõ — hỏi Lead: trạng thái lưu nháp/đồng bộ/xung đột (không thấy trong file). Nếu đoán sai: tự bịa đồng bộ, sai phạm vi thiết kế.

## §4 States — vòng đời theo dữ liệu

- Quan sát: bản ghi tồn tại 3 dạng: thô (ghi) → tác phẩm (hé lộ) → nút sao (bản đồ/bầu trời). Nếu đoán sai: 3 bản rời rạc vênh nhau.
- Quan sát: phản chiếu 3 dạng: đang tạo → đã xong → thất bại cần thử lại; bản gốc luôn an toàn khi lỗi mạng. Nếu đoán sai: lỗi mạng mất bản gốc.
- Quan sát: ngày lịch 2 dạng: trống vô hiệu / có sao (vàng lớn hơn nếu mạnh). Nếu đoán sai: ngày trống bấm được gây nhầm.
- Quan sát: lớp ảo ảnh đóng/mở tại chỗ + đếm số lớp đã mở. Nếu đoán sai: không lưu trạng thái vén, mở lại từ đầu mỗi lần.
- Chưa rõ — hỏi Lead: nút lưu/FAB có trạng thái khóa/vô hiệu không. Nếu đoán sai: cho lưu rỗng hoặc chặn không lý do.

## §5 Tokens — quy tắc dùng + claim (SSOT ở README + `:root` index.html)

- Quan sát: 4 vai trò Đen nền `#05050A` / Vàng sáng `#C9A961` / Bạc khí quyển `#AEB6C4` / Đỏ thẫm hiếm `#941D2E`; cấm xanh lam chủ đạo (README bảng màu; brief hệ màu; `:root` index.html). Nếu đoán sai: đỏ tràn lan hoặc xanh chủ đạo sẽ vỡ nhận diện.
- Quan sát: serif Cormorant Garamond cho tên giấc mơ/tiêu đề/câu cảm xúc; sans Be Vietnam Pro cho điều hướng/nút/dữ liệu (README; Google Fonts link index.html). Nếu đoán sai: 1 họ chữ cho cả app, mất chất sách nghệ thuật.
- Quan sát: vật liệu CSS/SVG nội tuyến, không bitmap; chuyển động chậm + tôn trọng reduced-motion (README; index.html). Nếu đoán sai: nhúng ảnh ngoài vỡ nguyên tắc tự chứa.
- Quan sát (chưa kiểm độc lập): chạm ≥40px (nút/tab ≥44px), chữ phụ đạt WCAG AA 4.5:1 trên nền gần đen, đủ rỗng/tải/lỗi (README). Nếu đoán sai: tin luôn không đo lại, rủi ro trượt audit.
- Quan sát (chưa kiểm độc lập): online duy nhất 2 font Google; offline dùng font hệ thống, bố cục nguyên vẹn (README kỹ thuật). Nếu đoán sai: chặn cả app khi offline trong khi thiết kế chỉ suy giảm chữ.
- Quan sát: radius sm 9 / md 15 / lg 24 / pill; pad 22; gap 14; blur 22 (`:root`). Nếu đoán sai: bo/pad lệch hệ thống.

## §6 Copy — giọng + trích dẫn (không sao chép hàng loạt)

- Quan sát: giao tiếp chức năng toàn tiếng Việt; AI hoàn toàn tiếng Việt; cho phép điểm xuyết kiểu chữ Anh ở trang trí (brief Vietnamese-first). Nếu đoán sai: AI trả lời tiếng Anh sẽ vỡ yêu cầu.
- Quan sát: trích giọng (brief): "Let's explore what this dream might represent." / "A private museum of the subconscious." Nếu đoán sai: dịch thành khẳng định chắc chắn sẽ mất thế phản chiếu.
- Quan sát: chuỗi 5 lớp "Dream → Illusion → Memory → Emotion → Self" (brief). Nếu đoán sai thứ tự/diễn đạt lại: mất chữ ký sản phẩm.
- Quan sát: vài chỗ HTML vỡ mã dấu tiếng Việt nên không trích nguyên văn từ HTML, chỉ dùng bản Việt trong README/brief. Nếu đoán sai: sao chép chuỗi vỡ dấu vào sản phẩm.

## §7 Rules — cấm + failure

- Quan sát: cấm mạng xã hội/bảng xếp hạng/gamification; không phải app năng suất/tử vi/mạng xã hội/nhật ký AI generic (README; brief tổng thể). Nếu đoán sai: thêm điểm/huy hiệu sẽ vỡ định vị.
- Quan sát: cấm xanh lam chủ đạo; đen nền, bạc khí quyển, vàng sáng, đỏ hiếm (brief hệ màu). Nếu đoán sai: giao diện nhiều màu mất nhận diện.
- Quan sát: cấm hoạt hình/anime/minh họa dễ thương/fantasy generic/kinh dị rẻ/neon/cyberpunk/phát sáng quá mức (brief nghệ thuật). Nếu đoán sai: tranh lạc tông.
- Quan sát: cấm AI khẳng định khoa học/tiên đoán tương lai; chỉ phản chiếu (brief phân tích). Nếu đoán sai: rủi ro đạo đức/pháp lý.
- Quan sát: cấm hiệu ứng vỡ bạo lực/kinh dị; phải nên thơ + tâm lý (brief vén lớp). Nếu đoán sai: gây sợ, vỡ tông.
- Quan sát: cấm biến lịch thành theo dõi năng suất; là kho mặt trăng cá nhân (brief lịch). Nếu đoán sai: thêm streak/nhắc nhở vỡ tông chiêm nghiệm.
- Failure 5 dòng: (1) ngưỡng vô hiệu nút lưu/FAB không thấy → lưu rỗng hoặc chặn oan, mất giấc mơ vừa tỉnh; (2) công thức chuỗi đêm/độ mạnh sao không thấy → số liệu sai lệch thành thành tích; (3) quy tắc thử lại chiêm nghiệm chỉ thấy một phần → bấm thử mù hoặc khóa oan; (4) nối giấc mơ liên quan + ngưỡng sáng dần không thấy → chòm sao sai, hiểu lầm nội tâm; (5) chuỗi Việt vỡ dấu trong HTML → sao chép sai chính tả lên màn signature.
