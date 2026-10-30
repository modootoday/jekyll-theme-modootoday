---
nav_order: 10
title: 公開 API
description: このテーマがサイト向けに文書化している名前、クラス、ファイル。
---
# 公開 API

> [!NOTE]
> このページは[英語の原文](../../../reference/api/)の翻訳です。内容が異なる場合は英語版が優先されます。

公開 API はこのページにまとめてあり、変更は `CHANGELOG.md` に記録されます。一覧にないもの (内部の include、Sass パーシャルのパス、非公開の `--mt-p-*` プリミティブ、どのルールにも書かれていない HTML の細部) は、どのリリースでも変わることがあります。

## 安定した名前

| 領域 | 安定した名前 |
|---|---|
| 設定 | [設定](../../guides/configuration/)に載っている `modootoday:` 配下のすべてのキー |
| デザイントークン | セマンティックおよびコンポーネントのカスタムプロパティ `--mt-*` (プリミティブ `--mt-p-*` を除く)。生成される `tokens.json` も同じ |
| Markdown ルール | `RULES.md` のパターンと、その出力クラス `mt-*`、解除用クラス `mt-flat-list`（その下のリスト項目の間隔をなくす） |
| レイアウト | `default`, `doc`, `post`, `archive`, `twin`, `llms`, `llms-full` |
| 上書きしてよい include | `head-custom.html`, `footer-custom.html`。自作のフッターから `modootoday/lang-switch.html` と `modootoday/brand/logo.html`(`size` 指定可)を include できる。独自のロゴは `modootoday/brand/logo.html` を上書き |
| 自分で用意する include | `_includes/sections/<name>.html`。`visual: <name>` を書いたセクションかヒーローの末尾に描画される（[カスタマイズ](../../guides/customize/#セクションのビジュアルと全幅ページ)を参照） |
| 呼び出してよい include | `modootoday/archive.html`（`by`、`lang`）。`modootoday/brand/icon.html`（`name`: globe, sun, moon, search, menu, copy, check, external, prev, next, chevron-right, chevron-down, note, tip, important, warning, caution, edit, rss, tag, folder, brand。任意で `size`(px、既定 18)、`label`(指定するとその名前の `role="img"`、なければ `aria-hidden`)、`class`）。出力は `currentColor` の `svg.mt-icon.mt-icon-<name>` で、向きのあるアイコンは `.mt-icon-flip` が付き RTL で反転 |
| include | `modootoday/t.html`（`key=`、任意の `n=` / `name=`）はページの言語でテーマの文言を出力します |
| データファイル | `_data/i18n/<lang>.yml` のキー（組み込みカタログを上書きする場合のみ）、`_data/nav/<name>.yml`、`_data/components.yml` |
| チェッカー | `modootoday-check` のオプション、終了コード 0 (問題なし) と 1 (問題あり、または使い方の誤り) |

## Markdown のルール

`md-components v1` は `RULES.md` にある Markdown ルール標準の名前で、CSS の接頭辞ではありません。出力クラスは `mt-*` を使います。

## コンポーネントの構造

自分の CSS から今すぐ対象にできるマークアップです。この表のクラスと属性は公開 API に含まれます。表に名前のない内側の要素 (ラッパー、生成される id、子要素の順序) は安定していません。下のスロット契約が、各コンポーネントが使う Markdown の部分を定めます。

| コンポーネント | ルート | スタイルを当ててよい部分 | 状態とバリエーション |
|---|---|---|---|
| ページの枠 | `body.mt-body` | `a.mt-skip`, `header.mt-header` > `.mt-header-inner` (`.mt-site-title`, `nav.mt-nav`, `.mt-search`, `details.mt-lang.mt-menu` (`summary` globe button, `ul` of `a[lang][hreflang]`, current one `aria-current`), `.mt-theme-toggle`), `main.mt-main`, `footer.mt-footer` > `.mt-footer-inner` | `html[data-theme=light\|dark]` (固定の配色、またはトグルが設定) |
| ドキュメントページ | `article.mt-doc` | `.mt-doc-layout` > `.mt-doc-main` と `.mt-doc-aside` (`nav.mt-toc` を含む), `nav.mt-toc-mobile`, `nav.mt-breadcrumb`, `.mt-page-meta`, `nav.mt-pagination` | — |
| ドキュメントのサイドバー | `aside.mt-doc-nav` > `nav.mt-sidebar`(64rem 以上)、`details.mt-sidebar-mobile`(それより狭い画面) | `.mt-sidebar-group`、`.mt-sidebar-title`、リンクの `ul`。現在のリンクは `aria-current=page` | `.mt-doc-layout.mt-has-sidebar`、モバイルメニューの `[open]` |
| ページの操作 | `details.mt-menu.mt-page-actions` | `summary`、`button[data-mt-act=copy\|ai]`(JS が動くまで非表示)と Markdown 表示の `a[type="text/markdown"]` を含む `ul` | `[open]` |
| ヒーロー | `section.mt-hero` | `h1`、リードの `p.mt-hero-lead` (`h1` の直後の最初の `p`)、リンクだけの `p` (CTA ボタン。最初のリンクが主ボタン) | `.mt-hero-checks` (front matter `hero: {checks: true}`: 最初の `ul` が `--mt-ok` の ✓ の行) |
| セクション | `section.mt-section` | `h2` とその内容 | `[data-section]` = 名前、`[data-c]` と `.mt-c-<c>` = コンポーネント、`.mt-cols-<n>`、`.mt-cta`(セクション内に `[data-mt-result]` 要素があればその要素に) |
| セクションの装飾 | `section.mt-hero` または `section.mt-section` の `.mt-has-decor`(front matter `decor: <include>`) | 最後の子 `.mt-section-decor[aria-hidden=true]`。中身は `_includes/sections/<include>.html` で、上の終端の角に置かれ、ポインターイベントを受けません | — |
| スクロール表示 | `section.mt-hero` または `section.mt-section` の `.mt-reveal`（front matter `reveal: true`） | — | CSS のみ: `@supports (animation-timeline: view())` と `prefers-reduced-motion: no-preference` の場合だけスクロール時にゆっくり表示され、それ以外ではそのまま表示されます |
| 全幅の帯 | `section.mt-hero` または `section.mt-section` の `.mt-bleed` (front matter `bleed: true`)、`.mt-bleed-wide` (`bleed: wide`) | — | `--mt-bleed-bg` で帯の色を指定します。サイドバーや目次があるレイアウトでは、帯は本文の列の中に収まります。`bleed` シート |
| イラスト | `figure.mt-illustration[role=img][aria-label]`(サイトの include) | 上の開始側の角の `.mt-illustration-tag` バッジ。`role=img` の子は読み上げられないため、バッジの文字も `aria-label` に入れます | — |
| リストスタイル | `ul.mt-chips`、`li > strong.mt-item-title + span.mt-item-sep` (`modootoday.lists` を使うとき) | `li > a` のチップ (高さ 44px、テキストの後に →)、タイトルと `: ` の区切り | — |
| 本文 (`sections:` なし) | `div.mt-prose` | レンダリングされた本文 | — |
| カードグリッド | `section.mt-section` | `ul > li`、先頭の `strong` がタイトル | `.mt-cols-2`, `.mt-cols-3`, `.mt-cols-4`, `.mt-badge-bottom` (`c: features`) |
| タブ | `section.mt-c-tabs[data-tabs]` | `[role=tablist]`, `[role=tab]`, `[role=tabpanel]` (JS が生成。JS がなければ `h3` とコードブロックのまま) | `[aria-selected]` |
| アコーディオン | `section.mt-c-accordion` | `h3 > button[aria-expanded]`、その後のパネル | `[aria-expanded=true\|false]` |
| ステップ / タイムライン | `section.mt-c-steps`, `section.mt-c-timeline` | `ol > li` または `h3` の項目 | — |
| ファイルツリー | `section.mt-c-filetree` | `ul[aria-label]`、入れ子の `ul`（それがある項目はフォルダー） | — |
| 詳細 / FAQ | `section.mt-c-details`, `section.mt-c-faq` | `details.mt-details`、`summary > h3`、その後の内容 | `[open]` |
| パラメーター表 | `section.mt-c-params` | `th[scope=col]`, `.mt-param-required` | — |
| リンクカード | `section.mt-c-linkcards` | `ul > li > a`（カード全体がリンク先） | — |
| 引用 | `figure.mt-quote` | `blockquote`, `figcaption` | — |
| ギャラリー | `section.mt-c-gallery` | `a.mt-gallery-thumb`, `a.mt-lightbox`, `.mt-lightbox-close` | 開いたライトボックスの `:target` |
| 料金プラン | `.mt-plans` | `.mt-plan`、その `h3`、リンクだけの `p.mt-actions` | `.mt-plan-recommended` と `.mt-plan-flag` |
| 購読 | `section.mt-c-subscribe` | `form.mt-subscribe`（action 設定時）、`label`, `input[type=email]`, `button` | — |
| 分割 | `section.mt-c-split`（`.mt-split-start`, `.mt-split-5-7` を含む） | `.mt-section-in` > `.mt-section-body`（`h2` とテキスト）+ `.mt-section-visual`（`visual:` の include） `hero: {c: split}` は `section.mt-hero` を同じラッパーで包み、`h1`、リード文、チェック行、アクションは `.mt-section-body` に入ります。 `visual: code` は最初のコードブロックを `div.mt-section-visual.mt-split-code` に入れ、`chrome: terminal` は `.mt-split-terminal` と `div.mt-split-bar`（`aria-hidden`）を加えます。 | — |
| インライン追加要素 | `div.mt-code`, `span.mt-progress`, `div.mt-embed` | `.mt-code-title`, `progress`, `iframe` | — |
| 読み込み表示（任意シート） | `.mt-spinner`, `.mt-topbar`, `.mt-skeleton` | `.mt-skeleton-text`, `-card`, `-image`, `-avatar`, `-row`; `.mt-ratio-16x9`, `-4x3`, `-1x1` | `[aria-busy=true]`, `[role=status]` |
| バナー | `div.mt-banner` | その `p` とリンク、`a.mt-back-to-top` | — |
| アラート | `blockquote.mt-callout[role=note]` | `p.mt-callout-title`、本文 | `.mt-callout-<type>`, `[data-variant]` = note, tip, important, warning, caution |
| バッジ | `span.mt-badge` | 記号 (`aria-hidden`)、ラベル | `.mt-badge-<status>`, `.mt-badge-tag`, `[data-variant]` |
| キーボードのキー | `kbd.mt-kbd` | キーごとの `kbd` | — |
| 図 | `figure.mt-figure` | `img`, `figcaption` | — |
| 記事ヘッダー | `header.mt-post-header` | `h1.mt-post-title`、`.mt-post-deck`、`.mt-byline`（`.mt-byline-authors` > `.mt-post-author`、`.mt-byline-dates` > `time`）、`figure.mt-post-cover`、`nav.mt-series`、`p.mt-post-meta`（タグバッジ） | `[data-part]` = header, deck, byline, authors, dates, cover, terms |
| 記事フッター | `article.mt-doc` | `.mt-share` ボタン、`nav.mt-post-nav`、`section.mt-related`、`.mt-news-correction`、`.mt-news-sources` | `[data-part]` = share, post-nav, related, sources |
| 記事カード | `article.mt-card-post` | `.mt-card-post-cover`、`.mt-card-post-meta`、`.mt-card-post-title`、`.mt-card-post-excerpt` | `.mt-card-post-featured`、`[data-kind=news]`、`.mt-post-list[data-variant=list\|grid\|magazine]` |
| ニューストップ | `div.mt-news-top` | `.mt-news-lead`、`.mt-news-secondary`、`section.mt-news-latest`、`section.mt-news-section` | `[data-category]`、`.mt-badge[data-variant=breaking\|live]` |
| 検索 | `div.mt-search[role=search]` | 入力欄、`.mt-search-results` | — |

## スロット契約

スロットはセクションの Markdown の中の名前付きの部分です。スロット名は上のポリシーのもとで安定しており、宣言しても生成されるマークアップは変わりません。`_data/components.yml` で `slots:` が定義された `c:` を使うセクションごとに `modootoday-check` がスロットの数を数え、宣言した範囲を外れると失敗します。

| スロット | セクション内 (`##` 見出しの後) で数えるもの | 表示 |
|---|---|---|
| `lead` | 最初のリスト、`###`、コードブロック、引用より前の普通の段落 | `p` |
| `items` | リスト項目 | `ul > li` または `ol > li` (カード、ステップ) |
| `panels` | `###` 見出し | タブ、アコーディオン、ステップのパネル |
| `actions` | リンクだけの行 | CTA ボタン (`c: cta`) |
| `code` | フェンスコードブロック | `pre` (タブの内容) |
| `figures` | 画像で始まる行 | `figure.mt-figure` |

各スロットは `required: true` (`min: 1` と同じ)、`min`、`max` を取ります (整数で、`min` は `max` 以下)。正しい形が二つあるコンポーネントでは、`slots:` を代わりの形のリストにでき、セクションはそのどれか一つを満たせば通ります。`parts:` には、[コンポーネントの構造](#コンポーネントの構造)の表のうち、そのコンポーネントが保つと約束するセレクターを並べます。サイトにその表がある `api.md` を置いている場合、すべてのパートが表に載っている必要があります。Nokogiri が使える場合 (`github-pages` には含まれます)、そのコンポーネントを使うページのビルド済み HTML で、そのコンポーネントのセクション内にすべてのパートが実際に存在する必要もあります。コンポーネントのスクリプトが実行時に付けるパート (`role=`、`aria-*`) は、ドキュメントサイトの QA がスクリプト実行後に確認します。

```yaml
features: {params: {cols: {allowed: [2, 3, 4]}, badge: {allowed: [bottom]}}, slots: {items: {min: 1}}, parts: [ul > li, .mt-cols-2, .mt-cols-3, .mt-cols-4, .mt-badge-bottom]}
tabs: {i18n: [tabs.label], slots: {panels: {min: 2}, code: {min: 2}}}
cta: {slots: {actions: {required: true}}, parts: [.mt-cta]}
accordion: {slots: {panels: {min: 1}}}
steps: {slots: [{items: {min: 1}}, {panels: {min: 1}}], parts: [section.mt-c-steps, ol > li]}
```

コンポーネントの項目に書けるのは `params`、`i18n`、`slots`、`parts` だけで、スロットの規則に書けるのは `required`、`min`、`max` だけです。それ以外のキー、未知のスロット名、`max` より大きい `min`、二つ未満の形のリストはエラーで、レジストリごとに一度だけ報告されます。`slots:` のないコンポーネントは数えず、一つのマップで書いた `slots:` は以前とまったく同じに動きます。

## 右から左への表記と数式

- アラビア語、ペルシア語、ヘブライ語、ウルドゥー語などの RTL 言語のページは `lang` から `dir="rtl"` を受け取ります。front matter の `direction: rtl` または `ltr` (または `_data/i18n/<lang>.yml` の `direction:`) で上書きできます。コンポーネントは論理プロパティを使って左右が反転し、コードは左から右のままです。
- テーマは数式や図のレンダラーを同梱しません。[数式と図](../../recipes/math-diagrams/)を参照してください。

## 記事とアーカイブ

記事は `post` レイアウトを使います。日付・著者・タグの行、本文、そして各カテゴリーとタグをアーカイブの該当セクションにつなぐフッターが付きます。`_config.yml` でアーカイブページを指定します。

```yaml
modootoday:
  archive: {tags: /tags/, categories: /categories/}
```

次に、分類の種類ごとにページを 1 つ作ります。たとえば `tags.md` は次のとおりです。

```yaml
---
title: タグ
layout: archive
archive: tags        # または categories
---
```

このページには本文、記事数付きの分類一覧、分類ごとのセクション（`id="tags-<slug>"`、新しい記事が先）が表示されます。別の場所にアーカイブを置くにはレイアウトや include から `modootoday/archive.html` を呼び出し、`by` に `tags` または `categories` を、必要なら `lang` を指定します。アーカイブのスタイルは `modootoday-blog.css` にあります。`archive` と `post` レイアウトはこのファイルを読み込みます。ほかのページで include を呼び出すときは、front matter に `blog_css: true` を指定します。

- 記事の言語は `lang`（なければ `site.lang`）です。アーカイブはページと同じ言語の記事だけを表示し、`archive_lang: all`（include では `lang="all"`）ならすべての記事を表示します。`lang` が `site.lang` と異なる記事のフッターのリンクは `/<lang>/tags/` を指すので、言語ディレクトリごとにアーカイブページを置いてください。
- ラベルは `_data/i18n/<lang>.yml` の `archive.tags`、`archive.categories`、`archive.posts`、`archive.empty` から取り、なければ英語を使います。
- 制限：クラシックな GitHub Pages は独自プラグインを実行しないため、分類ごとのページは作らず、分類の種類ごとに 1 ページとし、分類ごとにアンカーを置きます。記事には Markdown 版がなく、エージェントはアーカイブのリンクから記事を見つけます。Jekyll は `_posts/` より上のフォルダー名を `categories` に入れるため、記事は最上位の `_posts/` に置き、front matter で `lang:` を指定してください。
