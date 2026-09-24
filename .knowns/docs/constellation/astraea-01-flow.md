---
title: astraea-01 — Flow + màn hình + trạng thái
description: 'Đối chiếu đếm màn astraea (18/16/14/13) + inventory luồng nghi thức tarot: hỏi, chọn trải, xòe, lật, kết quả, lưu'
createdAt: '2026-09-21T13:30:00.000Z'
updatedAt: '2026-09-21T13:30:00.000Z'
tags:
  - constellation
  - astraea
---

# astraea-01 — Flow + màn hình + trạng thái

> Submodule `designs/astraea` @ `047351d`. Ngày đọc: 2026-09-21. File nguồn chính: `designs/astraea/readme.md`, `V2 astraea-bản đồ toàn cảnh.html`, `V2 astraea-nguyên mẫu tương tác.html`. Lưu ý: HTML vỡ dấu tiếng Việt nhiều đoạn — chỉ trích nguyên văn từ readme + chuỗi ASCII đọc rõ.

## Đối chiếu số màn (ghi cả các số, chốt tạm)

| Nguồn | Con số tự xưng | Đếm thực tế quan sát |
|---|---|---|
| readme.md (dòng 11) | 18 màn hình | Không đếm được (chỉ bảng mô tả) |
| Bản đồ toàn cảnh (chú thích + tag) | 16 màn hình | Đếm được 18 panel vẽ trên canvas (nhãn "Đăng nhập" tới "Hồ sơ") |
| Nguyên mẫu (chú thích) | "screens: 13" nhưng liệt kê 14 tên | Đếm được 16 tuyến điều hướng (chào đón, đăng nhập, đăng ký, ngày sinh, mối quan tâm, trang chủ, hỏi, chọn trải, xòe, lật, kết quả, chi tiết lá, bộ bài, hoàng đạo, nhật ký, hồ sơ) |

- Quan sát: bản đồ vẽ 18 panel nhưng tag/chú thích cùng file ghi 16; nguyên mẫu chú thích 13 nhưng liệt kê 14 tên và cài 16 tuyến. Nếu đoán sai: thiếu/thừa màn, backlog lệch thiết kế.
- Chưa rõ — hỏi Lead: số nào là chuẩn hợp đồng (18/16/14/13)? Giả thuyết tạm: 18 panel thắng cho kiểm kê hiển thị, 16 tuyến thắng cho điều hướng khả bấm (đăng nhập/đăng ký chung khung, danh sách + chi tiết cung gộp 1 tuyến, trạng thái trống là chế độ xem trong Nhật ký). Nếu đoán sai: gộp nhầm màn cần tách hoặc tách màn chung khung, ước lượng vỡ.

## §1 Screens — inventory

