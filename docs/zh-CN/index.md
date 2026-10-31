---
toc: false
hero: {visual: showcase}
title: 首页
description: 保持纯 Markdown，在 GitHub、GitHub Pages 和 AI 智能体中都清晰易读的文档。
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# 文档始终是纯 Markdown

jekyll-theme-modootoday 把标准的 GitHub Flavored Markdown 变成简洁的文档站点。同一个文件在 github.com、GitHub Pages 上都清晰易读，也能作为 Markdown 版本交给 AI 智能体。

[开始使用](../guides/install/) [浏览组件](../components/) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## 为什么选择 modoo.today 主题

- **只用标准 Markdown** — 提示、表格、列表和代码块。页面里不需要 HTML、Liquid 或 kramdown 扩展语法。
- **可在 GitHub Pages 上运行** — 仅用 Liquid 的主题，适配经典的 `github-pages` 构建，其他场景使用 Jekyll 4。
- **便于智能体读取** — 每个页面都有与源文件逐字节一致的 Markdown 版本，另有 `llms.txt` 和 `llms-full.txt`。

## 快速开始

### remote_theme

```yaml
remote_theme: modootoday/jekyll-theme-modootoday@v1.3.0
plugins: [jekyll-remote-theme]
```

### Gemfile

```ruby
gem "jekyll-theme-modootoday", "~> 1.3"
```

### _config.yml

```yaml
theme: jekyll-theme-modootoday
permalink: pretty
```

## 文档阅读路线

1. 在 GitHub Pages 或 Jekyll 4 上[安装](../guides/install/)主题。
2. 用纯 Markdown [编写第一个页面](../guides/first-page/)。
3. 从[组件](../components/)和[组件大全](../components/kitchen-sink/)中挑选。
4. 在[配置](../guides/configuration/)中调整，并用 token 和 `_sass` [自定义外观](../guides/customize/)。
5. 借助 Markdown 版本和 `llms.txt` 让页面[便于智能体读取](../guides/agents/)。

> [!NOTE]
> 本页译自[英文原文](../)，如有出入以英文为准。链接的指南目前只有英文版。

## 现在开始

[安装主题](../guides/install/) [查看全部组件](../components/kitchen-sink/)
