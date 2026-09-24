---
title: after-midnight-02 — Dữ liệu + quy tắc + failure
description: Nhóm dữ liệu quan sát after-midnight, vòng đời hiển thị, tokens/a11y, copy giọng văn, cấm kỵ + 5 failure-mode
createdAt: '2026-09-21T13:30:00.000Z'
updatedAt: '2026-09-24T16:29:36.635Z'
tags:
  - constellation
  - after-midnight
---

# after-midnight-02 — Dữ liệu + quy tắc + failure

> Submodule `designs/after-midnight` @ `003f822`. Ngày đọc: 2026-09-21. File nguồn chính: `designs/after-midnight/readme.md` + quét chuỗi ASCII 2 file HTML. Không trích khối tiếng Việt dài vì vỡ dấu mã hóa.

## §1 Screens — tóm tắt định hướng (chi tiết xem `constellation/after-midnight-01-flow`)

- Quan sát: 15 inventory item chia 3 chặng — khóa (Ngày, Chạng vạng), đêm (Nhà, Thành phố đêm + 6 điểm + Void), khép (Bình minh, Lưu trữ) + 2 màn trung gian chỉ-đọc (Thư niêm phong, Gương). Đây là cách gom inventory, không phải canonical definition của “không gian”.
- Nếu đoán sai: phân chặng sai, cổng giờ và điều hướng lệch.
## §2 Flows — vòng đời hiển thị (chi tiết xem `constellation/after-midnight-01-flow`)

- Quan sát: dữ liệu chỉ sống trong đêm, trừ Lưu trữ xem lại sau đêm; Void ngoại lệ — sống lúc viết rồi bị gỡ khỏi DOM khi thả. Quyền xem Lưu trữ ban ngày và draft lúc 05:00 vẫn `Chưa rõ — hỏi Lead`.
## §3 Data — nhóm quan sát + vòng đời hiển thị (văn xuôi, không tên field/kiểu)

- Quan sát: nhóm suy nghĩ ẩn danh (Café) = nội dung gõ tay + tâm trạng chọn sẵn (đang nghĩ, nhớ ai đó, đang làm việc, đang sáng tạo, nghĩ quá nhiều, trống rỗng) + mốc giờ; vòng đời: bản thảo → kiểm tra tối thiểu → gửi (có chờ) → thành sao → Lưu trữ nhóm suy nghĩ. Nếu đoán sai: thiếu tâm trạng/mốc giờ, suy nghĩ không vào lưu trữ.
- Quan sát: nhóm phát thanh (Radio) = trạng thái phát/im + đồng hồ đếm; vòng đời: phát → đếm → dừng; không sinh nội dung lưu trữ. Nếu đoán sai: coi Radio là nội dung lưu được, dựng kho thừa.
- Quan sát: nhóm trả lời riêng tư (Câu hỏi) = nội dung + mốc giờ; vòng đời: bản thảo → kiểm tra tối thiểu → giữ lại → Lưu trữ nhóm câu hỏi. Nếu đoán sai: lộ câu trả lời ra không gian chung, vi phạm riêng tư.
- Quan sát: nhóm thư tương lai (Bưu cục) = nội dung + chủ đề (công việc, tương lai, nơi chốn, ký ức, con người, thay đổi) + thời hạn (ngày mai / 7 / 30 ngày / 1 năm) kèm ngày mở dự kiến; vòng đời: viết → kiểm tra → niêm phong → khóa chỉ-đọc → Lưu trữ nhóm thư. Nếu đoán sai: sai mốc thời hạn hoặc cho sửa sau niêm phong, mất niềm tin.
- Quan sát: nhóm bầu trời (Đài thiên văn) = sao ghim + 2 chòm mẫu ("THE THINGS I NEVER SAID" 4 sao, "THE PLACES I MISS" 3 sao); vòng đời: ghim → chòm cá nhân → Lưu trữ nhóm bầu trời. Nếu đoán sai: mất chòm mẫu, màn rỗng trơ lần đầu mở.
- Quan sát: nhóm trút bỏ (Void) = đoạn văn tối đa 400 ký tự có đếm số; vòng đời: viết → thả → tan biến → không còn gì (viết lại được). Nếu đoán sai: lưu lại 1 ký tự Void cũng là vi phạm.
- Quan sát: nhóm xem lại (Lưu trữ) = 5 nhóm (đêm, thư, câu hỏi, bầu trời, suy nghĩ); nhóm rỗng hiện trạng thái rỗng riêng. Nếu đoán sai: gộp nhóm sai, không tìm lại được kỷ niệm.
- Chưa rõ — hỏi Lead: nội dung mẫu sẵn (suy nghĩ, chòm sao, tóm tắt lưu trữ) là hạt giống cố định hay ví dụ minh họa. Nếu đoán sai: ship nội dung designer thành dữ liệu người dùng thật.

