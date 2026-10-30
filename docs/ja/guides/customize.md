---
nav_order: 40
nav_title: カスタム
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
> このページは[英語の原文](../../../guides/customize/)の翻訳です。内容が異なる場合は英語版が優先されます。

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

`sections:` の項目に `visual: <name>` を書くと、そのセクションの末尾にサイトの `_includes/sections/<name>.html` が描画されます。 include は項目を `include.section` として受け取るので、`scene:` のような追加キーも渡ります。front matter の `hero: {visual: <name>}` は最初の `##` より前の部分に同じことをします（`sections:` が必要です）。 include がないと `modootoday-check` が失敗します。

```yaml
---
full_width: true
hero: {visual: player-mock}
sections: [{c: features, name: why, visual: chart, scene: night}, faq]
---
```

テーマにはヒーロー用ビジュアル `showcase` が 1 つ付属しています。やわらかな背景画像、トークンによるオーバーレイ、SVG で描いた UI シーンのアニメーションを重ねて表示します。スタイルシートはこのビジュアルを使うページにだけ読み込まれ、JavaScript を使わず 5 秒以内に動きが止まります。視差効果を減らす設定では最後の場面だけを表示します。ダークモードでは同じ画像を CSS filter で暗くし、`--mt-img-filter-dark` で調整できます。独自の画像を使うには `image:`、`srcset:`、`width:`、`height:` を渡してください。[ホーム](../../)で実際の表示を確認できます。

```yaml
hero: {visual: showcase}
# または: hero: {visual: showcase, image: /assets/hero.webp, srcset: "/assets/hero-800.webp 800w, /assets/hero.webp 1600w", width: 1600, height: 900}
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

## レイアウトと include の上書き

テーマの `_layouts/`、`_includes/`、`_sass/` にあるファイルは、サイトの同じパスにファイルを置けば置き換えられます。ページの head にタグを足すには `_includes/head-custom.html` を使います。

```html
<link rel="icon" href="/favicon.svg">
```

> [!CAUTION]
> 上書きしたファイルにはテーマの更新が反映されません。トークンと `head-custom.html` を優先してください。

## 次へ

[エージェントが読める Markdown](../agents/) [設定](../configuration/)
