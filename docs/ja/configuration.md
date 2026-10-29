---
title: 設定
description: _config.yml の modootoday キーで指定するサイト全体の設定。
sections:
  - keys
  - head
  - i18n
  - registry
  - {c: cta, name: next}
---
# 設定

すべて省略できます。設定は一つの `modootoday:` キーの下にまとまっているので、ほかのプラグインとぶつかりません。

> [!NOTE]
> このページは[英語の原文](../../configuration/)の翻訳です。内容が異なる場合は英語版が優先されます。

## キー

```yaml
modootoday:
  color_scheme: auto  # auto | light | dark
  components: [callout, badge, cta, card, tabs]
  tokens: {primary: "#4f46e5", radius: "0.5rem"}
  nav: main
```

| キー | 既定値 | 効果 |
|---|---|---|
| `badges` | `true` | ステータスのコードスパンをバッジにする。`false` ならコードのまま |
| `color_scheme` | `auto` | OS に合わせるか、ライトまたはダークに固定する |
| `components` | すべて | 配信する CSS と JS を絞る |
| `css_layers` | `false` | テーマの CSS を `@layer mt.*` で包む |
| `nav` | `main` | `_data/nav/` のナビゲーションファイル。`items:` を持つ項目は広い画面でドロップダウングループになる |
| `tokens`, `tokens_dark` | テーマの値 | セマンティックなデザイントークンをインラインで上書きする |
| `twins` | スタブ | `source` で front matter のないツインを使う ([エージェント](../agents/)を参照) |
| `seo` | `true` | `false` で組み込みの canonical、hreflang、Open Graph タグを出さない |
| `hreflang` | `seo` に従う | `true` なら `seo: false` でも `hreflang` の代替リンクを残す（`jekyll-seo-tag` を使うサイト向け） |
| `languages` | なし | `hreflang` 用の言語コード。例: `[en, ko]` ヘッダーのサイト名は、その言語のホーム(`/<lang>/`)があればそこにリンクします。 |
| `language_switcher` | なし | `header`(地球儀ボタンとドロップダウンメニュー。言語数によらず幅は一定)または `footer`(言語名の一覧)で `languages` から言語切り替えを表示。各リンクはこのページの翻訳、なければその言語のトップへ。言語が 2 つ未満なら描画しない。メニューは JavaScript なしで開き、`menu.js` が Esc、矢印キー、外側クリックで閉じる動作を加える |
| `og_image` | なし | 既定の Open Graph 画像。front matter の `image:` が優先 |
| `feed` | `false` | `true` で `/feed.xml` にリンクする (`plugins` に `jekyll-feed` を追加) |
| `logo` | なし | `brand` でサイト名の前に modootoday マークを `currentColor`(`brand` トークンなのでライト・ダークに追従)で表示。パスを指定するとその画像を表示(装飾、`alt=""`)。別のロゴは `modootoday/brand/logo.html` を上書き |
| `favicon` | なし | `brand` で modootoday マークを SVG、32px PNG、Apple タッチアイコンとしてリンク。パスを指定するとそのアイコンをリンク |
| `csp` | なし | `strict` でペイント前スクリプトをインラインではなくファイルから読み込む |
| `edit_url` | なし | 「このページを編集」リンクの接頭辞。末尾は `/` |
| `archive` | なし | アーカイブページの URL。例：`{tags: /tags/, categories: /categories/}`。記事フッターのリンク先（[記事とアーカイブ](../api/#記事とアーカイブ)を参照） |

`modootoday-check` はすべてのキーを検証します。安定した名前の一覧は[公開 API](../api/)にあります。

## head と SEO

`url:` を設定すると、すべてのページに canonical リンクと Open Graph タグが付きます。プラグインは要りません。`languages:` を設定すると、複数の言語にあるページが `hreflang` で互いにリンクします。サイトマップとフィードは、GitHub Pages が許可するプラグインを使う任意機能です。

```yaml
url: https://example.github.io
modootoday:
  languages: [en, ko]
  edit_url: https://github.com/OWNER/REPO/edit/main/docs/
plugins: [jekyll-remote-theme, jekyll-sitemap, jekyll-feed]
```

代わりに `jekyll-seo-tag` を使うなら、`seo: false` にして jekyll-seo-tag の `seo` タグを `_includes/head-custom.html` に入れます。front matter の `last_modified_at:` でページに日付を表示できます。パンくずリストの最初の項目は、ホームページの front matter に `short_title:` があればそれを、なければ `title` を表示します。厳格な Content Security Policy については [CSP](../csp/) を参照してください。

## 言語

UI の文字列は `_data/i18n/<lang>.yml` に、ページは `<lang>/` に置きます。

```yaml
language: 한국어
callout: {note: 참고, tip: 팁, important: 중요, warning: 경고, caution: 주의}
tabs: {label: 설치 방법}
status: {available: 사용 가능, partial: 일부 구현, planned: 계획}
skip: 본문으로 건너뛰기
```

ないキーは英語にフォールバックします。

## コンポーネントレジストリ

任意の `_data/components.yml` を置くと、チェッカーが `sections:` のパラメーターを検証します。

```yaml
features: {params: {cols: {allowed: [2, 3], required: false}}}
tabs: {i18n: [tabs.label]}
cta: {}
```

## 次へ

[見た目をカスタマイズ](../customize/) [コンポーネント](../components/)
