---
nav_order: 30
title: 設定
description: _config.yml の modootoday キーで指定するサイト全体の設定。
sections:
  - keys
  - new-window
  - head
  - i18n
  - registry
  - {c: cta, name: next}
---
# 設定

すべて省略できます。設定は一つの `modootoday:` キーの下にまとまっているので、ほかのプラグインとぶつかりません。

> [!NOTE]
> このページは[英語の原文](../../../guides/configuration/)の翻訳です。内容が異なる場合は英語版が優先されます。

## キー

```yaml
modootoday:
  color_scheme: auto  # auto | auto-dark | auto-light | light | dark
  components: [callout, badge, cta, card, tabs]
  tokens: {primary: "#4f46e5", radius: "0.5rem"}
  nav: main
```

| キー | 既定値 | 効果 |
|---|---|---|
| `badges` | `true` | ステータスのコードスパンをバッジにする。`false` ならコードのまま |
| `color_scheme` | `auto` | `auto` は OS に合わせる。`auto-dark`・`auto-light` はダーク・ライトで始まり切り替えボタンを残す(読者の選択は記憶される)。`light`・`dark` は切り替えなしで固定。開始時の配色は HTML に書き出されるので、ちらつかない |
| `components` | すべて | 配信する CSS と JS を絞る |
| `css_layers` | `false` | テーマの CSS を `@layer mt.*` で包む |
| `nav` | `main` | `_data/nav/` のナビゲーションファイル。`items:` がある項目はグループになる。前後のページへのリンクはこのファイルの順序(グループ自体のページ、次にその項目)に従う |
| `sidebar` | `auto` | `auto` はナビゲーションにグループがあるとき `doc` ページにサイドバーを付ける。`true` は常に、`false` は付けない。64rem より狭い画面では本文の上の折りたたみメニューになる。front matter の `sidebar: false` でそのページだけ隠す |
| `page_actions` | `true` | Markdown 版があるページに「Markdown で表示」「ページをコピー」「AI 向けにコピー」(出典 URL のあとに Markdown)のメニューを出す。ここか front matter で `false` にすると消える。完全に外すなら `components` から `page-actions` を除く |
| `tokens`, `tokens_dark` | テーマの値 | セマンティックなデザイントークンをインラインで上書きする |
| `twins` | スタブ | `source` で front matter のない Markdown 版を使う ([エージェント](../agents/)を参照) |
| `seo` | `true` | `false` で組み込みの canonical、hreflang、Open Graph タグを出さない |
| `hreflang` | `seo` に従う | `true` なら `seo: false` でも `hreflang` の代替リンクを残す（`jekyll-seo-tag` を使うサイト向け） |
| `schema` | `url` があれば有効 | schema.org JSON-LD グラフ: `publisher`、`search_url`、`layouts`。`false` で無効。[構造化データ](../structured-data/)を参照 |
| `languages` | なし | `hreflang` 用の言語コード。例: `[en, ko]` ヘッダーのサイト名は、その言語のホーム(`/<lang>/`)があればそこにリンクします。 |
| `full_languages` | なし | すべてのページを翻訳する `languages` 内のコード。例: `[ko, ja]` `modootoday-check --i18n-pages` は、その言語の翻訳がない既定言語のページごとに警告します。 |
| `language_switcher` | なし | `header`(地球儀ボタンとドロップダウンメニュー。言語数によらず幅は一定)または `footer`(言語名の一覧)で `languages` から言語切り替えを表示。各リンクはこのページの翻訳、なければその言語のトップへ。言語が 2 つ未満なら描画しない。メニューは JavaScript なしで開き、`menu.js` が Esc、矢印キー、外側クリックで閉じる動作を加える |
| `og_image` | なし | 既定の Open Graph 画像。front matter の `image:` が優先 |
| `feed` | `false` | `true` で `/feed.xml` にリンクする (`plugins` に `jekyll-feed` を追加) |
| `logo` | なし | `brand` でサイト名の前に modootoday マークを `currentColor`(`brand` トークンなのでライト・ダークに追従)で表示。パスを指定するとその画像を表示(装飾、`alt=""`)。別のロゴは `modootoday/brand/logo.html` を上書き |
| `favicon` | なし | `brand` で modootoday マークを SVG、32px PNG、Apple タッチアイコンとしてリンク。パスを指定するとそのアイコンをリンク |
| `csp` | なし | `strict` でペイント前スクリプトをインラインではなくファイルから読み込む |
| `viewport_fit` | `cover` | `auto` でノッチの下まで描かず、ページをセーフエリア内に収める ([アクセシビリティ](../accessibility/#設定)を参照) |
| `theme_color` | ページ背景 | ブラウザーのバーの色: `"#hex"` 1 つ、`{light: "#hex", dark: "#hex"}`、またはタグを出さない `false` |
| `edit_url` | なし | 「このページを編集」リンクの接頭辞。末尾は `/` |
| `archive` | なし | アーカイブページの URL。例：`{tags: /tags/, categories: /categories/}`。記事フッターのリンク先（[記事とアーカイブ](../../reference/api/#記事とアーカイブ)を参照） |
| `mermaid` | 無効 | `{enabled: true, src:, integrity:, theme: auto}` で、```` ```mermaid ```` フェンスのあるページで描画します。`src` はバージョンを固定した https の URL と SRI の `integrity` ハッシュ、またはサイト内のパスです。CDN を使うと `script-src` にそのオリジンが加わり、訪問者の IP アドレスが CDN に送られます。[数式と図](../../recipes/math-diagrams/#組み込みローダー)を参照 |
| `math` | 無効 | `{enabled: true, engine: katex, src:, css:, integrity: {js:, css:}, auto_render_src:, auto_render_integrity:, inline: false}` で、```` ```math ```` フェンスと `$$` ブロックのあるページで KaTeX により描画します。`inline: true` で `$…$` も描画します。CDN を使うと `script-src`、`style-src`、`font-src` にそのオリジンが加わります。[数式と図](../../recipes/math-diagrams/#csp-とプライバシー)を参照 |
| `external_links` | なし | `new_window: true` で外部リンク（`url:` で始まらないリンク）をすべて新しいウィンドウで開きます。`icon: false` で矢印を隠します。[新しいウィンドウで開くリンク](#新しいウィンドウで開くリンク)を参照 |
| `blog` | なし | ブログ設定（`per_page`、`variant`、`related`、`share`、`reading_time` など）。[ブログとニュース](../../layouts/blog-news/#設定)を参照 |
| `news` | なし | ニュース設定（トップページの `sections:` など）。[ブログとニュース](../../layouts/blog-news/#設定)を参照 |
| `css` | `split` | `split` は小さなコアシートと、ページが使うコンポーネントのシートだけを読み込みます。`bundle` はすべてを含む 1 枚のシートを読み込みます |
| `banner` | なし | `{text: "…", url: /path/, link: "詳しく"}` はスキップリンクの下にサイト全体のお知らせバーを表示します |
| `back_to_top` | `false` | `true` はすべてのページの末尾に「先頭へ戻る」リンクを追加します |
| `loading` | `false` | `true` は独自スクリプトが追加するプレースホルダーのため、スピナーとスケルトンのシートを全ページで読み込みます。Markdown で使うページは自動で読み込みます |
| `subscribe` | なし | `{action: https://…}` は `c: subscribe` のメールフォームの送信先です |

`modootoday-check` はすべてのキーを検証します。安定した名前の一覧は[公開 API](../../reference/api/)にあります。

## 新しいウィンドウで開くリンク

新しいウィンドウで開く動作は、明示的に有効にしたときだけ働きます。リンクごと、または外部リンク全体に設定できます。

```yaml
# _config.yml: 外部リンク全体
modootoday:
  external_links:
    new_window: true
    icon: true        # false で矢印を隠します
```

```yaml
# リンクごと: ナビ、カード、ボタン、リンクカード、ディレクトリ項目、料金プランのボタン、フッターのリンク
- {title: "ステータスページ", url: "https://status.example.com", new_window: true}
- {title: "フォーラム", url: "https://forum.example.com", target: _blank}
```

```markdown
[リリースノート](https://github.com/modootoday/jekyll-theme-modootoday/releases "new-window")
```

こうしたリンクには `target="_blank"`、`rel="noopener noreferrer"`、CSS で描いた小さな矢印、そしてスクリーンリーダーが `aria-describedby` で読み上げる非表示の案内（「新しいウィンドウで開きます」、ページの言語に翻訳）が付きます。スクリプトは使わないので、厳しいコンテンツセキュリティポリシー（CSP）でもそのまま動きます。サイト設定を有効にしていても、リンクに `new_window: false` を書くとそのリンクは同じウィンドウで開きます。

## head と SEO

`url:` を設定すると、すべてのページに canonical リンクと Open Graph タグが付きます。プラグインは要りません。`languages:` を設定すると、複数の言語にあるページが `hreflang` で互いにリンクします。サイトマップとフィードは、GitHub Pages が許可するプラグインを使う任意機能です。

```yaml
url: https://example.github.io
modootoday:
  languages: [en, ko]
  edit_url: https://github.com/OWNER/REPO/edit/main/docs/
plugins: [jekyll-remote-theme, jekyll-sitemap, jekyll-feed]
```

代わりに `jekyll-seo-tag` を使うなら、`seo: false` にして jekyll-seo-tag の `seo` タグを `_includes/head-custom.html` に入れます。front matter の `last_modified_at:` でページに日付を表示できます。パンくずリストの最初の項目は、ホームページの front matter に `short_title:` があればそれを、なければ `title` を表示します。厳格な Content Security Policy については [CSP](../../recipes/csp/) を参照してください。

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

パスが異なる翻訳ページどうしは、front matter に同じ `ref:` を書きます。たとえば `guides/start.md` と `ko/guides/sijak.md` の両方に `ref: guide` を書きます。すると `hreflang` リンクと言語スイッチャーがそのページを使います。`ref:` があって翻訳がないページは `hreflang` から外れ、言語スイッチャーはその言語のホームへ案内します。include とレイアウトでは、`modootoday/link.html` に `ref="guide"` を渡すと、現在の言語の `ref: guide` ページの URL を、なければ既定言語のページの URL を返します(代替しない場合は `exact=true`、完全な URL は `absolute=true`)。どのページにもない `ref=` は `modootoday-check` がエラーにします。`full_languages` を設定すると、`modootoday-check . _site --i18n-pages` がその言語の翻訳(同じ `ref:`、または `<lang>/` 以下の同じパス)がない既定言語のページを警告として表示します。`--strict` と併用すると失敗します。

テーマではなくサイト側で決める文言もあります。`tabs.label` はタブを使うページでタブ一覧に付ける名前です(例: `tabs: {label: インストール方法}`)。スクリーンリーダーが何を切り替えるタブかを読み上げるので、言語ごとのカタログに入れてください。

独自の include では、`modootoday/t.html` に `key="nav.label"` を渡すと、同じ順序で解決された文言を出力できます。

## コンポーネントレジストリ

任意の `_data/components.yml` を置くと、チェッカーが `sections:` のパラメーターを検証します。

```yaml
features: {params: {cols: {allowed: [2, 3, 4], required: false}}}
tabs: {i18n: [tabs.label]}
cta: {}
```

## 次へ

[見た目をカスタマイズ](../customize/) [コンポーネント](../../components/)
