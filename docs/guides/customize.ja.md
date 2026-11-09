---
lang: ja
permalink: /ja/guides/customize/
source_rev: sha256:221af770fbea
nav_order: 50
title: カスタマイズ
description: トークンとトークンブリッジで色、角丸、フォントを変え、独自のスタイルシートを足すか、Sass パーシャルを上書きします。
sections:
  - tokens
  - bridge
  - code
  - visuals
  - sass
  - shadow
---
# カスタマイズ

まずはトークンから。トークンで足りないときだけ Sass パーシャルを使います。

> [!NOTE]
> このページは[英語の原文](../../../guides/customize/)の翻訳です。内容が異なる場合は英語版が優先されます。

## デザイントークン

テーマは CSS カスタムプロパティを公開しています。自分のスタイルシートか `modootoday.tokens` で上書きします。

```css
:root {
  --mt-primary: #0f766e;
  --mt-radius: 0.75rem;
}
```

自分のスタイルシートで上書きするには、テーマのダークスキームのセレクター（`:root[data-theme]` と `prefers-color-scheme` のルール）に勝つ必要があります。サポートしている方法は三つです。

- [トークンブリッジ](#トークンブリッジ)に値を置きます（推奨）。テーマ自身のトークンのルールにコンパイルされ、インラインになるものはありません。
- 値を `modootoday.tokens` と `modootoday.tokens_dark` に書きます。テーマ自身のトークンと同じセレクターでインラインの `<style>` に出力されるため、厳格な CSP ではブロックされます。
- `modootoday.css_layers: true` にします。テーマの CSS が `@layer mt.*` に入り、レイヤー外のルールが勝つので、普通の `:root { … }` で足ります。

ダークモードの画像：写真は `--mt-img-filter-dark` を、`.svg` の図は色相を保って反転してから `--mt-img-filter-dark` を適用する `--mt-diagram-filter-dark` を使います。どちらもトークンで変更できます。たとえば `--mt-diagram-filter-dark: none` にすると、すべての図が描いたままになります。一つの画像のパスの末尾に `#light` を付けると（`flow.svg#light`）、その画像だけが描いたままになります。[数式と図](../../recipes/figures/math-diagrams/#画像の図)を参照してください。

### レイアウトのフック

一部のサイズと主要なボタンの色はフックです。テーマはこれを `var(--mt-<name>, <既定値>)` として読むだけで自分では設定しないため、自分のスタイルシート（たとえば `site_css` で読み込むファイル）の普通のルールで、テーマのセレクターより優先させる工夫なしに変更できます。

| フック | 既定値 | 決めるもの |
|---|---|---|
| `--mt-sidebar-width` | `18rem` | 64rem から表示されるドキュメントのサイドバーの列 |
| `--mt-toc-width` | `15rem` | 「このページの内容」の列 |
| `--mt-doc-gap` | `2rem` | ドキュメントの列の間隔 |
| `--mt-doc-container` | `90rem` | ドキュメントのサイドバーがあるページのヘッダー、本文、フッターの幅 |
| `--mt-code-radius` | `var(--mt-radius)` | コードブロックとタイトルの行の角 |
| `--mt-button-primary-bg` | `var(--mt-foreground)` | 主要な操作(ヒーローや `c: cta` のボタンの行の最初のリンク)の塗りと枠線 |
| `--mt-button-primary-fg` | `var(--mt-background)` | 主要な操作の文字 |
| `--mt-hero-title-size` | `clamp(2.5rem, 1.5rem + 3vw, 3.5rem)` | ヒーローの見出しとマーケティングページの見出しの大きさ |

```css
:root { --mt-sidebar-width: 16rem; }
```

既定値は `_sass/modootoday/registry/_hooks.scss` にあります。

## トークンブリッジ

サイトに `_sass/modootoday/_site.scss` を作り、最大三つのマップを設定します。テーマはこのファイルを設定より先に読み込むので、コアシートとすべての任意シートが、ライトとダークの両モードでこの値を使います。

```scss
// _sass/modootoday/_site.scss
$mt-overrides-base: (font-sans: (Inter, system-ui, sans-serif), font-heading: (Fraunces, Georgia, serif));
$mt-overrides: (primary: #0f766e, link: #0f766e);
$mt-overrides-dark: (primary: #2dd4bf, link: #5eead4);
```

| マップ | トークン | 出力先 |
|---|---|---|
| `$mt-overrides-base` | `font-sans`、`font-mono`、`font-heading`、`heading-weight`、`font-size`、`line-height`、`measure`、`narrow`、`radius` などカラースキームに依存しないトークン | `:root` |
| `$mt-overrides` | `primary`、`link`、`link-hover`、`background`、`foreground`、`border` などの色トークン | `:root` (ライト) |
| `$mt-overrides-dark` | ダークモードの同じ色トークン | ダークスキームのセレクター |

色は両方のマップに指定してください。ダークのセレクターはすべての色トークンを出力し直すため、`$mt-overrides` にだけ置いた値はダークモードに反映されません。既存のトークンに加えて、`h1`〜`h4` 用の `font-heading` と `heading-weight`、本文のリンク用の `link` と `link-hover` があります。既定値はそれぞれ `font-sans`、600、`primary` に従うため、`primary` だけを変えたサイトでは何も変わりません。このファイルに書けるのはこの三つのマップだけで、トークン名はテーマが定義したものに限られます。それ以外があると `modootoday-check` が失敗するので、タイプミスが見過ごされることはありません。

サイトが `lang` または `modootoday.languages` で宣言した韓国語、日本語、中国語のページには、言語ごとに専用の `font-sans` が付きます。その文字のシステムフォントで、韓国語はサイトが Pretendard を読み込んでいればそれを優先します（テーマは Pretendard を同梱しません）。英語だけのサイトには何も出力されません。ブリッジまたは `modootoday.tokens` で `font-sans` を指定するとこれらは無効になり、指定したフォントがすべての言語に使われます。

二つの設定で、サイトのファイルをテーマのファイルと並べて読み込みます。

```yaml
modootoday:
  site_css: [/assets/css/site.css]   # テーマのシートの後に読み込む。front matter の site_css: はそのページだけに追加
  preload:                           # スタイルシートより前の <link rel="preload">。front matter の preload: はページ単位
    - {href: /assets/fonts/inter.woff2, as: font, type: font/woff2}
```

配色、セルフホストのフォント、コントラストの確認までそろった例は[ブランドトークン](../../recipes/brand-tokens/)にあります。

## コードの色

コードブロックは `--mt-code-*` トークンから色を取ります。`modootoday.code_theme: github` を設定すると、GitHub のライトとダークのパレットに切り替わります（[デモ](../../layouts/demo/code-github/)）。

```yaml
modootoday:
  code_theme: github   # theme (default) or github
```

色は GitHub のエディターテーマ（github-light-default と github-dark-default）から取っています。Rouge はエディターとは違う基準でトークンを分けるため、パレットは GitHub と同じでも、単語ひとつの色が異なることがあります。トークンは `code-background`、`code-foreground`、`code-keyword`、`code-string`、`code-comment`、`code-function`、`code-constant`、`code-variable`、`code-type`、`code-number`、`code-operator`、`code-tag`、`code-attribute`、`code-inserted`、`code-deleted` です。既定の `theme` では、新しい十個が従来の五個に従うので、コードの見た目は変わりません。トークンブリッジはプリセットの後に適用されるので、`$mt-overrides: (code-comment: #57606a)` のように一色だけ変えられます。コードの色には Jekyll の既定である Rouge（`kramdown.syntax_highlighter`）が必要で、別のハイライターを設定すると `modootoday-check` が警告します。

## セクションのビジュアルと全幅ページ

`sections:` の項目に `visual: <name>` を書くと、そのセクションの末尾にサイトの `_includes/sections/<name>.html` が描画されます。 include は項目を `include.section` として受け取るので、`scene:` のような追加キーも渡ります。front matter の `hero: {visual: <name>}` は最初の `##` より前の部分に同じことをします（`sections:` が必要です）。 include がないと `modootoday-check` が失敗します。

```yaml
---
full_width: true
hero: {visual: player-mock}
sections: [{c: features, name: why, visual: chart, scene: night}, faq]
---
```

テーマにはヒーロー用ビジュアル `showcase` が 1 つ付属しています。やわらかな背景画像、トークンによるオーバーレイ、SVG で描いた UI シーンのアニメーションを重ねて表示します。スタイルシートはこのビジュアルを使うページにだけ読み込まれ、JavaScript を使わず 5 秒以内に動きが止まります。視差効果を減らす設定では最後の場面だけを表示します。ダークモードでは同じ画像を CSS filter で暗くし、`--mt-img-filter-dark` で調整できます。独自の画像を使うには `hero.image` にパスか `{path, srcset, width, height}` を指定してください。ホームレイアウトのヒーローと同じ `hero.image` キーです。[ホーム](../../)で実際の表示を確認できます。

```yaml
hero: {visual: showcase}
# または: hero: {visual: showcase, image: {path: /assets/hero.webp, srcset: "/assets/hero-800.webp 800w, /assets/hero.webp 1600w", width: 1600, height: 900}}
```

### モジュールスクリプトとポスター

canvas や動く SVG のように JavaScript が必要なビジュアルは、ES モジュールを `modootoday.scripts` に一度登録し、ヒーローかセクションの項目で `script:` に名前を指定します。名前を指定したページだけがモジュールを読み込みます。テーマは項目の `css` シート、`preload` のパスごとの `<link rel="modulepreload">`、`<script type="module">` を `<head>` にページごとに一度ずつ追加します。パスはすべてサイトパスです。モジュールスクリプトは遅延実行され、`script-src 'self'` で許可されるので、厳格な CSP を変える必要はありません。`preload` には、モジュールが読み込むモジュールがさらに読み込むモジュール（2 段下）だけを書いてください。直接読み込むモジュールにはヒントは要りません。

```yaml
# _config.yml
modootoday:
  scripts:
    orbit: {src: /assets/js/hero/orbit.js, css: /assets/css/orbit.css, preload: [/assets/js/hero/scene.js]}
```

```yaml
hero: {c: split, visual: orbit-stage, script: orbit, poster: {path: /assets/hero/orbit-960.webp, srcset: "/assets/hero/orbit-640.webp 640w, /assets/hero/orbit-960.webp 960w", width: 960, height: 960}}
```

`poster:` は `hero.image` と同じ形です。パスか `{path, srcset, sizes, width, height}` を書きます。画像が届く前に場所を確保するため、`width` と `height` は必須です。テーマはポスターをビジュアルの列の先頭に `img.mt-visual-poster` として出力します。ヒーローでは高い優先度で取得されるので、たいていページの Largest Contentful Paint (LCP) になります。セクションでは遅延読み込みされます。分割の項目に `script:` か `poster:` があれば `visual:` は不要です。分割でなければ、ポスターと include は `div.mt-visual` に入ります。ビジュアルの列には `data-mt-script="<name>"` が付きます。

モジュールが守る契約:

- `prefers-reduced-motion: reduce` のときは何もしません。ポスターが残ります。JavaScript がオフのときやモジュールが失敗したときもポスターが残ります。
- ポスターの後ろにある `mt-visual-stage` クラスの要素に描きます。この要素は `visual:` の include から出力でき、ポスターの領域を覆います。
- 最初の場面を描いたら `[data-mt-script]` の列に `data-mt-ready` を付けます。するとテーマがポスターを隠します。
- 設定は `readConfig`（`/assets/js/modootoday/dom/config.js`）で `data-*` 属性から読み、ライトとダークの切り替えには `onThemeChange`（`/assets/js/modootoday/theme/current.js`、[イベント](../../reference/api/#イベント)を参照）で追従します。`../modootoday/dom/config.js` のように相対パスで読み込んでください。

[ヒーローモジュールのデモ](../../layouts/demo/orbit/)は、この契約に従う 40 行のモジュールです。

`element: <name>` を付けた項目は、ビジュアルを描く代わりに custom element を定義します。その要素があるページは `script:` なしでモジュールを読み込みます。[ウィジェット](../../recipes/figures/widgets/)は、そうした要素を Markdown から代替テキスト付きで置きます。

`full_width: true` はランディングページ向けに、`main.mt-main` の本文幅の制限と左右の余白を外します（`.mt-main-full` を追加）。

## Sass パーシャル

独自のルールはサイトのスタイルシートに書き、`site_css` に登録します。テーマのシートの後に読み込まれるので、同じセレクターならこちらが勝ちます。

```scss
---
---
.mt-hero h1 { letter-spacing: -0.02em; }
```

Jekyll はテーマより先にサイトの `_sass/` を読みます。`assets/css/modootoday.scss` をすでに上書きしているサイトもそのまま動き、トークンフックも適用されます。テーマはフックをコアのパーシャルから読み込むためです。コアシートにはトークン、基本ルール、シェルだけが入り、コンポーネントはそれぞれのシートで読み込みます。テーマの古いバージョンから作ったコピーはすべてのコンポーネントをコアシートに入れたままのことがあるので、使っているバージョンからコピーし直すか、コピーを削除してトークンで設定してください。

> [!WARNING]
> `@use` ではなく `@import` を使ってください。GitHub Pages は Ruby Sass で Sass をコンパイルし、`@use` をそのまま出力します。

## レイアウトと include の上書き

テーマの `_layouts/`、`_includes/`、`assets/` にあるファイルは、サイトの同じパスにファイルを置けば置き換えられます。`_sass/` でそうなるのは、テーマが Sass のロードパスから読み込むパーシャルだけです。トークンフック `_sass/modootoday/_site.scss`、`_sass/modootoday/_access.scss`、`_sass/modootoday/components/` 以下のコンポーネントのパーシャルが該当します（FAQ のシートはそれでもテーマの `_details.scss` を読みます）。ほかのパーシャル（設定、ツール、トークン、基本スタイル、レイアウト、レイアウトごとのシート）は、それを使うテーマのファイルからの相対パスで読み込まれるため、GitHub Pages でも Jekyll 4 でも Sass はテーマのファイルを読み、サイトのファイルは無視されます。`_core.scss`、`_sheet.scss`、レイアウトごとの `_index.scss` をコピーすると、相対パスで読み込むファイルが隣にないためビルドが失敗します。コンポーネントのパーシャルは内部 API なので、上書きするとテーマの更新で壊れることがあります。それ以外を変えるには、`site_css` でルールを足すか、`assets/css/` 以下のスタイルシートを上書きしてください。

ページの head にタグを足すには `_includes/head-custom.html` を使います。

```html
<link rel="icon" href="/favicon.svg">
```

> [!CAUTION]
> 上書きしたファイルにはテーマの更新が反映されません。トークンと `head-custom.html` を優先してください。

class のないリストには、項目の間に小さな間隔が入ります。レイアウトや include で class のない Markdown リストを grid や flex の行にする場合は（例: `.c-body > ul`）、`<div class="c-body mt-flat-list">` のように祖先要素に `mt-flat-list` を付けます。こうすると最初の項目が他の項目とそろいます。独自の class があるリストには間隔が入りません。

### フッター

テーマは `_data/nav/footer.yml`(言語ごとには `footer-ko.yml` のような `footer-<lang>.yml`)から、リンクの列と著作権の行があるフッターを描きます。このファイルがなければ、これまでどおりフッターはありません。

```yaml
# _data/nav/footer.yml
columns:
  - title: ドキュメント
    items:
      - {title: 導入, url: /guides/install/}
      - {title: 変更履歴, url: /changelog/}
  - title: プロジェクト
    items:
      - {title: GitHub, url: "https://github.com/you/site"}
copyright: © 2026 You
```

各列はタイトルで名前を付けたリストで、それ自体はランドマークではないため、Docs のようなタイトルがサイドバーの名前と重なっても問題ありません。列は収まるだけ 10rem の列に並びます。スタイルは `footer` コンポーネントで、列があるページだけがそのシートを読み込みます。`modootoday.language_switcher: footer` なら言語の切り替えが列の後に続きます。自作の `_includes/footer-custom.html` はこれまでどおりフッター全体を置き換えます。列を残すには、その中で `modootoday/chrome/footer.html` を include してください。
