---
nav_order: 50
nav_title: AI 向け
title: エージェント向け
description: AI エージェントのための Markdown ツイン、llms.txt、llms-full.txt。
sections:
  - twins
  - llms
  - {c: cta, name: next}
---
# エージェントが読める Markdown

すべてのページは 2 回公開されます。人のための HTML と、エージェントのための元の Markdown です。

> [!NOTE]
> このページは[英語の原文](../../../guides/agents/)の翻訳です。内容が異なる場合は英語版が優先されます。

## Markdown ツイン

`guide.md` というページは `/guide/index.md` でも配信され、その内容は本文とバイト単位で同一です。Jekyll 4 ではテーマのプラグインがツインを自動で作ります。

```yaml
plugins: [jekyll-theme-modootoday]
```

クラシックな GitHub Pages ビルドはプラグインを実行できないので、代わりに各ページの隣にスタブを置きます。

```yaml
# guide.md.txt
---
layout: twin
twin_of: guide.md
permalink: /guide/index.md
---
```

`twin_of` はスタブファイルからの相対パスです（`include_relative` で読み込みます）。スタブはページと同じフォルダーに置くか、`../` のパスを使ってください。サイトのソースの外や `_` フォルダーは指せません。

各 HTML ページは `rel="alternate" type="text/markdown"` でツインにリンクします。

## llms.txt

`/llms.txt` は [llmstxt.org](https://llmstxt.org) に従って、ある言語のすべてのページを一覧にします。`/llms-full.txt` はすべてのページ本文をつなげたものです。どちらも 1 行のスタブから作られます。

```yaml
---
layout: llms
---
```

このサイトで試せます: [llms.txt](../../llms.txt) と [llms-full.txt](../../llms-full.txt)。

## 次へ

[変更履歴](../../reference/changelog/) [ホーム](../../)
