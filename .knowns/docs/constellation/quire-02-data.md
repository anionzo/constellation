---
title: quire-02 — Dữ liệu + quy tắc + failure
description: 'Nhóm dữ liệu quan sát quire, vòng đời hiển thị, tokens/a11y song ngữ, copy EN-VI, danh sách cấm + failure-mode'
createdAt: '2026-09-21T13:00:00.000Z'
updatedAt: '2026-09-21T13:00:00.000Z'
tags:
  - constellation
  - quire
---

# quire-02 — Dữ liệu + quy tắc + failure

> Submodule `designs/quire` @ `a97d862`. Ngày đọc: 2026-09-21. File nguồn chính: `designs/quire/README.md`, `designs/quire/design-notes.md`, `designs/quire/prototype.html` (126 keys `t()` EN/VI), `designs/quire/design-board.html`, `designs/quire/LICENSE`.

## §1 Screens — phạm vi dữ liệu từng cụm (chi tiết xem `constellation/quire-01`)

- Quan sát: cụm Đọc giữ bài viết + thư viện + hồ sơ cây viết; Khoảnh khắc giữ ảnh + người nhận + chuỗi đáp; Cài đặt 4 tầng; Tài khoản giữ hồ sơ + hoạt động + bản tối + trạng thái (board 4 cụm). Nếu dồn khoảnh khắc vào thư viện bài sẽ phá tách bạch 2 không gian.
- Chưa rõ — hỏi Lead: "theo dõi" cây viết và "chia sẻ riêng" vòng bạn có phải 2 quan hệ khác nhau (board vẽ cả nút theo dõi lẫn gửi ảnh ở trang cây viết). Nếu gộp 1 quan hệ, người theo dõi có thể thấy ảnh riêng tư (lỗi nghiêm trọng).

## §2 Flows — vòng đời hiển thị (quan sát, không suy diễn lưu trữ)

- Quan sát: bài viết feed → trình đọc → lưu → thư viện (chờ đọc / bộ sưu tập / đã đọc xong tháng) (board Reading + màn Saved). Nếu thiếu "đã đọc xong tháng" thư viện không bao giờ gọn.
- Quan sát: ảnh chụp/chọn → chọn người + lời nhắn → đang gửi → đã gửi (trạng thái từng người) → chuỗi đáp ảnh (board Sharing + prototype). Nếu bỏ trạng thái từng người sẽ không biết ai đã nhận.
- Quan sát: hoạt động cũ tự xóa sau 30 ngày; khối "không có gì cũ hơn" ngay dưới danh sách (board Activity + prototype). Nếu giữ lâu hơn sẽ vi phạm vòng đời công bố.
- Quan sát: xóa khoảnh khắc là "xóa với mọi người" (VI "Xoá với mọi người") (prototype). Nếu chỉ xóa phía người xóa sẽ sai cam kết trên màn.
- Chưa rõ — hỏi Lead: hoàn tác gửi có thu hồi ảnh phía đã xem hay chỉ chặn phía chưa nhận (lời báo chỉ nói "không có gì rời khỏi ứng dụng"). Nếu đoán "thu hồi cả đã xem" mà không làm được sẽ hứa sai khả năng.

## §3 Data — nhóm quan sát + quy tắc prose