| Màn | Vào từ đâu | Ra tới đâu | Dữ liệu vào (quan sát) | Dữ liệu ra (quan sát) | Bị chặn khi nào | Rỗng / Tải / Lỗi / Khóa |
|---|---|---|---|---|---|---|
| Chào đón | Quan sát: màn đầu mặc định | Quan sát: Đăng nhập, Đăng ký | Quan sát: không | Quan sát: lựa chọn cửa vào | Quan sát: không | Không thấy trạng thái đặc biệt |
| Đăng ký | Quan sát: Chào đón; link "chưa có tài khoản" từ Đăng nhập | Quan sát: Ngày sinh (khi tạo xong) | Quan sát: tên, email, mật khẩu, đồng ý điều khoản | Quan sát: báo đã tạo (toast) | Quan sát: khóa khi email sai định dạng, mật khẩu <6 ký tự, tên quá ngắn, chưa đồng ý điều khoản | Khóa nút; vùng báo lỗi khi gửi sai |
| Đăng nhập | Quan sát: Chào đón; link từ Đăng ký | Quan sát: Trang chủ (khi xong) | Quan sát: email, mật khẩu | Quan sát: chào mừng trở lại (toast) | Quan sát: khóa khi email sai định dạng hoặc mật khẩu quá ngắn | Khóa nút; link quên mật khẩu (chỉ thấy link, chưa rõ đích) |
| Ngày sinh → Cung | Quan sát: Đăng ký xong | Quan sát: Mối quan tâm / Trang chủ | Quan sát: ngày–tháng–năm đã chọn (điền sẵn ngày ví dụ) | Quan sát: cung tự cập nhật theo ngày | Quan sát: không thấy khóa | Không thấy trạng thái đặc biệt |
| Mối quan tâm | Quan sát: Ngày sinh | Quan sát: Trang chủ (hoàn tất) | Quan sát: chủ đề đã chạm chọn | Quan sát: tập chủ đề đã chọn | Quan sát: khóa khi chưa chọn gì | Khóa nút |
| Trang chủ / Khám phá | Quan sát: Đăng nhập; hoàn tất onboarding; thanh tab | Quan sát: Hỏi (rút bài), Bộ bài, Hoàng đạo, Nhật ký, Hồ sơ, Chi tiết lá (lá hôm nay) | Quan sát: cung hiện tại, lá hôm nay, 2 bài đọc gần nhất | Quan sát: lựa chọn điểm đến; lối tắt rút bài theo cung | Quan sát: không | Không thấy trạng thái đặc biệt |
| Hỏi điều muốn biết | Quan sát: Trang chủ; thanh tab (bắt đầu lại, xóa lựa chọn cũ) | Quan sát: Chọn kiểu trải | Quan sát: câu hỏi đã gõ, gợi ý chạm (điền sẵn câu mẫu) | Quan sát: câu hỏi đã chốt | Quan sát: khóa khi ô hỏi trống | Khóa nút; dòng gợi ý dưới ô nhập |
| Chọn kiểu trải | Quan sát: màn Hỏi | Quan sát: Xòe bài | Quan sát: kiểu đã chọn (4 kiểu: một lá; ba lá quá khứ–hiện tại–tương lai; tình yêu; công việc) | Quan sát: kiểu + số lá cần rút | Quan sát: không thấy khóa (luôn có kiểu mặc định) | Kiểu đang chọn tô sáng |
| Xòe bài – chọn lá | Quan sát: Chọn kiểu trải (nút rút bài) | Quan sát: Lật bài | Quan sát: lá đã chạm trong dải xòe | Quan sát: tập lá đủ số lượng | Quan sát: khóa nút lật khi chưa đủ số lá | Khóa nút; đếm số lá đã chọn |
| Lật bài (từng lá) | Quan sát: Xòe bài | Quan sát: Kết quả (sau lá cuối) | Quan sát: thứ tự lật, vị trí mỗi lá, mặt xuôi/ngược | Quan sát: tập lá đã lật | Quan sát: không thấy khóa; có xem lại lá trước | Chưa rõ — hỏi Lead: có tải giữa các lá không |
| Thông điệp kết quả | Quan sát: lật xong lá cuối (chờ "đang đọc thông điệp" chốc lát) | Quan sát: Nhật ký (sau lưu); rút lại | Quan sát: lá đã rút, câu hỏi gốc | Quan sát: bài mới lên đầu Nhật ký; báo đã lưu | Quan sát: nút lưu đổi trạng thái sau lưu (tránh trùng) | Tải ngắn trước kết quả; nút thành "đã lưu" |
| Chi tiết lá bài | Quan sát: Kết quả; Bộ bài; Hoàng đạo (lá liên kết); Trang chủ (lá hôm nay) | Quan sát: quay lại màn trước; rút bài với lá này; lưu (ngôi sao) | Quan sát: lá đang xem, mặt xuôi/ngược, ngăn diễn giải đang mở (4 ngăn) | Quan sát: lựa chọn rút/lưu | Quan sát: không | Nội dung đổi theo công tắc xuôi/ngược |
| Bộ bài (78 lá) | Quan sát: Trang chủ; thanh tab | Quan sát: Chi tiết lá | Quan sát: bộ lọc (tất cả / Ẩn Chính / Ẩn Phụ / đã lưu) | Quan sát: lá được chọn | Quan sát: không | Dòng đếm số lá đang hiện; chưa rõ lọc "đã lưu" trống hiện gì — hỏi Lead |
| Hoàng đạo (12 cung) | Quan sát: Trang chủ; thanh tab; Hồ sơ (cung của tôi) | Quan sát: Chi tiết cung; rút bài cho cung đang xem | Quan sát: cung đang chọn | Quan sát: cung đã chọn; lối tắt rút bài | Quan sát: không | Cung đang chọn tô sáng |
| Chi tiết cung – lá cặp | Quan sát: chạm cung trong danh sách | Quan sát: Chi tiết lá liên kết; rút bài | Quan sát: cung đang xem | Quan sát: lá Ẩn Chính tương ứng + diễn giải ngắn | Quan sát: không | Chưa rõ — hỏi Lead: màn riêng hay chế độ xem trong màn 14 (bản đồ vẽ riêng, nguyên mẫu gộp). Nếu đoán sai: tách/gộp sai component, back sai |
| Nhật ký | Quan sát: thanh tab; Trang chủ; Kết quả (sau lưu) | Quan sát: rút bài đầu tiên (khi trống); xem bài đọc | Quan sát: 2 ngăn (bài đọc / ghi chú) | Quan sát: bài đã lưu; ghi chú mới | Quan sát: nút thêm ghi chú khóa khi ô trống | Rỗng có minh họa + nút rút bài / dòng trấn an ghi chú |
| Trạng thái trống (panel bản đồ) | Quan sát: chỉ vẽ trong bản đồ, không phải tuyến riêng | — | — | — | — | Quan sát: bản đồ vẽ như 1 màn nhưng nguyên mẫu cài là chế độ xem trong Nhật ký. Nếu đoán sai: tạo màn không ai tới |
| Hồ sơ | Quan sát: thanh tab | Quan sát: cung của tôi (sang Hoàng đạo); xem lại trạng thái trống Nhật ký (nút xóa) | Quan sát: cung, ngày sinh, bộ đếm (bài đọc / đã lưu / chuỗi ngày) | Quan sát: nhật ký rỗng sau xác nhận xóa (2 chạm: gài rồi xóa) | Quan sát: nút xóa đòi xác nhận 2 chạm | Dòng giải thích nút xóa dùng xem lại trạng thái trống |

