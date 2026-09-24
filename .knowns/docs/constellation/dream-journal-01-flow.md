---
title: dream-journal-01 — Flow + màn hình + trạng thái
description: 'Inventory 22 màn dream-journal: vào/ra, dữ liệu quan sát, chặn, rỗng/tải/lỗi/khóa + luồng chính-phụ + copy signature'
createdAt: '2026-09-21T12:45:00.000Z'
updatedAt: '2026-09-21T12:45:00.000Z'
tags:
  - constellation
  - dream-journal
---

# dream-journal-01 — Flow + màn hình + trạng thái

> Submodule `designs/dream-journal` @ `3f3205a`. Ngày đọc: 2026-09-21. File nguồn chính: `designs/dream-journal/index.html`, `designs/dream-journal/canvas.html`, `designs/dream-journal/README.md`, `designs/dream-journal/docs/brief.md`.

## §1 Screens — inventory 22 màn (đếm từ `SCREENS` trong index.html; canvas.html đếm khớp 22/22)

| Màn (id / label) | Vào từ đâu | Ra tới đâu | Dữ liệu vào (quan sát) | Dữ liệu ra (quan sát) | Bị chặn khi nào | Rỗng / Tải / Lỗi / Khóa |
|---|---|---|---|---|---|---|
| onboarding / Khởi đầu (chrome none) | Quan sát: màn đầu khi mở prototype | Quan sát: nút CTA vào Đêm nay | Quan sát: không form nhập | Quan sát: vào home | Chưa rõ — hỏi Lead: có màn này trong app thật hay chỉ là khung mở prototype → nếu đoán sai sẽ thừa/thiếu màn chào | Không quan sát thấy |
| home / Đêm nay (tabbar, tab dem-nay) | Quan sát: tab Đêm nay; nút FAB ở mọi tab | Quan sát: FAB `data-go="record"` → Ghi lại; thẻ giấc mơ → Chi tiết | Quan sát: ngày "Thứ Hai · 14 tháng 9, 2026", lời chào "Chào buổi tối.", hỏi "Bạn vừa mơ thấy điều gì?" | Quan sát: điều hướng ghi/đọc | Không quan sát thấy | Không quan sát thấy |
| record / Ghi lại giấc mơ (none) | Quan sát: FAB trung tâm 60px | Quan sát: nhánh sang voice/draw/attach/editor/meta | Quan sát: chọn phương thức ghi | Quan sát: sang bước ghi tương ứng | Chưa rõ — hỏi Lead: có bắt buộc chọn 1 phương thức không → nếu đoán sai sẽ kẹt hoặc cho qua bước trống | Không quan sát thấy |
| voice / Ghi âm (none) | Quan sát: từ record | Quan sát: quay lại record / tiếp editor | Quan sát: bản ghi âm + nút tạm dừng/tiếp tục đổi nhãn, chấm đỏ chạy/dừng | Quan sát: audio đính kèm bản ghi | Chưa rõ — hỏi Lead: chưa có audio có cho tiếp không → nếu đoán sai sẽ lưu bản ghi rỗng | Quan sát: trạng thái đang ghi qua hiệu ứng chấm đỏ |
| draw / Vẽ lại (none) | Quan sát: từ record | Quan sát: quay lại record | Quan sát: nét vẽ trên nền phác họa tối | Quan sát: hình vẽ đính kèm | Chưa rõ — hỏi Lead: canvas trống có cho tiếp không → nếu đoán sai sẽ đính kèm ảnh trắng | Không quan sát thấy |
| attach / Thêm ảnh (none) | Quan sát: từ record | Quan sát: quay lại record | Quan sát: ảnh dạng lưới 3 cột | Quan sát: ảnh đính kèm | Không quan sát thấy | Không quan sát thấy |
| editor / Viết trong mơ (none) | Quan sát: từ record | Quan sát: sang meta | Quan sát: trình soạn thảo lớn kiểu bản thảo nền đen (brief) | Quan sát: đoạn văn bản giấc mơ | Chưa rõ — hỏi Lead: text rỗng có cho sang meta không → nếu đoán sai sẽ tạo giấc mơ không nội dung | Không quan sát thấy |
| meta / Cảm xúc & mảnh ghép (none) | Quan sát: từ editor | Quan sát: sang reveal | Quan sát: chọn cảm xúc + thẻ mảnh ghép | Quan sát: tập cảm xúc + fragments đã chọn | Chưa rõ — hỏi Lead: không chọn gì có cho lưu không → nếu đoán sai sẽ mất trục phân loại về sau | Không quan sát thấy |
| reveal / Hé lộ giấc mơ (none) | Quan sát: sau khi lưu (brief: bản thô → tác phẩm) | Quan sát: sang detail | Quan sát: bản kể thô đã lưu | Quan sát: tác phẩm (tiêu đề + ngày + bối cảnh ngủ + tranh lớn) | Chưa rõ — hỏi Lead: có cho lưu nháp/quay lại sau không → nếu đoán sai sẽ mất bản ghi khi thoát giữa chừng | Không quan sát thấy trạng thái tải khi biến đổi |
| detail / Chi tiết giấc mơ (none) | Quan sát: từ reveal, thẻ Nhật ký, nút quay lại các màn Chiêm nghiệm | Quan sát: sang fragments/symbol/analysis/chat/illusion | Quan sát: toàn bộ nội dung 1 giấc mơ đã lưu | Quan sát: điều hướng sang phân tích liên quan | Không quan sát thấy | Không quan sát thấy |
| fragments / Mảnh ghép (none) | Quan sát: từ detail | Quan sát: quay lại detail | Quan sát: chạm mảnh quanh tranh chính → ghi chú mở rộng ngay trong thẻ cùng màn (không chuyển màn) | Quan sát: đọc ghi chú mảnh | Không quan sát thấy | Không quan sát thấy |
| symbol / Biểu tượng (none) | Quan sát: từ detail | Quan sát: quay lại detail | Quan sát: chạm biểu tượng → diễn giải phản chiếu | Quan sát: đọc diễn giải | Không quan sát thấy | Không quan sát thấy |
| analysis / Chiêm nghiệm (none) | Quan sát: từ detail | Quan sát: sang chat; sang loading khi tạo mới | Quan sát: nhóm biểu tượng/cảm xúc/chủ đề + câu hỏi phản chiếu (brief) | Quan sát: bộ phản chiếu để đọc | Quan sát: cần mạng để tạo mới (màn error nêu rõ) | Tải → loading. Lỗi → error |
| chat / Trò chuyện (none) | Quan sát: từ analysis | Quan sát: quay lại analysis/detail | Quan sát: câu hỏi gợi sẵn + khung soạn gõ tay; mỗi lượt thêm 1 cặp tin nhắn trong cùng luồng | Quan sát: hội thoại chiêm nghiệm | Chưa rõ — hỏi Lead: offline có cho gửi chờ hay chặn hẳn → nếu đoán sai sẽ mất tin nhắn im lặng | Lỗi → dùng màn error |
| illusion / Vén lớp ảo ảnh (none) | Quan sát: từ detail | Quan sát: quay lại detail | Quan sát: chạm từng lớp mở/đóng tại chỗ; bộ đếm số lớp đã mở + thanh mức sáng cập nhật; 5 lớp: Giấc mơ → Ảo ảnh → Ký ức → Cảm xúc → Bản ngã; nhãn "Lớp vỏ đang nứt" | Quan sát: trạng thái đã vén | Không quan sát thấy | Không quan sát thấy |
| calendar / Nhật ký (tabbar, tab nhat-ky) | Quan sát: tab Nhật ký | Quan sát: chạm thẻ → detail | Quan sát: lưới lịch âm; ngày có sao = có giấc mơ; sao vàng lớn hơn = giấc mơ mạnh; ngày trống mờ + vô hiệu | Quan sát: ngày được chọn + danh sách giấc mơ ngày đó | Quan sát: ngày trống bấm không tác dụng | Quan sát: rỗng qua ngày trống vô hiệu (không màn rỗng riêng tại đây) |
| map / Bản đồ mơ (tabbar, tab ban-do) | Quan sát: tab Bản đồ mơ | Chưa rõ — hỏi Lead: chạm nút sao có sang detail không (không thấy nút chuyển tường minh) → nếu đoán sai bản đồ thành màn trang trí | Quan sát: bộ lọc biểu tượng/địa điểm/người/cảm xúc/chủ đề; nút sao + thẻ diễn giải | Quan sát: nút sao được chọn | Không quan sát thấy | Không quan sát thấy trạng thái rỗng |
| nightsky / Bầu trời (tabbar, tab bau-troi) | Quan sát: tab Bầu trời | Chưa rõ — hỏi Lead: đích chạm sao/vùng cảm xúc (như map) → nếu đoán sai thiếu lối vào chi tiết | Quan sát: điều khiển thu phóng + vùng cảm xúc | Quan sát: mức zoom + vùng đang xem | Không quan sát thấy | Không quan sát thấy |
| profile / Hồ sơ (tabbar, tab ho-so) | Quan sát: tab Hồ sơ | Chưa rõ — hỏi Lead: hàng giấc mơ xem nhiều có sang detail không → nếu đoán sai mất lối tắt đọc lại | Quan sát: trang đọc tổng hợp lưu trữ (brief: số giấc mơ, biểu tượng/cảm xúc lặp lại, xem nhiều, chòm sao, chuỗi đêm) | Quan sát: chỉ đọc + điều hướng lại | Không quan sát thấy | Không quan sát thấy |
| empty / Chưa có giấc mơ (tabbar, tab nhat-ky) | Quan sát: mở thay calendar khi chưa có bản ghi nào | Quan sát: nút chính → record; nút phụ → lịch tháng | Quan sát: không cần nhập | Quan sát: bắt đầu ghi hoặc xem lịch | Không quan sát thấy | Quan sát: rỗng = tranh mặt trăng + gợi ý ghi bằng giọng nói ngay khi tỉnh dậy |
| loading / Đang chiêm nghiệm (none) | Quan sát: tự mở khi tạo phản chiếu | Quan sát: tự sang analysis khi xong; cho phép rời màn hình | Quan sát: không cần nhập thêm | Quan sát: bộ phản chiếu hoàn chỉnh | Quan sát: không chặn rời màn hình | Quan sát: tải = vòng xoay + khung chờ nhấp nháy + "Đang đọc lại giấc mơ của bạn" + "Thường mất khoảng 20 giây. Bạn có thể rời màn hình này." |
| error / Không kết nối được (none) | Quan sát: tự mở khi tạo phản chiếu thất bại | Quan sát: "Thử lại" → analysis; "Ghi chú thủ công thay thế" → detail | Quan sát: không cần nhập thêm | Quan sát: thử lại hoặc ghi chú thủ công | Quan sát: bị chặn tạo phản chiếu mới khi chưa mạng | Quan sát: lỗi = thẻ cảnh báo + "Chưa kết nối được để chiêm nghiệm" + "Giấc mơ của bạn vẫn an toàn trên thiết bị. Phần chiêm nghiệm cần mạng để tạo." + "Đã thử lúc 23:58." + "Mã lỗi: DJ-2041" + "Luôn còn dùng được khi offline" |

