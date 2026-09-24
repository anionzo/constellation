---
title: C-91 Backlog defer
description: 'Danh sách hoãn显式: backend/auth, motion chi tiết, audit WCAG full, prompt AI, deploy — ngoài phạm vi docs-only'
createdAt: '2026-09-21T13:45:00.000Z'
updatedAt: '2026-09-21T13:45:00.000Z'
tags:
  - constellation
  - backlog
---

# C-91 Backlog defer

> Các mục dưới đây KHÔNG thuộc đợt docs-only này. Ghi rõ để không ai tưởng đã có. Khi sang phase kiến trúc/implement, bốc từ đây ra.

## Defer có chủ đích

1. **Backend / auth / sync**: cả 4 prototype đều không có máy chủ, tài khoản, đồng bộ (readme quire/astraea/dream ghi rõ). Đã chốt quyết định kiến trúc: Triển khai bằng **Flutter (Dart)** đa nền tảng (Mobile & Web), áp dụng chiến lược **Hybrid Local-First** (mặc định lưu cục bộ trên máy qua SQLite/Hive/Isar) + hỗ trợ tùy chọn đồng bộ hóa lên Database online của người dùng khi người dùng muốn đồng bộ đa thiết bị (xem memory `blhhrm` & @doc/ARCHITECTURE).
2. **Toàn văn copywriting tiếng Việt**: docs chỉ giữ chuỗi ngắn + 1–2 quote giọng/app. Thu thập toàn văn (đặc biệt after-midnight/astraea vỡ dấu HTML) là việc biên tập riêng, phải đọc trên trình duyệt.
3. **Motion spec chi tiết**: docs chỉ ghi quy tắc (chậm/tiết chế/reduced-motion). Thông số easing/duration từng hiệu ứng (vén lớp, nứt kính, chòm sao nối) để dành phase motion.
4. **Audit WCAG đầy đủ**: mọi con số tương phản/chạm trong docs đều `chưa kiểm độc lập`. Cần đo lại bằng thiết bị + công cụ trước release.
5. **Prompt design cho AI reflection** (dream chiêm nghiệm, astraea diễn giải): docs chỉ ghi khung phản chiếu + cấm tiên tri. Prompt thật, guardrail, đánh giá chất lượng là việc riêng.
6. **Analytics**: cả 4 app đều cấm đo đếm hành vi theo triết lý (no streak, no follower, quiet). Mọi đề xuất analytics phải qua Lead + đối chiếu danh sách cấm từng app.
7. **Chiến lược offline** (picsum/Google Fonts, font fallback, ảnh mẫu mã cố định): docs chỉ ghi fallback quan sát được. Quyết định self-host font/ảnh để dành phase kiến trúc.
8. **Deploy Pages / phân phối**: readme quire/dream gợi ý GitHub Pages để xem demo. Pipeline build/release bản production để dành sau.
9. **Dữ liệu hạt giống vs ví dụ**: nội dung mẫu sẵn trong prototype (suy nghĩ, chòm sao, bài đọc ví dụ, số liệu quire) chưa phân loại hạt-giống/ví-dụ — Lead chốt trước khi implement (xem failure từng app-02).
10. **Nâng cấp knowns CLI**: bản 0.18.3 vỡ encoding UTF-8 + sinh slug từ content (xem memory `w6kiug`). Mọi docs đợt này ghi file trực tiếp UTF-8 + validate tay. Khi CLI sửa xong, kiểm tra lại pipeline tạo doc.
