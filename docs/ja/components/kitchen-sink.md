---
nav_order: 10
title: キッチンシンク
description: 実装済みのすべてのコンポーネントとバリエーションを 1 ページで見た目を確認します。
hero: {checks: true, c: split, visual: split-demo, ratio: "5:7", label: "見出し、2 行のテキスト、ボタンがある画面"}
sections:
  - alerts
  - {c: features, name: cards-2, cols: 2}
  - {c: features, name: cards-3, cols: 3, reveal: true}
  - {c: features, name: cards-4, cols: 4, badge: bottom}
  - {c: tabs, name: tabs-2}
  - {c: tabs, name: tabs-many}
  - badges
  - {c: accordion, name: accordion}
  - {c: steps, name: steps-list}
  - {c: steps, name: steps-headings}
  - figure
  - {c: timeline, name: timeline}
  - {c: timeline, name: timeline-list}
  - keyboard
  - tables
  - code
  - {name: typography, visual: flat-list}
  - {c: cta, name: cta}
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
  - {c: subscribe, name: subscribe, bleed: true}
  - {c: split, name: split, visual: split-demo, decor: decor-demo, tag: "イラスト", side: start, ratio: "5:7", label: "見出し、2 行のテキスト、ボタンがある画面"}
  - {c: split, name: split-code, visual: code}
  - lists
---
# キッチンシンク

テーマが提供するすべてのコンポーネントを、すべてのバリエーションで表示します。同じファイルを github.com で開くとフォールバックの表示を確認できます。日本語の折り返し確認用の長い文: いろはにほへとちりぬるをわかよたれそつねならむうゐのおくやまけふこえてあさきゆめみしゑひもせす。

- 普通の Markdown
- github.com でも読める
- WCAG 2.2 AA

