---
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
---
# キッチンシンク

テーマが提供するすべてのコンポーネントを、すべてのバリエーションで表示します。同じファイルを github.com で開くとフォールバックの表示を確認できます。日本語の折り返し確認用の長い文: いろはにほへとちりぬるをわかよたれそつねならむうゐのおくやまけふこえてあさきゆめみしゑひもせす。

[主なアクション](../../install/) [二番目](../) [三番目のリンク](https://github.com/modootoday/jekyll-theme-modootoday)

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
- **リンク付き** — [インストールガイド](../../install/)を読んでください。

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

[はじめる](../../install/) [ルールを読む](https://github.com/modootoday/jekyll-theme-modootoday/blob/main/RULES.md)
