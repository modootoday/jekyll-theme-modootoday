---
nav_order: 0
nav_title: コンポーネント
layout: examples
title: コンポーネント
description: すべてのコンポーネントを、元の Markdown と実際の表示結果を並べて紹介します。
examples: [alerts, alerts-content, cards, cards-3, buttons, tabs, badges, keyboard, accordion, steps, steps-headings, timeline, timeline-list, figure, tables, code, code-titles, progress, embeds, loading, filetree, details, faq, params, linkcards, quote, gallery, pricing, subscribe, split]
sections:
  - alerts
  - alerts-content
  - {c: features, name: cards, cols: 2}
  - {c: features, name: cards-3, cols: 3}
  - {c: features, name: cards-4, cols: 4}
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
  - code-titles
  - progress
  - embeds
  - loading
  - {c: filetree, name: filetree}
  - {c: details, name: details}
  - {c: faq, name: faq}
  - {c: params, name: params}
  - {c: linkcards, name: linkcards}
  - {c: quote, name: quote}
  - {c: gallery, name: gallery}
  - {c: pricing, name: pricing, recommended: 2}
  - {c: subscribe, name: subscribe}
  - {c: split, name: split, visual: split-demo, decor: decor-demo, tag: "イラスト", side: start, ratio: "5:7", label: "見出し、2 行のテキスト、ボタンがある画面"}
  - lists
  - navigation
  - language-switcher
  - theme-toggle
  - icons
  - search
  - breadcrumb-toc
  - pagination
  - posts
  - status
  - {c: cta, name: next}
---
# コンポーネント

どのコンポーネントも普通の Markdown です。各例では Markdown のソースと、同じソースからテーマが描いた実際の表示結果を続けて示します。表示結果はいまお使いのライト／ダークモードのままです。ソースをコピーして貼り付ければ同じ結果になります。github.com では素の要素として表示されます。

[キッチンシンクを開く](kitchen-sink/) [設定](../guides/configuration/)

> [!NOTE]
> このページは[英語の原文](../../components/)の翻訳です。内容が異なる場合は英語版が優先されます。

## アラート

`status:available` GitHub のアラートが、言語に合った見出し付きのコールアウトになります。種類は note、tip、important、warning、caution の 5 つです。スクリーンリーダーはノート（`role="note"`）として読み上げます。

> [!NOTE]
> 流し読みでも知っておくべき有用な情報です。

> [!TIP]
> より良く、より簡単に進めるための助言です。

> [!IMPORTANT]
> 目的を達成するために知っておくべき重要な情報です。

> [!WARNING]
> 問題を避けるためにすぐ注意が必要な緊急の情報です。

> [!CAUTION]
> 特定の操作のリスクや悪い結果について注意を促します。

## 内容のあるアラート

アラートにはリストやコードも入れられます。マーカーの行にはほかの文字を書かないでください。

> [!TIP]
> 公開する前に:
>
> - `modootoday-check` を実行する
> - `bundle exec jekyll serve` でプレビューする

## カード

`status:available` `c: features` セクションでは、**太字**で始まるリスト項目がカードになります。`cols: 2`、`cols: 3`、`cols: 4` で列数を決め、狭い画面では 1 列になります。`cols: 4` は中くらいの幅の画面では 2 列になります。

- **プレーンな Markdown** — github.com でも読みやすいページになります。
- **バッジ付き** — カードにステータスを付けられます。 `status:available`

## 3 列のカード

同じリストを `cols: 3` で書いた例です。

- **アラート** — 5 種類のアラート。
- **タブ** — アクセシブルなコードタブ。
- **検索** — クライアントサイド検索。

## 4 列のカード

広い画面で `cols: 4` を使った例です。

- **アラート** — 5 種類のアラート。
- **タブ** — アクセシブルなコードタブ。
- **検索** — クライアント側の検索。
- **カード** — 2 列から 4 列のグリッド。

## ボタン

`status:available` リンクだけの段落がボタンになり、最初のリンクが主ボタンです。ヒーロー（最初の `##` の前）と `c: cta` セクションで使えます。

[はじめる](../guides/install/) [設定を読む](../guides/configuration/)

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

