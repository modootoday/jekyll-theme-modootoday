---
lang: ja
permalink: /ja/recipes/brand-tokens/
source_rev: sha256:049fbb797e23
nav_order: 15
nav_title: ブランドトークン
title: ブランドトークン
description: トークンブリッジでブランドの色とフォントをテーマに反映し、サイトのスタイルシートと先読みするフォントまで厳格な CSP で使います。
site_css: [/assets/css/brand-demo.css]
preload:
  - {href: /assets/fonts/fraunces/fraunces-600-latin.woff2, as: font, type: font/woff2}
---
# ブランドトークン

> [!NOTE]
> このページは[英語の原文](../../../recipes/brand-tokens/)の翻訳です。内容が異なる場合は英語版が優先されます。

このページには、架空のティール色のブランドと、セルフホストした見出しフォントを適用しています。ライトとダークを切り替えて、二つの配色を確認してください。ほかのドキュメントは既定の見た目のままです。

## トークンブリッジ

サイトに `_sass/modootoday/_site.scss` を作ります。テーマはこのファイルを自身の設定より先に読み込むので、ここで設定したマップがコアシートとすべての任意シートのトークンを変えます。インラインになるものはなく、`assets/css/modootoday.scss` を上書きする必要もありません。

```scss
// _sass/modootoday/_site.scss
$mt-overrides-base: (font-heading: ("Fraunces", var(--mt-font-sans)), heading-weight: 600);
$mt-overrides: (
  primary: #0f766e, primary-foreground: #ffffff, link: #0f766e, link-hover: #115e59,
  background: #fbfdfc, foreground: #10302c, muted: #eef6f4, muted-foreground: #4b635f, border: #cfe3df
);
$mt-overrides-dark: (
  primary: #2dd4bf, primary-foreground: #042f2b, link: #5eead4, link-hover: #99f6e4,
  background: #0b1615, foreground: #e3f2ef, muted: #13211f, muted-foreground: #9db5b0, border: #24403b
);
```

色はライトとダークのために両方のマップに指定します。`heading-weight: 600` は既定値で、書く場所を示すために入れています。マップごとに受け取るトークンと `modootoday-check` が拒否する内容は[カスタマイズ > トークンブリッジ](../../guides/customize/#トークンブリッジ)にあります。

## サイトのスタイルシートとフォント

```yaml
modootoday:
  site_css: [/assets/css/site.css]
  preload:
    - {href: /assets/fonts/fraunces-600-latin.woff2, as: font, type: font/woff2}
```

- `site_css` はサイトのシートを、テーマのシートの後、`modootoday.tokens` と `head-custom.html` の前に読み込みます。テーマのファイルと同じ `?v=` クエリが付きます。ページの front matter に `site_css:` を書くと、そのページだけにシートを読み込みます。このページがその例です。`css_layers: true` と組み合わせると、サイトのルールが常にテーマのルールに勝ちます。
- `preload` はスタイルシートの前に `<link rel="preload">` を出力し、ブラウザーが CSS を読んでいる間にフォントの取得を始めさせます。フォントには `crossorigin` が付きます。URL には `?v=` クエリが付きません。`@font-face` の `url()` と一致している必要があり、違うとブラウザーがフォントを二度ダウンロードします。front matter の `preload:` もページ単位で使えます。

```scss
@font-face {
  font-family: "Fraunces";
  src: url("/assets/fonts/fraunces-600-latin.woff2") format("woff2");
  font-weight: 500 800;
  font-display: swap;
}
```

どちらのキーもサイトパスだけを受け付けます。外部のシートは `head-custom.html` から読み込んでください。

## コントラスト

公開する前に両方の配色を確認してください。背景と `muted` の上の本文、背景の上の `primary` と `link`、`primary` の上の `primary-foreground`、そしてホバー時の塗りである `accent` の上の `muted-foreground` は 4.5:1 以上が必要です。入力欄の枠線 `border-input` は背景に対して 3:1、細い区切り線の `border` は背景と `card` の上で 1.2:1 あれば足ります。テーマのドキュメント QA が同じ基準で、このページをライトとダークの両モードで測ります。

## 厳格な CSP で

ブリッジ、`site_css`、`preload` はどれもファイルなので、`default-src 'self'; style-src 'self'` で足ります ([CSP](../csp/) を参照)。`modootoday.tokens` はインラインの `<style>` を出力するため、厳格な CSP のサイトでは値をブリッジに移してください。

## デモのフォント

このページの見出しフォントは [Fraunces](https://github.com/undercasetype/Fraunces) で、SIL Open Font License 1.1 で提供されています。ドキュメントには、ウェイト 600 のインスタンスを一つ、ラテン文字に絞って収録しています。ライセンスと入手元はファイルと同じ `docs/assets/fonts/fraunces/` フォルダーにあります。ほかの文字の見出しは `font-sans` で表示されます。
