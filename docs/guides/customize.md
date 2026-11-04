---
nav_order: 40
title: Customize
description: Change colors, radius and fonts with tokens and the token bridge, add your own stylesheets, or override Sass partials.
sections:
  - tokens
  - bridge
  - code
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

Overrides in your own stylesheet need to beat the theme's dark-scheme selectors (`:root[data-theme]` and the `prefers-color-scheme` rule). Three supported ways:

- Set them in the [token bridge](#token-bridge) (recommended). The theme compiles them into its own token rules, with nothing inline.
- Put the values in `modootoday.tokens` and `modootoday.tokens_dark`. The theme prints them in an inline `<style>` with the same selectors as its own tokens, so a strict CSP blocks them.
- Set `modootoday.css_layers: true`. The theme CSS then sits in `@layer mt.*`, and any rule outside a layer wins, so a plain `:root { … }` is enough.

Images in dark mode: photos use `--mt-img-filter-dark`; `.svg` figures (diagrams) use `--mt-diagram-filter-dark`, which inverts them with the hues kept and then applies `--mt-img-filter-dark`. Override either in your tokens, for example `--mt-diagram-filter-dark: none` to keep every diagram as drawn; a `#light` ending on one image's path (`flow.svg#light`) does the same for that image. See [Math and diagrams](../../recipes/math-diagrams/#diagrams).

### Layout hooks

Some sizes and the primary button colours are hooks: the theme reads them as `var(--mt-<name>, <default>)` and never sets them, so a plain rule in your own stylesheet (for example one linked with `site_css`) changes them without having to beat the theme's selectors.

| Hook | Default | What it sets |
|---|---|---|
| `--mt-sidebar-width` | `18rem` | the doc sidebar column, from 64rem |
| `--mt-toc-width` | `15rem` | the "On this page" column |
| `--mt-doc-gap` | `2rem` | the gap between the doc columns |
| `--mt-doc-container` | `90rem` | the width of the header, main and footer on pages with a doc sidebar |
| `--mt-code-radius` | `var(--mt-radius)` | the corners of code blocks and their title bar |
| `--mt-button-primary-bg` | `var(--mt-foreground)` | the fill and border of the primary action (the first link of a hero or `c: cta` button row) |
| `--mt-button-primary-fg` | `var(--mt-background)` | the text of the primary action |
| `--mt-hero-title-size` | `clamp(2.5rem, 1.5rem + 3vw, 3.5rem)` | the hero title and the marketing page title |

```css
:root { --mt-sidebar-width: 16rem; }
```

The defaults are in `_sass/modootoday/registry/_hooks.scss`.

## Token bridge

Create `_sass/modootoday/_site.scss` in your site and set up to three maps. The theme imports this file before its settings, so the core sheet and every optional sheet use your values in light and dark mode:

```scss
// _sass/modootoday/_site.scss
$mt-overrides-base: (font-sans: (Inter, system-ui, sans-serif), font-heading: (Fraunces, Georgia, serif));
$mt-overrides: (primary: #0f766e, link: #0f766e);
$mt-overrides-dark: (primary: #2dd4bf, link: #5eead4);
```

`$mt-overrides-base` takes the scheme-free tokens (fonts, sizes, radius); the other two take colours for light and dark mode. Besides the existing tokens there are `font-heading` and `heading-weight` for `h1` to `h4`, and `link` and `link-hover` for links in running text; by default they follow `font-sans`, 600 and `primary`. The file may hold only these three maps, with token names the theme defines; `modootoday-check` reports anything else.

Korean, Japanese and Chinese pages get a `font-sans` stack of their own for each of those languages the site declares in `lang` or `modootoday.languages`: the system fonts of that script, with Pretendard first for Korean if your site loads it (the theme does not ship it). An English-only site prints none of them. Setting `font-sans` in the bridge or in `modootoday.tokens` turns them off, so your font applies to every language.

Two settings bring your own files next to the theme's:

```yaml
modootoday:
  site_css: [/assets/css/site.css]   # linked after the theme sheets; front matter site_css: adds sheets on one page
  preload:                           # <link rel="preload"> before the stylesheets; front matter preload: per page
    - {href: /assets/fonts/inter.woff2, as: font, type: font/woff2}
```

A worked example with a palette, a self-hosted font and the contrast checks is in [Brand tokens](../../recipes/brand-tokens/).

## Code colours

Code blocks take their colours from `--mt-code-*` tokens. `modootoday.code_theme: github` switches them to GitHub's light and dark palettes ([demo](../../layouts/demo/code-github/)):

```yaml
modootoday:
  code_theme: github   # theme (default) or github
```

The colours come from GitHub's editor themes (github-light-default and github-dark-default). Rouge sorts code into other token classes than the editor does, so the palette matches GitHub's but a word can get a different colour. The tokens are `code-background`, `code-foreground`, `code-keyword`, `code-string`, `code-comment`, `code-function`, `code-constant`, `code-variable`, `code-type`, `code-number`, `code-operator`, `code-tag`, `code-attribute`, `code-inserted` and `code-deleted`. With the default `theme`, the ten finer ones follow the older five, so code looks as before. The token bridge applies after the preset, so `$mt-overrides: (code-comment: #57606a)` changes one colour. Code colours need Rouge, the default `kramdown.syntax_highlighter`; `modootoday-check` warns when another highlighter is set.

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

### Module scripts and posters

For a visual that needs JavaScript, such as a canvas or an animated SVG, register an ES module once in `modootoday.scripts` and name it with `script:` on the hero or a section item. Only the pages that name it load it: the theme adds the entry's `css` sheet, a `<link rel="modulepreload">` for each `preload` path and a `<script type="module">` to `<head>`, once per page. All paths are site paths. Module scripts run deferred and are allowed by `script-src 'self'`, so a strict CSP needs no change. List in `preload` only the modules your module's own imports load (two levels down); a direct import needs no hint.

```yaml
# _config.yml
modootoday:
  scripts:
    orbit: {src: /assets/js/hero/orbit.js, css: /assets/css/orbit.css, preload: [/assets/js/hero/scene.js]}
```

```yaml
hero: {c: split, visual: orbit-stage, script: orbit, poster: {path: /assets/hero/orbit-960.webp, srcset: "/assets/hero/orbit-640.webp 640w, /assets/hero/orbit-960.webp 960w", width: 960, height: 960}}
```

`poster:` takes the `hero.image` shape: a path, or `{path, srcset, sizes, width, height}`. `width` and `height` are required, so the box is kept before the image arrives. The theme puts it first in the visual column as `img.mt-visual-poster`. On the hero it is fetched with high priority and is usually the page's largest contentful paint; in a section it loads lazily. A split item with `script:` or `poster:` needs no `visual:`; outside split, the poster and the include sit in `div.mt-visual`. The column carries `data-mt-script="<name>"`.

Your module's side of the contract:

- When `prefers-reduced-motion: reduce` matches, do nothing; the poster stays. It also stays when JavaScript is off or the module fails.
- Draw into an element with the class `mt-visual-stage` after the poster, for example from the `visual:` include; it covers the poster's box.
- After the first frame, set `data-mt-ready` on the `[data-mt-script]` column; the theme then hides the poster.
- Read settings from `data-*` attributes with `readConfig` (`/assets/js/modootoday/dom/config.js`) and follow light and dark with `onThemeChange` (`/assets/js/modootoday/theme/current.js`, see [Events](../../reference/api/#events)). Import them by relative path, such as `../modootoday/dom/config.js`.

The [hero module demo](../../layouts/demo/orbit/) is a 40-line module that follows this contract.

`full_width: true` removes the reading-column width and side padding of `main.mt-main` (adds `.mt-main-full`) for landing pages.

## Sass partials

Write your own rules in a stylesheet of your site and list it in `site_css`; it loads after the theme's sheets, so equal selectors win:

```scss
---
---
.mt-hero h1 { letter-spacing: -0.02em; }
```

Jekyll reads `_sass/` from your site before the theme. A site that already shadows `assets/css/modootoday.scss` keeps working, and its token hook applies there too, because the theme imports the hook from its core partial. Since 1.5 the core sheet holds only the tokens, the base rules and the shell, and components come in their own sheets; a copy made from an older version still keeps every component in the core sheet, so refresh it from the version you use, or delete it and set tokens instead.

> [!WARNING]
> Use `@import`, not `@use`. GitHub Pages compiles Sass with Ruby Sass, which passes `@use` through unchanged.

## Shadowing layouts and includes

Any file in the theme's `_layouts/`, `_includes/` or `assets/` can be replaced by a file with the same path in your site. In `_sass/` that holds only for the partials the theme imports through the Sass load path: the token hook `_sass/modootoday/_site.scss`, `_sass/modootoday/_access.scss` and the component partials under `_sass/modootoday/components/` (the FAQ sheet still reads the theme's `_details.scss`). Every other partial (settings, tools, tokens, base, layout and the per-layout sheets) is imported relative to the theme file that uses it, so Sass reads the theme's copy and ignores yours, on GitHub Pages and on Jekyll 4 alike. A copy of `_core.scss`, `_sheet.scss` or a per-layout `_index.scss` stops the build, because its relative imports are not next to it. Component partials are internal, so a shadowed one can break on a theme update; to change the rest, add rules with `site_css` or shadow the stylesheet under `assets/css/`.

Add tags to the page head with `_includes/head-custom.html`:

```html
<link rel="icon" href="/favicon.svg">
```

> [!CAUTION]
> Shadowed files do not receive theme updates. Prefer tokens and `head-custom.html`.

Lists without a class get a small gap between items. If your layout or include turns an unclassed Markdown list into a grid or flex row (for example `.c-body > ul`), add `mt-flat-list` to an ancestor, such as `<div class="c-body mt-flat-list">`, so the first item lines up with the rest. A list that has a class of its own gets no gap.

## Next

[Agent-readable Markdown](../agents/) [Configuration](../configuration/)
