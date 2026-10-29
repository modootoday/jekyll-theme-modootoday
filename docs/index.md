---
toc: false
title: Home
description: Plain Markdown in, polished docs out — on GitHub, GitHub Pages and for AI agents.
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# Docs that stay plain Markdown

jekyll-theme-modootoday turns standard GitHub Flavored Markdown into a clean documentation site. The same file reads well on github.com, on GitHub Pages and as a Markdown twin for AI agents.

[Get started](install/) [Browse components](components/) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## Why modootoday

- **Only standard Markdown** — Alerts, tables, lists and code blocks. No HTML, no Liquid, no kramdown extras in your pages.
- **Works on GitHub Pages** — Liquid-only theme for the classic `github-pages` build, and Jekyll 4 for everything else.
- **Agent-readable** — Every page has a byte-identical Markdown twin, plus `llms.txt` and `llms-full.txt`.

## Quick start

### remote_theme

```yaml
remote_theme: modootoday/jekyll-theme-modootoday@v1.0.0
plugins: [jekyll-remote-theme]
```

### Gemfile

```ruby
gem "jekyll-theme-modootoday", "~> 1.0"
```

### _config.yml

```yaml
theme: jekyll-theme-modootoday
permalink: pretty
```

## Your path through the docs

1. [Install](install/) the theme on GitHub Pages or Jekyll 4.
2. [Write your first page](first-page/) with plain Markdown.
3. Pick from the [components](components/) and the [kitchen sink](components/kitchen-sink/).
4. Tune it in [configuration](configuration/) and [customize](customize/) the look with tokens and `_sass`.
5. Make it [readable by agents](agents/) with twins and `llms.txt`.

## Start now

[Install the theme](install/) [See every component](components/kitchen-sink/)
