---
layout: examples
title: コンポーネント
description: すべてのコンポーネントを、元の Markdown と実際の表示結果を並べて紹介します。
examples: [alerts, alerts-content, cards, cards-3, buttons, tabs, badges, keyboard, accordion, steps, steps-headings, timeline, timeline-list, figure, tables, code]
sections:
  - alerts
  - alerts-content
  - {c: features, name: cards, cols: 2}
  - {c: features, name: cards-3, cols: 3}
  - {c: cta, name: buttons}
  - {c: tabs, name: tabs}
  - badges
  - keyboard
  - {c: accordion, name: accordion}
  - {c: steps, name: steps}
  - {c: steps, name: steps-headings}
  - {c: timeline, name: timeline}
  - {c: timeline, name: timeline-list}
  - figure
  - tables
  - code
  - navigation
  - language-switcher
  - theme-toggle
  - search
  - breadcrumb-toc
  - pagination
  - posts
  - status
  - {c: cta, name: next}
---
# コンポーネント

どのコンポーネントも普通の Markdown です。各例では Markdown のソースと、同じソースからテーマが描いた実際の表示結果を続けて示します。表示結果はいまお使いのライト／ダークモードのままです。ソースをコピーして貼り付ければ同じ結果になります。github.com では素の要素として表示されます。

[キッチンシンクを開く](kitchen-sink/) [設定](../configuration/)

> [!NOTE]
> このページは[英語の原文](../../components/)の翻訳です。内容が異なる場合は英語版が優先されます。

## アラート

`status:available` GitHub のアラートが、言語に合った見出し付きのコールアウトになります。種類は note、tip、important、warning、caution の 5 つです。スクリーンリーダーはノート（`role="note"`）として読み上げます。

> [!NOTE]
> Useful information that users should know, even when skimming.

> [!TIP]
> Helpful advice for doing things better or more easily.

> [!IMPORTANT]
> Key information users need to know to achieve their goal.

> [!WARNING]
> Urgent info that needs immediate user attention to avoid problems.

> [!CAUTION]
> Advises about risks or negative outcomes of certain actions.

## 内容のあるアラート

アラートにはリストやコードも入れられます。マーカーの行にはほかの文字を書かないでください。

> [!TIP]
> Before you publish:
>
> - run `modootoday-check`
> - preview with `bundle exec jekyll serve`

## カード

`status:available` `c: features` セクションでは、**太字**で始まるリスト項目がカードになります。`cols: 2` か `cols: 3` で列数を決め、狭い画面では 1 列になります。

- **Plain Markdown** — Pages read well on github.com too.
- **With a badge** — Cards can carry status. `status:available`

## 3 列のカード

同じリストを `cols: 3` で書いた例です。

- **Alerts** — Five alert types.
- **Tabs** — Accessible code tabs.
- **Search** — Client-side search.

## ボタン

`status:available` リンクだけの段落がボタンになり、最初のリンクが主ボタンです。ヒーロー（最初の `##` の前）と `c: cta` セクションで使えます。

[Get started](../install/) [Read the configuration](../configuration/)

## タブ

`status:available` `c: tabs` セクションでは、`###` 見出しと直後のコードブロックが 1 つのタブになります。2 つ以上書いてください。矢印キーでタブを移動し、Home と End で先頭と末尾に移ります。JavaScript がなければすべてのブロックが見出しの下に表示されます。

### macOS

```sh
brew install ruby
```

### Linux

```sh
sudo apt install ruby-full
```

## バッジ

`status:available` 決まった接頭辞のコードスパンがバッジになります。status（available、partial、planned）、tag、since があります。ステータス記号はスクリーンリーダーから隠し、名前を読み上げます。

`status:available` `status:partial` `status:planned`

`tag:beta` `since:1.0`

## キーボードキー

`status:available` `since:1.0` kbd とコロンで始まるコードスパンがキーボードキーになります。キーは空白なしの `+` でつなぎます。

Open search with `kbd:Ctrl+K`, or press `kbd:/`.

## アコーディオン

`status:available` `since:1.0` `c: accordion` セクションでは、`###` 見出しが下の内容を開閉するボタン（`aria-expanded`）になります。Enter か Space で切り替えます。JavaScript がなければすべての答えが表示されます。

### Does it work without JavaScript?

Yes. Every answer stays visible under its question.

### Can an answer hold code?

```sh
bundle exec jekyll serve
```

## ステップ

`status:available` `since:1.0` `c: steps` セクションでは、番号付きリストが番号付きのステップになります。

1. Add the theme to `_config.yml`.
2. Write `index.md` in plain Markdown.
3. Run `bundle exec jekyll build`.

