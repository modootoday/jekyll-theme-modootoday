---
title: Customize
description: Change colors, radius and fonts with tokens, or override Sass partials.
sections:
  - tokens
  - sass
  - shadow
  - {c: cta, name: next}
---
# Customize

Start with tokens. Reach for Sass partials only when tokens are not enough.

## Design tokens

The theme exposes CSS custom properties. Override them in your own stylesheet or with `modootoday.tokens`:

```css
:root {
  --mt-primary: #0f766e;
  --mt-radius: 0.75rem;
}
```

## Sass partials

Jekyll reads `_sass/` from your site before the theme. Create `assets/css/modootoday.scss` to add your own rules after the theme:

```scss
---
---
@import "modootoday";

.md-hero h1 { letter-spacing: -0.02em; }
```

> [!WARNING]
> Use `@import`, not `@use`. GitHub Pages compiles Sass with Ruby Sass, which passes `@use` through unchanged.

## Shadowing layouts and includes

Any file in the theme's `_layouts/`, `_includes/` or `_sass/` can be replaced by a file with the same path in your site. Add tags to the page head with `_includes/head-custom.html`:

```html
<link rel="icon" href="/favicon.svg">
```

> [!CAUTION]
> Shadowed files do not receive theme updates. Prefer tokens and `head-custom.html`.

## Next

[Agent-readable Markdown](../agents/) [Configuration](../configuration/)
