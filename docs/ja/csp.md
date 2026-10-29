---
title: Content Security Policy
description: unsafe-inline なしの厳格な CSP でテーマを動かします。
---
# Content Security Policy

> [!NOTE]
> このページは[英語の原文](../../csp/)の翻訳です。内容が異なる場合は英語版が優先されます。

テーマは CSS とスクリプトを `assets/` 配下のファイルから読み込みます。既定でインラインになるものは二つです。

| インラインの項目 | 条件 | 厳格にする方法 |
|---|---|---|
| ペイント前のテーマスクリプト (誤った配色が一瞬表示されるのを防ぐ) | `theme-toggle` が有効で `color_scheme: auto` | `modootoday.csp: strict` で、代わりに `assets/js/modootoday/theme-init.js` をブロッキングスクリプトとして読み込む |
| `<style id="mt-tokens">` | `modootoday.tokens` または `tokens_dark` を設定している | 上書きを自分の Sass (`:root` に `--mt-primary: …`) に移し、キーを削除する |

両方に対応すれば、次のポリシーで動きます。

```text
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:
```

GitHub Pages はレスポンスヘッダーを送れません。これらのディレクティブなら、`_includes/head-custom.html` に置いた `<meta http-equiv="Content-Security-Policy">` タグで機能します。インラインスクリプトを残す場合は、代わりにハッシュで許可してください。ハッシュはスクリプトが変わったときだけ変わり、その際は `CHANGELOG.md` で告知します。
