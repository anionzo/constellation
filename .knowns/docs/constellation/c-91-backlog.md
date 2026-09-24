---
title: C-91 Backlog defer
description: 'Danh sách công việc bị hoãn có chủ đích, trạng thái DEFERRED và ranh giới chưa được phê duyệt: backend/auth/sync, AI, accessibility, offline assets, motion, analytics, deploy và seed data.'
createdAt: '2026-09-21T13:45:00.000Z'
updatedAt: '2026-09-24T16:21:43.808Z'
tags:
  - constellation
  - backlog
  - deferred
  - governance
---

## Defer có chủ đích

Trạng thái chung của các mục dưới đây là **DEFERRED**: chưa được phép coi là đã thiết kế, đã kiểm định hoặc sẵn sàng triển khai. Khi rời phạm vi docs-only, mỗi mục phải có một quyết định/ADR và acceptance criteria riêng.

1. **Backend / auth / sync**: Nền tảng backend/sync chính thức đã được chốt là **Supabase Self-Hosted (Docker)** theo quyết định người dùng ngày 2026-09-24 (xem @doc/architecture/backend-supabase-version-gating). Prototype giữ nguyên không backend; trên production, client Flutter chạy Local-First mặc định; Supabase cung cấp Auth (GoTrue), Sync (PostgREST/Realtime), Media/Avatar Storage và Version Gating chống kẹt cache. Chi tiết về consent, mã hóa đầu cuối và conflict resolution từng bảng dữ liệu sẽ được thiết lập trong phase triển khai. The Void tuyệt đối không đủ điều kiện để sync.
2. **Toàn văn copywriting tiếng Việt**: docs chỉ giữ chuỗi ngắn và 1–2 quote đại diện. Toàn văn copy, đặc biệt phần vỡ dấu trong HTML, phải được biên tập lại từ nguồn sạch.
3. **Motion spec chi tiết**: docs chỉ ghi nhịp chậm, tiết chế và reduced-motion; chưa chốt easing, duration hoặc motion blueprint.
4. **Audit WCAG / accessibility đầy đủ**: mọi số đo tương phản, touch target, focus, screen reader và keyboard trong docs đều `chưa kiểm độc lập`. Hợp đồng production dùng mốc 44px, nhưng độ lệch ở prototype phải được đo lại trước release.
5. **Prompt và dịch vụ AI reflection**: Dream Journal và Astraea chỉ có UX/copy phản chiếu trong prototype. Prompt, guardrail, provider, dữ liệu gửi đi, retention và đánh giá chất lượng chưa được chốt; không được gọi nội dung tĩnh là AI production.
6. **Analytics**: không thêm analytics, telemetry hoặc event tracking mặc định; mọi đề xuất phải đối chiếu Calm/anti-retention và C-90.
7. **Chiến lược offline và asset**: prototype có remote font/placeholder ở một số luồng; đây là dependency quan sát được, không phải production contract. Quyết định bundle font/asset, license và behavior khi mất mạng để dành phase kiến trúc.
8. **Deploy / phân phối**: prototype có thể mở bằng Pages/local server; pipeline build, release và phân phối production chưa chốt.
9. **Seed data vs fixture**: mọi nội dung mẫu phải được gắn nhãn `fixture` hoặc `production-approved`; không được tự chuyển dữ liệu designer thành dữ liệu người dùng.
10. **Knowns CLI/encoding**: MCP `knowns_update_doc`/`knowns_validate` là đường chính. Workaround ghi file trực tiếp chỉ là biện pháp tạm thời khi MCP không khả dụng, phải ghi rõ và validate ngay sau đó.

Mọi mục `Chưa rõ — hỏi Lead` trong C-90 và các app docs vẫn là câu hỏi sản phẩm, không được tự động chuyển thành quyết định khi sửa tài liệu.