## §4 States — vòng đời trạng thái

- Quan sát: cùng 1 nội dung đi qua rỗng → bản thảo → lỗi (quá ngắn) → chờ (chỉ Café thấy) → đã xong → khóa (thư) hoặc tan biến (Void). Nếu đoán sai: thiếu nấc trung gian, không hiểu vì sao nút không bấm được.
- Quan sát: quy ước toàn nguyên mẫu: đang tải, rỗng, lỗi, đã có dữ liệu, biên + tắt/mờ/nhấn (chú thích đầu nguyên mẫu). Nếu đoán sai: màn thiếu trạng thái, treo giao diện.
- Chưa rõ — hỏi Lead: màn nào có tải mô phỏng và chờ bao lâu (chỉ thấy Café lúc gửi). Nếu đoán sai: thừa/thiếu màn chờ, trải nghiệm chập chờn.

## §5 Tokens / a11y / offline (nguyên văn + tag kiểm chứng)

- **Quan sát token**: bảng màu và typography After Midnight được ghi nhận từ source; mọi số đo contrast/touch/focus/screen-reader/reduced-motion là `chưa kiểm độc lập`.
- **Quan sát asset**: prototype có thể dùng Google Fonts và fallback; không được gọi là zero-network tuyệt đối. Core flow, Void non-persistence và audio opt-in phải được test offline.
- **Production contract**: bundle/provision font, license, cache, screen-reader/keyboard và audio interruption là `PROPOSED/DEFERRED`; không dùng claim HTML như certification.
- Âm thanh chỉ phát sau opt-in; The Void không gửi dữ liệu qua mạng. Nếu đoán sai: mất accessibility/offline guarantee hoặc vi phạm privacy.
## §6 Copy — trích giọng

- Voice quote 1 (ASCII nguyên văn, nguyên mẫu): "The city is asleep." + "Somewhere, someone is awake." — cặp mở đầu định vị thế giới.
- Voice quote 2 (ASCII nguyên văn, nguyên mẫu): "Tomorrow feels strangely important." — mẫu suy nghĩ, giọng nhật ký nửa đêm.
- Quan sát: lời thoại màn dài là tiếng Việt văn chương trầm/riêng tư, mỗi màn 1 khối riêng (readme § "Chỉnh sửa"); không trích nguyên văn vì HTML vỡ dấu — người viết copy phải mở trực tiếp file trên trình duyệt. Nếu đoán sai: copy chữ vỡ dấu, sai chính tả toàn bộ giọng sản phẩm.

## §7 Rules — cấm kỵ + failure

- Cấm kỵ: (1) Không lưu bất cứ gì từ The Void. (2) Không sửa thư sau niêm phong. (3) Không gắn danh tính vào suy nghĩ Café. (4) Không thêm nút vào Sân thượng. (5) Không mở thế giới ngoài 00:00–05:00 (trừ mở sớm thử nghiệm ở Chạng vạng). (6) Không dùng vàng/đỏ ngoài điểm nhấn hiếm. (7) Không trích khối tiếng Việt dài từ bản đọc thô (vỡ dấu) — chỉ đọc trên trình duyệt.
- Failure 5 dòng: (1) số không gian đêm 5 vs 8 → kiểm thử/nghiệm thu đếm sai phạm vi, sót màn; (2) quyền xem Lưu trữ ban ngày không rõ → nhốt kỷ niệm sau 05:00 hoặc lộ nội dung đêm sai giờ; (3) số phận bản thảo dở khi hết giờ không định nghĩa → mất chữ đúng lúc giao thời; (4) dữ liệu mẫu chưa rõ hạt giống hay ví dụ → ship nội dung designer thành dữ liệu người dùng; (5) khẳng định offline/tương phản/trình đọc màn hình/giảm chuyển động đều `chưa kiểm độc lập` → coi đúng không thử sẽ tuyên bố accessibility sai khi audit.
