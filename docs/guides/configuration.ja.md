---
lang: ja
permalink: /ja/guides/configuration/
source_rev: sha256:aed6bc9743a2
nav_order: 20
title: 設定
description: _config.yml の modootoday キーに書くサイト全体の設定をすべてまとめ、それぞれの既定値、変わる点、詳しく説明しているページを示します。
sections:
  - keys
  - new-window
  - head
  - i18n
  - registry
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

| キー | 既定値 | 役割 |
|---|---|---|
| `badges` | `true` | ステータスのコードスパンをバッジで表示する。`false` ならコードのまま。 |
| `code_theme` | `theme` | コードブロックの色。テーマの色(`theme`)か GitHub の色(`github`)を選ぶ。[コードの色](../customize/#コードの色)を参照。 |
| `color_scheme` | `auto` | ライト・ダークの表示。`auto` は端末に合わせ、`auto-dark`・`auto-light` は開始時の表示を、`light`・`dark` は固定の表示を決める。 |
| `components` | すべて | サイトが配信するコンポーネントの CSS と JS を絞る。 |
| `css_layers` | `false` | テーマの CSS を `@layer mt.*` で包む。 |
| `nav` | `main` | メニューを作る `_data/nav/` のファイル。`items:` がある項目はグループになる。 |
| `sidebar` | `auto` | `doc` ページのサイドメニュー。`auto` はメニューにグループがあるとき、`true` は常に表示、`false` は表示しない。 |
| `page_actions` | `true` | ページのコピーや Markdown 表示ができるメニュー。`false` で消える。 |
| `tokens` | テーマの値 | テーマの色などのデザイントークンを変える。厳格な CSP のサイトでは[トークンブリッジ](../customize/#トークンブリッジ)を使う。 |
| `tokens_dark` | テーマの値 | 同じことをダークモードだけで行う。 |
| `site_css` | なし | `[/assets/css/site.css]` のような独自のスタイルシートを、テーマのシートの後に読み込む。[ブランドトークン](../../recipes/brand-tokens/)を参照。 |
| `preload` | なし | フォントなど、ブラウザーに先に取得させるファイル。`{href, as, type}` のリストで書く。 |
| `scripts` | なし | 独自の JavaScript モジュール。`script:` で名前を指定したページか、その `element`（ウィジェット）があるページだけが読み込む。[モジュールスクリプトとポスター](../customize/#モジュールスクリプトとポスター)と[ウィジェット](../../recipes/figures/widgets/)を参照。 |
| `search` | なし | ヘッダー検索の設定。索引する本文の量と、検索語の照合方法を決める。[検索](../../recipes/search/)を参照。 |
| `twins` | スタブ | 各ページの Markdown 版の出し方。`source` は front matter のないページを使う。[AI エージェント](../agents/)を参照。 |
| `aliases` | なし | エージェント向けの追加 URL。`md: true` は `/<page>.md` を加え、`html: true` は `/<page>.html` をリダイレクトする。[URL エイリアス](../agents/#url-エイリアス)を参照。 |
| `records` | なし | `_data` ファイルの項目ごとにページを 1 つ作る。[生成ページ](../../recipes/generated-pages/)を参照。 |
| `seo` | `true` | `false` で組み込みの canonical、`hreflang`、Open Graph タグを出さない。 |
| `hreflang` | `seo` に従う | `true` なら `seo: false` でも `hreflang` リンクを残す。`jekyll-seo-tag` を使うサイト向け。 |
| `schema` | `url` があれば有効 | schema.org の構造化データを出す。`false` で無効。[構造化データ](../structured-data/)を参照。 |
| `languages` | なし | `[en, ko]` のようなサイトの言語コード。`hreflang` と言語メニューに使う。 |
| `full_languages` | なし | すべてのページを翻訳する言語(例: `[ko, ja]`)。`modootoday-check --i18n-pages` が足りない翻訳を警告する。 |
| `lists` | なし | `{link_chips: true, titled_items: true}` で、リンクだけのリストをチップに、`**タイトル**:` の項目を見出し付きの項目にする。 |
| `heading_anchors` | `false` | **1.7** `true` で、ドキュメントと投稿の `##`・`###` 見出しの末尾に、その見出し自身へのリンクを付ける。ポインターを重ねるかフォーカスすると表示され、タッチ画面では常に表示される。 |
| `language_switcher` | なし | 言語メニューを `header`(地球儀ボタン)か `footer`(言語名の一覧)に表示する。 |
| `og_image` | なし | **1.7** リンクプレビューの既定の画像。パス、または画像の代替テキスト(`og:image:alt`)とサイズを加える `{path, alt, width, height}`。ページの `image:` が優先し、次に hero の画像かポスター。ページの `image.alt` か `image_alt` がその画像の代替テキスト。 |
| `feed` | `false` | **1.7** `true` ですべてのページの head にサイトの Atom フィード(`/feed.xml`、またはフィードがある言語のページでは `/<lang>/feed.xml`)をリンクし、`category` も `tag` もないブログ一覧に購読リンクを加える。フィードのファイルは書かない。フィードは `layout: feed` の `feed.xml` ページがプラグインなしで書く([著者とフィード](../../layouts/blog-news/#著者とフィード)を参照)。そのページと `jekyll-feed` はどちらも `/feed.xml` を書くので、一方だけを使う。 |
| `logo` | なし | `brand` でサイト名の前にテーマのマークを、パスを指定するとその画像を表示する。 |
| `favicon` | なし | `brand` でテーマのマークを、パスを指定するとそのアイコンをサイトのアイコンにする。 |
| `pwa` | オフ | **1.7** `enabled: true` でサイトのタイトル、`theme_color`、ブランドのマークから作るウェブアプリマニフェストをリンクし、ブラウザーがサイトをインストールできるようにして、オフラインで読むためのサービスワーカーを登録します。`precache:` には追加で保存するサイトのパスを書きます(ページは front matter の `pwa: precache` で自分を加えられます)。`shortcuts:` と `screenshots:` はアプリアイコンのメニューとインストールダイアログの画像を加えます。`enabled: kill` は自分を取り除くワーカーを出します。[インストールできるサイト](../../recipes/pwa/)を参照。 |
| `header` | `{compact_title: true}` | `compact_title: false` でスマートフォンでもロゴの横にサイト名を表示する。 |
| `csp` | なし | `strict` で、最初の描画前に動くテーマのスクリプトをインラインではなくファイルから読み込む。 |
| `asset_version` | `theme` | テーマのファイル URL の `?v=` に付ける値。`theme` はバージョン、`build` はコミットまで、`false` は何も付けない。[パフォーマンス](../performance/#バージョン付きアセット-url)を参照。 |
| `viewport_fit` | `cover` | `auto` でスマートフォンのノッチを避けてページを描く。[アクセシビリティ](../accessibility/#設定)を参照。 |
| `theme_color` | ページ背景 | ブラウザーのバーの色。`"#hex"` 1 つ、`{light: "#hex", dark: "#hex"}`、または出さないなら `false`。 |
| `edit_url` | なし | **1.7** 「このページを編集」リンクの URL の先頭部分。末尾は `/`。`auto` なら GitHub Pages がビルドするリポジトリー、ブランチ、フォルダーから作ります(下記)。 |
| `feedback` | オフ | **1.7** ページ下の一行を作るマップです(例は head と SEO にあります)。`issues` は `auto`、`https://github.com/OWNER/REPO/issues` のようなリポジトリーの issue の URL、または `false` で、問題を報告するリンクを加えます。`helpful` は `true` か `false` で、`true` ならページが役に立ったかを尋ねる二択の質問を加え、`issues` が必要です。`discuss` はリポジトリーの Discussions ページのような http(s) の URL で、そこへのリンクを加えます。`labels` は事前入力する issue に付けるラベル名のリストです。front matter の `feedback: false` でそのページから隠します。 |
| `build_link` | `false` | **1.7** `true` なら、サイトをビルドしたコミットを「[commit] からビルド」と表示し、GitHub のそのコミットにリンクします。 |
| `archive` | なし | `{tags: /tags/, categories: /categories/}` のようなタグ・カテゴリーページの URL。記事フッターのリンク先になる。[記事とアーカイブ](../../reference/api/#記事とアーカイブ)を参照。 |
| `mermaid` | 無効 | ```` ```mermaid ```` ブロックを図として描く。[図と数式のローダー](../../recipes/figures/loaders/#組み込みローダー)を参照。 |
| `diagrams` | `{dir: /assets/diagrams/, dark: true, source: details}` | [静的な Mermaid の図](../../recipes/figures/math-diagrams/#静的な-mermaid-の図)の SVG を置く場所、ダークモード用の SVG があるかどうか、Mermaid のソースをページに残すかどうかを決める。 |
| `math` | 無効 | ```` ```math ```` と `$$` のブロックを ブラウザーの KaTeX で描画する。`mode: static` なら `_data/math` にコミットした MathML を表示する。[数式と図](../../recipes/figures/math-diagrams/#静的な数式)を参照。 |
| `external_links` | なし | `new_window: true` で、ほかのサイトへのリンクを新しいウィンドウで開く。[新しいウィンドウで開くリンク](#新しいウィンドウで開くリンク)を参照。 |
| `blog` | なし | `per_page` などのブログ設定。[ブログとニュース](../../layouts/blog-news/#設定)を参照。 |
| `authors` | `true` | `false` で記事と記事カードの署名を隠す。著者のデータは `_data/authors.yml` に残す。 |
| `news` | なし | トップページの `sections:` などのニュース設定。[ブログとニュース](../../layouts/blog-news/#設定)を参照。 |
| `css` | `split` | `split` はページが使う CSS だけを、`bundle` はすべてを含むシート 1 つを読み込む。 |
| `banner` | なし | **1.7** `{text: "…", url: /path/, link: "詳しく"}` で、すべてのページにお知らせバーを表示する。`text` がないとき、`release: latest` はビルド時に `site.github` からリポジトリーの最新リリースを知らせ(「1.7.0 を公開しました。」と「新機能」リンク)、`release: {version, url}` は指定した値で同じバーを作る。 |
| `print` | `false` | **1.7** `true` で、印刷のときだけ読み込む印刷用スタイルシートを加える。ヘッダー、メニュー、バナー、更新のお知らせ、インストールのセクション、ページ下のリンクを除き、白地に黒で印刷し、タブのパネルをすべて印刷し、リンクの後にアドレスを付け、図・コード・表をページの境目で分けない。`details`、アコーディオン、FAQ の項目は、読者が先に開かなければ要約だけを印刷する。 |
| `back_to_top` | `false` | `true` ですべてのページの末尾に「先頭へ戻る」リンクを追加する。 |
| `loading` | `false` | `true` で、独自スクリプトのためにスピナーとスケルトンのスタイルを全ページで読み込む。 |
| `showcase` | 無効 | `{enabled: true, style: bar, starter:, docs_url:, use_url:}`: スターターのデモのビルドに、テーマのドキュメントへ戻るバー(`style: pill` なら浮かぶピル)を表示する。デモ専用の設定ファイルに書く。[スターターのデモのショーケース](../../reference/showcase/)を参照。 |
| `chart` | 無効 | `{enabled: true, src:, integrity:}`: 表の直前に `chart:<type>` だけの行を置くと、その表がグラフの figure になり、サイトの Chart.js(`src`)が描画する。[グラフ](../../recipes/figures/charts/)を参照。 |
| `subscribe` | なし | `{action: https://…}`: `c: subscribe` のメールフォームが登録を送る先。 |

説明が **1.7** で始まる行は、リリース 1.7 で追加されたキー、または既存のキーの新しい形(`edit_url: auto` など)です。古い gem に固定したサイトにはまだありません。リリースごとの追加内容は[移行とアップグレード](../upgrade/#アップグレード)にあります。

`modootoday-check` はすべてのキーを検証します。安定した名前の一覧は[公開 API](../../reference/api/)にあります。

### いくつかのキーの詳細

- `color_scheme`: `auto-dark`・`auto-light` は切り替えボタンを残し、読者の選択を記憶します。`light`・`dark` には切り替えボタンがありません。開始時の配色は HTML に書き出されるので、ちらつきません。
- `components`: `lists`・`bleed`・`terminal`・`visual`・`filter`・`table`・`table-stack`・`showcase` は常に含まれます。そのシートは `lists:` または `hero: {checks: true}`、`bleed:`、`chrome: terminal`、`script:` または `poster:`、`filter:` または `filter_text:`、`modootoday.showcase` で有効にしたページか、本文に表があるページにだけ読み込まれます。リストを絞るときに SVG 図のスタイル(ダークトーン、横スクロール、静的な数式を囲む領域も含む)を残すには `figure` と一緒に `figure-svg` を、静的な Mermaid の図のライトとダークの切り替えを残すには `diagram` を入れてください。
- `nav`: 前後のページへのリンクはこのファイルの順序(グループ自体のページ、次にその項目)に従います。このファイルがないとき、ヘッダーは `_data/navigation.yml` の `main`、次に `header_pages`(minima と同じページパスの一覧)、次に、HTML ページが 100 以下のサイトでは `title` のある最上位のページ(`/about/` など)をすべて読みます(`nav_order` が先、次にタイトル順。`nav: false` または `nav_exclude: true` のページは除く)。`nav: false` は最後の一覧を止めます。
- `sidebar`: 64rem より狭い画面では本文の上の折りたたみメニューになります。front matter の `sidebar: false` でそのページだけ隠せます。
- `page_actions`: Markdown 版があるページに「Markdown で表示」「ページをコピー」「AI 向けにコピー」(出典 URL のあとに Markdown)のメニューが出ます。front matter の `page_actions: false` はそのページだけ消し、完全に外すなら `components` から `page-actions` を除きます。
- `tokens`, `tokens_dark`: 値はインラインの `<style>` に書き出されます。
- `site_css`, `preload`: `site_css` のシートにはテーマのシートと同じ `?v=` クエリが付きます。`preload` の `href` はサイトパス、`as` は `font`、`image`、`style`、`script`、`fetch` のいずれかです。フォントと fetch には `crossorigin` が付き、`?v=` クエリは付きません。front matter の `site_css:` と `preload:` はそのページだけに追加します。
- `scripts`: 各項目はサイトパスで書いた `{src, css, preload, element}` です。`src` は `.js` ファイル、`css` はシート、`preload` は `modulepreload` するモジュール、`element` はモジュールが定義するカスタム要素（ハイフンを含む小文字、`mt-` で始まらない、要素ごとに項目は一つ）で、`c: widget` と `widget:` がページに置きます。
- `aliases`: スタブは `modootoday-stubs --aliases` が書き、`modootoday-check --aliases` が確認します。`twins: source` とは `md` を併用できません。
- `records`: セットごとに `{data, key, dir, permalink, layout, title, description, facts, labels, body, lang}` を指定します。ページは `modootoday-stubs --records` が書き、`modootoday-check` が確認します。
- `schema`: グラフの設定は `publisher`、`search_url`、`layouts`、`faq` です。
- `languages`: ヘッダーのサイト名は、その言語のホーム(`/<lang>/`)があればそこにリンクします。
- `lists`: 通常のセクションとページで、リンクだけのリストは `ul.mt-chips` に、`**タイトル**:` で始まる項目は `strong.mt-item-title` になります。任意のシート `lists` がこれらと `hero: {checks: true}` を整え、使うページにだけ読み込まれます。
- `heading_anchors`: リンクは見出しの中、テキストの後に付く `a.mt-anchor` で、名前はページの言語の「セクション「[見出し]」へのリンク」です。スクリプトは要りません。コンポーネントセクション(`c:`)の見出しはそのままで、目次、検索、Markdown 版も変わりません。`components` のリストを使うときは `anchor` を入れると残ります。任意のシート `anchor` がリンクを整え、使うページにだけ読み込まれます。
- `language_switcher`: 各リンクはこのページの翻訳、なければその言語のトップページに移動します。ヘッダーのメニューは言語数によらず幅が一定で、言語が 2 つ未満なら表示しません。メニューは JavaScript なしで開き、`menu.js` が Esc、矢印キー、外側のクリックで閉じる動作を加えます。
- `logo`, `favicon`: `brand` のマークは `currentColor`(`brand` トークンなのでライト・ダークに追従)で描きます。独自のロゴ画像は装飾扱い(`alt=""`)です。別のロゴを描くには `modootoday/brand/logo.html` を上書きします。`brand` のファビコンは SVG、32px PNG、Apple タッチアイコンをリンクします。
- `header`: 画面の幅が 30rem(480px)より狭いと、`logo` のあるサイトはヘッダーにロゴだけを表示します。スクリーンリーダーはサイト名をそのまま読み上げます。`logo` がなければ名前は常に表示されます。
- `diagrams`: ページは front matter の `diagrams:` に、```` ```mermaid ```` フェンスごとに項目を一つずつ並べます。`dir` はサイトのパスです。`dark: false` なら図ごとに SVG を一つ使い、ほかの `.svg` の図と同じように暗くします。`source: none` ならフェンスは HTML から外れます。
- `mermaid`, `math`: 設定は `{enabled: true, src:, integrity:, theme: auto}` と `{enabled: true, engine: katex, src:, css:, integrity: {js:, css:}, auto_render_src:, auto_render_integrity:, inline: false}` で、ブロックのあるページでだけ読み込みます。`src` はバージョンを固定した https URL と SRI の `integrity` ハッシュ、またはサイト内のパスです。`inline: true` なら `$…$` も描画します。`base: /assets/vendor/katex/` は、KaTeX の `dist/` フォルダーを自分でホストするときに `src`、`css`、`auto_render_src` の代わりになります。`mode: static`（既定は `client`）はスクリプトを読み込まず、各ブロックを `_data/math/<key>.yml` の n 番目の項目に置き換えます。このファイルは `modootoday-check SRC --math` が一覧にし、`script/figures/math.mjs` が書き出します。`enabled`、`src`、`integrity` は不要で、`enabled: false` で無効になります。CDN を使うと `script-src`(数式は `style-src` と `font-src` も)にそのオリジンが加わり、訪問者の IP アドレスが CDN に送られます。
- `chart`: `src` は Chart.js 4(`dist/chart.umd.min.js`)で、URL と `integrity` の規則は同じです。Chart.js とテーマのグラフモジュールはグラフのあるページでだけ読み込みます。`src` がなければグラフは表のままです。
- `banner`: バーはスキップリンクの下に表示されます。
- `loading`: Markdown でスピナーやスケルトンを使うページは、シートを自動で読み込みます。

## 新しいウィンドウで開くリンク

新しいウィンドウで開く動作は、明示的に有効にしたときだけ働きます。リンクごと、または外部リンク(サイトの `url:` で始まらないリンク)全体に設定できます。

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

`url:` を設定すると、すべてのページに canonical リンクと Open Graph タグが付きます。プラグインは要りません。`languages:` を設定すると、複数の言語にあるページが `hreflang` で互いにリンクします。サイトマップは GitHub Pages が許可するプラグインを使う任意機能で、Atom フィードにはプラグインが要りません(上の `feed` キー)。

```yaml
url: https://example.github.io
modootoday:
  languages: [en, ko]
  edit_url: https://github.com/OWNER/REPO/edit/main/docs/
plugins: [jekyll-remote-theme, jekyll-sitemap]
```

フィードバックの行はマップを取り、どのキーも省略できます。

```yaml
modootoday:
  feedback:
    issues: auto        # または https://github.com/OWNER/REPO/issues、または false
    helpful: true       # true か false。issues が必要
    discuss: https://github.com/OWNER/REPO/discussions
    labels: [docs, feedback]
```

フィードバックのリンクは事前入力した GitHub のフォームを開きます。issue のタイトルはページのタイトルで(二つの答えでは前に "Helpful: " か "Not helpful: " が付きます)、本文はページの URL です。テーマはスクリプトを加えず、何も送りません。読者がクリックするまでブラウザーはリクエストせず、issue を作る前に GitHub がサインインを求めます。ラベルは読者がそのリポジトリーでラベルを付けられるときだけ付き、存在しないラベルは無視されます。

`edit_url: auto`、`build_link: true`、`feedback.issues: auto` は `site.github` を読みます。GitHub Pages はビルドするリポジトリーからこの値を埋め、リポジトリーやコミットがわからなければリンクを省きます。ほかの環境では `jekyll-github-metadata` プラグインを使うか、`_config.yml` に `repository_url`、`source: {branch, path}`、`build_revision` を書いた `github:` マップを置くと、その代わりになります。どれもなければ `modootoday-check` が警告します。`edit_url` に URL を直接書けば、常に `auto` より優先されます。GitHub Pages がリポジトリーの Pages 設定を読めないとき(GitHub の外でのビルドやトークンなしのビルド)、`source` はルートの `gh-pages` か `master` ブランチになるので、その場合は URL を直接書いてください。

GitHub Pages の外では、`github:` マップを次のように書きます。`source.path` はリポジトリー内でサイトがあるフォルダーで、先頭にスラッシュを付け、末尾には付けません。ルートは `/`、`docs` フォルダーは `/docs` です。キーはすべて任意で、値がないリンクは省かれます。

```yaml
github:
  repository_url: https://github.com/OWNER/REPO
  source:
    branch: main
    path: /docs  # リポジトリーのルートは /
  build_revision: 0123456789abcdef0123456789abcdef01234567  # build_link 用の完全なコミット SHA
  latest_release:  # banner: {release: latest} 用
    tag_name: v1.2.0
    html_url: https://github.com/OWNER/REPO/releases/tag/v1.2.0
```

代わりに `jekyll-seo-tag` を使うなら、`seo: false` にして jekyll-seo-tag の `seo` タグを `_includes/head-custom.html` に入れます。front matter の `last_modified_at:` でページに日付を表示できます。パンくずリストの最初の項目は、ホームページの front matter に `short_title:` があればそれを、なければ `title` を表示します。厳格な Content Security Policy については [CSP](../../recipes/csp/) を参照してください。

## 言語

順に進める手順は[サイトを翻訳する](../translate-site/)にあり、この節は完全なリファレンスです。

UI の文字列は `_data/i18n/<lang>.yml` に置きます。翻訳ページは原文の隣か `<lang>/` に置きます(後述)。

```yaml
language: 한국어
site_title: 모두의오늘 테마 # ヘッダー、<title>、og:site_name、JSON-LD の名前。ない場合は site.title
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

テーマにない言語を追加するには、英語のカタログと同じキーで `_data/i18n/<code>.yml` を作り、`languages` にコードを加えます。アラビア語、ペルシア語、ヘブライ語、ウルドゥー語などの RTL 言語のページには `dir="rtl"` が付きます（`ur-Latn` は左から右）。カタログか front matter の `direction: rtl` または `ltr` で上書きできます。ページ本文はカタログではなく Markdown で翻訳し、置き方は二通りです。原文の隣に置くなら、`guides/start.md` の隣に `guides/start.ko.md` を作り、front matter に `lang: ko` と `permalink: /ko/guides/start/` を書きます。Jekyll はこのファイル名からその URL を作れないためです。フォルダーに置くなら `ko/guides/start.md` を作り、`defaults` のスコープ(`path: ko`、`lang: ko`)を設定します。ホームページだけを翻訳する言語は `home/index.<lang>.md`(`permalink: /<lang>/`)に置けます。

`languages` にある言語のうち、サイトの `lang` 以外の言語にはすべて `/<lang>/` にホームページが必要です。言語メニュー(`language_switcher`)は、その言語の翻訳がないページから読者をそこへ送るので、ホームページがなければそうしたページのすべてでリンクが切れ、`modootoday-check --links` がそれを報告します。`index.md` の隣に `index.<lang>.md` を作り、front matter に `lang: <lang>` と `permalink: /<lang>/` を書いてください(フォルダーに置く場合は `<lang>/index.md`)。タイトルと、翻訳したページへのリンクが一行あれば足ります。

パスが異なる翻訳ページどうしは、front matter に同じ `ref:` を書きます。たとえば `guides/start.md` と `ko/guides/sijak.md` の両方に `ref: guide` を書きます。すると `hreflang` リンクと言語スイッチャーがそのページを使います。`ref:` があって翻訳がないページは `hreflang` から外れ、言語スイッチャーはその言語のホームへ案内します。include とレイアウトでは、`modootoday/link.html` に `ref="guide"` を渡すと、現在の言語の `ref: guide` ページの URL を、なければ既定言語のページの URL を返します(代替しない場合は `exact=true`、完全な URL は `absolute=true`)。どのページにもない `ref=` は `modootoday-check` がエラーにします。`full_languages` を設定すると、`modootoday-check . _site --i18n-pages` がその言語の翻訳(同じ `ref:`、ページの隣の `<name>.<lang>.md`、または `<lang>/` 以下の同じパス)がない既定言語のページを警告として表示します。`--strict` と併用すると失敗します。投稿、レコードページ、レコードの一覧、`/404.html` のようにファイルの URL にあるページは、ページごとに翻訳しないので対象外です。同じオプションは各翻訳の `source_rev:` も読みます。これは翻訳のもとになった原文のリビジョンです(原文の `title`、`description`、`nav_title` と本文から作る `sha256:` と 16 進数 12 桁)。この値がない翻訳や、その後に原文が変わった翻訳は警告になり、警告には現在の値が表示されます。原文の隣に置いた翻訳の `permalink` が、原文の URL の前に `/<lang>` を付けた値と違う場合はエラーです。

テーマではなくサイト側で決める文言もあります。`tabs.label` はタブを使うページでタブ一覧に付ける名前です(例: `tabs: {label: インストール方法}`)。スクリーンリーダーが何を切り替えるタブかを読み上げるので、言語ごとのカタログに入れてください。

独自の include では、`modootoday/t.html` に `key="nav.label"` を渡すと、同じ順序で解決された文言を出力できます。

## コンポーネントレジストリ

任意の `_data/components.yml` を置くと、チェッカーが `sections:` のパラメーターを検証します。

```yaml
features: {params: {cols: {allowed: [2, 3, 4], required: false}, badge: {allowed: [bottom], required: false}}}
tabs: {i18n: [tabs.label]}
cta: {}
```
