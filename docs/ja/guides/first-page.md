---
nav_order: 20
nav_title: 最初の一歩
title: 最初のページ
description: front matter、セクション、アラートを使ってページを書きます。
sections:
  - front-matter
  - body
  - rules
  - {c: cta, name: next}
---
# 最初のページを書く

ページは先頭に小さな front matter ブロックがある Markdown ファイルです。残りはテーマが引き受けます。

> [!NOTE]
> このページは[英語の原文](../../../guides/first-page/)の翻訳です。内容が異なる場合は英語版が優先されます。

## Front matter

```yaml
---
title: Getting started
description: shown in search results and llms.txt
sections:
  - {c: features, name: highlights}
  - {c: cta, name: next}
---
```

`sections:` の各項目は、トップレベルの `##` 見出しに順番どおり対応します。普通の記事にするなら `sections:` を省きます。

## 本文

```markdown
# Getting started

One sentence that explains the page.

## Highlights

- **Fast** — Builds in under a second.
- **Plain** — Readable on GitHub.

## Next

[Install](../install/)
```

> [!NOTE]
> 最初の `##` より前のテキストがヒーローになります。リンクだけの段落はボタンになります。

## 1 分でわかるルール

| 使えるもの | 使えないもの |
|---|---|
| GFM の表、リスト、タスクリスト | 生の HTML と HTML コメント |
| 言語名が一語のフェンスコード | ページ本文の Liquid タグ |
| トップレベルの GitHub アラート | kramdown の属性と `{#id}` |
| `<https://…>` 形式の自動リンク | 裸の URL |

完全な一覧は [RULES.md](https://github.com/modootoday/jekyll-theme-modootoday/blob/main/RULES.md) にあります。

## 次へ

[コンポーネントを見る](../../components/) [インストールに戻る](../install/)