## §2 Flows — luồng nghi thức

- Quan sát: 6 bước readme (dòng 25): hỏi → chọn trải → xòe/chọn → lật từng lá → thông điệp → lưu Nhật ký; nguyên mẫu cài đúng thứ tự. Nếu đoán sai (chọn trải trước hỏi): vỡ ý đồ "càng rõ điều hỏi, thông điệp càng sát".
- Quan sát: rút mới từ tab xóa lựa chọn cũ (reset khi chạm tab rút bài). Nếu đoán sai: bài mới lẫn lá cũ, kết quả sai.
- Chưa rõ — hỏi Lead: có lưu nháp giữa chừng (thoát ở Lật rồi quay lại) hay thoát là mất. Nếu đoán sai: mất bài đọc hoặc gánh cơ chế nháp không ai yêu cầu.

## §3 Data — xem `constellation/astraea-02`

## §4 States — khóa nút khi thiếu thông tin (tạo tài khoản, đăng nhập, hoàn tất onboarding, tiếp tục sau hỏi, lật bài chưa đủ lá, thêm ghi chú); tải ngắn trước kết quả; rỗng Nhật ký có minh họa + nút rút bài; lỗi đỏ dưới form đăng nhập/đăng ký. Chưa rõ: 2 bài đọc ví dụ + 1 lá "hôm nay" bản production giữ gì — hỏi Lead (demo lọt bản thật nếu đoán sai).

## §5 Tokens — xem `constellation/astraea-02`

## §6 Copy

- Quan sát (readme nguyên văn): "studio Tarot trong túi" (dòng 3); "mỗi lá bài mang chòm sao hoàng đạo vẽ ngay bên trong tranh" (dòng 5); công tắc "Xuôi / Ngược" (dòng 26); lọc "Ẩn Chính / Ẩn Phụ / Đã lưu" (dòng 27). Nếu đoán sai: sai thuật ngữ signature.
- Quan sát (giọng, readme): "nơi nghi thức rút bài diễn ra chậm rãi như một buổi lễ riêng tư" (dòng 3); "giọng thơ nhưng có đất, không tiên tri, không gieo sợ" (dòng 38). Không sao chép hàng loạt HTML vì vỡ dấu.

## §7 Rules

- Quan sát: toàn bộ lời thoại/diễn giải tiếng Việt; khung phản chiếu, không tiên tri, không gieo sợ (dòng 38). Nếu đoán sai: nội dung chệch định vị, rủi ro gieo sợ.
- Quan sát: đây là thiết kế giao diện, không máy chủ, không tài khoản thật, bài đọc mẫu chỉ ví dụ (dòng 42). Nếu đoán sai: tưởng đã có backend/auth thật.
- Quan sát: tranh lá vector đồng bộ 78 lá, không ảnh ngoài (dòng 35). Nếu đoán sai: ảnh rời lệch phong cách.
- Chưa rõ — hỏi Lead: "quên mật khẩu", "cài đặt thông báo", "Premium sắp ra mắt", "trợ giúp & phản hồi" có thuộc bản đầu không. Nếu đoán sai: màn mồ côi không ai duyệt.
