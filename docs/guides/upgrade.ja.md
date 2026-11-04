---
lang: ja
permalink: /ja/guides/upgrade/
source_rev: sha256:d4a5c9075459
nav_order: 60
nav_title: 移行
title: 移行とアップグレード
description: 別の Jekyll テーマからの移行、既存プロジェクトへの導入、バージョン間のアップグレード。
---
# 移行とアップグレード

> [!NOTE]
> このページは[英語の原文](../../../guides/upgrade/)の翻訳です。内容が異なる場合は英語版が優先されます。

## 別のテーマから

1. `theme:` または `remote_theme:` をこのテーマに置き換え ([インストール](../install/)を参照)、バージョンを固定します。
2. `_config.yml` で `layout: doc` を既定にするか、独自のレイアウトを残して必要な部分だけを include します。
3. ページ本文はそのままにします。GitHub アラート、表、フェンスコードはすでに動きます。できるところでは本文から生の HTML と Liquid を取り除きます。移植できないものは `modootoday-check` が一覧にします。
4. 色とフォントは CSS セレクターを上書きせず `modootoday.tokens` に移します。
5. `jekyll build` と `modootoday-check SRC _site` を実行し、報告された内容を直します。

よくある対応: minima の `layout: page` と just-the-docs の `layout: default` は `layout: doc` になります。`include note.html` タグで作ったコールアウトは `> [!NOTE]` に、HTML で書いたバッジは `` `status:available` `` のコードスパンになります。

## 既存プロジェクトへの導入

| 方法 | 使う場面 | 更新 |
|---|---|---|
| Gem (`theme:`) | サイトに `Gemfile` がある (Jekyll 4 または `github-pages` gem) | `bundle update jekyll-theme-modootoday` |
| `remote_theme:` | `Gemfile` のないクラシックな GitHub Pages | `@vX.Y.Z` タグを変える |
| コピーして取り込む | レイアウトをフォークする必要がある、または依存を追加できない | タグ付きリリースから `_layouts`、`_includes`、`_sass`、`assets` をコピーしてバージョンを記録する。更新は手作業でマージする |

gem か、タグに固定した `remote_theme:` を推奨します。コピーで取り込むと、変更したファイルについてはアップグレードとチェッカーの保証を失います。

## Markdown 版

各ページのエージェント向け Markdown 版を公開する方法を三つから選びます。

- **スタブファイル** (既定、クラシックな GitHub Pages): ページごとに小さな `<page>.md.txt` を一つ。
- **プラグイン** (Jekyll 4 または GitHub Actions): `plugins: [jekyll-theme-modootoday]` がスタブなしで Markdown 版と `llms.txt` を作ります。
- **ソースモード** (クラシックな GitHub Pages、スタブなし): front matter のないページで `modootoday.twins: source` を使います。クラシックな GitHub Pages は生のコピーをソースと同一のまま `text/markdown; charset=utf-8` として配信します (制限は RULES.md §5a を参照)。

切り替えてもページ本文は変わりません。[エージェント](../agents/)と `RULES.md` の 5a 節を参照してください。

## jekyll-seo-tag から移る

`jekyll-seo-tag` の代わりにキットに SEO タグを書かせるには、次のようにします。

1. `plugins:` と `Gemfile` から `jekyll-seo-tag` を削除し、`_includes/head-custom.html` から `seo` タグを削除します。
2. `modootoday:` から `seo: false` と `hreflang: true` を削除します。キットが canonical リンク、`hreflang` の alternate リンク、Open Graph を再び書きます。手で追加した alternate リンクは削除し、同じリンクが二重に出ないようにします。
3. ブラウザーのバーの色は `modootoday.theme_color` で指定します（[設定](../configuration/)を参照）。キットは既定でライト用とダーク用の `theme-color` タグを 2 つ書きます。独自の `theme-color` タグがあれば削除します。残すと 1 ページに 3 つになります。
4. キットが書くのは `twitter:card` だけです（ページに画像があれば `summary_large_image`）。`twitter:` の設定は読まないため、`twitter:site` が必要なら `_includes/head-custom.html` に meta タグで追加します。
5. 再ビルドして `modootoday-check SRC _site` を実行します。jekyll-seo-tag の JSON-LD に関する警告が消えているはずです。

## アップグレード

飛ばすすべてのバージョンについて `CHANGELOG.md` を読んでください。文書化された名前は[公開 API](../../reference/api/)にあります。アップグレード後に `modootoday-check --strict` を実行してください。

