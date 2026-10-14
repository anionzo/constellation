---
id: 75o6xd
title: Quire Article Visibility Scope and Soft-Expire Memory Rules
key: quire-article-visibility-scope-and-soft-expire-memory-rules
layer: project
category: convention
status: active
tags:
  - quire
  - backend-contract
  - rules
createdAt: '2026-10-14T09:04:38.120Z'
updatedAt: '2026-10-14T09:04:38.120Z'
---

Quy tắc nghiệp vụ cốt lõi của Quire: Bài viết tạp chí hỗ trợ 2 tầng phạm vi người đọc: Công khai (is_public=true, người chưa kết bạn cũng đọc được) và Vòng bạn bè (is_public=false). Cơ chế tự hủy khoảnh khắc là ẩn mềm (soft-expire) khỏi feed bạn bè sau thời hạn nhưng bảo toàn dữ liệu trong kho lưu trữ riêng của tác giả, cho phép khôi phục lại feed hoặc xóa vĩnh viễn theo ý muốn. Mọi thực thể đã lưu đều hỗ trợ thao tác xóa/bỏ lưu hai chiều.
