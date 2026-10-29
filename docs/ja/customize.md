---
title: カスタマイズ
description: トークンで色、角丸、フォントを変えるか、Sass パーシャルを上書きします。
sections:
  - tokens
  - sass
  - shadow
  - {c: cta, name: next}
---
# カスタマイズ

まずはトークンから。トークンで足りないときだけ Sass パーシャルを使います。

> [!NOTE]
> このページは[英語の原文](../../customize/)の翻訳です。内容が異なる場合は英語版が優先されます。

## デザイントークン

テーマは CSS カスタムプロパティを公開しています。自分のスタイルシートか `modootoday.tokens` で上書きします。

```css
:root {
  --mt-primary: #0f766e;
  --mt-radius: 0.75rem;
}
```

## Sass パーシャル

Jekyll はテーマより先にサイトの `_sass/` を読みます。テーマの後に独自のルールを足すには `assets/css/modootoday.scss` を作ります。

```scss
---
---
@import "modootoday";

.mt-hero h1 { letter-spacing: -0.02em; }
```

> [!WARNING]
> `@use` ではなく `@import` を使ってください。GitHub Pages は Ruby Sass で Sass をコンパイルし、`@use` をそのまま出力します。

## レイアウトとインクルードの上書き

テーマの `_layouts/`、`_includes/`、`_sass/` にあるファイルは、サイトの同じパスにファイルを置けば置き換えられます。ページの head にタグを足すには `_includes/head-custom.html` を使います。

```html
<link rel="icon" href="/favicon.svg">
```

> [!CAUTION]
> 上書きしたファイルにはテーマの更新が反映されません。トークンと `head-custom.html` を優先してください。

## 次へ

[エージェントが読める Markdown](../agents/) [設定](../configuration/)