## §2 Flows

- Quan sát: luồng chính Đêm nay → (FAB) Ghi lại → voice/draw/attach/editor → meta → (lưu) Hé lộ → Chi tiết (README thứ tự 7 nhóm; brief mục hé lộ/chi tiết). Nếu đoán sai: bỏ Hé lộ sẽ mất khoảnh khắc bản thô thành tác phẩm.
- Quan sát: từ Chi tiết tỏa sang fragments/symbol/analysis/chat/illusion để duyệt tự do (không tuyến tính bắt buộc). Nếu đoán sai: ép thành luồng tuyến tính sẽ vỡ cách duyệt.
- Quan sát: điều kiện sang Hé lộ là đã lưu bản ghi (brief). Nếu đoán sai: cho xem Hé lộ khi chưa có gì.
- Quan sát: vòng chiêm nghiệm detail → analysis → loading → (xong) analysis / (lỗi) error → Thử lại hoặc Ghi chú thủ công. Nếu đoán sai: kẹt màn tải hoặc mất lối ghi chú khi offline.
- Quan sát: vòng rỗng empty thay calendar; nút chính → record, nút phụ → lịch tháng. Nếu đoán sai: người mới không tìm được lối bắt đầu.
- Quan sát: phím Esc quay lại màn trước; phím mũi tên sang màn kề; chạm thẻ mảnh/lớp/ngày chỉ đổi nội dung tại chỗ, không chuyển màn. Nếu đoán sai: nút quay lại sai hành vi prototype.
- Chưa rõ — hỏi Lead: nhảy thẳng map/nightsky → detail; đích nút sao; hàng Hồ sơ. Nếu đoán sai: nút bấm được nhưng không đi đâu.

