---
toc: false
hero: {visual: showcase}
title: Trang chủ
description: Tài liệu viết bằng Markdown thuần, dễ đọc trên GitHub, GitHub Pages và với các tác tử AI.
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# Tài liệu vẫn là Markdown thuần

jekyll-theme-modootoday biến GitHub Flavored Markdown chuẩn thành một trang tài liệu gọn gàng. Cùng một tệp đọc tốt trên github.com, trên GitHub Pages và dưới dạng bản Markdown cho các tác tử AI.

[Bắt đầu](../guides/install/) [Xem các thành phần](../components/) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## Vì sao chọn giao diện modoo.today

- **Chỉ Markdown chuẩn** — Cảnh báo, bảng, danh sách và khối mã. Trang của bạn không cần HTML, Liquid hay cú pháp mở rộng của kramdown.
- **Chạy trên GitHub Pages** — Giao diện chỉ dùng Liquid cho bản dựng `github-pages` cổ điển, và Jekyll 4 cho mọi trường hợp khác.
- **Tác tử dễ đọc** — Mỗi trang có một bản Markdown giống hệt tệp nguồn đến từng byte, cùng `llms.txt` và `llms-full.txt`.

## Bắt đầu nhanh

### remote_theme

```yaml
remote_theme: modootoday/jekyll-theme-modootoday@v1.1.1
plugins: [jekyll-remote-theme]
```

### Gemfile

```ruby
gem "jekyll-theme-modootoday", "~> 1.1"
```

### _config.yml

```yaml
theme: jekyll-theme-modootoday
permalink: pretty
```

## Lộ trình đọc tài liệu

1. [Cài đặt](../guides/install/) giao diện trên GitHub Pages hoặc Jekyll 4.
2. [Viết trang đầu tiên](../guides/first-page/) bằng Markdown thuần.
3. Chọn từ [các thành phần](../components/) và [trang tổng hợp thành phần](../components/kitchen-sink/).
4. Tinh chỉnh trong phần [cấu hình](../guides/configuration/) và [tùy biến giao diện](../guides/customize/) bằng token và `_sass`.
5. Giúp trang [dễ đọc với tác tử AI](../guides/agents/) nhờ bản Markdown và `llms.txt`.

> [!NOTE]
> Trang này được dịch từ [bản gốc tiếng Anh](../); nếu có khác biệt, bản tiếng Anh được ưu tiên. Các hướng dẫn được liên kết hiện chỉ có bằng tiếng Anh.

## Bắt đầu ngay

[Cài đặt giao diện](../guides/install/) [Xem mọi thành phần](../components/kitchen-sink/)
