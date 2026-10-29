---
title: カスタマイズ
description: トークンで色、角丸、フォントを変えるか、Sass パーシャルを上書きします。
sections:
  - tokens
  - visuals
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

自分のスタイルシートで上書きするには、テーマのダークスキームのセレクター（`:root[data-theme]` と `prefers-color-scheme` のルール）に勝つ必要があります。サポートしている方法は二つです。

- 値を `modootoday.tokens` と `modootoday.tokens_dark` に書きます。テーマ自身のトークンと同じセレクターで出力されます。
- `modootoday.css_layers: true` にします。テーマの CSS が `@layer mt.*` に入り、レイヤー外のルールが勝つので、普通の `:root { … }` で足ります。

## セクションのビジュアルと全幅ページ

`sections:` の項目に `visual: <name>` を書くと、そのセクションの末尾にサイトの `_includes/sections/<name>.html` が描画されます。インクルードは項目を `include.section` として受け取るので、`scene:` のような追加キーも渡ります。フロントマターの `hero: {visual: <name>}` は最初の `##` より前の部分に同じことをします（`sections:` が必要です）。インクルードがないと `modootoday-check` が失敗します。

```yaml
---
full_width: true
hero: {visual: player-mock}
sections: [{c: features, name: why, visual: chart, scene: night}, faq]
---
```

`full_width: true` はランディングページ向けに、`main.mt-main` の本文幅の制限と左右の余白を外します（`.mt-main-full` を追加）。

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