| 移行元 | 移行先 | やること |
|---|---|---|
| 1.0.0 より前のリポジトリからのビルド | 1.0 | `~> 1.0` または `@v1.0.0` に固定し、`modootoday-check --strict` を実行する |
| 1.0 または 1.1 | 1.2 | `~> 1.2`（`remote_theme` では最新の `v1.2.x` タグ）に固定する。新しいセクションとヒーローのオプション（`bleed:`、`reveal:`、`visual:` と組み合わせる `c: split`）は任意なので、ページの修正は不要。`modootoday-check --strict` を実行する |
| 1.2 | 1.3 | `~> 1.3`（`remote_theme` では `@v1.3.0`）に固定する。`reference` のサイドバー（`sidebar: true`）とパッケージ表（`packages:`）は任意なので、ページの修正は不要。`modootoday-check --strict` を実行する |
| 1.3 | 1.4 | `~> 1.4`（`remote_theme` では `@v1.4.1`）に固定する。`packages_compact` と `packages_position` は任意で、`reference` ページも `doc` と同じくアラートを変換するようになったため、ページの修正は不要。`modootoday-check --strict` を実行する |
| 1.4 | 1.5 | `~> 1.5`（`remote_theme` では `@v1.5.0`）に固定する。既定の見た目が変わるが（下記参照）、ページの修正は不要。`modootoday-check --strict` を実行する |

`##` 見出しより少ない `sections:` 項目を許していた 1.0 以前の草案を使っていたなら、残りの見出しごとに `notes` のような名前だけを足してください。今は数が一致する必要があり、`modootoday-check` がページと両方の数を報告します。

`name:` を書いた `resume` や `links` のページは、人の名前ではなくファイル名（`resume.md`）を表示していました。Jekyll がページの `name:` をファイル名に置き換えるためです。キーを `display_name:` に変えてください。変えるまではページのタイトルが表示され、`modootoday-check` が警告します。

### 1.5 の見た目

1.5 は既定のスタイルをフラットでニュートラルにします。ニュートラルなグレーの段階、不透明な 4rem のヘッダー、メニューと検索結果以外は影なし、枠線だけのアラート、浮き上がらないボタンとカード、ウェイト 600 の見出し、行の高さ 1.75 の本文です。見出しは小さくなり行が均等に分かれ（すべての幅で h1 2rem、h2 1.5rem、h3 1.25rem）、韓国語・日本語・中国語のページは言語ごとのフォントを使い、日本語はブラウザーが対応していれば文節で改行します。トークン名はそのままで、値だけが変わります。`modootoday.theme_color` のダークモードの既定値も新しいページ背景の `#0a0a0a` になります。1.4 の色、サイズ、影を残すには、トークンブリッジに以前の値を書いてください。

```scss
// _sass/modootoday/_site.scss
$mt-overrides-base: (heading-weight: 650, line-height: 1.7, measure: 46rem, container: 76rem, header-height: 3.75rem,
  space-section: 3rem);
$mt-overrides: (
  foreground: #1f2328, card-foreground: #1f2328, accent-foreground: #1f2328, muted: #f6f8fa, accent: #eff2f5,
  muted-foreground: #59636e, status-planned: #59636e, code-comment: #59636e, border: #d1d9e0,
  shadow-sm: 0 1px 2px rgba(31, 35, 40, 0.06), shadow: 0 6px 20px -6px rgba(31, 35, 40, 0.16)
);
$mt-overrides-dark: (
  background: #0d1117, primary-foreground: #0d1117, foreground: #e6edf3, card-foreground: #e6edf3,
  accent-foreground: #e6edf3, muted: #1a212b, card: #1a212b, accent: #151b23, muted-foreground: #9198a1,
  status-planned: #9198a1, code-comment: #9198a1, border: #3d444d,
  shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.3), shadow: 0 8px 24px -6px rgba(0, 0, 0, 0.5)
);
```

`modootoday.theme_color: {light: "#ffffff", dark: "#0d1117"}` もあわせて設定してください。ヘッダーのぼかし、アラートの帯と背景色、ボタンの浮き上がりはなくなり、自分の `site_css` でのみ戻せます。

ヘッダーはどの幅でも高さ 4rem の 1 行のままです。64rem より狭いとリンクはメニューボタン（`.mt-nav-sheet`）の中に移り、グループのリンクを行内に並べ直していた `.mt-nav-flat` はなくなりました。`.mt-nav-flat` に書いたルールは `.mt-nav-sheet` を対象にしてください。見出しには `scroll-margin-top` がなくなり、アンカーへ移動するとページの `scroll-padding-top` によってヘッダーの下に収まります。

コールアウト、引用、図も同じフラットなスタイルになります。コールアウトは内側の余白 1rem の細い枠で、種類の色は 16px のアイコンと見出しだけに付きます。本文の引用は開始側に 2px の線が付き(以前は 3px)、`c: quote` セクションは背景を塗ったカードではなく、同じ線の付いた大きめの引用になります。図、SVG の図の枠、埋め込みの角は 8px(`radius`、以前は `radius-lg`)、キャプションは 14/20 で、`.mt-illustration-tag` バッジは絵に重ならず絵の上に置かれます。コールアウト、図、埋め込みのルールはコアシートを離れて `content/inline.css` に移り、そのどれかがあるページだけがこのシートを読み込みます。部分ファイルは `components/core/inline/` のパスのままなので、サイトで上書きしたファイルも引き続き効きます。`modootoday.css: bundle` ではコアシートにそのまま含まれます。
