---
nav_order: 10
title: 数式と図
description: 組み込みローダー、ビルド時の描画、独自のローダーで Mermaid の図と KaTeX の数式を描画する方法と、それぞれの CSP とプライバシーへの影響です。
---
# 数式と図

> [!NOTE]
> このページは[英語の原文](../../../recipes/math-diagrams/)の翻訳です。内容が異なる場合は英語版が優先されます。

```` ```math ```` や ```` ```mermaid ```` のフェンスは、レンダラーを有効にするまでコードブロックとして表示され、github.com では GitHub が描画します。サイトで描画する方法は三つあります。

| 方法 | 動く環境 | CSP | ブラウザーの JavaScript |
|---|---|---|---|
| [組み込みローダー](#組み込みローダー)：`modootoday.mermaid` と `modootoday.math` | 従来の GitHub Pages、Jekyll 3.10 と 4、任意のホスト | 自分でホスト：`'self'`、CDN：CDN のオリジンを追加（下記） | あり、ブロックのあるページだけ |
| [ビルド時に描画](#ビルド時に描画する)して出力をコミットする | 従来の GitHub Pages、Jekyll 4、任意のホスト | 厳格なまま、追加なし | なし |
| `_includes/footer-custom.html` の[独自のローダー](#独自のローダー) | 従来の GitHub Pages、Jekyll 4、任意のホスト | KaTeX は厳格なまま。Mermaid は `style-src 'unsafe-inline'` が必要 | あり |

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
    src: https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.js
    css: https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.css
    integrity: {js: sha384-…, css: sha384-…}
    auto_render_src: https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/contrib/auto-render.min.js
    auto_render_integrity: sha384-…
    inline: false
```

- **必要なページだけ。** ブロックのあるページだけでタグを読み込みます。Mermaid は `language-mermaid`、数式は ```` ```math ```` フェンスか `$$` ブロックが対象です。一つのページだけ除くには、front matter に `mermaid: false` か `math: false` を書きます。
- **ハッシュがなければ読み込みません。** `integrity` のない CDN の URL（または https 以外の URL）は何も読み込まず、`modootoday-check` がエラーを報告します。チェッカーは URL に正確なバージョン（`@11` や `@latest` ではなく `@11.4.1`）も求め、ビルドしたページにあるほかの第三者のスクリプトやスタイルシートも報告します。
- **自分でホストできます。** `/assets/vendor/mermaid.min.js` のようなパスはサイトから読み込みます（`relative_url` を適用、`integrity` は任意）。KaTeX は `katex` パッケージから `katex.min.js`、`katex.min.css`、`fonts/` フォルダー、`contrib/auto-render.min.js` をコピーします。
- **JavaScript なしでも読めます。** レンダラーが置き換えるまでソースはコードブロックとして残り、図や数式を解釈できない場合もそのまま残ります。
- **ライトとダーク。** `theme: auto` では、ページがダーク（テーマの切り替えか訪問者のシステム設定）のとき Mermaid の `dark` テーマを使い、変わると描き直します。視差効果を減らす設定では図のアニメーションを止めます。本文より広い図は、キーボードでフォーカスできる専用の領域の中でスクロールします。
- 各ローダーは小さな別のスクリプト（`assets/js/modootoday-mermaid.js`、`assets/js/modootoday-math.js`）で、コアのスクリプトとは別にサイズ予算があります。

### 数式の書き方

```` ```math ```` フェンスか、行を独占する `$$` ブロックを使います。どちらも標準の書き方で、github.com でも描画されます。`$$` ブロックには `auto_render_src` が必要で、ない場合はフェンスだけが描画されます。インラインの `$…$` は `inline: true` のときだけ描画します。そうしないと、ふつうの文の `$`（価格やシェル変数）が数式になってしまうためです。`inline: false` では、`modootoday-check` がページ内のインライン `$…$` に警告します。文中に書いた `$$…$$` は kramdown がインライン数式として出力し、`auto_render_src` があれば描画されます。

### CSP とプライバシー

CDN を使うと、コンテンツセキュリティポリシーと訪問者のプライバシーが変わります。

- **CSP。** CDN のオリジンを `script-src`（両方）、`style-src`（KaTeX のスタイルシート）、`font-src`（KaTeX のフォント）に追加します。Mermaid は各図に `<style>` を書き込むため、どこでホストしても `style-src 'unsafe-inline'` が必要です。自分でホストすれば、スクリプト・スタイル・フォントはすべて `'self'` のままです。[コンテンツセキュリティポリシー](../csp/)を参照してください。
- **プライバシー。** 訪問者のブラウザーが CDN にファイルを要求するので、CDN は訪問者の IP アドレス、ページのアドレス（リファラー）、時刻を受け取ります。自分でホストすればこれを避けられます。CDN を使う場合は、プライバシーポリシーに記載してください。
- **可用性。** CDN を使うと、その CDN に接続できるときだけブロックが描画され、できないときはソースのコードブロックが残ります。

## ビルド時に描画する

推奨の方法です。ページは静的な SVG を配信するので、JavaScript なしで動き、印刷にも向き、厳格な CSP を通ります。

### 図

Mermaid CLI で各 Mermaid ソースを SVG に描画し、SVG をコミットして図として参照します。図を再生成できるよう、ソースをその隣に置いておきます。

```sh
npx -y @mermaid-js/mermaid-cli -i assets/diagrams/flow.mmd -o assets/diagrams/flow.svg -b transparent
```

```markdown
![Markdown becomes a page, then the checker verifies the build](../../assets/diagrams/flow.svg)

*The build flow.*
```

画像だけの段落の後に強調だけの段落が続くと、キャプション付きの図になります。代替テキストには「図」ではなく図の意味を書きます。ダークモードには `-t dark` で二つ目の SVG を描画して `<picture>` と `prefers-color-scheme` で選ぶか、透明な背景とどちらでも読める中間の色を使います。

### 数式

コミット前に実行するスクリプト、または GitHub Actions 上の Jekyll 4 ビルドで、KaTeX を使って数式を一度 HTML に描画します。その後、KaTeX の CSS とフォントを自分のサイトから配信します。例の `/your-base` はサイトの `baseurl` に置き換えてください (または Jekyll の `relative_url` フィルターを使います):

```sh
npm install katex
mkdir -p assets/katex && cp -r node_modules/katex/dist/katex.min.css node_modules/katex/dist/fonts assets/katex/
```

```html
<!-- _includes/head-custom.html -->
<link rel="stylesheet" href="/your-base/assets/katex/katex.min.css">
```

KaTeX の静的な出力は普通の HTML と CSS クラスなので、`style-src 'self'` で足ります。

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

Mermaid は各 SVG に `<style>` 要素を書き込むため、厳格な `style-src 'self'` ではスタイルがブロックされます。ビルド時に描画する (上記) か、そのページだけインラインスタイルを許可し、スクリプトは厳格なままにします:

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

## チェックリスト

- ソースは Markdown に残るので、github.com と [Markdown 版](../../guides/agents/)を読むエージェントには引き続き見えます。
- CSP に第三者のオリジンがないこと。または CDN のオリジンを記載し、`integrity` で固定していること。
- すべての図に、何を示すかを述べる代替テキストかキャプションがあること。
- レンダラーは必要なページだけで読み込むこと。