`status:available` 決まった接頭辞のコードスパンがバッジになります。status（available、partial、planned）と tag があります。ステータス記号はスクリーンリーダーから隠し、名前を読み上げます。

`status:available` `status:partial` `status:planned`

`tag:beta`

## キーボードキー

`status:available` kbd とコロンで始まるコードスパンがキーボードキーになります。キーは空白なしの `+` でつなぎます。

`kbd:Ctrl+K` か `kbd:/` で検索を開きます。

## アコーディオン

`status:available` `c: accordion` セクションでは、`###` 見出しが下の内容を開閉するボタン（`aria-expanded`）になります。Enter か Space で切り替えます。JavaScript がなければすべての答えが表示されます。

### JavaScript なしでも動きますか?

はい。すべての答えが質問の下に表示されたままになります。

### 答えにコードを入れられますか?

```sh
bundle exec jekyll serve
```

## ステップ

`status:available` `c: steps` セクションでは、番号付きリストが番号付きのステップになります。

1. `_config.yml` にテーマを追加します。
2. プレーンな Markdown で `index.md` を書きます。
3. `bundle exec jekyll build` を実行します。

## 見出しで書くステップ

1 つのステップに複数行が必要なら、リストの代わりに `###` 見出しを使います。

### インストール

`remote_theme` とプラグインを追加します。

### 公開

`main` にプッシュして GitHub Pages を有効にします。

## タイムライン

`status:available` `c: timeline` セクションでは、`###` 見出しが線上の点になります。

### インストール

アラート、セクション、カード、タブ。

### 確認

テーマ切り替え、パンくずリスト、目次。

## リストで書くタイムライン

番号付きリストでも書けます。

1. インストール: アラート、セクション、カード。
2. 執筆: デザイントークン、ナビゲーション。
3. 確認: テーマ切り替え、ステップ。

## 図

`status:available` 画像だけの段落のあとに*強調*だけの段落が続くと、キャプション付きの図になります。代替テキストは必須です。

![左の Markdown ソースが右のスタイル付きページになる](../../assets/images/sample.svg)

*左が Markdown、右が表示結果です。*

## 表

`status:available` GFM の表は、狭い画面ではページからはみ出さず横にスクロールします。

| キー | 既定値 | 説明 |
|---|---|---|
| `color_scheme` | `auto` | OS に合わせるか、ライトかダークに固定する |
| `badges` | `true` | ステータスのコードスパンをバッジに変換する |

## コードブロック

`status:available` フェンスのコードブロックは構文が色分けされ、1 行目の末尾にコピーボタンが付きます。長い行はスクロールし、キーボードでもブロックに移動できます。

```ruby
Jekyll::Hooks.register :site, :post_write do |site|
  puts "Built #{site.pages.size} pages"
end
```

## コードのタイトルと diff

`status:available` フェンスのコードブロックの直前に、file とコロンで始まるコードスパンだけの行を置くと、ブロックのタイトルバーになります。`diff` ブロックは追加行と削除行に色を付け、プラスとマイナスの記号を残します。

`file:_config.yml`

```yaml
theme: jekyll-theme-modootoday
```

```diff
- remote_theme: old/theme
+ theme: jekyll-theme-modootoday
```

## 進捗

`status:available` progress とコロンのあとに 0 から 100 の整数が続くコードスパンは、値をテキストでも示すラベル付きの進捗バーになります。

翻訳 `progress:60`

## 埋め込み

`status:available` embed とコロン、https の URL、任意のタイトルからなるコードスパンだけの段落は、遅延読み込みされる 16:9 のフレームになり、読み込み中も領域を確保します。

`embed:https://modootoday.github.io/jekyll-theme-modootoday/assets/images/sample.svg サンプルページの図`

## 読み込み表示とスケルトン

`status:available` loading または skeleton とコロンで始まるコードスパンは、スピナー、細い上部バー、プレースホルダー（text、card、image、avatar、row）になります。それぞれ `role="status"` とスクリーンリーダー向けの読み込みラベルが付き、利用者が視差効果を減らす設定にしていると動きません。スタイルは別のスタイルシートにあり、使うページだけが読み込みます。

