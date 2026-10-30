---
nav_order: 40
title: Customize
description: Change colors, radius and fonts with tokens, or override Sass partials.
sections:
  - tokens
  - visuals
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

Overrides in your own stylesheet need to beat the theme's dark-scheme selectors (`:root[data-theme]` and the `prefers-color-scheme` rule). Two supported ways:

- Put the values in `modootoday.tokens` and `modootoday.tokens_dark`. The theme prints them with the same selectors as its own tokens.
- Set `modootoday.css_layers: true`. The theme CSS then sits in `@layer mt.*`, and any rule outside a layer wins, so a plain `:root { … }` is enough.

Images in dark mode: photos use `--mt-img-filter-dark`; `.svg` figures (diagrams) use `--mt-diagram-filter-dark`, which inverts them with the hues kept and then applies `--mt-img-filter-dark`. Override either in your tokens, for example `--mt-diagram-filter-dark: none` to keep every diagram as drawn; a `#light` ending on one image's path (`flow.svg#light`) does the same for that image. See [Math and diagrams](../../recipes/math-diagrams/#diagrams).

## Section visuals and full-width pages

Add `visual: <name>` to a `sections:` item to render your own `_includes/sections/<name>.html` at the end of that section. The include gets the item as `include.section`, so extra keys such as `scene:` reach it. `hero: {visual: <name>}` in front matter does the same for the part before the first `##` (it needs `sections:`). `modootoday-check` fails when the include is missing.

```yaml
---
full_width: true
hero: {visual: player-mock}
sections: [{c: features, name: why, visual: chart, scene: night}, faq]
---
```

The theme ships one hero visual, `showcase`: a soft background image, a token overlay and an animated UI scene drawn in SVG. It adds its own stylesheet only on that page, needs no JavaScript and settles within five seconds. With reduced motion it shows the final frame. In dark mode the same image is dimmed with a CSS filter; set `--mt-img-filter-dark` to change it. To use your own picture, set `hero.image` — a path, or `{path, srcset, width, height}`; it is the same `hero.image` key the home layout hero uses. The [home page](../../) uses it.

```yaml
hero: {visual: showcase}
# or: hero: {visual: showcase, image: {path: /assets/hero.webp, srcset: "/assets/hero-800.webp 800w, /assets/hero.webp 1600w", width: 1600, height: 900}}
```

`full_width: true` removes the reading-column width and side padding of `main.mt-main` (adds `.mt-main-full`) for landing pages.

## Sass partials

Jekyll reads `_sass/` from your site before the theme. Create `assets/css/modootoday.scss` to add your own rules after the theme:

```scss
---
---
@import "modootoday";

.mt-hero h1 { letter-spacing: -0.02em; }
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

Lists without a class get a small gap between items. If your layout or include turns an unclassed Markdown list into a grid or flex row (for example `.c-body > ul`), add `mt-flat-list` to an ancestor, such as `<div class="c-body mt-flat-list">`, so the first item lines up with the rest. A list that has a class of its own gets no gap.

## Next

[Agent-readable Markdown](../agents/) [Configuration](../configuration/)
