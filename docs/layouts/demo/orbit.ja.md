---
lang: ja
permalink: /ja/layouts/demo/orbit/
source_rev: sha256:8989380cb3b1
nav_exclude: true
title: ヒーローモジュールのデモ
twin: false
sitemap: false
edit: false
description: "サイトのモジュールスクリプトがポスター画像の上に絵を描く分割ヒーローです。script: と poster: の設定方法と、スクリプトが動かないときの表示を示します。"
hero: {c: split, visual: orbit-stage, script: orbit, turn: 12, poster: {path: /assets/images/hero/orbit-960.webp, srcset: "/assets/images/hero/orbit-640.webp 640w, /assets/images/hero/orbit-960.webp 960w", width: 960, height: 960}}
sections: [setup, contract]
---
# ヒーローモジュールのデモ

絵の中心を 3 つの点が回ります。このサイトのモジュールスクリプトがポスター画像の上に点を描いて回します。最初に見えるのはポスターで、JavaScript がオフのときや視差効果を減らす設定のときはポスターがそのまま残ります。

[セクションのビジュアル](../../../guides/customize/)

## 設定

`_config.yml` にモジュールを一度登録し、ヒーローでポスターと一緒に名前を指定します。

```yaml
# _config.yml
modootoday:
  scripts:
    orbit: {src: /assets/js/hero/orbit.js, css: /assets/css/orbit.css}
```

```yaml
# front matter
hero:
  c: split
  visual: orbit-stage
  script: orbit
  poster: {path: /assets/images/hero/orbit-960.webp, width: 960, height: 960}
```

`orbit.js` とそのシート、このモジュールが読み込むテーマの小さなヘルパーは、このページだけで読み込まれます。ポスターはページでいちばん大きな画像で、最初に取得されます。

## モジュールの役割

- 視差効果を減らす設定のときはすぐに止まるので、ポスターが残ります。
- `orbit-stage` の include が出力する `mt-visual-stage` クラスの要素に描きます。この要素はポスターを覆います。
- 描き終えたらビジュアルの列に `data-mt-ready` を付けてポスターを隠します。
- `readConfig` で `data-turn` を読み、`onThemeChange` でライトとダークの切り替えに追従します。
