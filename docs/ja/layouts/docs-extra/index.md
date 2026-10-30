---
title: ドキュメント拡張
description: リファレンス、変更履歴、ロードマップ、用語集、ハブ、コース、書籍のページを共通の任意スタイルシート 1 つで作ります。
nav_order: 50
---
# ドキュメント拡張

マニュアルの周辺ページを作るレイアウトです。自分のページでだけ `modootoday-docs-extra.css` を読み込み、JavaScript は追加しません。どのレイアウトもタイトルとリード文の `description:` を読み、本文は生成部分の後に置かれます。

| レイアウト | front matter | 構造化データ | デモ |
|---|---|---|---|
| `reference` | `members: [{name, signature, text, since, id}]` | TechArticle | [リファレンス](/jekyll-theme-modootoday/ja/layouts/docs-extra/reference/) |
| `changelog` | `releases: [{version, date, url, added, changed, fixed, removed, security}]` | WebPage | [変更履歴](/jekyll-theme-modootoday/ja/layouts/docs-extra/changelog/) |
| `roadmap` | `items: [{title, status, text, url}]`、status は `now`、`next`、`later` | WebPage | [ロードマップ](/jekyll-theme-modootoday/ja/layouts/docs-extra/roadmap/) |
| `glossary` | `terms: [{term, text, id}]` | DefinedTermSet | [用語集](/jekyll-theme-modootoday/ja/layouts/docs-extra/glossary/) |
| `hub` | `cards: [{title, text, url}]` | CollectionPage | [ハブ](/jekyll-theme-modootoday/ja/layouts/docs-extra/hub/) |
| `course` | `level`、`modules: [{title, lessons: [{title, url, minutes}]}]` | Course | [コース](/jekyll-theme-modootoday/ja/layouts/docs-extra/course/) |
| `book` | `image`、`author`、`isbn`、`pages`、`chapters: [{title, url}]` | Book | [書籍](/jekyll-theme-modootoday/ja/layouts/docs-extra/book/) |

## 変更履歴

各リリースの変更を 5 つの分類見出しの下に決まった順で示し、見出しはページの言語で表示されます。項目は Markdown です。`modootoday-check` はそれ以外のキーを報告するので、`fix:` のような打ち間違いが黙って消えることはありません。

## 用語集

用語は自動で並べ替えられ、最初の文字でまとめられます。文字バーは使われている文字にだけリンクします。各用語にアンカー（`id:` または用語のスラッグ）が付き、ページデータでは DefinedTerm として並びます。

## コース

レッスンの `minutes` の合計が、タイトル下の合計時間と `timeRequired` になります。コースの提供者はサイトの発行者で、`description:` は必須です。

## 検査

`modootoday-check` は、各レイアウトの基になるリスト、正しい `status`、用語ごとの `text`、重複のない用語、ハブカードごとの `url`、整数の `minutes` と `pages`、10 桁または 13 桁の `isbn` を求めます。
