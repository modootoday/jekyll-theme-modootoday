---
lang: ja
permalink: /ja/layouts/demo/code-github/
source_rev: sha256:ed6279dfbed8
title: GitHub コードカラーのデモ
description: GitHub のライトとダークのパレットで色付けしたコードブロックです。modootoday.code_theme github の見た目です。
twin: false
sitemap: false
edit: false
nav_exclude: true
site_css: [/assets/css/code-github.css]
---
# GitHub コードカラー

このページは、`code_theme: github` を設定したサイトでコードブロックがどう見えるかを示します。ライトとダークを切り替えて両方のパレットを確認してください。ドキュメントのほかのページは既定のコードカラーのままです。

```yaml
# _config.yml
modootoday:
  code_theme: github
```

色は GitHub のライトとダークのエディターテーマから取っています。Rouge はエディターとトークンの分け方が違うため、パレットは GitHub と同じでも、単語ひとつの色が異なることがあります。[カスタマイズ](../../../guides/customize/)を参照してください。

## Ruby

```ruby
# Greets everyone on the list.
class Greeter
  DEFAULT = "world"

  def initialize(names = [DEFAULT])
    @names = names
  end

  def greet(times: 2)
    @names.each { |n| puts "Hello, #{n}!" * times if n.length > 0 }
  end
end
```

## JavaScript

```js
const total = (items) => items.reduce((sum, item) => sum + item.price * 1.1, 0);
export async function load(url) {
  const res = await fetch(url, { cache: "no-store" });
  return res.ok ? res.json() : null;
}
```

## HTML

```html
<a class="mt-cta" href="/guides/install/" aria-label="Install">Install</a>
```

## SCSS

```scss
$mt-overrides: (code-keyword: #cf222e);
.site-note { color: var(--mt-code-comment); }
```

## Diff

```diff
- code_theme: theme
+ code_theme: github
```

## Shell

```sh
bundle exec jekyll build --config _config.yml && echo "done: $?"
```