- Quan sát: nhóm bài viết — chuyên mục, tiêu đề, mô tả, cây viết, thời lượng đọc, số thích/bình luận/lưu; quy tắc: serif giữ giọng, mono giữ số liệu/nhãn/thời gian (prototype; design-notes). Nếu hiện số liệu bằng serif sẽ mất phân vai chữ.
- Quan sát: nhóm khoảnh khắc — người gửi, mốc tương đối, ảnh, chú thích; vòng chưa xem phân biệt bằng kiểu viền nét đứt (prototype; design-notes). Nếu dùng màu rực báo chưa xem sẽ phá quy tắc 1 accent.
- Quan sát: vòng bạn bè cố định 11 người (ghi chú trên màn + chip "+6" sau 5 avatar + "còn 3 lời mời") (prototype). Nếu mở vòng vượt 12 người không hỏi sẽ phá giả định nhóm 4–12 người.
- Quan sát: nhóm cài đặt — chủ đề 3 mức, cỡ chữ 3 mức, ngôn ngữ 2 mức (126 keys), công tắc thông báo/đọc/vận động, 3 mức ai xem, giờ im lặng 22:00–07:00, 3 người thân đi qua (prototype). Nếu thiếu mức nào sẽ không đủ lựa chọn đã vẽ.
- Quan sát: nhóm hoạt động — ai–làm gì–khi nào, tới "tuần trước", cũ tự xóa 30 ngày (board Activity). Nếu giữ lâu hơn sẽ vi phạm vòng đời.
- Quan sát: mọi tên người/bài/số liệu đều là mẫu, không phải người dùng thật; đây là bản khám phá, không phải sản phẩm phát hành (README; index.html bìa). Nếu mang số mẫu vào app thật sẽ hiện dữ liệu giả.
- Chưa rõ — hỏi Lead: ảnh mẫu mã cố định (`photo()` + seed picsum) giữ để đối chiếu hay thay ảnh thật khi dựng. Nếu giữ ảnh mẫu trong bản dựng sẽ rò rỉ demo ra sản phẩm.

## §4 States — đã vẽ vs đã hứa

- Quan sát: đã vẽ 4/9 — trống ("Nobody has shared anything yet" + nút gửi đầu tiên), tải (khung xương xám), lỗi offline ("You are offline" + "Saved pieces still work…" + "Try again"), khóa camera ("Camera access is off" + "Open settings" / "Library") (board States). Nếu thiếu 1 trong 4 sẽ thiếu trạng thái đã vẽ.
- Quan sát: đã hứa chưa vẽ — đang gửi, đã gửi, story hết hạn, chuỗi không trả lời, thư viện đã xóa, đổi theme giữa đọc (board States). Nếu nghiệm thu đòi cả 9 có hình sẽ sai phạm vi; nếu bỏ qua khi dựng sẽ thiếu trạng thái đã hứa.
- Quan sát: offline vẫn đọc được bài đã lưu ("Saved pieces still work. New moments arrive when the connection is back.") (board States). Nếu offline chặn cả bài đã lưu sẽ sai cam kết.
- Quan sát: ảnh mạng lỗi → gỡ ảnh, để khung nền có nhãn (`photo()` fallback prototype + README). Nếu để khung vỡ sẽ vi phạm quy tắc offline.
- Chưa rõ — hỏi Lead: nút "thử lại" offline tải lại cả ảnh hay chỉ chữ (board tĩnh). Nếu đoán "cả ảnh" mà mạng yếu sẽ treo màn tải.
- Chưa rõ — hỏi Lead: 5 trạng thái chưa vẽ dựng theo văn mẫu nào (không có chữ mẫu). Nếu tự viết chữ sẽ là chữ bịa.

## §5 Tokens — quy tắc dùng + công bố (SSOT ở README + `:root` prototype)

