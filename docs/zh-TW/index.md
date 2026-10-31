---
toc: false
hero: {visual: showcase}
title: 首頁
description: 維持純 Markdown，在 GitHub、GitHub Pages 與 AI 代理中都清楚好讀的文件。
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# 文件始終是純 Markdown

jekyll-theme-modootoday 將標準的 GitHub Flavored Markdown 轉成簡潔的文件網站。同一個檔案在 github.com、GitHub Pages 上都清楚好讀，也能以 Markdown 版本提供給 AI 代理。

[開始使用](../guides/install/) [瀏覽元件](../components/) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## 為什麼選擇 modoo.today 主題

- **只用標準 Markdown** — 提示、表格、清單與程式碼區塊。頁面中不需要 HTML、Liquid 或 kramdown 擴充語法。
- **可在 GitHub Pages 上執行** — 僅用 Liquid 的佈景主題，支援經典的 `github-pages` 建置，其他情況則用 Jekyll 4。
- **方便代理讀取** — 每個頁面都有與原始檔逐位元組相同的 Markdown 版本，另有 `llms.txt` 與 `llms-full.txt`。

## 快速開始

### remote_theme

```yaml
remote_theme: modootoday/jekyll-theme-modootoday@v1.4.1
plugins: [jekyll-remote-theme]
```

### Gemfile

```ruby
gem "jekyll-theme-modootoday", "~> 1.4"
```

### _config.yml

```yaml
theme: jekyll-theme-modootoday
permalink: pretty
```

## 文件閱讀路線

1. 在 GitHub Pages 或 Jekyll 4 上[安裝](../guides/install/)佈景主題。
2. 用純 Markdown [撰寫第一個頁面](../guides/first-page/)。
3. 從[元件](../components/)與[元件總覽](../components/kitchen-sink/)中挑選。
4. 在[設定](../guides/configuration/)中調整，並以 token 與 `_sass` [自訂外觀](../guides/customize/)。
5. 透過 Markdown 版本與 `llms.txt` 讓頁面[方便代理讀取](../guides/agents/)。

> [!NOTE]
> 本頁譯自[英文原文](../)，內容如有出入，以英文為準。連結的指南目前只有英文版。

## 立即開始

[安裝佈景主題](../guides/install/) [檢視所有元件](../components/kitchen-sink/)
