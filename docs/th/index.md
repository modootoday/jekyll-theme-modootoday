---
toc: false
hero: {visual: showcase}
title: หน้าแรก
description: เอกสารที่ยังคงเป็น Markdown ธรรมดา อ่านง่ายทั้งบน GitHub, GitHub Pages และสำหรับเอเจนต์ AI
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# เอกสารที่ยังคงเป็น Markdown ธรรมดา

jekyll-theme-modootoday เปลี่ยน GitHub Flavored Markdown มาตรฐานให้เป็นเว็บไซต์เอกสารที่เรียบร้อย ไฟล์เดียวกันอ่านง่ายทั้งบน github.com บน GitHub Pages และในรูปแบบ Markdown สำหรับเอเจนต์ AI

[เริ่มต้นใช้งาน](../guides/install/) [ดูคอมโพเนนต์](../components/) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## ทำไมต้องธีม modoo.today

- **ใช้แค่ Markdown มาตรฐาน** — การแจ้งเตือน ตาราง รายการ และบล็อกโค้ด ไม่ต้องใช้ HTML, Liquid หรือส่วนเสริมของ kramdown ในหน้าเอกสาร
- **ใช้งานได้บน GitHub Pages** — ธีมที่ใช้เฉพาะ Liquid สำหรับการบิลด์ `github-pages` แบบดั้งเดิม และใช้ Jekyll 4 สำหรับกรณีอื่น
- **เอเจนต์อ่านได้ง่าย** — ทุกหน้ามีเวอร์ชัน Markdown ที่ตรงกับต้นฉบับทุกไบต์ พร้อม `llms.txt` และ `llms-full.txt`

## เริ่มต้นอย่างรวดเร็ว

### remote_theme

```yaml
remote_theme: modootoday/jekyll-theme-modootoday@v1.1.0
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

## เส้นทางการอ่านเอกสาร

1. [ติดตั้ง](../guides/install/)ธีมบน GitHub Pages หรือ Jekyll 4
2. [เขียนหน้าแรก](../guides/first-page/)ด้วย Markdown ธรรมดา
3. เลือกจาก[คอมโพเนนต์](../components/)และ[หน้ารวมคอมโพเนนต์](../components/kitchen-sink/)
4. ปรับแต่งใน[การตั้งค่า](../guides/configuration/) และ[ปรับหน้าตา](../guides/customize/)ด้วยโทเคนและ `_sass`
5. ทำให้[เอเจนต์อ่านได้](../guides/agents/)ด้วยเวอร์ชัน Markdown และ `llms.txt`

> [!NOTE]
> หน้านี้แปลจาก[ต้นฉบับภาษาอังกฤษ](../) หากเนื้อหาไม่ตรงกันให้ยึดฉบับภาษาอังกฤษ คู่มือที่ลิงก์ไว้มีเฉพาะภาษาอังกฤษ

## เริ่มเลย

[ติดตั้งธีม](../guides/install/) [ดูคอมโพเนนต์ทั้งหมด](../components/kitchen-sink/)
