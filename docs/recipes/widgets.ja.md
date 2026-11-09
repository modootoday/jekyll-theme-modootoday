---
lang: ja
permalink: /ja/recipes/widgets/
source_rev: sha256:7a880ba56daa
nav_order: 28
title: ウィジェット
description: 自作の custom element を Markdown からページに置き、JavaScript のない読者には代わりに読むテキストを渡します。
widget_props: {x-counter: {start: 10, step: 10, label: 10 を足す}}
---
# ウィジェット

> [!NOTE]
> このページは[英語の原文](../../../recipes/widgets/)の翻訳です。内容が異なる場合は英語版が優先されます。

ウィジェットとは、計算機やリアルタイムの状態表示のような自作の custom element を、Markdown からページに置いたものです。テーマはウィジェットのコードを提供しません。テーマは要素を置き、設定を渡し、その要素があるページでだけモジュールを読み込み、JavaScript のない読者、github.com、ページの Markdown 版、`llms-full.txt` のために代替テキストを残します。

## 要素を登録する

モジュールが定義する要素を書いて、`modootoday.scripts` に項目を追加します。

```yaml
modootoday:
  scripts:
    counter: {src: /assets/js/widgets/x-counter.js, css: /assets/css/widgets/x-counter.css, element: x-counter}
```

- `element` は custom element の名前です。小文字でハイフンを含め、テーマの接頭辞である `mt-` で始めることはできず、`font-face` のように SVG と MathML が予約している名前も使えません。二つの項目が同じ要素を指すことはできません。
- `src` と `css` はサイト内のパスです。`<x-counter` があるページは、[モジュールスクリプト](../../guides/customize/#モジュールスクリプトとポスター)と同じく、その項目のシートと `<script type="module">` を `<head>` に一度だけ受け取ります。モジュールスクリプトは `script-src 'self'` で許可されるので、厳格な CSP を変える必要はありません。
- 要素のないページは何も読み込みません。
- モジュールとシートの URL には、テーマのファイルや `site_css` のシートと同じくテーマの `?v=` クエリが付くので、CDN が長くキャッシュできます。既定の `modootoday.asset_version: theme` では、クエリはテーマのバージョンが変わるときだけ変わります。テーマのリリースの間に自作のモジュールを直すなら、コミットを加える `asset_version: build` にしてください（[バージョン付きアセット URL](../../guides/performance/#バージョン付きアセット-url)）。エントリーのモジュールが読み込むモジュールの URL にはクエリが付きません。

## セクションに置く

`c: widget` セクションは、セクションの見出しの後に要素を置きます。見出しの後のテキストが代替テキストです。

```yaml
sections:
  - c: widget
    name: counter
    widget: x-counter
    props: {start: 3, label: 数える}
```

```markdown
## カウンター

カウンターは 3 から始まります。JavaScript のない読者は代わりにこの段落を読みます。
```

テーマが書き出すマークアップは次のとおりです。

```html
<x-counter class="mt-widget" data-props="{&quot;start&quot;:3,&quot;label&quot;:&quot;数える&quot;}">
  <div class="mt-widget-fallback"><p>カウンターは 3 から始まります。…</p></div>
</x-counter>
```

- `props` はプレーンな値（テキスト、数値、`true`、`false`）のマップです。要素はこれを `data-props` から JSON として読みます。
- セクションの見出しの後には段落が少なくとも一つ必要です。その段落だけで意味が通じるように書いてください。一文、結果の表、同じことができるページへのリンクのどれでもかまいません。

[キッチンシンク](../../components/kitchen-sink/#ウィジェット)にカウンターのセクションがあります。

## 段落に置く

`widget:<element>` だけの行は、その場所に要素を置きます。

```markdown
`widget:x-counter`
```

props は要素名をキーにして front matter から取ります。`widget_props: {x-counter: {start: 10, step: 10}}` のように書きます。代替テキストはテーマのカタログの一文（`widget.fallback`、翻訳済み）です。`modootoday.scripts` に登録した要素だけがウィジェットになり、それ以外の `widget:` の行はコードスパンのまま残って、`modootoday-check` が報告します。このページにも一つあります。

`widget:x-counter`

## 要素を作る

テーマとモジュールの間の約束は次のとおりです。

- `customElements.define` で要素を定義します。それまでテーマは `div.mt-widget-fallback` を表示し、要素が定義されると（CSS の `:defined`）隠します。モジュールが失敗したり読み込まれなかったりすると代替テキストがそのまま残ります。`<noscript>` は使いません。
- 設定は `data-props` から読みます。テーマの `/assets/js/modootoday/dom/config.js` が名前付きエクスポートで提供する [`readConfig`](../../guides/customize/#モジュールスクリプトとポスター) が解析します。`readConfig(this, {props: {}})` のように使います。モジュールからの相対パスで読み込んでください。

  ```js
  // assets/js/widgets/x-counter.js
  import { readConfig } from "../modootoday/dom/config.js";
  ```

- コントロールは代替テキストの後に追加し、代替テキストは要素の中に残します。
- コントロールは `var(--mt-primary)` や `var(--mt-border)` などのテーマのトークンで装飾してライトモードとダークモードに従わせ、フォーカスが見えるようにします。

このページのカウンターは 30 行のモジュール [x-counter.js](https://github.com/modootoday/jekyll-theme-modootoday/blob/main/docs/assets/js/widgets/x-counter.js) と 7 行のシートです。

## 読者が受け取るもの

| 読者 | 見えるもの |
|---|---|
| モジュールを実行するブラウザー | 要素 |
| JavaScript がオフ、またはモジュールがブロックされたか失敗した場合 | 代替テキスト |
| github.com、Markdown 版、`llms-full.txt` | セクションのテキストと、コードとして表示される `widget:` の行 |

`modootoday-check` は、どの項目も登録していない要素、プレーンな値でない props、段落のない `c: widget` セクション、ブラウザーが受け付けない `element` 名を報告します。
