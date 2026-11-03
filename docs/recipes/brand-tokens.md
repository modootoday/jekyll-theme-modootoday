---
nav_order: 15
nav_title: Brand tokens
title: Brand tokens
description: Give the theme your brand's colours and fonts through the token bridge, with your own stylesheet and a preloaded font, under a strict CSP.
site_css: [/assets/css/brand-demo.css]
preload:
  - {href: /assets/fonts/fraunces/fraunces-600-latin.woff2, as: font, type: font/woff2}
---
# Brand tokens

This page wears a made-up teal brand with a self-hosted heading font. Switch between light and dark to see both palettes; the rest of the docs keep the default look.

## The token bridge

Create `_sass/modootoday/_site.scss` in your site. The theme imports it before its own settings, so the maps you set there change the tokens in the core sheet and in every optional sheet. Nothing is inline, and you do not shadow `assets/css/modootoday.scss`.

```scss
// _sass/modootoday/_site.scss
$mt-overrides-base: (font-heading: ("Fraunces", var(--mt-font-sans)), heading-weight: 600);
$mt-overrides: (
  primary: #0f766e, primary-foreground: #ffffff, link: #0f766e, link-hover: #115e59,
  background: #fbfdfc, foreground: #10302c, muted: #eef6f4, muted-foreground: #4b635f, border: #cfe3df
);
$mt-overrides-dark: (
  primary: #2dd4bf, primary-foreground: #042f2b, link: #5eead4, link-hover: #99f6e4,
  background: #0b1615, foreground: #e3f2ef, muted: #13211f, muted-foreground: #9db5b0, border: #24403b
);
```

| Map | Tokens | Printed on |
|---|---|---|
| `$mt-overrides-base` | `font-sans`, `font-mono`, `font-heading`, `heading-weight`, `font-size`, `line-height`, `measure`, `narrow`, `radius` and the other scheme-free tokens | `:root` |
| `$mt-overrides` | colour tokens such as `primary`, `link`, `link-hover`, `background`, `foreground`, `border` | `:root` (light) |
| `$mt-overrides-dark` | the same colour tokens for dark mode | the dark-scheme selectors |

Set each colour in both maps. The dark selectors print every colour token again, so a value you set only in `$mt-overrides` does not reach dark mode.

The file holds only these three maps. `modootoday-check` fails on any other statement and on a token name the theme does not define, so a typo cannot pass unnoticed.

> [!TIP]
> `font-heading` and `heading-weight` style `h1` to `h4`; `link` and `link-hover` colour links in running text. By default they follow `font-sans`, 600 and `primary`, so a site that sets only `primary` sees no change. The recipe sets `heading-weight: 600` only to show where it goes; it is the default.

## Your own stylesheet and font

```yaml
modootoday:
  site_css: [/assets/css/site.css]
  preload:
    - {href: /assets/fonts/fraunces-600-latin.woff2, as: font, type: font/woff2}
```

- `site_css` links your sheets after the theme's, and before `modootoday.tokens` and `head-custom.html`. They get the same `?v=` query as the theme files. Add `site_css:` to a page's front matter to link a sheet on that page only; this page does that. With `css_layers: true`, your rules always win over the theme's.
- `preload` adds `<link rel="preload">` before the stylesheets, so the browser starts on the font while it reads the CSS. Fonts get `crossorigin`. The URL carries no `?v=` query: it has to match the `url()` in your `@font-face`, or the browser downloads the font twice. `preload:` in front matter works per page as well.

```scss
@font-face {
  font-family: "Fraunces";
  src: url("/assets/fonts/fraunces-600-latin.woff2") format("woff2");
  font-weight: 500 800;
  font-display: swap;
}
```

Both keys take site paths only. Load third-party sheets from `head-custom.html` instead.

## Contrast

Check both palettes before you ship them: body text on the background and on `muted`, `primary` and `link` on the background, and `primary-foreground` on `primary` need at least 4.5:1, as does `muted-foreground` on `accent`, the hover fill. `border-input`, the border of form fields, needs 3:1 on the background; `border` is a hairline and needs only 1.2:1, on the background and on `card`. The theme's docs QA measures this page in light and dark mode with the same rules.

## Under a strict CSP

The bridge, `site_css` and `preload` are all files, so `default-src 'self'; style-src 'self'` is enough (see [CSP](../csp/)). `modootoday.tokens` writes an inline `<style>` instead; on a strict CSP site, move those values into the bridge.

## The demo font

The heading font on this page is [Fraunces](https://github.com/undercasetype/Fraunces), licensed under the SIL Open Font License 1.1. The docs ship one instance (weight 600) cut down to Latin. The licence and the source are next to the file in `docs/assets/fonts/fraunces/`. Headings in other scripts fall back to `font-sans`.