## 見出しで書くステップ

1 つのステップに複数行が必要なら、リストの代わりに `###` 見出しを使います。

### Install

Add `remote_theme` and the plugin.

### Publish

Push to `main` and turn on GitHub Pages.

## タイムライン

`status:available` `since:1.0` `c: timeline` セクションでは、`###` 見出しが線上の点になります。

### Install

Alerts, sections, cards and tabs.

### Check

Theme toggle, breadcrumb and table of contents.

## リストで書くタイムライン

番号付きリストでも書けます。

1. Install: alerts, sections and cards.
2. Write: design tokens and navigation.
3. Check: theme toggle and steps.

## 図

`status:available` `since:1.0` 画像だけの段落のあとに*強調*だけの段落が続くと、キャプション付きの図になります。代替テキストは必須です。

![A Markdown source on the left becomes a styled page on the right](../../assets/images/sample.svg)

*Markdown on the left, the rendered page on the right.*

## 表

`status:available` GFM の表は、狭い画面ではページからはみ出さず横にスクロールします。

| Key | Default | Description |
|---|---|---|
| `color_scheme` | `auto` | follow the OS or force light or dark |
| `badges` | `true` | turn status code spans into badges |

## コードブロック

`status:available` フェンスのコードブロックは構文が色分けされ、1 行目の末尾にコピーボタンが付きます。長い行はスクロールし、キーボードでもブロックに移動できます。

```ruby
Jekyll::Hooks.register :site, :post_write do |site|
  puts "Built #{site.pages.size} pages"
end
```

## ナビゲーション

`status:available` ヘッダーのメニューは `_data/nav/main.yml` から作られます。`items:` を持つ項目は広い画面でドロップダウンのグループになり、狭い画面ではメニューボタンが出ます。開いたメニューは Esc で閉じます。このページのヘッダーがその表示結果です。

```yaml
- {title: Install, url: /install/}
- {title: Components, url: /components/}
- title: More
  items:
    - {title: Public API, url: /api/}
```

## 言語切り替え

`status:available` `since:1.0` `languages:` と `language_switcher: header` を設定すると、ヘッダーに言語一覧を開く地球儀ボタンが出ます。言語が増えても幅は変わりません。言語名はそれぞれの言語で書かれ、現在の言語には `aria-current` が付きます。一覧は Esc で閉じます。このページのヘッダーの地球儀がその表示結果です。

```yaml
modootoday:
  languages: [en, ko, ja]
  language_switcher: header
```

## テーマ切り替え

`status:available` `since:1.0` ヘッダーのボタンでライトとダークを切り替え、選んだ設定を記憶します。どちらかに固定するには `color_scheme` を使います。このページのヘッダーのボタンがその表示結果です。

```yaml
modootoday:
  color_scheme: auto   # auto | light | dark
```

## 検索

`status:available` `since:1.0` `search.json` ファイルを使うクライアント検索がヘッダーに入ります（`role="search"`）。`kbd:Ctrl+K` か `kbd:/` で検索欄に移動します。サイトのルートに `search.json` を置くと有効になります。[このサイトのファイル](https://github.com/modootoday/jekyll-theme-modootoday/blob/main/docs/search.json)をコピーしてください。このページのヘッダーの検索欄がその表示結果です。

## パンくずリストと目次

`status:available` `since:1.0` ドキュメントページには、URL から作るパンくずリストと、`##`・`###` 見出しから作る目次が付きます。目次は広い画面では横に、狭い画面では折りたたみの箱に表示されます。レイアウトが付けるので、書くソースはありません。無効にするには `components` から `breadcrumb` か `toc` を外します。このページの上部と横がその表示結果です。

```yaml
modootoday:
  components: [callout, badge, hero, cta, card, tabs, code-copy, nav, pagination, theme-toggle]
```

## 前後のページ

`status:available` `since:1.0` ナビゲーションにあるページには、ナビゲーションの順に前後のページへのリンクが付きます。隠すにはフロントマターに `pagination: false` と書きます。このページの下部がその表示結果です。

```yaml
---
title: Components
pagination: false
---
```

## 投稿とアーカイブ

`status:available` `since:1.0` `layout: post` は日付、著者、タグを表示します（`p.mt-post-meta`）。

```yaml
---
layout: post
title: Hello
date: 2026-10-30
author: Won
tags: [release]
---
```

## ステータスの凡例

| バッジ | 意味 |
|---|---|
| `status:available` | 提供中で安定 |
| `status:partial` | 既知の制限あり |
| `status:planned` | ロードマップにある |

## 次へ

[キッチンシンク](kitchen-sink/) [設定](../configuration/)