`loading:spinner`

`skeleton:avatar`
`skeleton:text`
`skeleton:card`

## ファイルツリー

`status:available` `c: filetree` セクションでは、入れ子のリストがフォルダーツリーとして描かれます。入れ子のリストがある項目はフォルダーです。

- docs
  - _config.yml
  - index.md
  - ko
    - index.md

## 詳細

`status:available` `c: details` セクションでは、各 `###` 見出しがブラウザー標準の開閉要素になります。JavaScript なしで開閉します。

### 何が必要ですか？

ブラウザーだけです。

## よくある質問

`status:available` `c: faq` セクションは詳細と同じように動きます。FAQPage 構造化データは `schema:` ブロックを追加してください（[構造化データ](../guides/structured-data/) を参照）。

### テーマは無料ですか？

はい、MIT ライセンスです。

### GitHub Pages で動きますか？

はい、github-pages gem で動きます。

## パラメーター表

`status:available` `c: params` セクションでは、表が名前、型、既定値、説明でオプションを並べます。`required` だけのセルは必須バッジになります。

| 名前 | 型 | 既定値 | 説明 |
|---|---|---|---|
| `title` | 文字列 | `required` | ページタイトル |
| `cols` | 数値 | 2 | カードの列数 |

## リンクカード

`status:available` `c: linkcards` セクションでは、リンクで始まるリスト項目がカードになります。カード全体がリンク先です。

- [インストール](../guides/install/) — サイトにテーマを追加します。
- [設定](../guides/configuration/) — すべての設定を一か所で確認します。

## 引用

`status:available` `c: quote` セクションでは、最終行がダッシュ（—）で始まる引用の、その行が出典になります。

> ドキュメントが github.com でもサイトでも読みやすい。
>
> — テーマの利用者

## ギャラリー

`status:available` `c: gallery` セクションでは、画像のリストがサムネイルのグリッドになります。各サムネイルは JavaScript なしで原寸表示を開きます。すべての画像に代替テキストが必要です。

- ![植物とアームチェアのある日当たりのよい部屋](../../assets/images/gallery/room.webp)
- ![低い太陽の下のピンク色の砂丘](../../assets/images/gallery/dunes.webp)
- ![静かな池を囲む熱帯の葉](../../assets/images/gallery/leaves.webp)
- ![山の湖に延びる木の桟橋](../../assets/images/news/travel-sm.webp)
- ![緑の丘に並ぶ風力発電機と太陽光パネル](../../assets/images/news/energy-sm.webp)
- ![クリーム、紫、コーラルの色見本を扇形に広げた様子](../../assets/images/projects/brand.webp)

## 料金プラン

`status:available` `c: pricing` セクションでは、各 `###` 見出しが価格、機能リスト、リンクからなるプランカードになります。`recommended` パラメーターは一つのプランにおすすめラベルを付けます。

### 無料

**$0**

- サイト 1 つ

