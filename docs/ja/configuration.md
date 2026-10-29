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

`lang:` を指定するだけで、テーマが表示する文言（本文へのスキップリンク、ナビゲーション、アラート、ステータスバッジ、目次、前後のページ、コードのコピー、検索、言語メニュー）が 23 言語でローカライズされます。対応言語は en、zh-CN、zh-TW、ja、ko、tr、ru、vi、th、de、es、fr、uk、pl、pt-BR、ar、fa、id、it、el、ml、ur-Latn、ro です。GitHub Pages でも Jekyll 4 でも、何もコピーする必要はありません。テーマにない地域コードは基本の言語を使い（`pt` → pt-BR、`zh` → zh-CN）、それ以外の言語は英語で表示されます。

各文言は次の順に決まります。

1. サイトの `_data/i18n/<lang>.yml`（キー単位）
2. テーマに含まれるその言語のカタログ
3. 英語

そのため、サイトのカタログには変更したいキーと、独自のコンポーネントが使うキーだけを書けば十分です。拡張子は `.yml` を使ってください。チェッカーは `.yaml` をエラーにします。テーマの文言をもとに編集する場合は、カタログをコピーしてからチェックします。

```sh
modootoday-check . _site --i18n-init=ko   # optional: copy the theme's ko.yml to edit
modootoday-check . _site --i18n           # unknown keys and placeholder mismatches
```

テーマにない言語を追加するには、英語のカタログと同じキーで `_data/i18n/<code>.yml` を作り、`languages` にコードを加えます。アラビア語、ペルシア語、ヘブライ語、ウルドゥー語などの RTL 言語のページには `dir="rtl"` が付きます（`ur-Latn` は左から右）。カタログか front matter の `direction: rtl` または `ltr` で上書きできます。ページ本文はカタログではなく、`<lang>/` の Markdown で翻訳します。

独自の include では、`modootoday/t.html` に `key="nav.label"` を渡すと、同じ順序で解決された文言を出力できます。

## コンポーネントレジストリ

任意の `_data/components.yml` を置くと、チェッカーが `sections:` のパラメーターを検証します。

```yaml
features: {params: {cols: {allowed: [2, 3], required: false}}}
tabs: {i18n: [tabs.label]}
cta: {}
```

## 次へ

[見た目をカスタマイズ](../customize/) [コンポーネント](../components/)
