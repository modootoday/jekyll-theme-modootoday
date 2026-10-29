---
title: 数式と図
description: テーマに同梱せず、厳格な CSP を壊さずに KaTeX の数式と Mermaid の図を追加します。
---
# 数式と図

テーマは数式や図のレンダラーを同梱しません。```` ```math ```` や ```` ```mermaid ```` のフェンスはサイトではコードブロックとして表示され、github.com では GitHub が描画します。サイトで描画するには、下の二つの方法のどちらかを選びます。どちらも[厳格な CSP](../csp/) `default-src 'self'; script-src 'self'; style-src 'self'` で動きます。

> [!NOTE]
> このページは[英語の原文](../../math-diagrams/)の翻訳です。内容が異なる場合は英語版が優先されます。

| 方法 | 動く環境 | CSP | ブラウザーの JavaScript |
|---|---|---|---|
| ビルド時に描画して出力をコミットする | 従来の GitHub Pages、Jekyll 4、任意のホスト | 厳格なまま、追加なし | なし |
| レンダラーを自分でホストし `_includes/footer-custom.html` から読み込む | 従来の GitHub Pages、Jekyll 4、任意のホスト | KaTeX は厳格なまま。Mermaid は `style-src 'unsafe-inline'` が必要 | あり |

レンダラーを CDN から読み込まないでください。`script-src` に第三者のオリジンが加わり、ページがそのオリジンの稼働に依存します。

## ビルド時に描画する

推奨の方法です。ページは静的な SVG を配信するので、JavaScript なしで動き、印刷にも向き、厳格な CSP を通ります。

### 図

Mermaid CLI で各 Mermaid ソースを SVG に描画し、SVG をコミットして図として参照します。図を再生成できるよう、ソースをその隣に置いておきます。

```sh
npx -y @mermaid-js/mermaid-cli -i assets/diagrams/flow.mmd -o assets/diagrams/flow.svg -b transparent
```

```markdown
![Markdown becomes a page, then the checker verifies the build](../assets/diagrams/flow.svg)

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

## レンダラーを自分でホストする

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

- ソースは Markdown に残るので、github.com と [Markdown ツイン](../agents/)を読むエージェントには引き続き見えます。
- CSP に第三者のオリジンがないこと。
- すべての図に、何を示すかを述べる代替テキストかキャプションがあること。
- レンダラーは必要なページだけで読み込むこと。
