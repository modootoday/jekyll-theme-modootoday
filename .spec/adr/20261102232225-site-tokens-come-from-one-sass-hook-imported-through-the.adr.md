---
id: adr:modootoday/20261102232225
title: Site tokens come from one Sass hook imported through the load path before the settings
status: active
created: 2026-11-02T23:22:25Z
updated: 2026-11-02T23:23:08Z
rel:
  governs: [_sass/modootoday/_site.scss, _sass/modootoday/tokens, lib/modootoday/check/source/site_hook.rb]
---

# Site tokens come from one Sass hook imported through the load path before the settings

## Context

A site could change semantic tokens only through `modootoday.tokens` (an inline `<style>`, blocked by a strict CSP) or by shadowing `assets/css/modootoday.scss` to set `$mt-overrides` (it then misses entry-sheet updates, and the optional sheets never saw the value). `$mt-base`, which holds the fonts, had no override map at all. Brand design systems also want a heading font, a heading weight and a link colour apart from `primary`.

## Decision

- `_sass/modootoday/_site.scss` is the token hook: empty in the theme, shadowed by the site. `_core.scss` and `_sheet.scss` import it first, as `modootoday/site`. The path goes through the load path on purpose: a relative `@import "site"` resolves next to the importing theme file before the load path, so the site's copy would never be read. Jekyll puts the site's `_sass/` before the theme's on both stacks.
- Three maps: `$mt-overrides-base` (new, merged into `$mt-base`), `$mt-overrides` and `$mt-overrides-dark`. The merges live in `tokens/_merge.scss`, so `_semantic.scss` only defines the maps.
- New semantic tokens `font-heading` and `heading-weight` (base) and `link` and `link-hover` (light and dark). Their defaults are `var(--mt-font-sans)`, 650, `var(--mt-primary)` and `var(--mt-link)`, the values headings and links had, so rendering is unchanged. `link` and `link-hover` are in both colour maps, so a light-only override cannot leak into dark mode. The hover colour uses `a:where(:hover)`, element weight only, so links that components colour keep their own hover.
- The hook file and its three maps are public API; every other Sass partial stays internal. `modootoday-check` allows only the three map assignments in the hook and only token names defined in the theme's maps (read from `_semantic.scss`, so there is no second list to keep in sync).

## Consequences

Sites restyle the theme under a strict CSP without shadowing an entry sheet, and the optional sheets see the same settings. An empty hook builds byte-identical output to having none. The core sheet grows by the four new custom properties. `tokens.json` gains the tokens as DTCG aliases where they reference another token.