[始める](#)

### チーム

**$12**

- サイト 10 個
- サポート

[チームを選ぶ](#)

## 購読

`status:available` `c: subscribe` セクションは、テキストと `modootoday.subscribe.action` のアドレスに送信するメールフォームを表示します。この設定がない場合はテキストだけを表示します。

リリースのたびにメールを 1 通受け取れます。


## 分割

`status:available` `c: split` セクションは、48rem 以上でテキストと画像を横に並べ、それより狭いと縦に積みます。画像は `visual:` の include です。`side: start` は画像を開始側に移し、`ratio: "5:7"` は画像に広い列を割り当てます。ここの `label:` のように、項目のほかのキーは include で `include.section.label` として受け取れます。 この画像はイラストです。`class="mt-illustration"`、`role="img"`、`aria-label` がある `figure` で、`.mt-illustration-tag` バッジの文字もラベルに含めます。`decor: decor-demo` は上の角の点を `aria-hidden` の装飾として加えます。

片側にテキスト、もう片側に画像が来ます。

## リスト

`status:available` `_config.yml` に `modootoday.lists` を書くと、通常のセクションとページに 2 つのリストスタイルが適用されます。`link_chips: true` は、すべての項目がリンク 1 つだけのリストをチップの行にし、`titled_items: true` は太字のタイトルとコロンで始まる項目にタイトルと区切りを付けます。`hero: {checks: true}` は、上のようにヒーローの最初のリストをチェックマークの行にします。コンポーネントのセクションのリストは元のスタイルのままです。

- [インストール](../../guides/install/)
- [設定](../../guides/configuration/)
- [アクセシビリティ](../../guides/accessibility/)

タイトル付きの項目:

- **チップ**: リンクだけのリスト
- **タイトル付き項目**: 太字のタイトル、コロン、続いてテキスト

## ナビゲーション

`status:available` ヘッダーのメニューは `_data/nav/main.yml` から作られます。`items:` がある項目は広い画面でドロップダウンのグループになり、狭い画面ではメニューボタンが出ます。開いたメニューは Esc で閉じます。このページのヘッダーがその表示結果です。

```yaml
- {title: Install, url: /install/}
- {title: Components, url: /components/}
- title: More
  items:
    - {title: Public API, url: /api/}
```

## 言語切り替え

`status:available` `languages:` と `language_switcher: header` を設定すると、ヘッダーに言語一覧を開く地球儀ボタンが出ます。言語が増えても幅は変わりません。言語名はそれぞれの言語で書かれ、現在の言語には `aria-current` が付きます。一覧は Esc で閉じます。このページのヘッダーの地球儀がその表示結果です。

```yaml
modootoday:
  languages: [en, ko, ja]
  language_switcher: header
```

## テーマ切り替え

`status:available` ヘッダーのボタンでライトとダークを切り替え、選んだ設定を記憶します。どちらかに固定するには `color_scheme` を使います。このページのヘッダーのボタンがその表示結果です。

```yaml
modootoday:
  color_scheme: auto   # auto | light | dark
```

## アイコンとロゴ

`status:available` テーマのアイコン(地球儀、太陽と月、検索、アラートの種類、コピー、編集、前後、外部リンク、パンくずの矢印)は `currentColor` のインライン SVG なので、ライト・ダークに追従し、追加のリクエストもありません。アイコンはスクリーンリーダーから隠し、アイコンだけのボタンには個別の名前を付けます。向きのある矢印は右から左へ書くページで反転します。`logo` を設定するとサイト名の前に modootoday マーク(または独自の画像)が表示され、`favicon` を設定すると同じ形のブラウザーアイコンが付きます。このページのヘッダーとフッターがその結果です。

```yaml
modootoday:
  logo: brand        # brand | /assets/img/logo.svg
  favicon: brand     # brand | /favicon.ico
```

## 検索

`status:available` `search.json` ファイルを使うクライアント検索がヘッダーに入ります（`role="search"`）。`kbd:Ctrl+K` か `kbd:/` で検索欄に移動します。サイトのルートに `search.json` を置くと有効になります。[このサイトのファイル](https://github.com/modootoday/jekyll-theme-modootoday/blob/main/docs/search.json)をコピーしてください。このページのヘッダーの検索欄がその表示結果です。

## パンくずリストと目次

`status:available` ドキュメントページには、URL から作るパンくずリストと、`##`・`###` 見出しから作る目次が付きます。目次は広い画面では横に、狭い画面では折りたたみの箱に表示されます。レイアウトが付けるので、書くソースはありません。無効にするには `components` から `breadcrumb` か `toc` を外します。このページの上部と横がその表示結果です。

```yaml
modootoday:
  components: [callout, badge, hero, cta, card, tabs, code-copy, nav, pagination, theme-toggle]
```

## 前後のページ

`status:available` ナビゲーションにあるページには、ナビゲーションの順に前後のページへのリンクが付きます。隠すには front matter に `pagination: false` と書きます。このページの下部がその表示結果です。

```yaml
---
title: Components
pagination: false
---
```

## 投稿とアーカイブ

`status:available` `layout: post` は日付、著者、タグを表示します（`p.mt-post-meta`）。

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

[キッチンシンク](kitchen-sink/) [設定](../guides/configuration/)
