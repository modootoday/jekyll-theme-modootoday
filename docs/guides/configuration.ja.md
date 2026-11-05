---
lang: ja
permalink: /ja/guides/configuration/
source_rev: sha256:f0d63529ea10
nav_order: 30
title: 設定
description: _config.yml の modootoday キーで指定するサイト全体の設定。
sections:
  - keys
  - new-window
  - showcase
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
| `tokens`, `tokens_dark` | テーマの値 | テーマの色などのデザイントークンを変える。厳格な CSP のサイトでは[トークンブリッジ](../customize/#トークンブリッジ)を使う。 |
| `site_css` | なし | `[/assets/css/site.css]` のような独自のスタイルシートを、テーマのシートの後に読み込む。[ブランドトークン](../../recipes/brand-tokens/)を参照。 |
| `preload` | なし | フォントなど、ブラウザーに先に取得させるファイル。`{href, as, type}` のリストで書く。 |
| `scripts` | なし | 独自の JavaScript モジュール。`script:` で名前を指定したページか、その `element`（ウィジェット）があるページだけが読み込む。[モジュールスクリプトとポスター](../customize/#モジュールスクリプトとポスター)と[ウィジェット](../../recipes/widgets/)を参照。 |
| `search` | なし | ヘッダー検索の設定。索引する本文の量と、検索語の照合方法を決める。[検索](../../recipes/search/)を参照。 |
| `twins` | スタブ | 各ページの Markdown 版の出し方。`source` は front matter のないページを使う。[エージェント](../agents/)を参照。 |
| `aliases` | なし | エージェント向けの追加 URL。`md: true` は `/<page>.md` を加え、`html: true` は `/<page>.html` をリダイレクトする。[URL エイリアス](../agents/#url-エイリアス)を参照。 |
| `records` | なし | `_data` ファイルの項目ごとにページを 1 つ作る。[生成ページ](../../recipes/generated-pages/)を参照。 |
| `seo` | `true` | `false` で組み込みの canonical、`hreflang`、Open Graph タグを出さない。 |
| `hreflang` | `seo` に従う | `true` なら `seo: false` でも `hreflang` リンクを残す。`jekyll-seo-tag` を使うサイト向け。 |
| `schema` | `url` があれば有効 | schema.org の構造化データを出す。`false` で無効。[構造化データ](../structured-data/)を参照。 |
| `languages` | なし | `[en, ko]` のようなサイトの言語コード。`hreflang` と言語メニューに使う。 |
| `full_languages` | なし | すべてのページを翻訳する言語(例: `[ko, ja]`)。`modootoday-check --i18n-pages` が足りない翻訳を警告する。 |
| `lists` | なし | `{link_chips: true, titled_items: true}` で、リンクだけのリストをチップに、`**タイトル**:` の項目を見出し付きの項目にする。 |
| `language_switcher` | なし | 言語メニューを `header`(地球儀ボタン)か `footer`(言語名の一覧)に表示する。 |
| `og_image` | なし | リンクプレビューの既定の画像。ページの `image:` が優先。 |
| `feed` | `false` | `true` で `/feed.xml` にリンクする。`plugins` に `jekyll-feed` を追加する。 |
| `logo` | なし | `brand` でサイト名の前にテーマのマークを、パスを指定するとその画像を表示する。 |
| `favicon` | なし | `brand` でテーマのマークを、パスを指定するとそのアイコンをサイトのアイコンにする。 |
| `header` | `{compact_title: true}` | `compact_title: false` でスマートフォンでもロゴの横にサイト名を表示する。 |
| `csp` | なし | `strict` で、最初の描画前に動くテーマのスクリプトをインラインではなくファイルから読み込む。 |
| `asset_version` | `theme` | テーマのファイル URL の `?v=` に付ける値。`theme` はバージョン、`build` はコミットまで、`false` は何も付けない。[パフォーマンス](../performance/#バージョン付きアセット-url)を参照。 |
| `viewport_fit` | `cover` | `auto` でスマートフォンのノッチを避けてページを描く。[アクセシビリティ](../accessibility/#設定)を参照。 |
| `theme_color` | ページ背景 | ブラウザーのバーの色。`"#hex"` 1 つ、`{light: "#hex", dark: "#hex"}`、または出さないなら `false`。 |
| `edit_url` | なし | 「このページを編集」リンクの URL の先頭部分。末尾は `/`。 |
| `archive` | なし | `{tags: /tags/, categories: /categories/}` のようなタグ・カテゴリーページの URL。記事フッターのリンク先になる。[記事とアーカイブ](../../reference/api/#記事とアーカイブ)を参照。 |
| `mermaid` | 無効 | ```` ```mermaid ```` ブロックを図として描く。[数式と図](../../recipes/math-diagrams/#組み込みローダー)を参照。 |
| `diagrams` | `{dir: /assets/diagrams/, dark: true, source: details}` | [静的な Mermaid の図](../../recipes/math-diagrams/#静的な-mermaid-の図)の SVG を置く場所、ダークモード用の SVG があるかどうか、Mermaid のソースをページに残すかどうかを決める。 |
| `math` | 無効 | ```` ```math ```` と `$$` のブロックを ブラウザーの KaTeX で描画する。`mode: static` なら `_data/math` にコミットした MathML を表示する。[数式と図](../../recipes/math-diagrams/#静的な数式)を参照。 |
| `external_links` | なし | `new_window: true` で、ほかのサイトへのリンクを新しいウィンドウで開く。[新しいウィンドウで開くリンク](#新しいウィンドウで開くリンク)を参照。 |
| `blog` | なし | `per_page` などのブログ設定。[ブログとニュース](../../layouts/blog-news/#設定)を参照。 |
| `news` | なし | トップページの `sections:` などのニュース設定。[ブログとニュース](../../layouts/blog-news/#設定)を参照。 |
| `css` | `split` | `split` はページが使う CSS だけを、`bundle` はすべてを含むシート 1 つを読み込む。 |
| `banner` | なし | `{text: "…", url: /path/, link: "詳しく"}` で、すべてのページにお知らせバーを表示する。 |
| `back_to_top` | `false` | `true` ですべてのページの末尾に「先頭へ戻る」リンクを追加する。 |
| `loading` | `false` | `true` で、独自スクリプトのためにスピナーとスケルトンのスタイルを全ページで読み込む。 |
| `showcase` | 無効 | `{enabled: true, style: bar, starter:, docs_url:, use_url:}`: スターターのデモのビルドに、テーマのドキュメントへ戻るバー(`style: pill` なら浮かぶピル)を表示する。デモ専用の設定ファイルに書く。[スターターのデモのショーケース](#スターターのデモのショーケース)を参照。 |
| `chart` | 無効 | `{enabled: true, src:, integrity:}`: 表の直前に `chart:<type>` だけの行を置くと、その表がグラフの figure になり、サイトの Chart.js(`src`)が描画する。[グラフ](../../recipes/charts/)を参照。 |
| `subscribe` | なし | `{action: https://…}`: `c: subscribe` のメールフォームが登録を送る先。 |

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

## スターターのデモのショーケース

スターターのライブデモには、テーマとスターターの名前を示し、テーマのドキュメントへ戻るリンクを載せたバーを表示できます。このバーはデモのビルド専用です。デモのデプロイだけが `_config.yml` に重ねる 2 つ目の設定ファイルに書けば、スターターから作ったサイトには表示されません。GitHub Pages のビルダーは `_config.yml` しか読まないため、このビルダーを使うワークフローではビルドの前にデモのファイルを `_config.yml` に統合します。テーマのスターターは `if: github.repository == '<owner>/<repo>'` の条件が付いたワークフローのステップでこれを行うため、フォークやテンプレートから作ったリポジトリはショーケースなしでビルドされます。

```yaml
# _config.demo.yml: jekyll build --config _config.yml,_config.demo.yml
modootoday:
  showcase:
    enabled: true
    style: bar            # bar (default) or pill
    starter: blog         # names the starter in the label
    docs_url: https://modootoday.github.io/jekyll-theme-modootoday/
    use_url: https://github.com/<owner>/<repo>/generate   # optional
```

- **バー**(`style: bar`、既定): ヘッダーの上に 44 px のバーを置き、テーマ名、スターター名、ドキュメントへのリンク、このスターターで始めるリンク(`use_url` があるとき)、非表示にするボタンを並べます。固定ヘッダーとアンカー先のオフセットはバーの高さだけ下がります。40rem(640 px)より狭い画面では、テーマ名、ドキュメントへのリンク、ボタンだけが残ります。スマートフォンを横に持ったときや 200% に拡大したときなど、ウィンドウの高さが 30rem(480 px)未満になると、バーはページと一緒にスクロールします。
- **ピル**(`style: pill`): 画面下の中央に浮かぶピルに、テーマ名、スターター名、ドキュメントへのリンク、ボタンを並べます。ページの下に余白を取るため、ピルが最後の行、トップへ戻るリンク、セーフエリアを隠すことはありません。
- **色**はページの配色を反転したものです。明るいページには暗いバー、暗いページには明るいバーを表示します。`brand` トークンはマークにだけ使います。
- **リンク**は設定からだけ読み込みます。新しいウィンドウで開き、矢印を表示し、名前でもそのことを伝えます。
- **フォーカスの順序**: ショーケースは「テーマのショーケース」という名前の領域で、そのリンクは「本文へスキップ」のすぐ後に来ます。
- **非表示**はそのタブでの訪問が終わるまで続きます(`sessionStorage`)。`<head>` の小さなスクリプトがページを描く前にこの値を読むため、次のページにはバーもその余白もなく、表示がずれることもありません。JavaScript がないときやストレージが使えないときは、ショーケースはそのまま残ります。
- **検索エンジン**: ショーケースを有効にすると、すべてのページに `<meta name="robots" content="noindex">` が付きます。デモのサンプルの文章は、スターターから作ったどのサイトも最初に持つ文章だからです。サイトマップにはページが残りますが noindex が優先され、デモのビルドの Lighthouse SEO 監査はページがインデックスから除外されていると報告します。
- **ラベル**はページの言語に従います。`starter` は `showcase.starters.<name>` のラベルを選び、テーマには `docs`、`blog`、`landing` があります。ほかのスターターでは `_data/i18n/<lang>.yml` にそのキーを追加してください。ない場合、ラベルにはテーマ名だけが表示されます。
- `modootoday-check` は `_config.yml` と `_config.demo.yml` のキーを検査し、`_config.yml` 自体で有効にすると警告し、ショーケースが表示されるビルドでは noindex のタグがないページも警告します。`_config.demo.yml` があっても、それなしでビルドしたサイトには警告しません。

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
