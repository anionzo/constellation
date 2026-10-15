---
id: DFA-C9GZ34
title: Triển khai Golang Realtime SSE Hub và luồng chat đúng người
status: done
priority: high
labels:
  - backend
  - realtime
  - sse
  - chat
  - invariants
createdAt: '2026-10-15T06:37:47.301Z'
updatedAt: '2026-10-15T06:37:47.301Z'
completedAt: '2026-10-15T06:37:47.301Z'
timeSpent: 0
---
# Triển khai Golang Realtime SSE Hub và luồng chat đúng người

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Thiết kế và hiện thực hóa RealtimeHub (Server-Sent Events) bằng Golang channels và mutex thread-safe, thay thế toàn bộ polling timers. Đảm bảo bất biến lọc tin nhắn đúng người đúng hội thoại (sender_id và recipient_id) với độ trễ < 5ms.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