[主なアクション](#) [二番目](#) [三番目のリンク](#)

> [!NOTE]
> このページは[英語の原文](../../components/kitchen-sink/)の翻訳です。内容が異なる場合は英語版が優先されます。

## アラート

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

> [!NOTE]
> 内容の多いアラート:
>
> - `inline code` を含むリスト項目
> - [コンポーネント一覧](../)へのリンクを含む二つ目の項目
>
> ```sh
> echo "code inside an alert"
> ```

## 2 列のカード

- **短い** — 1 行。
- **長めのカード** — 説明が長く数行に折り返すカードで、グリッド全体の余白、行の高さ、揃えを確認します。
- **バッジ付き** — カードにステータスを付けられます。 `status:available`
- **リンク付き** — [インストールガイド](../../guides/install/)を読んでください。

## 3 列のカード

- **アラート** — 5 種類の GitHub アラート。 `status:available`
- **タブ** — アクセシブルなインストールタブ。 `status:partial`
- **検索** — 予定項目の例。 `status:planned`
- **トークン** — 色、角丸、フォント。 `status:available`
- **Sass** — コンポーネントごとに一つのパーシャル。 `status:available`
- **Markdown 版** — エージェント向けの Markdown。 `status:available`

## 4 列のカード

- **アラート** — 5 種類の GitHub アラート。 `status:available`
- **タブ** — アクセシブルなインストールタブ。 `status:partial`
- **検索** — 予定項目の例。 `status:planned`
- **トークン** — 色、角丸、フォント。 `status:available`
- **Sass** — コンポーネントごとに一つのパーシャル。 `status:available`
- **Markdown 版** — エージェント向けの Markdown。 `status:available`
- **グリッド** — 広い画面では 4 列。
- **行** — 8 枚のカードで 2 行になります。

## パネルが二つのタブ

### macOS

```sh
brew install ruby
gem install jekyll bundler
```

### Linux

```sh
sudo apt install ruby-full
gem install jekyll bundler
```

## パネルが多いタブ

### Ruby

```ruby
puts "Hello"
```

### JavaScript

```js
console.log("Hello");
```

### Python

```python
print("Hello")
```

### Shell

```sh
echo Hello
```

### 名前がずっと長いタブ

```yaml
greeting: Hello
```

## ステータスバッジ

インラインのバッジ: `status:available` `status:partial` `status:planned`

タグのバッジ: `tag:beta` `tag:experimental`

| 機能 | ステータス |
|---|---|
| アラート | `status:available` |
| タブ | `status:partial` |
| 検索 | `status:planned` |

## アコーディオン

### キッチンシンクは何のためにありますか?

すべてのコンポーネントを 1 か所で見せるので、見た目の回帰に気づきやすくなります。

### JavaScript なしでも動きますか?

はい。JavaScript がなければ、すべての答えが質問の下に表示されたままになります。

### 答えにコードを入れられますか?

```sh
bundle exec jekyll serve
```

## リスト形式のステップ

1. `_config.yml` にテーマを追加します。
2. プレーンな Markdown で `index.md` を書きます。
3. `bundle exec jekyll build` を実行します。
4. `modootoday-check` で結果を確認します。

## 見出し形式のステップ

### インストール

`remote_theme` とプラグインを追加します。

### 執筆

front matter 付きのページを作ります。

### 公開

`main` にプッシュして GitHub Pages を有効にします。

## 図

![左の Markdown ソースが右のスタイル付きページになる](../../assets/images/sample.svg)

*画像だけの段落の後に強調だけの段落が続くと、キャプション付きの図になります。*

## タイムライン

### インストール

アラート、セクション、カード、タブ、ステータスバッジ、チェッカー。

### 書く

デザイントークン、`modootoday:` ブロック、ナビゲーション、コードのコピー。

### 確認

テーマ切り替え、パンくずリスト、目次、アコーディオン、ステップ、図。

### 公開

タイムライン、キーボードのキー、クライアント検索、post レイアウト。

## リスト形式のタイムライン

1. インストール: アラート、セクション、カード、タブ。
2. 書く: デザイントークン、ナビゲーション。
3. 確認: テーマ切り替え、目次、ステップ。

## キーボードのキー

`kbd:Ctrl+K` か、`kbd:/` だけで検索を開きます。`kbd:Cmd+C` でコピーします。

## 表

| キー | 型 | 既定値 | 説明 |
|---|---|---|---|
| `badges` | boolean | `true` | ステータスのコードスパンをバッジに変換する |
| `color_scheme` | string | `auto` | OS に合わせるか、配色を固定する |
| `components` | list | すべてのコアコンポーネント | ブラウザーに配信する CSS と JavaScript を絞る |
| `tokens` | map | テーマの既定値 | 主色、角丸、フォントスタックなどのデザイントークンを上書きする |

| 左 | 中央 | 右 |
|:---|:---:|---:|
| a | b | 1 |
| 長めのセル | 中央揃え | 1,000 |

## コード

インラインの `code`、フェンスブロック、スクロールする長い行:

```ruby
# frozen_string_literal: true
Jekyll::Hooks.register :site, :post_write do |site|
  puts "Built #{site.pages.size} pages into #{site.dest} with a deliberately long line to test horizontal scrolling"
end
```

```diff
- theme: minima
+ theme: jekyll-theme-modootoday
```

## タイポグラフィ

**太字**、*斜体*、~~取り消し線~~、`code`、[コンポーネント一覧](../)へのリンクを含む段落です。脚注も使えます。[^1]

### 見出しレベル 3

#### 見出しレベル 4

1. 番号付きの項目
2. 番号付きの項目
   - 入れ子の箇条書き
   - 入れ子の箇条書き

- [x] 完了したタスク
- [ ] 未完了のタスク

> アラートではない普通の引用です。

---

区切り線の後のテキストです。

[^1]: 脚注です。

## 行動を促す

[はじめる](../../guides/install/) [ルールを読む](https://github.com/modootoday/jekyll-theme-modootoday/blob/main/RULES.md)

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

`status:available` `c: faq` セクションは詳細と同じように動きます。FAQPage 構造化データは `schema:` ブロックを追加してください（[構造化データ](../../guides/structured-data/) を参照）。

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

- [インストール](../../guides/install/) — サイトにテーマを追加します。
- [設定](../../guides/configuration/) — すべての設定を一か所で確認します。

## 引用

`status:available` `c: quote` セクションでは、最終行がダッシュ（—）で始まる引用の、その行が出典になります。

> ドキュメントが github.com でもサイトでも読みやすい。
>
> — テーマの利用者

## ギャラリー

`status:available` `c: gallery` セクションでは、画像のリストがサムネイルのグリッドになります。各サムネイルは JavaScript なしで原寸表示を開きます。すべての画像に代替テキストが必要です。

- ![植物とアームチェアのある日当たりのよい部屋](../../../assets/images/gallery/room.webp)
- ![低い太陽の下のピンク色の砂丘](../../../assets/images/gallery/dunes.webp)
- ![静かな池を囲む熱帯の葉](../../../assets/images/gallery/leaves.webp)
- ![山の湖に延びる木の桟橋](../../../assets/images/news/travel-sm.webp)
- ![緑の丘に並ぶ風力発電機と太陽光パネル](../../../assets/images/news/energy-sm.webp)
- ![クリーム、紫、コーラルの色見本を扇形に広げた様子](../../../assets/images/projects/brand.webp)

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

`status:available` `c: subscribe` セクションは、テキストと `modootoday.subscribe.action` のアドレスに送信するメールフォームを表示します。この設定がない場合はテキストだけを表示します。 ここでは項目に `bleed: true` もあります。どのセクション項目と `hero:` にも指定でき、内容は読みやすい幅のまま、`--mt-bleed-bg`(既定は muted のサーフェス色)の背景帯が画面の全幅に広がります。`bleed: wide` は内容の幅もコンテナ幅まで広げます。サイドバーや目次があるページでは、帯は本文の列の中に収まります。

リリースのたびにメールを 1 通受け取れます。

## 分割

`status:available` `c: split` セクションは、48rem 以上でテキストと画像を横に並べ、それより狭いと縦に積みます。画像は `visual:` の include です。`side: start` は画像を開始側に移し、`ratio: "5:7"` は画像に広い列を割り当てます。ここの `label:` のように、項目のほかのキーは include で `include.section.label` として受け取れます。 この画像はイラストです。`class="mt-illustration"`、`role="img"`、`aria-label` がある `figure` で、`.mt-illustration-tag` バッジの文字もラベルに含めます。`decor: decor-demo` は上の角の点を `aria-hidden` の装飾として加えます。 ヒーローも同じ形にできます。`hero: {c: split, visual: <名前>, side: start, ratio: "5:7"}` は、タイトル、リード文、チェック行、ボタンをテキストの列に置き、include をその横に置きます。キッチンシンクのヒーローがこの形です。

片側にテキスト、もう片側に画像が来ます。

## コード付きの分割

`status:available` `c: split` セクションや分割ヒーローの `visual: code` には include が不要です。そのセクションの最初のコードブロック（`file:` のタイトルがある場合はタイトルも）が画像の列に移り、コードのスタイルとコピーボタンはそのまま使えます。`chrome: terminal`（使うページだけに読み込まれる小さなシート）は枠線と装飾用のバーを加え、スクリーンリーダーはこのバーを読み飛ばします。ほかの場所の `visual: code` は、これまでどおり `_includes/sections/code.html` を指します。

キットをインストールし、ビルドのたびに検査ツールを実行します。

`file:terminal`

```sh
bundle add jekyll-theme-modootoday
bundle exec modootoday-check . _site
```

## リスト

`status:available` `_config.yml` に `modootoday.lists` を書くと、通常のセクションとページに 2 つのリストスタイルが適用されます。`link_chips: true` は、すべての項目がリンク 1 つだけのリストをチップの行にし、`titled_items: true` は太字のタイトルとコロンで始まる項目にタイトルと区切りを付けます。`hero: {checks: true}` は、上のようにヒーローの最初のリストをチェックマークの行にします。コンポーネントのセクションのリストは元のスタイルのままです。

- [インストール](../../guides/install/)
- [設定](../../guides/configuration/)
- [アクセシビリティ](../../guides/accessibility/)

タイトル付きの項目:

- **チップ**: リンクだけのリスト
- **タイトル付き項目**: 太字のタイトル、コロン、続いてテキスト
