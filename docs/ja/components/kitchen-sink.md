---
nav_order: 10
title: キッチンシンク
description: 実装済みのすべてのコンポーネントとバリエーションを 1 ページで見た目を確認します。
sections:
  - alerts
  - {c: features, name: cards-2, cols: 2}
  - {c: features, name: cards-3, cols: 3}
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
  - typography
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
  - {c: subscribe, name: subscribe}
---
# キッチンシンク

テーマが提供するすべてのコンポーネントを、すべてのバリエーションで表示します。同じファイルを github.com で開くとフォールバックの表示を確認できます。日本語の折り返し確認用の長い文: いろはにほへとちりぬるをわかよたれそつねならむうゐのおくやまけふこえてあさきゆめみしゑひもせす。

[主なアクション](../../guides/install/) [二番目](../) [三番目のリンク](https://github.com/modootoday/jekyll-theme-modootoday)

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
> - [リンク](../)を含む二つ目の項目
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
- **ツイン** — エージェント向けの Markdown。 `status:available`

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

### ずっと長い名前を持つタブ

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

**太字**、*斜体*、~~取り消し線~~、`code`、[リンク](../)を含む段落です。脚注も使えます。[^1]

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

`status:available` loading または skeleton とコロンで始まるコードスパンは、スピナー、細い上部バー、プレースホルダー（text、card、image、avatar、row）になります。それぞれ `role="status"` とスクリーンリーダー向けの読み込みラベルを持ち、利用者が視差効果を減らす設定にすると動きが止まります。スタイルは、使うページだけが読み込む任意のシートにあります。

`loading:spinner`

`skeleton:avatar`
`skeleton:text`
`skeleton:card`

## ファイルツリー

`status:available` `c: filetree` セクションでは、入れ子のリストがフォルダーツリーとして描かれます。入れ子のリストを持つ項目はフォルダーです。

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

`status:available` `c: faq` セクションは詳細と同じように動き、検索エンジン向けの FAQPage 構造化データも追加します。

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

- [インストール](../../install/) — サイトにテーマを追加します。
- [設定](../../configuration/) — すべての設定を一か所で確認します。

## 引用

`status:available` `c: quote` セクションでは、最終行がダッシュ（—）で始まる引用の、その行が出典になります。

> ドキュメントが github.com でもサイトでも読みやすい。
>
> — テーマの利用者

## ギャラリー

`status:available` `c: gallery` セクションでは、画像のリストがサムネイルのグリッドになります。各サムネイルは JavaScript なしで原寸表示を開きます。すべての画像に代替テキストが必要です。

- ![サンプルページの図](../../../assets/images/sample.svg)
- ![テーマのマーク](../../../assets/modootoday/favicon.svg)

## 料金プラン

`status:available` `c: pricing` セクションでは、各 `###` 見出しが価格、機能リスト、リンクを持つプランになります。`recommended` パラメーターは一つのプランにおすすめラベルを付けます。

### 無料

**$0**

- サイト 1 つ

[始める](../../install/)

### チーム

**$12**

- サイト 10 個
- サポート

[チームを選ぶ](../../install/)

## 購読

`status:available` `c: subscribe` セクションは、テキストと `modootoday.subscribe.action` のアドレスに送信するメールフォームを表示します。この設定がない場合はテキストだけを表示します。

リリースのたびにメールを 1 通受け取れます。
