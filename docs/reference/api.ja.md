---
lang: ja
permalink: /ja/reference/api/
source_rev: sha256:0fecde96120b
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
| 設定 | [設定](../../guides/configuration/)に載っている `modootoday:` の下のすべてのキー。 |
| デザイントークン | `--mt-*` カスタムプロパティ。プリミティブの `--mt-p-*` は除く。 |
| Sass | トークンフック `_sass/modootoday/_site.scss` とその上書き用マップだけ。[カスタマイズ](../../guides/customize/#トークンブリッジ)を参照。 |
| Markdown ルール | `RULES.md` のパターン、その `mt-*` クラス、`mt-flat-list`。 |
| レイアウト | `default`, `doc`, `page`, `post`, `archive`, `twin`, `llms`, `llms-full` |
| 上書きしてよい include | `head-custom.html`、`footer-custom.html`、`modootoday/brand/logo.html`。 |
| 自分で用意する include | `visual: <name>` で表示される `_includes/sections/<name>.html`。[カスタマイズ](../../guides/customize/#セクションのビジュアルと全幅ページ)を参照。 |
| モジュールのヘルパーとイベント | サイトの `scripts` 向けの ES モジュール 2 つ、`mt:themechange` イベント、`script:` ビジュアルの契約。 |
| 呼び出してよい include | `modootoday/archive.html`、`modootoday/brand/icon.html`、フッター用の include 2 つ。 |
| include | `modootoday/t.html` はページの言語でテーマの文言を出力する。 |
| データファイル | `_data/i18n/<lang>.yml`, `_data/nav/<name>.yml`, `_data/navigation.yml`, `_data/authors.yml`, `_data/components.yml` |
| チェッカー | `modootoday-check` のオプションと終了コード。 |
| 静的な図 | front matter の `diagrams:`、`data-mt-src` のダイジェストの規則、`diagram.source` のラベル。`modootoday.math.mode: static`、`_data/math/<key>.yml`、front matter の `math_key:`、`math.label` のラベル。 |
| レコードのページ | `modootoday.records`、レコードの front matter、事実の一覧。 |
| スタブ作成 | `modootoday-stubs` のオプション、スタブのファイル名と front matter、終了コード。 |

上の行の詳細:

- デザイントークン: 生成される `tokens.json` にも同じトークンが入っています。
- Sass: マップは `$mt-overrides-base`、`$mt-overrides`、`$mt-overrides-dark` です。ほかの Sass パーシャルと変数は内部用です。
- Markdown ルール: `mt-flat-list` は、その下のリスト項目の間隔をなくすための解除用クラスです。
- レイアウト: `page` は、Jekyll と minima が使う名前で呼ぶ `doc` レイアウトです。
- include: 自分のフッターから `modootoday/lang-switch.html` と `modootoday/brand/logo.html`(`size` を指定可)を include できます。独自のロゴを描くには `modootoday/brand/logo.html` を上書きします。`modootoday/archive.html` は `by` と `lang` を受け取ります。`modootoday/t.html` は `key=` と、任意の `n=` / `name=` を受け取ります。
- `modootoday/brand/icon.html` は `name`(globe, sun, moon, search, menu, copy, check, external, prev, next, chevron-right, chevron-down, note, tip, important, warning, caution, edit, rss, tag, folder, brand)、任意の `size`(px、既定 18)、`label`(指定するとその名前の `role="img"`、なければ `aria-hidden`)、`class` を受け取ります。出力は `currentColor` の `svg.mt-icon.mt-icon-<name>` で、方向のあるアイコンには `.mt-icon-flip` が付き、RTL で反転します。
- モジュールのヘルパー: `assets/js/modootoday/theme/current.js`(`currentTheme()` と、待ち受けを止める関数を返す `onThemeChange(callback)`)と `assets/js/modootoday/dom/config.js`(`readConfig(element, defaults)`)です。`mt:themechange` イベントは[イベント](#イベント)を参照してください。`script:` ビジュアルの契約は `data-mt-script`、`.mt-visual-stage`、`data-mt-ready` です。[カスタマイズ](../../guides/customize/#モジュールスクリプトとポスター)を参照。
- データファイル: `_data/i18n/<lang>.yml` のキーは、組み込みのカタログを上書きするときだけ書きます。`_data/navigation.yml` は `main` を読みます。
- チェッカーの終了コード: 0(問題なし)と 1(問題あり、または使い方の誤り)。`modootoday-check SRC --diagrams` は、SVG がないか古い静的な図を JSON (`page`、`name`、`line`、`fence`、`digest`、`files`、`reason`) で出力し、一覧が空でなければ 1 で終わります ([図を最新に保つ](../../recipes/math-diagrams/#図を最新に保つ)を参照)。`modootoday-check SRC --math` は静的な数式について同じことをし、書き出す `_data/math` のファイル (`key`、`file`、`page`、`line`・`tex`・`digest` からなる `blocks`、`reason`) を出力します。
- 静的な図: `diagrams: [{name, alt, caption, width, height}]` は、ページの n 番目の ```` ```mermaid ```` フェンスを n 番目の項目に対応させます ([数式と図](../../recipes/math-diagrams/#静的な-mermaid-の図)を参照)。SVG のルート要素の `data-mt-src="sha256-<hex>"` は、その SVG を描いたフェンスを記録します。値は、フェンス本文 (フェンスの行の間の行) の CRLF と CR を LF にし、最後の改行を除いた SHA-256 です。`data-mt-src` がフェンスのダイジェストと違う SVG は、`modootoday-check` が古い図 (stale diagram) として報告します。`_data/i18n/<lang>.yml` の `diagram.source` はソースの開閉要素の名前です。
- 静的な数式: `modootoday.math.mode: static` では、ページの n 番目の ```` ```math ```` フェンスか `$$` ブロックが、`{src, html}` の一覧である `_data/math/<key>.yml` の n 番目の項目の `html` に置き換わります ([静的な数式](../../recipes/math-diagrams/#静的な数式)を参照)。`<key>` はページの既定言語の原文のパスから拡張子を除き、`/` を `--` と書いたものです (front matter の `math_key:` で変えられます)。`src` は区切りの間の TeX に上の規則を適用したブロックのダイジェストです。`math.label` (`数式 [n]`) が各ブロックの領域の名前です。
- レコードのページ: `modootoday.records`([生成ページ](../../recipes/generated-pages/)を参照)、ページの front matter `record: <set>/<key>` と `record_index`、ディレクトリページの `records: <set>`、事実の一覧 `dl.mt-detail-facts.mt-record-facts`。
- スタブ作成: スタブのファイルは `<name>.md.txt`、`<name>.flat.md.txt`、`<name>.html.md.txt`、レコードのページ `<dir>/<key>.md` です。終了コードは 0(何もすることがない、プレビューした、または書き込んだ)、1(`--check` が差分を見つけた)、2(使い方または `_config.yml`)、3(データ)です。

## Markdown のルール

`md-components v1` は `RULES.md` にある Markdown ルール標準の名前で、CSS の接頭辞ではありません。出力クラスは `mt-*` を使います。

## コンポーネントの構造

自分の CSS から今すぐ対象にできるマークアップです。この表のクラスと属性は公開 API に含まれます。表に名前のない内側の要素 (ラッパー、生成される id、子要素の順序) は安定していません。下のスロット契約が、各コンポーネントが使う Markdown の部分を定めます。

| コンポーネント | ルート | 部分 | 状態 |
|---|---|---|---|
| ページの枠 | `body.mt-body` | `a.mt-skip`, `header.mt-header`, `main.mt-main`, `footer.mt-footer` > `.mt-footer-inner` | `html[data-theme=light\|dark]` |
| ドキュメントページ | `article.mt-doc` | `.mt-doc-layout` > `.mt-doc-main` と `.mt-doc-aside` (`nav.mt-toc` を含む), `nav.mt-toc-mobile`, `nav.mt-breadcrumb`, `.mt-page-meta`, `nav.mt-pagination` | — |
| ドキュメントのサイドバー | `aside.mt-doc-nav` > `nav.mt-sidebar`、`details.mt-sidebar-mobile` | `.mt-sidebar-group`、`.mt-sidebar-title`、リンクの `ul` | `.mt-doc-layout.mt-has-sidebar`、モバイルメニューの `[open]` |
| ページの操作 | `details.mt-menu.mt-page-actions` | `summary`、`button[data-mt-act=copy\|ai]`、`a[type="text/markdown"]` | `[open]` |
| ヒーロー | `section.mt-hero` | `h1`、`p.mt-hero-lead`、リンクだけの `p`(ボタン) | `.mt-hero-checks` |
| セクション | `section.mt-section` | `h2` とその内容 | `[data-section]`、`[data-c]`、`.mt-c-<c>`、`.mt-cols-<n>`、`.mt-cta` |
| セクションの装飾 | `section.mt-hero` または `section.mt-section` の `.mt-has-decor` | `.mt-section-decor[aria-hidden=true]` | — |
| スクロール表示 | `section.mt-hero` または `section.mt-section` の `.mt-reveal` | — | スクロールでゆっくり表示 |
| 全幅の帯 | `section.mt-hero` または `section.mt-section` の `.mt-bleed`、`.mt-bleed-wide` | — | `--mt-bleed-bg` で帯の色を指定 |
| イラスト | `figure.mt-illustration[role=img][aria-label]` | `.mt-illustration-tag` | — |
| リストスタイル | `ul.mt-chips`、`li > strong.mt-item-title + span.mt-item-sep` | `li > a` のチップ、タイトルと区切り | — |
| 本文 (`sections:` なし) | `div.mt-prose` | 描画された本文 | — |
| カードグリッド | `section.mt-section` | `ul > li`、先頭の `strong` がタイトル | `.mt-cols-2`, `.mt-cols-3`, `.mt-cols-4`, `.mt-badge-bottom` (`c: features`) |
| タブ | `section.mt-c-tabs[data-tabs]` | `[role=tablist]`、`[role=tab]`、`[role=tabpanel]` | `[aria-selected]` |
| アコーディオン | `section.mt-c-accordion` | `h3 > button[aria-expanded]`、その後のパネル | `[aria-expanded=true\|false]` |
| ステップ / タイムライン | `section.mt-c-steps`, `section.mt-c-timeline` | `ol > li` または `h3` の項目 | — |
| ファイルツリー | `section.mt-c-filetree` | `ul[aria-label]`、入れ子の `ul`(フォルダー) | — |
| 詳細 / FAQ | `section.mt-c-details`, `section.mt-c-faq` | `details.mt-details`、`summary > h3`、その後の内容 | `[open]` |
| 表 | `div.mt-table` | その中の `table` | `table.mt-table--stack`、`table.mt-table--dl`、`table.mt-table--fixed`、`td[data-label]` |
| パラメーター表 | `section.mt-c-params` | `th[scope=col]`、`.mt-param-required` | 狭い画面で積み重なる |
| リンクカード | `section.mt-c-linkcards` | `ul > li > a`(カード全体がリンク) | — |
| 引用 | `figure.mt-quote` | `blockquote`、`figcaption` | — |
| ギャラリー | `section.mt-c-gallery` | `a.mt-gallery-thumb`、`a.mt-lightbox`、`.mt-lightbox-close` | 開いたライトボックスの `:target` |
| 料金プラン | `.mt-plans` | `.mt-plan`、その `h3`、リンクだけの `p.mt-actions` | `.mt-plan-recommended` と `.mt-plan-flag` |
| 購読 | `section.mt-c-subscribe` | `form.mt-subscribe`、`label`、`input[type=email]`、`button` | — |
| 分割 | `section.mt-c-split` | `.mt-section-in` > `.mt-section-body` + `.mt-section-visual` | `.mt-split-start`、`.mt-split-5-7`、`.mt-split-code`、`.mt-split-terminal` |
| インライン追加要素 | `div.mt-code`, `span.mt-progress`, `div.mt-embed` | `.mt-code-title`, `progress`, `iframe` | — |
| 読み込み表示（任意シート） | `.mt-spinner`, `.mt-topbar`, `.mt-skeleton` | `.mt-skeleton-text`, `-card`, `-image`, `-avatar`, `-row`; `.mt-ratio-16x9`, `-4x3`, `-1x1` | `[aria-busy=true]`, `[role=status]` |
| バナー | `div.mt-banner` | その `p` とリンク、`a.mt-back-to-top` | — |
| アラート | `blockquote.mt-callout[role=note]` | `p.mt-callout-title`、本文 | `.mt-callout-<type>`, `[data-variant]` = note, tip, important, warning, caution |
| バッジ | `span.mt-badge` | ラベル(ステータスバッジの点は `::before` で描画) | `.mt-badge-<status>`, `.mt-badge-tag`, `[data-variant]` |
| キーボードのキー | `kbd.mt-kbd` | キーごとの `kbd` | — |
| 図 | `figure.mt-figure` | `img`、`figcaption` | — |
| 静的な数式 | `figure.mt-figure.mt-math` | `<math>` 要素か KaTeX の HTML を入れた `div.mt-figure-scroll[role=region]` | — |
| 静的な Mermaid の図 | `figure.mt-figure.mt-figure-svg.mt-diagram` | `div.mt-figure-scroll[role=region]`、`img.mt-diagram-light`、`img.mt-diagram-dark`、`figcaption`、図の後の `details.mt-diagram-source` | もう一方の配色の画像は非表示 |
| 記事ヘッダー | `header.mt-post-header` | `h1.mt-post-title`、`.mt-post-deck`、`.mt-byline`、`figure.mt-post-cover`、`nav.mt-series`、`p.mt-post-meta` | `[data-part]` = header, deck, byline, authors, dates, cover, terms |
| 記事フッター | `article.mt-doc` | `.mt-share` ボタン、`nav.mt-post-nav`、`section.mt-related`、`.mt-news-correction`、`.mt-news-sources` | `[data-part]` = share, post-nav, related, sources |
| 記事カード | `article.mt-card-post` | `.mt-card-post-cover`、`.mt-card-post-meta`、`.mt-card-post-title`、`.mt-card-post-excerpt` | `.mt-card-post-featured`、`[data-kind=news]`、`.mt-post-list[data-variant=list\|grid\|magazine]` |
| ニューストップ | `div.mt-news-top` | `.mt-news-lead`、`.mt-news-secondary`、`section.mt-news-latest`、`section.mt-news-section` | `[data-category]`、`.mt-badge[data-variant=breaking\|live]` |
| 検索 | `div.mt-search[role=search]` | 入力欄、`.mt-search-results` | `[data-match=terms]`、`[data-compact]`、`[data-results]` |
| 絞り込み | `[data-mt-filter]` | `div.mt-filter`、`.mt-filter-chips[role=group]` > `button[aria-pressed]` | `[data-facet]`、外れた項目の `[hidden]` |
| グラフ | `figure.mt-chart` | `.mt-chart-canvas`（グラフのモジュールがキャプションを名前にした `canvas[role=img]` を描くまで `[hidden]`）、`.mt-chart-data` > `div.mt-table` > `table`（`figure.mt-chart table`。描いた後は `details` > `summary` の中に畳まれる）、`figcaption` | `[data-type]`、`[data-opts]`、色のフック `--mt-chart-1`〜`--mt-chart-8`、`--mt-chart-grid`、`--mt-chart-text` |

上の行についての補足:

- ページの枠: `header.mt-header` > `.mt-header-inner` の中に `.mt-site-title` > `.mt-site-name`(サイト名。2 行まで表示し、長い単語はドットの後ろで折り返し、あふれたら省略記号。ロゴがあるとタイトルに `.mt-compact-title` が付き、30rem より狭いと名前を画面上だけ隠す)、`nav.mt-nav`、`.mt-search`、`details.mt-lang.mt-menu`、`.mt-theme-toggle` があります。`nav.mt-nav` は 64rem 以上ではリンクが 1 行に並ぶ `ul`、それより狭いと `details.mt-menu.mt-nav-sheet` になります。そこには `summary` のメニューボタンと、`.mt-nav-sheet-label` のグループ名を含む `ul` のシートがあります。言語メニューには `summary` の地球儀ボタンと `a[lang][hreflang]` の `ul` があり、現在の言語には `aria-current` が付きます。`html[data-theme]` は固定の配色か切り替えボタンが設定します。
- ドキュメントのサイドバー: `nav.mt-sidebar` は 64rem 以上で、`details.mt-sidebar-mobile` はそれより狭いときに表示されます。現在のリンクには `aria-current=page` が付きます。
- ページの操作: ボタンは `ul` の中にあり、JS が動くまで隠れています。`a[type="text/markdown"]` は「Markdown で表示」のリンクです。
- ヒーロー: リードは `h1` の直後の最初の `p` です。リンクだけの `p` では最初のリンクが主ボタンになります。`.mt-hero-checks` は front matter の `hero: {checks: true}` で有効になり、最初の `ul` が `--mt-ok` の色の ✓ の行になります。
- セクション: `[data-section]` は名前、`[data-c]` と `.mt-c-<c>` はコンポーネントです。`.mt-cta` はセクションに付き、セクション内に `[data-mt-result]` 要素があればその要素に付きます。
- セクションの装飾: front matter の `decor: <include>` で有効にします。装飾は最後の子要素で、`_includes/sections/<include>.html` を含み、上の終端側の角に置かれ、ポインターイベントを受けません。
- スクロール表示: front matter の `reveal: true` で有効にします。CSS のみで、`@supports (animation-timeline: view())` と `prefers-reduced-motion: no-preference` の場合だけゆっくり表示され、それ以外ではそのまま表示されます。
- 全幅の帯: front matter の `bleed: true` または `bleed: wide` で有効にします。サイドバーや目次があるレイアウトでは、帯は本文の列の中に収まります。`bleed` シートを使います。
- イラスト: サイトで用意する include です。タグは絵の上の開始側に置くバッジです。`role=img` の子要素は読み上げられないので、タグの文字も `aria-label` に入れてください。
- リストスタイル: `modootoday.lists` を有効にすると使われます。チップは高さ 44px で、テキストの後に → が付きます。区切りは `: ` です。
- タブ: タブの部分は JS が作ります。JS がなければ `h3` とコードブロックがそのまま残ります。
- ファイルツリー: 入れ子の `ul` がある項目がフォルダーです。
- 表: `div.mt-table` は描画時に本文のすべての表を包み、スクロールでき、はみ出すとラベル付きの領域になります。本文ではクラスを付けません。3 つのクラスは、サイトが自分で書くレイアウトや include の表のためのフックです（本文の kramdown の属性リストは移植できず、`modootoday-check` が報告します）。`c: params` の表と、40rem より狭いときに収まらない表は `--stack` になります。スクリプトが積み重ねた表にラベルを付けると `[data-mt-labelled]` と `td[data-label]` が付きます。スタイルは `table`・`table-stack` シートにあります。
- パラメーター表: 40rem 未満で `table.mt-table--stack` として積み重なります。
- 購読: `form.mt-subscribe` は action を設定したときに出ます。
- 分割: `.mt-section-body` には `h2` と本文、`.mt-section-visual` には `visual:` の include が入ります。`hero: {c: split}` は `section.mt-hero` を同じラッパーで包み、`h1`、リード、チェックの行、アクションは `.mt-section-body` に入ります。`visual: code` は最初のコードブロックを `div.mt-section-visual.mt-split-code` に入れ、`chrome: terminal` は `.mt-split-terminal` と `div.mt-split-bar`(`aria-hidden`)を加えます。
- 記事ヘッダー: `.mt-byline` の中に `.mt-byline-authors` > `.mt-post-author` と `.mt-byline-dates` > `time` があり、`p.mt-post-meta` にはタグのバッジが入ります。
- 検索: 状態の値は `modootoday.search` から付きます。
- 絞り込み: ルートは `section.mt-section`、`div.mt-prose`、`div.mt-dir` です(front matter の `filter:`、`filter_text:`)。`div.mt-filter` には `input[type=search]` と `output[aria-live]` があり、スクリプトが最初のリストか表の前に移すまで隠れています。チップは facet があるときに出て、`[data-facet]` は列番号です。`filter` シートを使います。

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

## イベント

| イベント | 送られるとき | `detail` |
|---|---|---|
| `mt:themechange` | ページのライト・ダーク表示が切り替わったとき。 | `{theme: "light" または "dark", source: "toggle" または "system"}` |

テーマ切り替えボタン(`theme-toggle.js`)が `document` に送ります。ボタンを押した後と、読者が配色を選んでいない状態でシステムの配色が変わった後に送られます。同じ文書の中だけで送られ、最初の描画のときや、切り替えボタンがないサイト(`color_scheme: light` または `dark`)では送られません。

切り替えボタンがなくても動き、実際に変わったときに一度だけ呼ばれるようにするには、`assets/js/modootoday/theme/current.js` の `onThemeChange` を使ってください。イベントとシステムの設定を両方待ち受け、待ち受けを止める関数を返します。

## 右から左への表記と数式

- アラビア語、ペルシア語、ヘブライ語、ウルドゥー語などの RTL 言語のページは `lang` から `dir="rtl"` を受け取ります。front matter の `direction: rtl` または `ltr` (または `_data/i18n/<lang>.yml` の `direction:`) で上書きできます。コンポーネントは論理プロパティを使って左右が反転し、コードは左から右のままです。
- テーマは数式や図のレンダラーを同梱しません。静的な図と数式は、コミットした SVG ファイルと MathML を表示します。[数式と図](../../recipes/math-diagrams/)を参照してください。

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
