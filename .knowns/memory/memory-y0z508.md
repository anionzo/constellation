---
id: y0z508
title: ''
key: legacy-doc-id-inject-reconcile
layer: project
category: convention
status: active
confidence: high
lastVerified: '2026-09-29T11:16:56.656Z'
ttlDays: 365
sources:
  - .knowns/docs/README.md
  - AGENTS.md
tags:
  - knowns
  - legacy-doc
  - hash-conflict
  - reconcile
  - frontmatter
  - workflow
createdAt: '2026-09-29T11:16:56.656Z'
updatedAt: '2026-09-29T11:16:56.656Z'
---

**Legacy doc lock fix (verified 2026-09-29, knowns 0.34.1):** Doc legacy tạo trước khi có chuẩn `id:` frontmatter bị **khóa mutation vĩnh viễn** — mỗi update báo hash conflict với 2 giá trị hash khác nhau (0d97/bb49...) hoán đổi vai trò expected/current; `knowns reconcile` từ chối `missing stable Doc id`. **Cách sửa:** (1) lấy DOC_ID qua `knowns doc history <path>`, (2) chèn `id: <DOC_ID>` vào frontmatter file, (3) `knowns reconcile` (preview → OK), (4) update bình thường qua MCP/CLI. Đã áp dụng thành công cho `README` (legacy-887f5887d303a51f). ~29 doc legacy khác vẫn lock — lặp lại quy trình khi cần edit.
