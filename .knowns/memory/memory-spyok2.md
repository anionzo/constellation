---
id: spyok2
title: Flutter Web Material Icons and Mouse Drag Scrolling Convention
key: flutter-web-material-icons-and-mouse-drag-scrolling-convention
layer: project
category: convention
status: active
tags:
  - flutter
  - web
  - scrolling
  - icons
createdAt: '2026-10-14T08:14:05.738Z'
updatedAt: '2026-10-14T08:14:05.738Z'
---

Để Flutter Web hiển thị đầy đủ Material Icons, pubspec.yaml bắt buộc phải khai báo uses-material-design: true. Để danh sách cuộn ngang (như hàng avatar bạn bè) có thể bấm giữ chuột kéo lướt (mouse drag scrolling) mượt mà trên desktop/web, MaterialApp phải được cấu hình AppScrollBehavior kế thừa MaterialScrollBehavior với dragDevices bao gồm PointerDeviceKind.mouse.
