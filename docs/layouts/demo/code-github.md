---
title: GitHub code colors demo
description: Code blocks in the GitHub light and dark palettes, the look of modootoday.code_theme github.
twin: false
sitemap: false
edit: false
nav_exclude: true
site_css: [/assets/css/code-github.css]
---
# GitHub code colors

This page shows code blocks as a site with `code_theme: github` sees them. Switch between light and dark to see both palettes; the rest of the docs keep the default code colors.

```yaml
# _config.yml
modootoday:
  code_theme: github
```

The colors come from GitHub's light and dark editor themes. Rouge sorts tokens differently from the editor, so the palette matches GitHub but a block can color a word differently. See [Customize](../../../guides/customize/#code-colors).

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