## §3 Data — xem `constellation/dream-journal-02`

## §4 States — xem bảng §1 + `constellation/dream-journal-02`

## §5 Tokens — xem `constellation/dream-journal-02`

## §6 Copy

- Quan sát: nút trung tâm "Ghi lại" / aria "Ghi lại giấc mơ" (index.html, FAB). Nếu đoán sai: đổi nhãn nút signature.
- Quan sát: 5 tab Đêm nay / Nhật ký / Bản đồ mơ / Bầu trời / Hồ sơ (brief mục điều hướng; index.html tabbar). Nếu đoán sai: sai tên điều hướng tiếng Việt.
- Quan sát: home "Chào buổi tối." + "Bạn vừa mơ thấy điều gì?" + ngày "Thứ Hai · 14 tháng 9, 2026". Nếu đoán sai: sai lời chào signature.
- Quan sát: loading "Đang đọc lại giấc mơ của bạn" + "Thường mất khoảng 20 giây. Bạn có thể rời màn hình này."; error toàn văn xem bảng §1. Nếu đoán sai: sai cam kết chờ/rời màn hình và an toàn dữ liệu.
- Quan sát: giọng AI phản chiếu, tiếng Việt hoàn toàn; mẫu brief: "Bạn vừa mơ thấy điều gì?", "Bạn còn nhớ cảm giác nào rõ nhất không?", "Chúng ta thử nhìn giấc mơ này từ một góc khác nhé.", "Giấc mơ này có một vài điểm lặp lại với những giấc mơ trước của bạn." Nếu đoán sai: AI phán định thay vì phản chiếu.

## §7 Rules

- Quan sát: mạch tích lũy mỗi giấc mơ → ký ức → mảnh ghép → sao → chòm sao → bản đồ nội tâm (brief tổng thể). Nếu đoán sai: các màn rời rạc, mất mạch signature.
- Quan sát: nút sao sáng dần theo biểu tượng lặp lại; sao lịch lớn theo độ mạnh giấc mơ (brief bản đồ/lịch). Nếu đoán sai: mất tín hiệu lặp lại.
- Quan sát: không mạng xã hội, không bảng xếp hạng, không gamification (README nhận diện). Nếu đoán sai: thêm điểm/huy hiệu sẽ vỡ định vị riêng tư.
