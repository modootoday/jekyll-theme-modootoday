---
id: adr:modootoday/20261103191401
title: Type scale and layout hooks are build-time Sass maps read through var() fallbacks
status: active
created: 2026-11-03T19:14:01Z
updated: 2026-11-03T19:14:22Z
rel:
  governs: [_sass/modootoday/tokens/_scale.scss, _sass/modootoday/tokens/_fonts.scss]
---

# Type scale and layout hooks are build-time Sass maps read through var() fallbacks

## Context

The flat base needs a role-based type scale on a 4px baseline, tracking and motion values, and later layout knobs (sidebar, TOC and doc widths, the primary button colours, the hero title size). Every `:root` custom property costs bytes in the core sheet, twice for a dark value, and the core sheet has little headroom. The planned token and component registries will own these defaults and generate them, so they need one place now that the generator can take over without moving files. Korean, Japanese and Chinese text also needs its own font stack, but one stack for every language put Korean fonts before Japanese ones, and printing every stack would charge English-only sites for scripts they never show.

## Decision

- The type scale (`$mt-type`, `xs` 12/16 to `6xl` 56/64), tracking (`$mt-tracking`) and motion (`$mt-motion`) are `!default` Sass maps in `tokens/_scale.scss`. `mt-size()` and `mt-leading()` in `tools/_functions.scss` return their values as literals, so they print no custom property. Every sheet imports the scale; it has no output.
- Layout knobs are hooks: a component reads `var(--mt-<name>, <default>)` and the theme never declares the property, so a site sets it in its own CSS and the core sheet pays only for the fallback. Their defaults go in one Sass map, `registry/_hooks.scss`, read through `mt-hook()`, added with the first component that uses a hook. Names follow the component registry's (`--mt-sidebar-width`, `--mt-toc-width`, `--mt-doc-gap`, `--mt-doc-container`, `--mt-button-primary-bg` and `-fg`, `--mt-hero-title-size`, `--mt-code-radius`), and the map also lists the hooks that exist today with their current defaults.
- Headings use the scale: h1 32/40, h2 24/32, h3 20/28, h4 16/24 at every width, line height `calc(1em + .5rem)`, -0.02em tracking and `text-wrap: balance`. CJK headings get no negative tracking and `calc(1em + .75rem)`.
- Per-language font stacks are a Sass map in `tokens/_fonts.scss`, keyed by codes from `i18n/languages.yml` (`ko`, `ja`, `zh-CN`, `zh-TW`). The core sheet prints `:root:lang(<code>) { --mt-font-sans: ... }` only for the languages the site declares: `config.html` builds `mt_langs` from `site.lang` and `modootoday.languages`, and `assets/css/modootoday.scss` passes it as `$mt-font-langs`, the same compile-time route as `$mt-css-layers`. A site that sets `font-sans` in the token bridge or in `modootoday.tokens` gets none, so its font wins in every language. Pretendard is named first for Korean but never shipped.
- Line breaking: Korean keeps `word-break: keep-all` in running text; Japanese gets `line-break: strict` and `word-break: auto-phrase` under `@supports`. The showcase hero no longer forces keep-all on every language.

## Consequences

The core sheet grows only by the CJK rules and, on sites that declare them, the stacks (the docs site declares ko, ja, zh-CN and zh-TW); the size is measured with the classic builder in the commit that lands this. Pages that declare a CJK language without listing it in `modootoday.languages` fall back to the generic `font-sans`, which no longer names Noto Sans KR or JP. A site cannot change a scale step at runtime, only through the Sass maps or its own CSS, until the registry exposes them. The registry generator later writes the same three files.
