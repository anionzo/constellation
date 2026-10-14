---
id: w6kiug
title: 'Workaround knowns CLI vỡ tiếng Việt: ghi file trực tiếp + validate'
layer: project
category: convention
status: active
confidence: high
lastVerified: '2026-09-29T10:45:39.403Z'
ttlDays: 365
sources:
  - AGENTS.md
  - .knowns/docs/constellation/s-01-quy-c-vit-docs-constellation.md
tags:
  - knowns
  - cli-bug
  - encoding
  - workflow
createdAt: '2026-09-21T12:39:55.851Z'
updatedAt: '2026-09-29T10:45:39.404Z'
---

**Workaround encoding tiếng Việt cho Knowns trên Windows (cập nhật 2026-09-29, đã verify):** MCP `knowns_docs` là kênh chính cho content dài (JSON an toàn UTF-8). CLI fallback dùng pwsh + here-string `@' '@` truyền multi-line OK; lưu ý PowerShell 5.1/native arg có nhúng `"` sẽ vỡ thành nhiều args (cobra `accepts 1 arg(s)`). **Cấm** ghi file `.knowns/docs` trực tiếp — mọi edit qua MCP/CLI để watcher ghi revision.
