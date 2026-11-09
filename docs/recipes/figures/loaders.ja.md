---
lang: ja
permalink: /ja/recipes/figures/loaders/
source_rev: sha256:ec9db6ff49cf
nav_order: 20
title: 図と数式のローダー
description: 組み込みのローダーや独自のローダーで Mermaid の図と KaTeX の数式をブラウザーで描画する方法と、それぞれが CSP とプライバシーに求めることを説明します。
---
# 図と数式のローダー

これらの方法は、読み手のブラウザーで図と数式を描きます。スクリプトの要らない静的な図との比較は[数式と図](../math-diagrams/)にあります。

> [!NOTE]
> このページは[英語の原文](../../../../recipes/figures/loaders/)の翻訳です。内容が異なる場合は英語版が優先されます。

## 組み込みローダー

どちらも既定では無効です。`_config.yml` で有効にし、**正確なバージョン**を含むレンダラーの URL とその[サブリソース完全性](https://developer.mozilla.org/ja/docs/Web/Security/Subresource_Integrity)（SRI）ハッシュ、またはサイトに置いたコピーのパスを指定します。

```yaml
modootoday:
  mermaid:
    enabled: true
    src: https://cdn.jsdelivr.net/npm/mermaid@11.4.1/dist/mermaid.min.js
    integrity: sha384-…   # そのファイルの正確なハッシュ
    theme: auto           # auto（ページのライト・ダークに従う）、default、dark、neutral、forest
  math:
    enabled: true
    engine: katex
    src: https://cdn.jsdelivr.net/npm/katex@0.19.0/dist/katex.min.js
    css: https://cdn.jsdelivr.net/npm/katex@0.19.0/dist/katex.min.css
    integrity: {js: sha384-…, css: sha384-…}
    auto_render_src: https://cdn.jsdelivr.net/npm/katex@0.19.0/dist/contrib/auto-render.min.js
    auto_render_integrity: sha384-…
    inline: false
```

- **必要なページだけ。** ブロックのあるページだけでタグを読み込みます。Mermaid は `language-mermaid`、数式は ```` ```math ```` フェンスか `$$` ブロックが対象です。一つのページだけ除くには、front matter に `mermaid: false` か `math: false` を書きます。
- **ハッシュがなければ読み込みません。** `integrity` のない CDN の URL（または https 以外の URL）は何も読み込まず、`modootoday-check` がエラーを報告します。チェッカーは URL に正確なバージョン（`@11` や `@latest` ではなく `@11.4.1`）も求め、ビルドしたページにあるほかの第三者のスクリプトやスタイルシートも報告します。
- **自分でホストできます。** `/assets/vendor/mermaid.min.js` のようなパスはサイトから読み込みます（`relative_url` を適用、`integrity` は任意）。KaTeX は `katex` パッケージから `katex.min.js`、`katex.min.css`、`fonts/` フォルダー、`contrib/auto-render.min.js` を一つのフォルダーにコピーすれば、`base: /assets/vendor/katex/` だけで `src`、`css`、`auto_render_src` を表せます。自分で書いたキーが優先です。
- **JavaScript なしでも読めます。** レンダラーが置き換えるまでソースはコードブロックとして残り、図や数式を解釈できない場合もそのまま残ります。
- **ライトとダーク。** `theme: auto` では、ページがダーク（テーマの切り替えか訪問者のシステム設定）のとき Mermaid の `dark` テーマを使い、変わると描き直します。視差効果を減らす設定では図のアニメーションを止めます。本文より広い図は、キーボードでフォーカスできる専用の領域の中でスクロールします。
- 各ローダーは小さな別のスクリプト（`assets/js/modootoday-mermaid.js`、`assets/js/modootoday-math.js`）で、コアのスクリプトとは別にサイズ予算があります。

### 数式の書き方

```` ```math ```` フェンスか、行を独占する `$$` ブロックを使います。どちらも標準の書き方で、github.com でも描画されます。`$$` ブロックには `auto_render_src` が必要で、ない場合はフェンスだけが描画されます。インラインの `$…$` は `inline: true` のときだけ描画します。そうしないと、ふつうの文の `$`（価格やシェル変数）が数式になってしまうためです。`inline: false` では、`modootoday-check` がページ内のインライン `$…$` に警告します。文中に書いた `$$…$$` は kramdown がインライン数式として出力し、`auto_render_src` があれば描画されます。

### CSP とプライバシー

CDN を使うと、コンテンツセキュリティポリシーと訪問者のプライバシーが変わります。

- **CSP。** CDN のオリジンを `script-src`（両方）、`style-src`（KaTeX のスタイルシート）、`font-src`（KaTeX のフォント）に追加します。Mermaid は各図に `<style>` を書き込むため、どこでホストしても `style-src 'unsafe-inline'` が必要です。自分でホストすれば、スクリプト・スタイル・フォントはすべて `'self'` のままです。[コンテンツセキュリティポリシー](../../csp/)を参照してください。
- **プライバシー。** 訪問者のブラウザーが CDN にファイルを要求するので、CDN は訪問者の IP アドレス、ページのアドレス（リファラー）、時刻を受け取ります。自分でホストすればこれを避けられます。CDN を使う場合は、プライバシーポリシーに記載してください。
- **可用性。** CDN を使うと、その CDN に接続できるときだけブロックが描画され、できないときはソースのコードブロックが残ります。

## 独自のローダー

ビルド手順を追加できないときに使います。レンダラーのファイルをサイトにコピーし、`_includes/footer-custom.html` から読み込みます。タグを Liquid の `if page.math` (または `if page.mermaid`) ブロックで囲み、front matter でそのキーを設定したページだけで読み込むようにします。

### ブラウザーでの KaTeX

```html
<link rel="stylesheet" href="/your-base/assets/katex/katex.min.css">
<script defer src="/your-base/assets/katex/katex.min.js"></script>
<script defer src="/your-base/assets/js/math.js"></script>
```

```js
// assets/js/math.js: render ```math fences (kramdown: pre > code.language-math)
document.querySelectorAll("code.language-math").forEach((code) => {
  const box = document.createElement("div");
  katex.render(code.textContent, box, { displayMode: true, throwOnError: false });
  code.closest("div.highlighter-rouge, pre").replaceWith(box);
});
```

ページの front matter に `math: true` を追加します。スクリプトはファイルなので `script-src 'self'` で足ります。

### ブラウザーでの Mermaid

Mermaid は各 SVG に `<style>` 要素を書き込むため、厳格な `style-src 'self'` ではスタイルがブロックされます。[静的な Mermaid の図](../math-diagrams/#静的な-mermaid-の図)を使うか、そのページだけインラインスタイルを許可し、スクリプトは厳格なままにします:

```html
<script defer src="/your-base/assets/mermaid/mermaid.min.js"></script>
<script defer src="/your-base/assets/js/diagrams.js"></script>
```

```js
// assets/js/diagrams.js
document.querySelectorAll("code.language-mermaid").forEach((code) => {
  const box = document.createElement("pre");
  box.className = "mermaid";
  box.textContent = code.textContent;
  code.closest("div.highlighter-rouge, pre").replaceWith(box);
});
const dark = document.documentElement.dataset.theme === "dark" || (!document.documentElement.dataset.theme && matchMedia("(prefers-color-scheme: dark)").matches);
mermaid.initialize({ startOnLoad: false, theme: dark ? "dark" : "default", securityLevel: "strict" });
mermaid.run();
```

`securityLevel: "strict"` を保ってください。図の中のクリックハンドラーと HTML ラベルを無効にします。