- Quan sát: editorial tĩnh — nền giấy ấm, serif, kẻ hairline thay bóng đổ, 1 accent tối đa 2 lần/màn (README). Nếu dùng bóng đổ/thêm lượt nhấn sẽ phá phong cách.
- Quan sát: cặp sáng/tối đầy đủ: giấy `#FBF9F5`/`#1A1612`, bề mặt `#FFFEFD`/`#25211C`, chữ 3 bậc, kẻ `#E8E3DB`/`#37322C`, nhấn nền nút `#E76136`/`#F0834E`, nhấn chữ/icon `#A52014`/`#FFA26E` (README + `:root` 2 block). Nếu đảo màu máy móc ra đen tuyền sẽ vi phạm "than ấm, không đen tuyền" (design-notes).
- Quan sát: Newsreader tiêu đề/nội dung; JetBrains Mono số liệu/nhãn/thời gian; bo 10–22px theo cấp (radio photo 10, plate 14, btn/field 13, card 18, sheet 22); chữ title 27/h3 19/body 14.5/small 13/meta 10/tab 9; text scale ts-1/ts-3; focus ring cam (README + `:root`). Nếu serif cho số liệu sẽ mất phân vai "giọng vs nhịp".
- Quan sát (chưa kiểm độc lập): tương phản 15.67:1 / 6.63:1 / 5.04:1 / 7.09:1 / nút 4.83:1 sáng và 6.91:1 tối (WCAG 2.2 AA); chạm ≥44px prototype (README). Nếu dùng công bố không đo lại sẽ sai khi audit.
- Quan sát (chưa kiểm độc lập): LICENSE MIT chỉ cho mã nguồn; thiết kế/nội dung/minh họa chỉ tham khảo–học tập, không dùng thương mại riêng. Nếu tách thiết kế bán riêng sẽ vi phạm phạm vi giấy phép.
- Quan sát: ảnh picsum mã cố định + Google Fonts cần mạng; mất mạng khung thành ô nền có nhãn (README). Nếu không vẽ fallback sẽ vỡ hình offline.

## §6 Copy — giọng + trích dẫn (EN+VI nguyên văn, không tự dịch)

- Quan sát: giọng quiet — đọc trọn bài, chia sẻ 1 ảnh đúng người, không thước đo chen vào; im lặng mặc định; tối giữ chất giấy (README; design-notes). Nếu viết copy marketing ồn ào sẽ phá giọng.
- Quan sát: VI dict đầy đủ (`vi:{}`): tab "Đọc/Khoảnh khắc/Khám phá/Bạn"; "Hôm nay ở Quire"; "Thứ Ba 14/09"; "5 mới hôm nay"; "Khoảnh khắc của bạn"; "Cũng hôm nay"; "phút đọc"; "ĐỌC"; "Từ những người bạn quen"; "Chỉ 11 người trong vòng thân thiết xem được"; "2 giờ trước"; "Trả lời/Giữ/Lưu/Đã lưu/Gửi"; "Kệ của biên tập"; "Đọc nhiều nhất tuần"; "Đã lưu"; "9 mục · 2 bộ sưu tập"; "Chưa đọc/Bộ sưu tập"; "Đã đọc xong tháng này". Nếu dùng bản dịch khác sẽ sai copy gốc.
- Quan sát: câu xem trước cỡ chữ "The azulejo facade is not decoration…" / "Mặt tiền azulejo không phải trang trí…" (prototype). Nếu gắn cứng mọi khung xem trước sẽ mang chữ mẫu design.
- Chưa rõ — hỏi Lead: số trong copy là mẫu cố định hay khớp dữ liệu thật. Nếu giữ số mẫu trong app thật sẽ hiện dữ liệu giả.

## §7 Rules / Not-do — cấm + quy tắc (nguyên văn ý)

- Quan sát: cấm đồ thị theo dõi/số đo quan hệ (số hóa bạn bè thành cuộc thi); cấm badge/streak (nợ tương tác); cấm thông báo thúc quay lại (mọi nhắc do người dùng bật); không gọi là mạng xã hội (đọc + chia sẻ riêng tư) (design-notes "Cố ý không làm"). Nếu thêm bất kỳ cái nào sẽ phá định vị.
- Quan sát: vòng chưa xem nét đứt không dải màu; bo 10–22px không viên thuốc; 1 accent duy nhất (design-notes quyết định). Nếu sai sẽ phá 3 quy tắc cùng lúc.
- Quan sát: V1→V2 — nội dung tự cuộn; avatar pastel hue mát; bo mềm toàn hệ; accent tươi hơn + 1 sắc phụ đúng 1 điểm; thêm settings 4 tầng + bản tối (design-notes). Nếu dựng theo V1 cũ sẽ thiếu settings/bản tối.
